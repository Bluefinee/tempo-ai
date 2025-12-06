# 🚀 Phase 1: MVP コア体験実装計画書

**最終更新**: 2025年12月5日  
**実装期間**: 3-4週間  
**対象**: 開発チーム  
**前提条件**: Phase 0完了（品質基盤・多言語化基盤構築済み）

---

## 📋 実装前必須準備

### 必須読み込みドキュメント

1. **[tempo-ai-product-spec.md](../tempo-ai-product-spec.md)** - プロダクト全体仕様
2. **[CLAUDE.md](../../CLAUDE.md)** - 開発ルール・品質基準・プロセス
3. **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift実装標準
4. **[TypeScript Hono Standards](../../.claude/typescript-hono-standards.md)** - Backend実装標準

### 品質基準

- **テストカバレッジ**: Backend ≥80%, iOS ≥80%
- **TDD必須**: Red → Green → Refactor → Integrate
- **小さなコミット**: 機能単位での頻繁なコミット
- **継続的品質確認**: 各実装後に必ず品質チェック実行

---

## 🎯 Phase 1 実装目標

### コア機能

✅ **美麗オンボーディングフロー** (4ページ)  
✅ **メインホーム画面** (挨拶・ステータス・アドバイス表示)  
✅ **カラーコード化ヘルスステータス** (4段階分析)  
✅ **AI アドバイス生成エンジン** (HealthKit + 環境 + Claude API)  
✅ **環境対応アラート** (気温・天気ベース)  
✅ **基本5タブナビゲーション** (プレースホルダー含む)  

### 技術目標

- **パフォーマンス**: アドバイス生成 ≤5秒、画面遷移 ≤1秒
- **多言語**: 日英完全対応（リソース実装済み）
- **エラーハンドリング**: 全API呼び出しでの適切なエラー処理

---

## 🏗️ 実装段階

## Stage 1: オンボーディングフロー実装 (4日)

**目標**: 美麗な4ページオンボーディング体験を提供

### 1.1 基本構造実装

```swift
// ios/TempoAI/TempoAI/Views/Onboarding/OnboardingFlowView.swift
struct OnboardingFlowView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            WelcomePageView().tag(0)
            HealthKitPermissionPageView().tag(1) 
            LocationPermissionPageView().tag(2)
            CompletionPageView().tag(3)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onAppear { viewModel.trackOnboardingStart() }
    }
}
```

**実装ファイル**:
- `Views/Onboarding/OnboardingFlowView.swift`
- `Views/Onboarding/WelcomePageView.swift`
- `Views/Onboarding/HealthKitPermissionPageView.swift`
- `Views/Onboarding/LocationPermissionPageView.swift`
- `Views/Onboarding/CompletionPageView.swift`
- `ViewModels/OnboardingViewModel.swift`

**コミットポイント**: `feat: implement basic onboarding flow structure`

### 1.2 権限管理システム

```swift
// ios/TempoAI/TempoAI/Services/PermissionManager.swift
class PermissionManager: ObservableObject {
    @Published var healthKitStatus: PermissionStatus = .notDetermined
    @Published var locationStatus: PermissionStatus = .notDetermined

    func requestHealthKitPermission() async -> PermissionStatus {
        // HealthKit読み取り権限要求
        let types: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!
        ]
        
        let success = await healthStore.requestAuthorization(toShare: [], read: types)
        let status: PermissionStatus = success ? .granted : .denied
        
        await MainActor.run {
            self.healthKitStatus = status
        }
        return status
    }
    
    func requestLocationPermission() async -> PermissionStatus {
        // 位置情報権限要求（天気データ取得用）
        locationManager.requestWhenInUseAuthorization()
        return await withUnsafeContinuation { continuation in
            locationDelegate.completionHandler = { status in
                continuation.resume(returning: status)
            }
        }
    }
}

enum PermissionStatus {
    case notDetermined, granted, denied, restricted
}
```

**コミットポイント**: `feat: implement permission management system`

### 1.3 TDD テスト実装

