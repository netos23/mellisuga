import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Which part of the crop rectangle a drag is manipulating.
enum _CropHandle { topLeft, topRight, bottomLeft, bottomRight, top, right, bottom, left, move }

/// Interactive crop rectangle drawn over the untransformed source image.
///
/// The rectangle is stored in normalised image coordinates so it survives
/// zooming, window resizes and orientation changes untouched.
class CropOverlay extends StatefulWidget {
  const CropOverlay({
    super.key,
    required this.image,
    required this.imageRect,
    required this.cropRect,
    required this.onChanged,
    required this.sourceAspect,
    this.lockedAspect,
    this.minSize = 0.04,
  });

  final ui.Image image;

  /// Where the whole source image is drawn, in local coordinates.
  final Rect imageRect;

  /// Crop window in normalised image coordinates.
  final Rect cropRect;

  final ValueChanged<Rect> onChanged;

  /// Width divided by height of the full source image, in pixels.
  final double sourceAspect;

  /// Pixel aspect ratio the crop is constrained to, or `null` when free.
  final double? lockedAspect;

  /// Smallest allowed crop edge, as a fraction of the image.
  final double minSize;

  @override
  State<CropOverlay> createState() => _CropOverlayState();
}

class _CropOverlayState extends State<CropOverlay> {
  static const double _handleHitRadius = 26;

  _CropHandle? _active;
  Rect? _dragStartCrop;
  Offset? _dragStartPointer;

