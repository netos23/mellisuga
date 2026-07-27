import 'package:flutter/material.dart';

/// Whether a tool is finished or still on the roadmap.
enum ToolStatus {
  available,
  comingSoon;

  bool get isAvailable => this == ToolStatus.available;
}

/// Top-level grouping shown in the navigation and on the home screen.
enum ToolCategory {
  photos('Photos', Icons.photo_library_outlined),
  documents('Documents', Icons.picture_as_pdf_outlined),
  convert('Convert', Icons.swap_horiz_rounded);

  const ToolCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// One utility in the app.
///
/// Adding a tool is meant to be a one-file change: describe it here, register
/// it in `ToolRegistry`, and the home screen, navigation rail, drawer, search
/// and routing all pick it up automatically.
@immutable
class ToolDefinition {
  const ToolDefinition({
    required this.id,
    required this.title,
    required this.summary,
    required this.icon,
    required this.category,
    this.status = ToolStatus.comingSoon,
    this.builder,
    this.highlights = const <String>[],
    this.keywords = const <String>[],
  }) : assert(
         status != ToolStatus.available || builder != null,
         'An available tool must provide a builder',
       );

  /// Stable identifier, also used as the route name (`/tool/<id>`).
  final String id;

  final String title;

  /// One-line description shown on cards and in the drawer.
  final String summary;

  final IconData icon;

  final ToolCategory category;

  final ToolStatus status;

  /// Builds the tool's screen. Required when [status] is available.
  final WidgetBuilder? builder;

  /// Bullet points describing what the tool does, shown on its card and on the
  /// placeholder page for tools that are not built yet.
  final List<String> highlights;

  /// Extra search terms so "combine" finds the merge tool.
  final List<String> keywords;

  String get route => '/tool/$id';

  /// Whether this tool matches a free-text [query].
  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    if (title.toLowerCase().contains(needle)) return true;
    if (summary.toLowerCase().contains(needle)) return true;
    if (category.label.toLowerCase().contains(needle)) return true;
    return keywords.any((keyword) => keyword.toLowerCase().contains(needle));
  }
}
