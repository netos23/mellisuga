import 'package:mellisuga_content/mellisuga_content.dart';

/// Copy that belongs to the landing page and nowhere else.
///
/// Anything the app also says — tool descriptions, legal text, the tagline —
/// comes from `package:mellisuga_content` instead. If a sentence here starts
/// showing up in the app too, it should move there.
abstract final class Copy {
  /// The page's one `h1`. Written for somebody who has just typed "print
  /// photos exact size" into a search engine, not for somebody who already
  /// knows what Mellisuga is.
  static const String heroHeading = 'Print photos at exactly the size you want';

  static const String heroLead =
      'Mellisuga packs passport photos, 10 × 15 cm prints and anything in '
      'between onto one sheet of A4, Letter or photo paper, then hands you a '
      'PDF. It runs entirely in your browser — your photos never leave the '
      'device they are on.';

  /// Short, checkable claims. Each one is either true of the build or it is not
  /// on this list.
  static const List<String> heroChips = <String>[
    'No upload',
    'No account',
    'No watermark',
    'Free & open source',
  ];

  static const String primaryAction = 'Open the app';
  static const String secondaryAction = 'See how it works';

  /// The three reasons somebody picks this over the first result for
  /// "photo collage printer online".
  static const List<ValueProp> valueProps = <ValueProp>[
    ValueProp(
      title: 'Your files stay on your device',
      body:
          'There is no backend. The page you load is a static file, and the '
          'photo you open is decoded in the tab and discarded when you close '
          'it. Nothing is transmitted, because there is nowhere to transmit it '
          'to.',
      illustration: 'privacy',
    ),
    ValueProp(
      title: 'Millimetres, not guesses',
      body:
          'Every measurement is held in millimetres and converted only at the '
          'edges. A 35 × 45 mm passport photo measures 35 × 45 mm under a '
          'ruler, and an A4 sheet exported at 300 DPI is exactly '
          '2480 × 3508 pixels.',
      illustration: 'ruler',
    ),
    ValueProp(
      title: 'Paper you already paid for',
      body:
          'The packer fills each sheet before it starts another: large prints '
          'first, small ones backfilled into the gaps, rotated 90° whenever '
          'that fits one more. What is left over is margin you asked for, not '
          'waste.',
      illustration: 'packing',
    ),
  ];

  static const List<Step> steps = <Step>[
    Step(
      title: 'Add your photos',
      body:
          'Drop in as many as you like. Orientation from the camera is applied '
          'on import, so nothing arrives sideways.',
    ),
    Step(
      title: 'Set a size for each one',
      body:
          'Pick a preset — passport, wallet, 10 × 15 cm — or type exact '
          'dimensions in millimetres, centimetres or inches. Crop, rotate and '
          'annotate without touching the original file.',
    ),
    Step(
      title: 'Print, or export a PDF',
      body:
          'The sheet re-packs as you go. Add cut lines, set your margins, then '
          'export a PDF or PNG at 150–600 DPI, or send it straight to a '
          'printer.',
    ),
  ];

  /// Section headings, kept together so the page outline is visible in one
  /// place.
  static const String toolsHeading = 'Every tool in the toolbox';
  static const String toolsLead =
      'One is finished and the rest are on the way. All of them work the same '
      'way: on your device, in the tab you already have open.';

  static const String sizesHeading = 'Sizes it already knows';
  static const String sizesLead =
      'Paper formats and print sizes are built in, so you can pick one instead '
      'of measuring it. Anything not on the list can be typed in exactly.';

  static const String platformsHeading = 'Where it runs';
  static const String platformsLead =
      'The browser build needs nothing installed. The native builds are the '
      'same code, packaged — useful when the machine you print from has no '
      'internet at all.';

  static const List<Platform> platforms = <Platform>[
    Platform(
      name: 'Browser',
      detail: 'Chrome, Edge, Firefox or Safari, desktop or mobile. Nothing to install.',
      isWeb: true,
    ),
    Platform(name: 'Android', detail: 'APK per architecture, attached to every release.'),
    Platform(name: 'Windows', detail: 'Portable zip. Unsigned, so Windows will ask once.'),
    Platform(name: 'macOS', detail: 'App bundle. Unsigned, so open it via right-click → Open.'),
    Platform(name: 'Linux', detail: 'Tarball with the bundle inside. GTK 3.'),
  ];

  static const String faqHeading = 'Questions people actually ask';

  static const String closingHeading = 'Open it and print something';
  static const String closingBody =
      'No sign-up, no upload, no trial. The tool opens in the tab you are '
      'already looking at.';

  /// Footer note under the legal links.
  static const String footerNote = Brand.nameOrigin;
}

/// One of the three reasons on the home page.
class ValueProp {
  const ValueProp({required this.title, required this.body, required this.illustration});

  final String title;
  final String body;

  /// Which illustration to draw beside it.
  final String illustration;
}

/// One numbered step in "how it works".
class Step {
  const Step({required this.title, required this.body});

  final String title;
  final String body;
}

/// One row in the platforms table.
class Platform {
  const Platform({required this.name, required this.detail, this.isWeb = false});

  final String name;
  final String detail;

  /// The browser row links to the app; the rest link to the releases page.
  final bool isWeb;
}
