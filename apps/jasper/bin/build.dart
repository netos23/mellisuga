import 'dart:io';

import 'package:mellisuga_content/mellisuga_content.dart';
// The site's own `Platform` (a row in the "where it runs" table, from
// `copy.dart`) would otherwise shadow `dart:io`'s.
import 'package:jasper/jasper.dart' hide Platform;

/// Builds the landing site, in every supported language.
///
/// ```
/// dart run bin/build.dart --out build/site \
///   --base-href /mellisuga/ --site-url https://netos23.github.io/mellisuga/
/// ```
///
/// The two URL arguments are what make one generator serve both a local preview
/// at `/` and a GitHub Pages project site at `/<repo>/`. Nothing else in the
/// program knows where the site will live.
Future<int> run(List<String> arguments) async {
  final options = _Options.parse(arguments);
  if (options.help) {
    stdout.writeln(_usage);
    return 0;
  }

  final config = SiteConfig(
    baseHref: options.baseHref,
    siteUrl: options.siteUrl,
    buildDate: options.buildDate,
  );

  final site = buildAllLocales(config);
  final directory = Directory(options.output);
  await writeSite(site, directory);

  stdout
    ..writeln('Built ${site.files.length} files into ${directory.path}')
    ..writeln('  base href  ${config.baseHref}')
    ..writeln('  site URL   ${config.siteUrl}')
    ..writeln('  app URL    ${config.appUrl}')
    ..writeln('  languages  ${AppLocale.values.map((locale) => locale.code).join(', ')}')
    ..writeln('  pages      ${site.pages.length}')
    ..writeln('  size       ${(site.byteCount / 1024).toStringAsFixed(1)} KiB');

  return 0;
}

Future<void> main(List<String> arguments) async {
  try {
    exitCode = await run(arguments);
  } on ArgumentError catch (error) {
    stderr
      ..writeln('jasper: ${error.message}')
      ..writeln()
      ..writeln(_usage);
    exitCode = 64; // EX_USAGE
  }
}

const String _usage = '''
Usage: dart run bin/build.dart [options]

  --out <dir>          Where to write the site (default: build/site)
  --base-href <path>   Path the site is served from (default: /)
  --site-url <url>     Absolute URL of that path, used for canonical links,
                       Open Graph and the sitemap
  --build-date <date>  ISO date stamped into the sitemap (default: today)
  -h, --help           Show this message
''';

/// A hand-rolled argument parser, so the generator has no dependencies beyond
/// the content package it exists to render.
class _Options {
  const _Options({
    required this.output,
    required this.baseHref,
    required this.siteUrl,
    required this.buildDate,
    required this.help,
  });

  factory _Options.parse(List<String> arguments) {
    var output = 'build/site';
    var baseHref = '/';
    String? siteUrl;
    DateTime? buildDate;
    var help = false;

    String valueFor(String flag, int index) {
      if (index + 1 >= arguments.length) {
        throw ArgumentError('$flag needs a value');
      }
      return arguments[index + 1];
    }

    for (var index = 0; index < arguments.length; index++) {
      final argument = arguments[index];
      switch (argument) {
        case '--out':
          output = valueFor(argument, index);
          index++;
        case '--base-href':
          baseHref = valueFor(argument, index);
          index++;
        case '--site-url':
          siteUrl = valueFor(argument, index);
          index++;
        case '--build-date':
          final raw = valueFor(argument, index);
          buildDate = DateTime.tryParse(raw);
          if (buildDate == null) {
            throw ArgumentError('--build-date must be an ISO date, got "$raw"');
          }
          index++;
        case '-h' || '--help':
          help = true;
        default:
          throw ArgumentError('unknown option "$argument"');
      }
    }

    return _Options(
      output: output,
      baseHref: baseHref,
      // Falling back to the base href keeps a local build's canonical links
      // pointing at the local build rather than at production.
      siteUrl: siteUrl ?? baseHref,
      buildDate: buildDate,
      help: help,
    );
  }

  final String output;
  final String baseHref;
  final String siteUrl;
  final DateTime? buildDate;
  final bool help;
}
