# TempoAI 技術仕様書

**バージョン**: 5.0  
**最終更新日**: 2025年1月1日

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [tempoai_product_spec.md](./tempoai_product_spec.md) | プロダクト仕様 |
| [tempoai_metrics_spec.md](./tempoai_metrics_spec.md) | スコア算出アルゴリズム |
| [tempoai_ai_prompt_spec.md](./tempoai_ai_prompt_spec.md) | AIプロンプト仕様 |
| [tempoai_knowledge_base.md](./tempoai_knowledge_base.md) | 科学的根拠 |

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

## 2. アーキテクチャ

### 設計原則

- **データベースレス**: ヘルスケアデータは端末内のみで処理
- **ドメイン駆動**: スコアリング等のビジネスロジックはドメインモデルに凝集
- **テスト容易性**: 純粋関数・依存性注入を前提

### レイヤー構成

```
┌─────────────────────────────────────────────────────┐
│ Presentation (SwiftUI Views)                        │
├─────────────────────────────────────────────────────┤
│ Application (ViewModels / UseCases)                 │
├─────────────────────────────────────────────────────┤
│ Domain (Models / Services) ← ビジネスロジック集約    │
├─────────────────────────────────────────────────────┤
│ Infrastructure (HealthKit / API / Cache)            │
└─────────────────────────────────────────────────────┘
```

### データフロー

```
HealthKitRepository → Domain Models → AdviceRequest → API → DailyAdvice
                          ↓
                    Score (値オブジェクト)
                    ConditionAssessment (集約)
```

---

## 3. iOS設計

### 3.1 ディレクトリ構造

```
ios/TempoAI/
├── App/
│   └── TempoAIApp.swift
├── Features/
│   ├── Onboarding/
│   ├── Home/
│   ├── Analytics/
│   └── Settings/
├── Domain/
│   ├── Models/
│   │   ├── Score.swift
│   │   ├── HealthMetrics.swift
│   │   ├── RhythmAnalysis.swift
│   │   └── UserProfile.swift
│   └── Services/
│       ├── ScoreCalculator.swift
│       └── RhythmAnalyzer.swift
├── Infrastructure/
│   ├── HealthKit/
│   │   └── HealthKitRepository.swift
│   ├── API/
│   │   └── AdviceAPIClient.swift
│   ├── Location/
│   │   └── LocationService.swift
│   └── Cache/
│       └── LocalStorage.swift
└── Shared/
    └── Extensions/
```

### 3.2 ドメインモデル

#### Score（値オブジェクト）

スコアとその評価を内包するリッチな値オブジェクト。

```swift
/// スコア値オブジェクト - ロジックを内包
struct Score: Equatable {
    let value: Int
    
    init(_ value: Int) {
        self.value = max(0, min(100, value))
    }
    
    var status: Status {
        switch value {
        case 80...100: return .excellent
        case 60..<80:  return .good
        case 40..<60:  return .fair
        case 20..<40:  return .poor
        default:       return .rest
        }
    }
    
    var icon: String {
        switch status {
        case .excellent: return "☀️"
        case .good:      return "⛅"
        case .fair:      return "🌥️"
        case .poor:      return "🌧️"
        case .rest:      return "⛈️"
        }
    }
    
    enum Status: String {
        case excellent = "絶好調"
        case good = "良好"
        case fair = "普通"
        case poor = "要休息"
        case rest = "休養優先"
    }
}
```

#### HealthMetrics（エンティティ）

HealthKitから取得した生データを保持。

