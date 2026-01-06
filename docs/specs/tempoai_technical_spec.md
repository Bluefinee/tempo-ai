# TempoAI 技術仕様書

**バージョン**: 8.0
**最終更新日**: 2026年1月6日

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [tempoai_product_spec.md](./tempoai_product_spec.md) | プロダクト仕様 |
| [tempoai_metrics_spec.md](./tempoai_metrics_spec.md) | スコア算出アルゴリズム |
| [tempoai_ai_prompt_spec.md](./tempoai_ai_prompt_spec.md) | AIプロンプト仕様 |
| [tempoai_knowledge_base.md](./tempoai_knowledge_base.md) | 科学的根拠 |

---

## 1. システム全体構成

### 1.1 アーキテクチャ概要図

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ユーザーのデバイス                            │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           React Native (Expo) アプリ                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │   │
│  │  │  HealthKit  │  │ AsyncStorage│  │  Location   │         │   │
│  │  │  (iOS)      │  │  (ローカル)  │  │  Service    │         │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘         │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │ HTTPS
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Cloudflare Workers (バックエンド)                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Hono (TypeScript)                                          │   │
│  │  ├─ /api/health   - ヘルスチェック                           │   │
│  │  ├─ /api/weather  - 天気情報 (Open-Meteo経由)                │   │
│  │  └─ /api/advice   - AIアドバイス生成 (Claude経由)            │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    ▼                       ▼
        ┌─────────────────┐     ┌─────────────────┐
        │   Open-Meteo    │     │   Anthropic     │
        │   (天気API)      │     │   Claude API    │
        │   無料           │     │   有料          │
        └─────────────────┘     └─────────────────┘
```

### 1.2 設計原則

| 原則 | 説明 |
|------|------|
| **データベースレス** | ユーザーのヘルスデータはデバイス内のみで処理。サーバー側にDBを持たない |
| **ドメイン駆動** | スコアリング等のビジネスロジックはドメインモデルに凝集 |
| **テスト容易性** | 純粋関数・依存性注入を前提とした設計 |
| **クロスプラットフォーム** | iOS/Android 両対応（React Native） |

### 1.3 データフロー

```
ユーザー操作
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ アプリ内処理（デバイス内完結）                                  │
│                                                             │
│  HealthKit → HealthMetrics → ScoreCalculator → Scores      │
│       │                                                     │
│       └──────────────────────────────────────────┐         │
│                                                   │         │
│  UserProfile + Scores + Weather ──→ AdviceRequest │         │
└───────────────────────────────────────────────────│─────────┘
                                                    │
                                                    ▼ API呼び出し
┌─────────────────────────────────────────────────────────────┐
│ バックエンド処理（Cloudflare Workers）                         │
│                                                             │
│  AdviceRequest ──→ PromptBuilder ──→ Claude API            │
│                                           │                 │
│                                           ▼                 │
│                                    AdviceResponse           │
└─────────────────────────────────────────────────────────────┘
                                                    │
                                                    ▼
                                              アプリに表示
