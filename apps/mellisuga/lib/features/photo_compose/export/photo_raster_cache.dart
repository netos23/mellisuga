import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

import '../logic/image_processor.dart';
import '../models/photo_edits.dart';
import '../models/photo_item.dart';

/// Bakes photos to bitmaps once and hands the result to every exporter.
///
/// A sheet full of the same 35 × 45 mm photo would otherwise decode and resize
/// the same JPEG forty times over, so results are cached for the length of one
/// export run. Two rules keep that cache from becoming the very problem it
/// solves — which matters most in a phone browser, where a tab that reaches for
/// a few hundred megabytes is simply killed:
///
///  * **Sources are shrunk the moment they are decoded.** A 12 MP phone photo
///    printed at 35 × 45 mm needs about 0.2 MP. Dragging the other 11.8 MP
///    through crop, flip, rotate and resample costs ~50 MB of live bitmap per
///    photo and changes not one output pixel, so only the resolution the target
///    actually needs is kept. The full-resolution decode is transient: one
///    photo's worth at a time, never the whole set.
///  * **Every cache is bounded.** Sources and rendered bitmaps sit in
///    byte-budgeted LRUs, so a fifteen-photo export holds a handful of small
///    bitmaps rather than fifteen large ones.
///
/// Better still is not decoding at all. The import already decoded every photo
/// and kept a downscaled, orientation-baked copy for the preview; when that copy
/// still holds every pixel a print needs — anything up to roughly 12 cm on the
/// long edge at 300 DPI — it is used as-is, and larger prints go back to the
/// original file. Re-decoding a 12 MP JPEG in Dart costs seconds per photo, and
/// on a phone those seconds are the export.
class PhotoRasterCache {
  PhotoRasterCache({
    this.backgroundColor = 0xFFFFFFFF,
    this.maxSourceBytes = defaultMaxSourceBytes,
    this.maxRenderedBytes = defaultMaxRenderedBytes,
  });

  /// Budget for cached (already downscaled) source bitmaps.
  static const int defaultMaxSourceBytes = 48 * 1024 * 1024;

  /// Budget for cached output bitmaps.
  static const int defaultMaxRenderedBytes = 32 * 1024 * 1024;

  /// Resolution kept above what a target strictly needs.
  ///
  /// A little slack means the final resample still has something to work with —
  /// `cover` trims one axis, and rounding must never leave a photo a pixel short
  /// of its printed size.
  static const double sourceHeadroom = 1.2;

  /// Packed ARGB colour used behind letterboxed photos.
  final int backgroundColor;

  final int maxSourceBytes;
  final int maxRenderedBytes;

  // Both of these are LRUs. A Dart map literal keeps insertion order, so the
  // first key is always the least recently used one and re-inserting an entry
  // moves it to the young end.

  /// Decoded sources, keyed by photo id.
  final Map<String, _CachedSource> _sources = {};

  /// Finished bitmaps, keyed by everything that affects their pixels.
  final Map<String, img.Image> _rendered = {};

  final Map<String, Uint8List> _encoded = {};

  int _sourceBytes = 0;
  int _renderedBytes = 0;

  /// Number of distinct bitmaps currently held.
  int get renderedCount => _rendered.length;

  /// Returns [item] rendered at exactly `width × height` pixels, with [edits]
  /// applied. [edits] may differ from `item.edits` when the layout engine has
  /// rotated the photo on the sheet.
  Future<img.Image> render(
    PhotoItem item, {
    required PhotoEdits edits,
    required int width,
    required int height,
  }) async {
    final key = _bitmapKey(item, edits, width, height);
    final cached = _rendered.remove(key);
    if (cached != null) {
      // Re-inserting moves the entry to the young end of the LRU.
      _rendered[key] = cached;
      return cached;
    }

    final rendered = await _rasterise(item, edits: edits, width: width, height: height);
    _rendered[key] = rendered;
    _renderedBytes += _bytesOf(rendered);
    _trimRendered();
    return rendered;
  }

  /// Same as [render], but returns JPEG bytes ready to embed in a PDF.
  ///
  /// JPEG keeps PDFs an order of magnitude smaller than PNG for photographic
  /// content, which matters a lot when a document holds dozens of prints.
  ///
  /// The intermediate bitmap is deliberately not cached: it is twenty times the
  /// size of the JPEG it just produced, and the PDF path never asks for those
  /// pixels again.
  Future<Uint8List> encodedJpeg(
    PhotoItem item, {
    required PhotoEdits edits,
    required int width,
    required int height,
    int quality = 92,
  }) async {
    final bitmapKey = _bitmapKey(item, edits, width, height);
    final key = '$bitmapKey|q$quality';
    final cached = _encoded[key];
    if (cached != null) return cached;

    final bitmap =
        _rendered[bitmapKey] ?? await _rasterise(item, edits: edits, width: width, height: height);
    final bytes = Uint8List.fromList(img.encodeJpg(bitmap, quality: quality));
    _encoded[key] = bytes;
    return bytes;
  }

  /// Drops the decoded source for [itemId].
  ///
  /// Exporters call this once every output that needs a photo has been produced,
  /// which keeps the peak at roughly one photo rather than the whole set.
  void releaseSource(String itemId) {
    final removed = _sources.remove(itemId);
    if (removed != null) _sourceBytes -= _bytesOf(removed.image);
  }

  /// Releases every cached bitmap. Call once an export finishes so a large job
  /// does not keep hundreds of megabytes alive.
  void dispose() {
    _sources.clear();
    _rendered.clear();
    _encoded.clear();
    _sourceBytes = 0;
    _renderedBytes = 0;
  }