```swift
struct HealthMetrics {
    let date: Date
    let sleep: SleepMetrics?
    let hrv: HRVMetrics?
    let activity: ActivityMetrics?
    let auxiliary: AuxiliaryMetrics?
}

struct SleepMetrics {
    let bedtime: Date
    let wakeTime: Date
    let durationMinutes: Int
    let deepSleepMinutes: Int
    let remSleepMinutes: Int
    
    var durationHours: Double {
        Double(durationMinutes) / 60.0
    }
    
    var deepSleepRatio: Double {
        guard durationMinutes > 0 else { return 0 }
        return Double(deepSleepMinutes) / Double(durationMinutes)
    }
}

struct HRVMetrics {
    let value: Double           // ms
    let baseline30d: Double
    
    var deviationPercent: Double {
        guard baseline30d > 0 else { return 0 }
        return ((value - baseline30d) / baseline30d) * 100
    }
}

struct ActivityMetrics {
    let stepsYesterday: Int
    let activeMinutesYesterday: Int
}

struct AuxiliaryMetrics {
    let daylight: DaylightMetrics?
    let wristTemperature: WristTemperatureMetrics?
}

struct DaylightMetrics {
    let minutesYesterday: Int
    
    var status: DaylightStatus {
        switch minutesYesterday {
        case 45...: return .sufficient
        case 30..<45: return .slightlyInsufficient
        default: return .insufficient
        }
    }
}

enum DaylightStatus: String, Codable {
    case sufficient = "十分"
    case slightlyInsufficient = "やや不足"
    case insufficient = "不足"
}

struct WristTemperatureMetrics {
    let deviation: Double
    
    var status: TemperatureStatus {
        switch abs(deviation) {
        case 0..<0.2: return .stable
        case 0.2..<0.5: return .slightlyVariable
        default: return .variable
        }
    }
}

enum TemperatureStatus: String, Codable {
    case stable = "安定"
    case slightlyVariable = "やや変動"
    case variable = "変動大"
}
```

#### RhythmAnalysis（集約）

リズムの安定性を分析・評価する集約ルート。

```swift
struct RhythmAnalysis {
    let bedtimeStddevMinutes: Double
    let wakeTimeStddevMinutes: Double
    let consecutiveStableDays: Int
    let wristTemperature: WristTemperatureMetrics?
    
    var status: RhythmStatus {
        if consecutiveStableDays >= 5 { return .stable }
        if consecutiveStableDays >= 3 { return .recovering }
        return .unstable
    }
    
    var isStable: Bool {
        bedtimeStddevMinutes <= 30 && wakeTimeStddevMinutes <= 30
    }
}

enum RhythmStatus: String, Codable {
    case stable = "安定"
    case recovering = "回復中"
    case unstable = "乱れ気味"
}
```

#### ConditionAssessment（集約）

全スコアを統合した状態評価。

```swift
struct ConditionAssessment {
    let sleepScore: Score
    let autonomicScore: Score
    let rhythmScore: Score
    let activityScore: Score
    let rhythmAnalysis: RhythmAnalysis
    
    /// 最も改善が必要な領域
    var weakestArea: Area {
        let scores = [
            (Area.sleep, sleepScore.value),
            (Area.autonomic, autonomicScore.value),
            (Area.rhythm, rhythmScore.value),
            (Area.activity, activityScore.value)
        ]
        return scores.min(by: { $0.1 < $1.1 })?.0 ?? .sleep
    }
    
    enum Area {
        case sleep, autonomic, rhythm, activity
    }
}
```

#### UserProfile（エンティティ）

```swift
struct UserProfile: Codable {
    let nickname: String
    let age: Int
    let gender: Gender
    let weight: Double
    let height: Double
    let occupation: Occupation?
    let chronotype: Chronotype
    let exerciseFrequency: ExerciseFrequency?
    let alcoholFrequency: AlcoholFrequency?
    let targetBedtime: Date
}

enum Gender: String, Codable {
    case male, female, other, preferNotToSay
}

enum Chronotype: String, Codable {
    case morning = "朝型"
    case intermediate = "中間型"
    case evening = "夜型"
}

enum Occupation: String, Codable {
    case deskWork = "デスクワーク"
    case standingWork = "立ち仕事"
    case physicalWork = "肉体労働"
    case hybrid = "ハイブリッド"
    case other = "その他"
}

enum ExerciseFrequency: String, Codable {
    case rarely = "ほとんどしない"
    case onceWeek = "週1回"
    case twiceWeek = "週2回"
    case threeOrMore = "週3回以上"
    case daily = "毎日"
}

enum AlcoholFrequency: String, Codable {
    case never = "飲まない"
    case rarely = "月に数回"
    case weekly = "週に数回"
    case daily = "ほぼ毎日"
}
```

### 3.3 ドメインサービス

#### ScoreCalculator

純粋関数でスコアを算出。テスト容易性を最大化。

