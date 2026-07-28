import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../../core/units/length.dart';
import '../logic/divider_geometry.dart';
import '../logic/image_processor.dart';
import '../models/layout_result.dart';
import '../models/layout_settings.dart';
import '../models/photo_item.dart';
import 'export_options.dart';
import 'photo_raster_cache.dart';
import 'render_plan.dart';

/// Renders composed sheets to PNG or JPEG bitmaps, one file per page.
///
/// Everything is computed in millimetres and converted to pixels exactly once,
/// at the requested DPI, so a 300 DPI A4 sheet comes out at precisely
/// 2480 × 3508 px.
///
/// Each page is composited from a plan rather than straight down the placement
/// list, so a photo repeated across a sheet is decoded and resampled once and
/// then stamped everywhere it appears.
abstract final class RasterExporter {
  /// Refuse to allocate a canvas beyond this many pixels per page.
  ///
  /// At four bytes a pixel the browser ceiling is already a 160 MB allocation,
  /// and a mobile tab does not survive much beyond that — for anything larger
  /// the PDF path is the right answer. Native builds can be trusted with far
  /// more: at 600 DPI an A2 sheet is ~190 MP.
  static int get maxPixelsPerPage => kIsWeb ? 40 * 1000 * 1000 : 220 * 1000 * 1000;

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
      final pageWidthPx = pixelsFor(settings.pageWidthMm, options.dpi);
      final pageHeightPx = pixelsFor(settings.pageHeightMm, options.dpi);

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

        // Photos never overlap on a sheet, so compositing them grouped by source
        // rather than in placement order changes nothing about the result — and
        // it keeps one decode alive at a time instead of interleaving them.
        final jobs = planRenderJobs(pages: [page], itemsById: itemsById, dpi: options.dpi);
        for (final job in jobs) {
          final rendered = await cache.render(
            job.item,
            edits: job.edits,
            width: job.widthPx,
            height: job.heightPx,
          );

          for (final placed in job.placements) {
            img.compositeImage(
              canvas,
              rendered,
              dstX: pixelsFor(placed.xMm, options.dpi, minimum: 0),
              dstY: pixelsFor(placed.yMm, options.dpi, minimum: 0),
            );
          }
          await breathe();
        }

        _drawGuides(canvas, page, settings, options.dpi);

        onProgress?.call(
          (page.index + 0.5) / pageCount,
          'Encoding page ${page.index + 1} of $pageCount',
        );
        await breathe();

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
        await breathe();
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
