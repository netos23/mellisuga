import 'dart:math' as math;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

import '../../../core/units/length.dart';
import '../../../core/units/paper_format.dart';
import '../export/export_options.dart';
import '../logic/layout_engine.dart';
import '../logic/photo_importer.dart';
import '../models/layout_result.dart';
import '../models/layout_settings.dart';
import '../models/photo_edits.dart';
import '../models/photo_item.dart';
import '../models/photo_size.dart';

/// What the composer is currently doing, so the UI can show the right feedback.
enum ComposeBusyState { idle, importing, exporting, printing }

/// Holds every piece of composer state and recomputes the layout on change.
///
/// The layout runs synchronously on every mutation. That is a deliberate
/// choice: packing a few hundred rectangles takes well under a millisecond, and
/// keeping it synchronous means the preview can never lag behind the controls.
class ComposeController extends ChangeNotifier {
  ComposeController();

  final List<PhotoItem> _items = <PhotoItem>[];
  LayoutSettings _settings = const LayoutSettings();
  LayoutResult _layout = LayoutResult.empty;
  ExportOptions _exportOptions = const ExportOptions();
  LengthUnit _unit = LengthUnit.millimeter;

  String? _selectedItemId;
  String? _selectedInstanceKey;

  ComposeBusyState _busy = ComposeBusyState.idle;
  double _progress = 0;
  String? _statusMessage;
  final List<ImportFailure> _importFailures = <ImportFailure>[];

  int _nextId = 0;

  // ---------------------------------------------------------------- getters

  List<PhotoItem> get items => List.unmodifiable(_items);

  LayoutSettings get settings => _settings;

  LayoutResult get layout => _layout;

  ExportOptions get exportOptions => _exportOptions;

  LengthUnit get unit => _unit;

  String? get selectedItemId => _selectedItemId;

  String? get selectedInstanceKey => _selectedInstanceKey;

  ComposeBusyState get busy => _busy;

  bool get isBusy => _busy != ComposeBusyState.idle;

  double get progress => _progress;

  String? get statusMessage => _statusMessage;

  List<ImportFailure> get importFailures => List.unmodifiable(_importFailures);

  bool get isEmpty => _items.isEmpty;

  bool get hasPages => _layout.pages.isNotEmpty;

  /// Photos indexed by id, for painters and exporters.
  Map<String, PhotoItem> get itemsById => {for (final item in _items) item.id: item};

