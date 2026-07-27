import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'file_saver.dart';

/// Browser implementation: wraps the bytes in a `Blob`, points an anchor at an
/// object URL and clicks it. This is the same path a normal download link
/// takes, so it works in every browser without extra permissions — and the
/// bytes never leave the tab.
Future<SaveOutcome> saveBytes({
  required Uint8List bytes,
  required String suggestedName,
  required String mimeType,
}) async {
  final blob = web.Blob(<JSUint8Array>[bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = suggestedName
    ..style.display = 'none';

  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();

  // Give the browser a moment to start the download before the URL — and with
  // it the underlying blob — is revoked.
  await Future<void>.delayed(const Duration(seconds: 1));
  web.URL.revokeObjectURL(url);

  return SaveOutcome.saved;
}
