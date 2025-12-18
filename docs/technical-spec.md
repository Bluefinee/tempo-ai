# Tempo AI 技術仕様書

**バージョン**: 2.0
**最終更新日**: 2025 年 12 月 19 日  
**ステータス**: MVP 開発準備中（シンプル化版）

---

## 関連ドキュメント

| ドキュメント        | 内容                                      |
| ------------------- | ----------------------------------------- |
| プロダクト仕様書    | 機能要件、ユーザープロフィール設計        |
| UI/UX 仕様書        | 詳細な画面設計、デザインシステム          |
| AI プロンプト設計書 | プロンプト構造、例文集、JSON 出力スキーマ |

---

## 1. システムアーキテクチャ

### 1.1 技術スタック

| レイヤー | 技術                  | バージョン               |
| -------- | --------------------- | ------------------------ |
| iOS      | SwiftUI               | iOS 17+                  |
| iOS      | HealthKit             | -                        |
| iOS      | CoreLocation          | -                        |
| Backend  | Cloudflare Workers    | -                        |
| Backend  | Hono                  | 4.x                      |
| Backend  | TypeScript            | 5.x                      |
| AI       | Claude API (Sonnet 4) | claude-sonnet-4-20250514 |
| Weather  | Open-Meteo API        | Free tier                |

### 1.2 データフロー（アドバイス生成）

```
1. ユーザーがアプリを起動
    ↓
2. キャッシュ確認（同日のアドバイスがあるか）
    ↓ なければ
3. HealthKitからデータ取得（デバイス内）
    ↓
4. 位置情報から気象・大気汚染データ取得
    ↓
5. ユーザープロフィール + HealthKitデータ + 環境データを統合
    ↓
6. Workers API経由でClaude APIにデータ送信・アドバイス生成
    ↓
7. アドバイスをキャッシュ・表示
```

---

## 2. iOS 設計

### 2.1 ディレクトリ構造

```
ios/TempoAI/
├── App/
│   ├── TempoAIApp.swift
│   └── ContentView.swift
├── Features/
│   ├── Onboarding/
│   │   ├── Views/
│   │   └── Models/
│   ├── Home/
│   │   ├── Views/
│   │   └── Models/
│   ├── Condition/
│   │   ├── Views/
│   │   └── Models/
│   └── Settings/
│       ├── Views/
│       └── Models/
├── Services/
│   ├── HealthKitManager.swift
│   ├── LocationManager.swift
│   ├── APIClient.swift
│   └── CacheManager.swift
└── Shared/
    ├── Models/
    ├── Extensions/
    └── Components/
```

### 2.2 主要クラス設計

#### HealthKitManager

```swift
@MainActor
final class HealthKitManager: ObservableObject {
    @Published var isAuthorized: Bool = false

    private let healthStore = HKHealthStore()

    // 必須データ型
    private let requiredTypes: Set<HKObjectType> = [
        HKQuantityType(.heartRate),
        HKQuantityType(.heartRateVariabilitySDNN),
        HKQuantityType(.restingHeartRate),
        HKQuantityType(.stepCount),
        HKCategoryType(.sleepAnalysis),
        HKQuantityType(.activeEnergyBurned)
    ]

    func requestAuthorization() async throws { }
    func fetchTodayHealthData() async throws -> HealthData { }
    func fetchWeekTrends() async throws -> WeekTrends { }
}
```

#### APIClient

```swift
final class APIClient {
    static let shared = APIClient()

    private let baseURL = "https://tempo-ai.YOUR_SUBDOMAIN.workers.dev"

    func generateAdvice(request: AdviceRequest) async throws -> DailyAdvice { }
}
```

#### CacheManager

```swift
final class CacheManager {
    static let shared = CacheManager()

    // ユーザープロフィール
    func saveUserProfile(_ profile: UserProfile) { }
    func loadUserProfile() -> UserProfile? { }

    // アドバイスキャッシュ（24時間）
    func saveAdvice(_ advice: DailyAdvice, for date: Date) { }
    func loadAdvice(for date: Date) -> DailyAdvice? { }

    // トライ履歴（過去2週間）
    func saveDailyTry(_ topic: String, date: Date) { }
    func getRecentDailyTries(days: Int) -> [String] { }
}
```

### 2.3 データモデル

#### UserProfile

```swift
struct UserProfile: Codable {
    let nickname: String
    let age: Int
    let gender: Gender
    let weightKg: Double
    let heightCm: Double
    let occupation: Occupation?
    let lifestyleRhythm: LifestyleRhythm?
    let exerciseFrequency: ExerciseFrequency?
    let interestTags: [InterestTag]
}
```

#### HealthData