```swift
// ios/TempoAI/TempoAITests/Onboarding/OnboardingFlowTests.swift
class OnboardingFlowTests: XCTestCase {
    var viewModel: OnboardingViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = OnboardingViewModel()
    }
    
    func testOnboardingPageProgression() {
        // 初期ページ確認
        XCTAssertEqual(viewModel.currentPage, 0)
        
        // ページ遷移テスト
        viewModel.nextPage()
        XCTAssertEqual(viewModel.currentPage, 1)
        
        viewModel.nextPage()
        XCTAssertEqual(viewModel.currentPage, 2)
        
        viewModel.nextPage()
        XCTAssertEqual(viewModel.currentPage, 3)
    }
    
    func testOnboardingCompletion() async {
        let expectation = expectation(description: "Onboarding completion")
        
        await viewModel.completeOnboarding()
        XCTAssertTrue(viewModel.isOnboardingCompleted)
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 2.0)
    }
}
```

**コミットポイント**: `test: add onboarding flow tests`

**Stage 1成功基準**:
- [ ] 4ページオンボーディングフローが動作
- [ ] HealthKit・位置情報権限取得機能
- [ ] オンボーディング完了状態の永続化
- [ ] テストカバレッジ ≥80%

---

## Stage 2: ヘルスステータス分析エンジン (3日)

**目標**: HealthKitデータから4段階ヘルスステータスを判定

### 2.1 ヘルスステータス分析エンジン

```swift
// ios/TempoAI/TempoAI/Services/HealthStatusAnalyzer.swift
class HealthStatusAnalyzer: ObservableObject {
    @Published var currentStatus: HealthStatus = .unknown
    
    func analyzeHealthStatus(from healthData: HealthKitData) async -> HealthStatus {
        let hrvScore = analyzeHRV(healthData.hrv)
        let sleepScore = analyzeSleep(healthData.sleep)
        let activityScore = analyzeActivity(healthData.activity)
        let heartRateScore = analyzeHeartRate(healthData.heartRate)
        
        return calculateOverallStatus(
            hrv: hrvScore,
            sleep: sleepScore, 
            activity: activityScore,
            heartRate: heartRateScore
        )
    }
    
    private func analyzeHRV(_ data: HRVData?) -> Double {
        guard let hrv = data?.averageHRV else { return 0.5 }
        
        // 年齢別HRV基準値との比較
        let ageBasedNorm = getAgeBasedHRVNorm(age: data?.userAge ?? 30)
        let score = hrv / ageBasedNorm
        return min(max(score, 0.0), 1.0)
    }
    
    private func analyzeSleep(_ data: SleepData?) -> Double {
        guard let sleep = data else { return 0.5 }
        
        let durationScore = min(sleep.duration / 8.0, 1.0) // 8時間を理想とする
        let efficiencyScore = sleep.efficiency
        let deepSleepScore = sleep.deepSleepPercentage / 0.25 // 25%を理想
        
        return (durationScore + efficiencyScore + deepSleepScore) / 3.0
    }
    
    private func calculateOverallStatus(
        hrv: Double,
        sleep: Double, 
        activity: Double,
        heartRate: Double
    ) -> HealthStatus {
        let average = (hrv + sleep + activity + heartRate) / 4.0
        
        switch average {
        case 0.8...1.0: return .optimal    // 🟢 絶好調
        case 0.6..<0.8: return .good       // 🟡 良好  
        case 0.4..<0.6: return .care       // 🟠 ケアモード
        default: return .rest              // 🔴 休息モード
        }
    }
}

enum HealthStatus: String, CaseIterable {
    case optimal = "optimal"    // 🟢 絶好調
    case good = "good"         // 🟡 良好
    case care = "care"         // 🟠 ケアモード  
    case rest = "rest"         // 🔴 休息モード
    case unknown = "unknown"   // ⚪ 分析中

    var color: Color {
        switch self {
        case .optimal: return .green
        case .good: return .yellow
        case .care: return .orange
        case .rest: return .red
        case .unknown: return .gray
        }
    }
    
    var emoji: String {
        switch self {
        case .optimal: return "🟢"
        case .good: return "🟡"
        case .care: return "🟠"
        case .rest: return "🔴"
        case .unknown: return "⚪"
        }
    }

    var localizedTitle: String {
        NSLocalizedString("health_status_\(rawValue)", comment: "")
    }
    
    var localizedDescription: String {
        NSLocalizedString("health_status_\(rawValue)_description", comment: "")
    }
}
```

**コミットポイント**: `feat: implement health status analysis engine`

### 2.2 HealthKitデータ収集サービス

