import 'package:mellisuga_content/mellisuga_content.dart';

import 'html.dart';

/// Every drawing on the site, as inline SVG.
///
/// Nothing here is a bitmap and nothing is fetched: the illustrations are part
/// of the HTML, so they inherit the current theme's colours, stay sharp at any
/// size, and cost no extra request. Motion is left to the stylesheet — these
/// functions only add the class names and custom properties the animations key
/// off, so `prefers-reduced-motion` can switch all of it off in one place.
abstract final class Illustrations {
  /// The hummingbird mark as a standalone graphic.
  ///
  /// [id] must be unique on the page: the eye is punched out with a mask, and
  /// two birds sharing an id would share one eye.
  static String mark({required String id, bool flying = true, String? title}) {
    final label = title == null
        ? 'aria-hidden="true" focusable="false"'
        : 'role="img" aria-label="${escapeHtml(title)}"';
    return '<svg class="${_markClasses(flying)}" viewBox="0 0 ${_n(BrandMark.canvasSize)} '
        '${_n(BrandMark.canvasSize)}" $label>\n${_markBody(id)}\n</svg>';
  }

  /// The mark as a group, for dropping inside a larger drawing.
  ///
  /// The placement transform goes on an outer group and the class on an inner
  /// one: a CSS animation on the marked element replaces its `transform`
  /// attribute outright, which would drop the bird back to the origin at full
  /// size the moment it started hovering.
  static String markGroup({required String id, required String transform, bool flying = true}) =>
      '<g transform="$transform">\n'
      '  <g class="${_markClasses(flying)}">\n${_markBody(id)}\n  </g>\n'
      '</g>';

  /// The hero: an A4 sheet filling up with prints, one after another.
  ///
  /// The rectangles are the real proportions of the presets they are named
  /// after — two units per millimetre — so the picture is an honest preview of
  /// what the packer does rather than a decorative arrangement.
  static String heroSheet() {
    const photos = <_Photo>[
      _Photo(20, 20, 200, 300, '10 × 15 cm'),
      _Photo(230, 20, 70, 90, 'passport'),
      _Photo(305, 20, 70, 90, 'passport'),
      _Photo(230, 115, 70, 90, 'passport'),
      _Photo(305, 115, 70, 90, 'passport'),
      _Photo(230, 215, 127, 178, 'wallet'),
      _Photo(20, 330, 102, 102, '5 × 5 cm'),
      _Photo(127, 330, 102, 102, '5 × 5 cm'),
      _Photo(20, 440, 70, 90, 'passport'),
      _Photo(95, 440, 70, 90, 'passport'),
      _Photo(170, 440, 70, 90, 'passport'),
      _Photo(245, 400, 127, 90, 'wallet, turned'),
    ];

    final rectangles = <String>[];
    for (var index = 0; index < photos.length; index++) {
      final photo = photos[index];
      final delay = (index * 0.12).toStringAsFixed(2);
      final box =
          'x="${_n(photo.x)}" y="${_n(photo.y)}" '
          'width="${_n(photo.width)}" height="${_n(photo.height)}" rx="3"';
      rectangles.add(
        '  <g class="sheet__photo" data-size="${escapeHtml(photo.label)}" '
        'style="--delay: ${delay}s">\n'
        '    <rect $box fill="url(#hero-photo-${index % 3})" />\n'
        '    <rect class="sheet__cut" $box />\n'
        '  </g>',
      );
    }

    return '''
<svg class="sheet" viewBox="0 0 420 594" role="img"
     aria-label="An A4 sheet filling up with photo prints of different sizes, each outlined with a cut line">
  <defs>
    <linearGradient id="hero-photo-0" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="${BrandColors.seedHex}" stop-opacity="0.85" />
      <stop offset="100%" stop-color="${BrandColors.seedHex}" stop-opacity="0.45" />
    </linearGradient>
    <linearGradient id="hero-photo-1" x1="0" y1="1" x2="1" y2="0">
      <stop offset="0%" stop-color="${BrandColors.accentHex}" stop-opacity="0.75" />
      <stop offset="100%" stop-color="${BrandColors.seedHex}" stop-opacity="0.55" />
    </linearGradient>
    <linearGradient id="hero-photo-2" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="${BrandColors.seedHex}" stop-opacity="0.6" />
      <stop offset="100%" stop-color="${BrandColors.accentHex}" stop-opacity="0.5" />
    </linearGradient>
  </defs>

  <rect class="sheet__paper" x="4" y="4" width="412" height="586" rx="8" />
  <rect class="sheet__margin" x="20" y="20" width="380" height="554" rx="4" />

${rectangles.join('\n')}

${markGroup(id: 'hero-bird', transform: 'translate(320 500) scale(0.7)')}
</svg>''';
  }