  PhotoItem? get selectedItem {
    final id = _selectedItemId;
    if (id == null) return null;
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Total number of prints once copies are counted.
  int get totalPrints => _items.fold(0, (sum, item) => sum + item.copies);

  /// Photos that would print below 150 DPI at their current size.
  List<PhotoItem> get lowResolutionItems =>
      _items.where((item) => item.effectiveDpi < 150).toList(growable: false);

  // ------------------------------------------------------------- selection

  void selectItem(String? itemId) {
    if (_selectedItemId == itemId) return;
    _selectedItemId = itemId;
    if (itemId == null) {
      _selectedInstanceKey = null;
    } else if (_selectedInstanceKey?.startsWith('$itemId#') != true) {
      _selectedInstanceKey = '$itemId#0';
    }
    notifyListeners();
  }

  /// Selects a specific placed copy, e.g. after tapping the sheet preview.
  void selectInstance(String? instanceKey) {
    _selectedInstanceKey = instanceKey;
    _selectedItemId = instanceKey?.split('#').first;
    notifyListeners();
  }

  // ----------------------------------------------------------------- import

  /// Opens the system file picker and imports whatever the user chooses.
  Future<void> pickAndAddPhotos() async {
    const typeGroup = XTypeGroup(
      label: 'Images',
      extensions: <String>['jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif', 'tif', 'tiff'],
      mimeTypes: <String>['image/*'],
      uniformTypeIdentifiers: <String>['public.image'],
    );
    final files = await openFiles(acceptedTypeGroups: const <XTypeGroup>[typeGroup]);
    if (files.isEmpty) return;
    await addFiles(files);
  }

  /// Imports already-selected files, e.g. from a drag-and-drop.
  Future<void> addFiles(List<XFile> files) async {
    if (files.isEmpty) return;
    _importFailures.clear();
    _setBusy(ComposeBusyState.importing, message: 'Reading photos…', progress: 0);

    try {
      for (var index = 0; index < files.length; index++) {
        final file = files[index];
        _statusMessage = 'Reading ${file.name} (${index + 1} of ${files.length})';
        _progress = index / files.length;
        notifyListeners();

        try {
          final bytes = await file.readAsBytes();
          final item = await PhotoImporter.import(
            id: 'photo-${_nextId++}',
            fileName: file.name,
            bytes: Uint8List.fromList(bytes),
          );
          _items.add(item);
          _selectedItemId ??= item.id;
        } on ImportException catch (error) {
          _importFailures.add(ImportFailure(fileName: file.name, reason: error.message));
        } catch (error) {
          _importFailures.add(
            ImportFailure(fileName: file.name, reason: 'Could not read the file: $error'),
          );
        }
      }
      _recompute();
    } finally {
      _setBusy(ComposeBusyState.idle);
    }
  }

  void dismissImportFailures() {
    if (_importFailures.isEmpty) return;
    _importFailures.clear();
    notifyListeners();
  }

  // ------------------------------------------------------------ item edits

  void removeItem(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index < 0) return;
    _items[index].image.dispose();
    _items.removeAt(index);
    if (_selectedItemId == itemId) {
      _selectedItemId = _items.isEmpty ? null : _items[math.min(index, _items.length - 1)].id;
      _selectedInstanceKey = _selectedItemId == null ? null : '$_selectedItemId#0';
    }
    _recompute();
  }

  void removeAll() {
    for (final item in _items) {
      item.image.dispose();
    }
    _items.clear();
    _selectedItemId = null;
    _selectedInstanceKey = null;
    _recompute();
  }

  /// Adds another copy of an existing photo as a separate, independently
  /// editable item.
  void duplicateItem(String itemId) {
    final source = _items.firstWhere((item) => item.id == itemId);
    // Sharing the decoded preview would mean a `dispose` on one item breaks the
    // other, so the duplicate gets its own clone.
    final clone = PhotoItem(
      id: 'photo-${_nextId++}',
      fileName: source.fileName,
      bytes: source.bytes,
      image: source.image.clone(),
      naturalWidth: source.naturalWidth,
      naturalHeight: source.naturalHeight,
      printSize: source.printSize,
      edits: source.edits,
      copies: source.copies,
      fit: source.fit,
      allowRotation: source.allowRotation,
      label: source.label,
    );
    _items.insert(_items.indexOf(source) + 1, clone);
    _selectedItemId = clone.id;
    _selectedInstanceKey = '${clone.id}#0';
    _recompute();
  }