```swift
/// スコア算出サービス - 純粋関数で構成
struct ScoreCalculator {
    
    // MARK: - Autonomic Score
    
    static func calculateAutonomicScore(
        hrv: HRVMetrics,
        sleep: SleepMetrics?
    ) -> Score {
        let baseScore = 70
        let deviation = hrv.deviationPercent
        var rawScore = Double(baseScore) + deviation
        
        // 補正
        if let sleep = sleep, sleep.deepSleepRatio < 0.15 {
            rawScore -= 5
        }
        
        return Score(Int(rawScore))
    }
    
    // MARK: - Sleep Score
    
    static func calculateSleepScore(
        sleep: SleepMetrics,
        targetHours: Double = 7.5
    ) -> Score {
        let durationScore = Self.durationScore(sleep.durationHours, target: targetHours)
        let deepScore = Self.deepSleepScore(sleep.deepSleepRatio)
        
        let rawScore = durationScore * 0.5 + deepScore * 0.5
        return Score(Int(rawScore))
    }
    
    // MARK: - Rhythm Score
    
    static func calculateRhythmScore(
        analysis: RhythmAnalysis
    ) -> Score {
        let bedtimeScore = Self.consistencyScore(analysis.bedtimeStddevMinutes)
        let wakeScore = Self.consistencyScore(analysis.wakeTimeStddevMinutes)
        
        var rawScore: Double
        if let temp = analysis.wristTemperature {
            let tempScore = Self.temperatureScore(temp)
            rawScore = bedtimeScore * 0.35 + wakeScore * 0.35 + tempScore * 0.30
        } else {
            rawScore = bedtimeScore * 0.5 + wakeScore * 0.5
        }
        
        return Score(Int(rawScore))
    }
    
    // MARK: - Activity Score
    
    static func calculateActivityScore(
        activity: ActivityMetrics,
        targetSteps: Int = 8000
    ) -> Score {
        let ratio = Double(activity.stepsYesterday) / Double(targetSteps)
        let rawScore = min(100, ratio * 100)
        return Score(Int(rawScore))
    }
    
    // MARK: - Private Helpers
    
    private static func durationScore(_ hours: Double, target: Double) -> Double {
        let diff = abs(hours - target)
        if diff <= 0.5 { return 100 }
        if diff <= 1.0 { return 85 }
        if diff <= 1.5 { return 70 }
        return 50
    }
    
    private static func deepSleepScore(_ ratio: Double) -> Double {
        if ratio >= 0.15 && ratio <= 0.25 { return 100 }
        if ratio >= 0.10 { return 70 }
        return 50
    }
    
    private static func consistencyScore(_ stddev: Double) -> Double {
        if stddev <= 15 { return 100 }
        if stddev <= 30 { return 85 }
        if stddev <= 45 { return 70 }
        if stddev <= 60 { return 55 }
        return 40
    }
    
    private static func temperatureScore(_ temp: WristTemperatureMetrics) -> Double {
        switch temp.status {
        case .stable: return 100
        case .slightlyVariable: return 70
        case .variable: return 40
        }
    }
}
```

#### RhythmAnalyzer

過去データからリズムの安定性を分析。

```swift
struct RhythmAnalyzer {
    
    static func analyze(
        sleepHistory: [SleepMetrics],
        wristTemperature: WristTemperatureMetrics?
    ) -> RhythmAnalysis {
        let bedtimes = sleepHistory.map { $0.bedtime.timeIntervalSinceReferenceDate }
        let wakeTimes = sleepHistory.map { $0.wakeTime.timeIntervalSinceReferenceDate }
        
        let bedtimeStddev = Self.standardDeviation(bedtimes) / 60  // 分に変換
        let wakeTimeStddev = Self.standardDeviation(wakeTimes) / 60
        
        let stableDays = Self.countConsecutiveStableDays(
            sleepHistory: sleepHistory,
            threshold: 30
        )
        
        return RhythmAnalysis(
            bedtimeStddevMinutes: bedtimeStddev,
            wakeTimeStddevMinutes: wakeTimeStddev,
            consecutiveStableDays: stableDays,
            wristTemperature: wristTemperature
        )
    }
    
    private static func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDiffs = values.map { pow($0 - mean, 2) }
        let variance = squaredDiffs.reduce(0, +) / Double(values.count - 1)
        return sqrt(variance)
    }
    
    private static func countConsecutiveStableDays(
        sleepHistory: [SleepMetrics],
        threshold: Double
    ) -> Int {
        // 実装省略
        return 0
    }
}
```

