import 'package:meta/meta.dart';

/// How the licences page groups bundled components.
enum ComponentGroup {
  framework('Runtime frameworks'),
  package('Dart packages'),
  asset('Fonts and icons');

  const ComponentGroup(this.label);

  final String label;
}

/// One third-party component shipped inside the app.
@immutable
class ThirdPartyComponent {
  const ThirdPartyComponent({
    required this.name,
    required this.licence,
    required this.purpose,
    required this.group,
    this.url,
  });

  final String name;

  /// SPDX identifier.
  final String licence;

  /// Why the project depends on it.
  final String purpose;

  final ComponentGroup group;

  /// Homepage, when there is one worth linking.
  final String? url;
}

/// Everything Mellisuga bundles that somebody else wrote.
///
/// `THIRD_PARTY_NOTICES.md` in the repository root is the prose version of this
/// list; the site renders the list itself.
abstract final class ThirdPartyNotices {
  static const List<ThirdPartyComponent> components = <ThirdPartyComponent>[
    ThirdPartyComponent(
      name: 'Flutter & Dart SDK',
      url: 'https://flutter.dev',
      licence: 'BSD-3-Clause',
      purpose: 'Application framework',
      group: ComponentGroup.framework,
    ),
    ThirdPartyComponent(
      name: 'CanvasKit / Skia',
      url: 'https://skia.org',
      licence: 'BSD-3-Clause',
      purpose: 'Web rendering engine, bundled rather than fetched from a CDN',
      group: ComponentGroup.framework,
    ),
    ThirdPartyComponent(
      name: 'pdf',
      url: 'https://pub.dev/packages/pdf',
      licence: 'Apache-2.0',
      purpose: 'PDF generation',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'printing',
      url: 'https://pub.dev/packages/printing',
      licence: 'Apache-2.0',
      purpose: 'Print dialogs and sharing',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'image',
      url: 'https://pub.dev/packages/image',
      licence: 'MIT',
      purpose: 'Decoding, editing and encoding bitmaps',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'file_selector',
      url: 'https://pub.dev/packages/file_selector',
      licence: 'BSD-3-Clause',
      purpose: 'Opening and saving files',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'path_provider',
      url: 'https://pub.dev/packages/path_provider',
      licence: 'BSD-3-Clause',
      purpose: 'Platform directories on mobile',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'shared_preferences',
      url: 'https://pub.dev/packages/shared_preferences',
      licence: 'BSD-3-Clause',
      purpose: 'Remembering interface preferences',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'url_launcher',
      url: 'https://pub.dev/packages/url_launcher',
      licence: 'BSD-3-Clause',
      purpose: 'Opening external links',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'package_info_plus',
      url: 'https://pub.dev/packages/package_info_plus',
      licence: 'BSD-3-Clause',
      purpose: 'Reading the app version',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'web',
      url: 'https://pub.dev/packages/web',
      licence: 'BSD-3-Clause',
      purpose: 'Browser interop for downloads',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'collection',
      url: 'https://pub.dev/packages/collection',
      licence: 'BSD-3-Clause',
      purpose: 'Collection utilities',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'meta',
      url: 'https://pub.dev/packages/meta',
      licence: 'BSD-3-Clause',
      purpose: 'Annotations in the shared content package',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'cupertino_icons',
      url: 'https://pub.dev/packages/cupertino_icons',
      licence: 'MIT',
      purpose: 'Icon set',
      group: ComponentGroup.package,
    ),
    ThirdPartyComponent(
      name: 'Roboto',
      url: 'https://fonts.google.com/specimen/Roboto',
      licence: 'Apache-2.0',
      purpose: 'Typeface, bundled so nothing contacts a font CDN',
      group: ComponentGroup.asset,
    ),
    ThirdPartyComponent(
      name: 'Material Icons',
      url: 'https://fonts.google.com/icons',
      licence: 'Apache-2.0',
      purpose: 'Icon set shipped with Flutter',
      group: ComponentGroup.asset,
    ),
  ];

  static List<ThirdPartyComponent> inGroup(ComponentGroup group) =>
      components.where((component) => component.group == group).toList(growable: false);
}