```

---

## 2. 使用技術・ツール・SaaS一覧

### 2.1 モバイルアプリ（フロントエンド）

| カテゴリ | 技術/ツール | バージョン | 用途 |
|---------|------------|-----------|------|
| フレームワーク | **React Native (Expo)** | SDK 54 | クロスプラットフォームモバイルアプリ開発 |
| 言語 | **TypeScript** | 5.x | 型安全な開発 |
| ルーティング | **expo-router** | 6.x | ファイルベースルーティング（Next.js風） |
| 状態管理 | **Zustand** | 5.x | 軽量・シンプルなグローバル状態管理 |
| ローカルストレージ | **AsyncStorage** | - | デバイス内データ永続化（ユーザー設定、キャッシュ） |
| 位置情報 | **expo-location** | 19.x | GPS取得・逆ジオコーディング |
| ネットワーク状態 | **@react-native-community/netinfo** | 11.x | オフライン検出・ネットワーク状態監視 |
| アイコン | **lucide-react-native** | - | UIアイコンライブラリ |
| バリデーション | **Zod** | 4.x | 実行時スキーマバリデーション |

### 2.2 バックエンド

| カテゴリ | 技術/ツール | バージョン | 用途 |
|---------|------------|-----------|------|
| ホスティング | **Cloudflare Workers** | - | サーバーレスエッジコンピューティング |
| フレームワーク | **Hono** | 4.x | 軽量・高速Webフレームワーク |
| 言語 | **TypeScript** | 5.x | 型安全な開発 |
| デプロイツール | **Wrangler** | 3.x | Cloudflare公式CLIツール |
| バリデーション | **Zod** | 3.x | リクエストバリデーション |
| リンター/フォーマッター | **Biome** | 1.9.x | 高速なコード品質管理ツール |
| テスト | **Vitest** | 2.x | 高速ユニットテストフレームワーク |

### 2.3 外部API・SaaS

| サービス | 用途 | 料金体系 | 備考 |
|---------|------|---------|------|
| **Cloudflare Workers** | バックエンドAPI実行環境 | 無料枠: 100,000リクエスト/日 | 世界中のエッジで動作、低レイテンシ |
| **Anthropic Claude API** | AIアドバイス生成 | 従量課金: ~$0.03/リクエスト | Claude Sonnet 4使用、Prompt Caching対応 |
| **Open-Meteo** | 天気・気圧・大気質情報 | 完全無料 | 商用利用可、10,000リクエスト/日 |

### 2.4 開発ツール・CI/CD

| ツール | 用途 |
|--------|------|
| **GitHub** | ソースコード管理・Issue管理 |
| **GitHub Actions** | CI/CD（lint, test, build, type-check） |
| **CodeRabbit** | AI自動コードレビュー |
| **pnpm** | 高速パッケージマネージャー |
| **Husky** | Git pre-commitフック |
| **lint-staged** | ステージングファイルのみlint実行 |

### 2.5 将来統合予定

| 技術 | 用途 | 状態 |
|------|------|------|
| **react-native-health** | HealthKit連携 (iOS) | Phase 8で実装予定 |
| **react-native-health-connect** | Health Connect連携 (Android) | 計画中 |
| **Supabase** | ユーザー認証・クラウド同期 | 将来検討 |

---

## 3. Cloudflare Workers 詳細

### 3.1 Cloudflare Workersとは

Cloudflare Workersは、Cloudflareのエッジネットワーク上でJavaScript/TypeScriptを実行できるサーバーレスプラットフォーム。

**特徴:**
- **エッジ実行**: 世界300+のデータセンターでユーザーに最も近い場所で実行
- **低レイテンシ**: コールドスタートが数ミリ秒
- **スケーラブル**: 自動スケーリング、インフラ管理不要
- **無料枠が大きい**: 100,000リクエスト/日まで無料

**本プロジェクトでの役割:**
- APIサーバーとして機能
- Claude APIへのプロキシ（APIキーを隠蔽）
- Open-Meteo APIへのプロキシ
- CORS処理

### 3.2 ワーカー構成

```
backend/
├── wrangler.toml          # Cloudflare設定ファイル
├── src/
│   ├── index.ts           # エントリーポイント（Honoアプリ）
│   ├── routes/
│   │   ├── advice.ts      # POST /api/advice
│   │   ├── weather.ts     # GET /api/weather
│   │   └── health.ts      # GET /api/health
│   ├── services/
│   │   └── advice/
│   │       ├── AdviceService.ts    # ビジネスロジック
│   │       ├── AnthropicClient.ts  # Claude API呼び出し
│   │       ├── PromptBuilder.ts    # プロンプト構築
│   │       └── types.ts            # 型定義
│   └── middleware/
│       ├── errorHandler.ts
│       └── logger.ts
```

### 3.3 環境変数とシークレット

| 種類 | 変数名 | 説明 | 設定方法 |
|------|--------|------|---------|
| 環境変数 | `ENVIRONMENT` | 実行環境識別子 | wrangler.toml |
| シークレット | `ANTHROPIC_API_KEY` | Claude APIキー | `wrangler secret put` |

### 3.4 デプロイコマンド

```bash
# ローカル開発サーバー起動
pnpm dev

# ステージング環境へデプロイ
pnpm deploy:staging

# 本番環境へデプロイ
pnpm deploy

# シークレット設定
npx wrangler secret put ANTHROPIC_API_KEY

