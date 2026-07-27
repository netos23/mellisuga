import 'package:flutter/material.dart';

import '../../features/photo_compose/ui/photo_compose_page.dart';
import '../../features/tool_placeholder/tool_placeholder_page.dart';
import 'tool_definition.dart';

/// The catalogue of every tool the app knows about.
///
/// This is the single place new utilities get wired in. Everything that lists,
/// searches or routes to a tool reads from here.
abstract final class ToolRegistry {
  static final List<ToolDefinition> tools = <ToolDefinition>[
    ToolDefinition(
      id: 'photo-compose',
      title: 'Compose photos for print',
      summary: 'Pack photos of any size onto Letter, A4, A3 or photo paper with no wasted space.',
      icon: Icons.grid_view_rounded,
      category: ToolCategory.photos,
      status: ToolStatus.available,
      builder: (context) => const PhotoComposePage(),
      highlights: [
        'Pick a print size per photo, or use passport and wallet presets',
        'Crop, rotate, flip and annotate before printing',
        'Automatic bin packing fills each sheet, then starts a new one',
        'Cut lines, crop marks, margins and spacing are all configurable',
        'Export to PDF or PNG, or send straight to a printer',
      ],
      keywords: ['collage', 'sheet', 'layout', 'passport', 'contact sheet', 'print'],
    ),
    const ToolDefinition(
      id: 'images-to-pdf',
      title: 'Images to PDF',
      summary: 'Turn a folder of images into a single paginated PDF document.',
      icon: Icons.picture_as_pdf_outlined,
      category: ToolCategory.convert,
      highlights: [
        'One image per page, scaled to fit',
        'Choose page size, orientation and margins',
        'Reorder pages before exporting',
      ],
      keywords: ['convert', 'jpg to pdf', 'png to pdf'],
    ),
    const ToolDefinition(
      id: 'pdf-merge',
      title: 'Merge PDFs',
      summary: 'Combine several PDF files into one, in the order you choose.',
      icon: Icons.merge_type_rounded,
      category: ToolCategory.documents,
      highlights: ['Drag to reorder documents', 'Preview every page before merging'],
      keywords: ['combine', 'join', 'append'],
    ),
    const ToolDefinition(
      id: 'pdf-split',
      title: 'Split PDF',
      summary: 'Extract pages or break one document into several files.',
      icon: Icons.call_split_rounded,
      category: ToolCategory.documents,
      highlights: ['Select page ranges visually', 'Split every N pages, or at bookmarks'],
      keywords: ['extract', 'separate', 'pages'],
    ),
    const ToolDefinition(
      id: 'pdf-to-images',
      title: 'PDF to images',
      summary: 'Render each page of a PDF to PNG or JPEG at a resolution you pick.',
      icon: Icons.image_outlined,
      category: ToolCategory.convert,
      highlights: ['Choose DPI per export', 'Export a page range or the whole document'],
      keywords: ['rasterise', 'render', 'export'],
    ),
    const ToolDefinition(
      id: 'image-resize',
      title: 'Resize & convert images',
      summary: 'Batch resize, crop and convert between JPEG, PNG and WebP.',
      icon: Icons.photo_size_select_large_rounded,
      category: ToolCategory.photos,
      highlights: ['Resize by pixels, percentage or print size', 'Strip metadata on the way out'],
      keywords: ['scale', 'compress', 'webp', 'jpeg', 'png'],
    ),
    const ToolDefinition(
      id: 'pdf-organise',
      title: 'Rotate & reorder pages',
      summary: 'Fix page order and orientation without leaving the browser.',
      icon: Icons.rotate_90_degrees_ccw_rounded,
      category: ToolCategory.documents,
      highlights: ['Rotate individual pages or the whole document', 'Delete and duplicate pages'],
      keywords: ['rotate', 'reorder', 'delete pages'],
    ),
    const ToolDefinition(
      id: 'watermark',
      title: 'Watermark',
      summary: 'Stamp text or an image across pages and photos.',
      icon: Icons.branding_watermark_outlined,
      category: ToolCategory.documents,
      highlights: ['Tiled or single placement', 'Control opacity, rotation and colour'],
      keywords: ['stamp', 'overlay', 'copyright'],
    ),
  ];

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
  static ToolDefinition get defaultTool => byId('photo-compose') ?? tools.first;

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
