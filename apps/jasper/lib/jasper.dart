/// Jasper: the static site generator behind the Mellisuga landing page.
///
/// It renders the shared product content — the same `mellisuga_content` package
/// the app compiles in — into plain HTML, CSS and SVG. There is no runtime, no
/// framework and no third-party request in the output; the whole site is files.
library;

export 'src/analytics.dart';
export 'src/analytics_config.dart';
export 'src/assets.dart';
export 'src/copy.dart';
export 'src/html.dart';
export 'src/i18n/site_strings.dart';
export 'src/illustrations.dart';
export 'src/layout.dart';
export 'src/markdown.dart';
export 'src/seo.dart';
export 'src/site.dart';
export 'src/site_config.dart';