# デプロイ状況確認
npx wrangler deployments list
```

---

## 4. AIとのやりとり詳細

### 4.1 AI呼び出しが発生するタイミング

| タイミング | トリガー | 頻度 | 料金発生 |
|-----------|---------|------|---------|
| **毎朝のアドバイス生成** | ホーム画面表示時（1日1回） | 1回/日/ユーザー | ✅ あり |
| **手動リフレッシュ** | ユーザーがリフレッシュボタンを押した時 | ユーザー操作時 | ✅ あり |
| **天気情報取得** | 位置情報更新時 | 数回/日 | ❌ なし（Open-Meteo無料） |

### 4.2 AI呼び出しフロー

```
アプリ                    バックエンド              Anthropic API
  │                          │                         │
  │  POST /api/advice        │                         │
  │  (AdviceRequest)         │                         │
  │ ─────────────────────────>                         │
  │                          │                         │
  │                          │  PromptBuilder          │
  │                          │  ・System Prompt構築    │
  │                          │  ・User Data XML構築    │
  │                          │                         │
  │                          │  messages.create()      │
  │                          │ ────────────────────────>
  │                          │                         │
  │                          │                         │ Claude処理
  │                          │                         │ ・ヘルスデータ分析
  │                          │                         │ ・パーソナライズ
  │                          │                         │
  │                          │  <────────────────────────
  │                          │  (JSON Response)        │
  │                          │                         │
  │                          │  parseResponse()        │
  │                          │  ・JSONパース           │
  │                          │  ・バリデーション        │
  │                          │                         │
  │  <─────────────────────────                        │
  │  (AdviceResponse)        │                         │
  │                          │                         │
  │  画面に表示              │                         │
```

### 4.3 Prompt Caching（コスト最適化）

Anthropic APIのPrompt Caching機能を使用して、System Promptをキャッシュし、コストを削減。

**仕組み:**
- System Prompt（固定部分）にキャッシュマーカーを付与
- 2回目以降の呼び出しではキャッシュされたPromptを再利用
- 入力トークン数を大幅削減

**コスト削減効果:**
- キャッシュヒット時: 入力コスト90%削減
- 5分間のキャッシュTTL

```typescript
// AnthropicClient.ts での実装
const response = await this.client.beta.promptCaching.messages.create({
  model: 'claude-sonnet-4-20250514',
  max_tokens: 2000,
  system: [
    {
      type: 'text',
      text: systemPrompt,
      cache_control: { type: 'ephemeral' },  // キャッシュ有効化
    },
  ],
  messages: [{ role: 'user', content: userDataXml }],
});
```

### 4.4 APIリクエスト/レスポンス形式

#### リクエスト (AdviceRequest)

アプリからバックエンドに送信されるデータ:

| フィールド | 内容 | ソース |
|-----------|------|--------|
| `user` | ニックネーム、年齢、性別、クロノタイプ、目標就寝時刻 | オンボーディングで収集 |
| `healthMetrics.sleep` | 睡眠時間、深い睡眠、REM睡眠など | HealthKit（現在はモック） |
| `healthMetrics.hrv` | HRV値、30日ベースライン | HealthKit（現在はモック） |
| `healthMetrics.activity` | 歩数、アクティブ時間 | HealthKit（現在はモック） |
| `rhythmAnalysis` | リズム安定性、標準偏差 | アプリ内で計算 |
| `weather` | 気温、気圧、天気コード、UV指数など | Open-Meteo API経由 |

#### レスポンス (AdviceResponse)

Claude APIが生成し、バックエンドがパースして返すデータ:

| フィールド | 内容 | 用途 |
|-----------|------|------|
| `summary` | 100-150文字の要約 | ホーム画面のカード表示 |
| `insight.greeting` | 挨拶 | 詳細画面の冒頭 |
| `insight.condition` | 今日のコンディション総評 | 詳細画面 |
| `insight.sleep` | 睡眠分析 | 詳細画面 |
| `insight.rhythm` | リズム分析 | 詳細画面 |
| `insight.environment` | 環境影響予測 | 詳細画面 |
| `insight.advice` | 今日の過ごし方提案 | 詳細画面 |
| `insight.closing` | クロージング | 詳細画面の末尾 |
| `recommendedAction` | Quick Action（呼吸法など） | ホーム画面のアクションボタン |

### 4.5 コスト詳細

#### 単価（Claude Sonnet 4）

| 項目 | 単価 |
|------|------|
| 入力トークン | $3.00 / 1M tokens |
| 出力トークン | $15.00 / 1M tokens |
| キャッシュ書き込み | $3.75 / 1M tokens |
| キャッシュ読み取り | $0.30 / 1M tokens |

#### 1リクエストあたりの見積もり

| 項目 | トークン数 | コスト |
|------|-----------|--------|
| System Prompt（入力） | ~2,000 | キャッシュ時: ~$0.0006 |
| User Data（入力） | ~1,500 | ~$0.0045 |
| Output | ~1,500 | ~$0.0225 |
| **合計** | ~5,000 | **~$0.03/リクエスト** |

#### 月間コスト試算

| ユーザー数 | 月間リクエスト | 月額コスト |
|-----------|---------------|-----------|
| 100人 | 3,000回 | ~$90 |
| 1,000人 | 30,000回 | ~$900 |
| 10,000人 | 300,000回 | ~$9,000 |

### 4.6 エラーハンドリングとフォールバック

| エラー種別 | 対応 |
|-----------|------|
| ネットワークエラー | リトライ（3回まで、指数バックオフ） |
| Claude APIエラー (429) | レート制限エラー、時間をおいてリトライ |
| Claude APIエラー (5xx) | サーバーエラー、フォールバックメッセージ表示 |
| パースエラー | ログ記録、フォールバックメッセージ表示 |
| タイムアウト | 30秒でタイムアウト、リトライ |

---

## 5. 環境構成と切り分け

### 5.1 環境一覧

| 環境 | 用途 | バックエンドURL | 使用場面 |
|------|------|----------------|---------|
| **ローカル開発** | 開発・デバッグ | `http://localhost:8787` | 日常開発 |
| **ステージング** | 検証・テスト | `https://tempo-ai-api-staging.saintetienne218.workers.dev` | PRレビュー、統合テスト |
| **本番** | リリース版 | （Phase 9で設定） | ユーザー向け |

