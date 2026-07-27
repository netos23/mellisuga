import 'package:flutter/material.dart';

import '../../../../core/units/length.dart';
import '../../models/photo_item.dart';
import '../../state/compose_controller.dart';
import 'photo_thumbnail.dart';

/// The list of imported photos, in layout priority order.
class PhotoListPanel extends StatelessWidget {
  const PhotoListPanel({super.key, required this.controller, required this.onEditPhoto});

  final ComposeController controller;
  final ValueChanged<String> onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = controller.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Photos',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (items.isNotEmpty)
                Text(
                  '${items.length} · ${controller.totalPrints} print'
                  '${controller.totalPrints == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (items.isNotEmpty)
                IconButton(
                  tooltip: 'Remove all photos',
                  icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                  onPressed: () => _confirmRemoveAll(context),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: FilledButton.tonalIcon(
            onPressed: controller.isBusy ? null : controller.pickAndAddPhotos,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
            label: const Text('Add photos'),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: items.isEmpty
              ? _EmptyList(onAdd: controller.pickAndAddPhotos)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  onReorderItem: controller.moveItem,
                  buildDefaultDragHandles: false,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _PhotoTile(
                      key: ValueKey(item.id),
                      index: index,
                      item: item,
                      unit: controller.unit,
                      selected: controller.selectedItemId == item.id,
                      onTap: () => controller.selectItem(item.id),
                      onEdit: () => onEditPhoto(item.id),
                      onDuplicate: () => controller.duplicateItem(item.id),
                      onRemove: () => controller.removeItem(item.id),
                      onCopiesChanged: (copies) => controller.setCopies(item.id, copies),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _confirmRemoveAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove all photos?'),
        content: const Text(
          'Every photo and all of its edits will be discarded. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove all'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) controller.removeAll();
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    super.key,
    required this.index,
    required this.item,
    required this.unit,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDuplicate,
    required this.onRemove,
    required this.onCopiesChanged,
  });

  final int index;
  final PhotoItem item;
  final LengthUnit unit;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;
  final ValueChanged<int> onCopiesChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lowRes = item.effectiveDpi < 150;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Material(
        color: selected ? scheme.primaryContainer.withValues(alpha: 0.55) : null,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          onDoubleTap: onEdit,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4, top: 14),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        size: 18,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Center(child: PhotoThumbnail(item: item)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label ?? item.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${unit.format(item.printSize.widthMm)} × '
                        '${unit.formatWithSymbol(item.printSize.heightMm)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      if (lowRes) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 13, color: scheme.error),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${item.effectiveDpi.round()} DPI — may look soft',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.error,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _CopiesStepper(copies: item.copies, onChanged: onCopiesChanged),
                          const Spacer(),
                          _TileAction(
                            icon: Icons.tune_rounded,
                            tooltip: 'Crop, rotate and draw',
                            onPressed: onEdit,
                          ),
                          _TileAction(
                            icon: Icons.copy_all_outlined,
                            tooltip: 'Duplicate as a separate photo',
                            onPressed: onDuplicate,
                          ),
                          _TileAction(
                            icon: Icons.close_rounded,
                            tooltip: 'Remove',
                            onPressed: onRemove,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CopiesStepper extends StatelessWidget {
  const _CopiesStepper({required this.copies, required this.onChanged});

  final int copies;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: 'Number of prints',
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepperButton(
              icon: Icons.remove_rounded,
              onPressed: copies > 1 ? () => onChanged(copies - 1) : null,
            ),
            SizedBox(
              width: 26,
              child: Text(
                '×$copies',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            _StepperButton(
              icon: Icons.add_rounded,
              onPressed: copies < 999 ? () => onChanged(copies + 1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          icon,
          size: 15,
          color: onPressed == null
              ? Theme.of(context).disabledColor
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _TileAction extends StatelessWidget {
  const _TileAction({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 17),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_outlined, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('No photos yet', style: theme.textTheme.titleSmall, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'Add photos and Mellisuga packs them onto as few sheets as possible.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Choose files'),
            ),
          ],
        ),
      ),
    );
  }
}
