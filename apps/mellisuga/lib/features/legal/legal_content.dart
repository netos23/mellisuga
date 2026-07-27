/// The legal documents live in `package:mellisuga_content`, so the screens in
/// the app and the pages on the landing site render the same words from the
/// same source.
///
/// The re-export keeps every existing import inside the app working.
library;

export 'package:mellisuga_content/mellisuga_content.dart'
    show LegalContent, LegalDocument, LegalSection;
