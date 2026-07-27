import 'package:flutter_test/flutter_test.dart';
import 'package:mellisuga/core/units/paper_format.dart';
import 'package:mellisuga/features/photo_compose/logic/layout_engine.dart';
import 'package:mellisuga/features/photo_compose/models/layout_settings.dart';

/// A4 with 8 mm margins and 3 mm spacing — the app's defaults.
const _defaults = LayoutSettings();

LayoutInput _photo(
  String id, {
  double width = 100,
  double height = 150,
  int copies = 1,
  bool allowRotation = true,
}) => LayoutInput(
  itemId: id,
  widthMm: width,
  heightMm: height,
  copies: copies,
  allowRotation: allowRotation,
);

void main() {
  group('LayoutEngine', () {
    test('returns nothing for an empty input', () {
      final result = LayoutEngine.compose(inputs: const [], settings: _defaults);
      expect(result.pages, isEmpty);
      expect(result.placedCount, 0);
    });

    test('places every copy of every photo', () {
      final result = LayoutEngine.compose(
        inputs: [_photo('a', copies: 3), _photo('b', width: 35, height: 45, copies: 5)],
        settings: _defaults,
      );
      expect(result.placedCount, 8);
    });

    test('keeps photos inside the printable area', () {
      final result = LayoutEngine.compose(
        inputs: [_photo('a', width: 35, height: 45, copies: 24)],
        settings: _defaults,
      );

      for (final page in result.pages) {
        for (final photo in page.photos) {
          expect(photo.xMm, greaterThanOrEqualTo(_defaults.marginLeftMm - 1e-6));
          expect(photo.yMm, greaterThanOrEqualTo(_defaults.marginTopMm - 1e-6));
          expect(
            photo.rightMm,
            lessThanOrEqualTo(_defaults.pageWidthMm - _defaults.marginRightMm + 1e-6),
          );
          expect(
            photo.bottomMm,
            lessThanOrEqualTo(_defaults.pageHeightMm - _defaults.marginBottomMm + 1e-6),
          );
        }
      }
    });

    test('never overlaps two photos', () {
      final result = LayoutEngine.compose(
        inputs: [
          _photo('a', width: 100, height: 150, copies: 4),
          _photo('b', width: 35, height: 45, copies: 10),
          _photo('c', width: 63.5, height: 88.9, copies: 6),
        ],
        settings: _defaults,
      );

      for (final page in result.pages) {
        for (var i = 0; i < page.photos.length; i++) {
          for (var j = i + 1; j < page.photos.length; j++) {
            final a = page.photos[i];
            final b = page.photos[j];
            final overlaps =
                a.xMm < b.rightMm - 1e-6 &&
                a.rightMm > b.xMm + 1e-6 &&
                a.yMm < b.bottomMm - 1e-6 &&
                a.bottomMm > b.yMm + 1e-6;
            expect(overlaps, isFalse, reason: 'page ${page.index}: $i overlaps $j');
          }
        }
      }
    });

    test('honours the configured spacing between neighbours', () {
      const settings = LayoutSettings(spacingMm: 6);
      final result = LayoutEngine.compose(
        inputs: [_photo('a', width: 50, height: 50, copies: 6)],
        settings: settings,
      );

      for (final page in result.pages) {
        for (var i = 0; i < page.photos.length; i++) {
          for (var j = i + 1; j < page.photos.length; j++) {
            final a = page.photos[i];
            final b = page.photos[j];
            // Neighbours must be separated by at least the spacing on one axis.
            final horizontalGap = a.xMm >= b.rightMm
                ? a.xMm - b.rightMm
                : (b.xMm >= a.rightMm ? b.xMm - a.rightMm : -1.0);
            final verticalGap = a.yMm >= b.bottomMm
                ? a.yMm - b.bottomMm
                : (b.yMm >= a.bottomMm ? b.yMm - a.bottomMm : -1.0);
            final separated =
                horizontalGap >= settings.spacingMm - 1e-6 ||
                verticalGap >= settings.spacingMm - 1e-6;
            expect(separated, isTrue, reason: 'photos $i and $j are too close');
          }
        }
      }
    });

    test('starts a new page once the current one is full', () {
      final result = LayoutEngine.compose(
        inputs: [_photo('a', width: 100, height: 150, copies: 5)],
        settings: _defaults,
      );
      // Only two 100 × 150 prints fit on an A4 sheet with margins.
      expect(result.pageCount, greaterThan(1));
      expect(result.placedCount, 5);
    });

    test('rotates a photo when that is the only way it fits', () {
      // 250 mm is wider than A4's printable width but fits its height.
      final result = LayoutEngine.compose(
        inputs: [_photo('wide', width: 250, height: 100)],
        settings: _defaults,
      );
      expect(result.placedCount, 1);
      final placed = result.pages.first.photos.first;
      expect(placed.rotated, isTrue);
      expect(placed.widthMm, closeTo(100, 1e-6));
      expect(placed.heightMm, closeTo(250, 1e-6));
    });

    test('leaves a photo unrotated when rotation is disabled and it fits', () {
      final result = LayoutEngine.compose(
        inputs: [_photo('a', width: 100, height: 150, allowRotation: false)],
        settings: _defaults,
      );
      expect(result.pages.first.photos.first.rotated, isFalse);
    });

    test('shrinks an oversized photo and reports it', () {
      final result = LayoutEngine.compose(
        inputs: [_photo('huge', width: 400, height: 600)],
        settings: _defaults,
      );
      expect(result.placedCount, 1);
      expect(result.pages.first.photos.first.scaledDown, isTrue);
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first.fatal, isFalse);
    });

    test('skips an oversized photo when shrinking is turned off', () {
      final result = LayoutEngine.compose(
        inputs: [_photo('huge', width: 400, height: 600)],
        settings: const LayoutSettings(shrinkOversizedPhotos: false),
      );
      expect(result.placedCount, 0);
      expect(result.warnings.single.fatal, isTrue);
    });

    test('backfills gaps by trying earlier pages first', () {
      // One large photo fills most of page 1; the small ones should slot into
      // the leftover space rather than opening a second page.
      final result = LayoutEngine.compose(
        inputs: [
          _photo('big', width: 200, height: 180),
          _photo('small', width: 35, height: 45, copies: 4),
        ],
        settings: _defaults,
      );
      expect(result.pageCount, 1);
    });

    test('uses the full sheet size for the page dimensions', () {
      final result = LayoutEngine.compose(
        inputs: [_photo('a')],
        settings: const LayoutSettings(paper: PaperFormats.letter),
      );
      expect(result.pages.first.widthMm, closeTo(215.9, 1e-6));
      expect(result.pages.first.heightMm, closeTo(279.4, 1e-6));
    });

    test('landscape orientation swaps the sheet dimensions', () {
      const settings = LayoutSettings(orientation: PageOrientation.landscape);
      expect(settings.pageWidthMm, closeTo(297, 1e-6));
      expect(settings.pageHeightMm, closeTo(210, 1e-6));
    });
  });
}
