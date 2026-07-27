import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A single freehand annotation drawn on a photo.
///
/// Points are stored in **normalised coordinates of the cropped source image**,
/// i.e. `(0,0)` is the top-left of the crop rectangle and `(1,1)` its
/// bottom-right, *before* flips and quarter turns are applied. Storing them in
/// that space means rotating or flipping the photo carries the drawing along
/// with it, which is what a user expects.
@immutable
class DrawStroke {
  const DrawStroke({required this.points, required this.color, required this.width});

  final List<Offset> points;

  final Color color;

  /// Stroke width as a fraction of the cropped image's width, so the stroke
  /// scales with the photo instead of being tied to screen pixels.
  final double width;

  DrawStroke copyWith({List<Offset>? points, Color? color, double? width}) {
    return DrawStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }

  Map<String, dynamic> toJson() => {
    'points': [
      for (final point in points) {'x': point.dx, 'y': point.dy},
    ],
    // ignore: deprecated_member_use
    'color': color.value,
    'width': width,
  };

  factory DrawStroke.fromJson(Map<String, dynamic> json) => DrawStroke(
    points: [
      for (final raw in json['points'] as List<dynamic>)
        Offset(
          ((raw as Map<String, dynamic>)['x'] as num).toDouble(),
          (raw['y'] as num).toDouble(),
        ),
    ],
    color: Color(json['color'] as int),
    width: (json['width'] as num).toDouble(),
  );
}

/// The complete, non-destructive edit stack applied to a source image.
///
/// Edits are applied in a fixed order, which both the on-screen preview and the
/// export pipeline follow exactly:
///
/// 1. [cropRect] is cut out of the source image.
/// 2. [strokes] are painted onto the cropped result.
/// 3. [flipHorizontal] / [flipVertical] mirror the image.
/// 4. [quarterTurns] rotates it clockwise in 90° steps.
@immutable
class PhotoEdits {
  const PhotoEdits({
    this.cropRect = const Rect.fromLTWH(0, 0, 1, 1),
    this.quarterTurns = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.strokes = const <DrawStroke>[],
  });

  /// Crop window in normalised source-image coordinates.
  final Rect cropRect;

  /// Clockwise rotation in 90° steps, always in the range `0..3`.
  final int quarterTurns;

  final bool flipHorizontal;
  final bool flipVertical;

  final List<DrawStroke> strokes;

  bool get isIdentity =>
      cropRect == const Rect.fromLTWH(0, 0, 1, 1) &&
      quarterTurns == 0 &&
      !flipHorizontal &&
      !flipVertical &&
      strokes.isEmpty;

  /// `true` when the quarter turns swap the width and height of the result.
  bool get swapsAxes => quarterTurns.isOdd;

  PhotoEdits copyWith({
    Rect? cropRect,
    int? quarterTurns,
    bool? flipHorizontal,
    bool? flipVertical,
    List<DrawStroke>? strokes,
  }) {
    return PhotoEdits(
      cropRect: cropRect ?? this.cropRect,
      quarterTurns: ((quarterTurns ?? this.quarterTurns) % 4 + 4) % 4,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      strokes: strokes ?? this.strokes,
    );
  }

  /// Aspect ratio of the edited result, given the source pixel dimensions.
  double aspectRatioFor(int sourceWidth, int sourceHeight) {
    final croppedWidth = cropRect.width * sourceWidth;
    final croppedHeight = cropRect.height * sourceHeight;
    return swapsAxes ? croppedHeight / croppedWidth : croppedWidth / croppedHeight;
  }

  /// Maps a point from the *displayed* (fully transformed) image back into the
  /// cropped source space that [strokes] live in.
  ///
  /// Both input and output are normalised to `0..1`.
  Offset displayToCropSpace(Offset display) {
    // Undo the rotation first, because it was applied last.
    final unrotated = switch (quarterTurns) {
      1 => Offset(display.dy, 1 - display.dx),
      2 => Offset(1 - display.dx, 1 - display.dy),
      3 => Offset(1 - display.dy, display.dx),
      _ => display,
    };
    return Offset(
      flipHorizontal ? 1 - unrotated.dx : unrotated.dx,
      flipVertical ? 1 - unrotated.dy : unrotated.dy,
    );
  }

  /// The inverse of [displayToCropSpace].
  Offset cropToDisplaySpace(Offset crop) {
    final flipped = Offset(
      flipHorizontal ? 1 - crop.dx : crop.dx,
      flipVertical ? 1 - crop.dy : crop.dy,
    );
    return switch (quarterTurns) {
      1 => Offset(1 - flipped.dy, flipped.dx),
      2 => Offset(1 - flipped.dx, 1 - flipped.dy),
      3 => Offset(flipped.dy, 1 - flipped.dx),
      _ => flipped,
    };
  }

  /// A cache key that changes whenever the rendered result would change.
  String get signature {
    final buffer = StringBuffer()
      ..write(cropRect.left.toStringAsFixed(5))
      ..write(',')
      ..write(cropRect.top.toStringAsFixed(5))
      ..write(',')
      ..write(cropRect.width.toStringAsFixed(5))
      ..write(',')
      ..write(cropRect.height.toStringAsFixed(5))
      ..write('|$quarterTurns|$flipHorizontal|$flipVertical|');
    for (final stroke in strokes) {
      buffer
        // ignore: deprecated_member_use
        ..write(stroke.color.value)
        ..write(':')
        ..write(stroke.width.toStringAsFixed(4))
        ..write(':')
        ..write(stroke.points.length)
        ..write(';');
    }
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
    'crop': {'l': cropRect.left, 't': cropRect.top, 'w': cropRect.width, 'h': cropRect.height},
    'quarterTurns': quarterTurns,
    'flipHorizontal': flipHorizontal,
    'flipVertical': flipVertical,
    'strokes': [for (final stroke in strokes) stroke.toJson()],
  };

  factory PhotoEdits.fromJson(Map<String, dynamic> json) {
    final crop = json['crop'] as Map<String, dynamic>?;
    return PhotoEdits(
      cropRect: crop == null
          ? const Rect.fromLTWH(0, 0, 1, 1)
          : Rect.fromLTWH(
              (crop['l'] as num).toDouble(),
              (crop['t'] as num).toDouble(),
              (crop['w'] as num).toDouble(),
              (crop['h'] as num).toDouble(),
            ),
      quarterTurns: json['quarterTurns'] as int? ?? 0,
      flipHorizontal: json['flipHorizontal'] as bool? ?? false,
      flipVertical: json['flipVertical'] as bool? ?? false,
      strokes: [
        for (final raw in (json['strokes'] as List<dynamic>? ?? const []))
          DrawStroke.fromJson(raw as Map<String, dynamic>),
      ],
    );
  }
}
