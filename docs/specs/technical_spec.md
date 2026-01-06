# 技術仕様書

**バージョン**: 2.0  
**最終更新日**: 2026年1月6日

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [product_spec.md](./product_spec.md) | プロダクト仕様 |
| [metrics_spec.md](./metrics_spec.md) | スコア算出アルゴリズム |
| [ai_prompt_spec.md](./ai_prompt_spec.md) | AIプロンプト仕様 |
| [knowledge_base.md](./knowledge_base.md) | 科学的根拠 |

---

## 1. システム構成

### 1.1 アーキテクチャ概要

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
                    ▼                       ▼
        ┌─────────────────┐     ┌─────────────────┐
        │   Open-Meteo    │     │   Anthropic     │
        │   (天気API)      │     │   Claude API    │
        └─────────────────┘     └─────────────────┘
```

### 1.2 設計原則

| 原則 | 説明 |
|------|------|
| **データベースレス** | ヘルスデータはデバイス内のみで処理。サーバー側にDBを持たない |
| **プライバシーファースト** | 個人データはサーバーに保存しない |
| **オフラインファースト** | 基本機能はオフラインでも動作 |

---

## 2. 技術スタック

### 2.1 モバイルアプリ

| カテゴリ | 技術 | バージョン |
|---------|------|-----------|
| フレームワーク | React Native (Expo) | SDK 54 |
| 言語 | TypeScript | 5.x |
| ルーティング | expo-router | 6.x |
| 状態管理 | Zustand | 5.x |
| ローカルストレージ | AsyncStorage | - |
| 位置情報 | expo-location | 19.x |
| ヘルスデータ | react-native-health | - |

### 2.2 バックエンド

| カテゴリ | 技術 | バージョン |
|---------|------|-----------|
| ホスティング | Cloudflare Workers | - |
| フレームワーク | Hono | 4.x |
| 言語 | TypeScript | 5.x |
| リンター | Biome | 1.9.x |
| テスト | Vitest | 2.x |

### 2.3 外部サービス

| サービス | 用途 | 料金 |
|---------|------|------|
| Cloudflare Workers | API実行環境 | 無料枠: 100,000リクエスト/日 |
| Claude API (Sonnet 4) | AIアドバイス生成 | ~$0.03/リクエスト |
| Open-Meteo | 天気・気圧情報 | 無料 |

---

## 3. API設計

### 3.1 エンドポイント一覧

| メソッド | パス | 用途 |
|---------|------|------|
| GET | `/api/health` | ヘルスチェック |
| GET | `/api/weather` | 天気情報取得 |
| POST | `/api/advice` | AIアドバイス生成 |

### 3.2 AIアドバイスAPI

**リクエスト**: `POST /api/advice`

```typescript
interface AdviceRequest {
  user: {
    goals: string[];           // ["better_sleep", "more_energy"]
    wakeUpTime: string;        // "07:00"
    windDownTime: string;      // "23:00"
  };
  healthMetrics: {
    sleep: {
      durationMinutes: number;
      deepSleepMinutes: number;
      remSleepMinutes: number;
    };
    hrv: {
      value: number;
      baseline30d: number;
    };
    activity: {
      steps: number;
    };
  };
  weather: {
    temperature: number;
    pressure: number;
    pressureTrend: "rising" | "stable" | "falling";
    sunrise: string;
    sunset: string;
  };
}
```

**レスポンス**:

```typescript
interface AdviceResponse {
  tempoScore: number;
  message: {
    title: string;              // "A Quiet Harmony"
    body: string;               // 詩的な本文
  };
  todayOneThing: {
    icon: string;               // "walking" | "breathing" | "rest"
    text: string;
    time?: string;              // "14:00"
  };
  relatedInsight: {
    text: string;
    insightId: string;
  };
  metricInsights: {
    sleep: string;
    hrv: string;
    steps: string;
  };
}
```

詳細は [ai_prompt_spec.md](./ai_prompt_spec.md) を参照

---

## 4. データフロー

### 4.1 毎朝のアドバイス生成

```
1. アプリ起動
   ↓
2. HealthKitからデータ取得（Sleep, HRV, Steps）
   ↓
3. Tempo Score算出（ローカル）
   ↓
4. 天気API呼び出し（/api/weather）
   ↓
5. AIアドバイスAPI呼び出し（/api/advice）
   ↓
6. レスポンスをキャッシュ（24時間有効）
   ↓
7. Today画面に表示
```

### 4.2 Rhythm画面のフェーズ計算

```
1. ユーザーの起床時刻を取得
   ↓
2. フェーズ時間帯を算出（ローカル）
   - Peak Focus: 起床 + 2〜4時間
   - Afternoon Dip: 起床 + 7〜8時間
   - Second Wind: 起床 + 10〜12時間
   - Wind Down: 就寝目標 - 2時間
   ↓
3. Open-MeteoからSunrise/Sunset取得
   ↓
4. Rhythm画面に表示
```

---

## 5. ローカルストレージ

### 5.1 AsyncStorage構造

| キー | 内容 | 有効期限 |
|-----|------|---------|
| `@user_profile` | ユーザー設定（goals, wake/wind down time） | 永続 |
| `@onboarding_completed` | オンボーディング完了フラグ | 永続 |
| `@advice_cache` | AIアドバイスのキャッシュ | 24時間 |
| `@health_data_{date}` | 日次ヘルスデータ | 30日 |

---

## 6. HealthKit連携

### 6.1 取得データ

| データタイプ | 用途 | 必須 |
|-------------|------|------|
| `HKQuantityType.heartRateVariabilitySDNN` | HRV値 | ✅ |
| `HKCategoryType.sleepAnalysis` | 睡眠時間・ステージ | ✅ |
| `HKQuantityType.stepCount` | 歩数 | ✅ |
| `HKQuantityType.restingHeartRate` | 安静時心拍数 | ○ |
| `HKQuantityType.appleSleepingWristTemperature` | 手首体温 | ○ |

### 6.2 権限リクエスト

オンボーディングのHealth Connect画面で一括リクエスト。
ユーザーが拒否した場合も、利用可能なデータのみで動作。

---

## 7. 環境構成

### 7.1 環境一覧

| 環境 | バックエンドURL | 用途 |
|------|----------------|------|
| ローカル | `http://localhost:8787` | 開発 |
| ステージング | `https://tempo-ai-api-staging.*.workers.dev` | テスト |
| 本番 | `https://api.tempo-ai.app` | リリース |

### 7.2 シークレット管理

| 変数 | 管理方法 |
|------|---------|
| `ANTHROPIC_API_KEY` | Cloudflare Workers Secrets |

---

## 8. 開発コマンド

### バックエンド

```bash
cd backend
pnpm dev              # ローカル開発サーバー
pnpm test             # テスト実行
pnpm deploy:staging   # ステージングデプロイ
pnpm deploy           # 本番デプロイ
```

### アプリ

```bash
cd app
pnpm start            # Expo開発サーバー
pnpm ios              # iOSシミュレーター
pnpm android          # Androidエミュレーター
pnpm lint             # Lint実行
pnpm typecheck        # 型チェック
```

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2026-01-06 | 初版（旧仕様書から移行） |
| 2.0 | 2026-01-06 | 新UI対応、API設計更新 |
