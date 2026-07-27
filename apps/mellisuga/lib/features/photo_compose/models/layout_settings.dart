import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../../core/units/paper_format.dart';

/// The kind of guide drawn around and between photos.
enum DividerStyle {
  none('None', 'No guides are printed'),
  outline('Outline', 'A thin border around every photo'),
  cutLines('Cut lines', 'Full-width lines through the gaps between photos'),
  cropMarks('Crop marks', 'Short corner ticks that stay outside the photo');

  const DividerStyle(this.label, this.description);

  final String label;
  final String description;
}

/// Line pattern used for dividers.
enum DividerPattern {
  solid('Solid'),
  dashed('Dashed'),
  dotted('Dotted');

  const DividerPattern(this.label);

  final String label;
}

/// How aggressively the packer tries to fill each sheet.
enum PackingStrategy {
  /// Best short side fit — the default; produces tight, tidy layouts.
  bestShortSide('Compact', 'Minimises wasted strips between photos'),

  /// Best area fit — favours filling large empty regions first.
  bestArea('Maximum coverage', 'Fills the largest free areas first'),

  /// Bottom-left — deterministic, keeps photos low and left.
  bottomLeft('Rows', 'Simple top-to-bottom rows, easiest to cut');

  const PackingStrategy(this.label, this.description);

  final String label;
  final String description;
}

/// Everything about the sheet itself and how photos are arranged on it.
@immutable
class LayoutSettings {
  const LayoutSettings({
    this.paper = PaperFormats.a4,
    this.orientation = PageOrientation.portrait,
    this.marginTopMm = 8,
    this.marginRightMm = 8,
    this.marginBottomMm = 8,
    this.marginLeftMm = 8,
    this.spacingMm = 3,
    this.dividerStyle = DividerStyle.outline,
    this.dividerPattern = DividerPattern.solid,
    this.dividerWidthMm = 0.2,
    this.dividerColor = const Color(0xFF9E9E9E),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.allowRotation = true,
    this.strategy = PackingStrategy.bestShortSide,
    this.exportDpi = 300,
    this.shrinkOversizedPhotos = true,
  });

  final PaperFormat paper;
  final PageOrientation orientation;

  final double marginTopMm;
  final double marginRightMm;
  final double marginBottomMm;
  final double marginLeftMm;

  /// Gap between neighbouring photos, in millimetres.
  final double spacingMm;

  final DividerStyle dividerStyle;
  final DividerPattern dividerPattern;
  final double dividerWidthMm;
  final Color dividerColor;

  /// Sheet colour; also fills letterboxed areas of `PhotoFit.contain` photos.
  final Color backgroundColor;

  /// Global switch for rotating photos 90° to improve packing. Individual
  /// photos can still opt out via `PhotoItem.allowRotation`.
  final bool allowRotation;

  final PackingStrategy strategy;

  /// Raster resolution used for PNG/JPEG export and for embedded PDF images.
  final int exportDpi;

  /// When a photo is larger than the printable area, scale it down to fit
  /// instead of dropping it from the layout.
  final bool shrinkOversizedPhotos;

  /// Sheet width in millimetres, accounting for [orientation].
  double get pageWidthMm => paper.sizeFor(orientation).width;

  /// Sheet height in millimetres, accounting for [orientation].
  double get pageHeightMm => paper.sizeFor(orientation).height;

  /// Width of the area photos may occupy.
  double get printableWidthMm =>
      (pageWidthMm - marginLeftMm - marginRightMm).clamp(1.0, double.infinity);

  /// Height of the area photos may occupy.
  double get printableHeightMm =>
      (pageHeightMm - marginTopMm - marginBottomMm).clamp(1.0, double.infinity);

  bool get hasUniformMargins =>
      marginTopMm == marginRightMm && marginTopMm == marginBottomMm && marginTopMm == marginLeftMm;

