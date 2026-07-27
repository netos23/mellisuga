/// Print sizes live in `package:mellisuga_content` so the landing site can list
/// exactly the presets the picker offers.
///
/// The re-export keeps every existing import inside the app working.
library;

export 'package:mellisuga_content/mellisuga_content.dart'
    show PhotoPrintSize, PhotoSizePreset, PhotoSizePresets;
