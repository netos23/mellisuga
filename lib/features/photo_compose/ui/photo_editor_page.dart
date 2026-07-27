import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/photo_edits.dart';
import '../models/photo_item.dart';
import 'painting/photo_painting.dart';
import 'widgets/crop_overlay.dart';

/// Which editing tool is active.
enum EditorTool {
  crop('Crop', Icons.crop_rounded),
  transform('Rotate', Icons.rotate_90_degrees_ccw_rounded),
  draw('Draw', Icons.gesture_rounded);

  const EditorTool(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Full-screen editor for a single photo.
///
/// Edits are non-destructive: the page hands back a new [PhotoEdits] and the
/// original bytes are never touched, so the user can reopen and refine at any
/// point without accumulating quality loss.
class PhotoEditorPage extends StatefulWidget {
  const PhotoEditorPage({super.key, required this.item});

  final PhotoItem item;

  /// Opens the editor and resolves with the new edits, or `null` if cancelled.
  static Future<PhotoEdits?> open(BuildContext context, PhotoItem item) {
    return Navigator.of(context).push<PhotoEdits>(
      MaterialPageRoute(fullscreenDialog: true, builder: (context) => PhotoEditorPage(item: item)),
    );
  }

  @override
  State<PhotoEditorPage> createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  late PhotoEdits _edits = widget.item.edits;
  EditorTool _tool = EditorTool.crop;

  // Draw tool state.
  Color _strokeColor = const Color(0xFFE0457B);
  double _strokeWidth = 0.010;
  bool _erasing = false;
  List<Offset>? _activeStroke;

  /// Aspect ratio the crop is locked to, or `null` for a free crop.
  double? _cropAspect;

  bool get _dirty => _edits.signature != widget.item.edits.signature;

  @override
  void initState() {
    super.initState();
    // Starting locked to the print size is what people almost always want:
    // it shows exactly what will survive the crop on paper.
    _cropAspect = widget.item.printSize.aspectRatio;
  }

  void _update(PhotoEdits edits) => setState(() => _edits = edits);

  void _reset() => setState(() => _edits = const PhotoEdits());

  // ------------------------------------------------------------------ draw

  /// Maps a pointer position inside [imageRect] to cropped-source space.
  Offset _toCropSpace(Offset local, Rect imageRect) {
    final normalised = Offset(
      ((local.dx - imageRect.left) / imageRect.width).clamp(0.0, 1.0),
      ((local.dy - imageRect.top) / imageRect.height).clamp(0.0, 1.0),
    );
    return _edits.displayToCropSpace(normalised);
  }

  void _eraseAt(Offset cropPoint) {
    // Aspect-correct the hit radius so erasing feels the same in both axes.
    const radius = 0.03;
    final remaining = <DrawStroke>[];
    var removed = false;
    for (final stroke in _edits.strokes) {
      final hit = stroke.points.any(
        (point) => (point - cropPoint).distance <= radius + stroke.width,
      );
      if (hit && !removed) {
        removed = true;
        continue;
      }
      remaining.add(stroke);
    }
    if (removed) _update(_edits.copyWith(strokes: remaining));
  }

  void _startStroke(Offset local, Rect imageRect) {
    final point = _toCropSpace(local, imageRect);
    if (_erasing) {
      _eraseAt(point);
      return;
    }
    setState(() => _activeStroke = <Offset>[point]);
  }

  void _extendStroke(Offset local, Rect imageRect) {
    final point = _toCropSpace(local, imageRect);
    if (_erasing) {
      _eraseAt(point);
      return;
    }
    final active = _activeStroke;
    if (active == null) return;
    // Drop points that are too close together; it keeps the stroke list small
    // without any visible loss of fidelity.
    if (active.isNotEmpty && (active.last - point).distance < 0.002) return;
    setState(() => _activeStroke = [...active, point]);
  }

  void _endStroke() {
    final active = _activeStroke;
    if (active == null || active.isEmpty) {
      setState(() => _activeStroke = null);
      return;
    }
    setState(() {
      _edits = _edits.copyWith(
        strokes: [
          ..._edits.strokes,
          DrawStroke(points: active, color: _strokeColor, width: _strokeWidth),
        ],
      );
      _activeStroke = null;
    });
  }

  void _undoStroke() {
    if (_edits.strokes.isEmpty) return;
    _update(_edits.copyWith(strokes: _edits.strokes.sublist(0, _edits.strokes.length - 1)));
  }

  // ----------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Discard changes',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.item.label ?? widget.item.fileName, overflow: TextOverflow.ellipsis),
        actions: [
          TextButton.icon(
            onPressed: _edits.isIdentity ? null : _reset,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Reset'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(_edits),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(_dirty ? 'Apply' : 'Done'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(builder: (context, constraints) => _buildStage(constraints)),
            ),
          ),
          const Divider(height: 1),
          _buildToolControls(theme),
          NavigationBar(
            selectedIndex: EditorTool.values.indexOf(_tool),
            onDestinationSelected: (index) => setState(() {
              _tool = EditorTool.values[index];
              _activeStroke = null;
            }),
            destinations: [
              for (final tool in EditorTool.values)
                NavigationDestination(icon: Icon(tool.icon), label: tool.label),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStage(BoxConstraints constraints) {
    final available = Size(constraints.maxWidth, constraints.maxHeight);
    final image = widget.item.image;

    if (_tool == EditorTool.crop) {
      // Crop works against the untransformed source, so the user can always see
      // what is being trimmed away.
      final sourceRect = _fit(Size(image.width.toDouble(), image.height.toDouble()), available);
      return CropOverlay(
        image: image,
        imageRect: sourceRect,
        cropRect: _edits.cropRect,
        lockedAspect: _cropAspect,
        sourceAspect: image.width / image.height,
        onChanged: (rect) => _update(_edits.copyWith(cropRect: rect)),
      );
    }

    final editedAspect = _edits.aspectRatioFor(image.width, image.height);
    final imageRect = _fit(
      editedAspect >= 1 ? Size(editedAspect, 1) : Size(1, 1 / editedAspect),
      available,
    );

    final canvas = _EditorCanvas(
      item: widget.item,
      edits: _edits,
      imageRect: imageRect,
      activeStroke: _activeStroke,
      activeColor: _strokeColor,
      activeWidth: _strokeWidth,
    );

    if (_tool != EditorTool.draw) return canvas;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) => _startStroke(details.localPosition, imageRect),
      onPanUpdate: (details) => _extendStroke(details.localPosition, imageRect),
      onPanEnd: (_) => _endStroke(),
      onPanCancel: _endStroke,
      onTapDown: (details) => _startStroke(details.localPosition, imageRect),
      onTapUp: (_) => _endStroke(),
      child: MouseRegion(
        cursor: _erasing ? SystemMouseCursors.cell : SystemMouseCursors.precise,
        child: canvas,
      ),
    );
  }

  /// Centres a box of the given aspect ratio inside [available].
  Rect _fit(Size content, Size available) {
    final scale = math.min(available.width / content.width, available.height / content.height);
    final width = content.width * scale;
    final height = content.height * scale;
    return Rect.fromLTWH(
      (available.width - width) / 2,
      (available.height - height) / 2,
      width,
      height,
    );
  }

  Widget _buildToolControls(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: theme.colorScheme.surfaceContainerLow,
      child: switch (_tool) {
        EditorTool.crop => _buildCropControls(theme),
        EditorTool.transform => _buildTransformControls(theme),
        EditorTool.draw => _buildDrawControls(theme),
      },
    );
  }

  Widget _buildCropControls(ThemeData theme) {
    final printAspect = widget.item.printSize.aspectRatio;
    final sourceAspect = widget.item.naturalWidth / widget.item.naturalHeight;

    final options = <(String, double?)>[
      ('Free', null),
      ('Print size', printAspect),
      ('Original', sourceAspect),
      ('1:1', 1),
      ('4:3', 4 / 3),
      ('3:4', 3 / 4),
      ('16:9', 16 / 9),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text('Lock to', style: theme.textTheme.labelMedium),
          const SizedBox(width: 12),
          for (final (label, aspect) in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: _sameAspect(_cropAspect, aspect),
                onSelected: (_) => setState(() => _cropAspect = aspect),
              ),
            ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: _edits.cropRect == const Rect.fromLTWH(0, 0, 1, 1)
                ? null
                : () => _update(_edits.copyWith(cropRect: const Rect.fromLTWH(0, 0, 1, 1))),
            icon: const Icon(Icons.crop_free_rounded, size: 18),
            label: const Text('Whole photo'),
          ),
        ],
      ),
    );
  }

  static bool _sameAspect(double? a, double? b) {
    if (a == null || b == null) return a == b;
    return (a - b).abs() < 0.001;
  }

  Widget _buildTransformControls(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ToolButton(
            icon: Icons.rotate_left_rounded,
            label: 'Rotate left',
            onPressed: () => _update(_edits.copyWith(quarterTurns: _edits.quarterTurns - 1)),
          ),
          _ToolButton(
            icon: Icons.rotate_right_rounded,
            label: 'Rotate right',
            onPressed: () => _update(_edits.copyWith(quarterTurns: _edits.quarterTurns + 1)),
          ),
          const SizedBox(width: 8),
          _ToolButton(
            icon: Icons.flip_rounded,
            label: 'Flip across',
            selected: _edits.flipHorizontal,
            onPressed: () => _update(_edits.copyWith(flipHorizontal: !_edits.flipHorizontal)),
          ),
          _ToolButton(
            icon: Icons.flip_rounded,
            label: 'Flip down',
            rotateIcon: true,
            selected: _edits.flipVertical,
            onPressed: () => _update(_edits.copyWith(flipVertical: !_edits.flipVertical)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawControls(ThemeData theme) {
    const palette = [
      Color(0xFFE0457B),
      Color(0xFFEF4444),
      Color(0xFFF59E0B),
      Color(0xFF10B981),
      Color(0xFF2563EB),
      Color(0xFF111827),
      Color(0xFFFFFFFF),
    ];
    const widths = [('Thin', 0.004), ('Medium', 0.010), ('Thick', 0.024)];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final color in palette)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() {
                  _strokeColor = color;
                  _erasing = false;
                }),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: !_erasing && color == _strokeColor
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      width: !_erasing && color == _strokeColor ? 3 : 1,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
          for (final (label, width) in widths)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: !_erasing && _strokeWidth == width,
                onSelected: (_) => setState(() {
                  _strokeWidth = width;
                  _erasing = false;
                }),
              ),
            ),
          const SizedBox(width: 12),
          _ToolButton(
            icon: Icons.auto_fix_normal_rounded,
            label: 'Erase strokes',
            selected: _erasing,
            onPressed: () => setState(() => _erasing = !_erasing),
          ),
          _ToolButton(
            icon: Icons.undo_rounded,
            label: 'Undo stroke',
            onPressed: _edits.strokes.isEmpty ? null : _undoStroke,
          ),
          _ToolButton(
            icon: Icons.layers_clear_rounded,
            label: 'Clear drawing',
            onPressed: _edits.strokes.isEmpty
                ? null
                : () => _update(_edits.copyWith(strokes: const <DrawStroke>[])),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.selected = false,
    this.rotateIcon = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final bool rotateIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = Icon(icon, size: 20);
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        tooltip: label,
        onPressed: onPressed,
        isSelected: selected,
        style: IconButton.styleFrom(
          backgroundColor: selected ? scheme.primaryContainer : null,
          foregroundColor: selected ? scheme.onPrimaryContainer : null,
        ),
        icon: rotateIcon ? Transform.rotate(angle: math.pi / 2, child: child) : child,
      ),
    );
  }
}

