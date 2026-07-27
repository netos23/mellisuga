import 'dart:convert';

/// Escapes [value] for use in HTML text or in a double-quoted attribute.
///
/// Every string that reaches a template goes through here. The content package
/// is written by hand rather than fetched from anywhere, but "the input is
/// trusted" is exactly the assumption that ages badly, and an unescaped `&` in
/// a summary would produce invalid HTML either way.
String escapeHtml(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    switch (rune) {
      case 0x26:
        buffer.write('&amp;');
      case 0x3C:
        buffer.write('&lt;');
      case 0x3E:
        buffer.write('&gt;');
      case 0x22:
        buffer.write('&quot;');
      case 0x27:
        buffer.write('&#39;');
      default:
        buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// Renders a JSON-LD block.
///
/// `<` is escaped as a unicode sequence so a stray closing script tag inside
/// a string can never end the element early — the one way structured data
/// turns into an injection.
String jsonLdScript(Map<String, Object?> data) {
  // JSON has no `<`, `>` or `&` outside string literals, so escaping them
  // wholesale is safe — and inside a string a `<` escape is still JSON.
  final json = const JsonEncoder.withIndent(
    '  ',
  ).convert(data).replaceAll('<', r'\u003C').replaceAll('>', r'\u003E').replaceAll('&', r'\u0026');
  return '<script type="application/ld+json">\n$json\n</script>';
}

/// Joins non-empty lines with a newline, so page builders can drop optional
/// sections in with a conditional and not think about blank lines.
String lines(Iterable<String?> parts) =>
    parts.whereType<String>().where((part) => part.isNotEmpty).join('\n');

/// Indents every line of [value] by [depth] levels of two spaces.
///
/// Only cosmetic: generated HTML that a human can read is generated HTML a
/// human can review.
String indent(String value, [int depth = 1]) {
  final prefix = '  ' * depth;
  return value.split('\n').map((line) => line.isEmpty ? line : '$prefix$line').join('\n');
}
