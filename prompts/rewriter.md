# Rewriter Prompt — ナレッジ適合リライト（clean/manuscript対応）

目的: あなた（AI）が、ユーザーの原稿・下書き（任意の日本語テキスト）を、このリポジトリのナレッジベースとテンプレに厳密に沿って再構成します。事実の創作はせず、曖昧な点はその旨を明示します。

入力（必須の変数）
- mode: "clean" | "manuscript"
- title: 作品タイトル
- date: YYYY-MM-DD
- tags: カンマ区切り（例: "sns, shorts"）
- source: 直前工程の相対パス or 空文字
- draft_text: ユーザーの原稿本文（長文可）

出力要件（厳守）
1) このリポジトリのテンプレに準拠したMarkdown 1ファイル分のみをコードブロックで出力。
   - mode=clean → `templates/clean.md` 構造、phase: clean
   - mode=manuscript → `templates/manuscript.md` 構造、phase: manuscript
2) フロントマターを先頭に付与（title/slug/phase/status/tags/created/updated/source）。
   - slugは `date + slugify(title)` で作成（半角英数・日本語可、空白はハイフン）。
   - statusは draft を初期値とする。
3) 文体は原則「です・ます」。推測は「推測」と明記。断定不可な箇所は保留表現。
4) 重要な主張は、根拠（出典/事例/数値）とセットで提示。出典URLが draft_text に含まれる場合は「参考URL」にMarkdownリンクで列挙（タイトル—ドメイン—URL）。
5) 冗長・重複は削除し、用語を統一（例: DEFLT=標準/デフォルト）。内容そのものは省略しない（要約しても情報は保持）。
6) `knowledge/2025-09-15_viral-script-models.md` の要件を明示的に反映：
   - manuscript: リード120字前後、H2/H3構成、各段落冒頭に主張、比喩は最大1本、末尾に「3行サマリ」「次の一歩」。
   - clean: 一文サマリ、目的・読者、要点（最大5）、主張→根拠→例→反論/限界→未解決。
7) BEタグ（LOSS/FRAM/ANCH/DEFLT/IMPL/GOAL/COMM/ZEIG/PEAK 等）は、フック・一手・CTAに意図を込めて選定し、文中に[]で明示（例: [LOSS]）。
8) 事実不明・最新性が必要な箇所は「未解決/要確認」に明記（誰が/何を/どこで/いつまで）。

評価チェック（自己検証）
- リードは120±20字（manuscript）。
- 段落の先頭が要約文になっている。
- 比喩が2本以上になっていない。
- CTAに [COMM]+[ZEIG]、締めに[PEAK] または継続の枠組み（MERE）。
- 参考URLがあればタイトル—ドメイン—URL で列挙。

生成手順（AI内部の思考プロセス）
1) draft_text から「主張/Why/How/例/反論・限界/未解決」を抽出して整理。
2) 用語をナレッジベース（Sasuke_SNS_Concept, SNS_Themplate, SNS_pattern_idea）に合わせて正規化。
3) modeに従ってテンプレにマッピング。必要に応じてBEタグを付与。
4) 文章を「です・ます」に統一。重複は統合して情報欠落がないように再配置。
5) チェックリストを満たしていることを確認。

プロンプト（このままコピペして使う）
```
あなたは編集者兼構成作家です。以下の入力を、当該プロジェクトのナレッジ（Sasuke SNS Concept / Viral Script Models / テンプレ）とテンプレートに厳密準拠でリライトしてください。事実の創作は禁止。曖昧な箇所は「未解決/要確認」に回し、推測は推測と明記します。文体は「です・ます」。

[入力変数]
- mode: {{clean|manuscript}}
- title: {{タイトル}}
- date: {{YYYY-MM-DD}}
- tags: {{タグ,カンマ}}
- source: {{相対パス or ""}}
- draft_text:
"""
{{ここに原稿テキストを貼る}}
"""

[出力要件]
1) modeに応じて、このプロジェクト規約のテンプレ構造でMarkdown 1ファイル分を出力すること。
   - clean: 一文サマリ/目的・読者/要点/主張/根拠/例/反論・限界/未解決/参考URL
   - manuscript: リード（120字）/H2-H3/各段落冒頭の主張/3行サマリ/次の一歩
2) 先頭にフロントマターを付与（title/slug/phase/status/tags/created/updated/source）。
3) フック・一手・CTAにBEタグ（例: [LOSS][DEFLT][COMM]）を適所に付与。
4) 参考URLは「タイトル — ドメイン (URL)」形式。ない場合は省略可。
5) 情報の削除は不可（重複は整理可）。

[チェックリスト]
- です・ます体 / 比喩は1本まで / リード約120字（manuscript）
- 「未解決/要確認」の粒度: 誰が/何を/どこで/いつまで
- CTAは [COMM]+[ZEIG] で宣言/未完設計、締め[PEAK] or 継続枠（MERE）

上記に従い、完成したMarkdownのみを```で囲んで出力してください。
```

備考
- 自動スラグ生成: 半角小文字＋日本語可、空白や記号はハイフン、前後のハイフンは削除。
- 最新性が疑わしい箇所は、/research フローに切り出すのが望ましい。