  /// One of the three value-proposition drawings.
  static String valueProp(String name) => switch (name) {
    'privacy' => _privacy(),
    'ruler' => _ruler(),
    'packing' => _packing(),
    _ => throw ArgumentError.value(name, 'name', 'No illustration by that name'),
  };

  /// The numbered step drawings, in order.
  static String step(int index) => switch (index) {
    0 => _stepImport(),
    1 => _stepSize(),
    2 => _stepExport(),
    _ => throw ArgumentError.value(index, 'index', 'Only three steps are drawn'),
  };

  /// A device holding two photos, with the route to the cloud struck out.
  static String _privacy() => '''
<svg class="spot" viewBox="0 0 120 96" role="img"
     aria-label="A laptop holding two photos, with the connection to a cloud crossed out">
  <g class="spot__stroke">
    <path class="spot__cloud" d="M 100 44 A 11 11 0 0 0 89 33 A 15 15 0 0 0 61 30 A 10 10 0 0 0 63 50 L 100 50 A 3 3 0 0 0 100 44 Z" />
    <rect x="10" y="44" width="62" height="38" rx="5" />
    <path d="M 4 88 L 78 88" />
    <rect class="spot__fill" x="20" y="53" width="18" height="21" rx="2" />
    <rect class="spot__fill spot__fill--accent" x="44" y="53" width="18" height="21" rx="2" />
    <path class="spot__dash" d="M 41 42 L 41 26" />
    <path class="spot__cross" d="M 24 18 L 58 52" />
  </g>
</svg>''';

  /// A ruler beside a print, because the millimetres are the point.
  static String _ruler() => '''
<svg class="spot" viewBox="0 0 120 96" role="img"
     aria-label="A ruler measuring a photo print to the millimetre">
  <g class="spot__stroke">
    <rect class="spot__fill" x="16" y="18" width="52" height="66" rx="4" />
    <rect x="80" y="14" width="24" height="74" rx="4" />
    <path d="M 80 24 L 90 24 M 80 34 L 95 34 M 80 44 L 90 44 M 80 54 L 95 54 M 80 64 L 90 64 M 80 74 L 95 74" />
    <path class="spot__dash" d="M 16 10 L 68 10" />
    <path d="M 16 6 L 16 14 M 68 6 L 68 14" />
  </g>
</svg>''';

  /// Small prints backfilling the gaps around a larger one.
  static String _packing() => '''
<svg class="spot" viewBox="0 0 120 96" role="img"
     aria-label="Small prints filling the gaps around a larger one on a sheet">
  <g class="spot__stroke">
    <rect x="12" y="8" width="96" height="80" rx="5" />
    <rect class="spot__fill" x="20" y="16" width="46" height="64" rx="3" />
    <rect class="spot__fill spot__fill--accent" x="72" y="16" width="28" height="30" rx="3" />
    <rect class="spot__fill" x="72" y="50" width="28" height="30" rx="3" />
  </g>
</svg>''';

  static String _stepImport() => '''
<svg class="step__art" viewBox="0 0 64 64" aria-hidden="true" focusable="false">
  <g class="spot__stroke">
    <rect class="spot__fill" x="8" y="18" width="34" height="34" rx="4" />
    <rect x="16" y="10" width="34" height="34" rx="4" />
    <path d="M 33 18 L 33 34 M 27 28 L 33 34 L 39 28" />
  </g>
</svg>''';