```swift
// ios/TempoAI/TempoAI/Services/HealthKitService.swift
class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    
    func fetchTodaysHealthData() async throws -> HealthKitData {
        async let hrv = fetchHRVData()
        async let sleep = fetchSleepData()
        async let activity = fetchActivityData()
        async let heartRate = fetchHeartRateData()
        
        return HealthKitData(
            hrv: try await hrv,
            sleep: try await sleep,
            activity: try await activity,
            heartRate: try await heartRate,
            timestamp: Date()
        )
    }
    
    private func fetchHRVData() async throws -> HRVData? {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date()
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result,
                         let average = result.averageQuantity() {
                    let hrvValue = average.doubleValue(for: .secondUnit(with: .milli))
                    continuation.resume(returning: HRVData(averageHRV: hrvValue))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            healthStore.execute(query)
        }
    }
}
```

**コミットポイント**: `feat: implement HealthKit data collection service`

### 2.3 テスト実装

```swift
// ios/TempoAI/TempoAITests/Services/HealthStatusAnalyzerTests.swift
class HealthStatusAnalyzerTests: XCTestCase {
    var analyzer: HealthStatusAnalyzer!
    
    override func setUp() {
        analyzer = HealthStatusAnalyzer()
    }
    
    func testOptimalHealthStatus() async {
        let mockData = HealthKitData(
            hrv: HRVData(averageHRV: 55.0),
            sleep: SleepData(duration: 8.5, efficiency: 0.95, deepSleepPercentage: 0.25),
            activity: ActivityData(steps: 12000, calories: 2400),
            heartRate: HeartRateData(resting: 58, average: 75),
            timestamp: Date()
        )
        
        let status = await analyzer.analyzeHealthStatus(from: mockData)
        XCTAssertEqual(status, .optimal)
    }
    
    func testCareHealthStatus() async {
        let mockData = HealthKitData(
            hrv: HRVData(averageHRV: 25.0),
            sleep: SleepData(duration: 5.5, efficiency: 0.75, deepSleepPercentage: 0.15),
            activity: ActivityData(steps: 4000, calories: 1800),
            heartRate: HeartRateData(resting: 68, average: 85),
            timestamp: Date()
        )
        
        let status = await analyzer.analyzeHealthStatus(from: mockData)
        XCTAssertEqual(status, .care)
    }
}
```

**コミットポイント**: `test: add health status analyzer tests`

**Stage 2成功基準**:
- [ ] 4段階ヘルスステータス判定機能
- [ ] HealthKitデータ収集・分析機能
- [ ] 年齢別・個人別基準値対応
- [ ] テストカバレッジ ≥80%

---

## Stage 3: AI アドバイス生成エンジン (5日)

**目標**: HealthKit + 環境データからパーソナライズアドバイス生成

### 3.1 Backend - アドバイス生成サービス

```typescript
// backend/src/services/advice-generation.ts
export interface DailyAdviceRequest {
  userProfile: UserProfile;
  healthData: HealthStatusData;
  environmentData: EnvironmentData;
  language: "en" | "ja";
  timezone: string;
}

export interface DailyAdvice {
  theme: "optimal" | "care" | "recovery";
  summary: string;
  greeting: string;
  meal_plan: {
    breakfast: string;
    lunch: string;  
    dinner: string;
    timing_notes: string;
  };
  exercise_plan: {
    type: string;
    duration: string;
    intensity: string;
    timing: string;
  };
  wellness_plan: {
    recovery: string;
    mindfulness: string;
    hydration: string;
  };
  environmental_considerations: EnvironmentConsideration[];
  confidence_score: number;
  generated_at: string;
}

export const generateDailyAdvice = async (
  request: DailyAdviceRequest
): Promise<DailyAdvice> => {
  // プロンプト構築
  const prompt = buildAdvicePrompt(request);
  
  // Claude API呼び出し
  const rawAdvice = await claudeService.generateAdvice(prompt, request.language);
  
  // レスポンス構造化
  const structuredAdvice = parseAdviceResponse(rawAdvice);
  
  // 環境考慮事項追加
  const environmentConsiderations = generateEnvironmentConsiderations(
    request.environmentData,
    request.healthData.status
  );

  return {
    ...structuredAdvice,
    environmental_considerations: environmentConsiderations,
    greeting: generatePersonalizedGreeting(
      request.userProfile,
      request.environmentData,
      request.healthData.status,
      request.language
    ),
    confidence_score: calculateConfidenceScore(request),
    generated_at: new Date().toISOString(),
  };
};

const buildAdvicePrompt = (request: DailyAdviceRequest): string => {
  const { healthData, environmentData, userProfile, language } = request;
  
  return `
