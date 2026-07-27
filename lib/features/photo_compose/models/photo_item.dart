import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'photo_edits.dart';
import 'photo_size.dart';

/// How a photo fills the print rectangle when the two aspect ratios differ.
enum PhotoFit {
  /// Scale up until the rectangle is covered, trimming the overflow.
  cover('Fill (crop edges)'),

  /// Scale down until the whole photo is visible, leaving empty margins.
  contain('Fit (letterbox)'),

  /// Ignore the source aspect ratio and stretch to the rectangle.
  stretch('Stretch');

  const PhotoFit(this.label);

  final String label;
}

/// One photo the user added, together with everything that describes how it
/// should be printed.
///
/// A [PhotoItem] holds the *decoded* image so previews stay fast, plus the
/// original bytes so exports can work from full resolution data.
class PhotoItem {
  PhotoItem({
    required this.id,
    required this.fileName,
    required this.bytes,
    required this.image,
    required this.naturalWidth,
    required this.naturalHeight,
    required this.printSize,
    this.edits = const PhotoEdits(),
    this.copies = 1,
    this.fit = PhotoFit.cover,
    this.allowRotation = true,
    this.label,
  });

  final String id;

  /// Original file name, shown in the photo list.
  final String fileName;

  /// Raw encoded bytes exactly as they were read from disk.
  final Uint8List bytes;

  /// Decoded, orientation-corrected image used for on-screen previews. It is
  /// capped in size, so it is usually smaller than the original.
  final ui.Image image;

  /// Full-resolution pixel width of the original, after EXIF orientation.
  final int naturalWidth;

  /// Full-resolution pixel height of the original, after EXIF orientation.
  final int naturalHeight;

  /// The physical size this photo should be printed at.
  final PhotoPrintSize printSize;

  final PhotoEdits edits;

  /// How many identical prints of this photo to lay out.
  final int copies;

  final PhotoFit fit;

  /// Whether the layout engine may turn this photo 90° to pack it better.
  final bool allowRotation;

  /// Optional caption the user can set to tell similar photos apart.
  final String? label;

  /// Source dimensions used for every physical calculation. These are the
  /// original pixel counts, not the downscaled preview's.
  int get sourceWidth => naturalWidth;

  int get sourceHeight => naturalHeight;

  /// Aspect ratio of the photo after crop, flips and rotation.
  double get editedAspectRatio => edits.aspectRatioFor(sourceWidth, sourceHeight);

  /// Pixel dimensions of the image after the edit stack is applied.
  ({int width, int height}) get editedPixelSize {
    final croppedWidth = (edits.cropRect.width * sourceWidth).round().clamp(1, sourceWidth);
    final croppedHeight = (edits.cropRect.height * sourceHeight).round().clamp(1, sourceHeight);
    return edits.swapsAxes
        ? (width: croppedHeight, height: croppedWidth)
        : (width: croppedWidth, height: croppedHeight);
  }

  /// The effective resolution this photo would be printed at, in DPI.
  ///
  /// Anything under roughly 150 DPI starts to look soft in print, which the UI
  /// surfaces as a warning.
  double get effectiveDpi {
    final pixels = editedPixelSize;
    final horizontal = pixels.width / (printSize.widthMm / 25.4);
    final vertical = pixels.height / (printSize.heightMm / 25.4);
    return horizontal < vertical ? horizontal : vertical;
  }

  PhotoItem copyWith({
    PhotoPrintSize? printSize,
    PhotoEdits? edits,
    int? copies,
    PhotoFit? fit,
    bool? allowRotation,
    String? label,
  }) {
    return PhotoItem(
      id: id,
      fileName: fileName,
      bytes: bytes,
      image: image,
      naturalWidth: naturalWidth,
      naturalHeight: naturalHeight,
      printSize: printSize ?? this.printSize,
      edits: edits ?? this.edits,
      copies: copies ?? this.copies,
      fit: fit ?? this.fit,
      allowRotation: allowRotation ?? this.allowRotation,
      label: label ?? this.label,
    );
  }

  /// Cache key covering everything that affects the rendered pixels.
  String get renderSignature => '$id|${edits.signature}|${fit.name}';

  @override
  String toString() => 'PhotoItem($id, $fileName, ×$copies)';
}

/// A lightweight description of a photo, used by isolate-friendly code that
/// must not touch `dart:ui` objects.
@immutable
class PhotoRenderRequest {
  const PhotoRenderRequest({
    required this.bytes,
    required this.edits,
    required this.targetWidthPx,
    required this.targetHeightPx,
    required this.fit,
    required this.backgroundColor,
  });

  final Uint8List bytes;
  final PhotoEdits edits;
  final int targetWidthPx;
  final int targetHeightPx;
  final PhotoFit fit;

  /// ARGB colour used behind letterboxed photos.
  final int backgroundColor;
}
