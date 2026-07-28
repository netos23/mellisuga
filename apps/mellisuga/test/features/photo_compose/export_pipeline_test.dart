import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mellisuga/core/units/length.dart';
import 'package:mellisuga/core/units/paper_format.dart';
import 'package:mellisuga/features/photo_compose/export/export_options.dart';
import 'package:mellisuga/features/photo_compose/export/pdf_exporter.dart';
import 'package:mellisuga/features/photo_compose/export/photo_raster_cache.dart';
import 'package:mellisuga/features/photo_compose/export/raster_exporter.dart';
import 'package:mellisuga/features/photo_compose/logic/layout_engine.dart';
import 'package:mellisuga/features/photo_compose/logic/photo_importer.dart';
import 'package:mellisuga/features/photo_compose/models/layout_settings.dart';
import 'package:mellisuga/features/photo_compose/models/photo_edits.dart';
import 'package:mellisuga/features/photo_compose/models/photo_item.dart';
import 'package:mellisuga/features/photo_compose/models/photo_size.dart';

/// Builds a recognisable test image: a red field with a blue top-left quadrant,
/// so rotations and flips are detectable in the output.
Uint8List _testPng({int width = 600, int height = 400}) {
  final image = img.Image(width: width, height: height, numChannels: 3);
  img.fill(image, color: img.ColorRgb8(200, 30, 30));
  img.fillRect(
    image,
    x1: 0,
    y1: 0,
    x2: width ~/ 2,
    y2: height ~/ 2,
    color: img.ColorRgb8(30, 60, 220),
  );
  return Uint8List.fromList(img.encodePng(image));
}

