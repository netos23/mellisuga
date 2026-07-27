import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/layout_result.dart';
import '../models/layout_settings.dart';

/// A straight guide segment, in sheet millimetres.
@immutable
class GuideSegment {
  const GuideSegment(this.x1, this.y1, this.x2, this.y2);

  final double x1;
  final double y1;
  final double x2;
  final double y2;

  double get length => math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
}

/// Computes the cutting guides for a composed sheet.
///
/// The geometry lives here, in millimetres, so the preview, the PDF exporter
/// and the raster exporter all draw byte-identical guides — the sheet a user
/// prints is the sheet they saw.
abstract final class DividerGeometry {
  /// Length of each crop-mark tick, in millimetres.
  static const double cropMarkLengthMm = 3.5;

  /// Two coordinates closer than this are treated as the same line.
  static const double _mergeToleranceMm = 0.25;

  static List<GuideSegment> build(ComposedPage page, LayoutSettings settings) {
    if (settings.dividerStyle == DividerStyle.none || page.photos.isEmpty) {
      return const <GuideSegment>[];
    }

    return switch (settings.dividerStyle) {
      DividerStyle.none => const <GuideSegment>[],
      DividerStyle.outline => _outlines(page),
      DividerStyle.cutLines => _cutLines(page, settings),
      DividerStyle.cropMarks => _cropMarks(page, settings),
    };
  }

  static List<GuideSegment> _outlines(ComposedPage page) {
    final segments = <GuideSegment>[];
    for (final photo in page.photos) {
      segments
        ..add(GuideSegment(photo.xMm, photo.yMm, photo.rightMm, photo.yMm))
        ..add(GuideSegment(photo.rightMm, photo.yMm, photo.rightMm, photo.bottomMm))
        ..add(GuideSegment(photo.rightMm, photo.bottomMm, photo.xMm, photo.bottomMm))
        ..add(GuideSegment(photo.xMm, photo.bottomMm, photo.xMm, photo.yMm));
    }
    return segments;
  }

  /// Full-width and full-height lines running through the middle of the gaps
  /// between photos — the layout a guillotine cutter wants.
  static List<GuideSegment> _cutLines(ComposedPage page, LayoutSettings settings) {
    final half = settings.spacingMm / 2;
    final verticals = <double>[];
    final horizontals = <double>[];

    void addUnique(List<double> into, double value) {
      for (final existing in into) {
        if ((existing - value).abs() <= _mergeToleranceMm) return;
      }
      into.add(value);
    }

    for (final photo in page.photos) {
      addUnique(verticals, photo.xMm - half);
      addUnique(verticals, photo.rightMm + half);
      addUnique(horizontals, photo.yMm - half);
      addUnique(horizontals, photo.bottomMm + half);
    }

    final segments = <GuideSegment>[];
    for (final x in verticals) {
      if (x < 0 || x > page.widthMm) continue;
      segments.add(GuideSegment(x, 0, x, page.heightMm));
    }
    for (final y in horizontals) {
      if (y < 0 || y > page.heightMm) continue;
      segments.add(GuideSegment(0, y, page.widthMm, y));
    }
    return segments;
  }

  /// Short ticks just outside each corner, so no ink lands on the photo.
  static List<GuideSegment> _cropMarks(ComposedPage page, LayoutSettings settings) {
    // Keep the ticks inside the gutter so neighbouring photos stay clean.
    final tick = math.min(
      cropMarkLengthMm,
      math.max(1.0, settings.spacingMm > 0 ? settings.spacingMm : cropMarkLengthMm),
    );
    final gap = math.min(tick * 0.2, 0.6);

    final segments = <GuideSegment>[];
    for (final photo in page.photos) {
      final corners = <(double, double, double, double)>[
        // (x, y, horizontal direction, vertical direction)
        (photo.xMm, photo.yMm, -1, -1),
        (photo.rightMm, photo.yMm, 1, -1),
        (photo.rightMm, photo.bottomMm, 1, 1),
        (photo.xMm, photo.bottomMm, -1, 1),
      ];
      for (final (x, y, dx, dy) in corners) {
        segments
          ..add(GuideSegment(x + dx * gap, y, x + dx * (gap + tick), y))
          ..add(GuideSegment(x, y + dy * gap, x, y + dy * (gap + tick)));
      }
    }
    return segments;
  }

  /// Splits [segment] into the dashes implied by [pattern].
  ///
  /// Returns the segment unchanged for [DividerPattern.solid].
  static List<GuideSegment> applyPattern(
    GuideSegment segment,
    DividerPattern pattern,
    double lineWidthMm,
  ) {
    if (pattern == DividerPattern.solid) return [segment];

    final (double on, double off) = switch (pattern) {
      DividerPattern.dashed => (2.0, 1.5),
      DividerPattern.dotted => (math.max(0.3, lineWidthMm), math.max(0.7, lineWidthMm * 2.5)),
      DividerPattern.solid => (1.0, 0.0),
    };

    final total = segment.length;
    if (total <= 0 || on + off <= 0) return [segment];

    final dirX = (segment.x2 - segment.x1) / total;
    final dirY = (segment.y2 - segment.y1) / total;

    final dashes = <GuideSegment>[];
    var position = 0.0;
    while (position < total) {
      final end = math.min(position + on, total);
      dashes.add(
        GuideSegment(
          segment.x1 + dirX * position,
          segment.y1 + dirY * position,
          segment.x1 + dirX * end,
          segment.y1 + dirY * end,
        ),
      );
      position = end + off;
    }
    return dashes;
  }

  /// Convenience helper returning every drawable segment, dashes included.
  static List<GuideSegment> buildDashed(ComposedPage page, LayoutSettings settings) {
    final segments = build(page, settings);
    if (settings.dividerPattern == DividerPattern.solid) return segments;
    return [
      for (final segment in segments)
        ...applyPattern(segment, settings.dividerPattern, settings.dividerWidthMm),
    ];
  }
}
