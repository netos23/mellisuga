import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../models/photo_edits.dart';
import '../../models/photo_item.dart';

/// Draws edited photos straight onto a Flutter canvas.
///
/// The preview deliberately does **not** go through the raster export pipeline:
/// re-encoding every photo on each rebuild would make the editor crawl. Instead
/// the decoded source image is drawn with canvas transforms that reproduce the
/// exact same edit stack, so what the user sees matches what gets exported.
abstract final class PhotoPainting {
  /// Paints [image] into [destination], applying [edits], [fit] and an
  /// optional extra 90° turn from the layout engine.
  ///
  /// The transform chain mirrors `ImageProcessor.applyEdits`: crop, then
  /// annotations, then flips, then rotation. Because rotations compose, the
  /// photo's own quarter turns and the layout's rotation are folded into a
  /// single `rotate` call.
  static void drawPhoto(
    Canvas canvas, {
    required ui.Image image,
    required PhotoEdits edits,
    required Rect destination,
    required PhotoFit fit,
    bool layoutRotated = false,
    double opacity = 1.0,
    FilterQuality filterQuality = FilterQuality.medium,
  }) {
    if (destination.isEmpty) return;

    final croppedWidth = math.max(1.0, edits.cropRect.width * image.width);
    final croppedHeight = math.max(1.0, edits.cropRect.height * image.height);

    final totalTurns = (edits.quarterTurns + (layoutRotated ? 1 : 0)) % 4;
    final swapsAxes = totalTurns.isOdd;

    // Extent of `destination` as seen from inside the rotated frame.
    final localWidth = swapsAxes ? destination.height : destination.width;
    final localHeight = swapsAxes ? destination.width : destination.height;

    final (double scaleX, double scaleY) = switch (fit) {
      PhotoFit.stretch => (localWidth / croppedWidth, localHeight / croppedHeight),
      PhotoFit.cover => () {
        final scale = math.max(localWidth / croppedWidth, localHeight / croppedHeight);
        return (scale, scale);
      }(),
      PhotoFit.contain => () {
        final scale = math.min(localWidth / croppedWidth, localHeight / croppedHeight);
        return (scale, scale);
      }(),
    };

    canvas
      ..save()
      ..clipRect(destination)
      ..translate(destination.center.dx, destination.center.dy);
    if (totalTurns != 0) {
      canvas.rotate(totalTurns * math.pi / 2);
    }
    canvas.scale(scaleX * (edits.flipHorizontal ? -1 : 1), scaleY * (edits.flipVertical ? -1 : 1));

    final sourceRect = Rect.fromLTWH(
      edits.cropRect.left * image.width,
      edits.cropRect.top * image.height,
      croppedWidth,
      croppedHeight,
    );
    final localRect = Rect.fromCenter(
      center: Offset.zero,
      width: croppedWidth,
      height: croppedHeight,
    );

    canvas.drawImageRect(
      image,
      sourceRect,
      localRect,
      Paint()
        ..filterQuality = filterQuality
        ..color = Color.fromRGBO(0, 0, 0, opacity.clamp(0.0, 1.0)),
    );

    _drawStrokes(canvas, edits.strokes, localRect, opacity);
    canvas.restore();
  }

  static void _drawStrokes(Canvas canvas, List<DrawStroke> strokes, Rect area, double opacity) {
    if (strokes.isEmpty) return;
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color.withValues(alpha: stroke.color.a * opacity.clamp(0.0, 1.0))
        ..strokeWidth = math.max(0.1, stroke.width * area.width)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      Offset toLocal(Offset normalised) =>
          Offset(area.left + normalised.dx * area.width, area.top + normalised.dy * area.height);

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          toLocal(stroke.points.first),
          paint.strokeWidth / 2,
          Paint()
            ..color = paint.color
            ..isAntiAlias = true,
        );
        continue;
      }

      final path = Path()..moveTo(toLocal(stroke.points.first).dx, toLocal(stroke.points.first).dy);
      for (var i = 1; i < stroke.points.length; i++) {
        final point = toLocal(stroke.points[i]);
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }
}
