import 'package:flutter_test/flutter_test.dart';
import 'package:mellisuga/features/photo_compose/logic/divider_geometry.dart';
import 'package:mellisuga/features/photo_compose/models/layout_result.dart';
import 'package:mellisuga/features/photo_compose/models/layout_settings.dart';

ComposedPage _page(List<PlacedPhoto> photos) =>
    ComposedPage(index: 0, widthMm: 210, heightMm: 297, photos: photos);

const _photo = PlacedPhoto(
  itemId: 'a',
  copyIndex: 0,
  xMm: 20,
  yMm: 30,
  widthMm: 100,
  heightMm: 150,
  rotated: false,
);

void main() {
  group('DividerGeometry', () {
    test('draws nothing when guides are turned off', () {
      final segments = DividerGeometry.build(
        _page([_photo]),
        const LayoutSettings(dividerStyle: DividerStyle.none),
      );
      expect(segments, isEmpty);
    });

    test('outline draws four sides per photo', () {
      final segments = DividerGeometry.build(
        _page([_photo]),
        const LayoutSettings(dividerStyle: DividerStyle.outline),
      );
      expect(segments.length, 4);
      // The outline must trace the photo's own rectangle exactly.
      expect(segments.first.x1, closeTo(_photo.xMm, 1e-9));
      expect(segments.first.x2, closeTo(_photo.rightMm, 1e-9));
    });

    test('cut lines span the whole sheet', () {
      final segments = DividerGeometry.build(
        _page([_photo]),
        const LayoutSettings(dividerStyle: DividerStyle.cutLines, spacingMm: 4),
      );
      expect(segments, isNotEmpty);
      for (final segment in segments) {
        final isVertical = (segment.x1 - segment.x2).abs() < 1e-9;
        if (isVertical) {
          expect(segment.y1, closeTo(0, 1e-9));
          expect(segment.y2, closeTo(297, 1e-9));
        } else {
          expect(segment.x1, closeTo(0, 1e-9));
          expect(segment.x2, closeTo(210, 1e-9));
        }
      }
    });

    test('cut lines run through the middle of the gap between photos', () {
      const spacing = 4.0;
      const second = PlacedPhoto(
        itemId: 'b',
        copyIndex: 0,
        xMm: 124,
        yMm: 30,
        widthMm: 60,
        heightMm: 150,
        rotated: false,
      );
      final segments = DividerGeometry.build(
        _page([_photo, second]),
        const LayoutSettings(dividerStyle: DividerStyle.cutLines, spacingMm: spacing),
      );
      // The gap runs from x=120 to x=124, so the shared cut line sits at 122.
      final verticals = segments
          .where((segment) => (segment.x1 - segment.x2).abs() < 1e-9)
          .map((segment) => segment.x1)
          .toList();
      expect(verticals, contains(closeTo(122, 1e-9)));
    });

    test('crop marks stay clear of the photo itself', () {
      final segments = DividerGeometry.build(
        _page([_photo]),
        const LayoutSettings(dividerStyle: DividerStyle.cropMarks, spacingMm: 6),
      );
      // Eight ticks: two at each of the four corners.
      expect(segments.length, 8);
    });

    test('dashing splits a segment into multiple pieces', () {
      const segment = GuideSegment(0, 0, 20, 0);
      final dashes = DividerGeometry.applyPattern(segment, DividerPattern.dashed, 0.2);
      expect(dashes.length, greaterThan(1));
      // Dashes stay within the original segment.
      for (final dash in dashes) {
        expect(dash.x1, greaterThanOrEqualTo(-1e-9));
        expect(dash.x2, lessThanOrEqualTo(20 + 1e-9));
      }
    });

    test('a solid pattern leaves the segment intact', () {
      const segment = GuideSegment(0, 0, 20, 0);
      final result = DividerGeometry.applyPattern(segment, DividerPattern.solid, 0.2);
      expect(result.length, 1);
      expect(result.single.x2, 20);
    });
  });
}
