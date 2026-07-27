import 'package:flutter/material.dart';

import '../../../../core/units/length.dart';
import '../../models/photo_size.dart';
import 'measure_field.dart';

/// Modal for choosing a photo's printed size, either from a preset or by
/// typing exact dimensions.
class PrintSizePickerDialog extends StatefulWidget {
  const PrintSizePickerDialog({super.key, required this.initial, required this.unit});

  final PhotoPrintSize initial;
  final LengthUnit unit;

  static Future<PhotoPrintSize?> show(
    BuildContext context, {
    required PhotoPrintSize initial,
    required LengthUnit unit,
  }) {
    return showDialog<PhotoPrintSize>(
      context: context,
      builder: (context) => PrintSizePickerDialog(initial: initial, unit: unit),
    );
  }

  @override
  State<PrintSizePickerDialog> createState() => _PrintSizePickerDialogState();
}

class _PrintSizePickerDialogState extends State<PrintSizePickerDialog> {
  late PhotoPrintSize _size = widget.initial;

  bool get _isLandscape => _size.widthMm > _size.heightMm;

  void _applyPreset(PhotoSizePreset preset) {
    setState(() {
      // Keep whichever orientation the user already had.
      _size = _isLandscape ? preset.size.swapped : preset.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = PhotoSizePresets.grouped;

    return AlertDialog(
      title: const Text('Print size'),
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      content: SizedBox(
        width: 420,
        height: 480,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: MeasureField(
                      valueMm: _size.widthMm,
                      unit: widget.unit,
                      minMm: 5,
                      maxMm: 1500,
                      onChanged: (value) => setState(() => _size = _size.copyWith(widthMm: value)),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('×')),
                  Expanded(
                    child: MeasureField(
                      valueMm: _size.heightMm,
                      unit: widget.unit,
                      minMm: 5,
                      maxMm: 1500,
                      onChanged: (value) => setState(() => _size = _size.copyWith(heightMm: value)),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Swap width and height',
                    icon: const Icon(Icons.swap_horiz_rounded),
                    onPressed: () => setState(() => _size = _size.swapped),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final entry in grouped.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    for (final preset in entry.value)
                      RadioListTile<String>(
                        value: preset.id,
                        // ignore: deprecated_member_use
                        groupValue: _size.presetId,
                        // ignore: deprecated_member_use
                        onChanged: (_) => _applyPreset(preset),
                        dense: true,
                        title: Text(preset.name),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_size),
          child: const Text('Use this size'),
        ),
      ],
    );
  }
}
