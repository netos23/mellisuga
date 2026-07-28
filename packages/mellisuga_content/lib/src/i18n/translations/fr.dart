import '../../tool_catalog.dart';
import '../brand_i18n.dart';
import '../faq_i18n.dart';
import '../tool_catalog_i18n.dart';

/// French translations: tool catalogue, category/status labels, general FAQ
/// and brand copy.
const Map<String, ToolTranslation> toolCatalogFr = <String, ToolTranslation>{
  'photo-compose': ToolTranslation(
    title: 'Composer des photos pour l’impression',
    summary:
        'Regroupez des photos de toutes tailles sur du papier Letter, A4, A3 ou '
        'photo sans gaspillage d’espace.',
    searchSummary:
        'Placez des photos d’identité, portefeuille et tirages 10 × 15 cm sur une '
        'seule feuille A4, Letter ou papier photo, puis exportez un PDF. Gratuit, et '
        'rien n’est envoyé.',
    highlights: <String>[
      'Choisissez une taille d’impression par photo, ou utilisez les préréglages '
          'identité et portefeuille',
      'Recadrez, pivotez, retournez et annotez avant d’imprimer',
      'Le remplissage automatique optimise chaque feuille avant d’en commencer une '
          'nouvelle',
      'Traits de coupe, repères de recadrage, marges et espacement sont tous '
          'configurables',
      'Exportez en PDF ou PNG, ou envoyez directement à une imprimante',
    ],
  ),
  'images-to-pdf': ToolTranslation(
    title: 'Images en PDF',
    summary: 'Transformez un dossier d’images en un seul document PDF paginé.',
    highlights: <String>[
      'Une image par page, mise à l’échelle pour s’adapter',
      'Choisissez la taille de page, l’orientation et les marges',
      'Réorganisez les pages avant l’export',
    ],
  ),
  'pdf-merge': ToolTranslation(
    title: 'Fusionner des PDF',
    summary: 'Combinez plusieurs fichiers PDF en un seul, dans l’ordre de votre choix.',
    highlights: <String>[
      'Glissez pour réorganiser les documents',
      'Prévisualisez chaque page avant la fusion',
    ],
  ),
  'pdf-split': ToolTranslation(
    title: 'Diviser un PDF',
    summary: 'Extrayez des pages ou découpez un document en plusieurs fichiers.',
    highlights: <String>[
      'Sélectionnez visuellement des plages de pages',
      'Divisez toutes les N pages, ou aux signets',
    ],
  ),
  'pdf-to-images': ToolTranslation(
    title: 'PDF en images',
    summary:
        'Convertissez chaque page d’un PDF en PNG ou JPEG à la résolution de votre '
        'choix.',
    highlights: <String>[
      'Choisissez le DPI pour chaque export',
      'Exportez une plage de pages ou le document entier',
    ],
  ),
  'image-resize': ToolTranslation(
    title: 'Redimensionner et convertir des images',
    summary: 'Redimensionnez, recadrez et convertissez par lot entre JPEG, PNG et WebP.',
    highlights: <String>[
      'Redimensionnez par pixels, pourcentage ou taille d’impression',
      'Supprimez les métadonnées à l’export',
    ],
  ),
  'pdf-organise': ToolTranslation(
    title: 'Pivoter et réorganiser les pages',
    summary: 'Corrigez l’ordre et l’orientation des pages sans quitter le navigateur.',
    highlights: <String>[
      'Pivotez des pages individuelles ou le document entier',
      'Supprimez et dupliquez des pages',
    ],
  ),
  'watermark': ToolTranslation(
    title: 'Filigrane',
    summary: 'Apposez du texte ou une image sur des pages et des photos.',
    searchSummary:
        'Apposez du texte ou une image sur des pages PDF et des photos, en mosaïque '
        'ou une seule fois, avec un contrôle de l’opacité, de la rotation et de la '
        'couleur. Rien n’est envoyé.',
    highlights: <String>[
      'Placement en mosaïque ou unique',
      'Contrôlez l’opacité, la rotation et la couleur',
    ],
  ),
};