  /// Moves a photo within the list.
  ///
  /// [newIndex] is the destination *after* the item has been lifted out, which
  /// is what `ReorderableListView.onReorderItem` reports.
  void moveItem(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _items.length) return;
    final target = newIndex.clamp(0, _items.length - 1);
    if (target == oldIndex) return;
    _items.insert(target, _items.removeAt(oldIndex));
    _recompute();
  }

  void updateItem(String itemId, PhotoItem Function(PhotoItem item) transform) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index < 0) return;
    _items[index] = transform(_items[index]);
    _recompute();
  }

  void setPrintSize(String itemId, PhotoPrintSize size) =>
      updateItem(itemId, (item) => item.copyWith(printSize: size));

  void setCopies(String itemId, int copies) =>
      updateItem(itemId, (item) => item.copyWith(copies: copies.clamp(1, 999)));

  void setFit(String itemId, PhotoFit fit) => updateItem(itemId, (item) => item.copyWith(fit: fit));

  void setAllowRotation(String itemId, bool allow) =>
      updateItem(itemId, (item) => item.copyWith(allowRotation: allow));

  void setEdits(String itemId, PhotoEdits edits) =>
      updateItem(itemId, (item) => item.copyWith(edits: edits));

  /// Rotates a photo by one quarter turn without opening the editor.
  void rotateItem(String itemId, {bool clockwise = true}) => updateItem(
    itemId,
    (item) => item.copyWith(
      edits: item.edits.copyWith(quarterTurns: item.edits.quarterTurns + (clockwise ? 1 : -1)),
    ),
  );

  /// Swaps a photo's print size between portrait and landscape.
  void swapPrintOrientation(String itemId) =>
      updateItem(itemId, (item) => item.copyWith(printSize: item.printSize.swapped));

  /// Applies the selected photo's print size to every other photo.
  void applySizeToAll(PhotoPrintSize size, {bool matchOrientation = true}) {
    for (var index = 0; index < _items.length; index++) {
      final item = _items[index];
      final target = matchOrientation && item.editedAspectRatio > 1 && !size.isLandscape
          ? size.swapped
          : size;
      _items[index] = item.copyWith(printSize: target);
    }
    _recompute();
  }

  // -------------------------------------------------------------- settings

  void updateSettings(LayoutSettings Function(LayoutSettings settings) transform) {
    _settings = transform(_settings);
    _recompute();
  }

  void setPaper(PaperFormat paper) => updateSettings((settings) => settings.copyWith(paper: paper));

  void setOrientation(PageOrientation orientation) =>
      updateSettings((settings) => settings.copyWith(orientation: orientation));

  void setUnit(LengthUnit unit) {
    if (_unit == unit) return;
    _unit = unit;
    notifyListeners();
  }

  void setExportOptions(ExportOptions options) {
    _exportOptions = options;
    notifyListeners();
  }

  // ---------------------------------------------------------------- export

  /// Marks the controller busy while an export runs, and routes progress
  /// updates from the exporter into the UI.
  Future<T> runExport<T>(
    Future<T> Function(ExportProgress onProgress) action, {
    ComposeBusyState state = ComposeBusyState.exporting,
  }) async {
    _setBusy(state, message: 'Preparing…', progress: 0);
    try {
      return await action((fraction, message) {
        _progress = fraction.clamp(0.0, 1.0);
        _statusMessage = message;
        notifyListeners();
      });
    } finally {
      _setBusy(ComposeBusyState.idle);
    }
  }

  // --------------------------------------------------------------- internals

  void _recompute() {
    _layout = LayoutEngine.compose(
      inputs: [
        for (final item in _items)
          LayoutInput(
            itemId: item.id,
            widthMm: item.printSize.widthMm,
            heightMm: item.printSize.heightMm,
            copies: item.copies,
            allowRotation: item.allowRotation,
          ),
      ],
      settings: _settings,
    );

    // Keep the highlighted copy valid after a re-layout.
    final selected = _selectedInstanceKey;
    if (selected != null) {
      final stillPlaced = _layout.pages.any(
        (page) => page.photos.any((photo) => photo.instanceKey == selected),
      );
      if (!stillPlaced) {
        _selectedInstanceKey = _selectedItemId == null ? null : '$_selectedItemId#0';
      }
    }

    notifyListeners();
  }

  void _setBusy(ComposeBusyState state, {String? message, double progress = 0}) {
    _busy = state;
    _statusMessage = state == ComposeBusyState.idle ? null : message;
    _progress = state == ComposeBusyState.idle ? 0 : progress;
    notifyListeners();
  }

  /// The page index a placed instance lives on, or `null` when not placed.
  int? pageIndexOf(String instanceKey) {
    for (final page in _layout.pages) {
      if (page.photos.any((photo) => photo.instanceKey == instanceKey)) {
        return page.index;
      }
    }
    return null;
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.image.dispose();
    }
    _items.clear();
    super.dispose();
  }
}