あなたは世界最高のパーソナルヘルスケアアドバイザーです。以下のデータに基づいて、今日一日の最適な健康アドバイスを${language === 'ja' ? '日本語' : '英語'}で提供してください。

## ユーザー健康状態
- 現在のステータス: ${healthData.status}
- HRV: ${healthData.hrv}ms
- 睡眠: ${healthData.sleep.duration}時間 (効率: ${healthData.sleep.efficiency}%)
- 心拍数: 安静時${healthData.heartRate.resting}bpm
- 活動量: ${healthData.activity.steps}歩

## 環境情報  
- 天気: ${environmentData.weather.condition}
- 気温: ${environmentData.weather.temperature}°C
- 湿度: ${environmentData.weather.humidity}%
- 気圧: ${environmentData.weather.pressure}hPa

## ユーザープロファイル
- 年齢: ${userProfile.age}歳
- 性別: ${userProfile.gender}
- 活動レベル: ${userProfile.activityLevel}

以下のJSON形式で回答してください:
{
  "theme": "optimal|care|recovery",
  "summary": "今日の総合的なアドバイス（2-3文）",
  "meal_plan": {
    "breakfast": "朝食の具体的提案",
    "lunch": "昼食の具体的提案", 
    "dinner": "夕食の具体的提案",
    "timing_notes": "食事タイミングのアドバイス"
  },
  "exercise_plan": {
    "type": "推奨運動の種類",
    "duration": "運動時間",
    "intensity": "運動強度", 
    "timing": "最適なタイミング"
  },
  "wellness_plan": {
    "recovery": "回復・休息のアドバイス",
    "mindfulness": "メンタルヘルスのアドバイス",
    "hydration": "水分補給のアドバイス"
  }
}
`;
};
```

**コミットポイント**: `feat: implement advice generation service`

### 3.2 iOS - アドバイス表示・管理

```swift
// ios/TempoAI/TempoAI/Services/AdviceService.swift
class AdviceService: ObservableObject {
    @Published var todaysAdvice: DailyAdvice?
    @Published var isLoading = false
    @Published var lastError: Error?
    
    private let backendService = BackendService()
    
    func generateTodaysAdvice(
        healthData: HealthKitData,
        environmentData: EnvironmentData
    ) async {
        await MainActor.run {
            isLoading = true
            lastError = nil
        }
        
        do {
            let request = DailyAdviceRequest(
                userProfile: UserProfileManager.shared.currentProfile,
                healthData: healthData.toHealthStatusData(),
                environmentData: environmentData,
                language: LocalizationManager.shared.currentLanguage,
                timezone: TimeZone.current.identifier
            )
            
            let advice = try await backendService.generateAdvice(request)
            
            await MainActor.run {
                self.todaysAdvice = advice
                self.isLoading = false
                
                // キャッシュ保存
                AdviceCache.shared.save(advice, for: Date())
            }
        } catch {
            await MainActor.run {
                self.lastError = error
                self.isLoading = false
            }
        }
    }
}

struct DailyAdvice: Codable, Identifiable {
    let id = UUID()
    let theme: AdviceTheme
    let summary: String
    let greeting: String
    let mealPlan: MealPlan
    let exercisePlan: ExercisePlan
    let wellnessPlan: WellnessPlan
    let environmentalConsiderations: [EnvironmentConsideration]
    let confidenceScore: Double
    let generatedAt: Date
}
```

**コミットポイント**: `feat: implement advice service for iOS`

### 3.3 テスト実装

