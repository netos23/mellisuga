# Jasper

The static site generator behind Mellisuga's landing page.

Jasper is a plain Dart program with one dependency: `mellisuga_content`, the
package the Flutter app also compiles in. That is the whole point — the tool
descriptions, legal documents, print formats and brand geometry on the site are
the same objects the app renders, so the two cannot drift.

## Build

```bash
dart pub get

# Local preview at the root of localhost.
dart run bin/build.dart --out build/preview --base-href / --site-url http://localhost:8080/
dart run bin/serve.dart build/preview

# What CI publishes: a GitHub Pages project site.
dart run bin/build.dart \
  --out build/site \
  --base-href /mellisuga/ \
  --site-url https://netos23.github.io/mellisuga/
```

`--base-href` decides how internal links are written, `--site-url` decides what
goes in canonical tags, Open Graph and the sitemap. Nothing else in the program
knows where the site will live, which is what lets the same generator serve a
localhost preview and a project subpath.

## What it produces

```
index.html              Home: hero, why, how, tools, sizes, platforms, FAQ
tools/index.html        The tool index
tools/<id>/index.html   One page per tool, from the shared catalogue
privacy/  terms/  licences/   The app's own legal documents, as pages
404.html                Served by Pages for anything missing, app paths included
sitemap.xml  robots.txt icon.svg  styles.css  site.js  .nojekyll
```

## Rules the tests enforce

`dart test` is not a smoke test — it is the specification:

- one `h1` per page, a title and meta description of a usable length, and a
  canonical URL that matches where the file was written;
- every page in the sitemap exists, and every generated page is in the sitemap;
- **no resource is loaded from another origin** — no font CDN, no analytics, no
  remote image. The privacy policy published on this site promises that, so the
  build fails rather than break it;
- external links are anchors only, and carry `rel="noopener"`;
- every tool, every legal section and every print format in the shared package
  actually appears on the site;
- structured data parses as JSON and cannot be escaped from;
- a subpath build never emits a link that escapes the subpath.

## Design notes

**No framework, no dependencies.** The stylesheet and the one script are
strings in `lib/src/assets.dart`, so the generator is a single self-contained
program and the tests can assert on exactly what ships.

**Illustrations are inline SVG**, drawn from the same `BrandMark` geometry the
Flutter app paints with. Motion lives entirely in the stylesheet, so
`prefers-reduced-motion` switches all of it off in one place.

**JavaScript is enhancement only.** Every link works, every FAQ answer is in the
HTML and every page reads correctly with `site.js` blocked; the script adds the
theme toggle, the mobile menu and the scroll reveals.

**The app is linked, never embedded.** The Flutter build is a separate artifact
published under `/app/`; Jasper only ever writes an anchor to it.
