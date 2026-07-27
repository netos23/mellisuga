import 'dart:ui' as ui;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/app_info.dart';
import '../../../core/units/length.dart';
import '../logic/divider_geometry.dart';
import '../models/layout_result.dart';
import '../models/layout_settings.dart';
import '../models/photo_item.dart';
import 'export_options.dart';
import 'photo_raster_cache.dart';

/// Writes a composed sheet set to a print-ready PDF.
///
/// Photos are embedded as JPEGs sized to their exact printed dimensions, and
/// cutting guides are drawn as real vector strokes rather than baked pixels —
/// so guides stay crisp at any zoom and the file stays small.
abstract final class PdfExporter {
  static Future<ExportedFile> export({
    required LayoutResult layout,
    required LayoutSettings settings,
    required Map<String, PhotoItem> itemsById,
    required ExportOptions options,
    ExportProgress? onProgress,
  }) async {
    final cache = PhotoRasterCache(
      // ignore: deprecated_member_use
      backgroundColor: settings.backgroundColor.value,
    );

    try {
      final document = pw.Document(
        title: options.embedMetadata ? options.fileNameStem : null,
        creator: options.embedMetadata ? AppInfo.name : null,
        producer: options.embedMetadata ? '${AppInfo.name} ${AppInfo.version}' : null,
      );

      final pageWidthPt = settings.pageWidthMm.mmToPdfPoints;
      final pageHeightPt = settings.pageHeightMm.mmToPdfPoints;
      final background = _toPdfColor(settings.backgroundColor);

      final totalPhotos = layout.placedCount;
      var processed = 0;

      for (final page in layout.pages) {
        final children = <pw.Widget>[
          pw.Positioned(
            left: 0,
            top: 0,
            child: pw.Container(width: pageWidthPt, height: pageHeightPt, color: background),
          ),
        ];

        for (final placed in page.photos) {
          final item = itemsById[placed.itemId];
          if (item == null) continue;

          // Folding the layout's 90° turn into the photo's own quarter turns
          // is exact: rotations compose, and flips are applied before both.
          final effectiveEdits = placed.rotated
              ? item.edits.copyWith(quarterTurns: item.edits.quarterTurns + 1)
              : item.edits;

          final widthPx = _pixelsFor(placed.widthMm, options.dpi);
          final heightPx = _pixelsFor(placed.heightMm, options.dpi);

          final jpeg = cache.encodedJpeg(
            item,
            edits: effectiveEdits,
            width: widthPx,
            height: heightPx,
            quality: options.jpegQuality,
          );

          children.add(
            pw.Positioned(
              left: placed.xMm.mmToPdfPoints,
              top: placed.yMm.mmToPdfPoints,
              child: pw.Image(
                pw.MemoryImage(jpeg),
                width: placed.widthMm.mmToPdfPoints,
                height: placed.heightMm.mmToPdfPoints,
                fit: pw.BoxFit.fill,
              ),
            ),
          );

          processed++;
          if (onProgress != null && totalPhotos > 0) {
            onProgress(processed / totalPhotos * 0.9, 'Rendering photo $processed of $totalPhotos');
          }
          // Hand the frame back so the progress indicator can actually paint.
          await Future<void>.delayed(Duration.zero);
        }

        final guides = DividerGeometry.buildDashed(page, settings);
        if (guides.isNotEmpty) {
          children.add(
            pw.Positioned(
              left: 0,
              top: 0,
              child: pw.SizedBox(
                width: pageWidthPt,
                height: pageHeightPt,
                child: pw.CustomPaint(
                  size: PdfPoint(pageWidthPt, pageHeightPt),
                  painter: (canvas, size) => _paintGuides(canvas, size, guides, settings),
                ),
              ),
            ),
          );
        }

        document.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(pageWidthPt, pageHeightPt),
            margin: pw.EdgeInsets.zero,
            build: (context) => pw.Stack(children: children),
          ),
        );
      }

      onProgress?.call(0.95, 'Writing PDF');
      final bytes = await document.save();
      onProgress?.call(1, 'Done');

      return ExportedFile(
        fileName: '${options.fileNameStem}.pdf',
        bytes: bytes,
        mimeType: 'application/pdf',
      );
    } finally {
      cache.dispose();
    }
  }

  static void _paintGuides(
    PdfGraphics canvas,
    PdfPoint size,
    List<GuideSegment> guides,
    LayoutSettings settings,
  ) {
    canvas
      ..setStrokeColor(_toPdfColor(settings.dividerColor))
      ..setLineWidth(settings.dividerWidthMm.mmToPdfPoints)
      ..setLineCap(PdfLineCap.butt);

    for (final guide in guides) {
      // PDF's origin is the bottom-left corner, so vertical coordinates flip.
      canvas.drawLine(
        guide.x1.mmToPdfPoints,
        size.y - guide.y1.mmToPdfPoints,
        guide.x2.mmToPdfPoints,
        size.y - guide.y2.mmToPdfPoints,
      );
    }
    canvas.strokePath();
  }

  static int _pixelsFor(double millimeters, int dpi) {
    final pixels = millimeters.mmToPixels(dpi.toDouble()).round();
    return pixels < 1 ? 1 : pixels;
  }

  static PdfColor _toPdfColor(ui.Color color) => PdfColor(color.r, color.g, color.b, color.a);
}
