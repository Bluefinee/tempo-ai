# TempoAI Mobile App

React Native (Expo) で構築されたモバイルアプリケーション。

---

## セットアップ

### 必要環境

- Node.js 18+
- pnpm 8+
- iOS Simulator (macOS) または Android Emulator

### インストール

```bash
pnpm install
```

### 開発サーバー起動

```bash
pnpm start
```

Expo Go アプリでスキャン、または：

```bash
pnpm ios       # iOS Simulator
pnpm android   # Android Emulator
```

---

## プロジェクト構造

```
app/
├── app/                      # expo-router ページ
│   ├── (onboarding)/        # オンボーディングフロー
│   │   ├── _layout.tsx      # Stack Navigator
│   │   ├── index.tsx        # Welcome 画面
│   │   ├── healthkit.tsx    # HealthKit 説明
│   │   ├── nickname.tsx     # ニックネーム入力
│   │   ├── basic-info.tsx   # 基本情報入力
│   │   ├── chronotype.tsx   # クロノタイプ選択
│   │   ├── bedtime.tsx      # 目標就寝時刻
│   │   ├── lifestyle.tsx    # ライフスタイル（任意）
│   │   ├── location.tsx     # 位置情報許可
│   │   └── complete.tsx     # 完了
│   ├── (main)/              # メインタブ
│   │   ├── _layout.tsx      # Tab Navigator
│   │   ├── index.tsx        # Home
│   │   ├── analytics.tsx    # 分析
│   │   └── settings.tsx     # 設定
│   ├── insight-detail.tsx   # AI インサイト詳細（Modal）
│   ├── index.tsx            # ルートリダイレクト
│   └── _layout.tsx          # ルートレイアウト
├── src/
│   ├── components/          # 共通 UI コンポーネント
│   ├── domain/              # ドメインモデル・サービス
│   ├── stores/              # Zustand ストア
│   ├── infrastructure/      # ネイティブ機能抽象化
│   ├── api/                 # API クライアント
│   ├── theme/               # デザイントークン
│   ├── constants/           # モックデータ
│   └── utils/               # ユーティリティ
├── assets/                  # 静的アセット
├── app.json                 # Expo 設定
└── package.json
```

---

## 主要コンポーネント

### UI コンポーネント (`src/components/`)

| コンポーネント | 用途 |
|---------------|------|
| `Card` | カード UI |
| `PrimaryButton` | 主要ボタン |
| `SecondaryButton` | 副次ボタン |
| `ProgressBar` | 進捗バー |
| `ScoreGauge` | スコア表示 |
| `MoodSelector` | 気分選択 |
| `LoadingView` | ローディング |
| `CircadianClock` | 概日リズムクロック |

### ドメインモデル (`src/domain/models/`)

| モデル | 説明 |
|--------|------|
| `Score` | スコア値オブジェクト |
| `HealthMetrics` | ヘルスデータ |
| `UserProfile` | ユーザープロファイル |
| `DailyAdvice` | 日次アドバイス |
| `WeatherData` | 天気データ |

### Zustand ストア (`src/stores/`)

| ストア | 責務 |
|--------|------|
| `userStore` | ユーザープロファイル、オンボーディング状態 |
| `healthStore` | ヘルスメトリクス、スコア |
| `insightStore` | AI インサイト、ローディング状態 |

---

## 開発コマンド

```bash
pnpm start       # Expo 開発サーバー起動
pnpm ios         # iOS Simulator で実行
pnpm android     # Android Emulator で実行
pnpm lint        # ESLint 実行
pnpm typecheck   # TypeScript 型チェック
pnpm test        # テスト実行
```

---

## 環境変数

```bash
# .env.local
EXPO_PUBLIC_API_URL=http://localhost:8787
```

---

## アーキテクチャ

### レイヤー構成

```
┌─────────────────────────────────────────────────────┐
│ Presentation (Screens / Components)                 │
│ - expo-router ページ                                │
│ - 共通 UI コンポーネント                            │
├─────────────────────────────────────────────────────┤
│ Application (Stores / Hooks)                        │
│ - Zustand ストア                                    │
│ - カスタムフック                                    │
├─────────────────────────────────────────────────────┤
│ Domain (Models / Services)                          │
│ - TypeScript 型定義                                 │
│ - スコア計算ロジック                                │
├─────────────────────────────────────────────────────┤
│ Infrastructure (Repositories / API)                 │
│ - HealthRepository (モック / ネイティブ)           │
│ - LocationRepository (Expo Location)               │
│ - API クライアント                                  │
└─────────────────────────────────────────────────────┘
```

### データフロー

```
HealthRepository
       ↓
   HealthMetrics
       ↓
   ScoreCalculator → Score (sleepScore, autonomicScore, etc.)
       ↓
   healthStore (Zustand)
       ↓
   Screen Components
```

---

## 将来の拡張

### ヘルスデータ連携

現在はモックデータを使用。将来的に以下を実装予定：

- **iOS**: `react-native-health` (Apple HealthKit)
- **Android**: `react-native-health-connect` (Google Health Connect)

### ビルド

```bash
# EAS Build を使用
eas build --platform ios
eas build --platform android
```

---

## 関連ドキュメント

- [React Native コーディング規約](../.claude/react-native-standards.md)
- [技術仕様書](../docs/specs/tempoai_technical_spec.md)
- [プロダクト仕様書](../docs/specs/tempoai_product_spec.md)