```typescript
// backend/tests/services/advice-generation.test.ts
describe("Advice Generation Service", () => {
  it("should generate optimal advice for excellent health metrics", async () => {
    const mockRequest: DailyAdviceRequest = {
      userProfile: { age: 30, gender: "male", activityLevel: "active" },
      healthData: {
        status: "optimal",
        hrv: { average: 55, trend: "stable" },
        sleep: { duration: 8.5, efficiency: 0.95, deep: 2.2, rem: 1.8 },
        heartRate: { resting: 58, average: 75 },
        activity: { steps: 12000, calories: 2400 }
      },
      environmentData: {
        weather: { condition: "sunny", temperature: 22, humidity: 60, pressure: 1013 },
        airQuality: { index: 25, category: "good" }
      },
      language: "en",
      timezone: "Asia/Tokyo"
    };

    const advice = await generateDailyAdvice(mockRequest);
    
    expect(advice.theme).toBe("optimal");
    expect(advice.summary).toBeDefined();
    expect(advice.meal_plan).toBeDefined();
    expect(advice.exercise_plan).toBeDefined();
    expect(advice.confidence_score).toBeGreaterThan(0.7);
  });

  it("should generate care advice for poor health metrics", async () => {
    const mockRequest: DailyAdviceRequest = {
      userProfile: { age: 35, gender: "female", activityLevel: "low" },
      healthData: {
        status: "care",
        hrv: { average: 25, trend: "declining" },
        sleep: { duration: 5.5, efficiency: 0.75, deep: 1.0, rem: 1.2 },
        heartRate: { resting: 68, average: 85 },
        activity: { steps: 4000, calories: 1800 }
      },
      environmentData: {
        weather: { condition: "rainy", temperature: 15, humidity: 80, pressure: 995 },
        airQuality: { index: 65, category: "moderate" }
      },
      language: "ja",
      timezone: "Asia/Tokyo"
    };

    const advice = await generateDailyAdvice(mockRequest);
    
    expect(advice.theme).toBe("care");
    expect(advice.exercise_plan.intensity).toMatch(/low|gentle|light/i);
    expect(advice.wellness_plan.recovery).toBeDefined();
  });
});
```

**コミットポイント**: `test: add comprehensive advice generation tests`

**Stage 3成功基準**:
- [ ] HealthKit + 環境データ統合アドバイス生成
- [ ] 多言語対応（日英）アドバイス
- [ ] 4段階ヘルスステータス別最適化
- [ ] エラーハンドリングと再試行機構
- [ ] テストカバレッジ ≥80%

---

## Stage 4: ホーム画面実装 (4日)

**目標**: パーソナライズされたメイン体験画面を提供

### 4.1 ホーム画面UI実装

```swift
// ios/TempoAI/TempoAI/Views/Home/HomeView.swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingAdviceDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // パーソナライズ挨拶
                    GreetingCardView(
                        greeting: viewModel.personalizedGreeting,
                        healthStatus: viewModel.healthStatus
                    )
                    
                    // ヘルスステータス表示
                    HealthStatusCardView(
                        status: viewModel.healthStatus,
                        analysis: viewModel.healthAnalysis,
                        onTap: { showingAdviceDetail = true }
                    )
                    
                    // 環境アラート（必要時のみ）
                    if !viewModel.environmentAlerts.isEmpty {
                        EnvironmentAlertsView(alerts: viewModel.environmentAlerts)
                    }
                    
                    // 今日のアドバイスサマリー
                    AdviceSummaryCardView(
                        advice: viewModel.todaysAdvice,
                        onViewDetails: { showingAdviceDetail = true }
                    )
                    
                    // クイックアクション
                    QuickActionsView(
                        actions: viewModel.availableActions,
                        onActionTap: viewModel.handleQuickAction
                    )
                }
                .padding()
            }
            .navigationTitle("home_title")
            .refreshable { 
                await viewModel.refreshData() 
            }
        }
        .sheet(isPresented: $showingAdviceDetail) {
            AdviceDetailView(advice: viewModel.todaysAdvice)
        }
        .task { 
            await viewModel.loadInitialData() 
        }
    }
}
```

**コミットポイント**: `feat: implement home screen UI`

### 4.2 HomeViewModel実装

