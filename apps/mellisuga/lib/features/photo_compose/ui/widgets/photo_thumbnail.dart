import 'package:flutter/material.dart';

import '../../models/photo_item.dart';
import '../painting/photo_painting.dart';

/// A small preview of a photo with its current edits applied.
///
/// Uses the same painting code as the sheet preview, so a crop or rotation
/// shows up here immediately without any re-encoding.
class PhotoThumbnail extends StatelessWidget {
  const PhotoThumbnail({
    super.key,
    required this.item,
    this.size = 52,
    this.borderRadius = 8,
    this.showPrintAspect = true,
  });

  final PhotoItem item;
  final double size;
  final double borderRadius;

  /// When set, the thumbnail is shaped like the chosen print size rather than
  /// the photo, which makes it obvious how the photo will be cropped.
  final bool showPrintAspect;

  @override
  Widget build(BuildContext context) {
    final aspect = showPrintAspect ? item.printSize.aspectRatio : item.editedAspectRatio;
    final width = aspect >= 1 ? size : size * aspect;
    final height = aspect >= 1 ? size / aspect : size;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: CustomPaint(painter: _ThumbnailPainter(item: item)),
      ),
    );
  }
}

class _ThumbnailPainter extends CustomPainter {
  const _ThumbnailPainter({required this.item});

  final PhotoItem item;

  @override
  void paint(Canvas canvas, Size size) {
    PhotoPainting.drawPhoto(
      canvas,
      image: item.image,
      edits: item.edits,
      destination: Offset.zero & size,
      fit: item.fit,
      filterQuality: FilterQuality.low,
    );
  }

  @override
  bool shouldRepaint(covariant _ThumbnailPainter oldDelegate) =>
      oldDelegate.item.renderSignature != item.renderSignature ||
      !identical(oldDelegate.item.image, item.image);
}
