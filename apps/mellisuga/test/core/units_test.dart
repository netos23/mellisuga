import 'package:flutter_test/flutter_test.dart';
import 'package:mellisuga/core/units/length.dart';
import 'package:mellisuga/core/units/paper_format.dart';

void main() {
  group('LengthUnit', () {
    test('converts inches to millimetres', () {
      expect(LengthUnit.inch.toMillimeters(1), closeTo(25.4, 1e-9));
      expect(LengthUnit.inch.fromMillimeters(25.4), closeTo(1, 1e-9));
    });

    test('converts centimetres to millimetres', () {
      expect(LengthUnit.centimeter.toMillimeters(2.5), closeTo(25, 1e-9));
    });

    test('formats with the right precision per unit', () {
      expect(LengthUnit.millimeter.format(10), '10');
      expect(LengthUnit.centimeter.format(10), '1.0');
      expect(LengthUnit.inch.formatWithSymbol(25.4), '1.00 in');
    });

    test('round trips through every unit', () {
      for (final unit in LengthUnit.values) {
        expect(unit.toMillimeters(unit.fromMillimeters(123.4)), closeTo(123.4, 1e-9));
      }
    });
  });

  group('DPI conversions', () {
    test('A4 at 300 DPI is 2480 x 3508 pixels', () {
      expect(210.0.mmToPixels(300).round(), 2480);
      expect(297.0.mmToPixels(300).round(), 3508);
    });

    test('pixels convert back to millimetres', () {
      expect(2480.0.pixelsToMm(300), closeTo(209.97, 0.01));
    });

    test('A4 is 595 x 842 PDF points', () {
      expect(210.0.mmToPdfPoints.round(), 595);
      expect(297.0.mmToPdfPoints.round(), 842);
    });
  });

  group('PaperFormat', () {
    test('landscape swaps the two edges', () {
      final portrait = PaperFormats.a4.sizeFor(PageOrientation.portrait);
      final landscape = PaperFormats.a4.sizeFor(PageOrientation.landscape);
      expect(portrait.width, landscape.height);
      expect(portrait.height, landscape.width);
    });

    test('every built-in format has a unique id', () {
      final ids = PaperFormats.all.map((format) => format.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('lookup by id finds the format', () {
      expect(PaperFormats.byId('letter'), PaperFormats.letter);
      expect(PaperFormats.byId('nope'), isNull);
    });

    test('grouping keeps every format', () {
      final total = PaperFormats.grouped.values.fold<int>(
        0,
        (sum, formats) => sum + formats.length,
      );
      expect(total, PaperFormats.all.length);
    });
  });
}