  LayoutSettings copyWith({
    PaperFormat? paper,
    PageOrientation? orientation,
    double? marginTopMm,
    double? marginRightMm,
    double? marginBottomMm,
    double? marginLeftMm,
    double? spacingMm,
    DividerStyle? dividerStyle,
    DividerPattern? dividerPattern,
    double? dividerWidthMm,
    Color? dividerColor,
    Color? backgroundColor,
    bool? allowRotation,
    PackingStrategy? strategy,
    int? exportDpi,
    bool? shrinkOversizedPhotos,
  }) {
    return LayoutSettings(
      paper: paper ?? this.paper,
      orientation: orientation ?? this.orientation,
      marginTopMm: marginTopMm ?? this.marginTopMm,
      marginRightMm: marginRightMm ?? this.marginRightMm,
      marginBottomMm: marginBottomMm ?? this.marginBottomMm,
      marginLeftMm: marginLeftMm ?? this.marginLeftMm,
      spacingMm: spacingMm ?? this.spacingMm,
      dividerStyle: dividerStyle ?? this.dividerStyle,
      dividerPattern: dividerPattern ?? this.dividerPattern,
      dividerWidthMm: dividerWidthMm ?? this.dividerWidthMm,
      dividerColor: dividerColor ?? this.dividerColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      allowRotation: allowRotation ?? this.allowRotation,
      strategy: strategy ?? this.strategy,
      exportDpi: exportDpi ?? this.exportDpi,
      shrinkOversizedPhotos: shrinkOversizedPhotos ?? this.shrinkOversizedPhotos,
    );
  }

  /// Sets all four margins at once.
  LayoutSettings withUniformMargin(double millimeters) => copyWith(
    marginTopMm: millimeters,
    marginRightMm: millimeters,
    marginBottomMm: millimeters,
    marginLeftMm: millimeters,
  );

  Map<String, dynamic> toJson() => {
    'paper': paper.toJson(),
    'orientation': orientation.name,
    'marginTopMm': marginTopMm,
    'marginRightMm': marginRightMm,
    'marginBottomMm': marginBottomMm,
    'marginLeftMm': marginLeftMm,
    'spacingMm': spacingMm,
    'dividerStyle': dividerStyle.name,
    'dividerPattern': dividerPattern.name,
    'dividerWidthMm': dividerWidthMm,
    // ignore: deprecated_member_use
    'dividerColor': dividerColor.value,
    // ignore: deprecated_member_use
    'backgroundColor': backgroundColor.value,
    'allowRotation': allowRotation,
    'strategy': strategy.name,
    'exportDpi': exportDpi,
    'shrinkOversizedPhotos': shrinkOversizedPhotos,
  };

  factory LayoutSettings.fromJson(Map<String, dynamic> json) {
    T enumFrom<T extends Enum>(List<T> values, Object? name, T fallback) {
      for (final value in values) {
        if (value.name == name) return value;
      }
      return fallback;
    }

    return LayoutSettings(
      paper: json['paper'] is Map<String, dynamic>
          ? PaperFormat.fromJson(json['paper'] as Map<String, dynamic>)
          : PaperFormats.a4,
      orientation: enumFrom(PageOrientation.values, json['orientation'], PageOrientation.portrait),
      marginTopMm: (json['marginTopMm'] as num?)?.toDouble() ?? 8,
      marginRightMm: (json['marginRightMm'] as num?)?.toDouble() ?? 8,
      marginBottomMm: (json['marginBottomMm'] as num?)?.toDouble() ?? 8,
      marginLeftMm: (json['marginLeftMm'] as num?)?.toDouble() ?? 8,
      spacingMm: (json['spacingMm'] as num?)?.toDouble() ?? 3,
      dividerStyle: enumFrom(DividerStyle.values, json['dividerStyle'], DividerStyle.outline),
      dividerPattern: enumFrom(DividerPattern.values, json['dividerPattern'], DividerPattern.solid),
      dividerWidthMm: (json['dividerWidthMm'] as num?)?.toDouble() ?? 0.2,
      dividerColor: Color(json['dividerColor'] as int? ?? 0xFF9E9E9E),
      backgroundColor: Color(json['backgroundColor'] as int? ?? 0xFFFFFFFF),
      allowRotation: json['allowRotation'] as bool? ?? true,
      strategy: enumFrom(PackingStrategy.values, json['strategy'], PackingStrategy.bestShortSide),
      exportDpi: json['exportDpi'] as int? ?? 300,
      shrinkOversizedPhotos: json['shrinkOversizedPhotos'] as bool? ?? true,
    );
  }
}
