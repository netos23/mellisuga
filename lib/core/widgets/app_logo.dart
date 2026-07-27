import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_info.dart';
import '../theme/app_theme.dart';

/// The Mellisuga mark: a hummingbird in flight, drawn as vector paths so it
/// stays sharp at every size and adapts to the current theme.
///
/// `Mellisuga helenae` is the bee hummingbird — the smallest bird there is, and
/// a fitting mascot for tools that do a lot in very little space.
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
    // The mark is authored on a 100 × 100 grid and scaled to fit.
    final scale = math.min(size.width, size.height) / 100;
    // A layer is required so the eye's `BlendMode.clear` punches through the
    // mark only, rather than erasing whatever is painted behind the widget.
    canvas
      ..saveLayer(Offset.zero & size, Paint())
      ..translate((size.width - 100 * scale) / 2, (size.height - 100 * scale) / 2)
      ..scale(scale);

    final bodyPaint = Paint()
      ..color = bodyColor
      ..isAntiAlias = true;
    final accentPaint = Paint()
      ..color = accentColor
      ..isAntiAlias = true;

    // Tail: two swept feathers trailing to the lower left.
    final tail = Path()
      ..moveTo(38, 62)
      ..quadraticBezierTo(24, 72, 6, 88)
      ..quadraticBezierTo(20, 82, 30, 78)
      ..quadraticBezierTo(22, 86, 16, 96)
      ..quadraticBezierTo(34, 82, 48, 74)
      ..close();
    canvas.drawPath(tail, bodyPaint);

    // Body: a teardrop running from the head down to where the tail starts.
    final body = Path()
      ..moveTo(64, 30)
      ..cubicTo(74, 34, 76, 46, 68, 55)
      ..cubicTo(60, 64, 48, 70, 38, 71)
      ..cubicTo(36, 60, 40, 46, 50, 36)
      ..cubicTo(54, 32, 59, 29, 64, 30)
      ..close();
    canvas.drawPath(body, bodyPaint);

    // Beak: a long, fine taper — the hummingbird's signature.
    final beak = Path()
      ..moveTo(69, 29)
      ..lineTo(99, 15)
      ..lineTo(70, 36)
      ..close();
    canvas.drawPath(beak, bodyPaint);

    // Throat patch, in the iridescent accent colour.
    final throat = Path()
      ..moveTo(66, 34)
      ..cubicTo(73, 38, 73, 47, 66, 52)
      ..cubicTo(62, 46, 62, 39, 66, 34)
      ..close();
    canvas.drawPath(throat, accentPaint);

    // Upstroke wing, drawn last so it reads as the nearest element.
    final wing = Path()
      ..moveTo(52, 40)
      ..cubicTo(50, 22, 34, 8, 12, 6)
      ..cubicTo(26, 22, 32, 40, 42, 54)
      ..cubicTo(46, 51, 50, 46, 52, 40)
      ..close();
    canvas.drawPath(wing, accentPaint);

    // Eye, punched out of the body so it works on any background.
    canvas.drawCircle(const Offset(64, 37), 3.2, Paint()..blendMode = BlendMode.clear);
    canvas.drawCircle(const Offset(64, 37), 2.0, bodyPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HummingbirdPainter oldDelegate) =>
      oldDelegate.bodyColor != bodyColor || oldDelegate.accentColor != accentColor;
}
