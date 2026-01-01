# TempoAI 開発開始プロンプト

以下のプロンプトをClaude Codeに貼り付けて開発を開始してください。

---

## 🚀 起動プロンプト（これをコピペ）

```
TempoAIプロジェクトの開発を開始します。

## プロジェクト概要
TempoAIは、サーカディアンリズム（体内時計）と自律神経を整え、日々のパフォーマンスを最適化するAIパートナーアプリです。

## 開発方針
1. **仕様書駆動開発**: docs/specs/ 配下の仕様書に従って実装
2. **テスト駆動開発（TDD）**: テストを先に書いてから実装
3. **フェーズ分割**: 6つのフェーズに分けて、各フェーズごとにPRを作成
4. **品質基準**: CLAUDE.md の規約に従う

## 最初のタスク

### 1. プロジェクト状態の確認
まず以下を確認してください：
- プロジェクト構造（ios/, backend/, docs/）
- 既存の実装状況
- docs/specs/ 配下の仕様書一覧

### 2. 仕様書の読み込み
以下の仕様書を順に読んで、プロジェクトの全体像を把握してください：
1. docs/specs/product-spec.md （プロダクト仕様・画面構成）
2. docs/specs/technical-spec.md （技術仕様・ドメインモデル）
3. docs/specs/metrics-spec.md （スコア算出アルゴリズム）
4. docs/specs/ai-prompt-spec.md （AIプロンプト設計）
5. docs/specs/ui-spec.md （UI/UXデザイン仕様）
6. docs/specs/knowledge-base.md （科学的根拠）

### 3. マスタープロンプトの確認
TEMPOAI_MASTER_PROMPT.md を読んで、開発ワークフローとフェーズ詳細を確認してください。

### 4. 開発開始
プロジェクトの現状を確認した上で、どのフェーズから開始すべきか判断し、
そのフェーズの IMPLEMENTATION_PLAN.md を作成してください。

## フェーズ一覧
- Phase 1: Backend基盤（Hono + Open-Meteo API）
- Phase 2: iOS基盤 + HealthKit連携
- Phase 3: スコア計算エンジン
- Phase 4: AI連携（Claude API）
- Phase 5: UI実装（SwiftUI）
- Phase 6: 統合・最終調整

## 重要な制約
- 医学的アドバイス・診断は絶対に行わない
- any型は使用禁止（unknownを使用）
- 各フェーズ完了時にPRを作成
- 3回試行ルール：同じ問題で3回失敗したらアプローチを変更

準備ができたら、プロジェクトの現状報告と開始フェーズの提案をしてください。
```

---

## 📂 事前準備チェックリスト

Claude Codeを起動する前に、以下を確認してください：

### 1. 仕様書の配置

```
tempo-ai/
├── docs/
│   └── specs/
│       ├── product-spec.md      ← tempoai_product_spec.md をリネーム
│       ├── technical-spec.md    ← tempoai_technical_spec.md をリネーム
│       ├── metrics-spec.md      ← tempoai_metrics_spec.md をリネーム
│       ├── ai-prompt-spec.md    ← tempoai_ai_prompt_spec.md をリネーム
│       ├── ui-spec.md           ← ui-spec.md をコピー
│       └── knowledge-base.md    ← tempoai_knowledge_base.md をリネーム
├── .claude/
│   ├── swift-coding-standards.md   （作成が必要な場合）
│   ├── typescript-hono-standards.md （作成が必要な場合）
│   └── ux_concepts.md               （作成が必要な場合）
├── CLAUDE.md
├── TEMPOAI_MASTER_PROMPT.md
└── README.md
```

### 2. ファイルのリネーム/移動コマンド

```bash
# docs/specs/ ディレクトリ作成
mkdir -p docs/specs

# 仕様書を移動・リネーム
mv tempoai_product_spec.md docs/specs/product-spec.md
mv tempoai_technical_spec.md docs/specs/technical-spec.md
mv tempoai_metrics_spec.md docs/specs/metrics-spec.md
mv tempoai_ai_prompt_spec.md docs/specs/ai-prompt-spec.md
mv ui-spec.md docs/specs/ui-spec.md
mv tempoai_knowledge_base.md docs/specs/knowledge-base.md

# マスタープロンプトをルートに配置
mv TEMPOAI_MASTER_PROMPT.md ./
```

### 3. 既存のCIが動作することを確認

```bash
# Backend
cd backend
pnpm install
pnpm check
pnpm test

# iOS
# Xcode で ⌘+U を実行
```

---

## 🔄 フェーズ進行時のプロンプト

### フェーズ開始時

```
Phase N: [フェーズ名] を開始します。

1. docs/specs/ の関連仕様書を再確認してください
2. IMPLEMENTATION_PLAN.md を作成してください
3. feature/phase-N-[name] ブランチを作成してください
4. TDDで実装を進めてください
```

### フェーズ完了時

```
Phase N が完了しました。

1. 全テストがパスしていることを確認してください
2. Lint/Formatエラーがないことを確認してください
3. 変更をコミットしてプッシュしてください
4. GitHub PRを作成してください（ベース: main）
5. IMPLEMENTATION_PLAN.md を更新してください
```

### 問題発生時

```
[問題の説明]

1. エラーメッセージを分析してください
2. 考えられる原因を列挙してください
3. 3回試行ルールに従い、アプローチを変更する必要があるか判断してください
4. 解決策を提案してください
```

---

## 💡 Tips

### Claude Codeの効果的な使い方

1. **コンテキストを維持**: 長いセッションでは定期的に仕様書を参照させる
2. **小さく進める**: 大きな変更は避け、コンパイル可能な単位でコミット
3. **テストを重視**: テストが先、実装は後
4. **PRレビューを活用**: CodeRabbitが自動レビューしてくれる

### よくある問題と対処法

| 問題 | 対処法 |
|------|--------|
| 仕様書の内容を忘れている | 「docs/specs/xxx.md を再読してください」と指示 |
| テストが書かれていない | 「このファイルのテストを先に書いてください」と指示 |
| any型が使われている | 「any型をunknownに置き換えてください」と指示 |
| PRが大きすぎる | フェーズをサブフェーズに分割 |

---

**最終更新**: 2025年1月1日
