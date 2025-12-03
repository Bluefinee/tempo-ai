# 💻 Tempo AI - 開発仕様書（エンジニア向け）

**バージョン:** 2.0 - Cloudflare Workers Edition  
**最終更新:** 2024年12月4日  
**開発者:** Masakazu  
**構成:** Cloudflare Workers + Hono + Supabase

---

## 📋 目次

1. [システムアーキテクチャ](#システムアーキテクチャ)
2. [技術スタック](#技術スタック)
3. [開発環境](#開発環境)
4. [iOS App仕様](#ios-app仕様)
5. [Cloudflare Workers仕様](#cloudflare-workers仕様)
6. [データベース設計](#データベース設計)
7. [API設計](#api設計)
8. [AI統合](#ai統合)
9. [開発フェーズ詳細](#開発フェーズ詳細)
10. [セキュリティ](#セキュリティ)
11. [テスト戦略](#テスト戦略)
12. [デプロイメント](#デプロイメント)

---

## 🏗️ システムアーキテクチャ

### 全体構成図

```
┌──────────────────────────────────────────────────┐
│              iOS App (Swift + SwiftUI)            │
│                                                   │
│  ┌─────────────────┐  ┌─────────────────┐       │
│  │ HealthKit       │  │ Location        │       │
│  │ Manager         │  │ Manager         │       │
│  └─────────────────┘  └─────────────────┘       │
│           ↓                    ↓                  │
│  ┌──────────────────────────────────────┐        │
│  │         API Client (URLSession)       │        │
│  └──────────────────────────────────────┘        │
│           ↓                    ↓                  │
│  ┌─────────────────┐  ┌─────────────────┐       │
│  │ Local Storage   │  │ Notification    │       │
│  │ (UserDefaults)  │  │ Manager         │       │
│  └─────────────────┘  └─────────────────┘       │
└──────────────────────────────────────────────────┘
                       ↓
              HTTPS (TLS 1.3)
                       ↓
┌──────────────────────────────────────────────────┐
│   Cloudflare Workers (300+ Global Edge Locations) │
│              Hono Framework (14KB)                │
│                                                   │
│  ┌─────────────────┐  ┌─────────────────┐       │
│  │ /health/analyze │  │ /users/profile  │       │
│  │ Route Handler   │  │ Route Handler   │       │
│  └─────────────────┘  └─────────────────┘       │
│           ↓                    ↓                  │
│  ┌─────────────────┐  ┌─────────────────┐       │
│  │ Weather Service │  │ AI Service      │       │
│  │ (Open-Meteo)    │  │ (Claude)        │       │
│  └─────────────────┘  └─────────────────┘       │
└──────────────────────────────────────────────────┘
         ↓                    ↓
┌──────────────┐    ┌──────────────┐
│ Claude API   │    │  Supabase    │
│ (Anthropic)  │    │ via Hyperdrive│
└──────────────┘    └──────────────┘
         ↓
┌──────────────┐
│ Open-Meteo   │
│ Weather API  │
└──────────────┘
```

### データフロー

**朝のアドバイス生成フロー:**
```
1. ユーザーがアプリ起動または通知タップ
   ↓
2. iOS App: HealthKitからデータ取得
   - 睡眠データ（総時間、深い睡眠、REM）
   - HRVデータ
   - 心拍数データ
   - 活動データ（歩数、カロリー）
   ↓
3. iOS App: 位置情報取得（緯度・経度）
   ↓
4. iOS App → Cloudflare Workers
   POST /api/health/analyze
   Body: {
     userId: "uuid",
     healthData: {...},
     userProfile: {...},
     location: {lat, lon}
   }
   ↓
5. Cloudflare Workers (Hono): データ受信
   CPU time: ~2ms
   ↓
6. Workers → Open-Meteo API
   天気データ取得（fetch）
   Wall time: 1-2秒
   CPU time: <1ms（待機時間はカウントされない）
   ↓
7. Workers: プロンプト構築
   - HealthKitデータ解析
   - 天気データ統合
   - ユーザープロフィール考慮
   CPU time: ~3ms
   ↓
8. Workers → Claude API
   AIアドバイス生成（fetch）
   Wall time: 5-10秒
   CPU time: <5ms（待機時間はカウントされない）
   ↓
9. Workers: JSONパース
   CPU time: ~2ms
   ↓
10. Workers → Supabase (via Hyperdrive)
   アドバイス保存（fetch）
   Wall time: 100-500ms
   CPU time: <1ms
   ↓
11. Workers → iOS App: アドバイス返却
   CPU time: <1ms
   ↓
12. iOS App: アドバイス表示

合計:
- Wall time: 15-20秒（ユーザー体験）
- CPU time: <15ms（課金対象、無料プラン10msでもOK）
```

**重要：CPU time vs Wall time**

Cloudflare Workersは**CPU time**で課金されます：
- **CPU time**: JavaScriptコードを実際に実行している時間
- **Wall time**: 実際の経過時間（待機時間含む）

**fetch()などのAPI呼び出し待機時間はCPU timeにカウントされません！**

これが今回のユースケースで重要な理由：
```javascript
// ❌ これは遅い（Wall time: 10秒、CPU time: 10秒）
for (let i = 0; i < 10000000000; i++) {
  // CPU使用
}

// ✅ これは速い（Wall time: 10秒、CPU time: <5ms）
const response = await fetch('https://api.anthropic.com/...');
// fetch()の待機中、CPU timeはカウントされない！
```

今回のアプリでは、ほとんどの時間がAPI待機なので、無料プラン（10ms CPU time）でも十分動作します。

---

## 🛠️ 技術スタック

### iOS App

| カテゴリ | 技術 | バージョン |
|---------|------|-----------|
| 言語 | Swift | 5.9+ |
| フレームワーク | SwiftUI | iOS 16.0+ |
| ヘルスデータ | HealthKit | - |
| ネットワーク | URLSession | - |
| ローカルストレージ | UserDefaults | - |
| 通知 | UserNotifications | - |
| 位置情報 | CoreLocation | - |

**追加ライブラリ（Phase 3以降）:**
- **Charts**: グラフ表示（Apple純正）

---

### Cloudflare Workers API

| カテゴリ | 技術 | バージョン |
|---------|------|-----------|
| プラットフォーム | Cloudflare Workers | Latest |
| ランタイム | V8 JavaScript Engine | Latest |
| フレームワーク | Hono | 4.x |
| 言語 | TypeScript | 5.x |
| AI | Claude API | Sonnet 4.5 |
| 天気 | Open-Meteo API | - |
| DB接続 | Hyperdrive | - |
| デプロイツール | Wrangler | 3.x |

**主要な依存関係:**
```json
{
  "dependencies": {
    "hono": "^4.0.0",
    "@anthropic-ai/sdk": "^0.9.0",
    "@prisma/client": "^5.0.0",
    "@prisma/adapter-pg": "^5.0.0",
    "pg": "^8.16.3"
  },
  "devDependencies": {
    "wrangler": "^3.0.0",
    "@cloudflare/workers-types": "^4.0.0",
    "prisma": "^5.0.0"
  }
}
```

---

### Database

| カテゴリ | 技術 | バージョン |
|---------|------|-----------|
| データベース | PostgreSQL | 15+ |
| ホスティング | Supabase | - |
| 接続プーリング | Hyperdrive | - |
| ORM | Prisma | 5+ |

---

### Infrastructure & Services

| サービス | 用途 | 無料枠 |
|---------|------|-------|
| Cloudflare Workers | APIホスティング | 100,000 req/日 |
| Cloudflare Hyperdrive | DB接続最適化 | Workers Paidに含まれる |
| Supabase | PostgreSQLデータベース | 500MB, 無制限リクエスト |
| GitHub | バージョン管理 | 無料 |
| GitHub Actions | CI/CD（将来） | 2,000分/月 |

**Phase 1-2のコスト:**
- Cloudflare Workers: **無料**（100,000 req/日で十分）
- Supabase: **無料**（500MBで十分）
- Claude API: 従量課金（~$10-20/月）
- **合計: $10-20/月**

**Phase 3+ 有料プラン移行時:**
- Cloudflare Workers Paid: **$5/月**
- Supabase: **無料**
- Claude API: ~$10-20/月
- **合計: $15-25/月**

---

### なぜCloudflare Workers + Honoか？

#### 1. **コールドスタート: ~0ms**
従来のサーバーレス（AWS Lambda等）はコールドスタート100-500ms。
Cloudflare WorkersのV8 isolatesは**瞬時起動**。

#### 2. **グローバルエッジ配信**
世界300+箇所のエッジロケーションで実行。
東京からでもNYからでも高速。

#### 3. **CPU time課金 = コスト効率**
API待機時間は課金されない。
今回のユースケースでは無料枠で十分。

#### 4. **軽量 & モダン**
- Hono: 14KB（Express.jsの1/10以下）
- TypeScript標準サポート
- 2024年Production Ready

#### 5. **公式サポート**
- Anthropic（Claude）公式パートナー
- Supabase公式統合
- Stripe、PayPal、Asanaなど大手企業が採用

---

## 💻 開発環境

### 必要なツール

**iOS開発:**
- Xcode 15+
- macOS Sonoma 14+
- iPhone実機（HealthKitテスト用）
- Apple Watch（Phase 4+）

**Cloudflare Workers開発:**
- Node.js 18+
- npm または pnpm
- Wrangler CLI
- VS Code（推奨エディタ）
- Cloudflareアカウント

**その他:**
- Git
- GitHub アカウント
- Claude API キー（Anthropic）
- Supabase アカウント

---

### セットアップ手順

#### 1. Cloudflare Workers プロジェクト作成

```bash
# Wranglerをグローバルインストール
npm install -g wrangler

# Cloudflareにログイン
wrangler login

# プロジェクト作成
npm create cloudflare@latest tempo-ai-api

# セットアップウィザード
? What would you like to start with? 
  › "Hello World" Worker

? Which template would you like to use?
  › Hello World example

? Which language do you want to use?
  › TypeScript

? Do you want to use git for version control?
  › Yes

? Do you want to deploy your application?
  › No（後でデプロイ）

cd tempo-ai-api
```

#### 2. Honoをインストール

```bash
# Honoと必要な依存関係
npm install hono @anthropic-ai/sdk @prisma/client @prisma/adapter-pg pg

# 開発用依存関係
npm install -D @cloudflare/workers-types @types/pg prisma wrangler
```

#### 3. Prisma初期化

```bash
npx prisma init
```

#### 4. 環境変数設定

**ローカル開発用: `.dev.vars`**
```bash
# .dev.varsファイルを作成
cat > .dev.vars << EOF
ANTHROPIC_API_KEY=sk-ant-xxx
DATABASE_URL=postgresql://user:pass@host:5432/tempo_ai
EOF
```

**本番用: Wrangler Secrets**
```bash
# Claude APIキー
wrangler secret put ANTHROPIC_API_KEY

# 実行時にキーを入力
```

#### 5. Hyperdrive設定（Supabase接続）

```bash
# Hyperdriveコンフィグ作成
wrangler hyperdrive create tempo-ai-db \
  --connection-string="postgres://user:pass@db.supabase.co:5432/postgres"

# 出力されたIDをwrangler.tomlに追加
```

**wrangler.toml:**
```toml
name = "tempo-ai-api"
main = "src/index.ts"
compatibility_date = "2024-12-04"
compatibility_flags = ["nodejs_compat"]

[observability]
enabled = true

[[hyperdrive]]
binding = "HYPERDRIVE"
id = "YOUR_HYPERDRIVE_ID"  # 上記コマンドで取得したID
```

#### 6. 開発サーバー起動

```bash
# ローカル開発
npm run dev

# または
wrangler dev

# アクセス: http://localhost:8787
```

---

#### 7. iOS App セットアップ

```bash
# Xcodeでプロジェクトを開く
cd ../ios
open TempoAI.xcodeproj

# Info.plistを編集
# - API_BASE_URLを設定
#   開発: http://localhost:8787/api
#   本番: https://tempo-ai-api.YOUR_SUBDOMAIN.workers.dev/api
# - HealthKit権限を追加
```

---

### 開発ワークフロー

#### ローカル開発
```bash
# ターミナル1: Workers開発サーバー
cd tempo-ai-api
npm run dev

# ターミナル2: iOS シミュレーター/実機
# Xcodeから実行
```

#### デプロイ
```bash
# Workers デプロイ
cd tempo-ai-api
wrangler deploy

# iOS TestFlight
# Xcode Archive → Upload to App Store Connect
```

---

## 📱 iOS App仕様

### プロジェクト構造

```
TempoAI/
├── App/
│   ├── TempoAIApp.swift          # アプリエントリーポイント
│   └── ContentView.swift         # ルートビュー
│
├── Models/
│   ├── HealthData.swift          # HealthKitデータモデル
│   ├── WeatherData.swift         # 天気データモデル
│   ├── DailyAdvice.swift         # アドバイスモデル
│   ├── UserProfile.swift         # ユーザープロフィールモデル
│   └── APIModels.swift           # APIリクエスト/レスポンスモデル
│
├── Services/
│   ├── HealthKit/
│   │   ├── HealthKitManager.swift      # HealthKit管理
│   │   ├── SleepDataFetcher.swift      # 睡眠データ取得
│   │   ├── HRVDataFetcher.swift        # HRVデータ取得
│   │   ├── HeartRateDataFetcher.swift  # 心拍数取得
│   │   └── ActivityDataFetcher.swift   # 活動データ取得
│   │
│   ├── API/
│   │   ├── APIClient.swift             # APIクライアント
│   │   ├── APIEndpoints.swift          # エンドポイント定義
│   │   └── APIError.swift              # エラー定義
│   │
│   ├── Location/
│   │   └── LocationManager.swift       # 位置情報管理
│   │
│   ├── Notification/
│   │   └── NotificationManager.swift   # 通知管理
│   │
│   └── Storage/
│       ├── UserDefaultsManager.swift   # UserDefaults管理
│       └── ProfileStorage.swift        # プロフィール保存
│
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── WelcomeView.swift
│   │   ├── FeatureIntroView.swift
│   │   ├── PermissionRequestView.swift
│   │   └── ProfileSetupView.swift
│   │
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── ThemeCardView.swift
│   │   ├── AdviceCardView.swift
│   │   └── LoadingView.swift
│   │
│   ├── Detail/
│   │   ├── AdviceDetailView.swift
│   │   ├── MealAdviceView.swift
│   │   ├── ExerciseAdviceView.swift
│   │   └── HealthDataSummaryView.swift
│   │
│   ├── History/                  # Phase 3
│   │   ├── HistoryView.swift
│   │   └── HistoryItemView.swift
│   │
│   ├── Trends/                   # Phase 4
│   │   ├── TrendsView.swift
│   │   ├── SleepChartView.swift
│   │   ├── HRVChartView.swift
│   │   └── StepsChartView.swift
│   │
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   ├── BasicInfoEditView.swift
│   │   ├── GoalsEditView.swift
│   │   ├── DietEditView.swift
│   │   ├── ExerciseEditView.swift
│   │   └── HealthConditionsEditView.swift
│   │
│   └── Settings/
│       ├── SettingsView.swift
│       └── NotificationSettingsView.swift
│
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── HistoryViewModel.swift
│   ├── TrendsViewModel.swift
│   └── ProfileViewModel.swift
│
├── Utilities/
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   └── View+Extensions.swift
│   │
│   ├── Constants.swift
│   ├── Helpers.swift
│   └── Theme.swift              # カラー、フォント定義
│
└── Resources/
    ├── Assets.xcassets          # 画像、アイコン
    ├── Info.plist
    └── Localizable.strings      # 将来の多言語対応
```

---

### 主要データモデル

#### HealthData.swift
```swift
import Foundation

struct HealthData: Codable {
    let date: Date
    let sleep: SleepData?
    let hrv: Double?
    let restingHeartRate: Double?
    let respiratoryRate: Double?
    let steps: Int
    let activeCalories: Double
    let weight: Double?
    let bodyFatPercentage: Double?
    let vo2Max: Double?
    
    enum CodingKeys: String, CodingKey {
        case date, sleep, hrv
        case restingHeartRate = "resting_heart_rate"
        case respiratoryRate = "respiratory_rate"
        case steps
        case activeCalories = "active_calories"
        case weight
        case bodyFatPercentage = "body_fat_percentage"
        case vo2Max = "vo2_max"
    }
}

struct SleepData: Codable {
    let totalMinutes: Int
    let deepMinutes: Int
    let remMinutes: Int
    let lightMinutes: Int
    let sleepStart: Date?
    let sleepEnd: Date?
    
    var totalHours: Double {
        Double(totalMinutes) / 60.0
    }
    
    var sleepQuality: Int {
        calculateQuality()
    }
    
    private func calculateQuality() -> Int {
        let totalHours = Double(totalMinutes) / 60.0
        let deepRatio = Double(deepMinutes) / Double(totalMinutes)
        let remRatio = Double(remMinutes) / Double(totalMinutes)
        
        var score = 0
        
        // 総睡眠時間（7-9時間が理想）
        if totalHours >= 7 && totalHours <= 9 {
            score += 40
        } else if totalHours >= 6 && totalHours <= 10 {
            score += 30
        } else {
            score += 10
        }
        
        // 深い睡眠（15-25%が理想）
        if deepRatio >= 0.15 && deepRatio <= 0.25 {
            score += 30
        } else if deepRatio >= 0.10 && deepRatio <= 0.30 {
            score += 20
        } else {
            score += 10
        }
        
        // REM睡眠（20-25%が理想）
        if remRatio >= 0.20 && remRatio <= 0.25 {
            score += 30
        } else if remRatio >= 0.15 && remRatio <= 0.30 {
            score += 20
        } else {
            score += 10
        }
        
        return min(score, 100)
    }
    
    enum CodingKeys: String, CodingKey {
        case totalMinutes = "total_minutes"
        case deepMinutes = "deep_minutes"
        case remMinutes = "rem_minutes"
        case lightMinutes = "light_minutes"
        case sleepStart = "sleep_start"
        case sleepEnd = "sleep_end"
    }
}
```

#### WeatherData.swift
```swift
import Foundation

struct WeatherData: Codable {
    let temperature: Double
    let temperatureMin: Double
    let temperatureMax: Double
    let humidity: Int
    let pressure: Double
    let uvIndex: Int
    let precipitationProbability: Int
    let weatherDescription: String
    let windSpeed: Double?
    
    enum CodingKeys: String, CodingKey {
        case temperature
        case temperatureMin = "temperature_min"
        case temperatureMax = "temperature_max"
        case humidity
        case pressure
        case uvIndex = "uv_index"
        case precipitationProbability = "precipitation_probability"
        case weatherDescription = "weather_description"
        case windSpeed = "wind_speed"
    }
}
```

#### DailyAdvice.swift
```swift
import Foundation

struct DailyAdvice: Codable, Identifiable {
    let id: UUID
    let date: Date
    let userId: String
    let theme: String
    let breakfast: MealAdvice
    let lunch: MealAdvice
    let dinner: MealAdvice
    let exercise: ExerciseAdvice
    let breathing: BreathingAdvice
    let hydration: HydrationAdvice
    let evening: String
    let weatherAdvice: String
    
    enum CodingKeys: String, CodingKey {
        case id, date
        case userId = "user_id"
        case theme, breakfast, lunch, dinner
        case exercise, breathing, hydration, evening
        case weatherAdvice = "weather_advice"
    }
}

struct MealAdvice: Codable {
    let recommendation: String
    let reason: String
    let examples: [String]?
}

struct ExerciseAdvice: Codable {
    let type: String
    let duration: String
    let intensity: String
    let reason: String
    let avoid: [String]?
}

struct BreathingAdvice: Codable {
    let technique: String
    let instructions: [String]
    let timing: String
}

struct HydrationAdvice: Codable {
    let amount: String
    let reason: String
    let schedule: [HydrationScheduleItem]?
}

struct HydrationScheduleItem: Codable {
    let time: String
    let amount: String
}
```

#### UserProfile.swift
```swift
import Foundation

struct UserProfile: Codable {
    var userId: UUID
    var age: Int
    var gender: String
    var height: Double  // cm
    var weight: Double  // kg
    var goals: [String]
    var dietaryPreferences: [String]
    var dietaryRestrictions: [String]
    var exerciseHabits: [String]
    var exerciseFrequency: String
    var exerciseMinutesPerSession: Int
    var healthConditions: [String]
    var supplements: [String]
    var medications: [String]?
    var sleepConcerns: [String]
    var notificationTime: Date
    var notificationDays: [Int]  // 0=Sunday, 1=Monday, ...
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case age, gender, height, weight, goals
        case dietaryPreferences = "dietary_preferences"
        case dietaryRestrictions = "dietary_restrictions"
        case exerciseHabits = "exercise_habits"
        case exerciseFrequency = "exercise_frequency"
        case exerciseMinutesPerSession = "exercise_minutes_per_session"
        case healthConditions = "health_conditions"
        case supplements, medications
        case sleepConcerns = "sleep_concerns"
        case notificationTime = "notification_time"
        case notificationDays = "notification_days"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

---

### HealthKitManager実装詳細

#### HealthKitManager.swift
```swift
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    @Published var lastError: HealthKitError?
    
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!,
        HKObjectType.quantityType(forIdentifier: .vo2Max)!,
        HKObjectType.workoutType(),
    ]
    
    private init() {}
    
    /// HealthKit利用可能性チェック
    func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    /// 権限リクエスト
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        do {
            try await healthStore.requestAuthorization(
                toShare: [],
                read: readTypes
            )
            
            await MainActor.run {
                self.isAuthorized = true
            }
        } catch {
            await MainActor.run {
                self.lastError = .authorizationFailed
            }
            throw HealthKitError.authorizationFailed
        }
    }
    
    /// 昨晩のデータを取得
    func fetchLastNightData() async throws -> HealthData {
        let calendar = Calendar.current
        let now = Date()
        
        // 昨日18:00から今日6:00まで
        guard let endDate = calendar.date(
            bySettingHour: 6,
            minute: 0,
            second: 0,
            of: now
        ) else {
            throw HealthKitError.invalidData
        }
        
        guard let startDate = calendar.date(
            byAdding: .hour,
            value: -12,
            to: endDate
        ) else {
            throw HealthKitError.invalidData
        }
        
        // 並行処理でデータ取得
        async let sleep = SleepDataFetcher.fetch(
            healthStore: healthStore,
            from: startDate,
            to: endDate
        )
        async let hrv = HRVDataFetcher.fetch(
            healthStore: healthStore,
            from: startDate,
            to: endDate
        )
        async let restingHR = HeartRateDataFetcher.fetchResting(
            healthStore: healthStore,
            from: startDate,
            to: endDate
        )
        async let respiratoryRate = RespiratoryDataFetcher.fetch(
            healthStore: healthStore,
            from: startDate,
            to: endDate
        )
        async let steps = ActivityDataFetcher.fetchSteps(
            healthStore: healthStore,
            from: startDate,
            to: endDate
        )
        async let calories = ActivityDataFetcher.fetchActiveCalories(
            healthStore: healthStore,
            from: startDate,
            to: endDate
        )
        async let weight = BodyDataFetcher.fetchLatestWeight(
            healthStore: healthStore
        )
        async let bodyFat = BodyDataFetcher.fetchLatestBodyFat(
            healthStore: healthStore
        )
        async let vo2Max = BodyDataFetcher.fetchLatestVO2Max(
            healthStore: healthStore
        )
        
        return try await HealthData(
            date: startDate,
            sleep: sleep,
            hrv: hrv,
            restingHeartRate: restingHR,
            respiratoryRate: respiratoryRate,
            steps: steps,
            activeCalories: calories,
            weight: weight,
            bodyFatPercentage: bodyFat,
            vo2Max: vo2Max
        )
    }
}

enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case authorizationFailed
    case noData
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKitはこのデバイスで利用できません"
        case .authorizationFailed:
            return "HealthKitの権限取得に失敗しました"
        case .noData:
            return "データが見つかりません"
        case .invalidData:
            return "データが無効です"
        }
    }
}
```

#### SleepDataFetcher.swift
```swift
import HealthKit

struct SleepDataFetcher {
    static func fetch(
        healthStore: HKHealthStore,
        from startDate: Date,
        to endDate: Date
    ) async throws -> SleepData? {
        let sleepType = HKObjectType.categoryType(
            forIdentifier: .sleepAnalysis
        )!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [
                    NSSortDescriptor(
                        key: HKSampleSortIdentifierStartDate,
                        ascending: true
                    )
                ]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                if samples.isEmpty {
                    continuation.resume(returning: nil)
                    return
                }
                
                let sleepData = processSleepSamples(samples)
                continuation.resume(returning: sleepData)
            }
            
            healthStore.execute(query)
        }
    }
    
    private static func processSleepSamples(
        _ samples: [HKCategorySample]
    ) -> SleepData {
        var totalSleep: TimeInterval = 0
        var deepSleep: TimeInterval = 0
        var remSleep: TimeInterval = 0
        var lightSleep: TimeInterval = 0
        
        var earliestStart: Date?
        var latestEnd: Date?
        
        for sample in samples {
            let duration = sample.endDate.timeIntervalSince(
                sample.startDate
            )
            
            // 最早入眠時刻と最遅起床時刻を記録
            if earliestStart == nil || sample.startDate < earliestStart! {
                earliestStart = sample.startDate
            }
            if latestEnd == nil || sample.endDate > latestEnd! {
                latestEnd = sample.endDate
            }
            
            switch sample.value {
            case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                lightSleep += duration
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                deepSleep += duration
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                remSleep += duration
            default:
                break
            }
        }
        
        totalSleep = deepSleep + remSleep + lightSleep
        
        return SleepData(
            totalMinutes: Int(totalSleep / 60),
            deepMinutes: Int(deepSleep / 60),
            remMinutes: Int(remSleep / 60),
            lightMinutes: Int(lightSleep / 60),
            sleepStart: earliestStart,
            sleepEnd: latestEnd
        )
    }
}
```

#### HRVDataFetcher.swift
```swift
import HealthKit

struct HRVDataFetcher {
    static func fetch(
        healthStore: HKHealthStore,
        from startDate: Date,
        to endDate: Date
    ) async throws -> Double? {
        let hrvType = HKQuantityType.quantityType(
            forIdentifier: .heartRateVariabilitySDNN
        )!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: hrvType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result,
                      let average = result.averageQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let hrv = average.doubleValue(
                    for: HKUnit.secondUnit(with: .milli)
                )
                continuation.resume(returning: hrv)
            }
            
            healthStore.execute(query)
        }
    }
}
```

---

### APIClient実装

#### APIClient.swift
```swift
import Foundation
import CoreLocation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private init() {
        // 環境に応じてbaseURLを切り替え
        #if DEBUG
        self.baseURL = "http://localhost:3000/api"
        #else
        self.baseURL = "https://tempo-ai-api.railway.app/api"
        #endif
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    /// ヘルスデータを分析してアドバイスを取得
    func analyzeHealth(
        healthData: HealthData,
        userProfile: UserProfile,
        location: CLLocationCoordinate2D
    ) async throws -> DailyAdvice {
        let endpoint = "\(baseURL)/health/analyze"
        
        let request = AnalyzeRequest(
            userId: userProfile.userId.uuidString,
            healthData: healthData,
            userProfile: userProfile,
            location: LocationData(
                latitude: location.latitude,
                longitude: location.longitude
            )
        )
        
        var urlRequest = URLRequest(url: URL(string: endpoint)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? decoder.decode(
                ErrorResponse.self,
                from: data
            ) {
                throw APIError.serverError(errorResponse.message)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        return try decoder.decode(DailyAdvice.self, from: data)
    }
    
    /// アドバイス履歴を取得（Phase 3）
    func fetchHistory(userId: String) async throws -> [DailyAdvice] {
        let endpoint = "\(baseURL)/advice/history/\(userId)"
        
        let urlRequest = URLRequest(url: URL(string: endpoint)!)
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        return try decoder.decode([DailyAdvice].self, from: data)
    }
    
    /// ユーザープロフィールを保存
    func saveProfile(_ profile: UserProfile) async throws {
        let endpoint = "\(baseURL)/users/profile"
        
        var urlRequest = URLRequest(url: URL(string: endpoint)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        urlRequest.httpBody = try encoder.encode(profile)
        
        let (_, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.saveFailed
        }
    }
}

// MARK: - Request/Response Models

struct AnalyzeRequest: Codable {
    let userId: String
    let healthData: HealthData
    let userProfile: UserProfile
    let location: LocationData
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case healthData = "health_data"
        case userProfile = "user_profile"
        case location
    }
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
}

struct ErrorResponse: Codable {
    let message: String
    let statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case statusCode = "status_code"
    }
}

// MARK: - API Error

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case decodingError
    case saveFailed
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "サーバーからの応答が無効です"
        case .httpError(let code):
            return "HTTPエラー: \(code)"
        case .serverError(let message):
            return "サーバーエラー: \(message)"
        case .decodingError:
            return "データの解析に失敗しました"
        case .saveFailed:
            return "保存に失敗しました"
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        }
    }
}
```

**注意:** APIClient内のbaseURLは開発時にCloudflare Workers用に更新：
```swift
#if DEBUG
self.baseURL = "http://localhost:8787/api"  // Wrangler dev
#else
self.baseURL = "https://tempo-ai-api.YOUR_SUBDOMAIN.workers.dev/api"
#endif
```

---

### HomeViewModel実装

```swift
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var dailyAdvice: DailyAdvice?
    @Published var isLoading = false
    @Published var error: String?
    @Published var showError = false
    
    private let healthKitManager = HealthKitManager.shared
    private let locationManager = LocationManager.shared
    private let apiClient = APIClient.shared
    private let profileStorage = ProfileStorage.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $error
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.showError = true
            }
            .store(in: &cancellables)
    }
    
    /// アドバイス生成
    func generateAdvice() async {
        isLoading = true
        error = nil
        
        do {
            // 1. HealthKitデータ取得
            guard let healthData = try await healthKitManager.fetchLastNightData() else {
                throw AppError.noHealthData
            }
            
            // 2. 位置情報取得
            guard let location = try await locationManager.getCurrentLocation() else {
                throw AppError.locationFailed
            }
            
            // 3. ユーザープロフィール取得
            guard let profile = profileStorage.loadProfile() else {
                throw AppError.profileNotFound
            }
            
            // 4. API呼び出し
            let advice = try await apiClient.analyzeHealth(
                healthData: healthData,
                userProfile: profile,
                location: location
            )
            
            // 5. 結果を保存
            dailyAdvice = advice
            
            // 6. ローカルに保存（キャッシュ）
            saveAdviceToCache(advice)
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// キャッシュからアドバイスをロード
    func loadCachedAdvice() {
        if let cached = loadAdviceFromCache(),
           Calendar.current.isDateInToday(cached.date) {
            dailyAdvice = cached
        }
    }
    
    private func handleError(_ error: Error) {
        if let appError = error as? AppError {
            self.error = appError.localizedDescription
        } else if let apiError = error as? APIError {
            self.error = apiError.localizedDescription
        } else if let healthKitError = error as? HealthKitError {
            self.error = healthKitError.localizedDescription
        } else {
            self.error = "予期しないエラーが発生しました"
        }
    }
    
    private func saveAdviceToCache(_ advice: DailyAdvice) {
        if let encoded = try? JSONEncoder().encode(advice) {
            UserDefaults.standard.set(encoded, forKey: "cachedAdvice")
            UserDefaults.standard.set(Date(), forKey: "cachedAdviceDate")
        }
    }
    
    private func loadAdviceFromCache() -> DailyAdvice? {
        guard let data = UserDefaults.standard.data(forKey: "cachedAdvice"),
              let advice = try? JSONDecoder().decode(DailyAdvice.self, from: data) else {
            return nil
        }
        return advice
    }
}

enum AppError: Error, LocalizedError {
    case noHealthData
    case locationFailed
    case profileNotFound
    
    var errorDescription: String? {
        switch self {
        case .noHealthData:
            return "ヘルスケアデータを取得できませんでした"
        case .locationFailed:
            return "位置情報を取得できませんでした"
        case .profileNotFound:
            return "プロフィールが設定されていません"
        }
    }
}
```

---

## 💾 データベース設計

### Prismaスキーマ

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
  previewFeatures = ["driverAdapters"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id                  String   @id @default(uuid())
  createdAt           DateTime @default(now()) @map("created_at")
  updatedAt           DateTime @updatedAt @map("updated_at")
  
  // Profile
  age                 Int
  gender              String
  height              Float
  weight              Float
  goals               String[]
  dietaryPreferences  String[] @map("dietary_preferences")
  dietaryRestrictions String[] @map("dietary_restrictions")
  exerciseHabits      String[] @map("exercise_habits")
  exerciseFrequency   String   @map("exercise_frequency")
  exerciseMinutesPerSession Int @map("exercise_minutes_per_session")
  healthConditions    String[] @map("health_conditions")
  supplements         String[]
  medications         String[]
  sleepConcerns       String[] @map("sleep_concerns")
  
  // Notification
  notificationTime    DateTime @map("notification_time")
  notificationDays    Int[]    @map("notification_days")
  
  // Relations
  adviceHistory       Advice[]
  
  @@map("users")
}

model Advice {
  id                 String   @id @default(uuid())
  createdAt          DateTime @default(now()) @map("created_at")
  date               DateTime
  
  // Foreign key
  userId             String   @map("user_id")
  user               User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  // Content
  theme              String
  breakfast          Json
  lunch              Json
  dinner             Json
  exercise           Json
  breathing          Json
  hydration          Json
  evening            String
  weatherAdvice      String   @map("weather_advice")
  
  // Metadata
  healthData         Json     @map("health_data")
  weatherData        Json     @map("weather_data")
  
  @@index([userId, date])
  @@map("advice")
}
```

### マイグレーション

```bash
# Prismaマイグレーション作成
npx prisma migrate dev --name init

# Prismaクライアント生成
npx prisma generate
```

---

## 🔌 API設計

### エンドポイント一覧

#### Phase 1: MVP

| メソッド | エンドポイント | 説明 |
|---------|---------------|------|
| POST | `/api/health/analyze` | HealthKitデータ分析してアドバイス生成 |
| POST | `/api/users/profile` | ユーザープロフィール保存 |
| GET | `/api/users/profile/:userId` | ユーザープロフィール取得 |

#### Phase 3: 履歴機能

| メソッド | エンドポイント | 説明 |
|---------|---------------|------|
| GET | `/api/advice/history/:userId` | アドバイス履歴取得（7日間） |
| DELETE | `/api/advice/:adviceId` | 特定のアドバイス削除 |

---

## 🧪 テスト戦略

### ユニットテスト

**iOS (XCTest):**
```swift
func testFetchLastNightData() async throws {
    let manager = HealthKitManager.shared
    let data = try await manager.fetchLastNightData()
    
    XCTAssertNotNil(data)
    XCTAssertNotNil(data.sleep)
}
```

**Cloudflare Workers (Vitest):**
```typescript
// test/health.test.ts
import { describe, it, expect } from 'vitest';
import app from '../src/index';

describe('Health API', () => {
  it('should generate advice', async () => {
    const res = await app.request('/api/health/analyze', {
      method: 'POST',
      body: JSON.stringify(mockHealthData),
    });
    
    expect(res.status).toBe(200);
    const data = await res.json();
    expect(data.theme).toBeDefined();
  });
});
```

### E2Eテスト

**シナリオ:**
1. アプリ起動
2. HealthKitデータ取得
3. Workers API呼び出し
4. アドバイス表示
5. 詳細画面遷移

### パフォーマンステスト

**指標:**
- Workers CPU time: <10ms（目標）
- API レスポンス時間: <15秒
- アプリ起動時間: <3秒

---
        case .decodingError:
            return "データの解析に失敗しました"
        case .saveFailed:
            return "保存に失敗しました"
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        }
    }
}
```

---

### HomeViewModel実装

```swift
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var dailyAdvice: DailyAdvice?
    @Published var isLoading = false
    @Published var error: String?
    @Published var showError = false
    
    private let healthKitManager = HealthKitManager.shared
    private let locationManager = LocationManager.shared
    private let apiClient = APIClient.shared
    private let profileStorage = ProfileStorage.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // エラー監視
        $error
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.showError = true
            }
            .store(in: &cancellables)
    }
    
    /// アドバイス生成
    func generateAdvice() async {
        isLoading = true
        error = nil
        
        do {
            // 1. HealthKitデータ取得
            guard let healthData = try await healthKitManager.fetchLastNightData() else {
                throw AppError.noHealthData
            }
            
            // 2. 位置情報取得
            guard let location = try await locationManager.getCurrentLocation() else {
                throw AppError.locationFailed
            }
            
            // 3. ユーザープロフィール取得
            guard let profile = profileStorage.loadProfile() else {
                throw AppError.profileNotFound
            }
            
            // 4. API呼び出し
            let advice = try await apiClient.analyzeHealth(
                healthData: healthData,
                userProfile: profile,
                location: location
            )
            
            // 5. 結果を保存
            dailyAdvice = advice
            
            // 6. ローカルに保存（キャッシュ）
            saveAdviceToCache(advice)
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// キャッシュからアドバイスをロード
    func loadCachedAdvice() {
        if let cached = loadAdviceFromCache(),
           Calendar.current.isDateInToday(cached.date) {
            dailyAdvice = cached
        }
    }
    
    private func handleError(_ error: Error) {
        if let appError = error as? AppError {
            self.error = appError.localizedDescription
        } else if let apiError = error as? APIError {
            self.error = apiError.localizedDescription
        } else if let healthKitError = error as? HealthKitError {
            self.error = healthKitError.localizedDescription
        } else {
            self.error = "予期しないエラーが発生しました: \(error.localizedDescription)"
        }
    }
    
    private func saveAdviceToCache(_ advice: DailyAdvice) {
        if let encoded = try? JSONEncoder().encode(advice) {
            UserDefaults.standard.set(encoded, forKey: "cachedAdvice")
            UserDefaults.standard.set(Date(), forKey: "cachedAdviceDate")
        }
    }
    
    private func loadAdviceFromCache() -> DailyAdvice? {
        guard let data = UserDefaults.standard.data(forKey: "cachedAdvice"),
              let advice = try? JSONDecoder().decode(DailyAdvice.self, from: data) else {
            return nil
        }
        return advice
    }
}

enum AppError: Error, LocalizedError {
    case noHealthData
    case locationFailed
    case profileNotFound
    
    var errorDescription: String? {
        switch self {
        case .noHealthData:
            return "ヘルスケアデータを取得できませんでした"
        case .locationFailed:
            return "位置情報を取得できませんでした"
        case .profileNotFound:
            return "プロフィールが設定されていません"
        }
    }
}
```

---

## ⚡ Cloudflare Workers仕様

### プロジェクト構造（軽量版）

```
tempo-ai-api/
├── src/
│   ├── index.ts                  # メインエントリー（Honoアプリ）
│   │
│   ├── routes/
│   │   ├── health.ts             # POST /api/health/analyze
│   │   ├── users.ts              # POST /api/users/profile
│   │   └── advice.ts             # GET /api/advice/history/:userId (Phase 3)
│   │
│   ├── services/
│   │   ├── claude.service.ts     # Claude API統合
│   │   ├── weather.service.ts    # Open-Meteo API
│   │   ├── prompt.builder.ts     # プロンプト構築
│   │   └── db.service.ts         # Supabase/Prisma
│   │
│   ├── types/
│   │   ├── health-data.ts        # HealthKitデータ型
│   │   ├── advice.ts             # アドバイス型
│   │   └── user-profile.ts       # ユーザープロフィール型
│   │
│   └── utils/
│       ├── errors.ts             # エラーハンドリング
│       └── validators.ts         # バリデーション
│
├── prisma/
│   ├── schema.prisma             # DBスキーマ
│   └── migrations/               # マイグレーション
│
├── test/                         # テスト（Phase 2+）
│
├── wrangler.toml                 # Workers設定
├── .dev.vars                     # ローカル環境変数
├── package.json
├── tsconfig.json
└── README.md
```

**Phase 1のファイル数: 約8ファイル**
- `index.ts` - エントリー
- `routes/health.ts` - メインAPI
- `services/claude.service.ts` - AI
- `services/weather.service.ts` - 天気
- `services/prompt.builder.ts` - プロンプト
- `types/health-data.ts` - 型定義
- `wrangler.toml` - 設定
- `prisma/schema.prisma` - DB

---

### 主要コンポーネント実装

#### src/index.ts（メインエントリー）

```typescript
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import healthRoutes from './routes/health';
import userRoutes from './routes/users';

// Cloudflare Workers の型定義
type Bindings = {
  ANTHROPIC_API_KEY: string;
  HYPERDRIVE: Hyperdrive;
};

const app = new Hono<{ Bindings: Bindings }>();

// ミドルウェア
app.use('*', logger());
app.use('*', cors({
  origin: '*', // Phase 2で適切に設定
  credentials: true,
}));

// ルート
app.route('/api/health', healthRoutes);
app.route('/api/users', userRoutes);

// ヘルスチェック
app.get('/', (c) => c.json({ 
  status: 'ok', 
  service: 'Tempo AI API',
  version: '1.0.0' 
}));

// エラーハンドリング
app.onError((err, c) => {
  console.error('Error:', err);
  return c.json({
    error: err.message || 'Internal Server Error',
    status: 500,
  }, 500);
});

export default app;
```

---

#### src/routes/health.ts（メインAPIロジック）

```typescript
import { Hono } from 'hono';
import { ClaudeService } from '../services/claude.service';
import { WeatherService } from '../services/weather.service';
import { PromptBuilder } from '../services/prompt.builder';
import type { AnalyzeHealthRequest, DailyAdvice } from '../types';

type Bindings = {
  ANTHROPIC_API_KEY: string;
  HYPERDRIVE: Hyperdrive;
};

const health = new Hono<{ Bindings: Bindings }>();

health.post('/analyze', async (c) => {
  try {
    // 1. リクエストボディ取得
    const body: AnalyzeHealthRequest = await c.req.json();
    
    // 2. バリデーション（簡易版）
    if (!body.healthData || !body.location || !body.userProfile) {
      return c.json({ error: 'Missing required fields' }, 400);
    }
    
    // 3. 天気データ取得
    const weatherService = new WeatherService();
    const weather = await weatherService.getWeather(
      body.location.latitude,
      body.location.longitude
    );
    
    // 4. プロンプト構築
    const promptBuilder = new PromptBuilder();
    const prompt = promptBuilder.build({
      healthData: body.healthData,
      weather,
      userProfile: body.userProfile,
    });
    
    // 5. Claude API呼び出し
    const claudeService = new ClaudeService(c.env.ANTHROPIC_API_KEY);
    const aiResponse = await claudeService.generateAdvice(prompt);
    
    // 6. レスポンス整形
    const advice: DailyAdvice = {
      id: crypto.randomUUID(),
      date: new Date().toISOString(),
      userId: body.userId,
      theme: aiResponse.theme,
      breakfast: aiResponse.breakfast,
      lunch: aiResponse.lunch,
      dinner: aiResponse.dinner,
      exercise: aiResponse.exercise,
      breathing: aiResponse.breathing,
      hydration: aiResponse.hydration,
      evening: aiResponse.evening,
      weatherAdvice: aiResponse.weatherAdvice,
    };
    
    // 7. データベース保存（Phase 2で実装）
    // await dbService.saveAdvice(advice);
    
    return c.json(advice);
    
  } catch (error) {
    console.error('Analyze error:', error);
    return c.json({
      error: error.message || 'Failed to generate advice',
      status: 500,
    }, 500);
  }
});

export default health;
```

---

#### src/services/claude.service.ts

```typescript
import Anthropic from '@anthropic-ai/sdk';

export class ClaudeService {
  private client: Anthropic;
  
  constructor(apiKey: string) {
    this.client = new Anthropic({ apiKey });
  }
  
  async generateAdvice(prompt: string) {
    const response = await this.client.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 3000,
      temperature: 0.7,
      system: this.getSystemPrompt(),
      messages: [
        {
          role: 'user',
          content: prompt,
        },
      ],
    });
    
    // レスポンステキスト抽出
    const text = response.content[0].type === 'text' 
      ? response.content[0].text 
      : '';
    
    // JSONパース（```json ``` を除去）
    const jsonText = text
      .replace(/```json\s*/g, '')
      .replace(/```\s*/g, '')
      .trim();
    
    try {
      return JSON.parse(jsonText);
    } catch (error) {
      console.error('JSON parse error:', error);
      console.error('Response text:', text);
      throw new Error('Failed to parse AI response');
    }
  }
  
  private getSystemPrompt(): string {
    return `あなたは精密栄養学、運動生理学、睡眠科学の専門家です。
ユーザーの生体データ、天気、個人特性を総合的に分析し、
その日に最適化された健康アドバイスを生成してください。

重要な原則:
1. 科学的根拠に基づいたアドバイス
2. 具体的で実行可能な提案
3. ユーザーの個人特性を考慮
4. 天気や環境要因も反映
5. ポジティブで励ます口調

回答は必ず以下のJSON形式で返してください：
{
  "theme": "今日のテーマ（例：血糖安定の日）",
  "breakfast": {
    "recommendation": "推奨メニュー",
    "reason": "理由",
    "examples": ["具体例1", "具体例2"]
  },
  "lunch": {
    "recommendation": "推奨",
    "reason": "理由",
    "examples": ["具体例"]
  },
  "dinner": {
    "recommendation": "推奨",
    "reason": "理由",
    "examples": ["具体例"]
  },
  "exercise": {
    "type": "運動の種類",
    "duration": "時間",
    "intensity": "強度",
    "reason": "理由",
    "avoid": ["避けるべき運動"]
  },
  "breathing": {
    "technique": "呼吸法の名前",
    "instructions": ["手順1", "手順2"],
    "timing": "実施タイミング"
  },
  "hydration": {
    "amount": "目標水分量",
    "reason": "理由",
    "schedule": [
      {"time": "時間帯", "amount": "量"}
    ]
  },
  "evening": "夜の過ごし方",
  "weatherAdvice": "天気に基づくアドバイス"
}`;
  }
}
```

---

#### src/services/weather.service.ts

```typescript
export interface WeatherData {
  temperature: number;
  temperatureMin: number;
  temperatureMax: number;
  humidity: number;
  pressure: number;
  uvIndex: number;
  precipitationProbability: number;
  weatherDescription: string;
  windSpeed?: number;
}

