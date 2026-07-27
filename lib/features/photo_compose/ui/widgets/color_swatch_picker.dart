import 'package:flutter/material.dart';

/// A compact row of colour swatches.
///
/// The composer only ever needs paper white, a few greys and a couple of
/// accents for cut lines, so a fixed palette beats a full colour wheel.
class ColorSwatchPicker extends StatelessWidget {
  const ColorSwatchPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.colors = defaultPalette,
    this.swatchSize = 24,
  });

  final Color value;
  final ValueChanged<Color> onChanged;
  final List<Color> colors;
  final double swatchSize;

  static const List<Color> defaultPalette = [
    Color(0xFFFFFFFF),
    Color(0xFFF5F5F5),
    Color(0xFFBDBDBD),
    Color(0xFF9E9E9E),
    Color(0xFF616161),
    Color(0xFF212121),
    Color(0xFF000000),
    Color(0xFF0E9F8E),
    Color(0xFF2563EB),
    Color(0xFFE0457B),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final color in colors)
          Tooltip(
            // ignore: deprecated_member_use
            message: '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            child: InkWell(
              onTap: () => onChanged(color),
              borderRadius: BorderRadius.circular(swatchSize),
              child: Container(
                width: swatchSize,
                height: swatchSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == value ? scheme.primary : scheme.outlineVariant,
                    width: color == value ? 2.5 : 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
