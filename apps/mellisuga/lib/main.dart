import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';

import 'app.dart';
import 'core/app_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicense();
  await _loadPackageInfo();
  runApp(const MellisugaApp());
}

/// Adds the bundled typeface's licence to the in-app licences page.
///
/// Flutter registers licences for packages automatically, but assets we ship
/// ourselves have to be declared here.
void _registerFontLicense() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/Roboto_LICENSE.txt');
    yield LicenseEntryWithLineBreaks(const ['Roboto'], license);
  });
}

/// Fills [AppInfo] with the real version so the about page and PDF metadata
/// report what is actually running.
Future<void> _loadPackageInfo() async {
  try {
    final info = await PackageInfo.fromPlatform();
    if (info.version.isNotEmpty) AppInfo.version = info.version;
    if (info.buildNumber.isNotEmpty) AppInfo.buildNumber = info.buildNumber;
  } catch (error) {
    // Not fatal — the compiled-in defaults are close enough to keep going.
    debugPrint('Could not read package info: $error');
  }
}