export class WeatherService {
  private readonly baseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  async getWeather(latitude: number, longitude: number): Promise<WeatherData> {
    const params = new URLSearchParams({
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      current: 'temperature_2m,relative_humidity_2m,pressure_msl,uv_index',
      daily: 'temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code',
      timezone: 'Asia/Tokyo',
    });
    
    const response = await fetch(`${this.baseUrl}?${params}`);
    
    if (!response.ok) {
      throw new Error('Failed to fetch weather data');
    }
    
    const data = await response.json();
    
    return {
      temperature: data.current.temperature_2m,
      temperatureMin: data.daily.temperature_2m_min[0],
      temperatureMax: data.daily.temperature_2m_max[0],
      humidity: data.current.relative_humidity_2m,
      pressure: data.current.pressure_msl,
      uvIndex: data.current.uv_index,
      precipitationProbability: data.daily.precipitation_probability_max[0],
      weatherDescription: this.getWeatherDescription(
        data.daily.weather_code[0]
      ),
      windSpeed: data.current.wind_speed_10m,
    };
  }
  
  private getWeatherDescription(code: number): string {
    // WMO Weather interpretation codes
    if (code === 0) return '快晴';
    if (code === 1) return '晴れ';
    if (code === 2) return '一部曇り';
    if (code === 3) return '曇り';
    if (code >= 45 && code <= 48) return '霧';
    if (code >= 51 && code <= 55) return '霧雨';
    if (code >= 61 && code <= 65) return '雨';
    if (code >= 71 && code <= 77) return '雪';
    if (code >= 80 && code <= 82) return 'にわか雨';
    if (code >= 95 && code <= 99) return '雷雨';
    return '不明';
  }
}
```

---

#### src/services/prompt.builder.ts

```typescript
export interface PromptData {
  healthData: any;
  weather: any;
  userProfile: any;
}

