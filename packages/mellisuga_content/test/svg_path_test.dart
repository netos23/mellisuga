import 'package:mellisuga_content/mellisuga_content.dart';
import 'package:test/test.dart';

/// Records what a parse produced, so expectations can be written as strings.
class RecordingPathSink implements PathSink {
  final List<String> commands = <String>[];

  @override
  void moveTo(double x, double y) => commands.add('M $x $y');

  @override
  void lineTo(double x, double y) => commands.add('L $x $y');

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x, double y) =>
      commands.add('C $x1 $y1 $x2 $y2 $x $y');

  @override
  void quadraticBezierTo(double x1, double y1, double x, double y) =>
      commands.add('Q $x1 $y1 $x $y');

  @override
  void close() => commands.add('Z');
}

List<String> parse(String data) {
  final sink = RecordingPathSink();
  writeSvgPath(data, sink);
  return sink.commands;
}

void main() {
  group('writeSvgPath', () {
    test('replays every supported command', () {
      expect(parse('M 1 2 L 3 4 C 5 6 7 8 9 10 Q 11 12 13 14 Z'), [
        'M 1.0 2.0',
        'L 3.0 4.0',
        'C 5.0 6.0 7.0 8.0 9.0 10.0',
        'Q 11.0 12.0 13.0 14.0',
        'Z',
      ]);
    });

    test('repeats the last command for extra coordinate sets', () {
      expect(parse('L 1 1 2 2 3 3'), ['L 1.0 1.0', 'L 2.0 2.0', 'L 3.0 3.0']);
      expect(parse('C 0 0 1 1 2 2 3 3 4 4 5 5'), [
        'C 0.0 0.0 1.0 1.0 2.0 2.0',
        'C 3.0 3.0 4.0 4.0 5.0 5.0',
      ]);
    });

    test('treats coordinates after a moveto as lines, per the SVG spec', () {
      expect(parse('M 0 0 10 0 10 10 Z'), ['M 0.0 0.0', 'L 10.0 0.0', 'L 10.0 10.0', 'Z']);
    });

    test('accepts commas, negatives, decimals and exponents', () {
      expect(parse('M-1.5,+2.25L1e2,-3E-1'), ['M -1.5 2.25', 'L 100.0 -0.3']);
    });

    test('accepts newlines and tabs between tokens', () {
      expect(parse('M 1 2\n\tL\r\n3 4'), ['M 1.0 2.0', 'L 3.0 4.0']);
    });

    test('rejects data that does not start with a command', () {
      expect(() => parse('1 2 3'), throwsFormatException);
    });

    test('rejects relative commands rather than drawing the wrong shape', () {
      expect(() => parse('m 1 2 l 3 4'), throwsFormatException);
    });

    test('rejects unsupported commands', () {
      expect(() => parse('M 0 0 A 1 1 0 0 1 2 2'), throwsFormatException);
    });

    test('rejects numbers after a close', () {
      expect(() => parse('M 0 0 Z 1 2'), throwsFormatException);
    });

    test('rejects a truncated command', () {
      expect(() => parse('M 0 0 L 5'), throwsFormatException);
    });

    test('rejects a malformed exponent', () {
      expect(() => parse('M 1e 2'), throwsFormatException);
    });
  });

  group('BrandMark', () {
    test('every path parses', () {
      for (final path in BrandMark.paths) {
        expect(parse(path.data), isNotEmpty, reason: '${path.id} produced no commands');
      }
    });

    test('every path is closed and starts with a moveto', () {
      for (final path in BrandMark.paths) {
        final commands = parse(path.data);
        expect(commands.first, startsWith('M '), reason: '${path.id} does not start with a moveto');
        expect(commands.last, 'Z', reason: '${path.id} is not closed');
      }
    });

    test('ids are unique, so CSS can target them', () {
      final ids = BrandMark.paths.map((path) => path.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('geometry stays inside the authored canvas', () {
      for (final path in BrandMark.paths) {
        for (final number in RegExp(r'-?\d+(\.\d+)?').allMatches(path.data)) {
          final value = double.parse(number.group(0)!);
          expect(value, inInclusiveRange(0, BrandMark.canvasSize), reason: path.id);
        }
      }
    });

    test('both tones are used', () {
      expect(BrandMark.paths.map((path) => path.tone).toSet(), MarkTone.values.toSet());
    });
  });
}