  Future<img.Image> _rasterise(
    PhotoItem item, {
    required PhotoEdits edits,
    required int width,
    required int height,
  }) async {
    final source = await _sourceFor(item, edits: edits, width: width, height: height);
    return ImageProcessor.fitInto(
      ImageProcessor.applyEdits(source, edits),
      targetWidth: width,
      targetHeight: height,
      fit: item.fit,
      backgroundColor: backgroundColor,
    );
  }

  /// Produces [item] at the smallest resolution that can still fill a
  /// `width × height` target without upscaling, reusing an earlier one when it
  /// is already big enough.
  ///
  /// Throws [FormatException] for unsupported data.
  Future<img.Image> _sourceFor(
    PhotoItem item, {
    required PhotoEdits edits,
    required int width,
    required int height,
  }) async {
    // Work backwards from the target. The crop happens before the quarter
    // turns, so the required dimensions swap when the photo is turned on its
    // side, and dividing by the crop fractions maps them back onto the whole
    // frame.
    final neededWidth = edits.swapsAxes ? height : width;
    final neededHeight = edits.swapsAxes ? width : height;
    final cropWidth = edits.cropRect.width > 0 ? edits.cropRect.width : 1.0;
    final cropHeight = edits.cropRect.height > 0 ? edits.cropRect.height : 1.0;

    final minWidth = math.max(1, (neededWidth * sourceHeadroom / cropWidth).ceil());
    final minHeight = math.max(1, (neededHeight * sourceHeadroom / cropHeight).ceil());

    final cached = _sources.remove(item.id);
    if (cached != null) {
      if (cached.satisfies(minWidth, minHeight)) {
        _sources[item.id] = cached;
        return cached.image;
      }
      // Too small for this target: a fresh decode replaces it.
      _sourceBytes -= _bytesOf(cached.image);
    }

    // Make room *before* decoding, not after — the full-resolution decode is
    // the peak, and it must not land on top of a cache that is already full.
    _trimSources(maxSourceBytes ~/ 2);

    // The preview is the same image, already decoded and orientation-baked at
    // import. Whenever it still has the pixels this print needs, that is a whole
    // JPEG decode saved.
    final preview = item.image.width >= minWidth && item.image.height >= minHeight
        ? await _previewPixels(item)
        : null;

    final decoded = preview ?? ImageProcessor.decode(item.bytes);
    if (decoded == null) {
      throw FormatException('Could not decode "${item.fileName}"');
    }

    // Never scale up: a photo smaller than its print is as good as it gets. A
    // preview is never the last word, though — the original file always has
    // more to give, so a later, larger print must go back to it.
    final scale = math.min(1.0, math.max(minWidth / decoded.width, minHeight / decoded.height));
    final isOriginal = scale >= 1 && preview == null;
    // A box filter is both cheaper and cleaner than cubic for a large
    // reduction; the mild cubic resample that follows then starts from properly
    // averaged pixels instead of aliased ones.
    final source = isOriginal
        ? decoded
        : img.copyResize(
            decoded,
            width: math.max(1, (decoded.width * scale).ceil()),
            height: math.max(1, (decoded.height * scale).ceil()),
            maintainAspect: false,
            interpolation: img.Interpolation.average,
          );

    _sources[item.id] = _CachedSource(source, isOriginal: isOriginal);
    _sourceBytes += _bytesOf(source);
    _trimSources(maxSourceBytes, keepNewest: true);
    return source;
  }

  /// Reads [item]'s preview back as pixels the `image` package can work on, or
  /// `null` when that is not safe or not possible.
  Future<img.Image?> _previewPixels(PhotoItem item) async {
    // Flutter hands back premultiplied alpha and the rest of the pipeline works
    // in straight alpha, so a photo that actually has an alpha channel goes the
    // long way round rather than risk darkened edges.
    if (item.sourceHasAlpha) return null;

    try {
      final data = await item.image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return null;
      return img.Image.fromBytes(
        width: item.image.width,
        height: item.image.height,
        bytes: data.buffer,
        bytesOffset: data.offsetInBytes,
        numChannels: 4,
        order: img.ChannelOrder.rgba,
      );
    } catch (_) {
      // The preview can be disposed out from under us if the photo is removed
      // mid-export. Falling back to the original file is always correct.
      return null;
    }
  }

  /// Evicts least-recently-used sources until they fit in [budget].
  ///
  /// [keepNewest] protects the entry the caller is about to use, which matters
  /// when a single photo is larger than the whole budget — evicting it would
  /// mean decoding it again for the very next print.
  void _trimSources(int budget, {bool keepNewest = false}) {
    while (_sourceBytes > budget && _sources.length > (keepNewest ? 1 : 0)) {
      final oldest = _sources.keys.first;
      final removed = _sources.remove(oldest)!;
      _sourceBytes -= _bytesOf(removed.image);
    }
  }

  void _trimRendered() {
    // Never evict the newest entry: the caller is holding it right now.
    while (_renderedBytes > maxRenderedBytes && _rendered.length > 1) {
      final oldest = _rendered.keys.first;
      final removed = _rendered.remove(oldest)!;
      _renderedBytes -= _bytesOf(removed);
    }
  }

  String _bitmapKey(PhotoItem item, PhotoEdits edits, int width, int height) =>
      '${item.id}|${edits.signature}|${item.fit.name}|${width}x$height';

  /// Live size of a bitmap. Four bytes a pixel is the worst case and the common
  /// one, and over-estimating only makes the budgets more conservative.
  static int _bytesOf(img.Image image) => image.width * image.height * 4;
}

class _CachedSource {
  const _CachedSource(this.image, {required this.isOriginal});

  final img.Image image;

  /// `true` when this is the untouched full-resolution decode, i.e. no larger
  /// version of this photo exists to decode.
  final bool isOriginal;

  bool satisfies(int width, int height) =>
      isOriginal || (image.width >= width && image.height >= height);
}
