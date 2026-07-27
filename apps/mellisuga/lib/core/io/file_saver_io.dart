import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'file_saver.dart';

/// Desktop and mobile implementation.
///
/// Desktop platforms get a real "Save as…" dialog. iOS and Android have no such
/// dialog, so the file is written into the app's documents directory and the
/// path is reported back to the caller through the returned outcome.
Future<SaveOutcome> saveBytes({
  required Uint8List bytes,
  required String suggestedName,
  required String mimeType,
}) async {
  if (Platform.isAndroid || Platform.isIOS) {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}${Platform.pathSeparator}$suggestedName');
    await file.writeAsBytes(bytes, flush: true);
    return SaveOutcome.saved;
  }

  final extension = suggestedName.contains('.')
      ? suggestedName.split('.').last.toLowerCase()
      : null;

  final location = await getSaveLocation(
    suggestedName: suggestedName,
    acceptedTypeGroups: <XTypeGroup>[
      if (extension != null)
        XTypeGroup(
          label: extension.toUpperCase(),
          extensions: <String>[extension],
          mimeTypes: <String>[mimeType],
        ),
    ],
  );
  if (location == null) return SaveOutcome.cancelled;

  try {
    await File(location.path).writeAsBytes(bytes, flush: true);
    return SaveOutcome.saved;
  } on FileSystemException catch (error) {
    debugPrint('Could not write ${location.path}: $error');
    rethrow;
  }
}
