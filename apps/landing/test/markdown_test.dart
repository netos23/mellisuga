import 'dart:io';

import 'package:landing/landing.dart';
import 'package:mellisuga_content/mellisuga_content.dart';
import 'package:test/test.dart';

/// The repository root, relative to this package. `dart test` runs with the
/// package directory as its working directory.
const String repositoryRoot = '../..';

void main() {
  group('renderLegalMarkdown', () {
    test('reproduces every heading and paragraph', () {
      for (final document in [LegalContent.privacy, LegalContent.terms]) {
        final markdown = renderLegalMarkdown(document);
        expect(markdown, startsWith('# ${document.title}'));
        expect(markdown, contains(document.summary));
        expect(markdown, contains(document.lastUpdated));

        for (final section in document.sections) {
          expect(markdown, contains('## ${section.heading}'), reason: document.id);
          for (final paragraph in section.paragraphs) {
            // The renderer rewraps, so compare on words rather than lines.
            expect(_words(markdown), containsAllInOrder(_words(paragraph)), reason: document.id);
          }
        }
      }
    });

    test('wraps at 80 columns', () {
      for (final document in [LegalContent.privacy, LegalContent.terms]) {
        for (final line in renderLegalMarkdown(document).split('\n')) {
          expect(line.length, lessThanOrEqualTo(80), reason: line);
        }
      }
    });

    test('marks bullets as a list', () {
      final markdown = renderLegalMarkdown(LegalContent.terms);
      final bullets = LegalContent.terms.sections.expand((section) => section.bullets);
      expect(bullets, isNotEmpty, reason: 'the fixture needs a document with bullets');
      for (final bullet in bullets) {
        expect(markdown, contains('- ${bullet.split(' ').first}'));
      }
    });

    test('ends with exactly one newline', () {
      final markdown = renderLegalMarkdown(LegalContent.privacy);
      expect(markdown, endsWith('\n'));
      expect(markdown, isNot(endsWith('\n\n')));
    });
  });

  group('the repository copies', () {
    test('are what the generator produces', () {
      const files = <String, LegalDocument>{
        'PRIVACY.md': LegalContent.privacy,
        'TERMS.md': LegalContent.terms,
      };

      for (final entry in files.entries) {
        final file = File('$repositoryRoot/${entry.key}');
        expect(file.existsSync(), isTrue, reason: '${entry.key} is missing');
        expect(
          file.readAsStringSync(),
          renderLegalMarkdown(entry.value),
          reason:
              '${entry.key} has drifted from mellisuga_content. '
              'Run: dart run bin/legal_markdown.dart --out $repositoryRoot',
        );
      }
    });
  });
}

List<String> _words(String value) =>
    value.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
