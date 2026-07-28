import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/io/file_saver.dart';
import '../../export/export_options.dart';
import '../../export/pdf_exporter.dart';
import '../../export/raster_exporter.dart';
import '../../state/compose_controller.dart';

/// Export and print panel.
///
/// Presented as a bottom sheet on narrow screens and as a dialog on wide ones,
/// but the contents — and the code path that produces the files — are the same
/// either way.
class ExportSheet extends StatefulWidget {
  const ExportSheet({super.key, required this.controller});

  final ComposeController controller;

  static Future<void> show(BuildContext context, ComposeController controller) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    if (isWide) {
      return showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ExportSheet(controller: controller),
          ),
        ),
      );
    }
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ExportSheet(controller: controller),
    );
  }

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  late ExportOptions _options = widget.controller.exportOptions;
  late final TextEditingController _nameController = TextEditingController(
    text: _options.fileNameStem,
  );

  bool _asPdf = true;
  bool _running = false;
  double _progress = 0;
  String _statusMessage = '';
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  ExportOptions get _currentOptions => _options.copyWith(fileNameStem: _sanitisedName);

  /// Keeps generated names usable on every filesystem.
  String get _sanitisedName {
    final raw = _nameController.text.trim();
    final cleaned = raw.replaceAll(RegExp(r'[\\/:*?"<>|]'), '-');
    return cleaned.isEmpty ? 'mellisuga-sheet' : cleaned;
  }

  void _report(double fraction, String message) {
    if (!mounted) return;
    setState(() {
      _progress = fraction;
      _statusMessage = message;
    });
  }

  Future<void> _guard(Future<void> Function() action) async {
    setState(() {
      _running = true;
      _error = null;
      _progress = 0;
      _statusMessage = 'Preparing…';
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _running = false;
          _statusMessage = '';
        });
      }
    }
  }

  Future<void> _savePdf() => _guard(() async {
    final controller = widget.controller;
    controller.setExportOptions(_currentOptions);
    final file = await PdfExporter.export(
      layout: controller.layout,
      settings: controller.settings,
      itemsById: controller.itemsById,
      options: _currentOptions,
      onProgress: _report,
    );
    final outcome = await FileSaver.save(
      bytes: file.bytes,
      suggestedName: file.fileName,
      mimeType: file.mimeType,
    );
    if (!mounted) return;
    if (outcome != SaveOutcome.cancelled) {
      AnalyticsService.instance.logExportCompleted(
        toolId: 'photo-compose',
        format: 'pdf',
        pageCount: controller.layout.pages.length,
      );
    }
    _finish(
      outcome == SaveOutcome.cancelled
          ? 'Export cancelled'
          : 'Saved ${file.fileName} (${file.readableSize})',
    );
  });

  Future<void> _saveImages() => _guard(() async {
    final controller = widget.controller;
    controller.setExportOptions(_currentOptions);
    final files = await RasterExporter.export(
      layout: controller.layout,
      settings: controller.settings,
      itemsById: controller.itemsById,
      options: _currentOptions,
      onProgress: _report,
    );
    final written = await FileSaver.saveAll([
      for (final file in files)
        (bytes: file.bytes, suggestedName: file.fileName, mimeType: file.mimeType),
    ]);
    if (!mounted) return;
    if (written > 0) {
      AnalyticsService.instance.logExportCompleted(
        toolId: 'photo-compose',
        format: _currentOptions.format.name,
        pageCount: written,
      );
    }
    _finish(written == 0 ? 'Export cancelled' : 'Saved $written image${written == 1 ? '' : 's'}');
  });

  Future<void> _print() => _guard(() async {
    final controller = widget.controller;
    final file = await PdfExporter.export(
      layout: controller.layout,
      settings: controller.settings,
      itemsById: controller.itemsById,
      options: _currentOptions,
      onProgress: _report,
    );
    await Printing.layoutPdf(
      onLayout: (_) => file.bytes,
      name: file.fileName,
      // The layout already places everything at exact physical sizes, so
      // the printer must not add any scaling of its own.
      usePrinterSettings: false,
    );
    if (mounted) Navigator.of(context).maybePop();
  });

  void _finish(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.of(context).maybePop();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;
    final pageCount = controller.layout.pageCount;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Export',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _running ? null : () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$pageCount page${pageCount == 1 ? '' : 's'} · '
              '${controller.totalPrints} print'
              '${controller.totalPrints == 1 ? '' : 's'} · '
              '${controller.settings.paper.name}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('PDF'),
                  icon: Icon(Icons.picture_as_pdf_outlined, size: 17),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Images'),
                  icon: Icon(Icons.image_outlined, size: 17),
                ),
              ],
              selected: {_asPdf},
              showSelectedIcon: false,
              onSelectionChanged: _running
                  ? null
                  : (selection) => setState(() => _asPdf = selection.first),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              enabled: !_running,
              decoration: InputDecoration(
                labelText: 'File name',
                suffixText: _asPdf ? '.pdf' : '.${_options.format.extension}',
              ),
            ),
            const SizedBox(height: 14),
            if (!_asPdf) ...[
              DropdownButtonFormField<RasterFormat>(
                initialValue: _options.format,
                decoration: const InputDecoration(labelText: 'Image format'),
                items: [
                  for (final format in RasterFormat.values)
                    DropdownMenuItem(value: format, child: Text(format.label)),
                ],
                onChanged: _running
                    ? null
                    : (format) => setState(() => _options = _options.copyWith(format: format)),
              ),
              const SizedBox(height: 14),
            ],
            DropdownButtonFormField<int>(
              initialValue: _options.dpi,
              decoration: const InputDecoration(labelText: 'Resolution'),
              items: [
                for (final entry in ExportOptions.dpiChoices.entries)
                  DropdownMenuItem(
                    value: entry.key,
                    child: Text('${entry.key} DPI — ${entry.value}'),
                  ),
              ],
              onChanged: _running
                  ? null
                  : (dpi) => setState(() => _options = _options.copyWith(dpi: dpi)),
            ),
            if (_asPdf || _options.format == RasterFormat.jpeg) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('JPEG quality', style: theme.textTheme.labelMedium),
                  const Spacer(),
                  Text('${_options.jpegQuality}', style: theme.textTheme.labelMedium),
                ],
              ),
              Slider(
                value: _options.jpegQuality.toDouble(),
                min: 50,
                max: 100,
                divisions: 50,
                onChanged: _running
                    ? null
                    : (value) =>
                          setState(() => _options = _options.copyWith(jpegQuality: value.round())),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_running) ...[
              const SizedBox(height: 20),
              LinearProgressIndicator(value: _progress == 0 ? null : _progress),
              const SizedBox(height: 8),
              Text(
                _statusMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _running ? null : _print,
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('Print'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _running ? null : (_asPdf ? _savePdf : _saveImages),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(_asPdf ? 'Save PDF' : 'Save images'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