### 3.4 インフラストラクチャ

#### HealthKitRepository

```swift
protocol HealthKitRepositoryProtocol {
    func requestAuthorization() async throws
    func fetchTodayMetrics() async throws -> HealthMetrics
    func fetchSleepHistory(days: Int) async throws -> [SleepMetrics]
    func fetchHRVBaseline(days: Int) async throws -> Double
}

final class HealthKitRepository: HealthKitRepositoryProtocol {
    private let healthStore = HKHealthStore()
    
    private let requiredTypes: Set<HKObjectType> = [
        HKQuantityType(.heartRateVariabilitySDNN),
        HKQuantityType(.restingHeartRate),
        HKQuantityType(.stepCount),
        HKCategoryType(.sleepAnalysis)
    ]
    
    private let optionalTypes: Set<HKObjectType> = [
        HKQuantityType(.timeInDaylight),
        HKQuantityType(.appleSleepingWristTemperature)
    ]
    
    func requestAuthorization() async throws { /* ... */ }
    func fetchTodayMetrics() async throws -> HealthMetrics { /* ... */ }
    func fetchSleepHistory(days: Int) async throws -> [SleepMetrics] { /* ... */ }
    func fetchHRVBaseline(days: Int) async throws -> Double { /* ... */ }
}
```

#### LocalStorage

```swift
protocol LocalStorageProtocol {
    func save<T: Codable>(_ value: T, forKey key: String)
    func load<T: Codable>(forKey key: String) -> T?
    func remove(forKey key: String)
}

final class LocalStorage: LocalStorageProtocol {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func save<T: Codable>(_ value: T, forKey key: String) { /* ... */ }
    func load<T: Codable>(forKey key: String) -> T? { /* ... */ }
    func remove(forKey key: String) { /* ... */ }
}
```

---

## 4. Backend設計

### 4.1 構成

```
backend/
├── src/
│   ├── index.ts
│   ├── routes/
│   │   └── advice.ts
│   ├── services/
│   │   ├── claude.ts
│   │   └── weather.ts
│   └── types/
│       └── index.ts
├── wrangler.toml
└── package.json
```

### 4.2 API

#### POST /api/advice

```typescript
interface AdviceRequest {
  profile: UserProfile;
  healthData: {
    sleep?: SleepData;
    hrv?: HRVData;
    activity?: ActivityData;
    scores: Scores;
    rhythmAnalysis: RhythmAnalysis;
    auxiliary?: AuxiliaryData;
  };
  location: { latitude: number; longitude: number; city: string };
  context: {
    currentTime: string;
    dayOfWeek: string;
    recentDailyTries: string[];
    mood?: number;
  };
}

interface AdviceResponse {
  greeting: string;
  energyComment: string;
  condition: { summary: string; detail: string };
  insight: string;
  dailyTry: { title: string; detail: string };
  closingMessage: string;
}
```

### 4.3 外部API（Open-Meteo）

無料で10,000リクエスト/日まで利用可能。

```typescript
// Weather
const weatherUrl = new URL("https://api.open-meteo.com/v1/forecast");
weatherUrl.searchParams.set("latitude", lat.toString());
weatherUrl.searchParams.set("longitude", lon.toString());
weatherUrl.searchParams.set("current", "temperature_2m,relative_humidity_2m,pressure_msl,weather_code");
weatherUrl.searchParams.set("daily", "uv_index_max,sunrise,sunset");
weatherUrl.searchParams.set("timezone", "auto");

// Air Quality
const aqUrl = new URL("https://air-quality-api.open-meteo.com/v1/air-quality");
aqUrl.searchParams.set("latitude", lat.toString());
aqUrl.searchParams.set("longitude", lon.toString());
aqUrl.searchParams.set("current", "pm2_5,us_aqi");
```

---

## 5. オンボーディング

### 5.1 フロー（HealthKit先行）

| ステップ | 情報 | 必須 | 備考 |
|---------|------|------|------|
| 1 | HealthKit認証 | ○ | **先に認証**（自動推定のため） |
| 2 | ニックネーム | ○ | |
| 3 | 年齢・性別・体重・身長 | ○ | 1画面に統合 |
| 4 | クロノタイプ | ○ | HealthKitから自動推定、確認のみ |
| 5 | 目標就寝時刻 | ○ | HealthKitから自動提案、調整可能 |
| 6 | 職業・運動頻度・飲酒頻度 | - | 任意、1画面に統合 |
| 7 | 位置情報認証 | ○ | |

