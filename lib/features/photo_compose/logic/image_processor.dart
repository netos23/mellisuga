import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:image/image.dart' as img;

import '../models/photo_edits.dart';
import '../models/photo_item.dart';

/// Rasterises photos for export.
///
/// On-screen previews never go through this class — they are painted directly
/// with Flutter's canvas, which is far cheaper. This code exists for the export
/// path, where the pixels must be baked into a real bitmap.
///
/// Everything here is pure Dart with no `dart:ui` dependency, so it runs
/// unchanged on web, mobile and desktop.
abstract final class ImageProcessor {
  /// Decodes [bytes], honouring any EXIF orientation flag.
  ///
  /// Returns `null` when the data is not a supported image. Note that
  /// `decodeImage` does not confine itself to returning `null` for bad input —
  /// truncated or malformed files make its format sniffing read past the end of
  /// the buffer and throw. Everything is caught here so callers only ever have
  /// one failure mode to handle.
  static img.Image? decode(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      // Cameras record orientation in EXIF rather than rotating the pixels;
      // bake it in so what we lay out matches what the user saw.
      return img.bakeOrientation(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Applies the full edit stack to [source]: crop, annotations, flips and
  /// quarter turns, in that order.
  static img.Image applyEdits(img.Image source, PhotoEdits edits) {
    var result = _crop(source, edits.cropRect);
    if (edits.strokes.isNotEmpty) {
      result = _drawStrokes(result, edits.strokes);
    }
    if (edits.flipHorizontal && edits.flipVertical) {
      result = img.copyFlip(result, direction: img.FlipDirection.both);
    } else if (edits.flipHorizontal) {
      result = img.copyFlip(result, direction: img.FlipDirection.horizontal);
    } else if (edits.flipVertical) {
      result = img.copyFlip(result, direction: img.FlipDirection.vertical);
    }
    if (edits.quarterTurns % 4 != 0) {
      result = img.copyRotate(result, angle: (edits.quarterTurns % 4) * 90);
    }
    return result;
  }

  /// Scales [source] into a `targetWidth × targetHeight` bitmap according to
  /// [fit], padding with [backgroundColor] where needed.
  static img.Image fitInto(
    img.Image source, {
    required int targetWidth,
    required int targetHeight,
    required PhotoFit fit,
    required int backgroundColor,
  }) {
    final width = math.max(1, targetWidth);
    final height = math.max(1, targetHeight);

    switch (fit) {
      case PhotoFit.stretch:
        return img.copyResize(
          source,
          width: width,
          height: height,
          maintainAspect: false,
          interpolation: img.Interpolation.cubic,
        );

      case PhotoFit.cover:
        // Take the largest centred region of the source that has the target
        // aspect ratio, then scale it to size.
        final targetAspect = width / height;
        final sourceAspect = source.width / source.height;
        int cropWidth;
        int cropHeight;
        if (sourceAspect > targetAspect) {
          cropHeight = source.height;
          cropWidth = math.max(1, (source.height * targetAspect).round());
        } else {
          cropWidth = source.width;
          cropHeight = math.max(1, (source.width / targetAspect).round());
        }
        final cropped = img.copyCrop(
          source,
          x: ((source.width - cropWidth) / 2).round().clamp(0, source.width - 1),
          y: ((source.height - cropHeight) / 2).round().clamp(0, source.height - 1),
          width: math.min(cropWidth, source.width),
          height: math.min(cropHeight, source.height),
        );
        return img.copyResize(
          cropped,
          width: width,
          height: height,
          maintainAspect: false,
          interpolation: img.Interpolation.cubic,
        );

      case PhotoFit.contain:
        final scale = math.min(width / source.width, height / source.height);
        final scaledWidth = math.max(1, (source.width * scale).round());
        final scaledHeight = math.max(1, (source.height * scale).round());
        final scaled = img.copyResize(
          source,
          width: scaledWidth,
          height: scaledHeight,
          maintainAspect: false,
          interpolation: img.Interpolation.cubic,
        );
        final canvas = img.Image(width: width, height: height, numChannels: 4);
        img.fill(canvas, color: colorFromArgb(canvas, backgroundColor));
        img.compositeImage(
          canvas,
          scaled,
          dstX: ((width - scaledWidth) / 2).round(),
          dstY: ((height - scaledHeight) / 2).round(),
        );
        return canvas;
    }
  }

  /// Convenience wrapper: decode, edit and fit in one call.
  ///
  /// Throws [FormatException] when the bytes are not a supported image.
  static img.Image render(PhotoRenderRequest request) {
    final decoded = decode(request.bytes);
    if (decoded == null) {
      throw const FormatException('Unsupported or corrupt image data');
    }
    return fitInto(
      applyEdits(decoded, request.edits),
      targetWidth: request.targetWidthPx,
      targetHeight: request.targetHeightPx,
      fit: request.fit,
      backgroundColor: request.backgroundColor,
    );
  }

  /// Builds a colour compatible with [image]'s pixel format from a packed
  /// 32-bit ARGB value (the layout Flutter's `Color` uses).
  static img.Color colorFromArgb(img.Image image, int argb) {
    final a = (argb >> 24) & 0xFF;
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return img.ColorRgba8(r, g, b, a);
  }

  static img.Image _crop(img.Image source, Rect cropRect) {
    final left = (cropRect.left * source.width).round().clamp(0, source.width - 1);
    final top = (cropRect.top * source.height).round().clamp(0, source.height - 1);
    final width = (cropRect.width * source.width).round().clamp(1, source.width - left);
    final height = (cropRect.height * source.height).round().clamp(1, source.height - top);
    if (left == 0 && top == 0 && width == source.width && height == source.height) {
      return source;
    }
    return img.copyCrop(source, x: left, y: top, width: width, height: height);
  }

  static img.Image _drawStrokes(img.Image target, List<DrawStroke> strokes) {
    // Work on a copy so a cached decode is never mutated.
    final canvas = target.convert(numChannels: 4);
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      // ignore: deprecated_member_use
      final color = colorFromArgb(canvas, stroke.color.value);
      final thickness = math.max(1.0, stroke.width * canvas.width);

      if (stroke.points.length == 1) {
        final point = stroke.points.first;
        img.fillCircle(
          canvas,
          x: (point.dx * canvas.width).round(),
          y: (point.dy * canvas.height).round(),
          radius: math.max(1, (thickness / 2).round()),
          color: color,
          antialias: true,
        );
        continue;
      }

      for (var i = 0; i < stroke.points.length - 1; i++) {
        final from = stroke.points[i];
        final to = stroke.points[i + 1];
        img.drawLine(
          canvas,
          x1: (from.dx * canvas.width).round(),
          y1: (from.dy * canvas.height).round(),
          x2: (to.dx * canvas.width).round(),
          y2: (to.dy * canvas.height).round(),
          color: color,
          thickness: thickness,
          antialias: true,
        );
      }

      // `drawLine` renders each segment independently, which leaves a notch at
      // sharp corners. Round the joints off with a dot at every interior point.
      if (thickness > 2) {
        for (var i = 1; i < stroke.points.length - 1; i++) {
          final point = stroke.points[i];
          img.fillCircle(
            canvas,
            x: (point.dx * canvas.width).round(),
            y: (point.dy * canvas.height).round(),
            radius: math.max(1, (thickness / 2).round()),
            color: color,
            antialias: true,
          );
        }
      }
    }
    return canvas;
  }
}
