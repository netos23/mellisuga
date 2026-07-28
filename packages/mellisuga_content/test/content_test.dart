import 'package:mellisuga_content/mellisuga_content.dart';
import 'package:test/test.dart';

void main() {
  group('ToolCatalog', () {
    test('every tool has a unique id', () {
      final ids = ToolCatalog.tools.map((tool) => tool.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('ids are URL-safe, because they are directory names on the site', () {
      for (final tool in ToolCatalog.tools) {
        expect(tool.id, matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')), reason: tool.id);
      }
    });

    test('meta descriptions stay within what search results show', () {
      for (final tool in ToolCatalog.tools) {
        expect(tool.metaDescription.length, lessThanOrEqualTo(165), reason: tool.id);
        expect(tool.metaDescription.length, greaterThanOrEqualTo(50), reason: tool.id);
      }
    });

    test('every tool says something beyond its title', () {
      for (final tool in ToolCatalog.tools) {
        expect(tool.summary, isNotEmpty, reason: tool.id);
        expect(tool.highlights, isNotEmpty, reason: tool.id);
        expect(tool.overview, isNotEmpty, reason: tool.id);
      }
    });

    test('the flagship tool is the available one', () {
      expect(ToolCatalog.flagship.status.isAvailable, isTrue);
      expect(ToolCatalog.available, contains(ToolCatalog.flagship));
    });

    test('available and roadmap partition the catalogue', () {
      expect(ToolCatalog.available.length + ToolCatalog.roadmap.length, ToolCatalog.tools.length);
    });

    test('categories partition the catalogue', () {
      final counted = <String>{};
      for (final category in ToolCategory.values) {
        for (final tool in ToolCatalog.inCategory(category)) {
          counted.add(tool.id);
        }
      }
      expect(counted.length, ToolCatalog.tools.length);
    });

    test('search matches titles, summaries and keywords', () {
      expect(ToolCatalog.search('compose'), isNotEmpty);
      expect(ToolCatalog.search('passport').map((tool) => tool.id), contains('photo-compose'));
      expect(ToolCatalog.search('combine').map((tool) => tool.id), contains('pdf-merge'));
      expect(ToolCatalog.search('zzzzz'), isEmpty);
    });

    test('an empty query matches everything', () {
      expect(ToolCatalog.search('  ').length, ToolCatalog.tools.length);
    });

    test('paths are distinct and end in a slash', () {
      final paths = ToolCatalog.tools.map((tool) => tool.path).toList();
      expect(paths.toSet().length, paths.length);
      for (final path in paths) {
        expect(path, endsWith('/'));
      }
    });
  });

  group('LegalContent', () {
    test('every document has an id, a summary and sections', () {
      for (final document in LegalContent.documents) {
        expect(document.id, matches(RegExp(r'^[a-z]+$')), reason: document.title);
        expect(document.summary, isNotEmpty, reason: document.title);
        expect(document.sections, isNotEmpty, reason: document.title);
      }
    });

    test('ids are unique', () {
      final ids = LegalContent.documents.map((document) => document.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every section has a heading and a body', () {
      for (final document in LegalContent.documents) {
        for (final section in document.sections) {
          expect(section.heading, isNotEmpty, reason: document.id);
          expect(
            section.paragraphs.isNotEmpty || section.bullets.isNotEmpty,
            isTrue,
            reason: '${document.id} › ${section.heading}',
          );
        }
      }
    });

    test('section anchors are unique within a document and URL-safe', () {
      for (final document in LegalContent.documents) {
        final anchors = document.sections.map((section) => section.anchor).toList();
        expect(anchors.toSet().length, anchors.length, reason: document.id);
        for (final anchor in anchors) {
          expect(anchor, matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')), reason: anchor);
        }
      }
    });

    test('the privacy policy still says the thing that matters', () {
      final text = LegalContent.privacy.sections
          .expand((section) => [...section.paragraphs, ...section.bullets])
          .join(' ')
          .toLowerCase();
      expect(text, contains('never uploaded'));
      // Analytics is opt-in and off by default, rather than categorically
      // absent — the policy has to say so honestly, not claim "no analytics".
      expect(text, contains('optional'));
      expect(text, contains('consent'));
      expect(text, contains('analytics.md'));
    });
  });

  group('Brand', () {
    test('the app URL sits under the website URL', () {
      expect(Brand.appUrl, startsWith(Brand.websiteUrl));
      expect(Brand.websiteUrl, endsWith('/'));
      expect(Brand.appUrl, endsWith('/'));
    });

    test('every public URL is absolute and https', () {
      for (final url in [
        Brand.repositoryUrl,
        Brand.issuesUrl,
        Brand.licenseUrl,
        Brand.authorUrl,
        Brand.websiteUrl,
        Brand.appUrl,
      ]) {
        expect(Uri.parse(url).scheme, 'https', reason: url);
      }
    });

    test('the short description fits a search result', () {
      expect(Brand.shortDescription.length, lessThanOrEqualTo(165));
    });

    test('hex colours and ARGB values describe the same colour', () {
      expect(BrandColors.seedHex.toUpperCase(), '#0E9F8E');
      expect(BrandColors.seedValue & 0xFFFFFF, 0x0E9F8E);
      expect(BrandColors.accentValue & 0xFFFFFF, 0xE0457B);
      expect(BrandColors.surfaceLightValue & 0xFFFFFF, 0xFAFDFC);
      expect(BrandColors.surfaceDarkValue & 0xFFFFFF, 0x101413);
    });
  });

  group('Formats', () {
    test('paper formats are portrait-nominal and uniquely identified', () {
      final ids = PaperFormats.all.map((format) => format.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final format in PaperFormats.all) {
        expect(format.heightMm, greaterThanOrEqualTo(format.widthMm), reason: format.id);
      }
    });

    test('print size presets are uniquely identified and sane', () {
      final ids = PhotoSizePresets.all.map((preset) => preset.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final preset in PhotoSizePresets.all) {
        expect(preset.widthMm, greaterThan(0), reason: preset.id);
        expect(preset.heightMm, greaterThan(0), reason: preset.id);
      }
    });

    test('the passport preset is exactly 35 × 45 mm', () {
      final passport = PhotoSizePresets.byId('id_35x45');
      expect(passport, isNotNull);
      expect(passport!.widthMm, 35);
      expect(passport.heightMm, 45);
    });
  });

  group('ThirdPartyNotices', () {
    test('every component names a licence and a purpose', () {
      for (final component in ThirdPartyNotices.components) {
        expect(component.licence, isNotEmpty, reason: component.name);
        expect(component.purpose, isNotEmpty, reason: component.name);
      }
    });

    test('every group is represented', () {
      for (final group in ComponentGroup.values) {
        expect(ThirdPartyNotices.inGroup(group), isNotEmpty, reason: group.label);
      }
    });
  });

  group('Faqs', () {
    test('questions are questions and answers are prose', () {
      final entries = [...Faqs.general, ...ToolCatalog.tools.expand((tool) => tool.faqs)];
      expect(entries, isNotEmpty);
      for (final entry in entries) {
        expect(entry.question, endsWith('?'));
        expect(entry.answer.length, greaterThan(40));
        expect(entry.answer, isNot(contains('<')));
      }
    });

    test('questions are unique', () {
      final questions = Faqs.general.map((entry) => entry.question).toList();
      expect(questions.toSet().length, questions.length);
    });
  });
}