const Map<ToolCategory, CategoryTranslation> toolCategoriesFr = <ToolCategory, CategoryTranslation>{
  ToolCategory.photos: CategoryTranslation(
    label: 'Photos',
    blurb: 'Tout ce qui se passe avant qu’une photo n’arrive sur papier.',
  ),
  ToolCategory.documents: CategoryTranslation(
    label: 'Documents',
    blurb: 'Chirurgie de PDF : fusionner, diviser, réorganiser, tamponner.',
  ),
  ToolCategory.convert: CategoryTranslation(
    label: 'Convertir',
    blurb: 'Passez d’un format à l’autre sans passer par un serveur.',
  ),
};

const Map<ToolStatus, String> toolStatusesFr = <ToolStatus, String>{
  ToolStatus.available: 'Disponible',
  ToolStatus.comingSoon: 'Bientôt disponible',
};

const Map<String, FaqTranslation> faqsFr = <String, FaqTranslation>{
  'Are my photos uploaded anywhere?': FaqTranslation(
    question: 'Mes photos sont-elles envoyées quelque part ?',
    answer:
        'Non. Mellisuga est un site statique sans serveur, il n’y a donc aucun '
        'serveur susceptible de recevoir un fichier. Les photos que vous ouvrez sont '
        'décodées dans la page, conservées en mémoire, puis disparaissent dès que '
        'vous fermez l’onglet.',
  ),
  'Does it cost anything, and do I need an account?': FaqTranslation(
    question: 'Est-ce payant, et ai-je besoin d’un compte ?',
    answer:
        'C’est gratuit, open source sous licence MIT, et il n’y a ni comptes, ni '
        'connexion, ni filigranes, ni limites de pages, ni publicité.',
  ),
  'Does it work offline?': FaqTranslation(
    question: 'Fonctionne-t-il hors ligne ?',
    answer:
        'Une fois la page chargée, elle n’effectue plus aucune requête réseau, donc '
        'un onglet ouvert continue de fonctionner sans connexion. Il existe aussi des '
        'versions natives pour Android, Windows, macOS et Linux si vous préférez ne '
        'pas dépendre d’un navigateur du tout.',
  ),
  'Which browsers are supported?': FaqTranslation(
    question: 'Quels navigateurs sont pris en charge ?',
    answer:
        'Toute version récente de Chrome, Edge, Firefox ou Safari, sur ordinateur ou '
        'mobile. L’application s’affiche avec CanvasKit, qui est intégré à la page '
        'plutôt que récupéré depuis un CDN.',
  ),
  'Can I use the exported files commercially?': FaqTranslation(
    question: 'Puis-je utiliser les fichiers exportés à des fins commerciales ?',
    answer:
        'Oui. Mellisuga ne revendique rien sur ce que vous créez avec, n’ajoute '
        'aucun filigrane et n’intègre aucun traceur dans les PDF ou images exportés.',
  ),
  'What is a "bee hummingbird" doing on a printing app?': FaqTranslation(
    question: 'Que fait un « colibri d’Elena » sur une application d’impression ?',
    answer:
        'Mellisuga helenae est le plus petit oiseau qui existe. Les outils visent '
        'le même exploit : faire tenir énormément de choses dans très peu d’espace — '
        'sur une feuille de papier, et dans un téléchargement.',
  ),
};

const BrandTranslation brandFr = BrandTranslation(
  tagline: 'Outils photo et PDF qui fonctionnent dans votre navigateur.',
  shortDescription:
      'Regroupez des photos de toutes tailles sur du papier A4, Letter ou photo '
      'sans gaspillage. Tout se passe sur votre appareil — rien n’est jamais envoyé.',
  description:
      'Mellisuga est une collection d’utilitaires photo et documents qui '
      'effectuent tout leur travail sur votre propre appareil. Les fichiers que vous '
      'ouvrez ne sont jamais envoyés à un serveur — il n’y a pas de serveur.',
  nameOrigin:
      'Nommé d’après Mellisuga helenae, le colibri d’Elena — le plus petit oiseau '
      'qui existe, et une mascotte parfaite pour des outils qui font tenir beaucoup '
      'de choses dans très peu d’espace.',
);
