# TempoAI

**"Tune Your Rhythm"**

サーカディアンリズム（体内時計）と自律神経を整え、日々のパフォーマンスを最適化するAIパートナーアプリ。

---

## コンセプト

HealthKitデータと気象データをAIが分析し、あなた固有の「テンポ」に合わせたパーソナライズされたアドバイスを毎朝お届けします。

**設計思想**: データベースレス × HealthKit × 生成AI
- プライバシー重視: ヘルスケアデータは端末内完結
- 軽量設計: サーバーはAI連携のプロキシのみ

---

## 技術スタック

| レイヤー | 技術 |
|---------|------|
| iOS | SwiftUI (iOS 17+), HealthKit, CoreLocation |
| Backend | Cloudflare Workers, Hono, TypeScript |
| AI | Claude Sonnet 4 |
| Weather | Open-Meteo (Weather / Air Quality) |

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

> HealthKitのデータ取得には実機が必要です。

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

| 操作 | ショートカット |
|------|--------------|
| ビルド＆実行 | `⌘+R` |
| テスト | `⌘+U` |
| クリーンビルド | `⌘+Shift+K` |

---

## プロジェクト構造

```
tempo-ai/
├── backend/              # Cloudflare Workers API
│   └── src/
├── ios/TempoAI/          # SwiftUI アプリ
│   ├── App/
│   ├── Features/
│   │   ├── Onboarding/
│   │   ├── Home/
│   │   ├── Analytics/
│   │   └── Settings/
│   ├── Domain/           # ドメインモデル・サービス
│   ├── Infrastructure/   # HealthKit, API, Cache
│   └── Shared/
├── docs/                 # ドキュメント
│   └── specs/            # 仕様書
└── .claude/              # 開発ガイドライン
```

---

## ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| `docs/specs/product-spec.md` | プロダクト仕様・画面構成 |
| `docs/specs/technical-spec.md` | 技術仕様・アーキテクチャ |
| `docs/specs/metrics-spec.md` | スコア算出アルゴリズム |
| `docs/specs/ai-prompt-spec.md` | AIプロンプト仕様 |
| `docs/specs/ui-spec.md` | UI/UXデザイン仕様 |
| `docs/specs/knowledge-base.md` | 科学的根拠・ナレッジベース |

---

## 重要な制約

> ⚠️ **医学的なアドバイス・診断は絶対に行わない**
