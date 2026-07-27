import 'package:flutter/material.dart';

import '../../logic/divider_geometry.dart';
import '../../models/layout_result.dart';
import '../../models/layout_settings.dart';
import '../../models/photo_item.dart';
import 'photo_painting.dart';

/// Paints one composed sheet, one-to-one with what gets exported.
///
/// The painter works in millimetres and multiplies by [pixelsPerMm] on the way
/// out, so the same code drives a 90 px thumbnail and a full-screen preview.
class PagePainter extends CustomPainter {
  PagePainter({
    required this.page,
    required this.settings,
    required this.itemsById,
    required this.pixelsPerMm,
    this.selectedInstanceKey,
    this.showMarginGuides = false,
    this.showPlaceholders = true,
    this.selectionColor = const Color(0xFF3B82F6),
  });

  final ComposedPage page;
  final LayoutSettings settings;
  final Map<String, PhotoItem> itemsById;

  /// Canvas pixels per millimetre of paper.
  final double pixelsPerMm;

  /// Instance key (`itemId#copyIndex`) of the highlighted photo, if any.
  final String? selectedInstanceKey;

  /// Draws the non-printing margin outline. Preview only — never exported.
  final bool showMarginGuides;

  /// Draws a grey box for photos whose image has not decoded yet.
  final bool showPlaceholders;

  final Color selectionColor;

  @override
  void paint(Canvas canvas, Size size) {
    final pageRect = Rect.fromLTWH(0, 0, page.widthMm * pixelsPerMm, page.heightMm * pixelsPerMm);

    canvas.drawRect(pageRect, Paint()..color = settings.backgroundColor);

    for (final placed in page.photos) {
      final destination = Rect.fromLTWH(
        placed.xMm * pixelsPerMm,
        placed.yMm * pixelsPerMm,
        placed.widthMm * pixelsPerMm,
        placed.heightMm * pixelsPerMm,
      );
      final item = itemsById[placed.itemId];
      if (item == null) {
        if (showPlaceholders) {
          canvas.drawRect(destination, Paint()..color = const Color(0x1F000000));
        }
        continue;
      }

      // `contain` leaves empty space that must show the sheet colour, not
      // whatever was underneath.
      if (item.fit == PhotoFit.contain) {
        canvas.drawRect(destination, Paint()..color = settings.backgroundColor);
      }

      PhotoPainting.drawPhoto(
        canvas,
        image: item.image,
        edits: item.edits,
        destination: destination,
        fit: item.fit,
        layoutRotated: placed.rotated,
        filterQuality: pixelsPerMm < 1.5 ? FilterQuality.low : FilterQuality.medium,
      );
    }

    _paintGuides(canvas);

    if (showMarginGuides) {
      _paintMarginGuides(canvas, pageRect);
    }

    final selectedKey = selectedInstanceKey;
    if (selectedKey != null) {
      for (final placed in page.photos) {
        if (placed.instanceKey != selectedKey) continue;
        final rect = Rect.fromLTWH(
          placed.xMm * pixelsPerMm,
          placed.yMm * pixelsPerMm,
          placed.widthMm * pixelsPerMm,
          placed.heightMm * pixelsPerMm,
        );
        canvas
          ..drawRect(rect, Paint()..color = selectionColor.withValues(alpha: 0.14))
          ..drawRect(
            rect.deflate(0.5),
            Paint()
              ..color = selectionColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
      }
    }
  }

  void _paintGuides(Canvas canvas) {
    final segments = DividerGeometry.buildDashed(page, settings);
    if (segments.isEmpty) return;

    final paint = Paint()
      ..color = settings.dividerColor
      ..strokeWidth = (settings.dividerWidthMm * pixelsPerMm).clamp(0.4, double.infinity)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    for (final segment in segments) {
      canvas.drawLine(
        Offset(segment.x1 * pixelsPerMm, segment.y1 * pixelsPerMm),
        Offset(segment.x2 * pixelsPerMm, segment.y2 * pixelsPerMm),
        paint,
      );
    }
  }

  void _paintMarginGuides(Canvas canvas, Rect pageRect) {
    final printable = Rect.fromLTRB(
      settings.marginLeftMm * pixelsPerMm,
      settings.marginTopMm * pixelsPerMm,
      pageRect.right - settings.marginRightMm * pixelsPerMm,
      pageRect.bottom - settings.marginBottomMm * pixelsPerMm,
    );
    if (printable.isEmpty) return;

    const dash = 4.0;
    const gap = 4.0;
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.55)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    void dashedLine(Offset from, Offset to) {
      final delta = to - from;
      final total = delta.distance;
      if (total <= 0) return;
      final direction = delta / total;
      var travelled = 0.0;
      while (travelled < total) {
        final end = (travelled + dash).clamp(0.0, total);
        canvas.drawLine(from + direction * travelled, from + direction * end, paint);
        travelled = end + gap;
      }
    }

    dashedLine(printable.topLeft, printable.topRight);
    dashedLine(printable.topRight, printable.bottomRight);
    dashedLine(printable.bottomRight, printable.bottomLeft);
    dashedLine(printable.bottomLeft, printable.topLeft);
  }

  @override
  bool shouldRepaint(covariant PagePainter oldDelegate) {
    return oldDelegate.page != page ||
        oldDelegate.settings != settings ||
        oldDelegate.pixelsPerMm != pixelsPerMm ||
        oldDelegate.selectedInstanceKey != selectedInstanceKey ||
        oldDelegate.showMarginGuides != showMarginGuides ||
        !identical(oldDelegate.itemsById, itemsById);
  }
}
