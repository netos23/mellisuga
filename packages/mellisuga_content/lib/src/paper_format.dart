import 'package:meta/meta.dart';

/// How a sheet is oriented relative to its nominal dimensions.
enum PageOrientation {
  portrait('Portrait'),
  landscape('Landscape');

  const PageOrientation(this.label);

  final String label;
}

/// A sheet of paper, described by its nominal (portrait) size in millimetres.
@immutable
class PaperFormat {
  const PaperFormat({
    required this.id,
    required this.name,
    required this.widthMm,
    required this.heightMm,
    this.group = 'Other',
  });

  /// Stable identifier used when persisting a project.
  final String id;

  /// Display name, e.g. `A4`.
  final String name;

  /// Nominal short edge in millimetres.
  final double widthMm;

  /// Nominal long edge in millimetres.
  final double heightMm;

  /// Menu grouping, e.g. `ISO A` or `North America`.
  final String group;

  /// Returns the sheet size for [orientation] as `(width, height)`.
  ({double width, double height}) sizeFor(PageOrientation orientation) =>
      orientation == PageOrientation.portrait
      ? (width: widthMm, height: heightMm)
      : (width: heightMm, height: widthMm);

  PaperFormat copyWith({String? id, String? name, double? widthMm, double? heightMm}) {
    return PaperFormat(
      id: id ?? this.id,
      name: name ?? this.name,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      group: group,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'widthMm': widthMm,
    'heightMm': heightMm,
    'group': group,
  };

  factory PaperFormat.fromJson(Map<String, dynamic> json) => PaperFormat(
    id: json['id'] as String? ?? 'custom',
    name: json['name'] as String? ?? 'Custom',
    widthMm: (json['widthMm'] as num).toDouble(),
    heightMm: (json['heightMm'] as num).toDouble(),
    group: json['group'] as String? ?? 'Custom',
  );

  @override
  bool operator ==(Object other) =>
      other is PaperFormat &&
      other.id == id &&
      other.widthMm == widthMm &&
      other.heightMm == heightMm;

  @override
  int get hashCode => Object.hash(id, widthMm, heightMm);
}

/// The built-in catalogue of print formats.
abstract final class PaperFormats {
  static const a3 = PaperFormat(id: 'a3', name: 'A3', widthMm: 297, heightMm: 420, group: 'ISO A');
  static const a4 = PaperFormat(id: 'a4', name: 'A4', widthMm: 210, heightMm: 297, group: 'ISO A');
  static const a5 = PaperFormat(id: 'a5', name: 'A5', widthMm: 148, heightMm: 210, group: 'ISO A');
  static const a6 = PaperFormat(id: 'a6', name: 'A6', widthMm: 105, heightMm: 148, group: 'ISO A');
  static const a2 = PaperFormat(id: 'a2', name: 'A2', widthMm: 420, heightMm: 594, group: 'ISO A');

  static const b4 = PaperFormat(id: 'b4', name: 'B4', widthMm: 250, heightMm: 353, group: 'ISO B');
  static const b5 = PaperFormat(id: 'b5', name: 'B5', widthMm: 176, heightMm: 250, group: 'ISO B');

  static const letter = PaperFormat(
    id: 'letter',
    name: 'Letter',
    widthMm: 215.9,
    heightMm: 279.4,
    group: 'North America',
  );
  static const legal = PaperFormat(
    id: 'legal',
    name: 'Legal',
    widthMm: 215.9,
    heightMm: 355.6,
    group: 'North America',
  );
  static const tabloid = PaperFormat(
    id: 'tabloid',
    name: 'Tabloid',
    widthMm: 279.4,
    heightMm: 431.8,
    group: 'North America',
  );
  static const executive = PaperFormat(
    id: 'executive',
    name: 'Executive',
    widthMm: 184.15,
    heightMm: 266.7,
    group: 'North America',
  );

  static const photo10x15 = PaperFormat(
    id: 'photo_10x15',
    name: '10 × 15 cm',
    widthMm: 100,
    heightMm: 150,
    group: 'Photo paper',
  );
  static const photo13x18 = PaperFormat(
    id: 'photo_13x18',
    name: '13 × 18 cm',
    widthMm: 130,
    heightMm: 180,
    group: 'Photo paper',
  );
  static const photo4x6 = PaperFormat(
    id: 'photo_4x6',
    name: '4 × 6 in',
    widthMm: 101.6,
    heightMm: 152.4,
    group: 'Photo paper',
  );
  static const photo5x7 = PaperFormat(
    id: 'photo_5x7',
    name: '5 × 7 in',
    widthMm: 127,
    heightMm: 177.8,
    group: 'Photo paper',
  );
  static const photo8x10 = PaperFormat(
    id: 'photo_8x10',
    name: '8 × 10 in',
    widthMm: 203.2,
    heightMm: 254,
    group: 'Photo paper',
  );

  /// Every built-in format, in menu order.
  static const List<PaperFormat> all = [
    a2,
    a3,
    a4,
    a5,
    a6,
    b4,
    b5,
    letter,
    legal,
    tabloid,
    executive,
    photo10x15,
    photo13x18,
    photo4x6,
    photo5x7,
    photo8x10,
  ];

  /// Formats bucketed by [PaperFormat.group], preserving menu order.
  static Map<String, List<PaperFormat>> get grouped {
    final result = <String, List<PaperFormat>>{};
    for (final format in all) {
      result.putIfAbsent(format.group, () => <PaperFormat>[]).add(format);
    }
    return result;
  }

  static PaperFormat? byId(String id) {
    for (final format in all) {
      if (format.id == id) return format;
    }
    return null;
  }
}
