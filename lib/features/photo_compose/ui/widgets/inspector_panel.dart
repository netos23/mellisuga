import 'package:flutter/material.dart';

import '../../../../core/units/length.dart';
import '../../../../core/units/paper_format.dart';
import '../../models/layout_settings.dart';
import '../../models/photo_item.dart';
import '../../state/compose_controller.dart';
import 'color_swatch_picker.dart';
import 'measure_field.dart';
import 'panel_section.dart';
import 'print_size_picker.dart';

/// Right-hand panel: everything about the selected photo, and everything about
/// the sheet, split across two tabs.
class InspectorPanel extends StatelessWidget {
  const InspectorPanel({
    super.key,
    required this.controller,
    required this.onEditPhoto,
    this.initialTab = 0,
  });

  final ComposeController controller;
  final ValueChanged<String> onEditPhoto;
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Photo', height: 44),
              Tab(text: 'Sheet', height: 44),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              children: [
                _PhotoTab(controller: controller, onEditPhoto: onEditPhoto),
                _SheetTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTab extends StatelessWidget {
  const _PhotoTab({required this.controller, required this.onEditPhoto});

  final ComposeController controller;
  final ValueChanged<String> onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = controller.selectedItem;

    if (item == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined, size: 36, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              Text('Select a photo', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(
                'Pick one from the list or click it on the sheet to change its '
                'size, copies and framing.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final unit = controller.unit;
    final pixels = item.editedPixelSize;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        PanelSection(
          title: 'Print size',
          icon: Icons.straighten_rounded,
          children: [
            OutlinedButton(
              onPressed: () async {
                final size = await PrintSizePickerDialog.show(
                  context,
                  initial: item.printSize,
                  unit: unit,
                );
                if (size != null) controller.setPrintSize(item.id, size);
              },
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${unit.format(item.printSize.widthMm)} × '
                      '${unit.formatWithSymbol(item.printSize.heightMm)}',
                    ),
                  ),
                  const Icon(Icons.expand_more_rounded, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.swapPrintOrientation(item.id),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 17),
                    label: const Text('Rotate size'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.applySizeToAll(item.printSize),
                    icon: const Icon(Icons.select_all_rounded, size: 17),
                    label: const Text('Apply to all'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ResolutionNote(item: item),
          ],
        ),
        const Divider(height: 24),
        PanelSection(
          title: 'Framing',
          icon: Icons.crop_rounded,
          children: [
            SegmentedButton<PhotoFit>(
              segments: const [
                ButtonSegment(
                  value: PhotoFit.cover,
                  icon: Icon(Icons.crop_free_rounded, size: 17),
                  tooltip: 'Fill the frame, trimming the edges',
                ),
                ButtonSegment(
                  value: PhotoFit.contain,
                  icon: Icon(Icons.fit_screen_outlined, size: 17),
                  tooltip: 'Fit the whole photo, leaving margins',
                ),
                ButtonSegment(
                  value: PhotoFit.stretch,
                  icon: Icon(Icons.open_in_full_rounded, size: 17),
                  tooltip: 'Stretch to the frame',
                ),
              ],
              selected: {item.fit},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => controller.setFit(item.id, selection.first),
            ),
            const SizedBox(height: 6),
            Text(
              item.fit.label,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            FilledButton.tonalIcon(
              onPressed: () => onEditPhoto(item.id),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Crop, rotate & draw'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.rotateItem(item.id, clockwise: false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Icon(Icons.rotate_left_rounded, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.rotateItem(item.id),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Icon(Icons.rotate_right_rounded, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(height: 24),
        PanelSection(
          title: 'Layout',
          icon: Icons.dashboard_customize_outlined,
          children: [
            SwitchListTile(
              value: item.allowRotation,
              onChanged: (value) => controller.setAllowRotation(item.id, value),
              title: const Text('Allow 90° turn on the sheet'),
              subtitle: const Text('Lets the packer fit more per page'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ],
        ),
        const Divider(height: 24),
        PanelSection(
          title: 'Source',
          icon: Icons.info_outline_rounded,
          children: [
            _DetailRow(label: 'File', value: item.fileName),
            _DetailRow(label: 'Original', value: '${item.naturalWidth} × ${item.naturalHeight} px'),
            _DetailRow(label: 'After edits', value: '${pixels.width} × ${pixels.height} px'),
            _DetailRow(label: 'Print resolution', value: '${item.effectiveDpi.round()} DPI'),
          ],
        ),
      ],
    );
  }
}

class _ResolutionNote extends StatelessWidget {
  const _ResolutionNote({required this.item});

  final PhotoItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dpi = item.effectiveDpi;
    final (IconData icon, Color color, String message) = switch (dpi) {
      < 100 => (
        Icons.error_outline_rounded,
        theme.colorScheme.error,
        'Only ${dpi.round()} DPI at this size. The print will look noticeably '
            'blurry — use a smaller size or a higher resolution photo.',
      ),
      < 150 => (
        Icons.warning_amber_rounded,
        theme.colorScheme.error,
        '${dpi.round()} DPI. Acceptable at arm\'s length, soft up close.',
      ),
      < 240 => (
        Icons.info_outline_rounded,
        theme.colorScheme.onSurfaceVariant,
        '${dpi.round()} DPI. Good for everyday prints.',
      ),
      _ => (
        Icons.check_circle_outline_rounded,
        theme.colorScheme.primary,
        '${dpi.round()} DPI. Plenty of detail for photo quality.',
      ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: theme.textTheme.bodySmall?.copyWith(color: color)),
        ),
      ],
    );
  }
}

class _SheetTab extends StatelessWidget {
  const _SheetTab({required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = controller.settings;
    final unit = controller.unit;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        PanelSection(
          title: 'Paper',
          icon: Icons.description_outlined,
          children: [
            DropdownButtonFormField<String>(
              initialValue: settings.paper.id,
              isExpanded: true,
              items: [
                for (final entry in PaperFormats.grouped.entries)
                  ...entry.value.map(
                    (format) => DropdownMenuItem(
                      value: format.id,
                      child: Text(
                        '${format.name}  ·  ${format.widthMm.toStringAsFixed(0)}'
                        ' × ${format.heightMm.toStringAsFixed(0)} mm',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
              onChanged: (id) {
                final format = id == null ? null : PaperFormats.byId(id);
                if (format != null) controller.setPaper(format);
              },
            ),
            const SizedBox(height: 12),
            SegmentedButton<PageOrientation>(
              segments: const [
                ButtonSegment(
                  value: PageOrientation.portrait,
                  label: Text('Portrait'),
                  icon: Icon(Icons.stay_current_portrait_rounded, size: 16),
                ),
                ButtonSegment(
                  value: PageOrientation.landscape,
                  label: Text('Landscape'),
                  icon: Icon(Icons.stay_current_landscape_rounded, size: 16),
                ),
              ],
              selected: {settings.orientation},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => controller.setOrientation(selection.first),
            ),
            const SizedBox(height: 12),
            Text(
              'Printable area: '
              '${unit.format(settings.printableWidthMm)} × '
              '${unit.formatWithSymbol(settings.printableHeightMm)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const Divider(height: 24),
        PanelSection(
          title: 'Units',
          icon: Icons.straighten_rounded,
          children: [
            SegmentedButton<LengthUnit>(
              segments: const [
                ButtonSegment(value: LengthUnit.millimeter, label: Text('mm')),
                ButtonSegment(value: LengthUnit.centimeter, label: Text('cm')),
                ButtonSegment(value: LengthUnit.inch, label: Text('in')),
              ],
              selected: {unit},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => controller.setUnit(selection.first),
            ),
          ],
        ),
        const Divider(height: 24),
        _MarginsSection(controller: controller),
        const Divider(height: 24),
        PanelSection(
          title: 'Spacing',
          icon: Icons.space_bar_rounded,
          children: [
            InlineField(
              label: 'Between photos',
              child: MeasureField(
                valueMm: settings.spacingMm,
                unit: unit,
                maxMm: 100,
                onChanged: (value) =>
                    controller.updateSettings((settings) => settings.copyWith(spacingMm: value)),
              ),
            ),
          ],
        ),
        const Divider(height: 24),
        _DividersSection(controller: controller),
        const Divider(height: 24),
        PanelSection(
          title: 'Packing',
          icon: Icons.auto_awesome_mosaic_outlined,
          children: [
            for (final strategy in PackingStrategy.values)
              RadioListTile<PackingStrategy>(
                value: strategy,
                // ignore: deprecated_member_use
                groupValue: settings.strategy,
                // ignore: deprecated_member_use
                onChanged: (value) =>
                    controller.updateSettings((settings) => settings.copyWith(strategy: value)),
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(strategy.label),
                subtitle: Text(strategy.description),
              ),
            const SizedBox(height: 6),
            SwitchListTile(
              value: settings.allowRotation,
              onChanged: (value) =>
                  controller.updateSettings((settings) => settings.copyWith(allowRotation: value)),
              title: const Text('Turn photos to fit'),
              subtitle: const Text('Rotate photos 90° when it saves paper'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            SwitchListTile(
              value: settings.shrinkOversizedPhotos,
              onChanged: (value) => controller.updateSettings(
                (settings) => settings.copyWith(shrinkOversizedPhotos: value),
              ),
              title: const Text('Shrink oversized photos'),
              subtitle: const Text('Otherwise they are left out of the layout'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ],
        ),
        const Divider(height: 24),
        PanelSection(
          title: 'Sheet colour',
          icon: Icons.format_color_fill_rounded,
          children: [
            ColorSwatchPicker(
              value: settings.backgroundColor,
              onChanged: (color) => controller.updateSettings(
                (settings) => settings.copyWith(backgroundColor: color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anything other than white will use ink across the whole page.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

class _MarginsSection extends StatefulWidget {
  const _MarginsSection({required this.controller});

  final ComposeController controller;

  @override
  State<_MarginsSection> createState() => _MarginsSectionState();
}

class _MarginsSectionState extends State<_MarginsSection> {
  late bool _linked = widget.controller.settings.hasUniformMargins;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final settings = controller.settings;
    final unit = controller.unit;

    return PanelSection(
      title: 'Page margins',
      icon: Icons.border_outer_rounded,
      trailing: IconButton(
        tooltip: _linked ? 'Set each edge separately' : 'Use one value for all edges',
        icon: Icon(_linked ? Icons.link_rounded : Icons.link_off_rounded, size: 18),
        visualDensity: VisualDensity.compact,
        onPressed: () {
          setState(() => _linked = !_linked);
          if (_linked) {
            controller.updateSettings(
              (settings) => settings.withUniformMargin(settings.marginTopMm),
            );
          }
        },
      ),
      children: [
        if (_linked)
          InlineField(
            label: 'All edges',
            child: MeasureField(
              valueMm: settings.marginTopMm,
              unit: unit,
              maxMm: 120,
              onChanged: (value) =>
                  controller.updateSettings((settings) => settings.withUniformMargin(value)),
            ),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: LabeledField(
                  label: 'Top',
                  child: MeasureField(
                    valueMm: settings.marginTopMm,
                    unit: unit,
                    maxMm: 120,
                    onChanged: (value) => controller.updateSettings(
                      (settings) => settings.copyWith(marginTopMm: value),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LabeledField(
                  label: 'Bottom',
                  child: MeasureField(
                    valueMm: settings.marginBottomMm,
                    unit: unit,
                    maxMm: 120,
                    onChanged: (value) => controller.updateSettings(
                      (settings) => settings.copyWith(marginBottomMm: value),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: LabeledField(
                  label: 'Left',
                  child: MeasureField(
                    valueMm: settings.marginLeftMm,
                    unit: unit,
                    maxMm: 120,
                    onChanged: (value) => controller.updateSettings(
                      (settings) => settings.copyWith(marginLeftMm: value),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LabeledField(
                  label: 'Right',
                  child: MeasureField(
                    valueMm: settings.marginRightMm,
                    unit: unit,
                    maxMm: 120,
                    onChanged: (value) => controller.updateSettings(
                      (settings) => settings.copyWith(marginRightMm: value),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        Text(
          'Most printers cannot print within about 5 mm of the paper edge.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _DividersSection extends StatelessWidget {
  const _DividersSection({required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final settings = controller.settings;
    final unit = controller.unit;
    final hasDividers = settings.dividerStyle != DividerStyle.none;

    return PanelSection(
      title: 'Cutting guides',
      icon: Icons.content_cut_rounded,
      children: [
        DropdownButtonFormField<DividerStyle>(
          initialValue: settings.dividerStyle,
          isExpanded: true,
          items: [
            for (final style in DividerStyle.values)
              DropdownMenuItem(value: style, child: Text(style.label)),
          ],
          onChanged: (style) =>
              controller.updateSettings((settings) => settings.copyWith(dividerStyle: style)),
        ),
        const SizedBox(height: 6),
        Text(
          settings.dividerStyle.description,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        if (hasDividers) ...[
          const SizedBox(height: 14),
          InlineField(
            label: 'Line style',
            child: DropdownButtonFormField<DividerPattern>(
              initialValue: settings.dividerPattern,
              isExpanded: true,
              items: [
                for (final pattern in DividerPattern.values)
                  DropdownMenuItem(value: pattern, child: Text(pattern.label)),
              ],
              onChanged: (pattern) => controller.updateSettings(
                (settings) => settings.copyWith(dividerPattern: pattern),
              ),
            ),
          ),
          InlineField(
            label: 'Thickness',
            child: MeasureField(
              valueMm: settings.dividerWidthMm,
              unit: unit,
              minMm: 0.05,
              maxMm: 5,
              onChanged: (value) =>
                  controller.updateSettings((settings) => settings.copyWith(dividerWidthMm: value)),
            ),
          ),
          const SizedBox(height: 4),
          Text('Colour', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          ColorSwatchPicker(
            value: settings.dividerColor,
            onChanged: (color) =>
                controller.updateSettings((settings) => settings.copyWith(dividerColor: color)),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
