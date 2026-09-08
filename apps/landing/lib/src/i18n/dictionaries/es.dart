import '../../copy.dart';

/// Spanish translations of the landing site's own chrome text.
const Map<String, String> siteStringsEs = <String, String>{
  'skipLink': 'Saltar al contenido',
  'nav.tools': 'Herramientas',
  'nav.how': 'Cómo funciona',
  'nav.sizes': 'Tamaños',
  'nav.faq': 'Preguntas frecuentes',
  'nav.source': 'Código fuente',
  'nav.openApp': 'Abrir la aplicación',
  'menuLabel': 'Menú',
  'themeToggleAria': 'Cambiar entre tema claro y oscuro',
  'languagePickerLabel': 'Idioma',
  'footer.product': 'Producto',
  'footer.allTools': 'Todas las herramientas',
  'footer.downloads': 'Descargas',
  'footer.legal': 'Legal',
  'footer.project': 'Proyecto',
  'footer.sourceCode': 'Código fuente',
  'footer.reportProblem': 'Informar de un problema',
  'footer.releasedUnder': 'Publicado bajo la',
  'footer.noAnalyticsLine': 'Sin cookies. Sin analítica. Sin cuentas.',
  'banner.defaultNote': 'Todo esto funciona en tu navegador. No se sube nada.',
  'home.heroHeading': 'Imprime fotos exactamente al tamaño que quieras',
  'home.heroTail': ' — sin subirlas',
  'home.heroLead':
      'Mellisuga organiza fotos de carné, impresiones de 10 × 15 cm y cualquier tamaño intermedio en una sola hoja de A4, carta o papel fotográfico, y te entrega un PDF. Funciona por completo en tu navegador: tus fotos nunca salen del dispositivo en el que están.',
  'home.heroChips': 'Sin subidas|Sin cuenta|Sin marca de agua|Gratis y de código abierto',
  'home.primaryAction': 'Abrir la aplicación',
  'home.secondaryAction': 'Ver cómo funciona',
  'home.whyDifferentHeading': 'Por qué es distinto del primer resultado de búsqueda',
  'home.howHeading': 'Tres pasos, sin registro',
  'home.toolsHeading': 'Todas las herramientas de la caja',
  'home.toolsLead':
      'Una está terminada y el resto están en camino. Todas funcionan igual: en tu dispositivo, en la pestaña que ya tienes abierta.',
  'home.sizesHeading': 'Tamaños que ya conoce',
  'home.sizesLead':
      'Los formatos de papel y los tamaños de impresión ya están incorporados, así que puedes elegir uno en lugar de medirlo. Cualquier tamaño que no esté en la lista se puede escribir con exactitud.',
  'home.paperHeading': 'Papel',
  'home.printSizesHeading': 'Tamaños de impresión',
  'home.paperCaption': 'Formatos de papel incorporados, agrupados por estándar',
  'home.printSizesCaption': 'Tamaños de impresión predefinidos, agrupados por tipo',
  'home.sizesFoot':
      '{paper} formatos de papel y {prints} tamaños de impresión ya están incorporados, en vertical u horizontal, y cualquier medida que escribas en milímetros, centímetros o pulgadas funciona igual de bien.',
  'home.platformsHeading': 'Dónde funciona',
  'home.platformsLead':
      'La versión de navegador no necesita instalar nada. Las versiones nativas son el mismo código, empaquetado: útil cuando el equipo desde el que imprimes no tiene conexión a internet en absoluto.',
  'home.openInBrowser': 'Abrir en este navegador',
  'home.download': 'Descargar',
  'home.faqHeading': 'Las preguntas que la gente realmente hace',
  'home.closingHeading': 'Ábrelo e imprime algo',
  'home.closingBody':
      'Sin registro, sin subidas, sin prueba. La herramienta se abre en la pestaña que ya estás mirando.',
  'home.openItNow': 'Ábrelo ahora',
  'home.readDetails': 'Leer los detalles',
  'home.readSource': 'Leer el código fuente',
  'crumb.home': 'Inicio',
  'tool.whatItDoes': 'Qué hace',
  'tool.seeHowItWorks': 'Ver cómo funciona',
  'tool.notBuiltYetHeading': 'Aún no está disponible',
  'tool.notBuiltYetBodyBefore':
      'Esta herramienta está en el plan y tiene una página en la aplicación que describe qué hará. Si la necesitas, dilo en el',
  'tool.notBuiltYetBodyLinkText': 'gestor de incidencias',
  'tool.notBuiltYetBodyAfter': ': así es como se decide el orden.',
  'tool.moreInTheBox': 'Más herramientas en la misma caja',
  'tool.readyNote': 'Esta herramienta está lista. Se abre en la pestaña que ya estás mirando.',
  'tool.notReadyNote':
      'Esta aún no está construida: la aplicación ya tiene las herramientas terminadas.',
  'toolsIndex.metaTitle': 'Herramientas de fotos y PDF que funcionan en tu dispositivo',
  'toolsIndex.metaDescription':
      'Todas las herramientas de {brand}: organiza fotos para imprimir, combina y divide PDF, convierte imágenes, añade marcas de agua y más, todo del lado del cliente, sin subir nada.',
  'toolsIndex.summary':
      '{available} terminadas, {roadmap} en camino. Cada una de ellas hace su trabajo en tu propio dispositivo.',
  'legal.lastUpdated': 'Última actualización: {date}',
  'legal.onThisPage': 'En esta página',
  'legal.proseFootBefore': 'El mismo documento se puede leer dentro de la aplicación en',
  'legal.proseFootAppLink': 'Acerca de',
  'legal.proseFootMiddle': ', y su historial está en el',
  'legal.proseFootRepoLink': 'repositorio de código público',
  'legal.otherDocuments': 'Otros documentos:',
  'legal.bannerNote': 'Cada palabra anterior describe cómo se comporta ya la aplicación.',
  'notFound.heading': 'Aquí no hay nada',
  'notFound.lead':
      'La página que buscas no existe, pero no se subió nada por el camino, así que no ha pasado nada malo.',
  'notFound.backToStart': 'Volver al inicio',
  'notFound.orJumpTo': 'O ve directamente a',
  'notFound.theTools': 'las herramientas',
};

