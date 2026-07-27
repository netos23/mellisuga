import 'package:meta/meta.dart';

import 'faq.dart';

/// Whether a tool is finished or still on the roadmap.
enum ToolStatus {
  available('Available'),
  comingSoon('Coming soon');

  const ToolStatus(this.label);

  final String label;

  bool get isAvailable => this == ToolStatus.available;
}

/// Top-level grouping shown in the app's navigation and as sections on the
/// landing page.
enum ToolCategory {
  photos('photos', 'Photos', 'Everything that happens before a photo reaches paper.'),
  documents('documents', 'Documents', 'PDF surgery: merge, split, reorder, stamp.'),
  convert('convert', 'Convert', 'Move between formats without a round trip to a server.');

  const ToolCategory(this.id, this.label, this.blurb);

  /// Stable identifier, used in URLs and anchors.
  final String id;

  final String label;

  /// One line introducing the category on the landing page.
  final String blurb;
}

/// One utility, described once for every surface that talks about it.
///
/// The app turns these into cards, navigation entries and search results; the
/// landing site turns them into sections and a page each. Adding a tool means
/// adding an entry here, an icon and a builder in the app, and nothing at all
/// on the site.
@immutable
class ToolInfo {
  const ToolInfo({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    this.status = ToolStatus.comingSoon,
    this.highlights = const <String>[],
    this.keywords = const <String>[],
    this.overview = const <String>[],
    this.faqs = const <FaqEntry>[],
    this.searchSummary,
  });

  /// Stable identifier: the app's route (`/tool/<id>`) and the site's
  /// directory (`/tools/<id>/`).
  final String id;

  final String title;

  /// One-line description shown on cards, in the drawer and as the default
  /// meta description.
  final String summary;

  final ToolCategory category;

  final ToolStatus status;

  /// Bullet points describing what the tool does.
  final List<String> highlights;

  /// Extra search terms, so "combine" finds the merge tool — and so the site
  /// has honest keyword coverage without stuffing the prose.
  final List<String> keywords;

  /// Body copy for the tool's own page on the site. Empty for tools whose
  /// summary and highlights already say everything.
  final List<String> overview;

  final List<FaqEntry> faqs;

  /// Replaces [summary] as the page's meta description when the tool deserves
  /// a longer, more search-oriented sentence.
  final String? searchSummary;

  /// Meta description for the tool's page, at most ~160 characters.
  String get metaDescription => searchSummary ?? summary;

