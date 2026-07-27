import 'dart:typed_data';

import 'file_saver_stub.dart'
    if (dart.library.js_interop) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart'
    as impl;

/// Outcome of a save request.
enum SaveOutcome {
  /// The file was written, or the browser download was started.
  saved,

  /// The user dismissed the save dialog.
  cancelled,

  /// Saving is not supported on this platform.
  unsupported,
}

/// Writes generated files out to wherever the current platform puts them.
///
/// On the web this triggers a browser download; on desktop and mobile it opens
/// the system save dialog. Nothing ever leaves the device either way.
abstract final class FileSaver {
  /// Saves a single file.
  ///
  /// [suggestedName] should include the extension. [mimeType] is used by the
  /// browser and by the desktop save dialog's type filter.
  static Future<SaveOutcome> save({
    required Uint8List bytes,
    required String suggestedName,
    required String mimeType,
  }) {
    return impl.saveBytes(bytes: bytes, suggestedName: suggestedName, mimeType: mimeType);
  }

  /// Saves several files in sequence.
  ///
  /// Stops early if the user cancels. Returns the number of files written.
  static Future<int> saveAll(
    List<({Uint8List bytes, String suggestedName, String mimeType})> files,
  ) async {
    var written = 0;
    for (final file in files) {
      final outcome = await save(
        bytes: file.bytes,
        suggestedName: file.suggestedName,
        mimeType: file.mimeType,
      );
      if (outcome == SaveOutcome.cancelled) break;
      if (outcome == SaveOutcome.saved) written++;
    }
    return written;
  }
}
