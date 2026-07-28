import 'package:meta/meta.dart';

import 'brand.dart';

/// A heading plus its paragraphs, used to render the legal pages.
@immutable
class LegalSection {
  const LegalSection({required this.heading, required this.paragraphs, this.bullets = const []});

  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;

  /// URL fragment for deep-linking a section on the site.
  String get anchor => _slugify(heading);
}

/// A legal document: title, effective date and body.
@immutable
class LegalDocument {
  const LegalDocument({
    required this.id,
    required this.title,
    required this.summary,
    required this.lastUpdated,
    required this.sections,
  });

  /// Stable identifier, also the site's directory name (`/privacy/`).
  final String id;

  final String title;
  final String summary;
  final String lastUpdated;
  final List<LegalSection> sections;

  /// Path of this document on the landing site, relative to the site root.
  String get path => '$id/';
}

/// The text of the project's legal documents.
///
/// These describe how Mellisuga actually behaves: both the landing site and the
/// app are static files with no backend, so there is no server-side processing
/// to disclose. The wording is deliberately plain rather than boilerplate, and
/// it is not legal advice — a deployment with different hosting or analytics
/// must update it to match.
///
/// The app renders these documents as screens and the landing site renders them
/// as pages, so the two can never say different things.
abstract final class LegalContent {
  static const String lastUpdated = '27 July 2026';

  static const LegalDocument privacy = LegalDocument(
    id: 'privacy',
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
          'By default, nothing. Mellisuga has no user accounts, no telemetry, no '
              'advertising and no cookies set by the application itself. The people '
              'who publish a build of this project — including the official one — '
              'may switch on the optional, anonymous analytics described below; it '
              'stays off until you say yes, and you can change your mind at any '
              'time.',
        ],
      ),
      LegalSection(
        heading: 'Optional analytics',
        paragraphs: [
          'A build of Mellisuga may report anonymous usage analytics, but only if '
              'the people who published it have switched it on, and only after you '
              'have agreed to a consent prompt — continuing to use the app or '
              'visiting the site is never treated as agreement.',
          'When analytics is on and you have agreed, a short, fixed list of events '
              'may be sent — things like a screen being opened, a tool being used, '
              'an export finishing, or your chosen language and theme. Every event '
              'this project can send, and exactly what each one contains, is listed '
              'in ${Brand.name}\'s ANALYTICS.md file in the source repository. None '
              'of them ever include the contents, names or metadata of the photos '
              'or documents you work with — the analytics code has no access to '
              'that data in the first place.',
          'The providers a build may report to are Firebase Analytics (Google), '
              'and Yandex\'s AppMetrica and Yandex Metrica. Each runs its own '
              'infrastructure outside this project\'s control and processes what it '
              'receives under its own privacy terms.',
          'You can withdraw consent at any time: in the app, under About → '
              'Privacy & analytics; on the website, from the "Manage analytics" '
              'link next to this notice. Withdrawing stops any further reporting '
              'immediately.',
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
        heading: 'This website',
        paragraphs: [
          'The pages describing Mellisuga are plain static HTML. They set no '
              'cookies, embed no advertising or social widgets, and load every '
              'stylesheet, script, font and illustration from the same origin as '
              'the page itself — with the one exception of the optional analytics '
              'above, which only ever loads after this site\'s own consent banner '
              'has been accepted. The only preference the site remembers on its '
              'own is whether you chose the light or dark theme, kept in your '
              'browser\'s local storage.',
        ],
      ),
      LegalSection(
        heading: 'Hosting',
        paragraphs: [
          'The website and the web version of the app are served as static files '
              'from GitHub Pages. As with any web request, GitHub receives your IP '
              'address and standard HTTP request metadata in order to deliver the '
              'page. That processing is governed by GitHub\'s own privacy statement '
              'and is outside this project\'s control. No request your device makes '
              'carries the contents of your files.',
        ],
      ),
      LegalSection(
        heading: 'Third-party services',
        paragraphs: [
          'Neither the app nor the website loads a third-party script, font or '
              'tracking pixel by default. The one exception is the optional '
              'analytics described above: once you have agreed to it, the relevant '
              'provider\'s script is loaded and the events listed in ANALYTICS.md '
              'are sent to it. With analytics off — the default, and the whole '
              'story for most builds — this section is exactly as absolute as it '
              'sounds: no third party ever hears from either surface.',
        ],
      ),
      LegalSection(
        heading: 'Children',
        paragraphs: [
          'The optional analytics above, when a build has it switched on and you '
              'have agreed to it, collects nothing that identifies who is using '
              'the app — no name, no account, no birth date — so it collects '
              'nothing that identifies a child either. With analytics off, which '
              'is the default, nothing at all is collected from anyone.',
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
    id: 'terms',
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
              '${Brand.licenseName}. You may use, copy, modify and redistribute '
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

  /// The licence page.
  ///
  /// Inside the app this sits alongside Flutter's generated licence list, which
  /// is built from the real dependency set; on the site it is followed by the
  /// table in [ThirdPartyNotices].
  static const LegalDocument licences = LegalDocument(
    id: 'licences',
    title: 'Open source licences',
    summary: 'Mellisuga is MIT licensed, and so is every line of it you can read.',
    lastUpdated: lastUpdated,
    sections: [
      LegalSection(
        heading: 'The project',
        paragraphs: [
          'Mellisuga — the app, the landing site and everything shared between '
              'them — is released under the ${Brand.licenseName}. You may use, '
              'copy, modify and redistribute it, including commercially, provided '
              'the copyright notice and the licence text travel with it.',
          '${Brand.copyright}.',
        ],
      ),
      LegalSection(
        heading: 'Bundled components',
        paragraphs: [
          'The app ships the frameworks, packages and fonts listed below. Their '
              'licences are reproduced in full inside the app under '
              'About → Open source licences, generated from the dependency set '
              'that was actually compiled in.',
        ],
      ),
      LegalSection(
        heading: 'Artwork',
        paragraphs: [
          'The hummingbird mark, the icon set and the illustrations on this site '
              'are original to the project and are covered by the same licence as '
              'the code.',
        ],
      ),
    ],
  );

  /// Every document, in the order the app and the site list them.
  static const List<LegalDocument> documents = <LegalDocument>[privacy, terms, licences];
}

String _slugify(String value) {
  final buffer = StringBuffer();
  var pendingDash = false;
  for (final rune in value.toLowerCase().runes) {
    final isDigit = rune >= 0x30 && rune <= 0x39;
    final isLetter = rune >= 0x61 && rune <= 0x7A;
    if (isDigit || isLetter) {
      if (pendingDash && buffer.isNotEmpty) buffer.write('-');
      pendingDash = false;
      buffer.writeCharCode(rune);
    } else {
      pendingDash = true;
    }
  }
  return buffer.toString();
}
