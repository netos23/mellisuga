import 'package:meta/meta.dart';

/// A physical size a single photo should be printed at.
///
/// Sizes are always stored in millimetres. [width] and [height] describe the
/// print as the user configured it; the layout engine may still rotate the
/// photo by 90° on the sheet when that packs better and rotation is allowed.
@immutable
class PhotoPrintSize {
  const PhotoPrintSize({required this.widthMm, required this.heightMm, this.presetId});

  final double widthMm;
  final double heightMm;

  /// Set when the size came from [PhotoSizePresets]; `null` for custom sizes.
  final String? presetId;

  double get aspectRatio => widthMm / heightMm;

  bool get isLandscape => widthMm > heightMm;

  /// The same physical size with the two edges swapped.
  PhotoPrintSize get swapped =>
      PhotoPrintSize(widthMm: heightMm, heightMm: widthMm, presetId: presetId);

  PhotoPrintSize copyWith({double? widthMm, double? heightMm, String? presetId}) {
    return PhotoPrintSize(
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      presetId: presetId,
    );
  }

  Map<String, dynamic> toJson() => {
    'widthMm': widthMm,
    'heightMm': heightMm,
    if (presetId != null) 'presetId': presetId,
  };

  factory PhotoPrintSize.fromJson(Map<String, dynamic> json) => PhotoPrintSize(
    widthMm: (json['widthMm'] as num).toDouble(),
    heightMm: (json['heightMm'] as num).toDouble(),
    presetId: json['presetId'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is PhotoPrintSize && other.widthMm == widthMm && other.heightMm == heightMm;

  @override
  int get hashCode => Object.hash(widthMm, heightMm);
}

/// A named photo size offered in the size picker.
@immutable
class PhotoSizePreset {
  const PhotoSizePreset({
    required this.id,
    required this.name,
    required this.widthMm,
    required this.heightMm,
    required this.group,
  });

  final String id;
  final String name;
  final double widthMm;
  final double heightMm;
  final String group;

  PhotoPrintSize get size => PhotoPrintSize(widthMm: widthMm, heightMm: heightMm, presetId: id);
}

/// Common print sizes, from ID photos through to large prints.
abstract final class PhotoSizePresets {
  static const List<PhotoSizePreset> all = [
    // Documents and IDs.
    PhotoSizePreset(
      id: 'id_35x45',
      name: '35 × 45 mm (passport)',
      widthMm: 35,
      heightMm: 45,
      group: 'Documents',
    ),
    PhotoSizePreset(
      id: 'id_30x40',
      name: '30 × 40 mm',
      widthMm: 30,
      heightMm: 40,
      group: 'Documents',
    ),
    PhotoSizePreset(
      id: 'id_50x70',
      name: '50 × 70 mm',
      widthMm: 50,
      heightMm: 70,
      group: 'Documents',
    ),
    PhotoSizePreset(
      id: 'id_us_2x2',
      name: '2 × 2 in (US visa)',
      widthMm: 50.8,
      heightMm: 50.8,
      group: 'Documents',
    ),

    // Metric photo prints.
    PhotoSizePreset(
      id: 'p_9x13',
      name: '9 × 13 cm',
      widthMm: 90,
      heightMm: 130,
      group: 'Metric prints',
    ),
    PhotoSizePreset(
      id: 'p_10x15',
      name: '10 × 15 cm',
      widthMm: 100,
      heightMm: 150,
      group: 'Metric prints',
    ),
    PhotoSizePreset(
      id: 'p_13x18',
      name: '13 × 18 cm',
      widthMm: 130,
      heightMm: 180,
      group: 'Metric prints',
    ),
    PhotoSizePreset(
      id: 'p_15x21',
      name: '15 × 21 cm',
      widthMm: 150,
      heightMm: 210,
      group: 'Metric prints',
    ),
    PhotoSizePreset(
      id: 'p_20x30',
      name: '20 × 30 cm',
      widthMm: 200,
      heightMm: 300,
      group: 'Metric prints',
    ),

    // Imperial photo prints.
    PhotoSizePreset(
      id: 'p_wallet',
      name: '2.5 × 3.5 in (wallet)',
      widthMm: 63.5,
      heightMm: 88.9,
      group: 'Imperial prints',
    ),
    PhotoSizePreset(
      id: 'p_3_5x5',
      name: '3.5 × 5 in',
      widthMm: 88.9,
      heightMm: 127,
      group: 'Imperial prints',
    ),
    PhotoSizePreset(
      id: 'p_4x6',
      name: '4 × 6 in',
      widthMm: 101.6,
      heightMm: 152.4,
      group: 'Imperial prints',
    ),
    PhotoSizePreset(
      id: 'p_5x7',
      name: '5 × 7 in',
      widthMm: 127,
      heightMm: 177.8,
      group: 'Imperial prints',
    ),
    PhotoSizePreset(
      id: 'p_8x10',
      name: '8 × 10 in',
      widthMm: 203.2,
      heightMm: 254,
      group: 'Imperial prints',
    ),

    // Square formats.
    PhotoSizePreset(id: 's_50', name: '5 × 5 cm', widthMm: 50, heightMm: 50, group: 'Square'),
    PhotoSizePreset(id: 's_100', name: '10 × 10 cm', widthMm: 100, heightMm: 100, group: 'Square'),
  ];

  static PhotoSizePreset? byId(String id) {
    for (final preset in all) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  static Map<String, List<PhotoSizePreset>> get grouped {
    final result = <String, List<PhotoSizePreset>>{};
    for (final preset in all) {
      result.putIfAbsent(preset.group, () => <PhotoSizePreset>[]).add(preset);
    }
    return result;
  }

  static PhotoPrintSize get defaultSize => byId('p_10x15')!.size;
}
