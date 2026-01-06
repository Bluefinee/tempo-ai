# TempoAI

**"Tune Your Rhythm"**

サーカディアンリズム（体内時計）と自律神経を整え、日々のパフォーマンスを最適化するAIパートナーアプリ。

---

## コンセプト

ヘルスデータと気象データをAIが分析し、あなた固有の「テンポ」に合わせたパーソナライズされたアドバイスを毎朝お届けします。

**設計思想**: データベースレス × ヘルスデータ × 生成AI
- プライバシー重視: ヘルスケアデータは端末内完結
- 軽量設計: サーバーはAI連携のプロキシのみ
- クロスプラットフォーム: iOS / Android 両対応

---

## 技術スタック

| レイヤー | 技術 |
|---------|------|
| Mobile | React Native (Expo SDK 54), TypeScript |
| Navigation | expo-router |
| State | Zustand, AsyncStorage |
| Backend | Cloudflare Workers, Hono, TypeScript |
| AI | Claude Sonnet 4 |
| Weather | Open-Meteo (Weather / Air Quality) |

---

## セットアップ

### 必要環境

- Node.js 18+
- pnpm 8+
- Expo CLI (`npx expo`)
- iOS Simulator (macOS) または Android Emulator

### Mobile App (Expo)

```bash
cd app
pnpm install
pnpm start
# または
pnpm ios    # iOS Simulator で起動
pnpm android # Android Emulator で起動
```

### Backend

```bash
cd backend
pnpm install
wrangler secret put ANTHROPIC_API_KEY
pnpm dev  # http://localhost:8787
```

---

## 開発コマンド

### Mobile App

```bash
cd app
pnpm start       # Expo 開発サーバー起動
pnpm ios         # iOS Simulator で実行
pnpm android     # Android Emulator で実行
pnpm lint        # ESLint 実行
pnpm typecheck   # TypeScript 型チェック
```

### Backend

```bash
cd backend
pnpm dev          # 開発サーバー
pnpm deploy       # 本番デプロイ
pnpm check        # lint + format + typecheck
pnpm test         # テスト実行
```

---

## プロジェクト構造

```
tempo-ai/
├── app/                      # Expo React Native アプリ
│   ├── app/                  # expo-router ページ
│   │   ├── (onboarding)/    # オンボーディングフロー
│   │   ├── (main)/          # メインタブ (Home, Analytics, Settings)
│   │   └── insight-detail.tsx
│   └── src/
│       ├── components/      # 共通 UI コンポーネント
│       ├── domain/          # ドメインモデル・サービス
│       ├── stores/          # Zustand ストア
│       ├── infrastructure/  # Health/Location 抽象化
│       ├── api/             # API クライアント
│       └── theme/           # デザイントークン
├── backend/                  # Cloudflare Workers API
│   └── src/
│       ├── routes/          # API エンドポイント
│       └── services/        # Claude AI, Weather
├── docs/                     # ドキュメント
│   └── specs/               # 仕様書
└── .claude/                  # 開発ガイドライン
```

---

## ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| `docs/specs/tempoai_product_spec.md` | プロダクト仕様・画面構成 |
| `docs/specs/tempoai_technical_spec.md` | 技術仕様・アーキテクチャ |
| `docs/specs/tempoai_metrics_spec.md` | スコア算出アルゴリズム |
| `docs/specs/tempoai_ai_prompt_spec.md` | AIプロンプト仕様 |
| `docs/specs/ui-spec.md` | UI/UXデザイン仕様 |
| `docs/specs/tempoai_knowledge_base.md` | 科学的根拠・ナレッジベース |

---

## 重要な制約

> ⚠️ **医学的なアドバイス・診断は絶対に行わない**