```swift
// ios/TempoAI/TempoAI/ViewModels/HomeViewModel.swift
@MainActor
class HomeViewModel: ObservableObject {
    @Published var healthStatus: HealthStatus = .unknown
    @Published var healthAnalysis: HealthAnalysis?
    @Published var todaysAdvice: DailyAdvice?
    @Published var environmentAlerts: [EnvironmentAlert] = []
    @Published var personalizedGreeting: String = ""
    @Published var isLoading = false
    @Published var lastError: Error?
    
    private let healthKitService = HealthKitService()
    private let healthAnalyzer = HealthStatusAnalyzer()
    private let adviceService = AdviceService()
    private let environmentService = EnvironmentService()
    private let greetingService = GreetingService()
    
    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 並列データ取得
            async let healthData = healthKitService.fetchTodaysHealthData()
            async let environmentData = environmentService.fetchCurrentEnvironment()
            
            let health = try await healthData
            let environment = try await environmentData
            
            // ヘルスステータス分析
            healthStatus = await healthAnalyzer.analyzeHealthStatus(from: health)
            healthAnalysis = await healthAnalyzer.generateAnalysis(from: health)
            
            // パーソナライズ挨拶生成
            personalizedGreeting = greetingService.generateGreeting(
                healthStatus: healthStatus,
                environment: environment,
                timeOfDay: Calendar.current.component(.hour, from: Date())
            )
            
            // 環境アラート生成
            environmentAlerts = generateEnvironmentAlerts(
                environment: environment,
                healthStatus: healthStatus
            )
            
            // AIアドバイス生成
            await adviceService.generateTodaysAdvice(
                healthData: health,
                environmentData: environment
            )
            todaysAdvice = adviceService.todaysAdvice
            
        } catch {
            lastError = error
            Logger.health.error("Failed to load home data: \(error.localizedDescription)")
        }
    }
    
    func refreshData() async {
        await loadInitialData()
    }
    
    func handleQuickAction(_ action: QuickAction) {
        switch action {
        case .refreshAdvice:
            Task { await adviceService.regenerateAdvice() }
        case .viewHealthTrends:
            // 健康トレンド画面へ遷移
            break
        case .updateProfile:
            // プロファイル更新画面へ遷移
            break
        }
    }
}
```

**コミットポイント**: `feat: implement home view model with data integration`

### 4.3 UI コンポーネント実装

```swift
// ios/TempoAI/TempoAI/Views/Home/Components/HealthStatusCardView.swift
struct HealthStatusCardView: View {
    let status: HealthStatus
    let analysis: HealthAnalysis?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(status.emoji)
                        .font(.title)
                    
                    VStack(alignment: .leading) {
                        Text(status.localizedTitle)
                            .font(.headline)
                            .foregroundColor(status.color)
                        
                        Text(status.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                
                if let analysis = analysis {
                    HealthMetricsRow(analysis: analysis)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(status.color.opacity(0.1))
                    .stroke(status.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

**コミットポイント**: `feat: implement health status card component`

### 4.4 テスト実装

```swift
// ios/TempoAI/TempoAITests/ViewModels/HomeViewModelTests.swift
@MainActor
class HomeViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var mockHealthKitService: MockHealthKitService!
    var mockAdviceService: MockAdviceService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        mockHealthKitService = MockHealthKitService()
        mockAdviceService = MockAdviceService()
        
        viewModel = HomeViewModel(
            healthKitService: mockHealthKitService,
            adviceService: mockAdviceService
        )
    }
    
    func testLoadInitialDataSuccess() async {
        // Mock データ設定
        mockHealthKitService.mockHealthData = createMockHealthData()
        mockAdviceService.mockAdvice = createMockAdvice()
        
        await viewModel.loadInitialData()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.lastError)
        XCTAssertNotEqual(viewModel.healthStatus, .unknown)
        XCTAssertNotNil(viewModel.todaysAdvice)
        XCTAssertFalse(viewModel.personalizedGreeting.isEmpty)
    }
    
    func testLoadInitialDataError() async {
        // Mock エラー設定
        mockHealthKitService.shouldThrowError = true
        
        await viewModel.loadInitialData()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.lastError)
    }
}
```

**コミットポイント**: `test: add home view model tests`

**Stage 4成功基準**:
- [ ] パーソナライズされたホーム画面表示
- [ ] リアルタイムヘルスステータス表示
- [ ] アドバイスサマリー・詳細表示
- [ ] プルリフレッシュ機能
- [ ] テストカバレッジ ≥80%

---

## Stage 5: 環境アラート統合 (2日)

**目標**: 気温・天気・気圧に基づく健康アラート機能

### 5.1 環境アラートサービス

```typescript
// backend/src/services/environment-alert.ts
export interface EnvironmentAlert {
  id: string;
  type: "temperature" | "weather" | "air_quality" | "pressure";
  severity: "info" | "warning" | "danger";
  title: string;
  message: string;
  actionable_advice: string;
  icon: string;
  color: string;
}

