import 'package:flutter/foundation.dart';

/// One photo instance placed on a sheet.
///
/// All coordinates are in millimetres, measured from the top-left corner of the
/// sheet (margins already applied).
@immutable
class PlacedPhoto {
  const PlacedPhoto({
    required this.itemId,
    required this.copyIndex,
    required this.xMm,
    required this.yMm,
    required this.widthMm,
    required this.heightMm,
    required this.rotated,
    this.scaledDown = false,
  });

  /// Identifier of the [PhotoItem] this instance came from.
  final String itemId;

  /// Which copy of that photo this is, starting at `0`.
  final int copyIndex;

  final double xMm;
  final double yMm;
  final double widthMm;
  final double heightMm;

  /// `true` when the photo was turned 90° clockwise to pack better. The photo's
  /// own content must be rotated by the same amount when drawn.
  final bool rotated;

  /// `true` when the photo had to be shrunk below its requested print size to
  /// fit the sheet at all.
  final bool scaledDown;

  double get rightMm => xMm + widthMm;

  double get bottomMm => yMm + heightMm;

  double get areaMm2 => widthMm * heightMm;

  /// A stable key for widget lists.
  String get instanceKey => '$itemId#$copyIndex';
}

/// A single composed sheet.
@immutable
class ComposedPage {
  const ComposedPage({
    required this.index,
    required this.widthMm,
    required this.heightMm,
    required this.photos,
  });

  /// Zero-based page number.
  final int index;

  final double widthMm;
  final double heightMm;

  final List<PlacedPhoto> photos;

  /// Fraction of the whole sheet covered by photos, `0..1`.
  double get coverage {
    if (widthMm <= 0 || heightMm <= 0) return 0;
    final used = photos.fold<double>(0, (sum, photo) => sum + photo.areaMm2);
    return (used / (widthMm * heightMm)).clamp(0.0, 1.0);
  }
}

/// A problem the layout engine hit while composing.
@immutable
class LayoutWarning {
  const LayoutWarning({required this.itemId, required this.message, this.fatal = false});

  final String itemId;
  final String message;

  /// `true` when the photo could not be placed at all.
  final bool fatal;
}

/// The complete result of a layout run.
@immutable
class LayoutResult {
  const LayoutResult({required this.pages, this.warnings = const <LayoutWarning>[]});

  static const empty = LayoutResult(pages: <ComposedPage>[]);

  final List<ComposedPage> pages;
  final List<LayoutWarning> warnings;

  int get pageCount => pages.length;

  int get placedCount => pages.fold(0, (sum, page) => sum + page.photos.length);

  /// Average sheet coverage across all pages, `0..1`.
  double get averageCoverage {
    if (pages.isEmpty) return 0;
    return pages.fold<double>(0, (sum, page) => sum + page.coverage) / pages.length;
  }

  bool get hasWarnings => warnings.isNotEmpty;
}
