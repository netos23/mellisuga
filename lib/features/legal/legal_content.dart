import 'package:flutter/foundation.dart';

import '../../core/app_info.dart';

/// A heading plus its paragraphs, used to render the legal pages.
@immutable
class LegalSection {
  const LegalSection({required this.heading, required this.paragraphs, this.bullets = const []});

  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;
}

/// A legal document: title, effective date and body.
@immutable
class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.summary,
    required this.lastUpdated,
    required this.sections,
  });

  final String title;
  final String summary;
  final String lastUpdated;
  final List<LegalSection> sections;
}

/// The text of the app's legal documents.
///
/// These describe how Mellisuga actually behaves: it is a static site with no
/// backend, so there is no server-side processing to disclose. The wording is
/// deliberately plain rather than boilerplate, and it is not legal advice — a
/// deployment with different hosting or analytics must update it to match.
abstract final class LegalContent {
  static const String lastUpdated = '27 July 2026';

  static const LegalDocument privacy = LegalDocument(
    title: 'Privacy Policy',
    summary: 'Your files never leave your device. There is no server to send them to.',
    lastUpdated: lastUpdated,
    sections: [
      LegalSection(
        heading: 'The short version',
        paragraphs: [
          'Mellisuga runs entirely inside your browser or on your device. Photos '
              'and documents you open are read into local memory, processed there, '
              'and written back out to a file you choose. They are never uploaded, '
              'transmitted or stored anywhere else.',
        ],
      ),
      LegalSection(
        heading: 'What we collect',
        paragraphs: [
          'Nothing. Mellisuga has no user accounts, no analytics, no telemetry, no '
              'advertising and no cookies set by the application itself.',
        ],
      ),
      LegalSection(
        heading: 'Files you open',
        paragraphs: [
          'When you add a photo, its bytes are held in memory for as long as the '
              'page or app is open. Closing the tab or quitting the app discards '
              'them. Nothing is written to disk unless you explicitly save or '
              'export a file.',
        ],
      ),
      LegalSection(
        heading: 'Local storage',
        paragraphs: [
          'The app may store your interface preferences — such as the unit of '
              'measurement or last used paper size — in your browser\'s local '
              'storage or the equivalent on your device. This data stays on your '
              'device, contains no personal information, and is cleared when you '
              'clear your browser data.',
        ],
      ),
      LegalSection(
        heading: 'Hosting',
        paragraphs: [
          'The web version is served as static files from GitHub Pages. As with '
              'any web request, GitHub receives your IP address and standard HTTP '
              'request metadata in order to deliver the page. That processing is '
              'governed by GitHub\'s own privacy statement and is outside this '
              'application\'s control. No request your device makes carries the '
              'contents of your files.',
        ],
      ),
      LegalSection(
        heading: 'Third-party services',
        paragraphs: [
          'The application makes no network requests of its own after it loads. It '
              'embeds no third-party scripts, fonts loaded from remote servers, or '
              'tracking pixels.',
        ],
      ),
      LegalSection(
        heading: 'Children',
        paragraphs: [
          'Because the application collects no data at all, it collects no data '
              'from children.',
        ],
      ),
      LegalSection(
        heading: 'Changes',
        paragraphs: [
          'If this policy changes, the updated version will be published with the '
              'application and the date above will change. Past versions remain '
              'visible in the project\'s public source history.',
        ],
      ),
      LegalSection(
        heading: 'Contact',
        paragraphs: [
          'Questions about this policy can be raised on the project\'s issue '
              'tracker, linked from the About page.',
        ],
      ),
    ],
  );

  static const LegalDocument terms = LegalDocument(
    title: 'Terms of Use',
    summary: 'Free and open source software, provided as-is, with no warranty.',
    lastUpdated: lastUpdated,
    sections: [
      LegalSection(
        heading: 'Acceptance',
        paragraphs: [
          'By using Mellisuga you agree to these terms. If you do not agree, do '
              'not use the application.',
        ],
      ),
      LegalSection(
        heading: 'Licence',
        paragraphs: [
          'Mellisuga is free and open source software released under the '
              '${AppInfo.licenseName}. You may use, copy, modify and redistribute '
              'it under the terms of that licence, a full copy of which is '
              'included in the application and in the source repository.',
        ],
      ),
      LegalSection(
        heading: 'No warranty',
        paragraphs: [
          'The software is provided "as is", without warranty of any kind, express '
              'or implied, including but not limited to the warranties of '
              'merchantability, fitness for a particular purpose and '
              'non-infringement. You use it at your own risk.',
        ],
      ),
      LegalSection(
        heading: 'Limitation of liability',
        paragraphs: [
          'To the fullest extent permitted by law, the authors and copyright '
              'holders are not liable for any claim, damages or other liability '
              'arising from the use of the software — including lost work, wasted '
              'paper or ink, or incorrect output.',
        ],
      ),
      LegalSection(
        heading: 'Your responsibilities',
        paragraphs: [
          'You are responsible for the content you process and for holding the '
              'rights to it.',
        ],
        bullets: [
          'Keep your own backups. The application holds files only in memory and '
              'does not recover work after a crash or a closed tab.',
          'Check a proof print before running a large job. Printer drivers, paper '
              'handling and page-scaling settings can all change the final size.',
          'Do not use the application to infringe copyright or to process material '
              'you are not permitted to handle.',
        ],
      ),
      LegalSection(
        heading: 'Print accuracy',
        paragraphs: [
          'Layouts are calculated at exact physical dimensions. Actual printed '
              'size also depends on your printer and its driver settings — in '
              'particular any "fit to page", "scale to fit" or borderless option, '
              'which must be turned off for sizes to come out exactly as designed.',
        ],
      ),
      LegalSection(
        heading: 'Changes to the service',
        paragraphs: [
          'The application may change or stop being hosted at any time. Because it '
              'is open source, you can always run your own copy.',
        ],
      ),
    ],
  );
}
