import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../models/photo_item.dart';
import '../models/photo_size.dart';
import 'image_processor.dart';

/// Why an imported file was rejected.
@immutable
class ImportFailure {
  const ImportFailure({required this.fileName, required this.reason});

  final String fileName;
  final String reason;
}

/// Reads image files and turns them into [PhotoItem]s.
///
/// Decoding goes through the `image` package rather than Flutter's own codec
/// for one specific reason: EXIF orientation. Phone cameras record rotation as
/// metadata instead of rotating pixels, and platform codecs disagree about
/// whether to honour it. Since the export pipeline bakes orientation in, the
/// preview has to do exactly the same or the printed sheet would not match what
/// the user arranged.
abstract final class PhotoImporter {
  /// Longest edge kept for the on-screen preview. Full resolution is only ever
  /// touched at export time, straight from the original bytes.
  static const int previewMaxEdge = 1800;

  /// Files larger than this are rejected rather than risking an out-of-memory
  /// crash in a browser tab.
  static const int maxFileBytes = 80 * 1024 * 1024;

  static const Set<String> supportedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'bmp',
    'gif',
    'tif',
    'tiff',
    'ico',
    'tga',
    'pnm',
  };

  /// Prepares one file. Throws [ImportException] when the data is unusable.
  static Future<PhotoItem> import({
    required String id,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (bytes.isEmpty) {
      throw const ImportException('The file is empty.');
    }
    if (bytes.length > maxFileBytes) {
      throw ImportException(
        'The file is ${(bytes.length / 1024 / 1024).toStringAsFixed(0)} MB, which is '
        'above the ${maxFileBytes ~/ (1024 * 1024)} MB limit.',
      );
    }

    final decoded = await compute(_decodeForPreview, bytes);
    if (decoded == null) {
      throw const ImportException('The format is not supported, or the file is damaged.');
    }

    final image = await _toUiImage(decoded);

    return PhotoItem(
      id: id,
      fileName: fileName,
      bytes: bytes,
      image: image,
      naturalWidth: decoded.naturalWidth,
      naturalHeight: decoded.naturalHeight,
      printSize: _defaultSizeFor(decoded.naturalWidth, decoded.naturalHeight),
    );
  }

  /// Picks a sensible starting print size: the default preset, turned to
  /// landscape when the photo is wider than it is tall.
  static PhotoPrintSize _defaultSizeFor(int width, int height) {
    final preset = PhotoSizePresets.defaultSize;
    return width > height ? preset.swapped : preset;
  }

  static Future<ui.Image> _toUiImage(_DecodedPreview decoded) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      decoded.rgba,
      decoded.width,
      decoded.height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }
}

/// Raised when a file cannot be turned into a usable photo.
class ImportException implements Exception {
  const ImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Pixel data handed back from the decode isolate.
///
/// Only plain data crosses the isolate boundary, which is what lets this run on
/// a background isolate on native platforms.
class _DecodedPreview {
  const _DecodedPreview({
    required this.rgba,
    required this.width,
    required this.height,
    required this.naturalWidth,
    required this.naturalHeight,
  });

  final Uint8List rgba;
  final int width;
  final int height;
  final int naturalWidth;
  final int naturalHeight;
}

/// Runs on a background isolate (or inline on web, which is single-threaded).
_DecodedPreview? _decodeForPreview(Uint8List bytes) {
  final decoded = ImageProcessor.decode(bytes);
  if (decoded == null) return null;

  final longestEdge = math.max(decoded.width, decoded.height);
  final preview = longestEdge <= PhotoImporter.previewMaxEdge
      ? decoded
      : img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? PhotoImporter.previewMaxEdge : null,
          height: decoded.height > decoded.width ? PhotoImporter.previewMaxEdge : null,
          interpolation: img.Interpolation.average,
        );

  return _DecodedPreview(
    rgba: preview.getBytes(order: img.ChannelOrder.rgba),
    width: preview.width,
    height: preview.height,
    naturalWidth: decoded.width,
    naturalHeight: decoded.height,
  );
}