export class PromptBuilder {
  build(data: PromptData): string {
    const { healthData, weather, userProfile } = data;
    
    return `
# ユーザープロフィール
- 年齢: ${userProfile.age}歳
- 性別: ${userProfile.gender}
- 身長: ${userProfile.height}cm
- 体重: ${userProfile.weight}kg
- 目標: ${userProfile.goals.join('、')}
- 運動習慣: ${userProfile.exerciseHabits.join('、')}
- 運動頻度: ${userProfile.exerciseFrequency}
- 食事の好み: ${userProfile.dietaryPreferences.join('、')}
- 食事制限: ${userProfile.dietaryRestrictions.length > 0 
    ? userProfile.dietaryRestrictions.join('、') 
    : 'なし'}

# 今日の生体データ分析
${this.buildHealthDataSection(healthData)}

# 今日の天気・環境
- 天気: ${weather.weatherDescription}
- 気温: ${weather.temperatureMax}°C / ${weather.temperatureMin}°C
- 湿度: ${weather.humidity}%
- 気圧: ${weather.pressure}hPa
- UV指数: ${weather.uvIndex}
- 降水確率: ${weather.precipitationProbability}%

上記を総合的に分析し、今日の最適な健康プランを生成してください。
必ずJSON形式で回答してください。
    `.trim();
  }
  