  @override
  void didUpdateWidget(covariant CropOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-apply the constraint when the user picks a different aspect lock.
    if (oldWidget.lockedAspect != widget.lockedAspect && widget.lockedAspect != null) {
      final constrained = _constrainToAspect(widget.cropRect, widget.lockedAspect!);
      if (constrained != widget.cropRect) {
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged(constrained));
      }
    }
  }

  Rect get _screenCrop => Rect.fromLTWH(
    widget.imageRect.left + widget.cropRect.left * widget.imageRect.width,
    widget.imageRect.top + widget.cropRect.top * widget.imageRect.height,
    widget.cropRect.width * widget.imageRect.width,
    widget.cropRect.height * widget.imageRect.height,
  );

  /// Normalised crop height that pairs with [width] to hit [aspect].
  ///
  /// The crop is normalised against the image's own dimensions, so the pixel
  /// aspect ratio is `(w · W) / (h · H)`. Solving for `h` brings the image's
  /// own aspect ratio into the equation.
  double _heightForWidth(double width, double aspect) => width * widget.sourceAspect / aspect;

  double _widthForHeight(double height, double aspect) => height * aspect / widget.sourceAspect;

  Rect _constrainToAspect(Rect crop, double aspect) {
    // Fit the largest rectangle of the requested aspect inside the current one,
    // keeping the centre put.
    var width = crop.width;
    var height = _heightForWidth(width, aspect);
    if (height > crop.height) {
      height = crop.height;
      width = _widthForHeight(height, aspect);
    }
    var left = crop.center.dx - width / 2;
    var top = crop.center.dy - height / 2;
    left = left.clamp(0.0, math.max(0.0, 1 - width));
    top = top.clamp(0.0, math.max(0.0, 1 - height));
    return Rect.fromLTWH(left, top, width, height);
  }

  _CropHandle _handleAt(Offset position) {
    final crop = _screenCrop;
    final corners = <_CropHandle, Offset>{
      _CropHandle.topLeft: crop.topLeft,
      _CropHandle.topRight: crop.topRight,
      _CropHandle.bottomLeft: crop.bottomLeft,
      _CropHandle.bottomRight: crop.bottomRight,
    };
    for (final entry in corners.entries) {
      if ((entry.value - position).distance <= _handleHitRadius) return entry.key;
    }

    final edges = <_CropHandle, Offset>{
      _CropHandle.top: Offset(crop.center.dx, crop.top),
      _CropHandle.bottom: Offset(crop.center.dx, crop.bottom),
      _CropHandle.left: Offset(crop.left, crop.center.dy),
      _CropHandle.right: Offset(crop.right, crop.center.dy),
    };
    for (final entry in edges.entries) {
      if ((entry.value - position).distance <= _handleHitRadius) return entry.key;
    }

    return _CropHandle.move;
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _active = _handleAt(details.localPosition);
      _dragStartCrop = widget.cropRect;
      _dragStartPointer = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final start = _dragStartCrop;
    final startPointer = _dragStartPointer;
    final handle = _active;
    if (start == null || startPointer == null || handle == null) return;

    final delta = details.localPosition - startPointer;
    final dx = delta.dx / widget.imageRect.width;
    final dy = delta.dy / widget.imageRect.height;

    widget.onChanged(_applyDrag(start, handle, dx, dy));
  }

  Rect _applyDrag(Rect start, _CropHandle handle, double dx, double dy) {
    if (handle == _CropHandle.move) {
      final left = (start.left + dx).clamp(0.0, 1 - start.width);
      final top = (start.top + dy).clamp(0.0, 1 - start.height);
      return Rect.fromLTWH(left, top, start.width, start.height);
    }

    var left = start.left;
    var top = start.top;
    var right = start.right;
    var bottom = start.bottom;

    if (handle == _CropHandle.topLeft ||
        handle == _CropHandle.left ||
        handle == _CropHandle.bottomLeft) {
      left = (start.left + dx).clamp(0.0, start.right - widget.minSize);
    }
    if (handle == _CropHandle.topRight ||
        handle == _CropHandle.right ||
        handle == _CropHandle.bottomRight) {
      right = (start.right + dx).clamp(start.left + widget.minSize, 1.0);
    }
    if (handle == _CropHandle.topLeft ||
        handle == _CropHandle.top ||
        handle == _CropHandle.topRight) {
      top = (start.top + dy).clamp(0.0, start.bottom - widget.minSize);
    }
    if (handle == _CropHandle.bottomLeft ||
        handle == _CropHandle.bottom ||
        handle == _CropHandle.bottomRight) {
      bottom = (start.bottom + dy).clamp(start.top + widget.minSize, 1.0);
    }

    var result = Rect.fromLTRB(left, top, right, bottom);

    final aspect = widget.lockedAspect;
    if (aspect != null) {
      result = _resizeToAspect(result, handle, aspect);
    }
    return result;
  }

  /// Re-imposes the locked aspect ratio, anchored to the edge or corner
  /// opposite the one being dragged.
  Rect _resizeToAspect(Rect rect, _CropHandle handle, double aspect) {
    final anchorRight =
        handle == _CropHandle.topLeft ||
        handle == _CropHandle.bottomLeft ||
        handle == _CropHandle.left;
    final anchorBottom =
        handle == _CropHandle.topLeft ||
        handle == _CropHandle.topRight ||
        handle == _CropHandle.top;

    // Edge drags decide the free dimension from the one the user moved;
    // corner drags follow whichever change was larger.
    final drivenByWidth = switch (handle) {
      _CropHandle.left || _CropHandle.right => true,
      _CropHandle.top || _CropHandle.bottom => false,
      _ => rect.width * widget.sourceAspect >= rect.height,
    };

    var width = rect.width;
    var height = rect.height;
    if (drivenByWidth) {
      height = _heightForWidth(width, aspect);
    } else {
      width = _widthForHeight(height, aspect);
    }

    // Shrink to stay inside the image if the constrained size overflows.
    if (width > 1) {
      width = 1;
      height = _heightForWidth(width, aspect);
    }
    if (height > 1) {
      height = 1;
      width = _widthForHeight(height, aspect);
    }

    var left = anchorRight ? rect.right - width : rect.left;
    var top = anchorBottom ? rect.bottom - height : rect.top;
    left = left.clamp(0.0, math.max(0.0, 1 - width));
    top = top.clamp(0.0, math.max(0.0, 1 - height));

    return Rect.fromLTWH(left, top, width, height);
  }

  void _onPanEnd() {
    setState(() {
      _active = null;
      _dragStartCrop = null;
      _dragStartPointer = null;
    });
  }

  MouseCursor _cursorFor(Offset position) => switch (_handleAt(position)) {
    _CropHandle.topLeft || _CropHandle.bottomRight => SystemMouseCursors.resizeUpLeftDownRight,
    _CropHandle.topRight || _CropHandle.bottomLeft => SystemMouseCursors.resizeUpRightDownLeft,
    _CropHandle.top || _CropHandle.bottom => SystemMouseCursors.resizeUpDown,
    _CropHandle.left || _CropHandle.right => SystemMouseCursors.resizeLeftRight,
    _CropHandle.move => SystemMouseCursors.move,
  };

  @override
  Widget build(BuildContext context) {
    return _CursorTracker(
      cursorFor: _cursorFor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: (_) => _onPanEnd(),
        onPanCancel: _onPanEnd,
        child: CustomPaint(
          size: Size.infinite,
          painter: _CropPainter(
            image: widget.image,
            imageRect: widget.imageRect,
            cropRect: widget.cropRect,
            accent: Theme.of(context).colorScheme.primary,
            dragging: _active != null,
          ),
        ),
      ),
    );
  }
}