export const generateEnvironmentAlerts = (
  environmentData: EnvironmentData,
  healthStatus: HealthStatus,
  userProfile: UserProfile
): EnvironmentAlert[] => {
  const alerts: EnvironmentAlert[] = [];
  
  // 極端な気温アラート
  if (environmentData.weather.temperature > 30) {
    alerts.push({
      id: generateId(),
      type: "temperature",
      severity: healthStatus === "rest" ? "danger" : "warning",
      title: "暑さ注意",
      message: `気温が${environmentData.weather.temperature}°Cです`,
      actionable_advice: "こまめな水分補給と涼しい場所での休息を心がけましょう。外出時は帽子や日傘をお忘れなく。",
      icon: "thermometer.sun.fill",
      color: "#FF6B6B"
    });
  }
  
  if (environmentData.weather.temperature < 5) {
    alerts.push({
      id: generateId(),
      type: "temperature", 
      severity: healthStatus === "rest" ? "danger" : "warning",
      title: "寒さ注意",
      message: `気温が${environmentData.weather.temperature}°Cです`,
      actionable_advice: "体を温める飲み物を摂取し、適切な防寒対策をしましょう。特に首、手首、足首を温めることが重要です。",
      icon: "thermometer.snowflake",
      color: "#4ECDC4"
    });
  }
  
  // 気圧変動アラート（頭痛・関節痛の原因）
  if (environmentData.weather.pressure < 1005) {
    alerts.push({
      id: generateId(),
      type: "pressure",
      severity: "info",
      title: "低気圧接近",
      message: `気圧が${environmentData.weather.pressure}hPaに下降しています`,
      actionable_advice: "気圧病による頭痛や関節痛が起こりやすい状況です。温かい飲み物を摂り、軽いストレッチで血行を促進しましょう。",
      icon: "barometer",
      color: "#95E1D3"
    });
  }
  
  // 悪天候アラート
  if (["rainy", "stormy", "snow"].includes(environmentData.weather.condition)) {
    alerts.push({
      id: generateId(),
      type: "weather",
      severity: "info", 
      title: "悪天候注意",
      message: `${environmentData.weather.condition}の天候です`,
      actionable_advice: "室内で行える軽い運動やストレッチを取り入れましょう。ビタミンDを意識した食事もおすすめです。",
      icon: "cloud.rain.fill",
      color: "#A8E6CF"
    });
  }
  
  return alerts;
};
```

**コミットポイント**: `feat: implement environment alert generation`

### 5.2 iOS環境アラート表示

```swift
// ios/TempoAI/TempoAI/Views/Home/Components/EnvironmentAlertsView.swift
struct EnvironmentAlertsView: View {
    let alerts: [EnvironmentAlert]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("environment_alerts_title")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(alerts) { alert in
                EnvironmentAlertCard(alert: alert)
            }
        }
    }
}

struct EnvironmentAlertCard: View {
    let alert: EnvironmentAlert
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: alert.icon)
                    .foregroundColor(Color(alert.color))
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text(alert.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(alert.message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                Text(alert.actionableAdvice)
                    .font(.caption)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(alert.color).opacity(0.1))
                .stroke(Color(alert.color).opacity(0.3), lineWidth: 1)
        )
    }
}
```

**コミットポイント**: `feat: implement environment alerts UI`

**Stage 5成功基準**:
- [ ] 気温・天気・気圧ベースアラート機能
- [ ] ヘルスステータス別アラート調整
- [ ] 実行可能なアドバイス提示
- [ ] 展開可能なアラートカードUI

---

## Stage 6: 基本ナビゲーション実装 (2日)

**目標**: 5タブ構造の基本ナビゲーション

### 6.1 メインタブビュー

```swift
// ios/TempoAI/TempoAI/Views/MainTabView.swift
struct MainTabView: View {
    @State private var selectedTab: Tab = .today
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == .today ? "house.fill" : "house")
                    Text("tab_today")
                }
                .tag(Tab.today)
            
            PlaceholderView(
                feature: "history",
                description: "Your health trends and advice history",
                icon: "calendar"
            )
            .tabItem {
                Image(systemName: selectedTab == .history ? "calendar" : "calendar")
                Text("tab_history")
            }
            .tag(Tab.history)
            
            PlaceholderView(
                feature: "insights",
                description: "Personalized health insights and learning",
                icon: "brain.head.profile"
            )
            .tabItem {
                Image(systemName: selectedTab == .insights ? "brain.head.profile.fill" : "brain.head.profile")
                Text("tab_insights")
            }
            .tag(Tab.insights)
            
            PlaceholderView(
                feature: "connect",
                description: "Social features and health sharing",
                icon: "person.2"
            )
            .tabItem {
                Image(systemName: selectedTab == .connect ? "person.2.fill" : "person.2")
                Text("tab_connect")
            }
            .tag(Tab.connect)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == .settings ? "gear" : "gear")
                    Text("tab_settings")
                }
                .tag(Tab.settings)
        }
        .accentColor(.primary)
    }
}

