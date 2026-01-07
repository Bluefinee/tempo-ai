# 技術仕様書

**バージョン**: 3.0  
**最終更新日**: 2026年1月7日

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
│  │         │                │                │                 │   │
│  │         ▼                ▼                ▼                 │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              ローカル計算エンジン                      │   │   │
│  │  │  ├─ 4スコア算出 (Recovery/Sleep/Rhythm/Energy)       │   │   │
│  │  │  ├─ Baseline計算 (30日/60日移動平均)                 │   │   │
│  │  │  ├─ Typical Range計算 (5-95パーセンタイル)           │   │   │
│  │  │  └─ テンプレート文生成                                │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
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
| **ローカル優先計算** | スコア・Baseline計算はローカルで実行 |

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
| チャート | react-native-chart-kit / Victory | - |

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
| Open-Meteo Weather | 天気・気温・湿度 | 無料 |
| Open-Meteo Air Quality | UV指数 | 無料 |
| Open-Meteo Astronomy | 日の出/日の入り・月齢 | 無料 |

---

## 3. HealthKit連携

### 3.1 取得データ一覧

| データタイプ | HealthKit Identifier | 用途 | 必須 |
|-------------|---------------------|------|------|
| HRV | `HKQuantityTypeIdentifierHeartRateVariabilitySDNN` | Recovery計算 | ✅ |
| 安静時心拍数 | `HKQuantityTypeIdentifierRestingHeartRate` | Recovery計算 | ✅ |
| 睡眠分析 | `HKCategoryTypeIdentifierSleepAnalysis` | Sleep計算 | ✅ |
| 歩数 | `HKQuantityTypeIdentifierStepCount` | Activity | ✅ |
| 呼吸数 | `HKQuantityTypeIdentifierRespiratoryRate` | Health Summary | ○ |
| 血中酸素 | `HKQuantityTypeIdentifierOxygenSaturation` | Health Summary | ○ |
| 手首体温 | `HKQuantityTypeIdentifierAppleSleepingWristTemperature` | Health Summary | ○ |

### 3.2 データ取得パターン

```typescript
// 期間別データ取得
interface HealthDataQuery {
  metric: HealthMetric;
  startDate: Date;
  endDate: Date;
  aggregation: 'raw' | 'daily' | 'weekly';
}

async function fetchHealthKitData(query: HealthDataQuery): Promise<HealthDataPoint[]> {
  const permissions = {
    permissions: {
      read: [
        AppleHealthKit.Constants.Permissions.HeartRateVariability,
        AppleHealthKit.Constants.Permissions.RestingHeartRate,
        AppleHealthKit.Constants.Permissions.SleepAnalysis,
        AppleHealthKit.Constants.Permissions.StepCount,
        AppleHealthKit.Constants.Permissions.RespiratoryRate,
        AppleHealthKit.Constants.Permissions.OxygenSaturation,
        AppleHealthKit.Constants.Permissions.BodyTemperature,
      ],
    },
  };
  
  await AppleHealthKit.initHealthKit(permissions);
  
  const options = {
    startDate: query.startDate.toISOString(),
    endDate: query.endDate.toISOString(),
  };
  
  // メトリクス別に取得
  switch (query.metric) {
    case 'hrv':
      return AppleHealthKit.getHeartRateVariabilitySamples(options);
    case 'rhr':
      return AppleHealthKit.getRestingHeartRateSamples(options);
    case 'sleep':
      return AppleHealthKit.getSleepSamples(options);
    case 'respiratory':
      return AppleHealthKit.getRespiratoryRateSamples(options);
    case 'spo2':
      return AppleHealthKit.getOxygenSaturationSamples(options);
    case 'wristTemp':
      return AppleHealthKit.getBodyTemperatureSamples(options);
    default:
      throw new Error(`Unknown metric: ${query.metric}`);
  }
}
```

### 3.3 7D/30D/60D切り替え対応

```typescript
type TimeRange = '7D' | '30D' | '60D';

function getDateRangeForTab(range: TimeRange): { start: Date; end: Date } {
  const end = new Date();
  const start = new Date();
  
  switch (range) {
    case '7D':
      start.setDate(end.getDate() - 7);
      break;
    case '30D':
      start.setDate(end.getDate() - 30);
      break;
    case '60D':
      start.setDate(end.getDate() - 60);
      break;
  }
  
  return { start, end };
}

// 期間別チャートデータ取得
async function getChartDataForRange(
  metric: HealthMetric,
  range: TimeRange
): Promise<ChartData> {
  const { start, end } = getDateRangeForTab(range);
  
  const rawData = await fetchHealthKitData({
    metric,
    startDate: start,
    endDate: end,
    aggregation: range === '7D' ? 'daily' : 'weekly',
  });
  
  // 7D: 日別、30D/60D: 週別に集計
  if (range === '7D') {
    return aggregateDaily(rawData);
  } else {
    return aggregateWeekly(rawData);
  }
}
```

### 3.4 権限リクエスト