  private buildHealthDataSection(healthData: any): string {
    const sections: string[] = [];
    
    // 睡眠データ
    if (healthData.sleep) {
      const sleep = healthData.sleep;
      sections.push(`
## 睡眠
- 総睡眠時間: ${(sleep.totalMinutes / 60).toFixed(1)}時間
- 深い睡眠: ${sleep.deepMinutes}分 (${((sleep.deepMinutes / sleep.totalMinutes) * 100).toFixed(0)}%)
- REM睡眠: ${sleep.remMinutes}分 (${((sleep.remMinutes / sleep.totalMinutes) * 100).toFixed(0)}%)
      `.trim());
    }
    
    // HRV
    if (healthData.hrv) {
      sections.push(`
## 心拍変動（HRV）
- HRV: ${healthData.hrv.toFixed(1)}ms
      `.trim());
    }
    
    // 活動データ
    sections.push(`
## 活動
- 歩数: ${healthData.steps}歩
- 消費カロリー: ${healthData.activeCalories.toFixed(0)}kcal
    `.trim());
    
    return sections.join('\n\n');
  }
}
```

---

### wrangler.toml（設定ファイル）

```toml
name = "tempo-ai-api"
main = "src/index.ts"
compatibility_date = "2024-12-04"
compatibility_flags = ["nodejs_compat"]

