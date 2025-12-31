# Tempo AI 技術仕様書

**バージョン**: 3.0  
**最終更新日**: 2025年12月19日

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [product-spec.md](./product-spec.md) | 機能要件 |
| [ui-spec.md](./ui-spec.md) | UI/UX設計 |
| [metrics-spec.md](./metrics-spec.md) | スコア算出アルゴリズム |
| [ai-prompt-spec.md](./ai-prompt-spec.md) | AIプロンプト仕様 |
| [phases.md](../phases/phases.md) | 開発フェーズ管理 |

---

## 1. 技術スタック

| レイヤー | 技術 | バージョン |
|---------|------|-----------|
| iOS | SwiftUI | iOS 17+ |
| iOS | HealthKit | - |
| iOS | CoreLocation | - |
| Backend | Cloudflare Workers | - |
| Backend | Hono | 4.x |
| Backend | TypeScript | 5.x |
| AI | Claude Sonnet 4 | claude-sonnet-4-20250514 |
| Weather | Open-Meteo API | Free tier |

---

## 2. データフロー

```
1. アプリ起動
    ↓
2. キャッシュ確認（同日のアドバイスがあるか）
    ↓ なければ
3. HealthKitからデータ取得（デバイス内）
    ↓
4. 位置情報から気象・大気汚染データ取得
    ↓
5. Workers API経由でClaude APIにリクエスト
    ↓
6. アドバイスをキャッシュ・表示
```

---

## 3. iOS設計

### 3.1 ディレクトリ構造

```
ios/TempoAI/
├── App/
│   ├── TempoAIApp.swift
│   └── ContentView.swift
├── Features/
│   ├── Onboarding/
│   ├── Home/
│   ├── CircadianRhythm/
│   └── Settings/
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

### 3.2 主要クラス

#### HealthKitManager

```swift
@MainActor
final class HealthKitManager: ObservableObject {
    @Published var isAuthorized: Bool = false
    
    private let healthStore = HKHealthStore()
    
    private let requiredTypes: Set<HKObjectType> = [
        HKQuantityType(.heartRateVariabilitySDNN),
        HKQuantityType(.restingHeartRate),
        HKQuantityType(.stepCount),
        HKCategoryType(.sleepAnalysis)
    ]

    // 補助データ（対応機種のみ）
    private let optionalTypes: Set<HKObjectType> = [
        HKQuantityType(.timeInDaylight),                    // watchOS 10+
        HKQuantityType(.appleSleepingWristTemperature)      // Series 8+/Ultra
    ]

    func requestAuthorization() async throws { }
    func fetchAuxiliaryData() async -> AuxiliaryData? {
        // 対応機種でない場合はnilを返す
    }
    func fetchTodayHealthData() async throws -> HealthData { }
    func fetchWeekTrends() async throws -> WeekTrends { }
}
```

#### CacheManager

```swift
final class CacheManager {
    static let shared = CacheManager()
    
    // キー形式: advice_YYYY-MM-DD
    func saveAdvice(_ advice: DailyAdvice, for date: Date) { }
    func loadAdvice(for date: Date) -> DailyAdvice? { }
    
    // トライ履歴（過去2週間）
    func saveDailyTry(_ topic: String, date: Date) { }
    func getRecentDailyTries(days: Int) -> [String] { }
}
```

### 3.3 データモデル

#### DailyAdvice

```swift
struct DailyAdvice: Codable {
    let date: Date
    let greeting: String
    let condition: Condition
    let insight: String
    let dailyTry: DailyTry
    let closingMessage: String
}

struct Condition: Codable {
    let summary: String
    let detail: String
}

struct DailyTry: Codable {
    let title: String
    let detail: String
}
```

#### HealthData

```swift
struct HealthData: Codable {
    let sleep: SleepData?
    let hrv: HRVData?
    let activity: ActivityData?
    let scores: Scores?
    let rhythmStability: RhythmStability?
}

struct Scores: Codable {
    let sleep: Int
    let hrv: Int
    let rhythm: Int
    let activity: Int
}

struct RhythmStability: Codable {
    let status: String
    let consecutiveStableDays: Int
}

struct AuxiliaryData: Codable {
    let daylight: DaylightData?
    let wristTemperature: WristTemperatureData?
}

struct DaylightData: Codable {
    let minutesYesterday: Int
    let status: DaylightStatus  // sufficient, slightlyInsufficient, insufficient
    let avg7dMinutes: Int?
}

struct WristTemperatureData: Codable {
    let deviation: Double       // 基準値からの偏差（℃）
    let status: TemperatureStatus  // stable, slightlyVariable, variable
}

enum DaylightStatus: String, Codable {
    case sufficient = "十分"
    case slightlyInsufficient = "やや不足"
    case insufficient = "不足"
}