/// Paints the photo with its current edits, plus the stroke being drawn.
class _EditorCanvas extends StatelessWidget {
  const _EditorCanvas({
    required this.item,
    required this.edits,
    required this.imageRect,
    required this.activeStroke,
    required this.activeColor,
    required this.activeWidth,
  });

  final PhotoItem item;
  final PhotoEdits edits;
  final Rect imageRect;
  final List<Offset>? activeStroke;
  final Color activeColor;
  final double activeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _EditorCanvasPainter(
        item: item,
        edits: edits,
        imageRect: imageRect,
        activeStroke: activeStroke,
        activeColor: activeColor,
        activeWidth: activeWidth,
        shadowColor: Colors.black.withValues(alpha: 0.25),
      ),
    );
  }
}

class _EditorCanvasPainter extends CustomPainter {
  const _EditorCanvasPainter({
    required this.item,
    required this.edits,
    required this.imageRect,
    required this.activeStroke,
    required this.activeColor,
    required this.activeWidth,
    required this.shadowColor,
  });

  final PhotoItem item;
  final PhotoEdits edits;
  final Rect imageRect;
  final List<Offset>? activeStroke;
  final Color activeColor;
  final double activeWidth;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      imageRect.inflate(1),
      Paint()
        ..color = shadowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    PhotoPainting.drawPhoto(
      canvas,
      image: item.image,
      edits: edits,
      destination: imageRect,
      // The rect was computed from the edited aspect ratio, so `contain`
      // fills it exactly with no letterboxing.
      fit: PhotoFit.contain,
      filterQuality: FilterQuality.high,
    );

