# AGENTS.md — sasuke_short プロジェクト運用規約（エージェント向け・Knowledge First版）

このリポジトリは「メモ → クリーン → 原稿」の3段階を内部で維持しつつ、ユーザー操作は最小（1コマンド/1メッセージ）で完了できるように設計します。

- 運用段階: 01_メモ → 02_クリーン → 03_原稿
- ナレッジ優先: knowledge配下のドキュメントを常に参照し、原則としてテンプレ・台本・用語を統一します。

必須ナレッジ（常時参照）
- knowledge/2025-09-15_viral-script-models.md（原稿化の要件）
- knowledge/2025-09-16_sasuke-sns-concept.md（SASスコア/BEタグ/運用OS）
- knowledge/2025-09-16_sns-template.md（ショート台本テンプレ）
- knowledge/2025-09-16_sns-pattern-idea.md（パターンとBEタグ）

## 共通ルール
- 文体は原則「です・ます」。
- ファイル名は `YYYY-MM-DD_スラグ.md`。3段階で同一スラグを維持します。
- 各ファイル先頭にフロントマターを付与します：
  ```yaml
  ---
  title: <タイトル>
  slug: <YYYY-MM-DD_スラグ>
  phase: memo | clean | manuscript
  status: draft | review | final
  tags: [<タグ>, ...]
  created: <YYYY-MM-DD>
  updated: <YYYY-MM-DD>
  source: <前段階の相対パス または 空文字>
  ---
  ```
- 生成物は該当ディレクトリへ保存し、可能なら `scripts/gen_index.sh` で `INDEX.md` を更新します。
- 既存ファイルは上書きせず `-v2`, `-v3` を末尾に付けて新規作成します（テンプレ仕様を守るため）。

## スラッシュコマンド（会話内でも scripts でも可）

### `/ship "タイトル" [タグ]`（推奨・一発仕上げ）
- 目的: メモ→クリーン→原稿を一括実行して3ファイルを作成します。
- 実装: `scripts/ship.sh` が `new_memo.sh` → `research.sh` → `draft.sh` → `gen_index.sh` を順に実行します。
- 出力: 生成パス3本（メモ/クリーン/原稿）。

### `/onepass <スラグ|メモのパス>`（既存メモから一気通貫）
- 目的: 既存メモを入力し、クリーン→原稿まで一気に生成します。
- 実装: `scripts/onepass.sh` が `research.sh` → `draft.sh` を実行します。

### `/memo "タイトル" [タグ,カンマ区切り]`
- 目的: 01_メモに当日ファイルを新規作成（テンプレ適用）。
- 実装: `scripts/new_memo.sh`。

### `/research <スラグ|メモのパス|トピック>`
- 目的: メモを元に、信頼できる情報源を調査して 02_クリーン を作成します。
- 必須: web.run を使用し、重要事実は最大5点まで出典を明示。更新の早い情報（価格/仕様/人物/規約/スケジュール等）は必ず最新を確認します。
- 手順（厳守）:
  1) 入力がスラグ/パスの場合は元メモを読み、要点を抽出。
  2) web.run で一次情報（公式Docs/公式ブログ/学術/大手メディア）を優先して収集。
  3) 主要ソースを比較し、相違があれば並記してバランスを確保。
  4) `templates/clean.md` の構造に沿って再構成（主張→根拠→例→反論/限界→未解決）。
  5) 末尾に「参考URL」を Markdown リンクで列挙（タイトル・ドメイン・URL）。
  6) `02_クリーン/YYYY-MM-DD_スラグ.md` に保存。`source` は元メモ相対パス。
- 出力基準:
  - 生成や推測は「推測」と明示。未確定は断定しない。
  - 用語を統一し、重複を削除。見出しだけで流れが追えること。

### `/draft <スラグ|クリーンのパス>`
- 目的: 02_クリーンを読者向け 03_原稿 に変換します。
- 必読: `knowledge/2025-09-15_viral-script-models.md` を適用（120字リード/H2-H3/各段落冒頭に主張/比喩1本/語尾連続抑制/「3行サマリ」「次の一歩」）。
- 実装: `scripts/draft.sh`（`templates/manuscript.md` 準拠）。

### 補助コマンド
- `/update-index` → `scripts/gen_index.sh`
- `/validate` → `scripts/validate_front_matter.sh`（front matter整合チェック）

## リサーチと出典（web.runポリシー）
- `/research` を受けた場合は必ず web.run を使用します（最新・不安定情報: 価格/仕様/法律/人事/規約/スケジュール/数値主張/新語など）。
- 出典は最大5点、一次情報優先。本文では要旨を記述し、末尾にMarkdownリンクで列挙します。
- 出典間で見解が分かれる場合は、相違点を並記し判断保留を明記します。

## 品質ゲート（自動）
- `scripts/validate_front_matter.sh` を適宜実行し、front matter の欠落を検出します。
- 02_クリーン: 主張/Why/How/例/限界/未解決（誰が/何を/どこで/いつまで）が揃っているかをセルフチェックします。
- 03_原稿: リード120字/H2-H3/段落冒頭の要約/比喩1本/3行サマリ/次の一歩 を満たします。

## 保存先と命名
- `01_メモ/YYYY-MM-DD_スラグ.md`
- `02_クリーン/YYYY-MM-DD_スラグ.md`（`source` はメモ相対パス）
- `03_原稿/YYYY-MM-DD_スラグ.md`（`source` はクリーン相対パス）

## 実装メモ（エージェント向け）
- `scripts/sasuke.sh` は `/memo` `/research` `/draft` に加え、`/ship` `/onepass` `/update-index` `/validate` を受け付けます。
- 既存テンプレ（templates/*.md）とナレッジ（knowledge/*.md）を常に参照し、用語・構成・BEタグを揃えます。
 - 参考: BEタグ辞書は `knowledge/2025-09-21_be-tags.md` を参照します。
