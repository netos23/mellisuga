import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Renders a JSON-LD block as a `<script type="application/ld+json">` element.
///
/// Jaspr escapes every text node and attribute it renders, so nothing else on
/// the site has to think about escaping. Structured data is the exception: the
/// payload has to reach the browser as JSON rather than as escaped text, so it
/// is written raw and [encodeJsonLd] does the escaping instead.
Component jsonLdScript(Map<String, Object?> data) =>
    script(attributes: const {'type': 'application/ld+json'}, content: encodeJsonLd(data));

/// Encodes [data] as JSON that is safe to drop into a `<script>` element.
///
/// `<` is escaped as a unicode sequence so a stray closing script tag inside
/// a string can never end the element early — the one way structured data
/// turns into an injection.
String encodeJsonLd(Map<String, Object?> data) {
  // JSON has no `<`, `>` or `&` outside string literals, so escaping them
  // wholesale is safe — and inside a string a `<` escape is still JSON.
  return const JsonEncoder.withIndent(
    '  ',
  ).convert(data).replaceAll('<', r'\u003C').replaceAll('>', r'\u003E').replaceAll('&', r'\u0026');
}
