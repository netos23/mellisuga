import 'package:meta/meta.dart';

/// Which colour a piece of the mark is painted in.
enum MarkTone {
  /// The primary green-teal: body, tail and beak.
  body,

  /// The magenta accent: throat patch and wing.
  accent,
}

/// One filled shape of the hummingbird mark.
@immutable
class MarkPath {
  const MarkPath({required this.id, required this.data, required this.tone});

  /// Stable name, used as the CSS class on the site and in tests.
  final String id;

  /// SVG path data, in the mark's own 100 × 100 coordinate space.
  final String data;

  final MarkTone tone;
}

/// The Mellisuga mark: a hummingbird in flight.
///
/// The geometry lives here rather than in the app so the Flutter painter and
/// the site's inline SVG draw the same bird from the same numbers. The app
/// replays [paths] onto a `Path` through [PathSink]; the landing generator
/// writes them straight into `<path d="…">`.
///
/// `Mellisuga helenae` is the bee hummingbird — the smallest bird there is, and
/// a fitting mascot for tools that do a lot in very little space.
abstract final class BrandMark {
  /// The mark is authored on a square grid of this size.
  static const double canvasSize = 100;

  /// Tail: two swept feathers trailing to the lower left.
  static const MarkPath tail = MarkPath(
    id: 'tail',
    data: 'M 38 62 Q 24 72 6 88 Q 20 82 30 78 Q 22 86 16 96 Q 34 82 48 74 Z',
    tone: MarkTone.body,
  );

  /// Body: a teardrop running from the head down to where the tail starts.
  static const MarkPath body = MarkPath(
    id: 'body',
    data:
        'M 64 30 C 74 34 76 46 68 55 C 60 64 48 70 38 71 '
        'C 36 60 40 46 50 36 C 54 32 59 29 64 30 Z',
    tone: MarkTone.body,
  );

  /// Beak: a long, fine taper — the hummingbird's signature.
  static const MarkPath beak = MarkPath(
    id: 'beak',
    data: 'M 69 29 L 99 15 L 70 36 Z',
    tone: MarkTone.body,
  );

  /// Throat patch, in the iridescent accent colour.
  static const MarkPath throat = MarkPath(
    id: 'throat',
    data: 'M 66 34 C 73 38 73 47 66 52 C 62 46 62 39 66 34 Z',
    tone: MarkTone.accent,
  );

  /// Upstroke wing, drawn last so it reads as the nearest element.
  static const MarkPath wing = MarkPath(
    id: 'wing',
    data: 'M 52 40 C 50 22 34 8 12 6 C 26 22 32 40 42 54 C 46 51 50 46 52 40 Z',
    tone: MarkTone.accent,
  );

  /// Every shape, in paint order.
  static const List<MarkPath> paths = <MarkPath>[tail, body, beak, throat, wing];

  /// Centre of the eye.
  static const double eyeX = 64;
  static const double eyeY = 37;

  /// The eye is a body-coloured dot inside a hole punched clean through the
  /// mark, so it works on any background.
  static const double eyeHoleRadius = 3.2;
  static const double eyePupilRadius = 2.0;

  /// Where the wing meets the body. The site rotates the wing about this point
  /// to animate the flap.
  static const double wingPivotX = 48;
  static const double wingPivotY = 44;
}
