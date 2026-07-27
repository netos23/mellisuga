import 'package:flutter/foundation.dart';

/// Raster image formats the composer can write.
enum RasterFormat {
  png('PNG', 'png', 'image/png'),
  jpeg('JPEG', 'jpg', 'image/jpeg');

  const RasterFormat(this.label, this.extension, this.mimeType);

  final String label;
  final String extension;
  final String mimeType;
}

/// Progress callback signature shared by both exporters.
typedef ExportProgress = void Function(double fraction, String message);

/// Knobs the export dialog exposes.
@immutable
class ExportOptions {
  const ExportOptions({
    this.dpi = 300,
    this.jpegQuality = 92,
    this.format = RasterFormat.png,
    this.fileNameStem = 'mellisuga-sheet',
    this.embedMetadata = true,
  });

  /// Output resolution in dots per inch.
  final int dpi;

  /// Quality for JPEG output and for photos embedded in a PDF, `1..100`.
  final int jpegQuality;

  final RasterFormat format;

  /// File name without extension or page suffix.
  final String fileNameStem;

  /// Whether to write the app name into the PDF's document properties.
  final bool embedMetadata;

  /// DPI values offered in the UI, with a short explanation each.
  static const Map<int, String> dpiChoices = {
    150: 'Draft — smallest files',
    200: 'Good for text and line art',
    300: 'Standard photo quality',
    400: 'High quality',
    600: 'Maximum — very large files',
  };

  ExportOptions copyWith({
    int? dpi,
    int? jpegQuality,
    RasterFormat? format,
    String? fileNameStem,
    bool? embedMetadata,
  }) {
    return ExportOptions(
      dpi: dpi ?? this.dpi,
      jpegQuality: jpegQuality ?? this.jpegQuality,
      format: format ?? this.format,
      fileNameStem: fileNameStem ?? this.fileNameStem,
      embedMetadata: embedMetadata ?? this.embedMetadata,
    );
  }
}

/// One finished output file held in memory, ready to save or share.
@immutable
class ExportedFile {
  const ExportedFile({required this.fileName, required this.bytes, required this.mimeType});

  final String fileName;
  final Uint8List bytes;
  final String mimeType;

  /// Human-readable size, e.g. `2.4 MB`.
  String get readableSize {
    final bytesCount = bytes.length;
    if (bytesCount < 1024) return '$bytesCount B';
    if (bytesCount < 1024 * 1024) {
      return '${(bytesCount / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytesCount / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
