# 📱 Tempo AI - Phase 1 MVP 実装計画書

**目標**: 最初のアドバイスを表示できるMVPを構築  
**期間**: 2週間（Week 1-2）  
**成功基準**: ユーザーがアプリを開いて今日のアドバイスが見れる  
**作成日**: 2024年12月4日

---

## 🎯 Phase 1 スコープ

### 含むもの ✅
- Cloudflare Workers API（基本機能）
- iOS アプリ（最小限のUI）
- HealthKitデータ取得
- 天気API統合
- Claude APIによるアドバイス生成
- ホーム画面と詳細画面
- 通知機能（基本）
- エラーハンドリング（基本）

### 含まないもの ❌
- データベース（履歴保存なし）
- 履歴画面
- トレンド分析
- 複雑なUI/アニメーション
- Apple Watch対応
- 多言語対応（英語のみ）
- ユーザー認証

---

## 🏗️ アーキテクチャ概要

```
iOS App (SwiftUI)
    ↓
[HTTPS Request]
    ↓
Cloudflare Workers (Hono)
    ├── Open-Meteo API (天気)
    └── Claude API (AI分析)
    ↓
[JSON Response]
    ↓
iOS App (表示)
```

---

## 📋 実装ステージ

## Stage 1: Cloudflare Workers API セットアップ（Day 1-3）

### 1.1 プロジェクト初期化

```bash
# Workersプロジェクト作成
npm create cloudflare@latest tempo-ai-api
cd tempo-ai-api

# 必要なパッケージインストール
npm install hono @anthropic-ai/sdk

# 開発用パッケージ
npm install -D @cloudflare/workers-types wrangler
```

### 1.2 プロジェクト構造

```
tempo-ai-api/
├── src/
│   ├── index.ts              # メインエントリー
│   ├── routes/
│   │   └── health.ts          # /health/* ルート
│   ├── services/
│   │   ├── weather.ts         # Open-Meteo API
│   │   └── ai.ts              # Claude API
│   ├── utils/
│   │   ├── prompts.ts         # AIプロンプト管理
│   │   └── errors.ts          # エラーハンドリング
│   └── types/
│       ├── health.ts          # HealthKitデータ型
│       ├── weather.ts         # 天気データ型
│       └── advice.ts          # アドバイスデータ型
├── wrangler.toml              # Cloudflare設定
├── package.json
└── tsconfig.json
```

### 1.3 Core API実装

**src/index.ts:**
```typescript
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { healthRoutes } from './routes/health'

type Bindings = {
  ANTHROPIC_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.use('/*', cors())

app.route('/api/health', healthRoutes)

app.get('/', (c) => {
  return c.json({ 
    service: 'Tempo AI API',
    version: '1.0.0',
    status: 'healthy'
  })
})

export default app
```

**src/routes/health.ts:**
```typescript
import { Hono } from 'hono'
import { analyzeHealth } from '../services/ai'
import { getWeather } from '../services/weather'

export const healthRoutes = new Hono()

healthRoutes.post('/analyze', async (c) => {
  try {
    // リクエストボディ取得
    const body = await c.req.json()
    const { healthData, location, userProfile } = body

    // 天気データ取得（並列実行）
    const weatherPromise = getWeather(location.latitude, location.longitude)
    
    // 天気データ待機
    const weather = await weatherPromise

    // AI分析実行
    const advice = await analyzeHealth({
      healthData,
      weather,
      userProfile,
      apiKey: c.env.ANTHROPIC_API_KEY
    })

    return c.json(advice)
  } catch (error) {
    console.error('Analysis error:', error)
    return c.json(
      { error: 'Failed to analyze health data' },
      500
    )
  }
})
```

### 1.4 外部API統合