### 5.2 環境変数設定

#### バックエンド (`backend/wrangler.toml`)

```toml
name = "tempo-ai-api"
main = "src/index.ts"

# ローカル開発
[vars]
ENVIRONMENT = "development"

# ステージング
[env.staging]
name = "tempo-ai-api-staging"
vars = { ENVIRONMENT = "staging" }

# 本番
[env.production]
vars = { ENVIRONMENT = "production" }
```

#### アプリ (`app/.env.local`)

```bash
# ローカル開発時
EXPO_PUBLIC_API_URL=http://localhost:8787

# ステージング接続時
EXPO_PUBLIC_API_URL=https://tempo-ai-api-staging.saintetienne218.workers.dev
```

### 5.3 シークレット管理

Cloudflare Workers Secretsで管理（コードにAPIキーを含めない）:

```bash
# シークレット設定
npx wrangler secret put ANTHROPIC_API_KEY
# → プロンプトでAPIキーを入力

# ステージング環境用
npx wrangler secret put ANTHROPIC_API_KEY --env staging

# シークレット一覧確認
npx wrangler secret list
```

---

## 6. ローカル開発・動作確認手順

### 6.1 初期セットアップ

```bash
# リポジトリクローン
git clone https://github.com/Bluefinee/tempo-ai.git
cd tempo-ai

# バックエンド
cd backend
pnpm install
npx wrangler login  # Cloudflare認証（初回のみ）
npx wrangler secret put ANTHROPIC_API_KEY  # APIキー設定

# アプリ
cd ../app
pnpm install
```

### 6.2 バックエンド動作確認

