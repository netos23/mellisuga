import 'package:flutter/material.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

export 'package:mellisuga_content/mellisuga_content.dart' show ToolCategory, ToolInfo, ToolStatus;

/// The icon each category is drawn with.
///
/// Icons live here rather than in the shared catalogue because `IconData` is a
/// Flutter type, and the landing site — which reads the same catalogue — has no
/// use for one.
extension ToolCategoryIcon on ToolCategory {
  IconData get icon => switch (this) {
    ToolCategory.photos => Icons.photo_library_outlined,
    ToolCategory.documents => Icons.picture_as_pdf_outlined,
    ToolCategory.convert => Icons.swap_horiz_rounded,
  };
}

/// One utility as the app sees it: everything the shared catalogue knows about
/// it, plus the two things only a Flutter app can hold — an icon and a screen.
///
/// Adding a tool is meant to be a small change: describe it in `ToolCatalog`
/// (shared with the landing site), then give it an icon and a builder in
/// `ToolRegistry`. The home screen, navigation rail, drawer, search and routing
/// all pick it up automatically.
@immutable
class ToolDefinition {
  ToolDefinition({required this.info, required this.icon, this.builder})
    : assert(
        info.status != ToolStatus.available || builder != null,
        'An available tool must provide a builder',
      );

  /// Title, summary, highlights and keywords — the same copy the site shows.
  final ToolInfo info;

  final IconData icon;

  /// Builds the tool's screen. Required when the status is available.
  final WidgetBuilder? builder;

  String get id => info.id;

  String get title => info.title;

  String get summary => info.summary;

  ToolCategory get category => info.category;

  ToolStatus get status => info.status;

  List<String> get highlights => info.highlights;

  List<String> get keywords => info.keywords;

  /// Route name inside the app.
  String get route => '/tool/${info.id}';

  /// Whether this tool matches a free-text [query].
  bool matches(String query) => info.matches(query);
}
