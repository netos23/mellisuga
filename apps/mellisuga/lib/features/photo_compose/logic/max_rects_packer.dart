import 'dart:math' as math;

import '../models/layout_settings.dart';

/// An axis-aligned rectangle in millimetres, used by the packer.
class PackRect {
  const PackRect(this.x, this.y, this.width, this.height);

  final double x;
  final double y;
  final double width;
  final double height;

  double get right => x + width;

  double get bottom => y + height;

  double get area => width * height;

  bool contains(PackRect other) =>
      other.x >= x - _epsilon &&
      other.y >= y - _epsilon &&
      other.right <= right + _epsilon &&
      other.bottom <= bottom + _epsilon;

  bool overlaps(PackRect other) =>
      x < other.right - _epsilon &&
      right > other.x + _epsilon &&
      y < other.bottom - _epsilon &&
      bottom > other.y + _epsilon;

  @override
  String toString() =>
      'PackRect(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}, '
      '${width.toStringAsFixed(2)} × ${height.toStringAsFixed(2)})';
}

/// Where the packer decided to put one rectangle.
class PackPlacement {
  const PackPlacement({required this.rect, required this.rotated});

  final PackRect rect;

  /// `true` when the rectangle was turned 90° to make it fit.
  final bool rotated;
}

const double _epsilon = 1e-6;

/// A single bin (one printable sheet area) packed with the MaxRects algorithm.
///
/// MaxRects keeps a list of *maximal* free rectangles — every free rectangle
/// that cannot be grown in any direction. Placing an item splits every free
/// rectangle it overlaps, then any rectangle fully contained in another is
/// pruned. This is slower than shelf packing but wastes far less paper, which
/// is exactly the trade-off we want when the user is paying for photo paper.
class MaxRectsBin {
  MaxRectsBin({
    required this.width,
    required this.height,
    this.strategy = PackingStrategy.bestShortSide,
  }) : _freeRects = [PackRect(0, 0, width, height)];

  final double width;
  final double height;
  final PackingStrategy strategy;

  final List<PackRect> _freeRects;
  final List<PackRect> _usedRects = [];

  List<PackRect> get usedRects => List.unmodifiable(_usedRects);

  /// Fraction of the bin covered by placed rectangles, `0..1`.
  double get occupancy {
    if (width <= 0 || height <= 0) return 0;
    final used = _usedRects.fold<double>(0, (sum, rect) => sum + rect.area);
    return used / (width * height);
  }

  /// Tries to place a `rectWidth × rectHeight` rectangle.
  ///
  /// Returns `null` when it does not fit. When [allowRotation] is set the
  /// rotated orientation is considered too, and the better of the two wins.
  PackPlacement? insert(double rectWidth, double rectHeight, {bool allowRotation = true}) {
    final placement = _findPosition(rectWidth, rectHeight, allowRotation);
    if (placement == null) return null;

    // Split every free rectangle the new placement intrudes on.
    for (var i = _freeRects.length - 1; i >= 0; i--) {
      if (_splitFreeRect(_freeRects[i], placement.rect)) {
        _freeRects.removeAt(i);
      }
    }
    _pruneFreeList();
    _usedRects.add(placement.rect);
    return placement;
  }

  /// Reports whether a rectangle of this size could still be placed, without
  /// mutating the bin.
  bool canFit(double rectWidth, double rectHeight, {bool allowRotation = true}) =>
      _findPosition(rectWidth, rectHeight, allowRotation) != null;

  PackPlacement? _findPosition(double rectWidth, double rectHeight, bool allowRotation) {
    PackRect? best;
    var bestRotated = false;
    var bestPrimary = double.infinity;
    var bestSecondary = double.infinity;

    void consider(double w, double h, bool rotated) {
      for (final free in _freeRects) {
        if (free.width + _epsilon < w || free.height + _epsilon < h) continue;

        final leftoverHorizontal = (free.width - w).abs();
        final leftoverVertical = (free.height - h).abs();

        final (double primary, double secondary) = switch (strategy) {
          PackingStrategy.bestShortSide => (
            math.min(leftoverHorizontal, leftoverVertical),
            math.max(leftoverHorizontal, leftoverVertical),
          ),
          PackingStrategy.bestArea => (
            free.area - w * h,
            math.min(leftoverHorizontal, leftoverVertical),
          ),
          PackingStrategy.bottomLeft => (free.y + h, free.x),
        };

        if (primary < bestPrimary - _epsilon ||
            ((primary - bestPrimary).abs() <= _epsilon && secondary < bestSecondary - _epsilon)) {
          bestPrimary = primary;
          bestSecondary = secondary;
          best = PackRect(free.x, free.y, w, h);
          bestRotated = rotated;
        }
      }
    }

    consider(rectWidth, rectHeight, false);
    if (allowRotation && (rectWidth - rectHeight).abs() > _epsilon) {
      consider(rectHeight, rectWidth, true);
    }

    final result = best;
    return result == null ? null : PackPlacement(rect: result, rotated: bestRotated);
  }

  /// Splits [free] around [used], appending the resulting maximal rectangles.
  ///
  /// Returns `true` when [free] was consumed and should be removed.
  bool _splitFreeRect(PackRect free, PackRect used) {
    if (!free.overlaps(used)) return false;

    // Slice above the used rectangle.
    if (used.y > free.y + _epsilon) {
      _freeRects.add(PackRect(free.x, free.y, free.width, used.y - free.y));
    }
    // Slice below.
    if (used.bottom < free.bottom - _epsilon) {
      _freeRects.add(PackRect(free.x, used.bottom, free.width, free.bottom - used.bottom));
    }
    // Slice to the left.
    if (used.x > free.x + _epsilon) {
      _freeRects.add(PackRect(free.x, free.y, used.x - free.x, free.height));
    }
    // Slice to the right.
    if (used.right < free.right - _epsilon) {
      _freeRects.add(PackRect(used.right, free.y, free.right - used.right, free.height));
    }
    return true;
  }

  /// Removes free rectangles that are fully contained in another one.
  void _pruneFreeList() {
    for (var i = 0; i < _freeRects.length; i++) {
      for (var j = i + 1; j < _freeRects.length; j++) {
        if (_freeRects[j].contains(_freeRects[i])) {
          _freeRects.removeAt(i);
          i--;
          break;
        }
        if (_freeRects[i].contains(_freeRects[j])) {
          _freeRects.removeAt(j);
          j--;
        }
      }
    }
  }
}
