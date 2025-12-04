# Tempo AI API

Cloudflare Workers APIサーバー for Tempo AI - パーソナライズされた健康アドバイスを提供するAIプラットフォーム

## 🚀 Quick Start

```bash
# 依存関係のインストール
npm install

# 開発サーバー起動
npm run dev

# APIテスト実行
npm run test:api
```

## 📁 プロジェクト構造

```
backend/
├── src/                     # ソースコード
│   ├── index.ts            # メインエントリーポイント
│   ├── routes/             # APIルート
│   │   ├── health.ts       # ヘルス分析エンドポイント
│   │   └── test.ts         # テスト用エンドポイント
│   ├── services/           # 外部サービス統合
│   │   ├── ai.ts           # Claude API
│   │   └── weather.ts      # Open-Meteo API
│   ├── types/              # TypeScript型定義
│   │   ├── advice.ts       # アドバイス構造
│   │   ├── health.ts       # HealthKit data
│   │   └── weather.ts      # 天気データ
│   └── utils/              # ユーティリティ
│       ├── errors.ts       # エラーハンドリング
│       └── prompts.ts      # AIプロンプト
├── tests/                  # テストファイル
│   ├── data/              # テストデータ
│   │   └── sample-request.json
│   ├── scripts/           # テストスクリプト
│   │   └── test-api.sh    # API統合テスト
│   └── utils/             # ユニットテスト
│       └── errors.test.ts
├── package.json           # パッケージ設定
├── tsconfig.json         # TypeScript設定
├── wrangler.toml         # Cloudflare Workers設定
├── vitest.config.ts      # テスト設定
├── eslint.config.js      # ESLint設定
└── .prettierrc           # Prettier設定
```

## 🛠 開発コマンド

### 基本コマンド

```bash
# 開発サーバー起動 (http://localhost:8787)
npm run dev

# 本番デプロイ
npm run deploy
```

### コード品質チェック

```bash
# TypeScript型チェック
npm run type-check

# ESLintでコードスタイルチェック
npm run lint

# ESLintで自動修正
npm run lint:fix

# Prettierでフォーマット
npm run format

# Prettierのフォーマットチェック
npm run format:check

# 全チェックを一度に実行
npm run validate
```

### テスト

```bash
# ユニットテスト実行
npm run test

# テストをwatch mode で実行
npm run test:watch

# API統合テスト実行 (開発サーバーが起動している必要があります)
npm run test:api
```

### ユーティリティ

```bash
# ビルドファイル削除
npm run clean

# 依存関係の更新確認
npm run deps:check

# 依存関係の更新実行
npm run deps:update
```

## 🔧 環境設定

### 1. 環境変数設定

`.dev.vars`ファイルを作成してAPIキーを設定:

```bash
# .dev.vars
ANTHROPIC_API_KEY=sk-ant-api03-your-api-key-here
```

### 2. 本番環境での設定

```bash
# Claude API キー設定
wrangler secret put ANTHROPIC_API_KEY

# 入力画面でAPIキーを設定
```

## 📡 API エンドポイント

### メインエンドポイント

- `GET /` - API情報
- `GET /api/health/status` - ヘルスチェック
- `POST /api/health/analyze` - HealthKitデータ分析

### テスト用エンドポイント

- `POST /api/test/weather` - 天気API単体テスト
- `POST /api/test/analyze-mock` - モックAI分析

### リクエスト例

```bash
# ヘルス分析
curl -X POST http://localhost:8787/api/health/analyze \
  -H "Content-Type: application/json" \
  -d @tests/data/sample-request.json
```

## 🧪 テスト戦略

### ユニットテスト
- `vitest`使用
- ユーティリティ関数のテスト
- エラーハンドリングのテスト

### 統合テスト
- APIエンドポイントの動作確認
- 外部サービス統合テスト
- `tests/scripts/test-api.sh`で自動実行

## 📚 技術スタック

- **Runtime**: Cloudflare Workers
- **Framework**: Hono
- **Language**: TypeScript
- **AI**: Claude API (Anthropic)
- **Weather**: Open-Meteo API
- **Testing**: Vitest
- **Linting**: ESLint + TypeScript
- **Formatting**: Prettier

## 🏗️ 開発フロー

### 1. 開発開始

```bash
npm run dev                # サーバー起動
npm run test:watch         # テスト監視
```

### 2. コード変更後

```bash
npm run validate          # 型チェック + lint + format
npm run test             # テスト実行
```

### 3. デプロイ前

```bash
npm run validate         # 全チェック
npm run test:api        # 統合テスト
npm run deploy          # デプロイ
```

## 🔍 トラブルシューティング

### よくある問題

1. **型エラーが出る場合**
   ```bash
   npm run type-check
   ```

2. **フォーマットエラー**
   ```bash
   npm run format
   ```

3. **ESLintエラー**
   ```bash
   npm run lint:fix
   ```

4. **APIテストが失敗する場合**
   - 開発サーバーが起動しているか確認
   - `.dev.vars`にAPIキーが設定されているか確認

### パフォーマンス

- **CPU time**: <15ms (Cloudflare Workers課金対象)
- **Wall time**: 10-20秒 (AI分析含む)
- **並列処理**: 天気API + AI分析を効率化

## 📄 ライセンス

ISC