### 5.2 HealthKitからの自動推定ロジック

#### クロノタイプ推定（MSFsc: Mid-Sleep on Free days, Sleep-corrected）

```swift
struct ChronotypeEstimator {
    
    /// 過去30日の睡眠データからクロノタイプを推定
    static func estimate(sleepHistory: [SleepMetrics]) -> (Chronotype, confidence: Double) {
        guard sleepHistory.count >= 7 else {
            return (.intermediate, confidence: 0.3) // データ不足時はデフォルト
        }
        
        // 睡眠中間点（MSF）を計算
        let midSleepTimes = sleepHistory.map { sleep -> Double in
            let bedtimeMinutes = minutesSinceMidnight(sleep.bedtime)
            let durationMinutes = Double(sleep.durationMinutes)
            return bedtimeMinutes + (durationMinutes / 2)
        }
        
        let avgMidSleep = midSleepTimes.reduce(0, +) / Double(midSleepTimes.count)
        
        // 時間に変換（分 → 時:分）
        let midSleepHour = avgMidSleep / 60
        
        // クロノタイプ判定
        let chronotype: Chronotype
        if midSleepHour < 3.0 {
            chronotype = .morning      // 〜3:00 → 朝型
        } else if midSleepHour < 5.0 {
            chronotype = .intermediate // 3:00-5:00 → 中間型
        } else {
            chronotype = .evening      // 5:00〜 → 夜型
        }
        
        // 信頼度（データ量に基づく）
        let confidence = min(1.0, Double(sleepHistory.count) / 30.0)
        
        return (chronotype, confidence: confidence)
    }
    
    private static func minutesSinceMidnight(_ date: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        // 深夜0時以降は+24時間として計算
        let adjustedHour = hour < 12 ? hour + 24 : hour
        return Double(adjustedHour * 60 + minute)
    }
}
```

#### 目標就寝時刻の提案

```swift
struct BedtimeRecommender {
    
    /// 過去30日の平均就寝時刻を提案
    static func recommend(sleepHistory: [SleepMetrics]) -> Date? {
        guard sleepHistory.count >= 7 else { return nil }
        
        let bedtimes = sleepHistory.map { $0.bedtime }
        let avgInterval = bedtimes.map { $0.timeIntervalSinceReferenceDate }.reduce(0, +) / Double(bedtimes.count)
        
        // 15分単位に丸める
        let roundedInterval = (avgInterval / 900).rounded() * 900
        
        return Date(timeIntervalSinceReferenceDate: roundedInterval)
    }
}
```

---

## 6. キャリブレーション期間

### 6.1 概要

初期7日間はスコアの精度が低いため、スコア表示を控えAIコメント主体で運用。

### 6.2 状態管理

```swift
struct CalibrationState: Codable {
    let startDate: Date
    var daysCompleted: Int
    var isComplete: Bool
    
    static let requiredDays = 7
    
    mutating func updateProgress(healthDataDays: Int) {
        daysCompleted = min(healthDataDays, Self.requiredDays)
        isComplete = daysCompleted >= Self.requiredDays
    }
}
```

### 6.3 UI表示ロジック

```swift
extension Score {
    func displayValue(isCalibrating: Bool) -> String {
        isCalibrating ? "---" : "\(value)"
    }
}
```

---

## 7. バックグラウンド処理

### 7.1 Background App Refresh

起床予定時刻の1時間前にAI Insightをプリフェッチ。

```swift
// AppDelegate or SceneDelegate
func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Task {
        do {
            let advice = try await prefetchDailyAdvice()
            localStorage.save(advice, forKey: "advice_\(Date().formatted(.iso8601))")
            completionHandler(.newData)
        } catch {
            completionHandler(.failed)
        }
    }
}

// BGTaskScheduler (iOS 13+)
func scheduleAdvicePrefetch() {
    let request = BGAppRefreshTaskRequest(identifier: "com.tempoai.advicePrefetch")
    
    // 起床予定時刻の1時間前
    if let targetBedtime = userProfile?.targetBedtime {
        let wakeTime = targetBedtime.addingTimeInterval(8 * 3600) // 8時間後
        let prefetchTime = wakeTime.addingTimeInterval(-3600)     // 1時間前
        request.earliestBeginDate = prefetchTime
    }
    
    try? BGTaskScheduler.shared.submit(request)
}
```

