import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../../core/units/length.dart';
import '../logic/divider_geometry.dart';
import '../logic/image_processor.dart';
import '../models/layout_result.dart';
import '../models/layout_settings.dart';
import '../models/photo_item.dart';
import 'export_options.dart';
import 'photo_raster_cache.dart';

/// Renders composed sheets to PNG or JPEG bitmaps, one file per page.
///
/// Everything is computed in millimetres and converted to pixels exactly once,
/// at the requested DPI, so a 300 DPI A4 sheet comes out at precisely
/// 2480 × 3508 px.
abstract final class RasterExporter {
  /// Refuse to allocate a canvas beyond this many pixels per page. At 600 DPI
  /// an A2 sheet is already ~190 MP, and browsers will simply die trying.
  static const int maxPixelsPerPage = 220 * 1000 * 1000;

  static Future<List<ExportedFile>> export({
    required LayoutResult layout,
    required LayoutSettings settings,
    required Map<String, PhotoItem> itemsById,
    required ExportOptions options,
    ExportProgress? onProgress,
  }) async {
    // ignore: deprecated_member_use
    final backgroundArgb = settings.backgroundColor.value;
    final cache = PhotoRasterCache(backgroundColor: backgroundArgb);
    final results = <ExportedFile>[];

    try {
      final pageWidthPx = _pixelsFor(settings.pageWidthMm, options.dpi);
      final pageHeightPx = _pixelsFor(settings.pageHeightMm, options.dpi);

      if (pageWidthPx * pageHeightPx > maxPixelsPerPage) {
        throw RasterExportTooLargeException(
          widthPx: pageWidthPx,
          heightPx: pageHeightPx,
          dpi: options.dpi,
        );
      }

      final pageCount = layout.pages.length;
      for (final page in layout.pages) {
        final canvas = img.Image(width: pageWidthPx, height: pageHeightPx, numChannels: 4);
        img.fill(canvas, color: ImageProcessor.colorFromArgb(canvas, backgroundArgb));

        for (final placed in page.photos) {
          final item = itemsById[placed.itemId];
          if (item == null) continue;

          final effectiveEdits = placed.rotated
              ? item.edits.copyWith(quarterTurns: item.edits.quarterTurns + 1)
              : item.edits;

          final widthPx = _pixelsFor(placed.widthMm, options.dpi);
          final heightPx = _pixelsFor(placed.heightMm, options.dpi);

          final rendered = cache.render(
            item,
            edits: effectiveEdits,
            width: widthPx,
            height: heightPx,
          );

          img.compositeImage(
            canvas,
            rendered,
            dstX: _pixelsFor(placed.xMm, options.dpi, minimum: 0),
            dstY: _pixelsFor(placed.yMm, options.dpi, minimum: 0),
          );
        }

        _drawGuides(canvas, page, settings, options.dpi);

        onProgress?.call(
          (page.index + 0.5) / pageCount,
          'Encoding page ${page.index + 1} of $pageCount',
        );
        await Future<void>.delayed(Duration.zero);

        final bytes = switch (options.format) {
          RasterFormat.png => Uint8List.fromList(img.encodePng(canvas)),
          RasterFormat.jpeg => Uint8List.fromList(
            img.encodeJpg(canvas, quality: options.jpegQuality),
          ),
        };

        results.add(
          ExportedFile(
            fileName: pageCount == 1
                ? '${options.fileNameStem}.${options.format.extension}'
                : '${options.fileNameStem}-'
                      '${(page.index + 1).toString().padLeft(2, '0')}'
                      '.${options.format.extension}',
            bytes: bytes,
            mimeType: options.format.mimeType,
          ),
        );

        onProgress?.call((page.index + 1) / pageCount, 'Page ${page.index + 1} ready');
        await Future<void>.delayed(Duration.zero);
      }

      return results;
    } finally {
      cache.dispose();
    }
  }

  static void _drawGuides(img.Image canvas, ComposedPage page, LayoutSettings settings, int dpi) {
    final guides = DividerGeometry.buildDashed(page, settings);
    if (guides.isEmpty) return;

    // ignore: deprecated_member_use
    final color = ImageProcessor.colorFromArgb(canvas, settings.dividerColor.value);
    final thickness = math.max(1.0, settings.dividerWidthMm.mmToPixels(dpi.toDouble()));

    for (final guide in guides) {
      img.drawLine(
        canvas,
        x1: guide.x1.mmToPixels(dpi.toDouble()).round(),
        y1: guide.y1.mmToPixels(dpi.toDouble()).round(),
        x2: guide.x2.mmToPixels(dpi.toDouble()).round(),
        y2: guide.y2.mmToPixels(dpi.toDouble()).round(),
        color: color,
        thickness: thickness,
        antialias: true,
      );
    }
  }

  static int _pixelsFor(double millimeters, int dpi, {int minimum = 1}) {
    final pixels = millimeters.mmToPixels(dpi.toDouble()).round();
    return pixels < minimum ? minimum : pixels;
  }
}

/// Thrown when the requested page bitmap would be too large to allocate.
class RasterExportTooLargeException implements Exception {
  const RasterExportTooLargeException({
    required this.widthPx,
    required this.heightPx,
    required this.dpi,
  });

  final int widthPx;
  final int heightPx;
  final int dpi;

  @override
  String toString() =>
      'A $dpi DPI page would be $widthPx × $heightPx pixels, which is too large '
      'to render in memory. Try a lower DPI, or export a PDF instead.';
}