  /// Path of this tool's page on the landing site, relative to the site root.
  String get path => 'tools/$id/';

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

/// The catalogue of every tool the project knows about.
abstract final class ToolCatalog {
  static const List<ToolInfo> tools = <ToolInfo>[
    ToolInfo(
      id: 'photo-compose',
      title: 'Compose photos for print',
      summary: 'Pack photos of any size onto Letter, A4, A3 or photo paper with no wasted space.',
      searchSummary:
          'Fit passport, wallet and 10 × 15 cm photos onto one sheet of A4, '
          'Letter or photo paper, then export a PDF. Free, and nothing is uploaded.',
      category: ToolCategory.photos,
      status: ToolStatus.available,
      highlights: [
        'Pick a print size per photo, or use passport and wallet presets',
        'Crop, rotate, flip and annotate before printing',
        'Automatic bin packing fills each sheet, then starts a new one',
        'Cut lines, crop marks, margins and spacing are all configurable',
        'Export to PDF or PNG, or send straight to a printer',
      ],
      keywords: [
        'collage',
        'sheet',
        'layout',
        'passport',
        'contact sheet',
        'print',
        'photo sheet maker',
        'multiple photos on one page',
        'id photo template',
      ],
      overview: [
        'Photo labs charge per print, and printing one 35 × 45 mm passport photo '
            'in the middle of an A4 sheet wastes the other 95% of the paper. '
            'Compose photos for print solves the packing problem instead: tell it '
            'how big each photo should come out, and it arranges as many as will '
            'fit on the sheet you actually own.',
        'The packer is a MaxRects implementation. It places large photos first, '
            'backfills the gaps with smaller ones, turns a photo 90° when that '
            'saves paper, and only starts a second page once the first is '
            'genuinely full. Every measurement is held in millimetres, so an A4 '
            'sheet exported at 300 DPI comes out at exactly 2480 × 3508 pixels '
            'and a passport photo measures 35 × 45 mm under a ruler.',
        'Editing is non-destructive and lives entirely in the preview: crop with '
            'an aspect lock, rotate in quarter turns, flip, or draw on a photo, '
            'and the sheet re-packs as you go. Pixels are only ever re-encoded '
            'when you export.',
      ],
      faqs: [
        FaqEntry(
          question: 'How do I print several passport photos on one sheet?',
          answer:
              'Add your photo, set its print size to 35 × 45 mm, then duplicate '
              'it until the sheet is full — or add it once and let the packer '
              'repeat it across the page. Choose A4 or 10 × 15 cm paper, turn on '
              'cut lines, and export a PDF to take to any printer.',
        ),
        FaqEntry(
          question: 'Will the printed photos be exactly the size I asked for?',
          answer:
              'Yes, provided you turn off "fit to page", "scale to fit" and '
              'borderless printing in your printer dialog. The PDF is generated at '
              'exact physical dimensions, so any scaling the driver applies is '
              'scaling you asked for.',
        ),
        FaqEntry(
          question: 'What resolution do I need?',
          answer:
              'At least 150 DPI at the printed size, and 300 DPI for anything you '
              'will look at closely. The app warns you when a photo would print '
              'below 150 DPI, so you find out before the paper is gone.',
        ),
      ],
    ),
    ToolInfo(
      id: 'images-to-pdf',
      title: 'Images to PDF',
      summary: 'Turn a folder of images into a single paginated PDF document.',
      category: ToolCategory.convert,
      highlights: [
        'One image per page, scaled to fit',
        'Choose page size, orientation and margins',
        'Reorder pages before exporting',
      ],
      keywords: ['convert', 'jpg to pdf', 'png to pdf', 'scan to pdf'],
      overview: [
        'Scans, receipts and phone photos arrive as a pile of JPEGs and have to '
            'leave as one document. This tool will stack them into a single PDF at '
            'the page size you choose, in the order you put them in, without '
            'sending anything to a conversion service.',
      ],
    ),
    ToolInfo(
      id: 'pdf-merge',
      title: 'Merge PDFs',
      summary: 'Combine several PDF files into one, in the order you choose.',
      category: ToolCategory.documents,
      highlights: ['Drag to reorder documents', 'Preview every page before merging'],
      keywords: ['combine', 'join', 'append', 'merge pdf offline'],
      overview: [
        'Merging PDFs is the most common reason people upload private documents '
            'to a random website. It is also pure arithmetic on a file you already '
            'have, which is why this one will run in the tab you already have open.',
      ],
    ),
    ToolInfo(
      id: 'pdf-split',
      title: 'Split PDF',
      summary: 'Extract pages or break one document into several files.',
      category: ToolCategory.documents,
      highlights: ['Select page ranges visually', 'Split every N pages, or at bookmarks'],
      keywords: ['extract', 'separate', 'pages', 'split pdf offline'],
      overview: [
        'Pull a single signed page out of a contract, or cut a 200-page scan into '
            'chapters. Pages are selected visually, and what comes out is a plain '
            'PDF with nothing added to it.',
      ],
    ),
    ToolInfo(
      id: 'pdf-to-images',
      title: 'PDF to images',
      summary: 'Render each page of a PDF to PNG or JPEG at a resolution you pick.',
      category: ToolCategory.convert,
      highlights: ['Choose DPI per export', 'Export a page range or the whole document'],
      keywords: ['rasterise', 'render', 'export', 'pdf to jpg', 'pdf to png'],
      overview: [
        'Sometimes a page has to become a picture — for a slide, a listing or a '
            'printer that will not take PDFs. Pick a DPI, pick a range, and get '
            'one image per page.',
      ],
    ),
    ToolInfo(
      id: 'image-resize',
      title: 'Resize & convert images',
      summary: 'Batch resize, crop and convert between JPEG, PNG and WebP.',
      category: ToolCategory.photos,
      highlights: ['Resize by pixels, percentage or print size', 'Strip metadata on the way out'],
      keywords: ['scale', 'compress', 'webp', 'jpeg', 'png', 'batch resize'],
      overview: [
        'Resize a folder of photos to fit an upload limit, convert them to WebP, '
            'and drop the EXIF metadata — including the GPS coordinates of your '
            'front door — before they go anywhere.',
      ],
    ),
    ToolInfo(
      id: 'pdf-organise',
      title: 'Rotate & reorder pages',
      summary: 'Fix page order and orientation without leaving the browser.',
      category: ToolCategory.documents,
      highlights: ['Rotate individual pages or the whole document', 'Delete and duplicate pages'],
      keywords: ['rotate', 'reorder', 'delete pages', 'organise pdf'],
      overview: [
        'Every double-sided scan produces a document with half its pages upside '
            'down and in the wrong order. This is the tool that puts them right.',
      ],
    ),
    ToolInfo(
      id: 'watermark',
      title: 'Watermark',
      summary: 'Stamp text or an image across pages and photos.',
      searchSummary:
          'Stamp text or an image across PDF pages and photos, tiled or once, '
          'with control over opacity, rotation and colour. Nothing is uploaded.',
      category: ToolCategory.documents,
      highlights: ['Tiled or single placement', 'Control opacity, rotation and colour'],
      keywords: ['stamp', 'overlay', 'copyright', 'draft watermark'],
      overview: [
        'Mark a document DRAFT, or put your name across a photo before it goes '
            'out. Placement, opacity and rotation are yours to set, and the file '
            'never leaves the device it is on.',
      ],
    ),
  ];

  /// Tools that are actually usable today.
  static List<ToolInfo> get available =>
      tools.where((tool) => tool.status.isAvailable).toList(growable: false);

  /// Tools still on the roadmap.
  static List<ToolInfo> get roadmap =>
      tools.where((tool) => !tool.status.isAvailable).toList(growable: false);

  static ToolInfo? byId(String id) {
    for (final tool in tools) {
      if (tool.id == id) return tool;
    }
    return null;
  }

  /// The tool the app opens into, and the one the site leads with.
  static ToolInfo get flagship => byId('photo-compose') ?? tools.first;

  static List<ToolInfo> inCategory(ToolCategory category) =>
      tools.where((tool) => tool.category == category).toList(growable: false);

  static List<ToolInfo> search(String query) =>
      tools.where((tool) => tool.matches(query)).toList(growable: false);
}