```typescript
const HEALTH_PERMISSIONS = {
  permissions: {
    read: [
      // 必須
      AppleHealthKit.Constants.Permissions.HeartRateVariability,
      AppleHealthKit.Constants.Permissions.RestingHeartRate,
      AppleHealthKit.Constants.Permissions.SleepAnalysis,
      AppleHealthKit.Constants.Permissions.StepCount,
      // オプション
      AppleHealthKit.Constants.Permissions.RespiratoryRate,
      AppleHealthKit.Constants.Permissions.OxygenSaturation,
      AppleHealthKit.Constants.Permissions.BodyTemperature,
    ],
    write: [], // 書き込みは不要
  },
};

async function requestHealthPermissions(): Promise<boolean> {
  return new Promise((resolve) => {
    AppleHealthKit.initHealthKit(HEALTH_PERMISSIONS, (err) => {
      if (err) {
        console.error('HealthKit init error:', err);
        resolve(false);
      }
      resolve(true);
    });
  });
}
```

---

## 4. API設計

### 4.1 エンドポイント一覧

| メソッド | パス | 用途 |
|---------|------|------|
| GET | `/api/health` | ヘルスチェック |
| GET | `/api/environment` | 環境データ取得（天気・気圧・UV・月齢） |
| POST | `/api/advice` | AIアドバイス生成 |

### 4.2 AIアドバイスAPI

**リクエスト**: `POST /api/advice`

```typescript
interface AdviceRequest {
  user: {
    goals: string[];           // ["better_sleep", "more_energy"]
    wakeUpTime: string;        // "07:00"
    windDownTime: string;      // "23:00"
  };
  scores: {
    recovery: number;          // 0-100
    sleep: number;             // 0-100
    rhythm: number;            // 0-100
    energy: number;            // 0-100
  };
  healthMetrics: {
    hrv: {
      current: number;
      baseline: number;
      deviation: number;       // %
    };
    rhr: {
      current: number;
      baseline: number;
    };
    sleep: {
      durationMinutes: number;
      deepSleepMinutes: number;
      deepSleepPercent: number;
      remSleepMinutes: number;
      remSleepPercent: number;
      bedtime: string;
      wakeTime: string;
      vsTargetBedtime: string;  // "+15min" or "-10min"
    };
  };
  environment: {
    location: string;          // "東京"
    weather: {
      condition: string;       // "晴れ"
      temperature: number;     // 気温 °C
      humidity: number;        // 湿度 %
    };
    pressure: {
      value: number;           // 気圧 hPa
      trend: "up" | "stable" | "down";
      change24h: number;       // 24時間変化 hPa
    };
    uv: {
      index: number;           // UVインデックス (0-11+)
      level: string;           // "弱い" | "中程度" | "強い" | "非常に強い"
    };
    moonPhase: {
      phase: string;           // "新月" | "上弦の月" | "満月" etc.
      illumination: number;    // 輝面比 0-100%
    };
    sunrise: string;           // "06:50"
    sunset: string;            // "16:48"
  };
  rhythmPhases: {
    peakFocus: { start: string; end: string };
    afternoonDip: { start: string; end: string };
  };
}
```

**レスポンス**:

```typescript
interface AdviceResponse {
  todayInsight: {
    title: string;              // "A Quiet Harmony"
    summary: string;            // Today画面用の簡潔な説明
    whyThisMatters: {
      hrv: { headline: string; explanation: string };
      sleep: { headline: string; explanation: string };
      rhythm: { headline: string; explanation: string };
    };
    whatThisMeansForToday: string;
  };
  todayOneThing: {
    icon: string;               // "walking" | "breathing" | "rest" | "sun" | "coffee"
    action: string;             // "14時頃に5分の散歩"
    summary: string;            // "夕方のリズムが整います"
    time: string;               // "14:00"
    whyThisAction: string;      // 理由の説明
    benefits: string[];         // 3つの効果
    howToDoIt: string[];        // 実践ステップ
    expectedBenefit: {
      text: string;             // "Afternoon walks are linked to 10-20% better sleep"
      source: string;           // "Based on circadian rhythm research"
    };
  };
  relatedInsight: {
    label: string;              // "Research Finding"
    text: string;               // "Sleeping before 11 PM is associated with..."
    source: string;             // "Based on circadian rhythm research"
  };
}
```

詳細は [ai_prompt_spec.md](./ai_prompt_spec.md) を参照

---

## 5. データフロー

### 5.1 アプリ起動時のフロー

```
1. アプリ起動
   ↓
2. AsyncStorageからキャッシュ確認
   ↓
3. HealthKitからデータ取得
   ├─ 今日のHealth指標
   ├─ 過去7日の睡眠データ
   └─ 過去60日のHRV/RHRデータ（Baseline用）
   ↓
4. ローカル計算
   ├─ Baseline算出（60日移動平均）
   ├─ Typical Range算出（5-95パーセンタイル）
   ├─ 4スコア算出（Recovery/Sleep/Rhythm/Energy）
   └─ テンプレート文生成（Recovery/Sleep説明文）
   ↓
5. 環境API呼び出し（/api/environment）
   ├─ 天気・気温・湿度
   ├─ 気圧・気圧トレンド
   ├─ UV指数
   ├─ 日の出/日の入り
   └─ 月齢
   ↓
6. AIアドバイスAPI呼び出し（/api/advice）
   ├─ 計算済みスコアを送信
   └─ AIは解釈・アドバイスのみ生成
   ↓
7. レスポンスをキャッシュ（24時間有効）
   ↓
8. Today画面に表示
```