**src/services/weather.ts:**
```typescript
export const getWeather = async (lat: number, lon: number) => {
  const url = `https://api.open-meteo.com/v1/forecast?` +
    `latitude=${lat}&longitude=${lon}&` +
    `current=temperature_2m,relative_humidity_2m,apparent_temperature,` +
    `precipitation,rain,weather_code,cloud_cover,wind_speed_10m&` +
    `daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,` +
    `uv_index_max,precipitation_sum&` +
    `timezone=auto`

  const response = await fetch(url)
  if (!response.ok) {
    throw new Error('Weather API failed')
  }

  return response.json()
}
```

**src/services/ai.ts:**
```typescript
import Anthropic from '@anthropic-ai/sdk'
import { buildPrompt } from '../utils/prompts'

export const analyzeHealth = async (params: AnalyzeParams) => {
  const anthropic = new Anthropic({
    apiKey: params.apiKey,
  })

  const prompt = buildPrompt(params)

  const message = await anthropic.messages.create({
    model: 'claude-3-5-sonnet-20241022',
    max_tokens: 4000,
    temperature: 0.7,
    system: "You are a health advisor that provides personalized daily health advice based on health metrics and weather conditions. Always respond in valid JSON format.",
    messages: [{
      role: 'user',
      content: prompt
    }]
  })

  const content = message.content[0].text
  return JSON.parse(content)
}
```

### 1.5 プロンプトエンジニアリング

**src/utils/prompts.ts:**
```typescript
export const buildPrompt = (params: PromptParams): string => {
  const { healthData, weather, userProfile } = params

  return `
Analyze the following health data and weather conditions to provide personalized health advice for today.

USER PROFILE:
- Age: ${userProfile.age}
- Gender: ${userProfile.gender}
- Goals: ${userProfile.goals.join(', ')}
- Dietary Preferences: ${userProfile.dietaryPreferences}
- Exercise Habits: ${userProfile.exerciseHabits}

HEALTH DATA (Last 24 hours):
- Sleep Duration: ${healthData.sleep.duration} hours
- Sleep Quality: Deep ${healthData.sleep.deep}h, REM ${healthData.sleep.rem}h
- Heart Rate Variability (HRV): ${healthData.hrv.average} ms
- Resting Heart Rate: ${healthData.heartRate.resting} bpm
- Steps: ${healthData.activity.steps}
- Active Calories: ${healthData.activity.calories} kcal

WEATHER CONDITIONS:
- Temperature: ${weather.current.temperature_2m}°C
- Feels Like: ${weather.current.apparent_temperature}°C
- Humidity: ${weather.current.relative_humidity_2m}%
- UV Index: ${weather.daily.uv_index_max[0]}
- Precipitation: ${weather.current.precipitation}mm

Based on this data, provide comprehensive health advice in the following JSON structure:

{
  "theme": "Short theme for today (e.g., 'Recovery Day', 'Energy Boost Day')",
  "summary": "2-3 sentence overview of today's health status and main recommendations",
  "breakfast": {
    "recommendation": "Specific breakfast recommendation",
    "reason": "Why this is recommended based on the data",
    "examples": ["Example 1", "Example 2", "Example 3"]
  },
  "lunch": {
    "recommendation": "Lunch guidance",
    "timing": "Optimal lunch time",
    "avoid": ["Foods to avoid"]
  },
  "dinner": {
    "recommendation": "Dinner guidance",
    "timing": "Optimal dinner time"
  },
  "exercise": {
    "recommendation": "Exercise type and duration",
    "intensity": "Low/Moderate/High",
    "reason": "Why this exercise is suitable",
    "timing": "Best time to exercise",
    "avoid": ["Exercises to avoid today"]
  },
  "hydration": {
    "target": "Total water intake in liters",
    "schedule": {
      "morning": "Amount in ml",
      "afternoon": "Amount in ml",
      "evening": "Amount in ml"
    },
    "reason": "Why this hydration level is needed"
  },
  "breathing": {
    "technique": "Recommended breathing exercise",
    "duration": "How long to practice",
    "frequency": "How many times today",
    "instructions": ["Step 1", "Step 2", "Step 3"]
  },
  "sleep_preparation": {
    "bedtime": "Recommended bedtime",
    "routine": ["Activity 1", "Activity 2", "Activity 3"],
    "avoid": ["Things to avoid before bed"]
  },
  "weather_considerations": {
    "warnings": ["Weather-related precautions"],
    "opportunities": ["Weather-related opportunities"]
  },
  "priority_actions": [
    "Most important action 1",
    "Most important action 2",
    "Most important action 3"
  ]
}

Ensure all recommendations are specific, actionable, and tailored to the individual's data and conditions.
`
}
```

### 1.6 環境変数とデプロイ設定

**wrangler.toml:**
```toml
name = "tempo-ai-api"
main = "src/index.ts"
compatibility_date = "2024-12-04"
compatibility_flags = ["nodejs_compat"]

