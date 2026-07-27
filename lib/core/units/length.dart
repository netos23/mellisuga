/// Length handling for the whole application.
///
/// Every physical dimension in Mellisuga is stored in **millimetres** as a
/// `double`. Millimetres are a convenient base unit: they are small enough that
/// rounding never matters at print resolutions, and both metric and imperial
/// presets convert cleanly.
library;

/// Units a user can pick in the UI.
enum LengthUnit {
  millimeter('mm', 'Millimetres', 1.0, 0),
  centimeter('cm', 'Centimetres', 10.0, 1),
  inch('in', 'Inches', 25.4, 2),
  point('pt', 'Points', 25.4 / 72.0, 0);

  const LengthUnit(this.symbol, this.label, this.millimetersPerUnit, this.decimals);

  /// Short symbol shown next to numbers, e.g. `mm`.
  final String symbol;

  /// Human readable name used in menus.
  final String label;

  /// How many millimetres one unit is worth.
  final double millimetersPerUnit;

  /// Sensible number of decimals to show for this unit.
  final int decimals;

  /// Converts [millimeters] into this unit.
  double fromMillimeters(double millimeters) => millimeters / millimetersPerUnit;

  /// Converts [value], expressed in this unit, into millimetres.
  double toMillimeters(double value) => value * millimetersPerUnit;

  /// Formats [millimeters] for display, without the unit symbol.
  String format(double millimeters) => fromMillimeters(millimeters).toStringAsFixed(decimals);

  /// Formats [millimeters] for display, including the unit symbol.
  String formatWithSymbol(double millimeters) => '${format(millimeters)} $symbol';

  /// Step size that feels natural when nudging a value with arrow keys.
  double get step => switch (this) {
    LengthUnit.millimeter => 1,
    LengthUnit.centimeter => 0.1,
    LengthUnit.inch => 0.05,
    LengthUnit.point => 1,
  };
}

/// Conversions between physical millimetres and device pixels.
extension DotsPerInch on double {
  /// Interprets this value as millimetres and converts it to pixels at [dpi].
  double mmToPixels(double dpi) => this / 25.4 * dpi;

  /// Interprets this value as pixels at [dpi] and converts it to millimetres.
  double pixelsToMm(double dpi) => this / dpi * 25.4;

  /// Interprets this value as millimetres and converts it to PDF points
  /// (1 pt = 1/72 inch), which is the unit the `pdf` package draws in.
  double get mmToPdfPoints => this / 25.4 * 72.0;
}