### 7.2 HealthKitバックグラウンド読み出し

```swift
// HealthKit Background Delivery
func enableBackgroundDelivery() {
    let types: [HKSampleType] = [
        HKQuantityType(.heartRateVariabilitySDNN),
        HKCategoryType(.sleepAnalysis)
    ]
    
    for type in types {
        healthStore.enableBackgroundDelivery(for: type, frequency: .daily) { success, error in
            if success {
                print("Background delivery enabled for \(type)")
            }
        }
    }
}
```

---

## 8. オフラインフォールバック

### 8.1 フォールバック戦略

| 状況 | フォールバック |
|------|---------------|
| ネットワークエラー | キャッシュ済みアドバイス表示 |
| キャッシュもなし | ローカル定型アドバイス生成 |
| HealthKitデータ不足 | データ不足を明示 |
| Claude APIエラー | 前日アドバイス + リトライボタン |

### 8.2 ローカル定型アドバイス生成

ネットワーク不可時にスコアベースで簡易アドバイスを生成。

```swift
struct LocalAdviceGenerator {
    
    static func generate(condition: ConditionAssessment, profile: UserProfile) -> DailyAdvice {
        let greeting = "おはようございます、\(profile.nickname)さん。"
        
        let summary: String
        let action: RecommendedAction
        
        switch condition.weakestArea {
        case .sleep:
            summary = "睡眠の質を高めることで、明日はもっと良いコンディションになりそうです。"
            action = RecommendedAction(type: .rest, message: "早めの就寝を心がけて")
        case .autonomic:
            summary = "今日は無理せず、こまめに休憩を取りながら過ごしましょう。"
            action = RecommendedAction(type: .breathing, message: "1分間の深呼吸を")
        case .rhythm:
            summary = "リズムを整えるために、朝の光を浴びることを意識してみてください。"
            action = RecommendedAction(type: .morningLight, message: "朝の光を15分浴びて")
        case .activity:
            summary = "少し体を動かすと、気分もリフレッシュできますよ。"
            action = RecommendedAction(type: .activity, message: "軽い散歩をしてみて")
        }
        
        return DailyAdvice(
            summary: greeting + summary,
            fullInsight: greeting + summary + "\n\n※ネットワーク接続時に詳細な分析を更新します。",
            recommendedAction: action,
            isOfflineFallback: true
        )
    }
}
```

## 9. ローカルストレージ

| キー | 内容 | 保持期間 |
|-----|------|---------|
| `user_profile` | ユーザープロフィール | 永続 |
| `calibration_state` | キャリブレーション状態 | 永続 |
| `advice_{date}` | 日次アドバイス | 7日 |
| `mood_logs` | 気分ログ | 30日 |
| `today_mode_logs` | 今日のモードログ | 30日 |
| `feedback_logs` | アドバイスフィードバック | 30日 |

---

## 10. エラーハンドリング

```swift
enum TempoError: Error {
    case healthKitNotAuthorized
    case healthKitInsufficientData
    case networkError(Error)
    case apiError(String)
}
```

| エラー | フォールバック |
|--------|---------------|
| ネットワークエラー | キャッシュ表示 → ローカル定型アドバイス |
| HealthKitデータ不足 | キャリブレーション期間として扱う |
| Claude APIエラー | 前日アドバイス + リトライ |

---

## 11. セキュリティ

| 原則 | 実装 |
|------|------|
| データ最小化 | HealthKitデータはデバイス内のみ |
| 暗号化 | HTTPS通信のみ |
| API保護 | API Key（MVP）→ OAuth（将来） |

---

## 12. コスト

| 項目 | コスト |
|------|--------|
| Claude API | ~$0.03/回 |
| 月間（1日1回） | ~$0.90/ユーザー |
| Open-Meteo | 無料 |

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 5.0 | 2025-01-01 | ドメインモデル中心の設計に全面改訂 |
| 6.0 | 2025-01-01 | Geminiフィードバック反映: オンボーディング改善、キャリブレーション期間、バックグラウンド処理、オフラインフォールバック |
