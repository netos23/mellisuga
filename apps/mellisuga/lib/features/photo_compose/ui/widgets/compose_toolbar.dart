import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive.dart';
import '../../state/compose_controller.dart';
import 'sheet_preview.dart';

/// The composer's action bar: add, zoom, guides and export.
///
/// On narrow screens the secondary actions collapse into an overflow menu and
/// two buttons open the photo list and sheet settings as bottom sheets.
class ComposeToolbar extends StatelessWidget {
  const ComposeToolbar({
    super.key,
    required this.controller,
    required this.screen,
    required this.zoomMode,
    required this.zoomScale,
    required this.onZoomChanged,
    required this.showMarginGuides,
    required this.onToggleMarginGuides,
    required this.onExport,
    required this.onOpenPhotos,
    required this.onOpenSettings,
  });

  final ComposeController controller;
  final ScreenSize screen;

  final PreviewZoomMode zoomMode;
  final double zoomScale;
  final void Function(PreviewZoomMode mode, double scale) onZoomChanged;

  final bool showMarginGuides;
  final VoidCallback onToggleMarginGuides;

  final VoidCallback onExport;
  final VoidCallback onOpenPhotos;
  final VoidCallback onOpenSettings;

  double get _effectiveScale => zoomMode == PreviewZoomMode.custom ? zoomScale : 1.0;

  void _zoomBy(double factor) =>
      onZoomChanged(PreviewZoomMode.custom, (_effectiveScale * factor).clamp(0.15, 8.0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canExport = controller.hasPages && !controller.isBusy;
    final compact = screen.isCompact;

    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: controller.isBusy ? null : controller.pickAndAddPhotos,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 19),
                  label: Text(compact ? 'Add' : 'Add photos'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18, vertical: 12),
                  ),
                ),
                if (compact) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Photos',
                    icon: const Icon(Icons.photo_library_outlined),
                    onPressed: onOpenPhotos,
                  ),
                  IconButton(
                    tooltip: 'Sheet settings',
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: onOpenSettings,
                  ),
                ],
                const Spacer(),
                if (!compact) ...[
                  _ZoomControls(
                    zoomMode: zoomMode,
                    zoomScale: zoomScale,
                    onZoomChanged: onZoomChanged,
                    onZoomBy: _zoomBy,
                    enabled: controller.hasPages,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: showMarginGuides ? 'Hide margin guides' : 'Show margin guides',
                    isSelected: showMarginGuides,
                    icon: const Icon(Icons.border_outer_rounded),
                    onPressed: onToggleMarginGuides,
                  ),
                  const SizedBox(width: 8),
                ],
                FilledButton.icon(
                  onPressed: canExport ? onExport : null,
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: Text(compact ? 'Export' : 'Export or print'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18, vertical: 12),
                  ),
                ),
                if (compact)
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    itemBuilder: (context) => [
                      CheckedPopupMenuItem(
                        value: 'guides',
                        checked: showMarginGuides,
                        child: const Text('Margin guides'),
                      ),
                      const PopupMenuItem(value: 'fit-width', child: Text('Fit width')),
                      const PopupMenuItem(value: 'fit-page', child: Text('Fit page')),
                    ],
                    onSelected: (value) => switch (value) {
                      'guides' => onToggleMarginGuides(),
                      'fit-width' => onZoomChanged(PreviewZoomMode.fitWidth, 1),
                      'fit-page' => onZoomChanged(PreviewZoomMode.fitPage, 1),
                      _ => null,
                    },
                  ),
              ],
            ),
          ),
          if (controller.hasPages) _SummaryStrip(controller: controller),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.zoomMode,
    required this.zoomScale,
    required this.onZoomChanged,
    required this.onZoomBy,
    required this.enabled,
  });

  final PreviewZoomMode zoomMode;
  final double zoomScale;
  final void Function(PreviewZoomMode mode, double scale) onZoomChanged;
  final ValueChanged<double> onZoomBy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = zoomMode == PreviewZoomMode.custom
        ? '${(zoomScale * 100).round()}%'
        : zoomMode.label;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Zoom out',
            icon: const Icon(Icons.remove_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: enabled ? () => onZoomBy(1 / 1.2) : null,
          ),
          PopupMenuButton<PreviewZoomMode>(
            enabled: enabled,
            tooltip: 'Zoom',
            itemBuilder: (context) => [
              for (final mode in PreviewZoomMode.values)
                if (mode != PreviewZoomMode.custom)
                  PopupMenuItem(
                    value: mode,
                    child: Row(
                      children: [
                        Icon(mode.icon, size: 17),
                        const SizedBox(width: 10),
                        Text(mode.label),
                      ],
                    ),
                  ),
              const PopupMenuDivider(),
              for (final scale in <double>[0.5, 1, 1.5, 2, 4])
                PopupMenuItem(
                  value: PreviewZoomMode.custom,
                  onTap: () => onZoomChanged(PreviewZoomMode.custom, scale),
                  child: Text('${(scale * 100).round()}%'),
                ),
            ],
            onSelected: (mode) {
              if (mode != PreviewZoomMode.custom) onZoomChanged(mode, 1);
            },
            child: Container(
              constraints: const BoxConstraints(minWidth: 84),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
              child: Text(label, textAlign: TextAlign.center, style: theme.textTheme.labelMedium),
            ),
          ),
          IconButton(
            tooltip: 'Zoom in',
            icon: const Icon(Icons.add_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: enabled ? () => onZoomBy(1.2) : null,
          ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = controller.layout;
    final settings = controller.settings;
    final lowRes = controller.lowResolutionItems.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DefaultTextStyle(
        style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
        child: Wrap(
          spacing: 18,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Stat(
              icon: Icons.description_outlined,
              label:
                  '${layout.pageCount} page${layout.pageCount == 1 ? '' : 's'} · '
                  '${settings.paper.name} ${settings.orientation.label.toLowerCase()}',
            ),
            _Stat(
              icon: Icons.photo_outlined,
              label:
                  '${layout.placedCount} print'
                  '${layout.placedCount == 1 ? '' : 's'} placed',
            ),
            _Stat(
              icon: Icons.pie_chart_outline_rounded,
              label: '${(layout.averageCoverage * 100).toStringAsFixed(0)}% paper used',
            ),
            if (lowRes > 0)
              _Stat(
                icon: Icons.warning_amber_rounded,
                label: '$lowRes photo${lowRes == 1 ? '' : 's'} below 150 DPI',
                color: theme.colorScheme.error,
              ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: color == null ? null : TextStyle(color: color)),
      ],
    );
  }
}
