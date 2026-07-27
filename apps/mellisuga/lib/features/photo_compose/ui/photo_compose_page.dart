import 'package:flutter/material.dart';

import '../../../core/widgets/responsive.dart';
import '../state/compose_controller.dart';
import '../state/compose_scope.dart';
import 'photo_editor_page.dart';
import 'widgets/compose_toolbar.dart';
import 'widgets/export_sheet.dart';
import 'widgets/inspector_panel.dart';
import 'widgets/photo_list_panel.dart';
import 'widgets/sheet_preview.dart';

/// The photo composer.
///
/// Three regions — photo list, sheet preview, inspector — collapse gracefully:
/// desktop shows all three side by side, tablets drop the photo list into a
/// drawer, and phones show the preview alone with the panels as sheets.
class PhotoComposePage extends StatefulWidget {
  const PhotoComposePage({super.key});

  @override
  State<PhotoComposePage> createState() => _PhotoComposePageState();
}

class _PhotoComposePageState extends State<PhotoComposePage> {
  PreviewZoomMode _zoomMode = PreviewZoomMode.fitWidth;
  double _zoomScale = 1;
  bool _showMarginGuides = true;

  static const double _listPanelWidth = 316;
  static const double _inspectorWidth = 336;

  void _onZoomChanged(PreviewZoomMode mode, double scale) {
    setState(() {
      _zoomMode = mode;
      _zoomScale = scale;
    });
  }

  Future<void> _editPhoto(ComposeController controller, String itemId) async {
    final item = controller.items.where((item) => item.id == itemId).firstOrNull;
    if (item == null) return;
    controller.selectItem(itemId);
    final edits = await PhotoEditorPage.open(context, item);
    if (edits != null) controller.setEdits(itemId, edits);
  }

  void _openPanel(ComposeController controller, int tab) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, scrollController) => InspectorPanel(
          controller: controller,
          initialTab: tab,
          onEditPhoto: (id) {
            Navigator.of(context).pop();
            _editPhoto(controller, id);
          },
        ),
      ),
    );
  }

  void _openPhotoList(ComposeController controller) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, scrollController) => PhotoListPanel(
          controller: controller,
          onEditPhoto: (id) {
            Navigator.of(context).pop();
            _editPhoto(controller, id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ComposeScope.of(context);

    return ResponsiveBuilder(
      builder: (context, screen) {
        return Column(
          children: [
            ComposeToolbar(
              controller: controller,
              screen: screen,
              zoomMode: _zoomMode,
              zoomScale: _zoomScale,
              onZoomChanged: _onZoomChanged,
              showMarginGuides: _showMarginGuides,
              onToggleMarginGuides: () => setState(() => _showMarginGuides = !_showMarginGuides),
              onExport: () => ExportSheet.show(context, controller),
              onOpenPhotos: () => _openPhotoList(controller),
              onOpenSettings: () => _openPanel(controller, 1),
            ),
            if (controller.isBusy) _BusyBar(controller: controller),
            if (controller.importFailures.isNotEmpty) _ImportFailureBanner(controller: controller),
            if (controller.layout.hasWarnings) _LayoutWarningBanner(controller: controller),
            Expanded(
              child: Row(
                children: [
                  if (screen.isExpanded) ...[
                    SizedBox(
                      width: _listPanelWidth,
                      child: PhotoListPanel(
                        controller: controller,
                        onEditPhoto: (id) => _editPhoto(controller, id),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                  ],
                  Expanded(child: _buildStage(controller, screen)),
                  if (screen.hasSidePanels) ...[
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: _inspectorWidth,
                      child: InspectorPanel(
                        controller: controller,
                        onEditPhoto: (id) => _editPhoto(controller, id),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStage(ComposeController controller, ScreenSize screen) {
    if (controller.isEmpty) {
      return _EmptyStage(onAdd: controller.pickAndAddPhotos, busy: controller.isBusy);
    }
    if (!controller.hasPages) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Nothing could be placed on the sheet. Try a larger paper size or '
            'smaller print sizes.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SheetPreview(
      pages: controller.layout.pages,
      settings: controller.settings,
      itemsById: controller.itemsById,
      selectedInstanceKey: controller.selectedInstanceKey,
      onSelect: controller.selectInstance,
      onPhotoDoubleTap: (id) => _editPhoto(controller, id),
      zoomMode: _zoomMode,
      zoomScale: _zoomScale,
      onZoomChanged: _onZoomChanged,
      showMarginGuides: _showMarginGuides,
      showThumbnails: !screen.isCompact,
    );
  }
}

class _EmptyStage extends StatelessWidget {
  const _EmptyStage({required this.onAdd, required this.busy});

  final VoidCallback onAdd;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Center(
        child: ReadableWidth(
          maxWidth: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_mosaic_outlined,
                size: 56,
                color: theme.colorScheme.primary.withValues(alpha: 0.85),
              ),
              const SizedBox(height: 20),
              Text(
                'Fit more photos on every sheet',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                'Add photos, give each one a print size, and Mellisuga packs '
                'them onto as few pages as possible. Everything happens on this '
                'device — nothing is uploaded.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: busy ? null : onAdd,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add photos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusyBar extends StatelessWidget {
  const _BusyBar({required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(controller.statusMessage ?? 'Working…', style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: controller.progress == 0 ? null : controller.progress,
            minHeight: 3,
          ),
        ],
      ),
    );
  }
}

class _ImportFailureBanner extends StatelessWidget {
  const _ImportFailureBanner({required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final failures = controller.importFailures;
    return MaterialBanner(
      backgroundColor: theme.colorScheme.errorContainer,
      leading: Icon(Icons.error_outline_rounded, color: theme.colorScheme.onErrorContainer),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${failures.length} file${failures.length == 1 ? '' : 's'} could not be added',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          for (final failure in failures.take(4))
            Text(
              '${failure.fileName} — ${failure.reason}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onErrorContainer),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: controller.dismissImportFailures, child: const Text('Dismiss')),
      ],
    );
  }
}

class _LayoutWarningBanner extends StatelessWidget {
  const _LayoutWarningBanner({required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warnings = controller.layout.warnings;
    // Repeated copies of one photo produce identical warnings; show each once.
    final messages = <String>{for (final warning in warnings) warning.message};

    return Container(
      width: double.infinity,
      color: theme.colorScheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: theme.colorScheme.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final message in messages.take(3))
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
