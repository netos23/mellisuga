import 'package:mellisuga_content/mellisuga_content.dart';

/// Renders a legal document as the Markdown file kept in the repository root.
///
/// The app shows these documents as screens, the site as pages and GitHub as
/// Markdown. Three renderings, one text — the Markdown is generated rather than
/// mirrored by hand, because a mirror kept by hand is a mirror that eventually
/// lies.
String renderLegalMarkdown(LegalDocument document) {
  final blocks = <String>[
    '# ${document.title}',
    '**Last updated: ${document.lastUpdated}**',
    '> ${document.summary}',
    '<!--\n'
        '  Generated from packages/mellisuga_content by\n'
        '  apps/jasper/bin/legal_markdown.dart. Edit the Dart source, not this file.\n'
        '-->',
    _wrap(
      'This is the same text the application shows under '
      '**About → ${document.title}**, and the website shows on its '
      '${document.title.toLowerCase()} page.',
    ),
    for (final section in document.sections) ...[
      '## ${section.heading}',
      for (final paragraph in section.paragraphs) _wrap(paragraph),
      if (section.bullets.isNotEmpty)
        section.bullets.map((bullet) => _wrap(bullet, bullet: true)).join('\n'),
    ],
  ];

  return '${blocks.join('\n\n')}\n';
}

/// Wraps [text] at 80 columns, the width the rest of the repository's Markdown
/// is written to.
String _wrap(String text, {bool bullet = false, int width = 80}) {
  final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  final lines = <String>[];
  var line = StringBuffer();

  for (final word in words) {
    if (line.isEmpty) {
      line.write('${bullet ? '- ' : ''}$word');
    } else if (line.length + 1 + word.length > width) {
      lines.add(line.toString());
      line = StringBuffer('${bullet ? '  ' : ''}$word');
    } else {
      line.write(' $word');
    }
  }

  if (line.isNotEmpty) lines.add(line.toString());
  return lines.join('\n');
}