enum Tab: String, CaseIterable {
    case today = "today"
    case history = "history"  
    case insights = "insights"
    case connect = "connect"
    case settings = "settings"
    
    var localizedTitle: String {
        NSLocalizedString("tab_\(rawValue)", comment: "")
    }
}
```

**コミットポイント**: `feat: implement main tab navigation`

### 6.2 プレースホルダービュー

```swift
// ios/TempoAI/TempoAI/Views/Common/PlaceholderView.swift
struct PlaceholderView: View {
    let feature: String
    let description: String
    let icon: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: icon)
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    Text("feature_coming_soon")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Text("planned_phase_2")
                    .font(.caption)
                    .foregroundColor(.tertiary)
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle(feature.capitalized)
        }
    }
}
```

**コミットポイント**: `feat: implement placeholder views for future features`

**Stage 6成功基準**:
- [ ] 5タブナビゲーション構造
- [ ] アクティブ状態のビジュアル表現
- [ ] 将来機能のプレースホルダー
- [ ] ローカライズ対応タブタイトル

---

## 📋 最終統合・テスト (3日)

### 統合テスト実行

```bash
# iOS統合テスト
cd ios && swift test --parallel

# Backend統合テスト  
cd backend && pnpm run test

# E2Eテスト
cd ios && xcodebuild test -scheme TempoAI-UITests
```

### パフォーマンステスト

```swift
// ios/TempoAI/TempoAITests/Performance/PerformanceTests.swift
class PerformanceTests: XCTestCase {
    func testAdviceGenerationPerformance() {
        measure {
            let expectation = expectation(description: "Advice generation")
            
            Task {
                await AdviceService().generateTodaysAdvice(
                    healthData: MockHealthData.optimal,
                    environmentData: MockEnvironmentData.normal
                )
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0) // ≤5秒要件
        }
    }
    
    func testHomeScreenLoadPerformance() {
        measure {
            let viewModel = HomeViewModel()
            let expectation = expectation(description: "Home load")
            
            Task {
                await viewModel.loadInitialData()
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0) // ≤1秒要件
        }
    }
}
```

**最終コミット**: `feat: complete Phase 1 MVP core experience`

---

## 🎯 Phase 1 完了基準

### 機能完了チェックリスト

- [ ] **オンボーディングフロー**: 4ページ完全動作
- [ ] **ホーム画面**: パーソナライズ表示完全動作
- [ ] **ヘルスステータス分析**: 4段階判定精度確認
- [ ] **AIアドバイス生成**: 5秒以内レスポンス確認
- [ ] **環境アラート**: 適切なトリガー動作確認
- [ ] **基本ナビゲーション**: 5タブ構造完全動作

### 品質完了チェックリスト

- [ ] **テストカバレッジ**: iOS ≥80%, Backend ≥80%
- [ ] **パフォーマンス**: アドバイス生成 ≤5秒, 画面遷移 ≤1秒
- [ ] **多言語対応**: 日英切り替え完全動作
- [ ] **エラーハンドリング**: 全シナリオでの適切な処理
- [ ] **開発ルール準拠**: CLAUDE.md + コーディング標準準拠

### デプロイ完了チェックリスト

- [ ] **開発環境**: TestFlight配布準備
- [ ] **Backend環境**: 本番環境デプロイ準備
- [ ] **監視設定**: エラー監視・パフォーマンス監視設定
- [ ] **ドキュメント**: APIドキュメント更新

---

## 🚀 Phase 2への引き継ぎ

Phase 1完了により以下が利用可能になります：

### 実装済み基盤
- **安定したコアアドバイス機能** - HealthKit統合・AI生成・表示
- **堅牢な権限管理・データ収集基盤** - HealthKit・位置情報
- **品質担保されたUI/UXパターン** - カード型・カラーコード化
- **多言語対応基盤** - 日英完全対応

### Phase 2 拡張予定機能
- **朝のクイックチェックイン機能** - 主観的データでアドバイス再調整
- **詳細教育的アドバイス画面** - インタラクティブ・理由説明
- **文化適応システム** - 地域食材・季節対応
- **拡張環境アラート** - 気圧病・花粉・大気質

**🎉 Phase 1完了により、ユーザーは毎朝パーソナライズされた健康アドバイスを受け取り、データドリブンなヘルスケア体験を開始できます！**