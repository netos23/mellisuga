import '../../tool_catalog.dart';
import '../brand_i18n.dart';
import '../faq_i18n.dart';
import '../tool_catalog_i18n.dart';

/// Arabic translations: tool catalogue, category/status labels, general FAQ
/// and brand copy.
const Map<String, ToolTranslation> toolCatalogAr = <String, ToolTranslation>{
  'photo-compose': ToolTranslation(
    title: 'ترتيب الصور للطباعة',
    summary: 'رتّب صورًا بأي حجم على ورق Letter أو A4 أو A3 أو ورق الصور دون هدر أي مساحة.',
    searchSummary:
        'اجمع صور جواز السفر والمحفظة وطبعات 10 × 15 سم على ورقة واحدة من A4 أو '
        'Letter أو ورق الصور، ثم صدّرها كملف PDF. مجانية، ولا شيء يُرفع.',
    highlights: <String>[
      'حدّد حجم طباعة لكل صورة، أو استخدم أحجام جواز السفر والمحفظة الجاهزة',
      'اقصص، ودوّر، واقلب، وأضف ملاحظات قبل الطباعة',
      'نظام ترتيب تلقائي يملأ كل ورقة قبل أن يبدأ ورقة جديدة',
      'خطوط القص، وعلامات القص، والهوامش، والتباعد، كلها قابلة للتخصيص',
      'صدّر إلى PDF أو PNG، أو أرسل مباشرة إلى طابعة',
    ],
  ),
  'images-to-pdf': ToolTranslation(
    title: 'تحويل الصور إلى PDF',
    summary: 'حوّل مجلدًا من الصور إلى مستند PDF واحد مقسّم إلى صفحات.',
    highlights: <String>[
      'صورة واحدة في كل صفحة، مع تكبير أو تصغير يلائم الحجم',
      'اختر حجم الصفحة والاتجاه والهوامش',
      'أعد ترتيب الصفحات قبل التصدير',
    ],
  ),
  'pdf-merge': ToolTranslation(
    title: 'دمج ملفات PDF',
    summary: 'اجمع عدة ملفات PDF في ملف واحد، بالترتيب الذي تختاره.',
    highlights: <String>['اسحب لإعادة ترتيب المستندات', 'عاين كل صفحة قبل الدمج'],
  ),
  'pdf-split': ToolTranslation(
    title: 'تقسيم PDF',
    summary: 'استخرج صفحات محددة أو قسّم مستندًا واحدًا إلى عدة ملفات.',
    highlights: <String>[
      'حدّد نطاقات الصفحات بصريًا',
      'قسّم كل عدد صفحات محدد، أو عند الإشارات المرجعية',
    ],
  ),
  'pdf-to-images': ToolTranslation(
    title: 'تحويل PDF إلى صور',
    summary: 'حوّل كل صفحة من ملف PDF إلى صورة PNG أو JPEG بالدقة التي تختارها.',
    highlights: <String>['اختر دقة النقاط لكل تصدير', 'صدّر نطاق صفحات أو المستند بأكمله'],
  ),
  'image-resize': ToolTranslation(
    title: 'تغيير حجم الصور وتحويلها',
    summary: 'غيّر حجم مجموعة صور واقصصها وحوّلها بين صيغ JPEG وPNG وWebP دفعة واحدة.',
    highlights: <String>[
      'غيّر الحجم بالبكسل أو النسبة المئوية أو حجم الطباعة',
      'احذف البيانات الوصفية عند التصدير',
    ],
  ),
  'pdf-organise': ToolTranslation(
    title: 'تدوير الصفحات وإعادة ترتيبها',
    summary: 'أصلح ترتيب الصفحات واتجاهها دون مغادرة المتصفح.',
    highlights: <String>['دوّر صفحات فردية أو المستند بأكمله', 'احذف الصفحات وكرّرها'],
  ),
  'watermark': ToolTranslation(
    title: 'العلامة المائية',
    summary: 'اطبع نصًا أو صورة عبر صفحات PDF والصور.',
    searchSummary:
        'اطبع نصًا أو صورة عبر صفحات PDF والصور، بشكل متكرر أو مرة واحدة، مع تحكم '
        'في الشفافية والدوران واللون. لا شيء يُرفع.',
    highlights: <String>['وضع متكرر أو مفرد', 'تحكم في الشفافية والدوران واللون'],
  ),
};

