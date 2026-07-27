/// Receives the commands parsed out of SVG path data.
///
/// The method signatures deliberately match Flutter's `Path`, so the app's
/// adapter is five one-line forwards and the brand artwork can live in this
/// Flutter-free package.
abstract interface class PathSink {
  void moveTo(double x, double y);

  void lineTo(double x, double y);

  void cubicTo(double x1, double y1, double x2, double y2, double x, double y);

  void quadraticBezierTo(double x1, double y1, double x, double y);

  void close();
}

/// Replays SVG path [data] onto [sink].
///
/// Only the absolute subset the brand artwork uses is supported — `M`, `L`,
/// `C`, `Q` and `Z`, with the usual implicit repetition (a bare pair of numbers
/// after `M` is a line, as the SVG specification requires). Anything else
/// throws rather than being silently dropped, because a path that half-parses
/// draws a shape nobody designed.
void writeSvgPath(String data, PathSink sink) {
  final parser = _PathParser(data, sink);
  parser.run();
}

class _PathParser {
  _PathParser(this.data, this.sink);

  final String data;
  final PathSink sink;

  int _index = 0;
  String? _command;

  static const int _space = 0x20;
  static const int _tab = 0x09;
  static const int _newline = 0x0A;
  static const int _carriageReturn = 0x0D;
  static const int _comma = 0x2C;
  static const int _zero = 0x30;
  static const int _nine = 0x39;

  void run() {
    while (true) {
      _skipSeparators();
      if (_index >= data.length) break;

      final character = data[_index];
      if (_isLetter(character)) {
        _index++;
        _command = character;
      } else {
        final current = _command;
        if (current == null) {
          throw FormatException('Path data must start with a command', data, _index);
        }
        if (current == 'Z') {
          throw FormatException('Numbers cannot follow a Z command', data, _index);
        }
        // A moveto followed by more coordinate pairs draws lines.
        if (current == 'M') _command = 'L';
      }

      switch (_command) {
        case 'M':
          final x = _readNumber();
          final y = _readNumber();
          sink.moveTo(x, y);
        case 'L':
          final x = _readNumber();
          final y = _readNumber();
          sink.lineTo(x, y);
        case 'C':
          final x1 = _readNumber();
          final y1 = _readNumber();
          final x2 = _readNumber();
          final y2 = _readNumber();
          final x = _readNumber();
          final y = _readNumber();
          sink.cubicTo(x1, y1, x2, y2, x, y);
        case 'Q':
          final x1 = _readNumber();
          final y1 = _readNumber();
          final x = _readNumber();
          final y = _readNumber();
          sink.quadraticBezierTo(x1, y1, x, y);
        case 'Z':
          sink.close();
        default:
          throw FormatException(
            'Unsupported path command "$_command" — only absolute M, L, C, Q '
            'and Z are handled',
            data,
            _index - 1,
          );
      }
    }
  }

  void _skipSeparators() {
    while (_index < data.length) {
      final unit = data.codeUnitAt(_index);
      if (unit == _space ||
          unit == _tab ||
          unit == _newline ||
          unit == _carriageReturn ||
          unit == _comma) {
        _index++;
      } else {
        return;
      }
    }
  }

  double _readNumber() {
    _skipSeparators();
    final start = _index;

    _consumeSign();
    final digitsBefore = _consumeDigits();
    var digitsAfter = 0;
    if (_index < data.length && data[_index] == '.') {
      _index++;
      digitsAfter = _consumeDigits();
    }
    if (digitsBefore == 0 && digitsAfter == 0) {
      throw FormatException('Expected a number', data, start);
    }

    if (_index < data.length && (data[_index] == 'e' || data[_index] == 'E')) {
      final exponentStart = _index;
      _index++;
      _consumeSign();
      if (_consumeDigits() == 0) {
        throw FormatException('Expected an exponent', data, exponentStart);
      }
    }

    return double.parse(data.substring(start, _index));
  }

  void _consumeSign() {
    if (_index < data.length && (data[_index] == '-' || data[_index] == '+')) _index++;
  }

  int _consumeDigits() {
    final start = _index;
    while (_index < data.length) {
      final unit = data.codeUnitAt(_index);
      if (unit < _zero || unit > _nine) break;
      _index++;
    }
    return _index - start;
  }

  static bool _isLetter(String character) {
    final unit = character.codeUnitAt(0);
    return (unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A);
  }
}
