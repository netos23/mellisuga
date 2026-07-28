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
import 'render_plan.dart';

/// Writes a composed sheet set to a print-ready PDF.
///
/// Photos are embedded as JPEGs sized to their exact printed dimensions, and
/// cutting guides are drawn as real vector strokes rather than baked pixels —
/// so guides stay crisp at any zoom and the file stays small.
///
/// The work is planned before a single pixel is touched. Placements that would
/// produce identical pixels — the twenty copies of one passport photo filling a
/// sheet, the same photo repeated across three pages — share one
/// [pw.MemoryImage], so the photo is decoded, resampled and encoded once and
/// stored in the document once. Rendering then walks that plan photo by photo
/// and releases each decoded source before opening the next, holding roughly one
/// photo in memory instead of the whole set. On a phone browser that is the
/// difference between a fifteen-photo export finishing and the tab being killed.
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

      final jobs = planRenderJobs(pages: layout.pages, itemsById: itemsById, dpi: options.dpi);

      final images = <String, pw.MemoryImage>{};
      for (var index = 0; index < jobs.length; index++) {
        final job = jobs[index];
        final jpeg = await cache.encodedJpeg(
          job.item,
          edits: job.edits,
          width: job.widthPx,
          height: job.heightPx,
          quality: options.jpegQuality,
        );
        images[job.key] = pw.MemoryImage(jpeg);
        if (job.lastOfSource) cache.releaseSource(job.item.id);

        onProgress?.call(
          (index + 1) / jobs.length * 0.85,
          'Rendering photo ${index + 1} of ${jobs.length}',
        );
        // Hand the frame back so the progress indicator can actually paint.
        await breathe();
      }

      final pageCount = layout.pages.length;
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

          final image =
              images[renderJobKey(
                item,
                effectiveEditsFor(item, placed),
                pixelsFor(placed.widthMm, options.dpi),
                pixelsFor(placed.heightMm, options.dpi),
              )];
          if (image == null) continue;

          children.add(
            pw.Positioned(
              left: placed.xMm.mmToPdfPoints,
              top: placed.yMm.mmToPdfPoints,
              child: pw.Image(
                image,
                width: placed.widthMm.mmToPdfPoints,
                height: placed.heightMm.mmToPdfPoints,
                fit: pw.BoxFit.fill,
              ),
            ),
          );
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

        onProgress?.call(
          0.85 + (page.index + 1) / pageCount * 0.1,
          'Composing page ${page.index + 1} of $pageCount',
        );
        await breathe();
      }

      // Nothing below needs a bitmap again, and writing the document is the
      // other memory peak — meet it with the caches already empty.
      cache.dispose();

      onProgress?.call(0.95, 'Writing PDF');
      await breathe();
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

  static PdfColor _toPdfColor(ui.Color color) => PdfColor(color.r, color.g, color.b, color.a);
}
