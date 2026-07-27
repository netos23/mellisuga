import 'package:meta/meta.dart';

/// A question somebody actually asks, and its answer.
///
/// The landing site renders these as an accordion and mirrors them into
/// `FAQPage` structured data, which is why answers are plain prose with no
/// markup in them.
@immutable
class FaqEntry {
  const FaqEntry({required this.question, required this.answer});

  final String question;

  /// One or two sentences. Kept free of markup so it can be dropped into
  /// JSON-LD unchanged.
  final String answer;
}

/// Questions about the project rather than about one tool.
abstract final class Faqs {
  static const List<FaqEntry> general = <FaqEntry>[
    FaqEntry(
      question: 'Are my photos uploaded anywhere?',
      answer:
          'No. Mellisuga is a static site with no backend, so there is no server '
          'that could receive a file. Photos you open are decoded in the page, '
          'held in memory, and gone the moment you close the tab.',
    ),
    FaqEntry(
      question: 'Does it cost anything, and do I need an account?',
      answer:
          'It is free, open source under the MIT licence, and has no accounts, no '
          'sign-in, no watermarks, no page limits and no advertising.',
    ),
    FaqEntry(
      question: 'Does it work offline?',
      answer:
          'Once the page has loaded it makes no further network requests, so an '
          'open tab keeps working with the connection off. There are also native '
          'builds for Android, Windows, macOS and Linux if you would rather not '
          'rely on a browser at all.',
    ),
    FaqEntry(
      question: 'Which browsers are supported?',
      answer:
          'Any current version of Chrome, Edge, Firefox or Safari, on desktop or '
          'mobile. The app renders with CanvasKit, which is bundled with the page '
          'rather than fetched from a CDN.',
    ),
    FaqEntry(
      question: 'Can I use the exported files commercially?',
      answer:
          'Yes. Mellisuga claims nothing over what you make with it, adds no '
          'watermark and embeds no tracking in exported PDFs or images.',
    ),
    FaqEntry(
      question: 'What is a "bee hummingbird" doing on a printing app?',
      answer:
          'Mellisuga helenae is the smallest bird there is. The tools aim for the '
          'same trick: fitting a great deal into very little space — on a sheet of '
          'paper, and in a download.',
    ),
  ];
}