const List<ValueProp> siteValuePropsEs = <ValueProp>[
  ValueProp(
    title: 'Tus archivos se quedan en tu dispositivo',
    body:
        'No hay backend. La página que cargas es un archivo estático, y la foto que abres se decodifica en la pestaña y se descarta al cerrarla. No se transmite nada, porque no hay adónde transmitirlo.',
    illustration: 'privacy',
  ),
  ValueProp(
    title: 'Milímetros, no suposiciones',
    body:
        'Cada medida se guarda en milímetros y solo se convierte en los extremos. Una foto de carné de 35 × 45 mm mide 35 × 45 mm con una regla, y una hoja A4 exportada a 300 DPI mide exactamente 2480 × 3508 píxeles.',
    illustration: 'ruler',
  ),
  ValueProp(
    title: 'Papel que ya has pagado',
    body:
        'El organizador llena cada hoja antes de empezar otra: las impresiones grandes van primero, las pequeñas rellenan los huecos y se giran 90° cuando eso permite encajar una más. Lo que sobra es el margen que pediste, no desperdicio.',
    illustration: 'packing',
  ),
];

const List<Step> siteStepsEs = <Step>[
  Step(
    title: 'Añade tus fotos',
    body:
        'Añade tantas como quieras. La orientación de la cámara se aplica al importarlas, así que nada llega girado.',
  ),
  Step(
    title: 'Asigna un tamaño a cada una',
    body:
        'Elige un preajuste (carné, cartera, 10 × 15 cm) o escribe medidas exactas en milímetros, centímetros o pulgadas. Recorta, gira y anota sin tocar el archivo original.',
  ),
  Step(
    title: 'Imprime, o exporta un PDF',
    body:
        'La hoja se reorganiza a medida que avanzas. Añade líneas de corte, ajusta los márgenes y luego exporta un PDF o PNG entre 150 y 600 DPI, o envíalo directamente a una impresora.',
  ),
];

const List<Platform> sitePlatformsEs = <Platform>[
  Platform(
    name: 'Navegador',
    detail: 'Chrome, Edge, Firefox o Safari, en escritorio o móvil. Nada que instalar.',
    isWeb: true,
  ),
  Platform(name: 'Android', detail: 'APK por arquitectura, incluido en cada versión publicada.'),
  Platform(
    name: 'Windows',
    detail: 'Archivo zip portátil. Sin firmar, así que Windows preguntará una vez.',
  ),
  Platform(
    name: 'macOS',
    detail: 'Paquete de aplicación. Sin firmar, así que ábrelo con clic derecho → Abrir.',
  ),
  Platform(name: 'Linux', detail: 'Archivo tar con el paquete dentro. GTK 3.'),
];
