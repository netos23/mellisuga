/// Paper formats live in `package:mellisuga_content` so the landing site can
/// publish the same catalogue the app offers, down to the millimetre.
///
/// The re-export keeps every existing import inside the app working.
export 'package:mellisuga_content/mellisuga_content.dart'
    show PageOrientation, PaperFormat, PaperFormats;
