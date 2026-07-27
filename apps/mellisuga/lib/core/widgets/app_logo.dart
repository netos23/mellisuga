import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

import '../app_info.dart';
import '../theme/app_theme.dart';

/// The Mellisuga mark: a hummingbird in flight, drawn as vector paths so it
/// stays sharp at every size and adapts to the current theme.
///
/// The geometry comes from `BrandMark` in `package:mellisuga_content`, which is
/// the same source the landing site inlines as SVG — one bird, two renderers.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 32, this.bodyColor, this.accentColor});

  final double size;

  /// Colour of the body and tail. Defaults to the theme's primary.
  final Color? bodyColor;

  /// Colour of the wing and throat. Defaults to the theme's tertiary.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _HummingbirdPainter(
          bodyColor: bodyColor ?? scheme.primary,
          accentColor: accentColor ?? scheme.tertiary,
        ),
      ),
    );
  }
}

/// The mark plus the wordmark, used in the app bar and on the home screen.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.markSize = 30,
    this.showWordmark = true,
    this.showTagline = false,
    this.textStyle,
  });

  final double markSize;
  final bool showWordmark;
  final bool showTagline;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!showWordmark) return AppLogoMark(size: markSize);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogoMark(size: markSize),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppInfo.name,
              style:
                  textStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
            ),
            if (showTagline)
              Text(
                AppInfo.tagline,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A larger badge version with a rounded gradient tile behind the mark, used on
/// the home screen and the about page.
class AppLogoBadge extends StatelessWidget {
  const AppLogoBadge({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(AppTheme.seed, Colors.white, 0.12)!,
            Color.lerp(AppTheme.seed, Colors.black, 0.28)!,
          ],
        ),
      ),
      child: Center(
        child: AppLogoMark(
          size: size * 0.66,
          bodyColor: Colors.white,
          accentColor: Color.lerp(AppTheme.accent, Colors.white, 0.35)!,
        ),
      ),
    );
  }
}

class _HummingbirdPainter extends CustomPainter {
  const _HummingbirdPainter({required this.bodyColor, required this.accentColor});

  final Color bodyColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    // The mark is authored on a 100 x 100 grid and scaled to fit.
    final scale = math.min(size.width, size.height) / BrandMark.canvasSize;
    final extent = BrandMark.canvasSize * scale;
    // A layer is required so the eye's `BlendMode.clear` punches through the
    // mark only, rather than erasing whatever is painted behind the widget.
    canvas
      ..saveLayer(Offset.zero & size, Paint())
      ..translate((size.width - extent) / 2, (size.height - extent) / 2)
      ..scale(scale);

    final bodyPaint = Paint()
      ..color = bodyColor
      ..isAntiAlias = true;
    final accentPaint = Paint()
      ..color = accentColor
      ..isAntiAlias = true;

    for (final shape in BrandMark.paths) {
      canvas.drawPath(_pathFor(shape), switch (shape.tone) {
        MarkTone.body => bodyPaint,
        MarkTone.accent => accentPaint,
      });
    }

    // Eye, punched out of the body so it works on any background.
    const eye = Offset(BrandMark.eyeX, BrandMark.eyeY);
    canvas
      ..drawCircle(eye, BrandMark.eyeHoleRadius, Paint()..blendMode = BlendMode.clear)
      ..drawCircle(eye, BrandMark.eyePupilRadius, bodyPaint)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _HummingbirdPainter oldDelegate) =>
      oldDelegate.bodyColor != bodyColor || oldDelegate.accentColor != accentColor;
}

/// Parsed geometry, kept between paints: the mark never changes shape, only
/// colour and scale.
final Map<String, Path> _pathCache = <String, Path>{};

Path _pathFor(MarkPath shape) => _pathCache.putIfAbsent(shape.id, () {
  final builder = _PathBuilder();
  writeSvgPath(shape.data, builder);
  return builder.path;
});

/// Replays the shared SVG path data onto a Flutter [Path].
class _PathBuilder implements PathSink {
  final Path path = Path();

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x, double y) =>
      path.cubicTo(x1, y1, x2, y2, x, y);

  @override
  void quadraticBezierTo(double x1, double y1, double x, double y) =>
      path.quadraticBezierTo(x1, y1, x, y);

  @override
  void close() => path.close();
}
