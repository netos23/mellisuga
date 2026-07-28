import '../../tool_catalog.dart';
import '../brand_i18n.dart';
import '../faq_i18n.dart';
import '../tool_catalog_i18n.dart';

/// German translations: tool catalogue, category/status labels,
/// general FAQ and brand copy.
const Map<String, ToolTranslation> toolCatalogDe = <String, ToolTranslation>{
  'photo-compose': ToolTranslation(
    title: 'Fotos für den Druck zusammenstellen',
    summary: 'Fotos jeder Größe ohne Verschnitt auf Letter-, A4-, A3- oder Fotopapier packen.',
    highlights: <String>[
      'Für jedes Foto eine Druckgröße wählen oder Pass- und Brieftaschen-Voreinstellungen '
          'nutzen',
      'Vor dem Drucken zuschneiden, drehen, spiegeln und beschriften',
      'Automatisches Bin-Packing füllt jedes Blatt, bevor ein neues beginnt',
      'Schnittlinien, Passermarken, Ränder und Abstände sind alle einstellbar',
      'Export als PDF oder PNG, oder direkt an einen Drucker senden',
    ],
    searchSummary:
        'Passfotos, Brieftaschenformate und 10 × 15 cm große Abzüge auf ein Blatt A4, '
        'Letter oder Fotopapier packen und als PDF exportieren. Kostenlos, und nichts wird '
        'hochgeladen.',
  ),
  'images-to-pdf': ToolTranslation(
    title: 'Bilder in PDF umwandeln',
    summary: 'Aus einem Ordner voller Bilder ein einziges, seitenweises PDF-Dokument erstellen.',
    highlights: <String>[
      'Ein Bild pro Seite, passend skaliert',
      'Seitenformat, Ausrichtung und Ränder wählen',
      'Seiten vor dem Export neu anordnen',
    ],
  ),
  'pdf-merge': ToolTranslation(
    title: 'PDFs zusammenführen',
    summary: 'Mehrere PDF-Dateien in der gewünschten Reihenfolge zu einer zusammenfassen.',
    highlights: <String>[
      'Dokumente per Ziehen neu anordnen',
      'Jede Seite vor dem Zusammenführen ansehen',
    ],
  ),
  'pdf-split': ToolTranslation(
    title: 'PDF aufteilen',
    summary: 'Seiten extrahieren oder ein Dokument in mehrere Dateien aufteilen.',
    highlights: <String>[
      'Seitenbereiche visuell auswählen',
      'Alle N Seiten oder an Lesezeichen aufteilen',
    ],
  ),
  'pdf-to-images': ToolTranslation(
    title: 'PDF in Bilder umwandeln',
    summary: 'Jede Seite eines PDFs mit der gewünschten Auflösung als PNG oder JPEG rendern.',
    highlights: <String>[
      'DPI pro Export wählen',
      'Einen Seitenbereich oder das gesamte Dokument exportieren',
    ],
  ),
  'image-resize': ToolTranslation(
    title: 'Bilder skalieren & konvertieren',
    summary:
        'Bilder stapelweise skalieren, zuschneiden und zwischen JPEG, PNG und WebP '
        'konvertieren.',
    highlights: <String>[
      'Skalieren nach Pixeln, Prozent oder Druckgröße',
      'Metadaten beim Export entfernen',
    ],
  ),
  'pdf-organise': ToolTranslation(
    title: 'Seiten drehen & neu anordnen',
    summary: 'Seitenreihenfolge und -ausrichtung korrigieren, ohne den Browser zu verlassen.',
    highlights: <String>[
      'Einzelne Seiten oder das gesamte Dokument drehen',
      'Seiten löschen und duplizieren',
    ],
  ),
  'watermark': ToolTranslation(
    title: 'Wasserzeichen',
    summary: 'Text oder ein Bild über Seiten und Fotos legen.',
    highlights: <String>[
      'Gekachelte oder einzelne Platzierung',
      'Deckkraft, Drehung und Farbe steuern',
    ],
    searchSummary:
        'Text oder ein Bild über PDF-Seiten und Fotos legen, gekachelt oder einmalig, mit '
        'Kontrolle über Deckkraft, Drehung und Farbe. Nichts wird hochgeladen.',
  ),
};