/// Tracks pointer position so the cursor can change per crop handle.
class _CursorTracker extends StatefulWidget {
  const _CursorTracker({required this.child, required this.cursorFor});

  final Widget child;
  final MouseCursor Function(Offset position) cursorFor;

  @override
  State<_CursorTracker> createState() => _CursorTrackerState();
}

class _CursorTrackerState extends State<_CursorTracker> {
  MouseCursor _cursor = SystemMouseCursors.basic;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _cursor,
      onHover: (event) {
        final next = widget.cursorFor(event.localPosition);
        if (next != _cursor) setState(() => _cursor = next);
      },
      onExit: (_) => setState(() => _cursor = SystemMouseCursors.basic),
      child: widget.child,
    );
  }
}

class _CropPainter extends CustomPainter {
  const _CropPainter({
    required this.image,
    required this.imageRect,
    required this.cropRect,
    required this.accent,
    required this.dragging,
  });

  final ui.Image image;
  final Rect imageRect;
  final Rect cropRect;
  final Color accent;
  final bool dragging;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      imageRect,
      Paint()..filterQuality = FilterQuality.medium,
    );

    final screenCrop = Rect.fromLTWH(
      imageRect.left + cropRect.left * imageRect.width,
      imageRect.top + cropRect.top * imageRect.height,
      cropRect.width * imageRect.width,
      cropRect.height * imageRect.height,
    );

    // Dim everything outside the crop, using an even-odd path so the inside
    // stays untouched.
    final shade = Path()
      ..addRect(imageRect)
      ..addRect(screenCrop)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(shade, Paint()..color = Colors.black.withValues(alpha: 0.55));

    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(screenCrop, border);

    // Rule-of-thirds guides, shown while dragging to help composition.
    if (dragging) {
      final guide = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 1;
      for (var i = 1; i < 3; i++) {
        final x = screenCrop.left + screenCrop.width * i / 3;
        final y = screenCrop.top + screenCrop.height * i / 3;
        canvas
          ..drawLine(Offset(x, screenCrop.top), Offset(x, screenCrop.bottom), guide)
          ..drawLine(Offset(screenCrop.left, y), Offset(screenCrop.right, y), guide);
      }
    }

    _paintHandles(canvas, screenCrop);
  }

  void _paintHandles(Canvas canvas, Rect crop) {
    const armLength = 20.0;
    const thickness = 4.0;
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final arm = math.min(armLength, math.min(crop.width, crop.height) / 3);

    void corner(Offset point, double dx, double dy) {
      canvas
        ..drawLine(point, point + Offset(arm * dx, 0), paint)
        ..drawLine(point, point + Offset(0, arm * dy), paint);
    }

    corner(crop.topLeft, 1, 1);
    corner(crop.topRight, -1, 1);
    corner(crop.bottomLeft, 1, -1);
    corner(crop.bottomRight, -1, -1);

    // Edge grips, so the mid-edge drag targets are discoverable.
    final edgePaint = Paint()
      ..color = accent
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    final horizontalGrip = math.min(24.0, crop.width / 3);
    final verticalGrip = math.min(24.0, crop.height / 3);
    canvas
      ..drawLine(
        Offset(crop.center.dx - horizontalGrip / 2, crop.top),
        Offset(crop.center.dx + horizontalGrip / 2, crop.top),
        edgePaint,
      )
      ..drawLine(
        Offset(crop.center.dx - horizontalGrip / 2, crop.bottom),
        Offset(crop.center.dx + horizontalGrip / 2, crop.bottom),
        edgePaint,
      )
      ..drawLine(
        Offset(crop.left, crop.center.dy - verticalGrip / 2),
        Offset(crop.left, crop.center.dy + verticalGrip / 2),
        edgePaint,
      )
      ..drawLine(
        Offset(crop.right, crop.center.dy - verticalGrip / 2),
        Offset(crop.right, crop.center.dy + verticalGrip / 2),
        edgePaint,
      );
  }

  @override
  bool shouldRepaint(covariant _CropPainter oldDelegate) =>
      oldDelegate.cropRect != cropRect ||
      oldDelegate.imageRect != imageRect ||
      oldDelegate.dragging != dragging ||
      !identical(oldDelegate.image, image);
}
