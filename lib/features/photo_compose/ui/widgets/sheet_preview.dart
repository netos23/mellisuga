import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/layout_result.dart';
import '../../models/layout_settings.dart';
import '../../models/photo_item.dart';
import '../painting/page_painter.dart';

/// How the preview decides its scale.
enum PreviewZoomMode {
  fitWidth('Fit width', Icons.fit_screen_outlined),
  fitPage('Fit page', Icons.crop_free_rounded),
  custom('Custom', Icons.zoom_in_rounded);

  const PreviewZoomMode(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// The large document view, modelled on a PDF reader: continuous vertical
/// scrolling, a page thumbnail rail, and zoom that is either fitted or manual.
class SheetPreview extends StatefulWidget {
  const SheetPreview({
    super.key,
    required this.pages,
    required this.settings,
    required this.itemsById,
    required this.selectedInstanceKey,
    required this.onSelect,
    required this.zoomMode,
    required this.zoomScale,
    required this.onZoomChanged,
    this.showThumbnails = true,
    this.showMarginGuides = true,
    this.onPhotoDoubleTap,
  });

  final List<ComposedPage> pages;
  final LayoutSettings settings;
  final Map<String, PhotoItem> itemsById;

  final String? selectedInstanceKey;
  final ValueChanged<String?> onSelect;

  /// Opens the editor for a placed photo.
  final ValueChanged<String>? onPhotoDoubleTap;

  final PreviewZoomMode zoomMode;

  /// Multiplier applied on top of fit-width when [zoomMode] is custom.
  final double zoomScale;
  final void Function(PreviewZoomMode mode, double scale) onZoomChanged;

  final bool showThumbnails;
  final bool showMarginGuides;

  @override
  State<SheetPreview> createState() => _SheetPreviewState();
}

class _SheetPreviewState extends State<SheetPreview> {
  final ScrollController _verticalController = ScrollController();
  final Map<int, GlobalKey> _pageKeys = {};

  static const double _pageGap = 28;
  static const double _outerPadding = 24;

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(int index) => _pageKeys.putIfAbsent(index, GlobalKey.new);

  Future<void> _scrollToPage(int index) async {
    final key = _pageKeys[index];
    final context = key?.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  void _handleZoomSignal(PointerScrollEvent event) {
    // Ctrl/Cmd + wheel is the near-universal zoom gesture on desktop.
    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    final zooming =
        pressed.contains(LogicalKeyboardKey.controlLeft) ||
        pressed.contains(LogicalKeyboardKey.controlRight) ||
        pressed.contains(LogicalKeyboardKey.metaLeft) ||
        pressed.contains(LogicalKeyboardKey.metaRight);
    if (!zooming) return;

    final current = widget.zoomMode == PreviewZoomMode.custom ? widget.zoomScale : 1.0;
    final next = (current * (event.scrollDelta.dy > 0 ? 0.9 : 1.1)).clamp(0.15, 8.0);
    widget.onZoomChanged(PreviewZoomMode.custom, next);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final showRail =
            widget.showThumbnails && widget.pages.length > 1 && constraints.maxWidth > 620;
        final railWidth = showRail ? 116.0 : 0.0;
        final viewportWidth = constraints.maxWidth - railWidth;

        final fitWidthPixelsPerMm = math.max(
          1.0,
          (viewportWidth - _outerPadding * 2) / widget.settings.pageWidthMm,
        );
        final fitPagePixelsPerMm = math.max(
          1.0,
          math.min(
            fitWidthPixelsPerMm,
            (constraints.maxHeight - _outerPadding * 2 - 28) / widget.settings.pageHeightMm,
          ),
        );

        final pixelsPerMm = switch (widget.zoomMode) {
          PreviewZoomMode.fitWidth => fitWidthPixelsPerMm,
          PreviewZoomMode.fitPage => fitPagePixelsPerMm,
          PreviewZoomMode.custom => fitWidthPixelsPerMm * widget.zoomScale,
        };

        final pageWidth = widget.settings.pageWidthMm * pixelsPerMm;

        return Container(
          color: AppTheme.canvasFor(context),
          child: Row(
            children: [
              if (showRail)
                _PageThumbnailRail(
                  pages: widget.pages,
                  settings: widget.settings,
                  itemsById: widget.itemsById,
                  width: railWidth,
                  onTap: _scrollToPage,
                ),
              Expanded(
                child: Listener(
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      _handleZoomSignal(event);
                    }
                  },
                  child: Scrollbar(
                    controller: _verticalController,
                    child: SingleChildScrollView(
                      controller: _verticalController,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: viewportWidth),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: _outerPadding),
                            child: Column(
                              children: [
                                for (final page in widget.pages) ...[
                                  _PageCard(
                                    key: _keyFor(page.index),
                                    page: page,
                                    settings: widget.settings,
                                    itemsById: widget.itemsById,
                                    pixelsPerMm: pixelsPerMm,
                                    width: pageWidth,
                                    selectedInstanceKey: widget.selectedInstanceKey,
                                    showMarginGuides: widget.showMarginGuides,
                                    onSelect: widget.onSelect,
                                    onPhotoDoubleTap: widget.onPhotoDoubleTap,
                                    pageCount: widget.pages.length,
                                  ),
                                  const SizedBox(height: _pageGap),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PageCard extends StatelessWidget {
  const _PageCard({
    super.key,
    required this.page,
    required this.settings,
    required this.itemsById,
    required this.pixelsPerMm,
    required this.width,
    required this.selectedInstanceKey,
    required this.showMarginGuides,
    required this.onSelect,
    required this.pageCount,
    this.onPhotoDoubleTap,
  });

  final ComposedPage page;
  final LayoutSettings settings;
  final Map<String, PhotoItem> itemsById;
  final double pixelsPerMm;
  final double width;
  final String? selectedInstanceKey;
  final bool showMarginGuides;
  final ValueChanged<String?> onSelect;
  final ValueChanged<String>? onPhotoDoubleTap;
  final int pageCount;

  /// Finds the placed photo under a local tap position.
  PlacedPhoto? _hitTest(Offset localPosition) {
    final xMm = localPosition.dx / pixelsPerMm;
    final yMm = localPosition.dy / pixelsPerMm;
    // Reverse order so the photo painted last wins, matching what is visible.
    for (final photo in page.photos.reversed) {
      if (xMm >= photo.xMm && xMm <= photo.rightMm && yMm >= photo.yMm && yMm <= photo.bottomMm) {
        return photo;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = settings.pageHeightMm * pixelsPerMm;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final hit = _hitTest(details.localPosition);
              onSelect(hit?.instanceKey);
            },
            onDoubleTapDown: (details) {
              final hit = _hitTest(details.localPosition);
              if (hit != null) onPhotoDoubleTap?.call(hit.itemId);
            },
            onDoubleTap: () {},
            child: SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                painter: PagePainter(
                  page: page,
                  settings: settings,
                  itemsById: itemsById,
                  pixelsPerMm: pixelsPerMm,
                  selectedInstanceKey: selectedInstanceKey,
                  showMarginGuides: showMarginGuides,
                  selectionColor: theme.colorScheme.primary,
                ),
                isComplex: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Page ${page.index + 1} of $pageCount  ·  '
          '${(page.coverage * 100).toStringAsFixed(0)}% covered  ·  '
          '${page.photos.length} photo${page.photos.length == 1 ? '' : 's'}',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _PageThumbnailRail extends StatelessWidget {
  const _PageThumbnailRail({
    required this.pages,
    required this.settings,
    required this.itemsById,
    required this.width,
    required this.onTap,
  });

  final List<ComposedPage> pages;
  final LayoutSettings settings;
  final Map<String, PhotoItem> itemsById;
  final double width;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumbWidth = width - 32;
    final pixelsPerMm = thumbWidth / settings.pageWidthMm;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                InkWell(
                  onTap: () => onTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: thumbWidth,
                      height: settings.pageHeightMm * pixelsPerMm,
                      child: CustomPaint(
                        painter: PagePainter(
                          page: page,
                          settings: settings,
                          itemsById: itemsById,
                          pixelsPerMm: pixelsPerMm,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${index + 1}', style: theme.textTheme.labelSmall),
              ],
            ),
          );
        },
      ),
    );
  }
}