const Map<ToolCategory, CategoryTranslation> toolCategoriesAr = <ToolCategory, CategoryTranslation>{
  ToolCategory.photos: CategoryTranslation(
    label: 'الصور',
    blurb: 'كل ما يحدث قبل أن تصل الصورة إلى الورق.',
  ),
  ToolCategory.documents: CategoryTranslation(
    label: 'المستندات',
    blurb: 'عمليات دقيقة على ملفات PDF: دمج، وتقسيم، وإعادة ترتيب، وختم.',
  ),
  ToolCategory.convert: CategoryTranslation(
    label: 'التحويل',
    blurb: 'انتقل بين الصيغ دون المرور بخادم.',
  ),
};

const Map<ToolStatus, String> toolStatusesAr = <ToolStatus, String>{
  ToolStatus.available: 'متاحة',
  ToolStatus.comingSoon: 'قريبًا',
};

const Map<String, FaqTranslation> faqsAr = <String, FaqTranslation>{
  'Are my photos uploaded anywhere?': FaqTranslation(
    question: 'هل تُرفع صوري إلى أي مكان؟',
    answer:
        'لا. Mellisuga موقع ثابت بلا خادم خلفي، لذا لا يوجد خادم يمكنه استقبال '
        'أي ملف. الصور التي تفتحها تُفكّ شفرتها داخل الصفحة، وتُحفظ في الذاكرة '
        'المؤقتة، وتختفي بمجرد إغلاق التبويب.',
  ),
  'Does it cost anything, and do I need an account?': FaqTranslation(
    question: 'هل يُكلّف الأمر شيئًا، وهل أحتاج إلى حساب؟',
    answer:
        'إنه مجاني، ومفتوح المصدر بموجب ترخيص MIT، ولا يتطلب حسابات، ولا تسجيل '
        'دخول، ولا علامات مائية، ولا حدودًا لعدد الصفحات، ولا إعلانات.',
  ),
  'Does it work offline?': FaqTranslation(
    question: 'هل يعمل دون اتصال بالإنترنت؟',
    answer:
        'بمجرد تحميل الصفحة، لا يُجري التطبيق أي طلبات شبكية إضافية، لذا يستمر '
        'التبويب المفتوح في العمل حتى مع إيقاف الاتصال. توجد أيضًا نسخ أصلية '
        'لأنظمة Android وWindows وmacOS وLinux إذا كنت تفضّل عدم الاعتماد على '
        'المتصفح إطلاقًا.',
  ),
  'Which browsers are supported?': FaqTranslation(
    question: 'ما المتصفحات المدعومة؟',
    answer:
        'أي إصدار حديث من Chrome أو Edge أو Firefox أو Safari، على سطح المكتب '
        'أو الجوال. يعرض التطبيق باستخدام CanvasKit، المُرفق مع الصفحة نفسها '
        'وليس مُحمّلًا من شبكة توصيل محتوى.',
  ),
  'Can I use the exported files commercially?': FaqTranslation(
    question: 'هل يمكنني استخدام الملفات المُصدَّرة تجاريًا؟',
    answer:
        'نعم. لا يطالب Mellisuga بأي حقوق على ما تصنعه به، ولا يضيف أي علامة '
        'مائية، ولا يُضمّن أي تتبّع في ملفات PDF أو الصور المُصدَّرة.',
  ),
  'What is a "bee hummingbird" doing on a printing app?': FaqTranslation(
    question: 'ما الذي يفعله "طائر الطنان النحلي" في تطبيق طباعة؟',
    answer:
        'طائر Mellisuga helenae هو أصغر طائر على الإطلاق. تسعى الأدوات إلى الحيلة '
        'نفسها: حشد الكثير في مساحة ضئيلة جدًا — على ورقة، وفي ملف تنزيل.',
  ),
};

const BrandTranslation brandAr = BrandTranslation(
  tagline: 'أدوات صور وملفات PDF تعمل داخل متصفحك.',
  shortDescription:
      'رتّب صورًا بأي حجم على ورق A4 أو Letter أو ورق الصور دون هدر أي مساحة. '
      'كل شيء يعمل على جهازك — لا شيء يُرفع أبدًا.',
  description:
      'Mellisuga مجموعة أدوات للصور والمستندات تنجز عملها بالكامل على جهازك '
      'أنت. الملفات التي تفتحها لا تُرفع أبدًا إلى خادم — لأنه لا يوجد خادم.',
  nameOrigin:
      'سُمّي التطبيق تيمنًا بطائر Mellisuga helenae، الطنان النحلي — أصغر طائر '
      'على الإطلاق، وشعار مناسب لأدوات تحشد الكثير في مساحة ضئيلة جدًا.',
);
