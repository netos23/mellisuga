# Third-party notices

Mellisuga bundles the components below. The complete licence text for every one
of them is available inside the application under
**About → Open source licences**, which Flutter generates from the actual
dependency set at build time.

## Runtime frameworks

| Component | Licence | Used for |
| --- | --- | --- |
| [Flutter](https://flutter.dev) & Dart SDK | BSD-3-Clause | Application framework |
| [CanvasKit / Skia](https://skia.org) | BSD-3-Clause | Web rendering engine (bundled, not fetched from a CDN) |

## Dart packages

| Package | Licence | Used for |
| --- | --- | --- |
| [`pdf`](https://pub.dev/packages/pdf) | Apache-2.0 | PDF generation |
| [`printing`](https://pub.dev/packages/printing) | Apache-2.0 | Print dialogs and sharing |
| [`image`](https://pub.dev/packages/image) | MIT | Decoding, editing and encoding bitmaps |
| [`file_selector`](https://pub.dev/packages/file_selector) | BSD-3-Clause | Opening and saving files |
| [`path_provider`](https://pub.dev/packages/path_provider) | BSD-3-Clause | Platform directories on mobile |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | BSD-3-Clause | Remembering interface preferences |
| [`url_launcher`](https://pub.dev/packages/url_launcher) | BSD-3-Clause | Opening external links |
| [`package_info_plus`](https://pub.dev/packages/package_info_plus) | BSD-3-Clause | Reading the app version |
| [`web`](https://pub.dev/packages/web) | BSD-3-Clause | Browser interop for downloads |
| [`collection`](https://pub.dev/packages/collection) | BSD-3-Clause | Collection utilities |
| [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) | MIT | Icon set |

## Fonts and icons

| Asset | Licence | Notes |
| --- | --- | --- |
| Roboto (`assets/fonts/`) | Apache-2.0 | Bundled so the app never contacts a font CDN. Full licence text ships at `assets/fonts/Roboto_LICENSE.txt`. |
| Material Icons | Apache-2.0 | Shipped with Flutter |

## Original work

The Mellisuga hummingbird mark (`lib/core/widgets/app_logo.dart` and the
generated icon set) is original to this project and is covered by the repository's
[MIT License](LICENSE).
