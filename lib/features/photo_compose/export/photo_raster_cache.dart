import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../logic/image_processor.dart';
import '../models/photo_edits.dart';
import '../models/photo_item.dart';

/// Bakes photos to bitmaps once and hands the result to every exporter.
///
/// A sheet full of the same 35 × 45 mm photo would otherwise decode and resize
/// the same JPEG forty times over. Decoded sources are cached for the lifetime
/// of one export run, and so are the final scaled bitmaps.
class PhotoRasterCache {
  PhotoRasterCache({this.backgroundColor = 0xFFFFFFFF});

  /// Packed ARGB colour used behind letterboxed photos.
  final int backgroundColor;

  final Map<String, img.Image> _decoded = {};
  final Map<String, img.Image> _rendered = {};
  final Map<String, Uint8List> _encoded = {};

  /// Number of distinct bitmaps produced so far — useful for progress display.
  int get renderedCount => _rendered.length;

  /// Decodes [item]'s source bytes, reusing an earlier decode when possible.
  ///
  /// Throws [FormatException] for unsupported data.
  img.Image decodedSource(PhotoItem item) {
    final cached = _decoded[item.id];
    if (cached != null) return cached;
    final decoded = ImageProcessor.decode(item.bytes);
    if (decoded == null) {
      throw FormatException('Could not decode "${item.fileName}"');
    }
    _decoded[item.id] = decoded;
    return decoded;
  }

  /// Returns [item] rendered at exactly `width × height` pixels, with [edits]
  /// applied. [edits] may differ from `item.edits` when the layout engine has
  /// rotated the photo on the sheet.
  img.Image render(
    PhotoItem item, {
    required PhotoEdits edits,
    required int width,
    required int height,
  }) {
    final key = '${item.id}|${edits.signature}|${item.fit.name}|${width}x$height';
    final cached = _rendered[key];
    if (cached != null) return cached;

    final rendered = ImageProcessor.fitInto(
      ImageProcessor.applyEdits(decodedSource(item), edits),
      targetWidth: width,
      targetHeight: height,
      fit: item.fit,
      backgroundColor: backgroundColor,
    );
    _rendered[key] = rendered;
    return rendered;
  }

  /// Same as [render], but returns JPEG bytes ready to embed in a PDF.
  ///
  /// JPEG keeps PDFs an order of magnitude smaller than PNG for photographic
  /// content, which matters a lot when a document holds dozens of prints.
  Uint8List encodedJpeg(
    PhotoItem item, {
    required PhotoEdits edits,
    required int width,
    required int height,
    int quality = 92,
  }) {
    final key = '${item.id}|${edits.signature}|${item.fit.name}|${width}x$height|q$quality';
    final cached = _encoded[key];
    if (cached != null) return cached;

    final bytes = Uint8List.fromList(
      img.encodeJpg(
        render(item, edits: edits, width: width, height: height),
        quality: quality,
      ),
    );
    _encoded[key] = bytes;
    return bytes;
  }

  /// Releases every cached bitmap. Call once an export finishes so a large job
  /// does not keep hundreds of megabytes alive.
  void dispose() {
    _decoded.clear();
    _rendered.clear();
    _encoded.clear();
  }
}