const Map<ToolCategory, CategoryTranslation> toolCategoriesDe = <ToolCategory, CategoryTranslation>{
  ToolCategory.photos: CategoryTranslation(
    label: 'Fotos',
    blurb: 'Alles, was passiert, bevor ein Foto zu Papier kommt.',
  ),
  ToolCategory.documents: CategoryTranslation(
    label: 'Dokumente',
    blurb: 'PDF-Chirurgie: zusammenführen, aufteilen, neu anordnen, stempeln.',
  ),
  ToolCategory.convert: CategoryTranslation(
    label: 'Konvertieren',
    blurb: 'Zwischen Formaten wechseln, ohne den Umweg über einen Server.',
  ),
};

const Map<ToolStatus, String> toolStatusesDe = <ToolStatus, String>{
  ToolStatus.available: 'Verfügbar',
  ToolStatus.comingSoon: 'Demnächst',
};

const Map<String, FaqTranslation> faqsDe = <String, FaqTranslation>{
  'Are my photos uploaded anywhere?': FaqTranslation(
    question: 'Werden meine Fotos irgendwohin hochgeladen?',
    answer:
        'Nein. Mellisuga ist eine statische Website ohne Backend, es gibt also keinen Server, '
        'der eine Datei empfangen könnte. Fotos, die Sie öffnen, werden auf der Seite '
        'dekodiert, im Speicher gehalten und sind verschwunden, sobald Sie den Tab schließen.',
  ),
  'Does it cost anything, and do I need an account?': FaqTranslation(
    question: 'Kostet es etwas, und brauche ich ein Konto?',
    answer:
        'Es ist kostenlos, Open Source unter der MIT-Lizenz, und hat keine Konten, keine '
        'Anmeldung, keine Wasserzeichen, keine Seitenlimits und keine Werbung.',
  ),
  'Does it work offline?': FaqTranslation(
    question: 'Funktioniert es offline?',
    answer:
        'Sobald die Seite geladen ist, stellt sie keine weiteren Netzwerkanfragen mehr, sodass '
        'ein offener Tab auch ohne Verbindung weiter funktioniert. Es gibt außerdem native '
        'Versionen für Android, Windows, macOS und Linux, falls Sie sich lieber gar nicht auf '
        'einen Browser verlassen möchten.',
  ),
  'Which browsers are supported?': FaqTranslation(
    question: 'Welche Browser werden unterstützt?',
    answer:
        'Jede aktuelle Version von Chrome, Edge, Firefox oder Safari, am Desktop oder mobil. '
        'Die App rendert mit CanvasKit, das mit der Seite gebündelt ist und nicht von einem '
        'CDN nachgeladen wird.',
  ),
  'Can I use the exported files commercially?': FaqTranslation(
    question: 'Darf ich die exportierten Dateien kommerziell nutzen?',
    answer:
        'Ja. Mellisuga beansprucht nichts von dem, was Sie damit erstellen, fügt kein '
        'Wasserzeichen hinzu und bettet kein Tracking in exportierte PDFs oder Bilder ein.',
  ),
  'What is a "bee hummingbird" doing on a printing app?': FaqTranslation(
    question: 'Was hat eine „Bienenelfe“ auf einer Druck-App zu suchen?',
    answer:
        'Mellisuga helenae ist der kleinste Vogel der Welt. Die Werkzeuge streben denselben '
        'Kunstgriff an: sehr viel auf sehr wenig Platz unterzubringen — auf einem Blatt Papier '
        'und in einem Download.',
  ),
};

const BrandTranslation brandDe = BrandTranslation(
  tagline: 'Foto- und PDF-Werkzeuge, die in Ihrem Browser laufen.',
  shortDescription:
      'Fotos jeder Größe ohne Verschnitt auf A4, Letter oder Fotopapier packen. Alles läuft '
      'auf Ihrem Gerät — nichts wird jemals hochgeladen.',
  description:
      'Mellisuga ist eine Sammlung von Foto- und Dokumentwerkzeugen, die ihre gesamte Arbeit '
      'auf Ihrem eigenen Gerät erledigen. Geöffnete Dateien werden nie auf einen Server '
      'hochgeladen — es gibt keinen Server.',
  nameOrigin:
      'Benannt nach Mellisuga helenae, der Bienenelfe — dem kleinsten Vogel der Welt und '
      'einem passenden Maskottchen für Werkzeuge, die viel auf sehr wenig Platz unterbringen.',
);
