import '../../tool_catalog.dart';
import '../brand_i18n.dart';
import '../faq_i18n.dart';
import '../tool_catalog_i18n.dart';

/// Japanese translations: tool catalogue, category/status labels,
/// general FAQ and brand copy.
const Map<String, ToolTranslation> toolCatalogJa = <String, ToolTranslation>{
  'photo-compose': ToolTranslation(
    title: '印刷用に写真をレイアウト',
    summary: 'あらゆるサイズの写真をLetter、A4、A3、フォト用紙に無駄なく配置します。',
    searchSummary:
        '証明写真、名刺サイズ、10 × 15 cmの写真をA4、Letter、フォト用紙などの1枚にまとめて配置し、PDFとして書き出せます。無料で、アップロードは一切行われません。',
    highlights: <String>[
      '写真ごとに印刷サイズを指定、または証明写真・名刺サイズのプリセットを利用',
      '印刷前に切り抜き、回転、反転、注釈の追加が可能',
      '自動ビンパッキングで1枚の用紙を埋めてから次の用紙へ',
      '裁断線、トンボ、余白、間隔をすべて設定可能',
      'PDFまたはPNGとして書き出し、あるいはそのままプリンターへ送信',
    ],
  ),
  'images-to-pdf': ToolTranslation(
    title: '画像をPDFに変換',
    summary: 'フォルダ内の画像をまとめて、ページ分けされた1つのPDF文書に変換します。',
    highlights: <String>['1ページに1枚の画像を、サイズに合わせて自動調整', 'ページサイズ、向き、余白を選択可能', '書き出し前にページの並び替えが可能'],
  ),
  'pdf-merge': ToolTranslation(
    title: 'PDFファイルを結合',
    summary: '複数のPDFファイルを、指定した順番で1つに結合します。',
    highlights: <String>['ドラッグして文書の順番を並び替え', '結合前にすべてのページをプレビュー'],
  ),
  'pdf-split': ToolTranslation(
    title: 'PDFファイルを分割',
    summary: 'ページを抽出したり、1つの文書を複数のファイルに分割したりできます。',
    highlights: <String>['ページ範囲を視覚的に選択', 'N ページごと、またはしおりの位置で分割'],
  ),
  'pdf-to-images': ToolTranslation(
    title: 'PDFを画像に変換',
    summary: 'PDFの各ページを、指定した解像度でPNGまたはJPEGに変換します。',
    highlights: <String>['書き出しごとにDPIを選択可能', 'ページ範囲を指定、または文書全体を書き出し'],
  ),
  'image-resize': ToolTranslation(
    title: '画像のリサイズと変換',
    summary: 'JPEG、PNG、WebPの間で、リサイズ・切り抜き・変換をまとめて処理します。',
    highlights: <String>['ピクセル数、パーセンテージ、印刷サイズでリサイズ', '書き出し時にメタデータを削除'],
  ),
  'pdf-organise': ToolTranslation(
    title: 'ページの回転と並び替え',
    summary: 'ブラウザから出ることなく、ページの順番と向きを整えられます。',
    highlights: <String>['個々のページ、または文書全体を回転', 'ページの削除と複製'],
  ),
  'watermark': ToolTranslation(
    title: '透かしを追加する',
    summary: 'ページや写真に、テキストまたは画像の透かしを入れます。',
    searchSummary: 'PDFのページや写真にテキストまたは画像の透かしをタイル状または単一配置で入れられ、不透明度・回転・色を細かく調整できます。アップロードは一切行われません。',
    highlights: <String>['タイル状配置または単一配置', '不透明度、回転、色を調整可能'],
  ),
};

const Map<ToolCategory, CategoryTranslation> toolCategoriesJa = <ToolCategory, CategoryTranslation>{
  ToolCategory.photos: CategoryTranslation(label: '写真', blurb: '写真が紙に印刷されるまでのすべての工程。'),
  ToolCategory.documents: CategoryTranslation(label: '文書', blurb: 'PDFの結合、分割、並び替え、透かしなど、あらゆる編集。'),
  ToolCategory.convert: CategoryTranslation(label: '変換', blurb: 'サーバーを経由せずに、形式を自由に変換。'),
};

const Map<ToolStatus, String> toolStatusesJa = <ToolStatus, String>{
  ToolStatus.available: '利用可能',
  ToolStatus.comingSoon: '近日公開',
};

const Map<String, FaqTranslation> faqsJa = <String, FaqTranslation>{
  'Are my photos uploaded anywhere?': FaqTranslation(
    question: '写真はどこかにアップロードされますか？',
    answer:
        'いいえ、されません。Mellisugaはバックエンドを持たない静的サイトなので、ファイルを受け取るサーバー自体が存在しません。開いた写真はページ内でデコードされてメモリ上に保持され、タブを閉じた瞬間に消去されます。',
  ),
  'Does it cost anything, and do I need an account?': FaqTranslation(
    question: '料金はかかりますか？アカウントは必要ですか？',
    answer: '無料で、MITライセンスのもとで公開されているオープンソースです。アカウントもサインインも不要で、透かしやページ数の制限、広告もありません。',
  ),
  'Does it work offline?': FaqTranslation(
    question: 'オフラインでも動作しますか？',
    answer:
        'ページの読み込みが完了すれば以降ネットワーク通信は発生しないため、通信を切った状態でも開いているタブはそのまま使い続けられます。ブラウザに頼りたくない場合のために、Android、Windows、macOS、Linux向けのネイティブ版も用意されています。',
  ),
  'Which browsers are supported?': FaqTranslation(
    question: '対応しているブラウザは？',
    answer:
        'Chrome、Edge、Firefox、Safariの最新バージョンであれば、パソコンでもスマートフォンでも利用できます。アプリの描画にはCanvasKitを使用しており、CDNから取得するのではなくページに同梱されています。',
  ),
  'Can I use the exported files commercially?': FaqTranslation(
    question: '書き出したファイルを商用利用できますか？',
    answer: 'はい、可能です。Mellisugaは書き出した成果物に対する権利を一切主張せず、透かしを追加することもなく、PDFや画像に追跡用の情報を埋め込むこともありません。',
  ),
  'What is a "bee hummingbird" doing on a printing app?': FaqTranslation(
    question: '印刷アプリになぜ「マメハチドリ」が登場するのですか？',
    answer:
        'Mellisuga helenae（マメハチドリ）は世界最小の鳥です。このツールも同じことを目指しています — 1枚の用紙の中に、そしてダウンロードするファイルの中に、できるだけ多くのものを詰め込むことです。',
  ),
};

const BrandTranslation brandJa = BrandTranslation(
  tagline: 'ブラウザで動作する写真・PDFツール。',
  shortDescription: 'あらゆるサイズの写真をA4、Letter、フォト用紙に無駄なく配置します。すべてお使いの端末上で処理され、アップロードは一切行われません。',
  description:
      'Mellisugaは、すべての処理をお使いの端末上だけで行う写真・文書ツール集です。開いたファイルがサーバーへアップロードされることはありません — そもそもサーバーが存在しないからです。',
  nameOrigin:
      'Mellisuga helenae、通称マメハチドリにちなんで名付けられました。世界最小の鳥であり、限られた空間に多くのものを詰め込むこのツールにふさわしいマスコットです。',
);