```swift
struct HealthData: Codable {
    let sleep: SleepData?
    let hrv: HRVData?
    let heartRate: HeartRateData?
    let activity: ActivityData?
    let trends: TrendsData?
}

struct SleepData: Codable {
    let totalMinutes: Int
    let deepSleepPercent: Double
    let remSleepPercent: Double
    let bedTime: Date
    let wakeTime: Date
}

struct HRVData: Codable {
    let morningValue: Double
    let sevenDayAverage: Double
    let thirtyDayAverage: Double
}

struct ActivityData: Codable {
    let steps: Int
    let activeMinutes: Int
    let caloriesBurned: Double
}
```

#### DailyAdvice

```swift
struct DailyAdvice: Codable {
    let date: Date
    let greeting: String
    let conditionSummary: String
    let actionSuggestions: [String]
    let dailyTry: DailyTry
    let farewell: String
}

struct DailyTry: Codable {
    let title: String
    let description: String
    let category: TryCategory
}
```

---

## 3. Backend 設計

### 3.1 Cloudflare Workers 構成

```
workers/
├── src/
│   ├── index.ts              # エントリーポイント
│   ├── routes/
│   │   └── advice.ts         # アドバイス生成エンドポイント
│   ├── services/
│   │   ├── claude.ts         # Claude API統合
│   │   ├── weather.ts        # Open-Meteo統合
│   │   └── airQuality.ts     # 大気質データ取得
│   └── types/
│       └── index.ts          # 型定義
├── wrangler.toml
└── package.json
```

### 3.2 主要エンドポイント

#### POST /api/advice

アドバイス生成

**Request:**

```typescript
{
  profile: UserProfile,
  healthData: HealthData,
  location: {
    latitude: number,
    longitude: number,
    city: string
  }
}
```

**Response:**

```typescript
{
  advice: DailyAdvice,
  generatedAt: string
}
```

### 3.3 Claude API 統合

```typescript
// services/claude.ts

export async function generateAdvice(
  userProfile: UserProfile,
  healthData: HealthData,
  weatherData: WeatherData,
  airQualityData: AirQualityData
): Promise<DailyAdvice> {
  const prompt = buildPrompt(
    userProfile,
    healthData,
    weatherData,
    airQualityData
  );

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": env.ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1500,
      messages: [
        {
          role: "user",
          content: prompt,
        },
      ],
    }),
  });

  const data = await response.json();
  return parseAdviceResponse(data);
}
```

### 3.4 Open-Meteo API 統合

```typescript
// services/weather.ts

export async function fetchWeatherData(
  latitude: number,
  longitude: number
): Promise<WeatherData> {
  const url = new URL("https://api.open-meteo.com/v1/forecast");
  url.searchParams.set("latitude", latitude.toString());
  url.searchParams.set("longitude", longitude.toString());
  url.searchParams.set(
    "current",
    "temperature_2m,relative_humidity_2m,weather_code"
  );
  url.searchParams.set("daily", "temperature_2m_max,uv_index_max");

  const response = await fetch(url.toString());
  return response.json();
}

// services/airQuality.ts

export async function fetchAirQualityData(
  latitude: number,
  longitude: number
): Promise<AirQualityData> {
  const url = new URL("https://air-quality-api.open-meteo.com/v1/air-quality");
  url.searchParams.set("latitude", latitude.toString());
  url.searchParams.set("longitude", longitude.toString());
  url.searchParams.set("current", "pm2_5,pm10,us_aqi");

  const response = await fetch(url.toString());
  return response.json();
}
```

---

## 4. AI プロンプト設計

### 4.1 プロンプト構造

```
Layer 1: システムプロンプト（静的・キャッシュ対象）
  - 役割定義: 「あなたは優しいお姉さんのようなヘルスアドバイザーです」
  - 禁止事項: 医学的診断の禁止
  - トーン: 温かく、励まし、データに基づく
  - 出力形式: JSON

Layer 2: 例文（動的選択）
  - 良好版・疲労版の例文

Layer 3: ユーザーデータ（動的）
  - プロフィール、HealthKit、気象データ
```

### 4.2 出力 JSON 形式

```typescript
{
  "greeting": "マサさん、おはようございます",
  "condition_summary": "昨夜は7時間15分の...",
  "action_suggestions": [
    "午前中に軽い散歩を...",
    "水分を意識的に摂取...",
    "15時までにカフェイン..."
  ],
  "daily_try": {
    "title": "呼吸法で心を整える",
    "description": "夜寝る前に、4-7-8呼吸法を...",
    "category": "mental"
  },
  "farewell": "良い一日をお過ごしください。"
}
```

---

## 5. コスト試算

### 5.1 Claude API コスト

