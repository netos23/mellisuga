import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/units/length.dart';

/// A number field that edits a millimetre value in whichever unit the user has
/// selected.
///
/// The text is only rewritten from the outside when the field does not have
/// focus, so typing `12.5` never gets reformatted to `13` mid-keystroke.
class MeasureField extends StatefulWidget {
  const MeasureField({
    super.key,
    required this.valueMm,
    required this.unit,
    required this.onChanged,
    this.minMm = 0,
    this.maxMm = 2000,
    this.enabled = true,
    this.hintText,
  });

  final double valueMm;
  final LengthUnit unit;
  final ValueChanged<double> onChanged;
  final double minMm;
  final double maxMm;
  final bool enabled;
  final String? hintText;

  @override
  State<MeasureField> createState() => _MeasureFieldState();
}

class _MeasureFieldState extends State<MeasureField> {
  late final TextEditingController _controller = TextEditingController(
    text: _format(widget.valueMm),
  );
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChanged);

  String _format(double millimeters) => widget.unit.format(millimeters);

  @override
  void didUpdateWidget(covariant MeasureField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final unitChanged = oldWidget.unit != widget.unit;
    final valueChanged = oldWidget.valueMm != widget.valueMm;
    if ((unitChanged || valueChanged) && !_focusNode.hasFocus) {
      _controller.text = _format(widget.valueMm);
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) return;
    // Normalise whatever the user left behind once they move away.
    _commit(_controller.text);
    _controller.text = _format(widget.valueMm);
  }

  void _commit(String raw) {
    final parsed = double.tryParse(raw.trim().replaceAll(',', '.'));
    if (parsed == null) return;
    final millimeters = widget.unit.toMillimeters(parsed).clamp(widget.minMm, widget.maxMm);
    if (millimeters == widget.valueMm) return;
    widget.onChanged(millimeters);
  }

  void _nudge(double steps) {
    final next = widget.unit
        .toMillimeters(widget.unit.fromMillimeters(widget.valueMm) + steps * widget.unit.step)
        .clamp(widget.minMm, widget.maxMm);
    widget.onChanged(next);
    _controller.text = _format(next);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _nudge(1),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _nudge(-1),
      },
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*'))],
        onSubmitted: _commit,
        onChanged: _commit,
        decoration: InputDecoration(
          hintText: widget.hintText,
          suffixText: widget.unit.symbol,
          suffixStyle: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