### 5.2 Health詳細画面のフロー

```
1. Health Summaryタップ
   ↓
2. Health詳細画面表示
   ↓
3. デフォルト7Dデータを表示
   ↓
4. タブ切り替え（30D/60D）
   ↓
5. キャッシュ確認
   ├─ キャッシュあり → 即時表示
   └─ キャッシュなし → HealthKit取得 → 表示
   ↓
6. チャート更新
   ├─ 7D: 日別ポイント
   └─ 30D/60D: 週別平均ポイント
```

### 5.3 4スコア詳細画面のフロー

```
1. Recovery/Sleep/Rhythm/Energyカードタップ
   ↓
2. 詳細画面表示
   ↓
3. テンプレート文を表示（ローカル生成済み）
   ↓
4. 7日間バーチャートを表示
   ↓
5. タブ切り替え（30D/60D）で履歴チャート更新
```

---

## 6. ローカルストレージ

### 6.1 AsyncStorage構造

| キー | 内容 | 有効期限 |
|-----|------|---------|
| `@user_profile` | ユーザー設定（goals, wake/wind down time） | 永続 |
| `@onboarding_completed` | オンボーディング完了フラグ | 永続 |
| `@advice_cache` | AIアドバイスのキャッシュ | 24時間 |
| `@health_today` | 今日のHealth指標 | 1時間 |
| `@health_7d` | 過去7日のデータ | 6時間 |
| `@health_30d` | 過去30日のデータ | 24時間 |
| `@health_60d` | 過去60日のデータ | 24時間 |
| `@baselines` | 各指標のBaseline値 | 24時間 |
| `@typical_ranges` | 各指標のTypical Range | 7日 |
| `@scores_history_{date}` | 日次スコア履歴 | 90日 |

### 6.2 キャッシュ管理

```typescript
interface CacheConfig {
  '@health_today': { ttl: 1 * 60 * 60 * 1000 };      // 1時間
  '@health_7d': { ttl: 6 * 60 * 60 * 1000 };         // 6時間
  '@health_30d': { ttl: 24 * 60 * 60 * 1000 };       // 24時間
  '@health_60d': { ttl: 24 * 60 * 60 * 1000 };       // 24時間
  '@advice_cache': { ttl: 24 * 60 * 60 * 1000 };     // 24時間
  '@baselines': { ttl: 24 * 60 * 60 * 1000 };        // 24時間
  '@typical_ranges': { ttl: 7 * 24 * 60 * 60 * 1000 }; // 7日
}

async function invalidateCacheOnDateChange(): Promise<void> {
  const lastDate = await AsyncStorage.getItem('@last_active_date');
  const today = new Date().toDateString();
  
  if (lastDate !== today) {
    // 日付が変わったらキャッシュをクリア
    await AsyncStorage.multiRemove([
      '@health_today',
      '@advice_cache',
    ]);
    await AsyncStorage.setItem('@last_active_date', today);
  }
}
```

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

## 9. パフォーマンス考慮

### 9.1 HealthKit取得の最適化

```typescript
// バッチ取得で複数指標を並列取得
async function fetchAllHealthMetrics(range: TimeRange): Promise<AllMetrics> {
  const { start, end } = getDateRangeForTab(range);
  
  const [hrv, rhr, sleep, respiratory, spo2, wristTemp] = await Promise.all([
    fetchHealthKitData({ metric: 'hrv', startDate: start, endDate: end }),
    fetchHealthKitData({ metric: 'rhr', startDate: start, endDate: end }),
    fetchHealthKitData({ metric: 'sleep', startDate: start, endDate: end }),
    fetchHealthKitData({ metric: 'respiratory', startDate: start, endDate: end }),
    fetchHealthKitData({ metric: 'spo2', startDate: start, endDate: end }),
    fetchHealthKitData({ metric: 'wristTemp', startDate: start, endDate: end }),
  ]);
  
  return { hrv, rhr, sleep, respiratory, spo2, wristTemp };
}
```

### 9.2 遅延ロード

```typescript
// 詳細画面は遅延ロード
const RecoveryDetail = lazy(() => import('./screens/RecoveryDetail'));
const SleepDetail = lazy(() => import('./screens/SleepDetail'));
const HealthDetail = lazy(() => import('./screens/HealthDetail'));
```

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2026-01-06 | 初版（旧仕様書から移行） |
| 2.0 | 2026-01-06 | 新UI対応、API設計更新 |
| 3.0 | 2026-01-07 | 4指標体系対応、HealthKit拡張、期間別データ取得追加 |
| 3.1 | 2026-01-07 | 環境データ拡張（UV指数・月齢追加）、/api/environment仕様更新 |
