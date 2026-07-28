import '../../tool_catalog.dart';
import '../brand_i18n.dart';
import '../faq_i18n.dart';
import '../tool_catalog_i18n.dart';

/// Chinese translations: tool catalogue, category/status labels, general FAQ
/// and brand copy.
const Map<String, ToolTranslation> toolCatalogZh = <String, ToolTranslation>{
  'photo-compose': ToolTranslation(
    title: '排版打印照片',
    summary: '将任意尺寸的照片排版到 Letter、A4、A3 或照片纸上,不浪费任何空间。',
    searchSummary: '将证件照、钱包照和 10 × 15 厘米照片排版到一张 A4、Letter 或照片纸上,然后导出 PDF。免费,且不会上传任何内容。',
    highlights: <String>[
      '为每张照片选择打印尺寸,或使用证件照、钱包照预设',
      '在打印前裁剪、旋转、翻转和标注照片',
      '自动装箱排版会先填满一张纸,再开始下一张',
      '裁切线、裁切标记、边距和间距均可自由配置',
      '导出为 PDF 或 PNG,或直接发送给打印机',
    ],
  ),
  'images-to-pdf': ToolTranslation(
    title: '图片转 PDF',
    summary: '将一整个文件夹的图片转换成一份分页的 PDF 文档。',
    highlights: <String>['每页一张图片,自动缩放以适应页面', '选择页面大小、方向和边距', '导出前可调整页面顺序'],
  ),
  'pdf-merge': ToolTranslation(
    title: '合并 PDF',
    summary: '按照你选择的顺序,将多个 PDF 文件合并为一个。',
    highlights: <String>['拖拽即可调整文档顺序', '合并前预览每一页内容'],
  ),
  'pdf-split': ToolTranslation(
    title: '拆分 PDF',
    summary: '提取指定页面,或将一份文档拆分成多个文件。',
    highlights: <String>['通过可视化方式选择页面范围', '按每 N 页拆分,或按书签拆分'],
  ),
  'pdf-to-images': ToolTranslation(
    title: 'PDF 转图片',
    summary: '按你选择的分辨率,将 PDF 的每一页渲染为 PNG 或 JPEG。',
    highlights: <String>['每次导出可自定义 DPI', '导出指定页面范围或整份文档'],
  ),
  'image-resize': ToolTranslation(
    title: '调整图片大小与格式转换',
    summary: '批量调整图片大小、裁剪,并在 JPEG、PNG、WebP 之间转换。',
    highlights: <String>['按像素、百分比或打印尺寸调整大小', '导出时清除元数据'],
  ),
  'pdf-organise': ToolTranslation(
    title: '旋转与重排页面',
    summary: '无需离开浏览器即可调整页面顺序和方向。',
    highlights: <String>['旋转单个页面或整份文档', '删除和复制页面'],
  ),
  'watermark': ToolTranslation(
    title: '添加水印',
    summary: '在页面和照片上添加文字或图片水印。',
    searchSummary: '在 PDF 页面和照片上平铺或单次添加文字或图片水印,可控制透明度、旋转角度和颜色。不会上传任何内容。',
    highlights: <String>['支持平铺或单次放置', '可控制透明度、旋转角度和颜色'],
  ),
};

const Map<ToolCategory, CategoryTranslation> toolCategoriesZh = <ToolCategory, CategoryTranslation>{
  ToolCategory.photos: CategoryTranslation(label: '照片', blurb: '照片送去打印之前需要经历的一切处理。'),
  ToolCategory.documents: CategoryTranslation(label: '文档', blurb: 'PDF 处理工具:合并、拆分、重排、加水印。'),
  ToolCategory.convert: CategoryTranslation(label: '转换', blurb: '无需借助服务器即可在不同格式之间转换。'),
};

const Map<ToolStatus, String> toolStatusesZh = <ToolStatus, String>{
  ToolStatus.available: '可用',
  ToolStatus.comingSoon: '即将推出',
};

const Map<String, FaqTranslation> faqsZh = <String, FaqTranslation>{
  'Are my photos uploaded anywhere?': FaqTranslation(
    question: '我的照片会被上传到哪里吗?',
    answer: '不会。Mellisuga 是一个没有后端的静态网站,因此没有任何服务器可以接收文件。你打开的照片会在页面中解码,保存在内存里,一旦关闭标签页就会消失。',
  ),
  'Does it cost anything, and do I need an account?': FaqTranslation(
    question: '使用它需要付费吗?需要注册账户吗?',
    answer: '完全免费,采用 MIT 许可协议开源,无需账户、无需登录、没有水印、没有页数限制,也没有广告。',
  ),
  'Does it work offline?': FaqTranslation(
    question: '它可以离线使用吗?',
    answer:
        '页面加载完成后就不会再发起任何网络请求,因此即使断网,已打开的标签页也能继续正常使用。如果你完全不想依赖浏览器,还提供了 Android、Windows、macOS 和 Linux 的原生版本。',
  ),
  'Which browsers are supported?': FaqTranslation(
    question: '支持哪些浏览器?',
    answer:
        '支持任意最新版本的 Chrome、Edge、Firefox 或 Safari,桌面端和移动端均可。应用使用 CanvasKit 渲染,该组件随页面一起打包,而非从 CDN 加载。',
  ),
  'Can I use the exported files commercially?': FaqTranslation(
    question: '导出的文件可以用于商业用途吗?',
    answer: '可以。Mellisuga 对你用它制作的内容不主张任何权利,不添加水印,也不会在导出的 PDF 或图片中嵌入任何追踪信息。',
  ),
  'What is a "bee hummingbird" doing on a printing app?': FaqTranslation(
    question: '一款打印应用为什么叫“蜂鸟”?',
    answer: 'Mellisuga helenae 是世界上最小的鸟类。这些工具追求的是同样的本领:把尽可能多的内容装进尽可能小的空间里 — 无论是一张纸上,还是一个下载包中。',
  ),
};

const BrandTranslation brandZh = BrandTranslation(
  tagline: '在浏览器中运行的照片与 PDF 工具。',
  shortDescription: '将任意尺寸的照片排版到 A4、Letter 或照片纸上,不浪费任何空间。一切都在你的设备上完成 — 不会上传任何内容。',
  description: 'Mellisuga 是一套照片与文档工具集,所有处理都在你自己的设备上完成。你打开的文件永远不会被上传到服务器 — 因为根本没有服务器。',
  nameOrigin: '以 Mellisuga helenae(吸蜜蜂鸟)命名 — 世界上最小的鸟类,恰好是这些追求“以小容大”工具的最佳象征。',
);
