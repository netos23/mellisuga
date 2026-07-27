import 'package:flutter/material.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

import '../../features/photo_compose/ui/photo_compose_page.dart';
import '../../features/tool_placeholder/tool_placeholder_page.dart';
import 'tool_definition.dart';

/// The app's view of the tool catalogue.
///
/// What each tool *is* lives in `ToolCatalog`, shared with the landing site so
/// the two can never disagree. What each tool *looks like* and *opens into*
/// lives here, because icons and screens do not exist outside Flutter.
///
/// Everything that lists, searches or routes to a tool reads from here.
abstract final class ToolRegistry {
  /// Icon per tool id. A tool without an entry falls back to its category's
  /// icon rather than disappearing from the gallery.
  static const Map<String, IconData> _icons = <String, IconData>{
    'photo-compose': Icons.grid_view_rounded,
    'images-to-pdf': Icons.picture_as_pdf_outlined,
    'pdf-merge': Icons.merge_type_rounded,
    'pdf-split': Icons.call_split_rounded,
    'pdf-to-images': Icons.image_outlined,
    'image-resize': Icons.photo_size_select_large_rounded,
    'pdf-organise': Icons.rotate_90_degrees_ccw_rounded,
    'watermark': Icons.branding_watermark_outlined,
  };

  /// Screen per tool id. Anything missing here is still on the roadmap and
  /// renders the placeholder page instead.
  static final Map<String, WidgetBuilder> _builders = <String, WidgetBuilder>{
    'photo-compose': (context) => const PhotoComposePage(),
  };

  static final List<ToolDefinition> tools = ToolCatalog.tools
      .map(
        (info) => ToolDefinition(
          info: info,
          icon: _icons[info.id] ?? info.category.icon,
          builder: _builders[info.id],
        ),
      )
      .toList(growable: false);

  /// Tools that are actually usable today.
  static List<ToolDefinition> get available =>
      tools.where((tool) => tool.status.isAvailable).toList(growable: false);

  static ToolDefinition? byId(String id) {
    for (final tool in tools) {
      if (tool.id == id) return tool;
    }
    return null;
  }

  /// The tool the app opens into.
  static ToolDefinition get defaultTool => byId(ToolCatalog.flagship.id) ?? tools.first;

  static List<ToolDefinition> inCategory(ToolCategory category) =>
      tools.where((tool) => tool.category == category).toList(growable: false);

  static List<ToolDefinition> search(String query) =>
      tools.where((tool) => tool.matches(query)).toList(growable: false);

  /// Builds the screen for [tool], falling back to the roadmap placeholder for
  /// anything not implemented yet.
  static Widget buildScreen(BuildContext context, ToolDefinition tool) {
    final builder = tool.builder;
    if (tool.status.isAvailable && builder != null) return builder(context);
    return ToolPlaceholderPage(tool: tool);
  }
}
