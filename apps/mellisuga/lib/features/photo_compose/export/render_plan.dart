import '../../../core/units/length.dart';
import '../models/layout_result.dart';
import '../models/photo_edits.dart';
import '../models/photo_item.dart';

/// One distinct bitmap an export has to produce, together with every placement
/// that uses it.
///
/// Two placements share a job whenever they would come out pixel for pixel
/// identical: same photo, same edits, same printed size. A sheet of twenty
/// copies of one passport photo is therefore a single job, not twenty.
class RenderJob {
  RenderJob({
    required this.key,
    required this.item,
    required this.edits,
    required this.widthPx,
    required this.heightPx,
  });

  /// Identity of the bitmap: everything that affects the output pixels.
  final String key;

  final PhotoItem item;

  /// Edits to apply, which may differ from `item.edits` when the layout engine
  /// turned this placement 90°.
  final PhotoEdits edits;

  final int widthPx;
  final int heightPx;

  /// Every placement this bitmap is drawn at.
  final List<PlacedPhoto> placements = [];

  /// `true` when no later job in the plan needs [item]'s decoded source, so it
  /// can be dropped as soon as this job is done.
  bool lastOfSource = false;

  int get pixelCount => widthPx * heightPx;
}

/// Groups every placement across [pages] into the smallest set of bitmaps that
/// can draw them all.
///
/// Jobs come back grouped by source photo, largest print first. That ordering is
/// what lets an exporter decode each photo once — the downscaled source kept for
/// the biggest print also satisfies every smaller one — and then release it
/// before opening the next file, instead of holding the whole set in memory.
List<RenderJob> planRenderJobs({
  required Iterable<ComposedPage> pages,
  required Map<String, PhotoItem> itemsById,
  required int dpi,
}) {
  final jobs = <String, RenderJob>{};

  for (final page in pages) {
    for (final placed in page.photos) {
      final item = itemsById[placed.itemId];
      if (item == null) continue;

      final edits = effectiveEditsFor(item, placed);
      final width = pixelsFor(placed.widthMm, dpi);
      final height = pixelsFor(placed.heightMm, dpi);
      final key = renderJobKey(item, edits, width, height);

      final job = jobs.putIfAbsent(
        key,
        () => RenderJob(key: key, item: item, edits: edits, widthPx: width, heightPx: height),
      );
      job.placements.add(placed);
    }
  }

  final ordered = jobs.values.toList()
    ..sort((a, b) {
      final byPhoto = a.item.id.compareTo(b.item.id);
      return byPhoto != 0 ? byPhoto : b.pixelCount.compareTo(a.pixelCount);
    });

  for (var index = 0; index < ordered.length; index++) {
    ordered[index].lastOfSource =
        index == ordered.length - 1 || ordered[index + 1].item.id != ordered[index].item.id;
  }

  return ordered;
}

/// The edit stack to apply for [placed].
///
/// Folding the layout's 90° turn into the photo's own quarter turns is exact:
/// rotations compose, and flips are applied before both.
PhotoEdits effectiveEditsFor(PhotoItem item, PlacedPhoto placed) =>
    placed.rotated ? item.edits.copyWith(quarterTurns: item.edits.quarterTurns + 1) : item.edits;

/// Cache key covering everything that changes the rendered pixels.
String renderJobKey(PhotoItem item, PhotoEdits edits, int widthPx, int heightPx) =>
    '${item.id}|${edits.signature}|${item.fit.name}|${widthPx}x$heightPx';

/// Converts [millimeters] to whole pixels at [dpi], never returning less than
/// [minimum].
int pixelsFor(double millimeters, int dpi, {int minimum = 1}) {
  final pixels = millimeters.mmToPixels(dpi.toDouble()).round();
  return pixels < minimum ? minimum : pixels;
}

/// Hands the frame back to the browser between expensive steps.
///
/// Export runs on the same thread as the UI on web, so without this the progress
/// bar never paints — and a long silent stretch is exactly what makes a mobile
/// browser decide the tab has hung.
Future<void> breathe() => Future<void>.delayed(Duration.zero);