[vars]
# 公開環境変数（なし）

# シークレット環境変数は wrangler secret put で設定
# ANTHROPIC_API_KEY
```

**.dev.vars (ローカル開発用):**
```
ANTHROPIC_API_KEY=sk-ant-api03-xxxxx
```

---

## Stage 2: iOS アプリ基盤（Day 4-7）

### 2.1 Xcodeプロジェクト作成

```
プロジェクト設定:
- Product Name: TempoAI
- Team: Personal Team
- Organization Identifier: com.yourname
- Interface: SwiftUI
- Language: Swift
- Use Core Data: No
- Include Tests: Yes
- Minimum Deployments: iOS 16.0
```

### 2.2 プロジェクト構造

```
TempoAI/
├── App/
│   ├── TempoAIApp.swift
│   └── ContentView.swift
├── Models/
│   ├── HealthData.swift
│   ├── DailyAdvice.swift
│   └── UserProfile.swift
├── Services/
│   ├── HealthKitManager.swift
│   ├── APIClient.swift
│   ├── LocationManager.swift
│   └── NotificationManager.swift
├── Views/
│   ├── HomeView.swift
│   ├── AdviceDetailView.swift
│   ├── ProfileView.swift
│   └── Components/
│       ├── ThemeCard.swift
│       ├── AdviceCard.swift
│       └── LoadingView.swift
├── Utils/
│   └── Constants.swift
└── Info.plist
```

### 2.3 HealthKit統合

**Info.plist 権限追加:**
```xml
<key>NSHealthShareUsageDescription</key>
<string>Tempo AI needs access to your health data to provide personalized daily advice based on your sleep, heart rate, and activity.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>Tempo AI needs permission to save health insights.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Tempo AI needs your location to provide weather-based health recommendations.</string>
```

**HealthKitManager.swift:**
```swift
import HealthKit
import Foundation

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    // 読み取り権限を要求するデータタイプ
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        try await healthStore.requestAuthorization(
            toShare: [],
            read: readTypes
        )
        
        await MainActor.run {
            self.isAuthorized = true
        }
    }
    
    func fetchTodayHealthData() async throws -> HealthData {
        let sleepData = try await fetchSleepData()
        let hrvData = try await fetchHRVData()
        let heartRateData = try await fetchHeartRateData()
        let activityData = try await fetchActivityData()
        
        return HealthData(
            sleep: sleepData,
            hrv: hrvData,
            heartRate: heartRateData,
            activity: activityData,
            timestamp: Date()
        )
    }
    
    private func fetchSleepData() async throws -> SleepData {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let endDate = Date()
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
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // 睡眠データ解析ロジック
                let sleepData = self.analyzeSleepSamples(samples ?? [])
                continuation.resume(returning: sleepData)
            }
            
            healthStore.execute(query)
        }
    }
    
    // 他のfetchメソッドも同様に実装
}