Future<PhotoItem> _importTestPhoto({
  String id = 'photo-0',
  int width = 600,
  int height = 400,
  PhotoPrintSize? size,
  PhotoEdits edits = const PhotoEdits(),
}) async {
  final item = await PhotoImporter.import(
    id: id,
    fileName: '$id.png',
    bytes: _testPng(width: width, height: height),
  );
  return size == null ? item.copyWith(edits: edits) : item.copyWith(printSize: size, edits: edits);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PhotoImporter', () {
    test('decodes an image and records its natural size', () async {
      final item = await _importTestPhoto(width: 800, height: 600);
      expect(item.naturalWidth, 800);
      expect(item.naturalHeight, 600);
      expect(item.image.width, greaterThan(0));
    });

    test('caps the preview but keeps the natural size intact', () async {
      final item = await _importTestPhoto(width: 4000, height: 3000);
      expect(item.naturalWidth, 4000);
      expect(item.image.width, PhotoImporter.previewMaxEdge);
      expect(item.image.height, closeTo(PhotoImporter.previewMaxEdge * 3 / 4, 2));
    });

    test('records whether the source carried an alpha channel', () async {
      final opaque = await _importTestPhoto();
      expect(opaque.sourceHasAlpha, isFalse);

      final transparent = img.Image(width: 40, height: 40, numChannels: 4);
      img.fill(transparent, color: img.ColorRgba8(10, 20, 30, 128));
      final item = await PhotoImporter.import(
        id: 'alpha',
        fileName: 'alpha.png',
        bytes: Uint8List.fromList(img.encodePng(transparent)),
      );
      expect(item.sourceHasAlpha, isTrue);
    });

    test('starts landscape photos with a landscape print size', () async {
      final item = await _importTestPhoto(width: 800, height: 600);
      expect(item.printSize.isLandscape, isTrue);
    });

    test('rejects data that is not an image', () async {
      expect(
        () => PhotoImporter.import(
          id: 'bad',
          fileName: 'bad.png',
          bytes: Uint8List.fromList([1, 2, 3, 4, 5]),
        ),
        throwsA(isA<ImportException>()),
      );
    });

    test('rejects an empty file', () async {
      expect(
        () => PhotoImporter.import(id: 'empty', fileName: 'empty.png', bytes: Uint8List(0)),
        throwsA(isA<ImportException>()),
      );
    });
  });

  group('effective DPI', () {
    test('is computed from the natural resolution and the print size', () async {
      // 600 px across a 50.8 mm (2 in) print is 300 DPI.
      final item = await _importTestPhoto(
        width: 600,
        height: 600,
        size: const PhotoPrintSize(widthMm: 50.8, heightMm: 50.8),
      );
      expect(item.effectiveDpi, closeTo(300, 0.5));
    });

    test('drops when the photo is cropped', () async {
      final item = await _importTestPhoto(
        width: 600,
        height: 600,
        size: const PhotoPrintSize(widthMm: 50.8, heightMm: 50.8),
        edits: const PhotoEdits(cropRect: Rect.fromLTWH(0, 0, 0.5, 0.5)),
      );
      expect(item.effectiveDpi, closeTo(150, 0.5));
    });
  });

  group('RasterExporter', () {
    test('produces one file per page at exactly the requested DPI', () async {
      final item = await _importTestPhoto(size: const PhotoPrintSize(widthMm: 100, heightMm: 150));
      const settings = LayoutSettings();
      final layout = LayoutEngine.compose(
        inputs: [LayoutInput(itemId: item.id, widthMm: 100, heightMm: 150, copies: 5)],
        settings: settings,
      );

      final files = await RasterExporter.export(
        layout: layout,
        settings: settings,
        itemsById: {item.id: item},
        options: const ExportOptions(dpi: 150),
      );

      expect(files.length, layout.pageCount);
      final decoded = img.decodePng(files.first.bytes)!;
      expect(decoded.width, settings.pageWidthMm.mmToPixels(150).round());
      expect(decoded.height, settings.pageHeightMm.mmToPixels(150).round());
    });

    test('names multi-page output with a page suffix', () async {
      final item = await _importTestPhoto(size: const PhotoPrintSize(widthMm: 100, heightMm: 150));
      const settings = LayoutSettings();
      final layout = LayoutEngine.compose(
        inputs: [LayoutInput(itemId: item.id, widthMm: 100, heightMm: 150, copies: 3)],
        settings: settings,
      );
      final files = await RasterExporter.export(
        layout: layout,
        settings: settings,
        itemsById: {item.id: item},
        options: const ExportOptions(dpi: 100, fileNameStem: 'sheet'),
      );
      expect(files.length, 2);
      expect(files[0].fileName, 'sheet-01.png');
      expect(files[1].fileName, 'sheet-02.png');
    });

    test('paints the configured background across the whole sheet', () async {
      final item = await _importTestPhoto(size: const PhotoPrintSize(widthMm: 50, heightMm: 50));
      const settings = LayoutSettings(backgroundColor: Color(0xFF00FF00));
      final layout = LayoutEngine.compose(
        inputs: [LayoutInput(itemId: item.id, widthMm: 50, heightMm: 50)],
        settings: settings,
      );
      final files = await RasterExporter.export(
        layout: layout,
        settings: settings,
        itemsById: {item.id: item},
        options: const ExportOptions(dpi: 72),
      );
      final decoded = img.decodePng(files.single.bytes)!;
      // A corner pixel is inside the margin, so it must be the sheet colour.
      final corner = decoded.getPixel(2, 2);
      expect(corner.r.round(), 0);
      expect(corner.g.round(), 255);
      expect(corner.b.round(), 0);
    });

    test('refuses a page bitmap that would be too large to allocate', () async {
      final item = await _importTestPhoto();
      const settings = LayoutSettings(paper: PaperFormats.a2);
      final layout = LayoutEngine.compose(
        inputs: [LayoutInput(itemId: item.id, widthMm: 50, heightMm: 50)],
        settings: settings,
      );
      expect(
        () => RasterExporter.export(
          layout: layout,
          settings: settings,
          itemsById: {item.id: item},
          options: const ExportOptions(dpi: 1200),
        ),
        throwsA(isA<RasterExportTooLargeException>()),
      );
    });

    test('reports progress from start to finish', () async {
      final item = await _importTestPhoto(size: const PhotoPrintSize(widthMm: 100, heightMm: 150));
      const settings = LayoutSettings();
      final layout = LayoutEngine.compose(
        inputs: [LayoutInput(itemId: item.id, widthMm: 100, heightMm: 150, copies: 3)],
        settings: settings,
      );
      final fractions = <double>[];
      await RasterExporter.export(
        layout: layout,
        settings: settings,
        itemsById: {item.id: item},
        options: const ExportOptions(dpi: 72),
        onProgress: (fraction, _) => fractions.add(fraction),
      );
      expect(fractions, isNotEmpty);
      expect(fractions.last, closeTo(1, 1e-9));
    });
  });

  group('PdfExporter', () {
    test('writes a valid PDF with the right page size', () async {
      final item = await _importTestPhoto(size: const PhotoPrintSize(widthMm: 100, heightMm: 150));
      const settings = LayoutSettings();
      final layout = LayoutEngine.compose(
        inputs: [LayoutInput(itemId: item.id, widthMm: 100, heightMm: 150, copies: 2)],
        settings: settings,
      );

      final file = await PdfExporter.export(
        layout: layout,
        settings: settings,
        itemsById: {item.id: item},
        options: const ExportOptions(dpi: 150, fileNameStem: 'sheets'),
      );

      expect(file.fileName, 'sheets.pdf');
      expect(file.mimeType, 'application/pdf');
      // A PDF always begins with the %PDF- header.
      expect(String.fromCharCodes(file.bytes.take(5)), '%PDF-');
      // A4 in points, which is what the page box must declare.
      final text = String.fromCharCodes(file.bytes);
      expect(text, contains('595.2'));
    });

    test('handles rotated placements without error', () async {
      final item = await _importTestPhoto(size: const PhotoPrintSize(widthMm: 250, heightMm: 100));
      const settings = LayoutSettings();
      final layout = LayoutEngine.compose(
        inputs: [LayoutInput(itemId: item.id, widthMm: 250, heightMm: 100)],
        settings: settings,
      );
      expect(layout.pages.first.photos.first.rotated, isTrue);

      final file = await PdfExporter.export(
        layout: layout,
        settings: settings,
        itemsById: {item.id: item},
        options: const ExportOptions(dpi: 150),
      );
      expect(file.bytes.length, greaterThan(1000));
    });

    test('renders a repeated photo once, however many copies a sheet holds', () async {
      final item = await _importTestPhoto(size: const PhotoPrintSize(widthMm: 35, heightMm: 45));
      const settings = LayoutSettings();
      final layout = LayoutEngine.compose(
        inputs: [LayoutInput(itemId: item.id, widthMm: 35, heightMm: 45, copies: 20)],
        settings: settings,
      );

      final progress = <String>[];
      final file = await PdfExporter.export(
        layout: layout,
        settings: settings,
        itemsById: {item.id: item},
        options: const ExportOptions(dpi: 200),
        onProgress: (_, message) => progress.add(message),
      );
      expect(file.bytes.length, greaterThan(1000));

      // Placements that would come out pixel for pixel identical share one
      // bitmap, so the only thing that can multiply the work is the packer
      // turning some copies on their side.
      final distinctShapes = layout.pages
          .expand((page) => page.photos)
          .map((placed) => '${placed.rotated}|${placed.widthMm}x${placed.heightMm}')
          .toSet();
      final renders = progress.where((m) => m.startsWith('Rendering')).length;
      expect(renders, distinctShapes.length);
      expect(renders, lessThan(20));
    });

    test('stores a repeated photo once instead of once per copy', () async {
      final item = await _importTestPhoto(size: const PhotoPrintSize(widthMm: 35, heightMm: 45));
      const settings = LayoutSettings();

      Future<int> bytesFor(int copies) async {
        final layout = LayoutEngine.compose(
          inputs: [LayoutInput(itemId: item.id, widthMm: 35, heightMm: 45, copies: copies)],
          settings: settings,
        );
        final file = await PdfExporter.export(
          layout: layout,
          settings: settings,
          itemsById: {item.id: item},
          options: const ExportOptions(dpi: 200),
        );
        return file.bytes.length;
      }

      final single = await bytesFor(1);
      final twenty = await bytesFor(20);
      // Twenty placements add twenty small drawing operations, not twenty
      // embedded JPEGs — which would put this an order of magnitude higher.
      expect(twenty, lessThan(single * 4));
    });

    test('reaches full progress', () async {
      final item = await _importTestPhoto(size: const PhotoPrintSize(widthMm: 100, heightMm: 150));
      const settings = LayoutSettings();
      final layout = LayoutEngine.compose(
        inputs: [LayoutInput(itemId: item.id, widthMm: 100, heightMm: 150, copies: 3)],
        settings: settings,
      );
      final fractions = <double>[];
      await PdfExporter.export(
        layout: layout,
        settings: settings,
        itemsById: {item.id: item},
        options: const ExportOptions(dpi: 150),
        onProgress: (fraction, _) => fractions.add(fraction),
      );
      expect(fractions, isNotEmpty);
      expect(fractions.every((f) => f >= 0 && f <= 1), isTrue);
      expect(fractions.last, closeTo(1, 1e-9));
    });
  });

  group('PhotoRasterCache', () {
    test('renders at exactly the requested size from a much larger source', () async {
      final item = await _importTestPhoto(width: 4000, height: 3000);
      final cache = PhotoRasterCache();
      addTearDown(cache.dispose);

      final rendered = await cache.render(item, edits: item.edits, width: 200, height: 150);
      expect(rendered.width, 200);
      expect(rendered.height, 150);
    });

    test('crops from the source before downscaling it', () async {
      // The test image is blue in the top-left quadrant and red everywhere
      // else, so a crop of the right-hand half must come out entirely red.
      final item = (await _importTestPhoto(
        width: 2400,
        height: 1600,
      )).copyWith(edits: const PhotoEdits(cropRect: Rect.fromLTWH(0.5, 0, 0.5, 1)));
      final cache = PhotoRasterCache();
      addTearDown(cache.dispose);

      final rendered = await cache.render(item, edits: item.edits, width: 120, height: 160);
      final pixel = rendered.getPixel(rendered.width ~/ 2, rendered.height ~/ 4);
      expect(pixel.r.round(), greaterThan(150));
      expect(pixel.b.round(), lessThan(100));
    });

    test('keeps the whole source when the target needs every pixel', () async {
      final item = await _importTestPhoto(width: 300, height: 200);
      final cache = PhotoRasterCache();
      addTearDown(cache.dispose);

      final rendered = await cache.render(item, edits: item.edits, width: 900, height: 600);
      expect(rendered.width, 900);
      expect(rendered.height, 600);
    });

    test('rotates without losing the requested size', () async {
      final item = await _importTestPhoto(width: 2000, height: 1500);
      final cache = PhotoRasterCache();
      addTearDown(cache.dispose);

      final rendered = await cache.render(
        item,
        edits: const PhotoEdits(quarterTurns: 1),
        width: 150,
        height: 200,
      );
      expect(rendered.width, 150);
      expect(rendered.height, 200);
    });

    test('evicts old bitmaps instead of growing without bound', () async {
      final item = await _importTestPhoto(width: 1200, height: 900);
      // Room for roughly one 200 × 200 bitmap.
      final cache = PhotoRasterCache(maxRenderedBytes: 200 * 200 * 4);
      addTearDown(cache.dispose);

      for (var size = 200; size < 260; size++) {
        await cache.render(item, edits: item.edits, width: size, height: size);
      }
      expect(cache.renderedCount, lessThan(4));
    });

    test('renders the same pixels from the preview as from the original file', () async {
      final viaPreview = await _importTestPhoto(width: 2400, height: 1600);
      // The preview is only reused for photos without an alpha channel, so
      // claiming one is how a test forces the decode-the-original path.
      final viaOriginal = PhotoItem(
        id: viaPreview.id,
        fileName: viaPreview.fileName,
        bytes: viaPreview.bytes,
        image: viaPreview.image,
        naturalWidth: viaPreview.naturalWidth,
        naturalHeight: viaPreview.naturalHeight,
        sourceHasAlpha: true,
        printSize: viaPreview.printSize,
      );

      final cache = PhotoRasterCache();
      addTearDown(cache.dispose);
      final fromPreview = await cache.render(
        viaPreview,
        edits: viaPreview.edits,
        width: 300,
        height: 200,
      );
      final fromOriginal = await cache.render(
        viaOriginal,
        edits: viaOriginal.edits,
        width: 300,
        height: 200,
      );

      expect(fromPreview.width, fromOriginal.width);
      expect(fromPreview.height, fromOriginal.height);
      // Well inside the blue quadrant and well inside the red field, where no
      // resampling difference can reach.
      for (final point in [(40, 30), (250, 150)]) {
        final preview = fromPreview.getPixel(point.$1, point.$2);
        final original = fromOriginal.getPixel(point.$1, point.$2);
        expect(preview.r.round(), closeTo(original.r.round(), 2));
        expect(preview.g.round(), closeTo(original.g.round(), 2));
        expect(preview.b.round(), closeTo(original.b.round(), 2));
        expect(preview.a.round(), 255);
      }
    });

    test('serves a second, smaller print from the source it already holds', () async {
      final item = await _importTestPhoto(width: 3000, height: 2000);
      final cache = PhotoRasterCache();
      addTearDown(cache.dispose);

      final large = await cache.render(item, edits: item.edits, width: 600, height: 400);
      final small = await cache.render(item, edits: item.edits, width: 150, height: 100);
      expect(large.width, 600);
      expect(small.width, 150);

      cache.releaseSource(item.id);
      // Dropping the source is not supposed to change what comes back out.
      final again = await cache.render(item, edits: item.edits, width: 150, height: 100);
      expect(again.width, 150);
      expect(again.height, 100);
    });
  });
}
