import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mellisuga/features/photo_compose/models/photo_edits.dart';

void main() {
  group('PhotoEdits coordinate mapping', () {
    const samplePoints = [
      Offset(0, 0),
      Offset(1, 0),
      Offset(0, 1),
      Offset(1, 1),
      Offset(0.25, 0.75),
      Offset(0.5, 0.5),
    ];

    /// Every combination of rotation and flips the editor can produce.
    final allTransforms = <PhotoEdits>[
      for (var turns = 0; turns < 4; turns++)
        for (final flipH in [false, true])
          for (final flipV in [false, true])
            PhotoEdits(quarterTurns: turns, flipHorizontal: flipH, flipVertical: flipV),
    ];

    test('display and crop space are exact inverses', () {
      for (final edits in allTransforms) {
        for (final point in samplePoints) {
          final roundTripped = edits.cropToDisplaySpace(edits.displayToCropSpace(point));
          expect(
            roundTripped.dx,
            closeTo(point.dx, 1e-9),
            reason:
                'turns=${edits.quarterTurns} '
                'flipH=${edits.flipHorizontal} flipV=${edits.flipVertical}',
          );
          expect(roundTripped.dy, closeTo(point.dy, 1e-9));
        }
      }
    });

    test('a 90° turn maps the top-left corner to the top-right', () {
      const edits = PhotoEdits(quarterTurns: 1);
      final result = edits.cropToDisplaySpace(Offset.zero);
      expect(result.dx, closeTo(1, 1e-9));
      expect(result.dy, closeTo(0, 1e-9));
    });

    test('a horizontal flip mirrors the x axis only', () {
      const edits = PhotoEdits(flipHorizontal: true);
      final result = edits.cropToDisplaySpace(const Offset(0.2, 0.7));
      expect(result.dx, closeTo(0.8, 1e-9));
      expect(result.dy, closeTo(0.7, 1e-9));
    });

    test('quarter turns wrap into 0..3', () {
      expect(const PhotoEdits().copyWith(quarterTurns: 5).quarterTurns, 1);
      expect(const PhotoEdits().copyWith(quarterTurns: -1).quarterTurns, 3);
      expect(const PhotoEdits().copyWith(quarterTurns: 4).quarterTurns, 0);
    });

    test('odd quarter turns swap the aspect ratio', () {
      const upright = PhotoEdits();
      const turned = PhotoEdits(quarterTurns: 1);
      expect(upright.aspectRatioFor(400, 200), closeTo(2, 1e-9));
      expect(turned.aspectRatioFor(400, 200), closeTo(0.5, 1e-9));
    });

    test('cropping changes the aspect ratio', () {
      const edits = PhotoEdits(cropRect: Rect.fromLTWH(0, 0, 0.5, 1));
      expect(edits.aspectRatioFor(400, 400), closeTo(0.5, 1e-9));
    });

    test('the signature changes when any edit changes', () {
      const base = PhotoEdits();
      expect(base.copyWith(quarterTurns: 1).signature, isNot(base.signature));
      expect(base.copyWith(flipHorizontal: true).signature, isNot(base.signature));
      expect(
        base.copyWith(cropRect: const Rect.fromLTWH(0.1, 0, 0.5, 0.5)).signature,
        isNot(base.signature),
      );
      expect(
        base
            .copyWith(
              strokes: const [
                DrawStroke(points: [Offset.zero], color: Color(0xFF000000), width: 0.01),
              ],
            )
            .signature,
        isNot(base.signature),
      );
    });

    test('survives a JSON round trip', () {
      const original = PhotoEdits(
        cropRect: Rect.fromLTWH(0.1, 0.2, 0.5, 0.6),
        quarterTurns: 3,
        flipHorizontal: true,
        strokes: [
          DrawStroke(
            points: [Offset(0.1, 0.1), Offset(0.4, 0.6)],
            color: Color(0xFFE0457B),
            width: 0.012,
          ),
        ],
      );
      final restored = PhotoEdits.fromJson(original.toJson());
      expect(restored.signature, original.signature);
      expect(restored.cropRect, original.cropRect);
      expect(restored.strokes.single.points.length, 2);
      expect(restored.strokes.single.color, const Color(0xFFE0457B));
    });
  });
}
