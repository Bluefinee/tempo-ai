# Tempo AI

**「自分のテンポで、健やかな毎日を」**

HealthKit データと環境データを AI が分析し、その日の過ごし方をパーソナライズしてアドバイスするヘルスケアアプリ。

---

## 技術スタック

| レイヤー | 技術                                       |
| -------- | ------------------------------------------ |
| iOS      | SwiftUI (iOS 17+), HealthKit, CoreLocation |
| Backend  | Cloudflare Workers, Hono, TypeScript       |
| AI       | Claude Sonnet 4                            |
| 外部 API | Open-Meteo (Weather / Air Quality)         |

---

## セットアップ

### Backend

```bash
cd backend
pnpm install
wrangler secret put ANTHROPIC_API_KEY
pnpm dev  # http://localhost:8787
```

### iOS

```bash
cd ios/TempoAI
open TempoAI.xcodeproj
# Xcode: Signing設定 → ⌘+R で実行
```

> HealthKit のデータ取得には実機が必要です。

---

## 開発コマンド

### Backend

```bash
pnpm dev          # 開発サーバー
pnpm deploy       # 本番デプロイ
pnpm check        # lint + format + typecheck
pnpm test         # テスト実行
```

### iOS

| 操作           | ショートカット |
| -------------- | -------------- |
| ビルド＆実行   | `⌘+R`          |
| テスト         | `⌘+U`          |
| クリーンビルド | `⌘+Shift+K`    |

---

## プロジェクト構造

```
tempo-ai/
├── backend/              # Cloudflare Workers API
│   └── src/
├── ios/TempoAI/          # SwiftUI アプリ
│   ├── Features/
│   │   ├── Onboarding/
│   │   ├── Home/
│   │   ├── CircadianRhythm/
│   │   └── Settings/
│   └── Services/
├── docs/                 # ドキュメント
│   ├── specs/            # 仕様書
│   └── phases/           # 開発フェーズ
└── .claude/              # 開発ガイドライン
```

---

## ドキュメント

| ドキュメント                   | 内容          |
| ------------------------------ | ------------- |
| `docs/specs/product-spec.md`   | 機能要件      |
| `docs/specs/ui-spec.md`        | UI/UX 設計    |
| `docs/specs/metrics-spec.md`   | スコア算出    |
| `docs/specs/ai-prompt-spec.md` | AI プロンプト |
| `docs/specs/technical-spec.md` | 技術仕様      |
| `docs/phases/phases.md`        | 開発フェーズ  |

---

## 重要な制約

> ⚠️ **医学的なアドバイス・診断は絶対に行わない**
