# TempoAI

**"Tune Your Rhythm"**

サーカディアンリズム（体内時計）と自律神経を整え、日々のパフォーマンスを最適化するAIパートナーアプリ。

---

## コンセプト

ヘルスデータと気象データをAIが分析し、あなた固有の「テンポ」に合わせたパーソナライズされたアドバイスを毎朝お届けします。

**設計思想**: データベースレス × ヘルスデータ × 生成AI
- **プライバシー重視**: ヘルスケアデータは端末内完結
- **軽量設計**: サーバーはAI連携のプロキシのみ
- **クロスプラットフォーム**: iOS / Android 両対応

---

## システム構成

```
┌─────────────────────────────────────────────────────────────┐
│  React Native (Expo) アプリ                                  │
│  ・オンボーディング、ホーム画面、設定                          │
│  ・HealthKit連携（Phase 8で実装予定）                         │
│  ・Zustand + AsyncStorage で状態管理                         │
└─────────────────────────────────────────────────────────────┘
                              │ HTTPS
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Cloudflare Workers (バックエンド)                           │
│  ・Hono フレームワーク                                       │
│  ・Claude API へのプロキシ（APIキー隠蔽）                     │
│  ・Open-Meteo API への中継                                  │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │  Open-Meteo     │             │  Anthropic      │
    │  (天気API・無料) │             │  Claude API     │
    └─────────────────┘             └─────────────────┘
```

---

## 技術スタック

### フロントエンド（モバイルアプリ）

| 技術 | 用途 |
|------|------|
| React Native (Expo SDK 54) | クロスプラットフォーム開発 |
| TypeScript | 型安全な開発 |
| expo-router | ファイルベースルーティング |
| Zustand | 状態管理 |
| AsyncStorage | ローカルストレージ |

### バックエンド

| 技術 | 用途 |
|------|------|
| Cloudflare Workers | サーバーレスエッジコンピューティング |
| Hono | 軽量Webフレームワーク |
| TypeScript | 型安全な開発 |
| Biome | Linter/Formatter |
| Vitest | ユニットテスト |

### 外部サービス

| サービス | 用途 | 料金 |
|---------|------|------|
| Cloudflare Workers | APIホスティング | 無料枠: 100,000リクエスト/日 |
| Claude API (Sonnet 4) | AIアドバイス生成 | ~$0.03/リクエスト |
| Open-Meteo | 天気・気圧情報 | 完全無料 |

---

## クイックスタート

### 必要環境

- Node.js 20+
- pnpm 9+
- Expo CLI (`npx expo`)
- iOS Simulator (macOS) または Android Emulator
- Cloudflare アカウント（バックエンド用）

### 1. リポジトリクローン

```bash
git clone https://github.com/Bluefinee/tempo-ai.git
cd tempo-ai
```

### 2. バックエンドセットアップ

```bash
cd backend
pnpm install

# Cloudflare認証（初回のみ）
npx wrangler login

# Claude APIキー設定
npx wrangler secret put ANTHROPIC_API_KEY

# ローカル開発サーバー起動
pnpm dev
# → http://localhost:8787
```

### 3. アプリセットアップ

```bash
cd app
pnpm install

# 環境変数設定（ローカルバックエンド接続）
echo "EXPO_PUBLIC_API_URL=http://localhost:8787" > .env.local

# Expo開発サーバー起動
pnpm start

# iOSシミュレーターで起動
pnpm ios
```

---

## 開発コマンド

### バックエンド (`backend/`)

```bash
pnpm dev              # ローカル開発サーバー
pnpm test             # ユニットテスト
pnpm test:coverage    # カバレッジ付きテスト
pnpm typecheck        # 型チェック
pnpm check            # lint + format チェック
pnpm deploy           # 本番デプロイ
pnpm deploy:staging   # ステージングデプロイ
```

### アプリ (`app/`)

```bash
pnpm start            # Expo開発サーバー
pnpm ios              # iOSシミュレーター起動
pnpm android          # Androidエミュレーター起動
pnpm lint             # ESLint
pnpm typecheck        # 型チェック
pnpm test             # Jest テスト
```

---

## APIエンドポイント

| エンドポイント | メソッド | 説明 |
|--------------|---------|------|
| `/api/health` | GET | ヘルスチェック |
| `/api/weather` | GET | 天気情報取得 |
| `/api/advice` | POST | AIアドバイス生成 |

### 動作確認例

```bash
# ヘルスチェック
curl http://localhost:8787/api/health

# 天気情報（東京）
curl "http://localhost:8787/api/weather?latitude=35.6762&longitude=139.6503"
```

---

## プロジェクト構造

```
tempo-ai/
├── app/                    # React Native (Expo) アプリ
│   ├── app/               # expo-router ページ
│   │   ├── (onboarding)/  # オンボーディングフロー
│   │   └── (main)/        # メインタブ (Home, Analytics, Settings)
│   └── src/
│       ├── api/           # APIクライアント
│       ├── components/    # UIコンポーネント
│       ├── domain/        # ドメインモデル・サービス
│       ├── stores/        # Zustand ストア
│       └── infrastructure/ # Health/Location抽象化
├── backend/                # Cloudflare Workers API
│   └── src/
│       ├── routes/        # APIエンドポイント
│       └── services/      # Claude AI, Weather
├── docs/                   # ドキュメント
│   └── specs/             # 仕様書
└── .claude/               # AI開発ガイドライン
```

---

## ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [技術仕様書](docs/specs/tempoai_technical_spec.md) | システム構成・インフラ・動作確認方法 |
| [プロダクト仕様](docs/specs/tempoai_product_spec.md) | 画面構成・機能仕様 |
| [メトリクス仕様](docs/specs/tempoai_metrics_spec.md) | スコア算出アルゴリズム |
| [AIプロンプト仕様](docs/specs/tempoai_ai_prompt_spec.md) | Claude APIプロンプト設計 |
| [UI仕様](docs/specs/ui-spec.md) | UI/UXデザイン |
| [ナレッジベース](docs/specs/tempoai_knowledge_base.md) | 科学的根拠 |

---

## 環境構成

| 環境 | バックエンドURL | 用途 |
|------|----------------|------|
| ローカル | `http://localhost:8787` | 開発・デバッグ |
| ステージング | `https://tempo-ai-api-staging.*.workers.dev` | 検証・テスト |
| 本番 | (Phase 9で設定) | リリース版 |

---

## 現在のフェーズ

| Phase | 内容 | 状態 |
|-------|------|------|
| Phase 1-5 | 設計・プロトタイプ・UI実装 | ✅ 完了 |
| Phase 6 | バックエンド整理・最適化 | ✅ 完了 |
| Phase 7 | API連携（アプリ↔バックエンド） | ✅ 完了 |
| **Phase 8** | HealthKit連携 | 🔜 次 |
| Phase 9 | リリース準備 | 📋 計画中 |

---

## 重要な制約

> **医学的なアドバイス・診断は絶対に行わない**

このアプリは一般的な健康・ウェルネス情報の提供のみを目的としており、医療行為の代替ではありません。

---

## ライセンス

Private - All Rights Reserved
