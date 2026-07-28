import '../../tool_catalog.dart';
import '../brand_i18n.dart';
import '../faq_i18n.dart';
import '../tool_catalog_i18n.dart';

/// Spanish translations: tool catalogue, category/status labels, general FAQ
/// and brand copy.
const Map<String, ToolTranslation> toolCatalogEs = <String, ToolTranslation>{
  'photo-compose': ToolTranslation(
    title: 'Organizar fotos para imprimir',
    summary:
        'Organiza fotos de cualquier tamaño en papel carta, A4, A3 o fotográfico sin desperdiciar espacio.',
    searchSummary:
        'Encaja fotos de carné, cartera y de 10 × 15 cm en una sola hoja de A4, carta o papel fotográfico, y exporta un PDF. Gratis, y no se sube nada.',
    highlights: <String>[
      'Elige un tamaño de impresión por foto, o usa los preajustes de carné y cartera',
      'Recorta, gira, voltea y anota antes de imprimir',
      'El empaquetado automático llena cada hoja y luego empieza otra',
      'Líneas de corte, marcas de recorte, márgenes y espaciado, todo configurable',
      'Exporta a PDF o PNG, o envíalo directamente a una impresora',
    ],
  ),
  'images-to-pdf': ToolTranslation(
    title: 'Imágenes a PDF',
    summary: 'Convierte una carpeta de imágenes en un único documento PDF paginado.',
    highlights: <String>[
      'Una imagen por página, ajustada al tamaño',
      'Elige tamaño de página, orientación y márgenes',
      'Reordena las páginas antes de exportar',
    ],
  ),
  'pdf-merge': ToolTranslation(
    title: 'Combinar PDF',
    summary: 'Combina varios archivos PDF en uno solo, en el orden que elijas.',
    highlights: <String>[
      'Arrastra para reordenar los documentos',
      'Previsualiza cada página antes de combinar',
    ],
  ),
  'pdf-split': ToolTranslation(
    title: 'Dividir PDF',
    summary: 'Extrae páginas o divide un documento en varios archivos.',
    highlights: <String>[
      'Selecciona rangos de páginas visualmente',
      'Divide cada N páginas, o por marcadores',
    ],
  ),
  'pdf-to-images': ToolTranslation(
    title: 'PDF a imágenes',
    summary: 'Convierte cada página de un PDF a PNG o JPEG con la resolución que elijas.',
    highlights: <String>[
      'Elige el DPI de cada exportación',
      'Exporta un rango de páginas o el documento completo',
    ],
  ),
  'image-resize': ToolTranslation(
    title: 'Redimensionar y convertir imágenes',
    summary: 'Redimensiona, recorta y convierte por lotes entre JPEG, PNG y WebP.',
    highlights: <String>[
      'Redimensiona por píxeles, porcentaje o tamaño de impresión',
      'Elimina los metadatos al exportar',
    ],
  ),
  'pdf-organise': ToolTranslation(
    title: 'Girar y reordenar páginas',
    summary: 'Corrige el orden y la orientación de las páginas sin salir del navegador.',
    highlights: <String>[
      'Gira páginas individuales o el documento completo',
      'Elimina y duplica páginas',
    ],
  ),
  'watermark': ToolTranslation(
    title: 'Marca de agua',
    summary: 'Estampa texto o una imagen sobre páginas y fotos.',
    searchSummary:
        'Estampa texto o una imagen sobre páginas de PDF y fotos, en mosaico o una sola vez, con control de opacidad, rotación y color. No se sube nada.',
    highlights: <String>[
      'Colocación en mosaico o única',
      'Controla la opacidad, la rotación y el color',
    ],
  ),
};

const Map<ToolCategory, CategoryTranslation> toolCategoriesEs = <ToolCategory, CategoryTranslation>{
  ToolCategory.photos: CategoryTranslation(
    label: 'Fotos',
    blurb: 'Todo lo que ocurre antes de que una foto llegue al papel.',
  ),
  ToolCategory.documents: CategoryTranslation(
    label: 'Documentos',
    blurb: 'Cirugía de PDF: combinar, dividir, reordenar, estampar.',
  ),
  ToolCategory.convert: CategoryTranslation(
    label: 'Convertir',
    blurb: 'Cambia de formato sin dar un rodeo por un servidor.',
  ),
};

const Map<ToolStatus, String> toolStatusesEs = <ToolStatus, String>{
  ToolStatus.available: 'Disponible',
  ToolStatus.comingSoon: 'Próximamente',
};

const Map<String, FaqTranslation> faqsEs = <String, FaqTranslation>{
  'Are my photos uploaded anywhere?': FaqTranslation(
    question: '¿Se suben mis fotos a algún sitio?',
    answer:
        'No. Mellisuga es un sitio estático sin backend, así que no hay ningún servidor que pueda recibir un archivo. Las fotos que abres se decodifican en la página, se guardan en memoria y desaparecen en cuanto cierras la pestaña.',
  ),
  'Does it cost anything, and do I need an account?': FaqTranslation(
    question: '¿Cuesta algo y necesito una cuenta?',
    answer:
        'Es gratis, de código abierto bajo la licencia MIT, y no tiene cuentas, ni inicio de sesión, ni marcas de agua, ni límites de páginas ni publicidad.',
  ),
  'Does it work offline?': FaqTranslation(
    question: '¿Funciona sin conexión?',
    answer:
        'Una vez que la página se ha cargado, no realiza más peticiones de red, así que una pestaña abierta sigue funcionando aunque desconectes internet. También hay versiones nativas para Android, Windows, macOS y Linux si prefieres no depender de un navegador en absoluto.',
  ),
  'Which browsers are supported?': FaqTranslation(
    question: '¿Qué navegadores son compatibles?',
    answer:
        'Cualquier versión actual de Chrome, Edge, Firefox o Safari, en escritorio o móvil. La aplicación se renderiza con CanvasKit, que se incluye con la página en lugar de descargarse desde una CDN.',
  ),
  'Can I use the exported files commercially?': FaqTranslation(
    question: '¿Puedo usar los archivos exportados con fines comerciales?',
    answer:
        'Sí. Mellisuga no reclama nada sobre lo que hagas con ella, no añade marca de agua y no incluye seguimiento en los PDF o imágenes exportados.',
  ),
  'What is a "bee hummingbird" doing on a printing app?': FaqTranslation(
    question: '¿Qué hace un "zunzuncito" en una aplicación de impresión?',
    answer:
        'Mellisuga helenae es el ave más pequeña que existe. Las herramientas buscan el mismo truco: encajar muchísimo en muy poco espacio, tanto en una hoja de papel como en una descarga.',
  ),
};

const BrandTranslation brandEs = BrandTranslation(
  tagline: 'Herramientas de fotos y PDF que funcionan en tu navegador.',
  shortDescription:
      'Organiza fotos de cualquier tamaño en A4, carta o papel fotográfico sin desperdiciar espacio. Todo funciona en tu dispositivo: no se sube nada.',
  description:
      'Mellisuga es una colección de utilidades de fotos y documentos que hacen todo su trabajo en tu propio dispositivo. Los archivos que abres nunca se suben a un servidor: no hay servidor.',
  nameOrigin:
      'Recibe su nombre de Mellisuga helenae, el zunzuncito: el ave más pequeña que existe, y una mascota adecuada para herramientas que encajan mucho en muy poco espacio.',
);