```bash
cd backend

# 開発サーバー起動
pnpm dev
# → http://localhost:8787 で起動

# 別ターミナルで確認

# 1. ヘルスチェック
curl http://localhost:8787/api/health
# → {"status":"ok","environment":"development",...}

# 2. 天気情報（東京）
curl "http://localhost:8787/api/weather?latitude=35.6762&longitude=139.6503"
# → {"success":true,"data":{"temperature":15.2,...}}

# 3. AIアドバイス生成
curl -X POST http://localhost:8787/api/advice \
  -H "Content-Type: application/json" \
  -d '{
    "user": {"nickname":"テスト","age":30,"gender":"male","chronotype":"intermediate","targetBedtime":"23:00"},
    "healthMetrics": {
      "sleep": {"bedtime":"2026-01-05T23:30:00Z","wakeTime":"2026-01-06T07:00:00Z","durationMinutes":450,"deepSleepMinutes":90,"deepSleepRatio":0.2,"remSleepMinutes":100},
      "hrv": {"value":45,"baseline30d":42,"deviationPercent":7.14},
      "activity": {"stepsYesterday":8000,"activeMinutesYesterday":45}
    },
    "rhythmAnalysis": {"status":"stable","consecutiveStableDays":5,"bedtimeStddevMinutes":25,"wakeTimeStddevMinutes":20},
    "weather": {"temperature":15,"humidity":60,"pressure":1013,"pressureTrend":"stable","weatherCode":1,"uvIndex":3,"airQualityIndex":50,"location":{"latitude":35.6762,"longitude":139.6503,"name":"東京"}}
  }'
# → {"success":true,"data":{"summary":"...","insight":{...}}}
```

### 6.3 アプリ動作確認

```bash
cd app

# 環境変数設定（ローカルバックエンド接続）
echo "EXPO_PUBLIC_API_URL=http://localhost:8787" > .env.local

# Expo開発サーバー起動
pnpm start

# iOSシミュレーターで起動
pnpm ios

# または Androidエミュレーターで起動
pnpm android
```

### 6.4 テスト実行

```bash
# バックエンド
cd backend
pnpm test          # ユニットテスト
pnpm test:coverage # カバレッジ付き
pnpm typecheck     # 型チェック
pnpm check         # lint + format

# アプリ
cd app
pnpm lint          # ESLint
pnpm typecheck     # 型チェック
pnpm test          # Jest
```

---

## 7. ディレクトリ構造

### 7.1 プロジェクト全体

```
tempo-ai/
├── app/                    # React Native (Expo) アプリ
├── backend/                # Cloudflare Workers バックエンド
├── docs/                   # ドキュメント
│   ├── specs/             # 仕様書（本ファイル含む）
│   ├── plans/             # フェーズ実装計画
│   └── cursor/            # Cursor向けタスク
├── ios/                    # レガシーSwiftアプリ（参照用、非アクティブ）
├── .github/                # GitHub Actions CI/CD
│   └── workflows/
├── .claude/                # Claude Code用開発ガイドライン
├── CLAUDE.md              # AI開発ガイドライン
└── README.md              # プロジェクト概要
```

### 7.2 アプリ (`app/`)

```
app/
├── app/                    # expo-router ページ（ファイルベースルーティング）
│   ├── _layout.tsx        # ルートレイアウト
│   ├── index.tsx          # エントリー（リダイレクト）
│   ├── (onboarding)/      # オンボーディングフロー
│   │   ├── index.tsx      # Welcome
│   │   ├── healthkit.tsx  # HealthKit説明
│   │   ├── nickname.tsx   # ニックネーム入力
│   │   ├── basic-info.tsx # 年齢・性別など
│   │   └── ...
│   ├── (main)/            # メインタブ
│   │   ├── _layout.tsx    # Tab Navigator
│   │   ├── index.tsx      # Home
│   │   ├── analytics.tsx  # Analytics
│   │   └── settings.tsx   # Settings
│   └── insight-detail.tsx # AI Insight詳細（モーダル）
├── src/
│   ├── api/               # APIクライアント
│   │   ├── client.ts      # fetch wrapper
│   │   ├── config.ts      # API URL設定
│   │   ├── types.ts       # API型定義
│   │   ├── helpers/       # リクエストビルダー
│   │   └── utils/         # リトライロジック
│   ├── components/        # 共通UIコンポーネント
│   ├── domain/
│   │   ├── models/        # ドメインモデル型定義
│   │   └── services/      # スコア計算ロジック
│   ├── hooks/             # カスタムフック
│   ├── infrastructure/    # 外部サービス抽象化
│   │   ├── health/        # HealthKit抽象化
│   │   └── location/      # 位置情報抽象化
│   ├── stores/            # Zustand ストア
│   ├── theme/             # デザイントークン
│   ├── constants/         # 定数・モックデータ
│   └── utils/             # ユーティリティ
├── assets/                # 画像・フォント
├── app.json               # Expo設定
├── tsconfig.json          # TypeScript設定
└── package.json           # 依存関係
```