  static String _stepSize() => '''
<svg class="step__art" viewBox="0 0 64 64" aria-hidden="true" focusable="false">
  <g class="spot__stroke">
    <rect x="10" y="12" width="44" height="40" rx="4" />
    <rect class="spot__fill" x="16" y="18" width="18" height="28" rx="2" />
    <rect class="spot__fill spot__fill--accent" x="38" y="18" width="12" height="13" rx="2" />
    <path class="spot__dash" d="M 38 38 L 50 38 M 38 45 L 50 45" />
  </g>
</svg>''';

  static String _stepExport() => '''
<svg class="step__art" viewBox="0 0 64 64" aria-hidden="true" focusable="false">
  <g class="spot__stroke">
    <path d="M 16 40 L 16 10 L 40 10 L 48 18 L 48 40" />
    <path d="M 40 10 L 40 18 L 48 18" />
    <rect class="spot__fill" x="12" y="40" width="40" height="14" rx="3" />
    <path d="M 32 20 L 32 33 M 26 27 L 32 33 L 38 27" />
  </g>
</svg>''';

  /// The standalone favicon.
  ///
  /// Colours are baked in rather than themed: the browser chrome draws this,
  /// and no stylesheet of ours reaches it.
  static String faviconFile() {
    const scale = 0.68;
    const offset = 16.0;
    final shapes = BrandMark.paths
        .map(
          (shape) =>
              '    <path d="${shape.data}" '
              'fill="${shape.tone == MarkTone.accent ? '#FFC9DD' : '#FFFFFF'}" />',
        )
        .join('\n');

    return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <defs>
    <linearGradient id="tile" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#2AB6A4" />
      <stop offset="100%" stop-color="#0A7367" />
    </linearGradient>
    <mask id="eye">
      <rect width="100" height="100" fill="#fff" />
      <circle cx="${_n(offset + BrandMark.eyeX * scale)}" cy="${_n(offset + BrandMark.eyeY * scale)}" r="${_n(BrandMark.eyeHoleRadius * scale)}" fill="#000" />
    </mask>
  </defs>
  <rect width="100" height="100" rx="24" fill="url(#tile)" />
  <g mask="url(#eye)" transform="translate($offset $offset) scale($scale)">
$shapes
  </g>
  <circle cx="${_n(offset + BrandMark.eyeX * scale)}" cy="${_n(offset + BrandMark.eyeY * scale)}" r="${_n(BrandMark.eyePupilRadius * scale)}" fill="#FFFFFF" />
</svg>
''';
  }

  static String _markClasses(bool flying) => flying ? 'mark mark--flying' : 'mark';

  static String _markBody(String id) {
    final shapes = BrandMark.paths
        .map(
          (shape) =>
              '    <path class="mark__shape mark__shape--${shape.tone.name} '
              'mark__${shape.id}" d="${shape.data}" />',
        )
        .join('\n');
    const size = BrandMark.canvasSize;

    return '''
  <defs>
    <mask id="$id-eye">
      <rect width="${_n(size)}" height="${_n(size)}" fill="#fff" />
      <circle cx="${_n(BrandMark.eyeX)}" cy="${_n(BrandMark.eyeY)}" r="${_n(BrandMark.eyeHoleRadius)}" fill="#000" />
    </mask>
  </defs>
  <g mask="url(#$id-eye)">
$shapes
  </g>
  <circle class="mark__pupil" cx="${_n(BrandMark.eyeX)}" cy="${_n(BrandMark.eyeY)}" r="${_n(BrandMark.eyePupilRadius)}" />''';
  }
}

/// Trims the trailing `.0` off whole numbers so the SVG reads like something a
/// person typed.
String _n(double value) =>
    value == value.roundToDouble() ? value.round().toString() : value.toString();

class _Photo {
  const _Photo(this.x, this.y, this.width, this.height, this.label);

  final double x;
  final double y;
  final double width;
  final double height;

  /// The preset these proportions come from. Rendered as a `data-size`
  /// attribute — invisible, but it makes the drawing legible in a DOM
  /// inspector.
  final String label;
}