enum TemperatureStatus: String, Codable {
    case stable = "安定"
    case slightlyVariable = "やや変動"
    case variable = "変動大"
}
```

---

## 4. Backend設計

### 4.1 ディレクトリ構造

```
backend/
├── src/
│   ├── index.ts
│   ├── routes/
│   │   └── advice.ts
│   ├── services/
│   │   ├── claude.ts
│   │   ├── weather.ts
│   │   └── airQuality.ts
│   └── types/
│       └── index.ts
├── wrangler.toml
└── package.json
```

### 4.2 APIエンドポイント

#### POST /api/advice

**Request:**

```typescript
interface AdviceRequest {
  profile: UserProfile;
  healthData: HealthData;
  location: {
    latitude: number;
    longitude: number;
    city: string;
  };
  context: {
    currentTime: string;
    dayOfWeek: string;
    recentDailyTries: string[];
  };
}
```

**Response:**

```typescript
interface AdviceResponse {
  greeting: string;
  condition: {
    summary: string;
    detail: string;
  };
  insight: string;
  daily_try: {
    title: string;
    detail: string;
  };
  closing_message: string;
}
```

### 4.3 Claude API統合

```typescript
export async function generateAdvice(
  request: AdviceRequest,
  weatherData: WeatherData,
  airQualityData: AirQualityData
): Promise<AdviceResponse> {
  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": env.ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
      "anthropic-beta": "prompt-caching-2024-07-31"
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1500,
      system: [
        {
          type: "text",
          text: systemPrompt,
          cache_control: { type: "ephemeral" }
        }
      ],
      messages: [{ role: "user", content: userMessage }]
    })
  });
  
  return parseResponse(response);
}
```

### 4.4 外部API統合

```typescript
// Weather
const weatherUrl = new URL("https://api.open-meteo.com/v1/forecast");
weatherUrl.searchParams.set("current", "temperature_2m,relative_humidity_2m,pressure_msl,weather_code");
weatherUrl.searchParams.set("daily", "uv_index_max");

// Air Quality
const aqUrl = new URL("https://air-quality-api.open-meteo.com/v1/air-quality");
aqUrl.searchParams.set("current", "pm2_5,pm10,us_aqi");
```

---

## 5. コスト試算

### Claude API

| 項目 | トークン数 | 料金 | コスト |
|------|-----------|------|--------|
| 入力（キャッシュヒット時） | ~3500 | $0.30/1M | $0.00105 |
| 入力（キャッシュミス時） | ~800 | $3.00/1M | $0.0024 |
| 出力 | ~400 | $15.00/1M | $0.006 |
| **合計** | | | **~$0.009/回** |

**月間コスト目安**（1日1回、30日）: ~$0.27/ユーザー

### Open-Meteo API

無料（10,000リクエスト/日）

---

## 6. エラーハンドリング

### iOS側エラー定義

```swift
enum TempoError: Error {
    case networkError(underlying: Error)
    case healthKitNotAuthorized
    case healthKitDataUnavailable
    case locationUnavailable
    case apiError(message: String)
}
```

### エラー対応表

| エラー | フォールバック |
|--------|---------------|
| ネットワークエラー | キャッシュ済みアドバイス表示 |
| HealthKitデータ不足 | 一般的なアドバイス生成 |
| 位置情報取得失敗 | 都市選択ダイアログ |
| Claude APIエラー | 前日のアドバイス表示 |
| Weather APIエラー | 気象データなしで生成 |

---

## 7. セキュリティ

### API保護（MVP）

```typescript
const API_KEY = "tempo-ai-mobile-app-key-v1";

export const validateApiKey = async (c: Context, next: Next) => {
  const apiKey = c.req.header("X-API-Key");
  if (apiKey !== API_KEY) {
    return c.json({ error: "Unauthorized" }, 401);
  }
  await next();
};
```

> **Note**: MVP用の簡易実装。本番運用ではOAuth/OIDC等への移行が必要。

### データ保護

| 原則 | 実装 |
|------|------|
| データ最小化 | HealthKitデータはデバイス内のみ保存 |
| 匿名化 | AI送信時は個人識別情報を除外 |
| 暗号化 | HTTPS通信のみ |

---

## 8. デプロイメント

### iOS

- **配布**: TestFlight → App Store
- **最小バージョン**: iOS 17.0
- **必須権限**: HealthKit, CoreLocation

### Cloudflare Workers

```bash
# デプロイ
wrangler deploy

# 環境変数設定
wrangler secret put ANTHROPIC_API_KEY
```

---

## 9. データ要件

### 9.1 必須HealthKitデータ

| メトリクス | HealthKit Type | 用途 |
|-----------|---------------|------|
| HRV | HKQuantityType(.heartRateVariabilitySDNN) | 自律神経評価 |
| 安静時心拍数 | HKQuantityType(.restingHeartRate) | 回復度評価 |
| 歩数 | HKQuantityType(.stepCount) | 活動量評価 |
| 睡眠 | HKCategoryType(.sleepAnalysis) | 睡眠パターン分析 |

### 9.2 補助HealthKitデータ（任意）

| メトリクス | HealthKit Type | 対応機種 |
|-----------|---------------|----------|
| 日光浴時間 | HKQuantityType(.timeInDaylight) | watchOS 10+ |
| 皮膚温 | HKQuantityType(.appleSleepingWristTemperature) | Series 8+/Ultra |

---

## 10. モニタリング

| メトリクス | 目標値 |
|-----------|--------|
| APIレスポンスタイム | < 3秒 |
| エラー率 | < 1% |
| キャッシュヒット率 | > 80% |

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-09 | 初版作成 |
| 2.0 | 2025-12-19 | シンプル化版 |
| 2.1 | 2025-12-19 | サーカディアンリズム画面対応 |
| 3.0 | 2025-12-19 | 新仕様に統合（追加アドバイス削除、insight追加、フィールド名統一） |