**モデル**: Claude Sonnet 4 (`claude-sonnet-4-20250514`)

| 項目     | トークン数 | 料金（/1M） | コスト      |
| -------- | ---------- | ----------- | ----------- |
| 入力     | ~2000      | $3.00/1M    | $0.006      |
| 出力     | ~300       | $15.00/1M   | $0.0045     |
| **合計** |            |             | **$0.0105** |

**月間コスト目安**（1 日 1 回利用、30 日）:

- 1 ユーザーあたり: ~$0.32/月

### 5.2 Open-Meteo API

- **無料**: 制限あり（10,000 リクエスト/日）
- MVP 段階では十分

---

## 6. エラーハンドリング

### 6.1 iOS 側エラー定義

```swift
enum TempoError: Error, LocalizedError {
    case networkError(underlying: Error)
    case healthKitNotAvailable
    case healthKitNotAuthorized
    case healthKitDataUnavailable
    case locationNotAuthorized
    case locationUnavailable
    case apiError(message: String)
    case cacheError
    case parseError

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "インターネット接続を確認してください"
        case .healthKitDataUnavailable:
            return "ヘルスケアデータが不足しています"
        case .locationUnavailable:
            return "位置情報を取得できませんでした"
        default:
            return "エラーが発生しました"
        }
    }
}
```

### 6.2 エラー対応表

| エラー種別           | iOS 側表示               | フォールバック                 |
| -------------------- | ------------------------ | ------------------------------ |
| ネットワークエラー   | 接続確認メッセージ       | キャッシュ済みアドバイス表示   |
| HealthKit データ不足 | データ不足メッセージ     | 一般的なアドバイス生成         |
| 位置情報取得失敗     | 都市選択ダイアログ       | 手動入力された都市で継続       |
| Claude API エラー    | 一時的なエラーメッセージ | 前日のアドバイス表示           |
| Weather API エラー   | (非表示)                 | 気象データなしでアドバイス生成 |

---

## 7. セキュリティ

### 7.1 API 保護

```typescript
// middleware/auth.ts

const API_KEY = "tempo-ai-mobile-app-key-v1";

export const validateApiKey = async (c: Context, next: Next) => {
  const apiKey = c.req.header("X-API-Key");

  if (apiKey !== API_KEY) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  await next();
};
```

**注意**: MVP 用の簡易実装。本番運用では OAuth/OIDC 等への移行が必要。

### 7.2 データ保護原則

| 原則         | 実装                                     |
| ------------ | ---------------------------------------- |
| データ最小化 | HealthKit データはデバイス内のみ保存     |
| 匿名化       | AI 送信時は本名・メールアドレス除外      |
| 透明性       | データ使用目的を明示（オンボーディング） |
| 暗号化       | HTTPS 通信のみ                           |

---

## 8. デプロイメント

### 8.1 iOS アプリ

- **配布**: TestFlight → App Store
- **最小バージョン**: iOS 17.0
- **必須権限**: HealthKit, CoreLocation

### 8.2 Cloudflare Workers

```bash
# デプロイ
wrangler deploy

# 環境変数設定
wrangler secret put ANTHROPIC_API_KEY
```

**環境変数:**

- `ANTHROPIC_API_KEY`: Claude API キー

---

## 9. モニタリング

### 9.1 主要メトリクス

| メトリクス                     | 目標値 |
| ------------------------------ | ------ |
| API レスポンスタイム           | < 2 秒 |
| エラー率                       | < 1%   |
| キャッシュヒット率             | > 80%  |
| 1 日あたりのアクティブユーザー | -      |

### 9.2 ログ

Cloudflare Workers のログを活用：

- リクエスト/レスポンスログ
- エラーログ
- Claude API 呼び出しログ

---

## 10. 開発フロー

### 10.1 Phase 1: 基本機能

1. オンボーディング実装
2. HealthKit 統合
3. 気象データ統合
4. Claude API 統合
5. ホーム画面実装
6. キャッシュ実装

### 10.2 Phase 2: コンディション画面

1. メトリクスカード実装
2. 詳細画面実装（4 画面）
3. スコア算出ロジック実装
4. 週間トレンドグラフ実装

### 10.3 Phase 3: リリース準備

1. エラーハンドリング強化
2. パフォーマンス最適化
3. TestFlight テスト
4. App Store 申請

---

## 改訂履歴

| バージョン | 日付       | 変更内容                                         |
| ---------- | ---------- | ------------------------------------------------ |
| 1.0        | 2025-12-09 | 初版作成                                         |
| 2.0        | 2025-12-19 | シンプル化版（追加アドバイス削除、500 行以内化） |

---

**以上、Tempo AI 技術仕様書 v2.0（シンプル化版）**