# CPU制限（デフォルト: 30秒、最大: 300秒）
[limits]
cpu_ms = 30000  # Phase 1は30秒で十分

# 監視（Phase 2+）
[observability]
enabled = true

# Hyperdrive（Supabase接続）
[[hyperdrive]]
binding = "HYPERDRIVE"
id = "YOUR_HYPERDRIVE_ID"  # wrangler hyperdrive createで取得

# 環境変数（本番用はwrangler secret putで設定）
# [vars]
# 追加の環境変数があればここに
```

### プロジェクト構造

```
backend/
├── src/
│   ├── main.ts                    # アプリエントリーポイント
│   ├── app.module.ts              # ルートモジュール
│   │
│   ├── health/
│   │   ├── health.module.ts
│   │   ├── health.controller.ts
│   │   ├── health.service.ts
│   │   └── dto/
│   │       ├── analyze.dto.ts
│   │       └── health-data.dto.ts
│   │
│   ├── ai/
│   │   ├── ai.module.ts
│   │   ├── claude.service.ts
│   │   ├── prompt.builder.ts
│   │   └── dto/
│   │       └── advice.dto.ts
│   │
│   ├── weather/
│   │   ├── weather.module.ts
│   │   ├── weather.service.ts
│   │   ├── open-meteo.client.ts
│   │   └── dto/
│   │       └── weather-data.dto.ts
│   │
│   ├── users/
│   │   ├── users.module.ts
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   └── dto/
│   │       └── user-profile.dto.ts
│   │
│   ├── advice/                    # Phase 3
│   │   ├── advice.module.ts
│   │   ├── advice.controller.ts
│   │   ├── advice.service.ts
│   │   └── dto/
│   │       └── save-advice.dto.ts
│   │
│   ├── database/
│   │   ├── database.module.ts
│   │   ├── prisma.service.ts
│   │   └── migrations/
│   │
│   ├── common/
│   │   ├── filters/
│   │   │   └── http-exception.filter.ts
│   │   ├── interceptors/
│   │   │   └── logging.interceptor.ts
│   │   ├── guards/
│   │   └── decorators/
│   │
│   └── config/
│       └── configuration.ts
│
├── prisma/
│   ├── schema.prisma             # Prismaスキーマ
│   └── migrations/               # マイグレーション
│
├── test/
│   ├── unit/
│   └── e2e/
│
├── .env.example
├── .env
├── .gitignore
├── nest-cli.json
├── package.json
├── tsconfig.json
└── README.md
```

---

### 主要コンポーネント実装

#### main.ts
```typescript
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // CORS設定
  app.enableCors({
    origin: process.env.CORS_ORIGIN || '*',
    credentials: true,
  });
  
  // グローバルバリデーションパイプ
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  
  // グローバルプレフィックス
  app.setGlobalPrefix('api');
  
  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  console.log(`🚀 Server is running on: http://localhost:${port}/api`);
}

bootstrap();
```

#### health.controller.ts
```typescript
import {
  Controller,
  Post,
  Body,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { HealthService } from './health.service';
import { AnalyzeHealthDto } from './dto/analyze.dto';

@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Post('analyze')
  async analyzeHealth(@Body() analyzeDto: AnalyzeHealthDto) {
    try {
      return await this.healthService.analyzeHealth(analyzeDto);
    } catch (error) {
      throw new HttpException(
        {
          statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
          message: error.message || 'アドバイス生成に失敗しました',
        },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }
}
```

#### health.service.ts
```typescript
import { Injectable } from '@nestjs/common';
import { ClaudeService } from '../ai/claude.service';
import { WeatherService } from '../weather/weather.service';
import { PromptBuilder } from '../ai/prompt.builder';
import { AnalyzeHealthDto } from './dto/analyze.dto';
import { DailyAdvice } from './interfaces/daily-advice.interface';

@Injectable()
export class HealthService {
  constructor(
    private readonly claudeService: ClaudeService,
    private readonly weatherService: WeatherService,
    private readonly promptBuilder: PromptBuilder,
  ) {}

  async analyzeHealth(dto: AnalyzeHealthDto): Promise<DailyAdvice> {
    // 1. 天気データ取得
    const weather = await this.weatherService.getWeather(
      dto.location.latitude,
      dto.location.longitude,
    );

    // 2. プロンプト構築
    const prompt = this.promptBuilder.build({
      healthData: dto.healthData,
      weather,
      userProfile: dto.userProfile,
    });

    // 3. Claude APIで分析
    const advice = await this.claudeService.generateAdvice(prompt);

    // 4. 結果を整形して返却
    return {
      id: crypto.randomUUID(),
      date: new Date(),
      userId: dto.userId,
      theme: advice.theme,
      breakfast: advice.breakfast,
      lunch: advice.lunch,
      dinner: advice.dinner,
      exercise: advice.exercise,
      breathing: advice.breathing,
      hydration: advice.hydration,
      evening: advice.evening,
      weatherAdvice: advice.weatherAdvice,
    };
  }
}
```

#### claude.service.ts
```typescript
import { Injectable } from '@nestjs/common';
import Anthropic from '@anthropic-ai/sdk';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class ClaudeService {
  private anthropic: Anthropic;

  constructor(private configService: ConfigService) {
    this.anthropic = new Anthropic({
      apiKey: this.configService.get<string>('ANTHROPIC_API_KEY'),
    });
  }

  async generateAdvice(prompt: string): Promise<any> {
    const message = await this.anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 3000,
      temperature: 0.7,
      system: this.getSystemPrompt(),
      messages: [
        {
          role: 'user',
          content: prompt,
        },
      ],
    });

    // Claude APIのレスポンスからテキストを抽出
    const responseText = message.content[0].type === 'text'
      ? message.content[0].text
      : '';

    // JSON部分を抽出（```json ... ``` を除去）
    const jsonMatch = responseText.match(/```json\s*([\s\S]*?)\s*```/);
    const jsonText = jsonMatch ? jsonMatch[1] : responseText;

    try {
      return JSON.parse(jsonText);
    } catch (error) {
      console.error('JSON parse error:', error);
      console.error('Response:', responseText);
      throw new Error('AIレスポンスの解析に失敗しました');
    }
  }

  private getSystemPrompt(): string {
    return `あなたは精密栄養学、運動生理学、睡眠科学の専門家です。
ユーザーの生体データ、天気、個人特性を総合的に分析し、
その日に最適化された健康アドバイスを生成してください。

重要な原則:
1. 科学的根拠に基づいたアドバイス
2. 具体的で実行可能な提案
3. ユーザーの個人特性（年齢、目標、食事制限など）を考慮
4. 天気や環境要因も反映
5. ポジティブで励ます口調

回答は必ず以下のJSON形式で返してください：
{
  "theme": "今日のテーマ（例：血糖安定の日）",
  "breakfast": {
    "recommendation": "推奨メニュー",
    "reason": "理由",
    "examples": ["具体例1", "具体例2"]
  },
  "lunch": {
    "recommendation": "推奨",
    "reason": "理由",
    "examples": ["具体例"]
  },
  "dinner": {
    "recommendation": "推奨",
    "reason": "理由",
    "examples": ["具体例"]
  },
  "exercise": {
    "type": "運動の種類",
    "duration": "時間",
    "intensity": "強度",
    "reason": "理由",
    "avoid": ["避けるべき運動"]
  },
  "breathing": {
    "technique": "呼吸法の名前",
    "instructions": ["手順1", "手順2", "手順3"],
    "timing": "実施タイミング"
  },
  "hydration": {
    "amount": "目標水分量",
    "reason": "理由",
    "schedule": [
      {"time": "時間帯", "amount": "量"}
    ]
  },
  "evening": "夜の過ごし方（就寝時刻、入浴、避けるべきこと）",
  "weatherAdvice": "天気に基づくアドバイス"
}`;
  }
}
```

#### prompt.builder.ts
```typescript
import { Injectable } from '@nestjs/common';

export interface PromptData {
  healthData: any;
  weather: any;
  userProfile: any;
}

