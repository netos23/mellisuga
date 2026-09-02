# mellisuga_content

Everything the Mellisuga app and the landing site have to agree on.

This package is pure Dart — no Flutter — because the landing generator is a
plain Dart program and could not import it otherwise. The app renders this
content with widgets; the site renders it as HTML. Neither owns it.

| File | What lives there |
| --- | --- |
| `brand.dart` | Name, tagline, descriptions, every public URL, the palette |
| `tool_catalog.dart` | Every tool: title, summary, highlights, keywords, body copy, status |
| `legal.dart` | Privacy policy, terms of use, licences — the actual text |
| `third_party.dart` | Bundled components and their licences |
| `faq.dart` | Questions and answers, shared with the site's structured data |
| `paper_format.dart` | Built-in paper sizes, in millimetres |
| `photo_size.dart` | Built-in print size presets |
| `brand_mark.dart` | The hummingbird's geometry, as SVG path data |
| `svg_path.dart` | A tiny path-data parser so Flutter can draw that geometry |

## Why the mark is here

The app paints the hummingbird onto a Flutter `Path`; the site inlines it as
`<path d="…">`. Rather than keep two copies of the same curves in step by hand,
the numbers live here once and `writeSvgPath` replays them onto a `PathSink` —
five methods whose signatures match Flutter's `Path`, so the app's adapter is
five one-line forwards.

## Adding a tool

Add a `ToolInfo` to `ToolCatalog`. The landing site picks it up with no further
change: a card on the home page, a row in the tool index, its own page, and an
entry in the sitemap. The app needs one more line — an icon, and a builder once
the tool actually exists.

```bash
dart pub get
dart test
dart analyze
```