    // The in-progress stroke lives in crop space, so it has to travel through
    // the same transform the committed strokes do.
    final active = activeStroke;
    if (active == null || active.isEmpty) return;

    final display = [for (final point in active) edits.cropToDisplaySpace(point)];
    final paint = Paint()
      ..color = activeColor
      ..strokeWidth = math.max(1.0, activeWidth * _cropSpaceWidth())
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    Offset toLocal(Offset normalised) => Offset(
      imageRect.left + normalised.dx * imageRect.width,
      imageRect.top + normalised.dy * imageRect.height,
    );

    if (display.length == 1) {
      canvas.drawCircle(
        toLocal(display.first),
        paint.strokeWidth / 2,
        Paint()..color = activeColor,
      );
      return;
    }

    final path = Path()..moveTo(toLocal(display.first).dx, toLocal(display.first).dy);
    for (var i = 1; i < display.length; i++) {
      final point = toLocal(display[i]);
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, paint);
  }

  /// On-screen length of one unit of cropped-image width.
  ///
  /// Stroke widths are stored relative to the cropped image's width, which maps
  /// to the display's *height* when the photo is turned a quarter turn.
  double _cropSpaceWidth() => edits.swapsAxes ? imageRect.height : imageRect.width;

  @override
  bool shouldRepaint(covariant _EditorCanvasPainter oldDelegate) =>
      oldDelegate.edits.signature != edits.signature ||
      oldDelegate.imageRect != imageRect ||
      oldDelegate.activeStroke != activeStroke ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.activeWidth != activeWidth;
}