@Injectable()
export class PromptBuilder {
  build(data: PromptData): string {
    const { healthData, weather, userProfile } = data;

    return `
# ユーザープロフィール
- 年齢: ${userProfile.age}歳
- 性別: ${userProfile.gender}
- 身長: ${userProfile.height}cm
- 体重: ${userProfile.weight}kg
- 目標: ${userProfile.goals.join('、')}
- 運動習慣: ${userProfile.exerciseHabits.join('、')}
- 運動頻度: ${userProfile.exerciseFrequency}
- 食事の好み: ${userProfile.dietaryPreferences.join('、')}
- 食事制限: ${userProfile.dietaryRestrictions.length > 0 
    ? userProfile.dietaryRestrictions.join('、') 
    : 'なし'}
- 健康状態: ${userProfile.healthConditions.length > 0 
    ? userProfile.healthConditions.join('、') 
    : '特になし'}
- サプリメント: ${userProfile.supplements.length > 0 
    ? userProfile.supplements.join('、') 
    : 'なし'}

# 今日の生体データ分析
${this.buildHealthDataSection(healthData)}

# 今日の天気・環境
- 天気: ${weather.weatherDescription}
- 気温: ${weather.temperatureMax}°C / ${weather.temperatureMin}°C
- 湿度: ${weather.humidity}%
- 気圧: ${weather.pressure}hPa
- UV指数: ${weather.uvIndex}
- 降水確率: ${weather.precipitationProbability}%

上記を総合的に分析し、今日の最適な健康プランを生成してください。
特に以下の点に注意してください：

1. 睡眠の質とHRVから回復度を評価
2. 天気と運動の推奨を連動
3. 食事制限を必ず考慮
4. 具体的で実行可能なアドバイス
5. ユーザーの目標に沿った提案

必ずJSON形式で回答してください。
    `.trim();
  }

  private buildHealthDataSection(healthData: any): string {
    const sections: string[] = [];

    // 睡眠データ
    if (healthData.sleep) {
      const sleep = healthData.sleep;
      sections.push(`
## 睡眠
- 総睡眠時間: ${(sleep.totalMinutes / 60).toFixed(1)}時間
- 深い睡眠: ${sleep.deepMinutes}分 (${((sleep.deepMinutes / sleep.totalMinutes) * 100).toFixed(0)}%)
- REM睡眠: ${sleep.remMinutes}分 (${((sleep.remMinutes / sleep.totalMinutes) * 100).toFixed(0)}%)
- 浅い睡眠: ${sleep.lightMinutes}分 (${((sleep.lightMinutes / sleep.totalMinutes) * 100).toFixed(0)}%)
- 入眠時刻: ${sleep.sleepStart ? new Date(sleep.sleepStart).toLocaleTimeString('ja-JP') : '不明'}
- 起床時刻: ${sleep.sleepEnd ? new Date(sleep.sleepEnd).toLocaleTimeString('ja-JP') : '不明'}
      `.trim());
    }

    // HRV
    if (healthData.hrv) {
      sections.push(`
## 心拍変動（HRV）
- HRV: ${healthData.hrv.toFixed(1)}ms
      `.trim());
    }

    // 安静時心拍数
    if (healthData.restingHeartRate) {
      sections.push(`
## 心拍数
- 安静時心拍数: ${healthData.restingHeartRate.toFixed(0)}bpm
      `.trim());
    }

    // 活動データ
    sections.push(`
## 活動
- 歩数: ${healthData.steps}歩
- 消費カロリー: ${healthData.activeCalories.toFixed(0)}kcal
    `.trim());

    // その他
    if (healthData.weight) {
      sections.push(`
## 体組成
- 体重: ${healthData.weight.toFixed(1)}kg
${healthData.bodyFatPercentage ? `- 体脂肪率: ${healthData.bodyFatPercentage.toFixed(1)}%` : ''}
      `.trim());
    }

    if (healthData.vo2Max) {
      sections.push(`
## フィットネス
- VO2max: ${healthData.vo2Max.toFixed(1)}ml/kg/min
      `.trim());
    }

    return sections.join('\n\n');
  }
}
```

#### weather.service.ts
```typescript
import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

export interface WeatherData {
  temperature: number;
  temperatureMin: number;
  temperatureMax: number;
  humidity: number;
  pressure: number;
  uvIndex: number;
  precipitationProbability: number;
  weatherDescription: string;
  windSpeed?: number;
}

@Injectable()
export class WeatherService {
  private readonly baseUrl = 'https://api.open-meteo.com/v1/forecast';

  constructor(private readonly httpService: HttpService) {}

  async getWeather(
    latitude: number,
    longitude: number,
  ): Promise<WeatherData> {
    try {
      const params = {
        latitude,
        longitude,
        current: 'temperature_2m,relative_humidity_2m,pressure_msl,uv_index',
        daily: 'temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code',
        timezone: 'Asia/Tokyo',
      };

      const response = await firstValueFrom(
        this.httpService.get(this.baseUrl, { params }),
      );

      const data = response.data;

      return {
        temperature: data.current.temperature_2m,
        temperatureMin: data.daily.temperature_2m_min[0],
        temperatureMax: data.daily.temperature_2m_max[0],
        humidity: data.current.relative_humidity_2m,
        pressure: data.current.pressure_msl,
        uvIndex: data.current.uv_index,
        precipitationProbability: data.daily.precipitation_probability_max[0],
        weatherDescription: this.getWeatherDescription(
          data.daily.weather_code[0],
        ),
        windSpeed: data.current.wind_speed_10m,
      };
    } catch (error) {
      throw new HttpException(
        '天気データの取得に失敗しました',
        HttpStatus.BAD_GATEWAY,
      );
    }
  }

  private getWeatherDescription(code: number): string {
    // WMO Weather interpretation codes
    if (code === 0) return '快晴';
    if (code === 1) return '晴れ';
    if (code === 2) return '一部曇り';
    if (code === 3) return '曇り';
    if (code >= 45 && code <= 48) return '霧';
    if (code >= 51 && code <= 55) return '霧雨';
    if (code >= 61 && code <= 65) return '雨';
    if (code >= 71 && code <= 77) return '雪';
    if (code >= 80 && code <= 82) return 'にわか雨';
    if (code >= 95 && code <= 99) return '雷雨';
    return '不明';
  }
}
```

---

## 💾 データベース設計

### Prismaスキーマ

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id                  String   @id @default(uuid())
  createdAt           DateTime @default(now()) @map("created_at")
  updatedAt           DateTime @updatedAt @map("updated_at")
  
  // Profile
  age                 Int
  gender              String
  height              Float    // cm
  weight              Float    // kg
  goals               String[] // Array of goals
  dietaryPreferences  String[] @map("dietary_preferences")
  dietaryRestrictions String[] @map("dietary_restrictions")
  exerciseHabits      String[] @map("exercise_habits")
  exerciseFrequency   String   @map("exercise_frequency")
  exerciseMinutesPerSession Int @map("exercise_minutes_per_session")
  healthConditions    String[] @map("health_conditions")
  supplements         String[]
  medications         String[]
  sleepConcerns       String[] @map("sleep_concerns")
  
  // Notification settings
  notificationTime    DateTime @map("notification_time")
  notificationDays    Int[]    @map("notification_days")
  
  // Relations
  adviceHistory       Advice[]
  
  @@map("users")
}

model Advice {
  id                 String   @id @default(uuid())
  createdAt          DateTime @default(now()) @map("created_at")
  date               DateTime
  
  // Foreign key
  userId             String   @map("user_id")
  user               User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  // Content
  theme              String
  breakfast          Json
  lunch              Json
  dinner             Json
  exercise           Json
  breathing          Json
  hydration          Json
  evening            String
  weatherAdvice      String   @map("weather_advice")
  
  // Metadata
  healthData         Json     @map("health_data")
  weatherData        Json     @map("weather_data")
  
  @@index([userId, date])
  @@map("advice")
}
```

### マイグレーション

```bash
# Prismaマイグレーション作成
npx prisma migrate dev --name init

# Prismaクライアント生成
npx prisma generate
```

---

## 🔌 API設計

### エンドポイント一覧

#### Phase 1: MVP

| メソッド | エンドポイント | 説明 |
|---------|---------------|------|
| POST | `/api/health/analyze` | ヘルスデータを分析してアドバイス生成 |
| POST | `/api/users/profile` | ユーザープロフィール保存 |
| GET | `/api/users/profile/:userId` | ユーザープロフィール取得 |

#### Phase 3: 履歴機能

| メソッド | エンドポイント | 説明 |
|---------|---------------|------|
| GET | `/api/advice/history/:userId` | アドバイス履歴取得（7日間） |
| DELETE | `/api/advice/:adviceId` | 特定のアドバイス削除 |

---

### API詳細仕様

#### POST /api/health/analyze

**リクエスト:**
```json
{
  "user_id": "uuid",
  "health_data": {
    "date": "2024-12-04T00:00:00Z",
    "sleep": {
      "total_minutes": 390,
      "deep_minutes": 90,
      "rem_minutes": 75,
      "light_minutes": 225,
      "sleep_start": "2024-12-03T22:30:00Z",
      "sleep_end": "2024-12-04T05:00:00Z"
    },
    "hrv": 65.5,
    "resting_heart_rate": 58.0,
    "respiratory_rate": 14.5,
    "steps": 8234,
    "active_calories": 450.0,
    "weight": 70.5,
    "body_fat_percentage": 15.2,
    "vo2_max": 48.5
  },
  "user_profile": {
    "user_id": "uuid",
    "age": 28,
    "gender": "male",
    "height": 175.0,
    "weight": 70.5,
    "goals": ["疲労回復", "集中力向上"],
    "dietary_preferences": ["和食", "洋食"],
    "dietary_restrictions": ["乳製品"],
    "exercise_habits": ["ランニング", "筋トレ"],
    "exercise_frequency": "週5-6回",
    "exercise_minutes_per_session": 60,
    "health_conditions": [],
    "supplements": ["ビタミンD", "オメガ3"],
    "medications": [],
    "sleep_concerns": [],
    "notification_time": "2024-12-04T06:00:00Z",
    "notification_days": [1, 2, 3, 4, 5, 6, 7],
    "created_at": "2024-12-01T00:00:00Z",
    "updated_at": "2024-12-04T00:00:00Z"
  },
  "location": {
    "latitude": 35.6895,
    "longitude": 139.6917
  }
}
```

**レスポンス:**
```json
{
  "id": "uuid",
  "date": "2024-12-04T00:00:00Z",
  "user_id": "uuid",
  "theme": "血糖安定の日",
  "breakfast": {
    "recommendation": "低GI食品を中心に",
    "reason": "睡眠時間が6.5時間と短めでした。睡眠不足時は血糖値が不安定になりやすいため、低GI食品で緩やかにエネルギーを補給しましょう。",
    "examples": [
      "オートミール（1カップ）",
      "ゆで卵（2個）",
      "アボカド（半分）",
      "ベリー類（適量）"
    ]
  },
  "lunch": {
    "recommendation": "炭水化物は控えめに",
    "reason": "午後の集中力を維持するため、タンパク質と野菜を中心にしましょう。",
    "examples": [
      "鶏胸肉のサラダ",
      "玄米（少量）",
      "味噌汁"
    ]
  },
  "dinner": {
    "recommendation": "18時までに済ませるのが理想",
    "reason": "睡眠の質を高めるため、消化の良いものを早めに。",
    "examples": [
      "焼き魚",
      "温野菜",
      "雑穀米"
    ]
  },
  "exercise": {
    "type": "軽めのウォーキング",
    "duration": "30分",
    "intensity": "心拍数100-120bpm程度",
    "reason": "HRVが昨日より10%低下しています。これは回復が不十分なサイン。激しい運動は避け、軽い有酸素運動で血流を促進しましょう。",
    "avoid": ["HIIT", "重量挙げ", "長距離ラン"]
  },
  "breathing": {
    "technique": "4-7-8呼吸法",
    "instructions": [
      "4秒かけて鼻から息を吸う",
      "7秒息を止める",
      "8秒かけて口から吐く",
      "これを3-5回繰り返す"
    ],
    "timing": "朝起きて5分以内が最適"
  },
  "hydration": {
    "amount": "2.5L",
    "reason": "気温15°C、湿度40%（やや乾燥）。今日は運動予定もあるため、適切な水分で代謝を維持しましょう。",
    "schedule": [
      {"time": "起床後", "amount": "500ml"},
      {"time": "午前中", "amount": "500ml"},
      {"time": "昼食時", "amount": "300ml"},
      {"time": "午後", "amount": "500ml"},
      {"time": "夕方", "amount": "400ml"},
      {"time": "夕食時", "amount": "300ml"}
    ]
  },
  "evening": "22時30分を目標に就寝。21時頃に40°Cのお湯に15分入浴。20時以降はカフェイン摂取を避け、照明を落としてリラックスタイムを。",
  "weather_advice": "今日は晴れで気温15°C。午前中に日光を15-30分浴びましょう。UV指数5（中程度）のため、帽子またはサングラスを。外での運動に最適な日です。"
}
```

