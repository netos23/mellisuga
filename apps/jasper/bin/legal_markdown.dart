import 'dart:io';

import 'package:jasper/jasper.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

/// Writes the repository's legal Markdown from the shared content package.
///
/// ```
/// dart run bin/legal_markdown.dart --out ../..          # regenerate
/// dart run bin/legal_markdown.dart --out ../.. --check  # fail if stale
/// ```
///
/// The privacy policy has three renderings — an app screen, a website page and
/// a Markdown file people read on GitHub. The first two share objects; this
/// keeps the third from drifting away from them.
Future<void> main(List<String> arguments) async {
  var output = '../..';
  var check = false;

  for (var index = 0; index < arguments.length; index++) {
    switch (arguments[index]) {
      case '--out':
        if (index + 1 >= arguments.length) {
          stderr.writeln('jasper: --out needs a directory');
          exitCode = 64;
          return;
        }
        output = arguments[index + 1];
        index++;
      case '--check':
        check = true;
      default:
        stderr.writeln('jasper: unknown option "${arguments[index]}"');
        exitCode = 64;
        return;
    }
  }

  // Only the documents that have a Markdown twin in the repository root. The
  // licence page lives on the website and alongside THIRD_PARTY_NOTICES.md,
  // which is prose rather than a rendering of this data.
  const files = <String, LegalDocument>{
    'PRIVACY.md': LegalContent.privacy,
    'TERMS.md': LegalContent.terms,
  };

  var stale = false;
  for (final entry in files.entries) {
    final file = File('$output/${entry.key}');
    final rendered = renderLegalMarkdown(entry.value);

    if (check) {
      final current = file.existsSync() ? file.readAsStringSync() : '';
      if (current != rendered) {
        stale = true;
        stderr.writeln('${entry.key} is out of date with mellisuga_content');
      }
      continue;
    }

    await file.writeAsString(rendered);
    stdout.writeln('Wrote ${file.path}');
  }

  if (stale) {
    stderr.writeln('Run: dart run bin/legal_markdown.dart --out $output');
    exitCode = 1;
  }
}
