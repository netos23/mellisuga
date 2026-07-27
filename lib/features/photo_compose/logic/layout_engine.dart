import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/layout_result.dart';
import '../models/layout_settings.dart';
import 'max_rects_packer.dart';

/// The minimum information the layout engine needs about one photo.
///
/// Deliberately free of `dart:ui` types so the engine stays pure Dart and can
/// be unit tested (and, if it ever becomes a bottleneck, moved to an isolate).
@immutable
class LayoutInput {
  const LayoutInput({
    required this.itemId,
    required this.widthMm,
    required this.heightMm,
    this.copies = 1,
    this.allowRotation = true,
  });

  final String itemId;
  final double widthMm;
  final double heightMm;
  final int copies;
  final bool allowRotation;

  double get areaMm2 => widthMm * heightMm;

  double get longestEdgeMm => math.max(widthMm, heightMm);
}

/// Turns a list of photos into a set of composed sheets.
///
/// The engine packs greedily: photos are sorted largest-first (which is what
/// makes greedy bin packing behave well in practice), then each one is placed
/// on the earliest sheet that still has room. Trying *every* open sheet rather
/// than only the newest one is what lets small photos backfill the gaps left
/// around large ones, and it is the single biggest win for paper usage.
abstract final class LayoutEngine {
  /// Hard cap so a pathological input cannot spin forever.
  static const int maxPages = 500;

  static LayoutResult compose({
    required List<LayoutInput> inputs,
    required LayoutSettings settings,
  }) {
    if (inputs.isEmpty) return LayoutResult.empty;

    final printableWidth = settings.printableWidthMm;
    final printableHeight = settings.printableHeightMm;
    final spacing = math.max(0.0, settings.spacingMm);

    final warnings = <LayoutWarning>[];

    // Expand copies into individual instances.
    final instances = <_Instance>[];
    for (final input in inputs) {
      for (var copy = 0; copy < math.max(1, input.copies); copy++) {
        instances.add(
          _Instance(
            itemId: input.itemId,
            copyIndex: copy,
            widthMm: input.widthMm,
            heightMm: input.heightMm,
            allowRotation: input.allowRotation && settings.allowRotation,
          ),
        );
      }
    }

    // Largest first. Ties break on the longest edge so awkward, elongated
    // photos are placed while the sheet is still mostly empty.
    instances.sort((a, b) {
      final byArea = b.areaMm2.compareTo(a.areaMm2);
      if (byArea != 0) return byArea;
      return b.longestEdgeMm.compareTo(a.longestEdgeMm);
    });

    // Photos are packed with the spacing baked into their size, on a bin that
    // is one spacing larger than the printable area. That yields exactly
    // `spacing` between neighbours and exactly the configured margin at the
    // sheet edges, without any special-casing for the first row or column.
    final binWidth = printableWidth + spacing;
    final binHeight = printableHeight + spacing;

    final bins = <MaxRectsBin>[];
    final pagePhotos = <List<PlacedPhoto>>[];

    for (final instance in instances) {
      var width = instance.widthMm;
      var height = instance.heightMm;
      var scaledDown = false;

      // A photo larger than the sheet is either shrunk or reported.
      final fitsUpright = width <= printableWidth && height <= printableHeight;
      final fitsRotated =
          instance.allowRotation && height <= printableWidth && width <= printableHeight;
      if (!fitsUpright && !fitsRotated) {
        if (!settings.shrinkOversizedPhotos) {
          warnings.add(
            LayoutWarning(
              itemId: instance.itemId,
              message: 'Does not fit on a ${settings.paper.name} sheet and was skipped.',
              fatal: true,
            ),
          );
          continue;
        }
        final scale = math.min(printableWidth / width, printableHeight / height);
        width *= scale;
        height *= scale;
        scaledDown = true;
        warnings.add(
          LayoutWarning(
            itemId: instance.itemId,
            message:
                'Larger than the printable area — scaled to '
                '${width.toStringAsFixed(1)} × ${height.toStringAsFixed(1)} mm.',
          ),
        );
      }

      var placed = false;
      for (var pageIndex = 0; pageIndex < bins.length; pageIndex++) {
        final placement = bins[pageIndex].insert(
          width + spacing,
          height + spacing,
          allowRotation: instance.allowRotation,
        );
        if (placement == null) continue;
        pagePhotos[pageIndex].add(
          _toPlacedPhoto(instance, placement, settings, width, height, scaledDown),
        );
        placed = true;
        break;
      }

      if (placed) continue;

      if (bins.length >= maxPages) {
        warnings.add(
          LayoutWarning(
            itemId: instance.itemId,
            message: 'Layout stopped at the $maxPages page limit.',
            fatal: true,
          ),
        );
        break;
      }

      final bin = MaxRectsBin(width: binWidth, height: binHeight, strategy: settings.strategy);
      final placement = bin.insert(
        width + spacing,
        height + spacing,
        allowRotation: instance.allowRotation,
      );
      bins.add(bin);
      pagePhotos.add(<PlacedPhoto>[]);
      if (placement == null) {
        // Should be unreachable given the fit check above, but never drop a
        // photo silently.
        warnings.add(
          LayoutWarning(
            itemId: instance.itemId,
            message: 'Could not be placed on an empty sheet.',
            fatal: true,
          ),
        );
        continue;
      }
      pagePhotos.last.add(_toPlacedPhoto(instance, placement, settings, width, height, scaledDown));
    }

    final pages = <ComposedPage>[
      for (var index = 0; index < pagePhotos.length; index++)
        ComposedPage(
          index: index,
          widthMm: settings.pageWidthMm,
          heightMm: settings.pageHeightMm,
          photos: _sortedForReading(pagePhotos[index]),
        ),
    ];

    return LayoutResult(pages: pages, warnings: warnings);
  }

  static PlacedPhoto _toPlacedPhoto(
    _Instance instance,
    PackPlacement placement,
    LayoutSettings settings,
    double width,
    double height,
    bool scaledDown,
  ) {
    // Strip the spacing that was baked into the packed rectangle and shift the
    // result into sheet coordinates.
    return PlacedPhoto(
      itemId: instance.itemId,
      copyIndex: instance.copyIndex,
      xMm: placement.rect.x + settings.marginLeftMm,
      yMm: placement.rect.y + settings.marginTopMm,
      widthMm: placement.rotated ? height : width,
      heightMm: placement.rotated ? width : height,
      rotated: placement.rotated,
      scaledDown: scaledDown,
    );
  }

  /// Orders photos top-to-bottom then left-to-right, so selection order and
  /// tab order on the preview match how a person reads the sheet.
  static List<PlacedPhoto> _sortedForReading(List<PlacedPhoto> photos) {
    final sorted = [...photos]
      ..sort((a, b) {
        const rowTolerance = 2.0;
        if ((a.yMm - b.yMm).abs() > rowTolerance) return a.yMm.compareTo(b.yMm);
        return a.xMm.compareTo(b.xMm);
      });
    return sorted;
  }
}

class _Instance {
  _Instance({
    required this.itemId,
    required this.copyIndex,
    required this.widthMm,
    required this.heightMm,
    required this.allowRotation,
  });

  final String itemId;
  final int copyIndex;
  final double widthMm;
  final double heightMm;
  final bool allowRotation;

  double get areaMm2 => widthMm * heightMm;

  double get longestEdgeMm => math.max(widthMm, heightMm);
}