---

## 🚀 開発フェーズ詳細

### Phase 1: MVP（Week 1-2）

**目標:** 最小限で動くアプリを完成

#### Week 1: iOS + Workers基礎

**Day 1-2: iOS基礎**
- [ ] Xcodeプロジェクト作成
- [ ] HealthKit権限設定
- [ ] 基本UI構造（タブバー、ホーム画面）
- [ ] カラーテーマ実装

**Day 3-4: HealthKit実装**
- [ ] HealthKitManager実装
  - [ ] 権限リクエスト
  - [ ] 睡眠データ取得
  - [ ] HRVデータ取得
  - [ ] 心拍数、歩数取得
- [ ] データ取得テスト（実機）

**Day 5-6: Workers構築**
```bash
# Workersプロジェクト作成
npm create cloudflare@latest tempo-ai-api
cd tempo-ai-api

# Hono + 依存関係インストール
npm install hono @anthropic-ai/sdk

# ファイル作成
- src/index.ts（エントリー）
- src/routes/health.ts（メインAPI）
- src/services/claude.service.ts（AI）
- src/services/weather.service.ts（天気）
- src/services/prompt.builder.ts（プロンプト）
- src/types/health-data.ts（型定義）

# ローカルテスト
wrangler dev
```

**Day 7: 統合**
- [ ] iOSとWorkers統合
- [ ] APIClient実装
- [ ] E2Eテスト
- [ ] エラーハンドリング

**成果物チェックリスト:**
- [ ] アプリを開くとHealthKitデータ取得
- [ ] Workersにデータ送信
- [ ] Claude APIからアドバイス取得
- [ ] ホーム画面に表示
- [ ] 詳細画面表示
- [ ] クラッシュしない

**デプロイ:**
```bash
# Workers本番デプロイ
wrangler deploy

# iOS実機テスト
# Xcodeから実機にインストール
```

---

### Phase 2: App Store準備（Week 3-4）

**目標:** リリース可能な品質

#### Week 3: 機能追加

**Day 1-2: 通知**
- [ ] UNUserNotificationCenter実装
- [ ] ローカル通知スケジュール
- [ ] 通知設定画面

**Day 3-4: プロフィール**
- [ ] 完全なプロフィール設定画面
- [ ] バリデーション
- [ ] UserDefaults保存

**Day 5-6: UI洗練**
- [ ] カラースキーム適用
- [ ] アニメーション追加
- [ ] ダークモード対応

**Day 7: オンボーディング**
- [ ] ウェルカム画面
- [ ] 機能紹介
- [ ] 権限リクエスト

#### Week 4: データベース & 最終調整

**Day 1-2: Supabase統合**
```bash
# Hyperdrive設定
wrangler hyperdrive create tempo-ai-db \
  --connection-string="postgres://..."

# Prisma設定
npx prisma init
npx prisma migrate dev

# Workers更新
npm install @prisma/client @prisma/adapter-pg pg
```

**Day 3-4: プロンプト改善**
- [ ] 複数シナリオテスト
- [ ] エッジケース対応
- [ ] 出力品質向上

**Day 5: App Store準備**
- [ ] アイコン作成
- [ ] スクリーンショット
- [ ] 説明文
- [ ] プライバシーポリシー

**Day 6-7: 総合テスト**
- [ ] バグ修正
- [ ] パフォーマンス最適化
- [ ] TestFlight配信

**リリース判断:**
- [ ] 基本機能安定
- [ ] UIクオリティ高い
- [ ] エラーハンドリング適切
- [ ] クラッシュ率 <1%
- [ ] TestFlight完了

**→ App Storeリリース！🎉**

**コスト（Phase 1-2）:**
- Cloudflare Workers: **無料**
- Supabase: **無料**
- Claude API: ~$10-20/月
- Apple Developer: $99/年
- **合計: $10-20/月 + $99/年**

---

### Phase 3: 履歴機能（Week 5-7）

**目標:** データ蓄積と振り返り

#### Week 5-6: 履歴開発

**Workers API:**
```typescript
// src/routes/advice.ts
advice.get('/history/:userId', async (c) => {
  const userId = c.req.param('userId');
  const days = 7;
  
  // Supabaseから取得
  const history = await dbService.getHistory(userId, days);
  
  return c.json(history);
});
```

**iOS:**
- [ ] 履歴画面UI
- [ ] 履歴一覧表示
- [ ] 詳細表示
- [ ] データキャッシュ

#### Week 7: 最適化
- [ ] ローディング最適化
- [ ] UIブラッシュアップ
- [ ] バグ修正
- [ ] v1.1リリース

**コスト（Phase 3）:**
- Cloudflare Workers: **$5/月**（有料プラン移行）
- Supabase: **無料**
- Claude API: ~$10-20/月
- **合計: $15-25/月**

---

### Phase 4: トレンド & Watch（Week 8-12）

**目標:** 高度な分析とApple Watch

#### Week 8-9: グラフ実装
- [ ] Charts framework
- [ ] 睡眠グラフ
- [ ] HRVグラフ
- [ ] 歩数グラフ

#### Week 10: AI分析
- [ ] パターン分析API
- [ ] 洞察生成
- [ ] フロントエンド表示

#### Week 11-12: Apple Watch
- [ ] watchOSアプリ
- [ ] 基本機能
- [ ] コンプリケーション
- [ ] v1.2リリース

---

## 💰 コスト見積もり（詳細）

### Phase 1-2（開発〜初回リリース）

| 項目 | 無料枠 | コスト |
|-----|-------|-------|
| **Cloudflare Workers** | 100,000 req/日 | **$0** |
| **Supabase** | 500MB, 無制限req | **$0** |
| **Claude API** | 従量課金 | $10-20/月 |
| **Apple Developer** | - | $99/年 |
| **合計** | | **$10-20/月 + $99/年** |

---

### Phase 3+（有料プラン移行後）

| 項目 | 提供内容 | コスト |
|-----|---------|-------|
| **Cloudflare Workers Paid** | 10M req/月, 30秒CPU | **$5/月** |
| **Cloudflare Hyperdrive** | DB接続最適化 | **含まれる** |
| **Supabase** | 500MB, 無制限req | **$0** |
| **Claude API** | 従量課金 | $10-20/月 |
| **Apple Developer** | - | $99/年 |
| **合計** | | **$15-25/月 + $99/年** |

---

### リリース後の想定（1,000 DAU）

**前提:**
- 1日1,000ユーザー
- 各ユーザー1回アドバイス生成
- 1リクエストあたり:
  - Claude API: $0.015（Sonnet 4.5, 3000 tokens）
  - Workers CPU time: 10ms

**月間コスト:**
```
Cloudflare Workers:
- リクエスト: 30,000/月（無料枠内）
- CPU time: 300秒/月（無料枠内）
= $0

Supabase:
- ストレージ: ~10MB（無料枠内）
= $0

Claude API:
- 30,000リクエスト × $0.015 = $450/月

合計: $450/月
```

**10,000 DAUの場合:**
```
Claude API: $4,500/月
Workers: $5/月（有料プラン）
= $4,505/月
```

**コスト削減策:**
- キャッシュ活用（同じ入力は再利用）
- プロンプト最適化（トークン数削減）
- Claude Haiku使用（安価なモデル）

---

## 🎯 次のステップ

### 今すぐ始める

**1. Cloudflareアカウント作成**
```bash
# Cloudflareにサインアップ
https://dash.cloudflare.com/sign-up

# Wranglerインストール
npm install -g wrangler

# ログイン
wrangler login
```

**2. Workersプロジェクト作成**
```bash
npm create cloudflare@latest tempo-ai-api
cd tempo-ai-api
npm install hono @anthropic-ai/sdk
```

**3. iOSプロジェクト作成**
- Xcodeで新規プロジェクト
- 名前: TempoAI
- Interface: SwiftUI
- Language: Swift

**4. Claude Codeと開発開始！**

---

**以上、Tempo AI 開発仕様書（Cloudflare Workers Edition）でした。**

準備は整いました。さあ、開発を始めましょう！ 🚀

**Day 1-2:**
- [ ] Xcodeプロジェクト作成
- [ ] HealthKit権限設定（Info.plist）
- [ ] 基本的なUI構造（タブバー、ホーム画面）
- [ ] カラーテーマ実装（Theme.swift）

**Day 3-4:**
- [ ] HealthKitManager実装
  - [ ] 権限リクエスト
  - [ ] 睡眠データ取得
  - [ ] HRVデータ取得
  - [ ] 心拍数データ取得
  - [ ] 歩数データ取得
- [ ] データ取得のテスト（実機必須）

**Day 5-6:**
- [ ] LocationManager実装
- [ ] APIClient実装（基本）
- [ ] UserDefaultsManagerでプロフィール保存

**Day 7:**
- [ ] ホーム画面UI実装
- [ ] ローディング状態
- [ ] エラー表示

#### Week 2: バックエンド & 統合

**Day 1-2:**
- [ ] NestJSプロジェクト作成
- [ ] 基本的なモジュール構成
- [ ] POST /api/health/analyze実装
- [ ] Open-Meteo API統合

**Day 3-4:**
- [ ] Claude API統合
- [ ] PromptBuilder実装
- [ ] 基本的なプロンプトエンジニアリング
- [ ] JSONパース処理

**Day 5-6:**
- [ ] iOSとバックエンドの統合
- [ ] E2Eテスト
- [ ] エラーハンドリング改善

**Day 7:**
- [ ] 詳細アドバイス画面実装
- [ ] プロフィール設定（最小限）
- [ ] 全体的なバグ修正

**成果物チェックリスト:**
- [ ] アプリを開くとHealthKitデータが取得できる
- [ ] サーバーにデータを送信できる
- [ ] AIからアドバイスが返ってくる
- [ ] ホーム画面に表示される
- [ ] 詳細画面が見れる
- [ ] クラッシュしない

---

### Phase 2: App Store準備（Week 3-4）

**目標:** リリース可能な品質に磨き上げ

#### Week 3: UI/UX & 機能追加

**Day 1-2:**
- [ ] 通知機能実装
  - [ ] UNUserNotificationCenter設定
  - [ ] ローカル通知スケジュール
  - [ ] 通知タップ時の処理
- [ ] 通知設定画面

**Day 3-4:**
- [ ] プロフィール設定（完全版）
  - [ ] 基本情報編集
  - [ ] 目標設定
  - [ ] 食事設定
  - [ ] 運動習慣設定
  - [ ] 健康状態設定
- [ ] データバリデーション

**Day 5-6:**
- [ ] UIの洗練
  - [ ] カラースキーム適用
  - [ ] フォント統一
  - [ ] アニメーション追加
  - [ ] ダークモード対応
- [ ] オンボーディング実装
  - [ ] ウェルカム画面
  - [ ] 機能紹介
  - [ ] 権限リクエスト

**Day 7:**
- [ ] エラーハンドリング改善
- [ ] ローディング状態改善
- [ ] 全体的なUXテスト

#### Week 4: データベース & 最終調整

**Day 1-2:**
- [ ] Supabase設定
- [ ] Prismaスキーマ作成
- [ ] マイグレーション実行
- [ ] バックエンドのデータベース統合

**Day 3-4:**
- [ ] プロンプトエンジニアリング改善
  - [ ] 複数シナリオでテスト
  - [ ] エッジケース対応
  - [ ] 出力品質向上
- [ ] APIレスポンスキャッシュ

**Day 5:**
- [ ] App Store素材準備
  - [ ] アイコン作成
  - [ ] スクリーンショット
  - [ ] プレビュー動画（オプション）
  - [ ] アプリ説明文
- [ ] プライバシーポリシー作成
- [ ] 利用規約作成

**Day 6-7:**
- [ ] 総合テスト
- [ ] バグ修正
- [ ] パフォーマンス最適化
- [ ] TestFlight配信準備

