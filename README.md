# 📱 Tempo AI

> あなた専用のヘルスケアアドバイザーが、毎朝最適なアドバイスをお届けします

[![CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/ci.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/ci.yml)
[![Backend CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/backend.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/backend.yml)
[![iOS CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/ios.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/ios.yml)
[![Security](https://github.com/Bluefinee/tempo-ai/actions/workflows/security.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/security.yml)
[![Coverage](https://github.com/Bluefinee/tempo-ai/actions/workflows/coverage.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/coverage.yml)

## 🎯 What is Tempo AI?

Tempo AI は HealthKit データ、天気情報、位置情報を統合し、AI があなたの体調と環境に最適化された健康アドバイスを毎日提供するパーソナルヘルスケアアシスタントです。

### 🌟 主な特徴

- **完全パーソナライズ**: 睡眠、心拍変動（HRV）、活動量、天気を総合分析
- **実行可能なアドバイス**: 食事、運動、水分補給、呼吸法の具体的な提案
- **天気連動**: 気象条件を考慮した最適化されたアドバイス
- **多言語対応**: 英語・日本語でのネイティブサポート
- **プライバシー重視**: HealthKit データはローカル処理、分析時のみサーバー送信

## 🏗️ アーキテクチャ

```
┌─────────────────┐    HTTPS     ┌──────────────────┐    ┌─────────────┐
│   iOS App       │─────────────▶│ Cloudflare       │───▶│ Claude API  │
│   (SwiftUI)     │               │ Workers + Hono   │    │ (Anthropic) │
│                 │               │                  │    └─────────────┘
│ • HealthKit     │               │ • TypeScript     │           │
│ • CoreLocation  │               │ • Zod validation │           ▼
│ • Notifications │               │ • Vitest testing │    ┌─────────────┐
└─────────────────┘               └──────────────────┘    │ Open-Meteo  │
                                                          │ Weather API │
                                                          └─────────────┘
```

## 🚀 クイックスタート

### 必要な環境

- **iOS 開発**: Xcode 15+, macOS Sonoma 14+, iPhone 実機
- **Backend 開発**: Node.js 20+, pnpm 9+
- **API キー**: Claude API キー (Anthropic)

### 1. リポジトリのクローン

```bash
git clone https://github.com/your-username/tempo-ai.git
cd tempo-ai
```

### 2. 開発環境セットアップ

```bash
# 全プロジェクトの自動セットアップ
make setup

# または個別セットアップ
cd backend
pnpm install
cd ../ios/TempoAI
open TempoAI.xcodeproj
```

### 3. 環境変数の設定

```bash
# backend/.dev.vars を作成
cd backend
cp .dev.vars.example .dev.vars
# Claude API キーを設定
```

### 4. 開発開始

```bash
# バックエンドAPI開発
cd backend
pnpm run dev  # localhost:8787

# iOSアプリ開発
# Xcode でプロジェクトを開いて実機でビルド
```

## 📁 プロジェクト構造

```
tempo-ai/
├── backend/          # Cloudflare Workers API (TypeScript + Hono)
│   ├── src/
│   │   ├── routes/   # API エンドポイント
│   │   ├── services/ # ビジネスロジック
│   │   ├── types/    # 型定義
│   │   └── utils/    # ユーティリティ
│   └── tests/        # API テスト
├── ios/              # iOS アプリ (Swift + SwiftUI)
│   └── TempoAI/
│       ├── TempoAI/  # アプリソースコード
│       └── Tests/    # iOS テスト
├── guidelines/       # 開発ドキュメント
└── scripts/          # 開発スクリプト
```

## 🔧 開発コマンド

### 基本コマンド

```bash
make setup           # 開発環境の自動セットアップ
make check           # 全プロジェクトの品質チェック
make fix             # 全問題の自動修正
make test            # 全テスト実行
make ci-full         # CI環境の完全模擬
```

### バックエンド開発

```bash
cd backend
pnpm run dev         # 開発サーバー起動
pnpm run test        # テスト実行
pnpm run check       # Lint + Format チェック
pnpm run build       # プロダクションビルド
pnpm run deploy      # Cloudflare Workers へデプロイ
```

### iOS 開発

```bash
cd ios
./scripts/quality-check.sh  # SwiftLint + Format チェック
# Xcode でテスト実行とビルド
```

## 📊 テストとカバレッジ

- **バックエンドカバレッジ**: 80%以上を維持
- **テストフレームワーク**: Vitest (Backend), XCTest (iOS)
- **リアルタイム監視**: GitHub Actions でのカバレッジ報告

## 🔐 セキュリティ

- **全通信**: HTTPS (TLS 1.3)
- **データ保護**: HealthKit データはローカル保存
- **API キー管理**: 環境変数での適切な管理
- **依存関係監査**: 自動セキュリティスキャン

## 📋 API エンドポイント

### 主要 API

- `POST /api/health/analyze` - ヘルスデータ分析とアドバイス生成
- `GET /api/health/status` - API サービス状態確認

詳細は [技術仕様書](./guidelines/tempo-ai-technical-spec.md) を参照

## 🤝 コントリビューション

1. Issue を作成して機能追加・バグ修正を提案
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. [CLAUDE.md](./CLAUDE.md) の開発標準に従って実装
4. テストを追加・実行 (`make test`)
5. Pull Request を作成

## 📚 関連ドキュメント

- [📋 技術仕様書](./guidelines/tempo-ai-technical-spec.md) - 実装詳細とアーキテクチャ
- [📱 プロダクト仕様書](./guidelines/tempo-ai-product-spec.md) - 機能仕様と要件
- [⚙️ 開発ガイドライン](./CLAUDE.md) - コーディング標準と品質要件

## 🌟 主要技術

- **Frontend**: SwiftUI (iOS 16.0+)
- **Backend**: Cloudflare Workers + Hono Framework
- **Language**: TypeScript 5.9+, Swift 5.9+
- **AI**: Claude API (Anthropic)
- **Testing**: Vitest, XCTest
- **Tools**: Biome (Lint/Format), pnpm, Xcode

## 🐇 Code Rabbit レビュー依頼 From Claude Code

```md
下記の流れで code rabbit によるレビューを受け、適切に修正してください。

### 1. レビューの実行

- CodeRabbit CLI のレビューコマンドを実行してコードレビューを受けること。レビュー指摘内容はそのまま YYYYMMDD-HHMM-code-rabbit-review-results.txt として
  guidelines/code-rabbit-reviews にアウトプットする。
  コマンド例：`coderabbit review --plain > guidelines/code-rabbit-reviews/20251204-$(date +%H%M)-code-rabbit-review-results.txt 2>&1`
- **重要**: レビュー処理には 5-10 分程度かかるため、コマンドの完了まで待機すること

### 2. レビュー結果の処理

レビュー結果が返却されたら、以下の手順で対応すること:

- 結果を分析し、詳細な修正計画を策定
- 修正計画は、先ほどアウトプットした YYYYMMDD-HHMM-code-rabbit-review-results.txt をもとに、チェックリスト形式で guidelines/code-rabbit-reviews
  ディレクトリ に Markdown ファイルで詳細にまとめる
- 計画的かつ適切な順序で修正を実施

### 3. 修正方針

- **基本原則**: 指摘事項は全て修正対象とする
- **例外**: 明らかに修正不要、または指摘が誤っていると判断できる場合のみ無視可

### 4. レビュー対象の確認

- `.coderabbit.yaml`の設定を確認し、レビュー対象から除外されているファイルを把握すること
- 除外設定を理解した上で、適切なファイルのみレビューを依頼すること
```
