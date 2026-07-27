# Mellisuga — the app

**Photo and PDF tools that run in your browser.** No uploads, no accounts, no server.

This is the Flutter application: one codebase shipping to the web, to desktop
and to mobile. It is one of two things in this repository — the other is
[Jasper](../jasper), the landing site that describes it. Both read their content
from [`mellisuga_content`](../../packages/mellisuga_content).

Every tool does its work on your own device: the web build is a static site, so
there is no backend that *could* receive your files.

Named after *Mellisuga helenae*, the bee hummingbird — the smallest bird there
is, and a fitting mascot for tools that fit a lot into very little space.

---

## Tools

### Compose photos for print — available

Pack photos of any size onto a sheet with as little waste as possible.

- **Any paper size.** A2–A6, Letter, Legal, Tabloid, Executive, B4/B5 and common
  photo paper sizes, in portrait or landscape.
- **A print size per photo.** Passport (35 × 45 mm), US visa, wallet, 10 × 15 cm,
  4 × 6 in and more — or type exact dimensions in mm, cm or inches.
- **Automatic bin packing.** A MaxRects packer fills each sheet, turning photos
  90° where that saves paper, and starts a new page only when the current one is
  genuinely full. Small photos backfill the gaps left around large ones.
- **Per-photo editing.** Crop with an aspect lock, rotate in quarter turns, flip,
  and draw freehand annotations. All edits are non-destructive.
- **Cutting guides.** Outlines, full-sheet cut lines or corner crop marks, in
  solid, dashed or dotted, with configurable thickness and colour.
- **Margins and spacing** in your preferred unit, uniform or per-edge.
- **Export** to PDF or PNG/JPEG at 150–600 DPI, or send straight to a printer.
- **Resolution warnings** when a photo would print below 150 DPI.

### On the roadmap

Images → PDF · Merge PDFs · Split PDF · PDF → images · Resize & convert images ·
Rotate & reorder pages · Watermark

Each appears in the app with a page describing what it will do. Adding a tool is
a one-file change — see [Adding a tool](#adding-a-tool).

---

## Running it

```bash
cd apps/mellisuga
flutter pub get

# Web
flutter run -d chrome

# Desktop
flutter run -d linux    # or macos, windows

# Mobile
flutter run -d android  # or ios
```

Requires Flutter 3.44 or newer (Dart 3.12).

### Building

```bash
# Web. --no-web-resources-cdn bundles CanvasKit locally so the app makes no
# third-party requests at runtime, which is what the privacy policy promises.
flutter build web --release --no-web-resources-cdn

flutter build apk --release --split-per-abi
flutter build linux --release
flutter build macos --release
flutter build windows --release
```

### Tests

```bash
cd apps/mellisuga
flutter test
flutter analyze --fatal-infos
dart format --line-length 100 lib test
```

---

## How it works

```
lib/
├── core/
│   ├── units/          Millimetre-based length model, DPI maths
│   ├── tools/          Tool registry — icons and screens for the shared catalogue
│   ├── io/             Cross-platform file saving (web / desktop / mobile)
│   ├── theme/          Colour and type system
│   └── widgets/        Logo, responsive helpers
└── features/
    ├── shell/          App frame: navigation, theme, branding
    ├── home/           Tool gallery
    ├── legal/          Privacy policy, terms, licences, about
    ├── tool_placeholder/  Roadmap page for unbuilt tools
    └── photo_compose/
        ├── models/     Photo items, edits, layout settings, layout results
        ├── logic/      Packer, layout engine, image processing, importing
        ├── state/      ComposeController (ChangeNotifier) + scope
        ├── ui/         Page, panels, editor, painters
        └── export/     PDF and raster exporters
```

### Design decisions worth knowing

**Everything physical is in millimetres.** `double` millimetres are the single
source of truth; pixels and PDF points are derived at the edges. That is why an
A4 sheet exported at 300 DPI comes out at exactly 2480 × 3508 px.

**The preview never re-encodes.** On-screen photos are drawn straight onto
Flutter's canvas with transforms that reproduce the edit stack, so dragging a
crop handle costs nothing. The `image` package is only used at export time,
where real pixels are required. Both paths apply crop → annotations → flips →
rotation in exactly that order, so what you see is what prints.

**EXIF orientation is baked in at import.** Phone cameras store rotation as
metadata, and platform codecs disagree about whether to honour it. Importing
through the `image` package removes the ambiguity — at the cost of one decode
per photo, which is worth it when the output is going on paper.

**Layout runs synchronously.** Packing a few hundred rectangles takes well under
a millisecond, so the preview can never lag behind the controls.

**Guide geometry is computed once.** The preview, the PDF exporter and the
raster exporter all read the same millimetre-space segments, so the cut lines
you print are the cut lines you saw.

### What comes from the shared package

The tool catalogue, the legal documents, the paper formats, the print size
presets, the palette and the hummingbird's geometry all live in
[`mellisuga_content`](../../packages/mellisuga_content), because the landing site
publishes the same facts. The app adds what only a Flutter app can hold: icons,
screens, and the theme built around the shared colours. `AppInfo`,
`ToolDefinition` and `legal_content.dart` are thin wrappers over that package,
so existing imports inside the app still work.

The logo is drawn from `BrandMark`'s SVG path data, replayed onto a Flutter
`Path` — the same numbers the site inlines as `<path d="…">`.

### Adding a tool

1. Describe it: add a `ToolInfo` to `ToolCatalog` in `mellisuga_content`. That
   alone gives it a card, a page and a sitemap entry on the landing site.
2. Build the screen as a widget under `lib/features/<your_tool>/`.
3. Give it an icon and a builder in `lib/core/tools/tool_registry.dart`.

The home gallery, navigation rail, drawer, search and routing all read from the
registry, so nothing else needs touching.

---

## Deployment

Pushing to `main` triggers `.github/workflows/deploy-pages.yml`, which publishes
the landing site at the root of GitHub Pages and this app underneath it at
`/app/`. Enable it once under **Settings → Pages → Source → GitHub Actions**.

Tagging a release (`v1.2.3`) triggers `.github/workflows/release.yml`, which
builds Android APKs plus Linux, macOS and Windows packages and attaches them to
a GitHub release. Those binaries are unsigned. Native builds contain the app
only: they link out to the landing site from **About → Website**, and never
bundle it.

---

## Privacy

Mellisuga collects nothing. No analytics, no telemetry, no cookies, no accounts.
Files you open are held in memory and discarded when you close the tab. After the
page loads, the app makes no network requests at all — CanvasKit and the typeface
are bundled rather than fetched from a CDN.

See [PRIVACY.md](../../PRIVACY.md) and [TERMS.md](../../TERMS.md). Both are also
readable inside the app and on the website — all three render the same text from
the shared content package.

## Licence

[MIT](../../LICENSE) © 2026 Nikita Morozov.

Bundled third-party components and their licences are listed in
[THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md) and on the app's
**About → Open source licences** page.