**リリース判断チェックリスト:**
- [ ] 基本機能が安定動作
- [ ] UIが洗練されている
- [ ] エラーハンドリングが適切
- [ ] プライバシーポリシー完成
- [ ] App Store審査用素材準備完了
- [ ] TestFlightでβテスト完了
- [ ] クラッシュ率 < 1%

**→ App Storeリリース！**

---

### Phase 3: 履歴機能（Week 5-7）

**目標:** データ蓄積と振り返り機能

#### Week 5-6: 履歴機能開発

**バックエンド:**
- [ ] GET /api/advice/history/:userId実装
- [ ] 7日間フィルタリング
- [ ] ページネーション（将来用）

**iOS:**
- [ ] 履歴画面UI実装
- [ ] 履歴一覧表示
- [ ] 詳細表示
- [ ] データキャッシュ

#### Week 7: テストと最適化

- [ ] 履歴データのローディング最適化
- [ ] UIブラッシュアップ
- [ ] バグ修正
- [ ] v1.1リリース

---

### Phase 4: トレンド分析（Week 8-12）

**目標:** データ可視化と高度な分析

#### Week 8-9: グラフ実装

- [ ] Charts framework統合
- [ ] 睡眠時間グラフ
- [ ] HRVグラフ
- [ ] 歩数グラフ
- [ ] インタラクティブ機能

#### Week 10: AI分析コメント

- [ ] バックエンドでパターン分析
- [ ] Claude APIで洞察生成
- [ ] フロントエンドに表示

#### Week 11-12: Apple Watch対応

- [ ] watchOSアプリ作成
- [ ] 基本機能実装
- [ ] コンプリケーション
- [ ] テストとバグ修正
- [ ] v1.2リリース

---

## 🔒 セキュリティ

### 通信セキュリティ

**HTTPS必須:**
- すべてのAPI通信はHTTPS（TLS 1.3）
- 証明書の検証

**APIキー管理:**
```typescript
// 環境変数で管理
ANTHROPIC_API_KEY=sk-ant-xxx
DATABASE_URL=postgresql://xxx

// iOS側は直接APIキーを持たない
// バックエンド経由でのみアクセス
```

### データプライバシー

**個人情報の取り扱い:**
- HealthKitデータはiPhoneローカルに保存
- サーバーには分析時のみ送信
- 送信後は即座に破棄（ログにも残さない）

**匿名化:**
- ユーザーIDはUUID（個人を特定できない）
- 名前、メールアドレスは収集しない（Phase 1-2）

**データ保持期間:**
- アドバイス履歴: 7日間のみ
- 7日以上経過したデータは自動削除

### 認証・認可（Phase 5以降）

```
Phase 1-4: 認証なし（UUIDのみ）
Phase 5: Supabase Authで認証導入
```

---

## 🧪 テスト戦略

### ユニットテスト

**iOS (XCTest):**
```swift
// HealthKitManagerのテスト
func testFetchLastNightData() async throws {
    let manager = HealthKitManager.shared
    let data = try await manager.fetchLastNightData()
    
    XCTAssertNotNil(data)
    XCTAssertNotNil(data.sleep)
}
```

**Backend (Jest):**
```typescript
// health.service.spec.ts
describe('HealthService', () => {
  it('should generate advice', async () => {
    const service = new HealthService(...);
    const advice = await service.analyzeHealth(mockDto);
    
    expect(advice.theme).toBeDefined();
    expect(advice.breakfast).toBeDefined();
  });
});
```

### E2Eテスト

**シナリオ:**
1. アプリ起動
2. HealthKitデータ取得
3. API呼び出し
4. アドバイス表示
5. 詳細画面遷移

### パフォーマンステスト

**指標:**
- アドバイス生成時間: < 15秒
- API レスポンス時間: < 10秒
- アプリ起動時間: < 3秒

---

## 🚢 デプロイメント

### Cloudflare Workers（超簡単）

#### 初回デプロイ

```bash
# 1. Cloudflareにログイン
wrangler login

# 2. Hyperdrive設定（Supabase接続）
wrangler hyperdrive create tempo-ai-db \
  --connection-string="postgres://user:pass@db.supabase.co:5432/postgres"

# 出力されたIDをwrangler.tomlに追加

# 3. Secretsを設定
wrangler secret put ANTHROPIC_API_KEY
# プロンプトでAPIキーを入力

# 4. デプロイ
wrangler deploy

# 完了！
# URL: https://tempo-ai-api.YOUR_SUBDOMAIN.workers.dev
```

**デプロイ時間: 約30秒**

---

#### 継続的デプロイ（GitHub Actions）

**`.github/workflows/deploy.yml`**

```yaml
name: Deploy to Cloudflare Workers

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    name: Deploy
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Deploy to Cloudflare Workers
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
```

**Secrets設定（GitHubリポジトリ）:**
1. Settings → Secrets and variables → Actions
2. 以下を追加:
   - `CLOUDFLARE_API_TOKEN`: Cloudflare APIトークン
   - `CLOUDFLARE_ACCOUNT_ID`: CloudflareアカウントID

---

### デプロイ戦略

#### Phase 1（MVP）: 手動デプロイ
```bash
wrangler deploy
```

#### Phase 2+: 自動デプロイ
```bash
git push origin main
# GitHub Actionsが自動デプロイ
```

#### Gradual Deployments（Phase 3+）

Cloudflareの段階的デプロイ機能を使用：

```toml
# wrangler.toml
[deployments]
gradual = true
```

新しいバージョンを段階的にロールアウト：
- 0.05% → 0.5% → 3% → 10% → 25% → 50% → 75% → 100%

問題があれば自動的にロールバック。

---

### 監視とログ

#### Wrangler Tail（リアルタイムログ）

```bash
# リアルタイムでログを表示
wrangler tail

# 特定のWorkerのログ
wrangler tail tempo-ai-api

# フィルタリング
wrangler tail --status error
```

#### Cloudflare Dashboard

1. Workers & Pages → tempo-ai-api
2. Logs タブ
   - リクエストログ
   - エラーログ
   - パフォーマンスメトリクス
3. Analytics タブ
   - リクエスト数
   - CPU time使用量
   - エラー率

---

### iOS App（App Store Connect）

#### TestFlight

```bash
# 1. Xcode Archive
# Product → Archive

# 2. App Store Connectにアップロード
# Distribute App → App Store Connect

# 3. TestFlight βテスト
# App Store Connect → TestFlight → Internal Testing
```

#### 本番リリース

```bash
# 1. バージョン番号更新
# Info.plist: CFBundleShortVersionString

# 2. リリースノート作成
# App Store Connect → 1.0 Prepare for Submission

# 3. スクリーンショット更新

# 4. 審査提出
# Submit for Review
```

---

### バージョン管理戦略

```
main (本番)
  ↑ PR
develop (開発)
  ↑ PR
feature/xxx (機能開発)
```

**ブランチ運用:**
- `main`: 本番環境（App Store + Workers本番）
- `develop`: 開発環境（TestFlight + Workers dev）
- `feature/*`: 機能開発

---

### ロールバック手順

#### Workers
```bash
# デプロイ履歴確認
wrangler deployments list

# 特定バージョンにロールバック
wrangler rollback [DEPLOYMENT_ID]
```

#### iOS
- App Store Connect → 新バージョンを緊急で審査申請
- または問題のあるビルドを削除

---

## 📊 パフォーマンスモニタリング

### 重要指標

#### Cloudflare Workers
- **リクエスト数**: 100,000/日以内（無料枠）
- **CPU time**: 平均 <10ms（目標）
- **エラー率**: <1%
- **レスポンス時間**: P50 <2秒、P95 <5秒

#### iOS App
- **クラッシュ率**: <1%
- **起動時間**: <3秒
- **通知開封率**: >60%
- **DAU/MAU**: >50%

### アラート設定（Phase 3+）

Cloudflare Alertsで以下を監視：
- エラー率が5%を超えた
- CPU time使用量が80%を超えた
- リクエスト数が急増

---

## 🔒 環境変数管理

### ローカル開発

**`.dev.vars`（gitignore対象）**
```bash
ANTHROPIC_API_KEY=sk-ant-xxx
DATABASE_URL=postgresql://...
```

### 本番環境

**Wrangler Secrets**
```bash
# 設定
wrangler secret put ANTHROPIC_API_KEY

# 確認
wrangler secret list

# 削除
wrangler secret delete ANTHROPIC_API_KEY
```

### iOS App

**Info.plist**
```xml
<key>API_BASE_URL</key>
<string>https://tempo-ai-api.YOUR_SUBDOMAIN.workers.dev/api</string>
```

開発/本番で切り替え：
```swift
#if DEBUG
let baseURL = "http://localhost:8787/api"
#else
let baseURL = "https://tempo-ai-api.YOUR_SUBDOMAIN.workers.dev/api"
#endif
```

---

## 📚 参考資料

### Apple Documentation
- [HealthKit Framework](https://developer.apple.com/documentation/healthkit)
- [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [SwiftUI](https://developer.apple.com/documentation/swiftui)

### Cloudflare Documentation
- [Cloudflare Workers](https://developers.cloudflare.com/workers/)
- [Hono Framework](https://hono.dev/docs/)
- [Hyperdrive](https://developers.cloudflare.com/hyperdrive/)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/)

### API Documentation
- [Claude API](https://docs.anthropic.com/claude/reference)
- [Open-Meteo API](https://open-meteo.com/en/docs)
- [Supabase](https://supabase.com/docs)

### Framework Documentation
- [Prisma](https://www.prisma.io/docs/)
- [TypeScript](https://www.typescriptlang.org/docs/)

---

**以上、Tempo AI 開発仕様書（Cloudflare Workers Edition）でした。**

この構成により：
- ✅ **モダン**: 2024年最新のエッジコンピューティング
- ✅ **軽量**: Hono 14KB、シンプルな構成
- ✅ **高速**: コールドスタート0ms、グローバル配信
- ✅ **安全**: V8 isolates、Cloudflare DDoS保護
- ✅ **コスト効率**: Phase 1-2は無料、リリース後も$15-25/月

準備は整いました。さあ、開発を始めましょう！ 🚀

```bash
# Server
NODE_ENV=production
PORT=3000

# Database
DATABASE_URL=postgresql://user:password@host:5432/tempo_ai

# API Keys
ANTHROPIC_API_KEY=sk-ant-api-xxx

# CORS
CORS_ORIGIN=*

# Sentry (Phase 2+)
SENTRY_DSN=https://xxx@sentry.io/xxx
```

### iOS (Info.plist)

```xml
<key>API_BASE_URL</key>
<string>https://tempo-ai-api.railway.app/api</string>

<key>NSHealthShareUsageDescription</key>
<string>睡眠や心拍データから健康アドバイスを生成します</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>天気情報を取得するために位置情報を使用します</string>
```

---

## 📚 参考資料

### Apple Documentation
- [HealthKit Framework](https://developer.apple.com/documentation/healthkit)
- [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [SwiftUI](https://developer.apple.com/documentation/swiftui)

### API Documentation
- [Claude API](https://docs.anthropic.com/claude/reference)
- [Open-Meteo API](https://open-meteo.com/en/docs)

### Framework Documentation
- [NestJS](https://docs.nestjs.com/)
- [Prisma](https://www.prisma.io/docs/)
- [Supabase](https://supabase.com/docs)

---

## 🎯 次のステップ

### 今すぐ始める

**1. リポジトリ作成:**
```bash
mkdir tempo-ai
cd tempo-ai
git init
```

**2. バックエンドセットアップ:**
```bash
mkdir backend
cd backend
npm init -y
npm install @nestjs/cli
nest new .
```

**3. iOSプロジェクト作成:**
- Xcodeで新規プロジェクト
- 名前: TempoAI
- Interface: SwiftUI
- Language: Swift

**4. Claude Codeと一緒に開発開始！**

---

**以上、Tempo AI 開発仕様書でした。**

準備は整いました。さあ、開発を始めましょう！ 🚀