### 7.3 バックエンド (`backend/`)

```
backend/
├── src/
│   ├── index.ts           # エントリーポイント（Honoアプリ）
│   ├── routes/            # APIルートハンドラー
│   │   ├── advice.ts      # POST /api/advice
│   │   ├── weather.ts     # GET /api/weather
│   │   └── health.ts      # GET /api/health
│   ├── services/
│   │   └── advice/        # AIアドバイス生成サービス
│   │       ├── AdviceService.ts      # メインサービス
│   │       ├── AnthropicClient.ts    # Claude API呼び出し
│   │       ├── PromptBuilder.ts      # プロンプト構築
│   │       ├── types.ts              # 型定義
│   │       └── *.test.ts             # テスト
│   ├── middleware/        # Honoミドルウェア
│   │   ├── errorHandler.ts
│   │   └── logger.ts
│   └── utils/             # ユーティリティ
│       └── result.ts      # Result型（Rust風エラーハンドリング）
├── wrangler.toml          # Cloudflare Workers設定
├── vitest.config.ts       # Vitest設定
├── biome.json             # Biome設定
├── tsconfig.json          # TypeScript設定
└── package.json           # 依存関係
```

---

## 8. 現在のフェーズ状況

### 8.1 完了済みフェーズ

| Phase | 内容 | 主な成果物 |
|-------|------|-----------|
| Phase 1-3 | 初期設計・プロトタイプ | 仕様書、Swiftプロトタイプ |
| Phase 4 | AI連携（バックエンド） | Claude API連携、Prompt Caching |
| Phase 5 | React Native UI実装 | 全画面UI、オンボーディング |
| Phase 6 | バックエンド整理・最適化 | Biome導入、テスト整備 |
| Phase 7 | API連携（アプリ↔バックエンド） | 天気API、アドバイスAPI連携 |

### 8.2 次のフェーズ

| Phase | 内容 | 主な作業 |
|-------|------|---------|
| **Phase 8** | HealthKit連携 | react-native-health導入、実ヘルスデータ取得 |
| Phase 9 | リリース準備 | 本番環境、App Store申請 |

### 8.3 Phase 7完了時点での動作確認範囲

| 機能 | 状態 | 確認方法 |
|------|------|---------|
| オンボーディングフロー | ✅ 動作 | Expoアプリで確認 |
| ホーム画面表示 | ✅ 動作 | Expoアプリで確認 |
| 天気情報取得 | ✅ 動作 | 実API呼び出し（Open-Meteo） |
| AIアドバイス生成 | ✅ 動作 | 実API呼び出し（Claude） |
| スコア計算・表示 | ⚠️ モック | モックデータで動作 |
| HealthKitデータ取得 | ❌ 未実装 | Phase 8で実装 |

---

## 9. セキュリティ

### 9.1 データ保護

| 原則 | 実装 |
|------|------|
| **データ最小化** | ヘルスデータはデバイス内のみで処理、サーバーには送信後破棄 |
| **暗号化通信** | HTTPS通信のみ（Cloudflare自動対応） |
| **シークレット管理** | Cloudflare Secrets Store使用、コードにキーを含めない |

### 9.2 API保護（現状と将来）

| 項目 | 現状 | 将来計画 |
|------|------|---------|
| CORS | 全オリジン許可 | 特定ドメインのみ許可 |
| レート制限 | なし | Cloudflare Rate Limiting |
| 認証 | なし | OAuth / JWT |
| APIキー | サーバー側のみ | クライアント認証追加 |

---

## 10. 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 5.0 | 2025-01-01 | ドメインモデル中心の設計に全面改訂 |
| 6.0 | 2025-01-01 | Geminiフィードバック反映 |
| 7.0 | 2026-01-06 | Swift/iOS → React Native (Expo) マイグレーション |
| 8.0 | 2026-01-06 | コード削除、インフラ・ツール・AI呼び出し・動作確認方法を包括的に追記 |