enum HealthKitError: Error {
    case notAvailable
    case authorizationFailed
    case dataNotFound
}
```

### 2.4 API クライアント実装

**APIClient.swift:**
```swift
import Foundation
import CoreLocation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    
    init() {
        #if DEBUG
        self.baseURL = "http://localhost:8787/api"
        #else
        self.baseURL = "https://tempo-ai-api.workers.dev/api"
        #endif
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    func analyzeHealth(
        healthData: HealthData,
        location: CLLocation,
        userProfile: UserProfile
    ) async throws -> DailyAdvice {
        
        let endpoint = "\(baseURL)/health/analyze"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = AnalyzeRequest(
            healthData: healthData.toAPIModel(),
            location: LocationData(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            ),
            userProfile: userProfile.toAPIModel()
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let advice = try JSONDecoder().decode(DailyAdvice.self, from: data)
        return advice
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
```

### 2.5 メインUI実装

**HomeView.swift:**
```swift
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingDetail = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ヘッダー
                    HeaderView(userName: viewModel.userName)
                    
                    // ローディング状態
                    if viewModel.isLoading {
                        LoadingView()
                            .frame(height: 300)
                    }
                    // エラー状態
                    else if let error = viewModel.error {
                        ErrorView(error: error) {
                            Task {
                                await viewModel.refresh()
                            }
                        }
                    }
                    // アドバイス表示
                    else if let advice = viewModel.todayAdvice {
                        ThemeCard(theme: advice.theme, summary: advice.summary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 15) {
                            AdviceCard(
                                icon: "🍳",
                                title: "Breakfast",
                                content: advice.breakfast.recommendation
                            )
                            
                            AdviceCard(
                                icon: "💪",
                                title: "Exercise",
                                content: advice.exercise.recommendation
                            )
                            
                            AdviceCard(
                                icon: "💧",
                                title: "Hydration",
                                content: "Target: \(advice.hydration.target)L"
                            )
                            
                            AdviceCard(
                                icon: "🧘",
                                title: "Breathing",
                                content: advice.breathing.technique
                            )
                        }
                        .padding(.horizontal)
                        
                        Button(action: { showingDetail = true }) {
                            Text("View All Details")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showingDetail) {
                if let advice = viewModel.todayAdvice {
                    AdviceDetailView(advice: advice)
                }
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
    }
}
```

**HomeViewModel.swift:**
```swift
import SwiftUI
import CoreLocation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var todayAdvice: DailyAdvice?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let healthKitManager = HealthKitManager()
    private let locationManager = LocationManager()
    private let apiClient = APIClient.shared
    
    var userName: String {
        UserDefaults.standard.string(forKey: "userName") ?? "User"
    }
    
    func loadInitialData() async {
        guard todayAdvice == nil else { return }
        await refresh()
    }
    
    func refresh() async {
        isLoading = true
        error = nil
        
        do {
            // HealthKit権限リクエスト
            if !healthKitManager.isAuthorized {
                try await healthKitManager.requestAuthorization()
            }
            
            // 位置情報権限リクエスト
            let location = try await locationManager.requestLocation()
            
            // HealthKitデータ取得
            let healthData = try await healthKitManager.fetchTodayHealthData()
            
            // ユーザープロファイル取得
            let userProfile = UserProfile.loadFromDefaults()
            
            // API呼び出し
            let advice = try await apiClient.analyzeHealth(
                healthData: healthData,
                location: location,
                userProfile: userProfile
            )
            
            self.todayAdvice = advice
            
            // キャッシュに保存
            advice.saveToCache()
            
        } catch {
            self.error = error
            // キャッシュから読み込み試行
            if let cached = DailyAdvice.loadFromCache() {
                self.todayAdvice = cached
            }
        }
        
        isLoading = false
    }
}
```

---

## Stage 3: 統合とテスト（Day 8-10）

### 3.1 エンドツーエンドテスト

#### テスト項目
1. **API単体テスト**
   - ヘルスデータPOSTリクエスト
   - 天気API呼び出し
   - Claude API呼び出し
   - エラーハンドリング

2. **iOS単体テスト**
   - HealthKit権限リクエスト
   - データフェッチ
   - API通信
   - キャッシュ機能

3. **統合テスト**
   - 完全なデータフロー
   - エラーリカバリー
   - オフライン対応

### 3.2 デバッグツール

**API デバッグ:**
```bash
# ローカルテスト
curl -X POST http://localhost:8787/api/health/analyze \
  -H "Content-Type: application/json" \
  -d @test-data.json

# レスポンス確認
cat response.json | jq .
```

**iOS デバッグ:**
- Xcodeのネットワークインスペクタ
- HealthKitシミュレータデータ
- Console.appでログ確認

### 3.3 パフォーマンス最適化

#### API最適化
- 天気とAI呼び出しを並列化
- レスポンスキャッシュ（1時間）
- エラー時のフォールバック

#### iOS最適化
- HealthKitデータのバッチ取得
- 画像の遅延読み込み
- バックグラウンドリフレッシュ

---

## Stage 4: 通知とプロフィール（Day 11-14）

### 4.1 通知機能実装

**NotificationManager.swift:**
```swift
import UserNotifications

class NotificationManager: ObservableObject {
    @Published var isEnabled = false
    @Published var notificationTime = Date()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization() async throws {
        let settings = await notificationCenter.notificationSettings()
        
        if settings.authorizationStatus == .notDetermined {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            
            await MainActor.run {
                self.isEnabled = granted
            }
        }
    }
    
    func scheduleDailyNotification() {
        // 既存の通知をクリア
        notificationCenter.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Good morning! ☀️"
        content.body = getRandomMessage()
        content.sound = .default
        
        // 時刻設定
        var dateComponents = Calendar.current.dateComponents(
            [.hour, .minute],
            from: notificationTime
        )
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "daily-advice",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    private func getRandomMessage() -> String {
        let messages = [
            "Your daily health advice is ready!",
            "Check your personalized recommendations",
            "Let's optimize your day together",
            "Time to check your Tempo",
            "Your health insights are waiting"
        ]
        return messages.randomElement() ?? messages[0]
    }
}
```

### 4.2 プロフィール設定

**ProfileView.swift:**
```swift
struct ProfileView: View {
    @State private var profile = UserProfile.loadFromDefaults()
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    Picker("Age", selection: $profile.age) {
                        ForEach(18...100, id: \.self) { age in
                            Text("\(age) years").tag(age)
                        }
                    }
                    
                    Picker("Gender", selection: $profile.gender) {
                        Text("Male").tag("male")
                        Text("Female").tag("female")
                        Text("Other").tag("other")
                    }
                }
                
                Section("Goals") {
                    Toggle("Fatigue Recovery", isOn: binding(for: "fatigue_recovery"))
                    Toggle("Focus Enhancement", isOn: binding(for: "focus"))
                    Toggle("Weight Management", isOn: binding(for: "weight"))
                    Toggle("Better Sleep", isOn: binding(for: "sleep"))
                    Toggle("Stress Reduction", isOn: binding(for: "stress"))
                }
                
                Section("Dietary Preferences") {
                    TextField("e.g., Vegetarian, Gluten-free", 
                             text: $profile.dietaryPreferences)
                }
                
                Section("Exercise Habits") {
                    Picker("Frequency", selection: $profile.exerciseFrequency) {
                        Text("Sedentary").tag("sedentary")
                        Text("Light (1-2 days/week)").tag("light")
                        Text("Moderate (3-4 days/week)").tag("moderate")
                        Text("Active (5-6 days/week)").tag("active")
                        Text("Very Active (Daily)").tag("very_active")
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
            .alert("Profile Saved", isPresented: $showingSaveConfirmation) {
                Button("OK") { }
            }
        }
    }
    
    private func saveProfile() {
        profile.saveToDefaults()
        showingSaveConfirmation = true
    }
    
    private func binding(for goal: String) -> Binding<Bool> {
        Binding(
            get: { profile.goals.contains(goal) },
            set: { isOn in
                if isOn {
                    profile.goals.append(goal)
                } else {
                    profile.goals.removeAll { $0 == goal }
                }
            }
        )
    }
}
```

---

## 📊 成功指標とテスト基準

### 機能要件チェックリスト

#### API ✅
- [ ] `/health/analyze` エンドポイント動作
- [ ] 天気データ取得成功
- [ ] Claude APIレスポンス正常
- [ ] JSONパース成功
- [ ] エラーハンドリング
- [ ] 15秒以内にレスポンス

#### iOS App ✅
- [ ] HealthKit権限リクエスト
- [ ] 位置情報権限リクエスト
- [ ] HealthKitデータ取得
- [ ] API通信成功
- [ ] アドバイス表示
- [ ] Pull to Refresh動作
- [ ] エラー時の再試行
- [ ] オフライン時のキャッシュ表示

#### UX ✅
- [ ] 初回起動フロー完了
- [ ] ローディング表示
- [ ] エラーメッセージ表示
- [ ] 通知設定
- [ ] プロフィール保存

### パフォーマンス基準

- **API応答時間**: < 15秒（95パーセンタイル）
- **アプリ起動時間**: < 3秒
- **データ取得**: < 5秒
- **メモリ使用量**: < 100MB
- **クラッシュ率**: < 0.1%

### テストデバイス

- iPhone 15 Pro (iOS 17)
- iPhone 13 (iOS 16)
- iPhone SE 3rd (iOS 16)
- iPad (オプション)

---

## 🚀 デプロイ手順

### Cloudflare Workers デプロイ

```bash
# 1. シークレット設定
wrangler secret put ANTHROPIC_API_KEY
# プロンプトでAPIキーを入力

# 2. デプロイ実行
wrangler deploy

# 3. 確認
curl https://tempo-ai-api.YOUR_SUBDOMAIN.workers.dev/
# {"service":"Tempo AI API","version":"1.0.0","status":"healthy"}
```

### iOS TestFlight配布

1. **Xcode Archive作成**
   - Product → Archive
   - Validate App
   - Distribute App → App Store Connect

2. **App Store Connect設定**
   - TestFlightタブ
   - 内部テスター追加
   - ビルド承認

3. **テスター招待**
   - TestFlightリンク送信
   - フィードバック収集

---

## 🐛 既知の問題と対策

### 問題1: HealthKitデータが空
**原因**: シミュレータではHealthKitデータなし  
**対策**: 実機テストまたはモックデータ使用

### 問題2: API タイムアウト
**原因**: Claude API応答が遅い  
**対策**: タイムアウトを30秒に延長、キャッシュ活用

### 問題3: 位置情報取得失敗
**原因**: 権限拒否または設定OFF  
**対策**: デフォルト位置（東京）を使用

---

## 📝 Phase 1 完了条件

### 必須機能 ✅
- [x] HealthKitデータ取得
- [x] 天気API統合  
- [x] Claude API統合
- [x] ホーム画面表示
- [x] 詳細画面表示
- [x] 基本的なエラーハンドリング
- [x] 通知機能
- [x] プロフィール設定

### デモ可能な状態
1. アプリを起動
2. 権限を許可
3. ローディング表示
4. 今日のアドバイス表示
5. 詳細画面へ遷移
6. プロフィール編集
7. 通知設定

### 次のフェーズへの準備
- コードのリファクタリング
- テストカバレッジ80%以上
- ドキュメント更新
- Phase 2の計画作成

---

## 🎯 Phase 1 終了後の状態

**ユーザー体験:**
> 「アプリを開くと、私の睡眠データと今日の天気を考慮した、具体的な健康アドバイスが表示される。朝食の提案、運動のタイミング、水分補給の目標など、今日1日を最適に過ごすための具体的な行動指針が得られる。」

**技術的達成:**
- Cloudflare Workers APIが稼働
- iOS アプリがHealthKitと連携
- AIによる個別最適化されたアドバイス生成
- 基本的な通知とプロフィール機能

**ビジネス価値:**
- MVP完成（投資家にデモ可能）
- ユーザーテスト開始可能
- App Store申請準備（Phase 2で洗練後）

---

## 📚 参考資料

### ドキュメント
- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Hono Documentation](https://hono.dev/)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [Claude API Reference](https://docs.anthropic.com/claude/reference/getting-started-with-the-api)

### サンプルコード
- [Hono + Cloudflare Workers Example](https://github.com/honojs/hono/tree/main/examples/cloudflare-workers)
- [HealthKit Swift Samples](https://developer.apple.com/documentation/healthkit/samples)

### コミュニティ
- Cloudflare Discord
- iOS Dev Slack
- Hono GitHub Discussions

---

**作成者**: Development Team  
**最終更新**: 2024年12月4日  
**次回レビュー**: Phase 1完了時