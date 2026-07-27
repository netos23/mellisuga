import 'dart:typed_data';

import 'file_saver.dart';

/// Fallback used on platforms that expose neither `dart:io` nor `dart:js_interop`.
Future<SaveOutcome> saveBytes({
  required Uint8List bytes,
  required String suggestedName,
  required String mimeType,
}) async => SaveOutcome.unsupported;
