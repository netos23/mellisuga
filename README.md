# Mellisuga

**Photo and PDF tools that run in your browser.** No uploads, no accounts, no
server.

This repository holds two products and the content they share:

| Path | What it is |
| --- | --- |
| [`apps/mellisuga`](apps/mellisuga) | The Flutter app — web, Android, Windows, macOS, Linux |
| [`apps/jasper`](apps/jasper) | Jasper, the static site generator that builds the landing page |
| [`packages/mellisuga_content`](packages/mellisuga_content) | The facts both of them state: tools, legal text, formats, brand |

Named after *Mellisuga helenae*, the bee hummingbird — the smallest bird there
is, and a fitting mascot for tools that fit a lot into very little space.

---

## One site, two builds

Both are published by a single workflow, to a single GitHub Pages site:

```
https://<owner>.github.io/<repo>/          the landing site   (apps/jasper)
https://<owner>.github.io/<repo>/app/      the application    (apps/mellisuga)
```

The landing site is static HTML with no JavaScript requirement, so it is what
search engines and link previews see. The app is the Flutter build, published
underneath it.

**The app links to the landing site; it never contains it.** Nothing Jasper
produces is a Flutter asset, and no native build bundles a page — the About
screen has a *Website* link and that is the whole relationship. In the other
direction the landing page only ever writes an anchor to `/app/`.

## The shared package

`mellisuga_content` is pure Dart — no Flutter — because Jasper is a plain Dart
program and could not import it otherwise. It holds:

- **the tool catalogue**: title, summary, highlights, keywords and body copy for
  every tool, plus whether it is built yet;
- **the legal documents**: privacy policy, terms and licences, as structured
  text;
- **the physical formats**: paper sizes and print size presets, in millimetres;
- **the brand**: name, tagline, URLs, palette, and the hummingbird's geometry as
  SVG path data.

The app renders that with widgets; the site renders it as HTML. Neither owns it,
so the privacy policy on the website and the privacy policy in the app cannot
say different things, and a tool added to the catalogue appears in both.

## Localization

Both surfaces support English, French, German, Spanish, Russian, Arabic,
Japanese and Chinese. `AppLocale` in `mellisuga_content` is the one list every
surface agrees on:

- The app uses Flutter's standard `gen-l10n` — ARB files under
  `apps/mellisuga/lib/l10n/`, one per language, with `app_en.arb` as the
  template every other file is checked against. It follows the system
  language by default; a picker under the "⋮" menu or About overrides it,
  persisted on-device.
- The landing site builds every language's pages at once
  (`buildAllLocales` in `apps/jasper/lib/src/site.dart`): English stays at the
  site root for backward-compatible URLs, and every other language gets its
  own path prefix (`/fr/`, `/de/`, …), with `hreflang` alternates linking
  them together.
- Navigation, headings, tool names and summaries are translated; each tool's
  long-form overview, its own FAQ, and the legal documents stay in English for
  now, to avoid an unreviewed machine translation drifting from — or
  misstating — the source text on anything with legal weight. Non-English
  legal pages say so and link back to the English original.

Translations were produced without a professional review pass; corrections
are welcome as ordinary pull requests against the ARB files and the
`*_i18n.dart` files in `packages/mellisuga_content/lib/src/i18n/` and
`apps/jasper/lib/src/i18n/`.

## Working on it

```bash
# The app
cd apps/mellisuga
flutter pub get
flutter run -d chrome
flutter test && flutter analyze --fatal-infos

# The landing site
cd apps/jasper
dart pub get
dart run bin/build.dart --out build/preview --base-href / --site-url http://localhost:8080/
dart run bin/serve.dart build/preview      # http://localhost:8080
dart test

# The shared content
cd packages/mellisuga_content
dart pub get && dart test
```

Formatting is `dart format --line-length 100` everywhere, and CI checks it.

Each package resolves its own dependencies with a plain path dependency — there
is no workspace file to keep in step, and `flutter pub get` in the app is enough
to pick up a change in `mellisuga_content`.

## Continuous integration

| Workflow | Trigger | What it does |
| --- | --- | --- |
| [`ci.yml`](.github/workflows/ci.yml) | any branch but `main`, and PRs | Formats, analyses and tests all three packages; builds the landing site and the web app |
| [`deploy-pages.yml`](.github/workflows/deploy-pages.yml) | push to `main` | Tests everything, builds the landing site into the Pages root and the app into `/app/`, publishes once |
| [`release.yml`](.github/workflows/release.yml) | `v*` tags | Builds and attaches unsigned Android, Linux, macOS and Windows packages |

Enable Pages once under **Settings → Pages → Source → GitHub Actions**.

## Privacy

Mellisuga collects nothing. No analytics, no telemetry, no cookies, no accounts —
on the website as well as in the app. Files you open are held in memory and
discarded when you close the tab. After the page loads, neither the site nor the
app makes any network request at all: CanvasKit, the typeface, the stylesheet and
every illustration are served from the same origin as the page, and Jasper's test
suite fails the build if that ever stops being true.

See [PRIVACY.md](PRIVACY.md) and [TERMS.md](TERMS.md); both are also readable
inside the app and on the website.

## Licence

[MIT](LICENSE) © 2026 Nikita Morozov.

Bundled third-party components and their licences are listed in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), on the website's **Open source
licences** page, and on the app's **About → Open source licences** screen.
