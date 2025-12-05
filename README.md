# 📱 Tempo AI

Tempo AI は、その人の HealthKit データなどを活用し、AI があなたの体調と環境に最適化された健康アドバイスを毎日提供するパーソナル健康アシスタントです。

[![CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/ci.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/ci.yml)
[![Backend CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/backend.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/backend.yml)
[![iOS CI](https://github.com/Bluefinee/tempo-ai/actions/workflows/ios.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/ios.yml)
[![Security](https://github.com/Bluefinee/tempo-ai/actions/workflows/security.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/security.yml)
[![Coverage](https://github.com/Bluefinee/tempo-ai/actions/workflows/coverage.yml/badge.svg)](https://github.com/Bluefinee/tempo-ai/actions/workflows/coverage.yml)

## 🎯 コンセプト

**「毎朝、あなた専用の健康コーチが最適なアドバイスを届ける世界」**

睡眠、心拍変動（HRV）、活動量、天気などを総合的に分析し、その日のコンディションに最適化された具体的で実行可能なアドバイスを生成します。

## ✨ 主な機能

### 🏠 ホーム画面

- **今日のテーマ**: AI が分析したあなたの今日の状態（例：「血糖安定の日」）
- **パーソナライズされたアドバイス**: 食事、運動、水分補給、呼吸法の具体的な提案
- **天気連動**: 気象条件を考慮した最適化されたアドバイス

### 📊 データ分析

- **HealthKit データ**: 睡眠時間、HRV、心拍数、歩数、活動カロリー
- **天気情報**: Open-Meteo API による正確な気象データ
- **AI 分析**: Claude 4 を使った高度なデータ解析と提案生成

### 🔔 通知機能

- **毎朝の定期通知**: カスタマイズ可能な時刻設定
- **フレンドリーなメッセージ**: モチベーションを高めるバリエーション豊富な通知

## 🏗️ 技術スタック

### iOS アプリ

- **言語**: Swift 5.9+
- **フレームワーク**: SwiftUI (iOS 16.0+)
- **ヘルスデータ**: HealthKit
- **位置情報**: CoreLocation
- **通知**: UserNotifications

### バックエンド API

- **プラットフォーム**: Cloudflare Workers
- **フレームワーク**: Hono (軽量 TypeScript)
- **AI**: Claude API (Anthropic)

### CI/CD & 品質管理

- **Linting**: ESLint + Prettier (TypeScript), SwiftLint (Swift)
- **Testing**: Vitest (API), XCTest (iOS)
- **Build**: GitHub Actions 並列実行
- **Security**: CodeQL, Trivy, 依存関係監査
- **Code Review**: CodeRabbit AI + CLAUDE.md standards
- **天気 API**: Open-Meteo
- **データベース**: PostgreSQL (Supabase)
- **接続最適化**: Hyperdrive

### インフラ

- **API ホスティング**: Cloudflare Workers
- **データベース**: Supabase
- **バージョン管理**: GitHub

## 📱 アプリ構造

```
┌─────┬─────┬─────┬─────┐
│ 🏠  │ 📅  │ 📈  │ 👤  │
│今日  │履歴  │傾向  │私   │
└─────┴─────┴─────┴─────┘
```

### ホーム画面（今日）

- 今日のテーマとアドバイス概要
- 詳細アドバイスへのリンク
- データ更新とローディング状態

### 履歴画面（Phase 3）

- 過去 7 日間のアドバイス履歴
- 日別のテーマとサマリー表示

### トレンド画面（Phase 4）

- 睡眠、HRV、歩数などのグラフ表示
- AI によるパターン分析コメント

### プロフィール画面

- 基本情報（年齢、身長、体重）
- 目標設定（疲労回復、集中力向上など）
- 食事設定（好み、制限）
- 運動習慣設定
- 通知設定

## 🎨 デザイン

### カラーパレット

- **プライマリ**: ソフトグリーン `#4ECDC4`
- **セカンダリ**: ウォームベージュ `#F7F3E9`
- **アクセント**: サンセットオレンジ `#FF6B6B`
- **テキスト**: ダークグレー `#2C3E50`

### UI コンポーネント

- **カード角丸**: 16pt
- **影**: `(0, 2, 8, rgba(0,0,0,0.08))`
- **フォント**: SF Pro Display/Text

## 🚀 開発フェーズ

### Phase 1: MVP （完了予定: Week 2）

**目標**: 1 回でもアドバイスを見れる

- [x] HealthKit データ取得
- [x] 天気 API 統合
- [x] Claude API 統合
- [x] ホーム画面
- [x] 詳細アドバイス画面
- [x] 通知機能
- [x] 基本プロフィール設定

### Phase 2: UX 改善 （完了予定: Week 4）

**目標**: 毎日使いたくなる

- [x] UI の洗練
- [x] プロンプト精度向上
- [x] エラーハンドリング
- [x] オンボーディング改善

### Phase 3: 履歴機能 （完了予定: Week 6）

**目標**: 振り返りができる

- [ ] Supabase データベース統合
- [ ] 履歴画面（7 日間）
- [ ] データ永続化

### Phase 4: 分析・拡張 （完了予定: Week 8+）

**目標**: より深い洞察

- [ ] トレンドグラフ
- [ ] パターン分析
- [ ] Apple Watch 対応

## 🔐 プライバシー・セキュリティ

### データ保護

- **HealthKit データ**: デバイスローカルに保存
- **分析時のみサーバー送信**: 即座に削除
- **履歴保存**: 7 日間のみ、8 日目に自動削除
- **第三者共有**: なし

### セキュリティ

- **HTTPS 必須**: 全通信 TLS 1.3
- **匿名化**: ユーザー ID は UUID（個人特定不可）
- **API キー管理**: 環境変数で適切に管理

## 🔧 品質管理 & CI/CD

### 基本コマンド

```bash
make setup           # 開発環境の自動セットアップ
make check           # 全プロジェクトの品質チェック
make fix             # 全問題の自動修正
make test            # 全テスト実行（モック使用、コスト $0）
make test-mutation   # ミューテーションテスト（モック使用）
make test-real-api   # 実APIテスト（コスト注意 💸）
make ci-full         # 完全CI環境模擬（コストセーフ）
```

### 💰 コスト管理

```bash
# 🆓 無料テスト（日常使用）
make test              # モックAPIでコスト $0
make test-mutation     # モックAPIでコスト $0

# 💸 有料テスト（リリース前のみ）
make test-real-api     # 実API使用、~$0.50/回
```

### テスト駆動開発（TDD）基準

- **テストカバレッジ**: 80%以上必須
- **ミューテーションスコア**: 70%以上推奨
- **TypeScript 型エラー**: ゼロ必須
- **ESLint/SwiftLint**: エラーなし
- **テストファースト**: 新機能はテスト先行
- **セキュリティ**: 脆弱性ゼロ

### CI/CD パイプライン

```
┌─────────────┬─────────────┬─────────────┐
│   品質ゲート   │   テスト実行   │   デプロイ    │
│              │              │              │
│ ✅ 型チェック  │ 🧪 単体テスト │ 🚀 本番環境  │
│ ✅ Lint     │ 🔗 統合テスト │ 📊 監視     │
│ ✅ フォーマット │ 🧬 変異テスト │ 📈 分析     │
│ ✅ セキュリティ │ ⚡ 性能テスト │              │
└─────────────┴─────────────┴─────────────┘
```

## 🛠️ 開発環境セットアップ

### 必要なツール

**iOS 開発**:

- Xcode 15+
- macOS Sonoma 14+
- iPhone 実機（HealthKit テスト用）

**Cloudflare Workers 開発**:

- Node.js 18+
- npm または pnpm
- Wrangler CLI
- VS Code（推奨）
- Cloudflare アカウント

**API キー**:

- Claude API キー（Anthropic）
- Supabase アカウント

### セットアップ手順

1. **リポジトリクローン**

```bash
git clone https://github.com/yourusername/tempo-ai.git
cd tempo-ai
```

2. **Cloudflare Workers API セットアップ**

```bash
cd workers
npm install
cp wrangler.toml.example wrangler.toml
# wrangler.toml を編集（APIキー等を設定）
npm run dev
```

3. **iOS アプリセットアップ**

```bash
cd ios/TempoAI
open TempoAI.xcodeproj
# Info.plistを編集してAPI_BASE_URLとHealthKit権限を設定
```

## 📋 主要な API エンドポイント

### POST /api/health/analyze

ヘルスデータを分析してアドバイス生成

**リクエスト**:

```json
{
  "user_id": "uuid",
  "health_data": {
    "sleep": { ... },
    "hrv": 65.5,
    "steps": 8234,
    ...
  },
  "user_profile": { ... },
  "location": {
    "latitude": 35.6895,
    "longitude": 139.6917
  }
}
```

**レスポンス**:

```json
{
  "theme": "血糖安定の日",
  "breakfast": {
    "recommendation": "低GI食品を中心に",
    "reason": "睡眠不足時は血糖値が不安定になりやすいため",
    "examples": ["オートミール", "ゆで卵", "アボカド"]
  },
  "exercise": { ... },
  "hydration": { ... },
  ...
}
```

## 🎯 ターゲットユーザー

- **健康意識の高い 25-40 代**
- **Apple Watch または iPhone ユーザー**
- **データドリブンで健康管理したい人**

## 🔮 将来の拡張

### Phase 5（3-6 ヶ月後）

- 血液検査データ統合
- 食事記録機能

### Phase 6（6-12 ヶ月後）

- パーソナルコーチング
- 週次振り返り

## 📚 関連ドキュメント

- [製品仕様書](./guidelines/01_tempo-ai-product-spec.md) - プロダクトの詳細仕様
- [技術仕様書](./guidelines/tempo-ai-technical-spec.md) - 開発者向け技術仕様

## CodeRabbit レビューの実行

claude code などへのプロンプト例

```md
下記の流れで code rabbit によるレビューを受け、適切に修正してください。

### 1. レビューの実行

- CodeRabbit CLI のレビューコマンドを実行してコードレビューを受けること。レビュー指摘内容はそのまま YYYYMMDD-HHMM-code-rabbit-review-results.txt として guidelines/code-rabbit-reviews にアウトプットする。
  コマンド例：`coderabbit review --plain > guidelines/code-rabbit-reviews/20241204-$(date +%H%M)-code-rabbit-review-results.txt 2>&1`
- **重要**: レビュー処理には 5-10 分程度かかるため、コマンドの完了まで待機すること

### 2. レビュー結果の処理

レビュー結果が返却されたら、以下の手順で対応すること:

- 結果を分析し、詳細な修正計画を策定
- 修正計画は、先ほどアウトプットした YYYYMMDD-HHMM-code-rabbit-review-results.txt をもとに、チェックリスト形式で guidelines/code-rabbit-reviews ディレクトリ に Markdown ファイルで詳細にまとめる
- 計画的かつ適切な順序で修正を実施

### 3. 修正方針

- **基本原則**: 指摘事項は全て修正対象とする
- **例外**: 明らかに修正不要、または指摘が誤っていると判断できる場合のみ無視可

### 4. レビュー対象の確認

- `.coderabbit.yaml`の設定を確認し、レビュー対象から除外されているファイルを把握すること
- 除外設定を理解した上で、適切なファイルのみレビューを依頼すること
```
