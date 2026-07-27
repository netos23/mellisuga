import 'package:flutter/material.dart';

/// Layout sizes the UI adapts to.
enum ScreenSize {
  /// Phones and narrow windows: one thing on screen at a time.
  compact,

  /// Tablets and split-screen desktop: preview plus one side panel.
  medium,

  /// Desktop: preview plus both side panels.
  expanded;

  bool get isCompact => this == ScreenSize.compact;

  bool get isMedium => this == ScreenSize.medium;

  bool get isExpanded => this == ScreenSize.expanded;

  bool get hasSidePanels => this != ScreenSize.compact;
}

/// Breakpoints and helpers for responsive layout.
abstract final class Breakpoints {
  static const double medium = 720;
  static const double expanded = 1180;

  /// The width past which a navigation rail shows its labels inline.
  static const double extendedRail = 1440;

  static ScreenSize of(BuildContext context) => fromWidth(MediaQuery.sizeOf(context).width);

  static ScreenSize fromWidth(double width) {
    if (width >= expanded) return ScreenSize.expanded;
    if (width >= medium) return ScreenSize.medium;
    return ScreenSize.compact;
  }
}

/// Rebuilds its child whenever the screen size bucket changes.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ScreenSize size) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, Breakpoints.fromWidth(constraints.maxWidth)),
    );
  }
}

/// Caps content width and centres it, so long text stays readable on very wide
/// displays.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({
    super.key,
    required this.child,
    this.maxWidth = 760,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
