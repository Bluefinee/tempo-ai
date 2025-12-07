# Phase 1: デジタルコックピット実装計画

## 🎯 Goal: "The Digital Cockpit" - 答えファースト UI 実装

**Philosophy**: UX 心理学原則に基づく認知負荷最小化 UI + ヒューマンバッテリーコンセプトの完全実装

## 📚 必読リファレンス

### 開発標準

- [CLAUDE.md](../../../CLAUDE.md) - 開発哲学、プロセス、品質基準
- [Swift Coding Standards](../../../.claude/swift-coding-standards.md) - Swift 実装ルール
- [UX Concepts](../../../.claude/ux_concepts.md) - **🔥 特に重要**: 心理学原則
- [Messaging Guidelines](../../../.claude/messaging_guidelines.md) - ヘルス表現指針

### 仕様書

- [Product Spec](../../tempo-ai-product-spec.md) - プロダクト全体像
- [Technical Spec](../../tempo-ai-technical-spec.md) - 技術アーキテクチャ
- [Phase 1 Dev Plan](../../development-plans/phase-1.md) - フェーズ 1 要件

## 🗂️ 実装ステージ

### Stage 1.0: オンボーディングフロー実装 (2日)

#### 1.0.1 オンボーディング基盤
**ファイル**: `Views/Onboarding/OnboardingCoordinator.swift`

**UXコンセプト適用**:
- **Progressive Disclosure**: 段階的な情報開示で認知負荷軽減
- **Peak-End Rule**: 最終画面で達成感演出
- **Mere Exposure Effect**: ブランド要素の反復露出

```swift
enum OnboardingPage: Int, CaseIterable {
    case welcome = 0        // コンセプト提示
    case userMode = 1       // Standard/Athlete選択
    case focusTags = 2      // 関心タグ選択
    case healthPermission = 3  // HealthKit許可
    case locationPermission = 4 // Location許可
    case completion = 5     // 完了・祝福
    
    var title: String {
        switch self {
        case .welcome: return LocalizationKey.onboardingWelcomeTitle.localized
        case .userMode: return LocalizationKey.onboardingModeTitle.localized
        case .focusTags: return LocalizationKey.onboardingTagsTitle.localized
        case .healthPermission: return LocalizationKey.onboardingHealthTitle.localized
        case .locationPermission: return LocalizationKey.onboardingLocationTitle.localized
        case .completion: return LocalizationKey.onboardingCompletionTitle.localized
        }
    }
}

@MainActor
class OnboardingCoordinator: ObservableObject {
    @Published var currentPage: OnboardingPage = .welcome
    @Published var isCompleted = false
    @Published var canProceed = false
    
    // 収集したデータ
    @Published var selectedUserMode: UserMode?
    @Published var selectedTags: Set<FocusTag> = []
    @Published var healthPermissionGranted = false
    @Published var locationPermissionGranted = false
    
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "onboarding_completed"
    
    init() {
        isCompleted = userDefaults.bool(forKey: onboardingCompletedKey)
        updateCanProceed()
    }
    
    func nextPage() {
        guard canProceed else { return }
        
        if let nextPageIndex = OnboardingPage(rawValue: currentPage.rawValue + 1) {
            withAnimation(.easeInOut) {
                currentPage = nextPageIndex
            }
        } else {
            completeOnboarding()
        }
        
        updateCanProceed()
    }
    
    func previousPage() {
        if let prevPageIndex = OnboardingPage(rawValue: currentPage.rawValue - 1) {
            withAnimation(.easeInOut) {
                currentPage = prevPageIndex
            }
        }
        updateCanProceed()
    }
    
    private func updateCanProceed() {
        switch currentPage {
        case .welcome:
            canProceed = true
        case .userMode:
            canProceed = selectedUserMode != nil
        case .focusTags:
            canProceed = !selectedTags.isEmpty
        case .healthPermission:
            canProceed = healthPermissionGranted
        case .locationPermission:
            canProceed = locationPermissionGranted
        case .completion:
            canProceed = true
        }
    }
    
    private func completeOnboarding() {
        isCompleted = true
        userDefaults.set(true, forKey: onboardingCompletedKey)
        
        // 選択内容を保存
        if let mode = selectedUserMode {
            UserProfileManager.shared.updateMode(mode)
        }
        FocusTagManager.shared.activeTags = selectedTags
        FocusTagManager.shared.completeOnboarding()
    }
}
```

#### 1.0.2 ウェルカム画面
**ファイル**: `Views/Onboarding/WelcomePage.swift`

```swift
struct WelcomePage: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            // Hero Animation
            BatteryHeroAnimation()
                .frame(height: 200)
            
            VStack(spacing: Spacing.lg) {
                Text("Meet Your Human Battery")
                    .heroStyle()
                    .multilineTextAlignment(.center)
                
                Text("あなたの体力を「スマホのバッテリー」のように可視化。今日は攻めるべき？休むべき？AIがリアルタイムでアドバイスします。")
                    .bodyStyle()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)
            }
            
            Spacer()
            
            Button("始める", action: onNext)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, Spacing.lg)
        }
        .padding(Spacing.lg)
        .background(
            LinearGradient(
                colors: [ColorPalette.pureWhite, ColorPalette.pearl],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct BatteryHeroAnimation: View {
    @State private var animationProgress: Double = 0
    @State private var isCharging = false
    
    var body: some View {
        ZStack {
            // バッテリー外形
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorPalette.gray300, lineWidth: 3)
                .frame(width: 120, height: 200)
            
            // 充電アニメーション
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [ColorPalette.success, ColorPalette.success.opacity(0.7)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 110, height: 190 * animationProgress)
                .clipShape(RoundedRectangle(cornerRadius: 17))
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animationProgress)
            
            // パーセンテージ
            Text("\(Int(animationProgress * 100))%")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(animationProgress > 0.5 ? ColorPalette.pureWhite : ColorPalette.richBlack)
        }
        .onAppear {
            animationProgress = 1.0
        }
    }
}
```

### Stage 1.1: 基盤アーキテクチャ (2-3 日)

#### 1.1.1 UserMode 管理システム

**ファイル**: `Models/UserProfile.swift`

```swift
enum UserMode: String, Codable, CaseIterable {
    case standard = "standard"  // 効率的な日常、メンタルヘルス重視
    case athlete = "athlete"    // パフォーマンス向上、負荷と回復重視

    var displayName: String {
        switch self {
        case .standard: return NSLocalizedString("userMode.standard", comment: "")
        case .athlete: return NSLocalizedString("userMode.athlete", comment: "")
        }
    }

    var description: String {
        switch self {
        case .standard: return NSLocalizedString("userMode.standard.description", comment: "")
        case .athlete: return NSLocalizedString("userMode.athlete.description", comment: "")
        }
    }
}

@MainActor
class UserProfileManager: ObservableObject {
    @Published var currentMode: UserMode = .standard

    private let userDefaults = UserDefaults.standard
    private let modeKey = "user_mode"

    init() {
        loadSavedMode()
    }

    func updateMode(_ mode: UserMode) {
        currentMode = mode
        userDefaults.set(mode.rawValue, forKey: modeKey)
    }

    private func loadSavedMode() {
        if let savedModeString = userDefaults.string(forKey: modeKey),
           let savedMode = UserMode(rawValue: savedModeString) {
            currentMode = savedMode
        }
    }
}
```

#### 1.1.2 Human Battery Engine

**ファイル**: `Services/BatteryEngine.swift`

**UX コンセプト適用**:

- **Doherty Threshold**: バッテリー更新は 400ms 以内
- **Immediate Feedback**: リアルタイム更新で制御感向上

```swift
import HealthKit

enum BatteryState: String, Codable {
    case high, medium, low, critical

    var color: Color {
        switch self {
        case .high: return ColorPalette.success
        case .medium: return ColorPalette.warning
        case .low, .critical: return ColorPalette.error
        }
    }
}

struct HumanBattery: Codable {
    let currentLevel: Double    // 0-100%
    let morningCharge: Double   // 起床時の初期容量
    let drainRate: Double       // 現在の放電速度
    let state: BatteryState
    let lastUpdated: Date

    var projectedEndTime: Date {
        let hoursRemaining = currentLevel / abs(drainRate)
        return Date().addingTimeInterval(hoursRemaining * 3600)
    }
}

@MainActor
class BatteryEngine: ObservableObject {
    @Published var currentBattery: HumanBattery

    private let healthManager: HealthKitManager
    private let weatherService: WeatherService

    init(healthManager: HealthKitManager, weatherService: WeatherService) {
        self.healthManager = healthManager
        self.weatherService = weatherService
        self.currentBattery = HumanBattery(
            currentLevel: 75.0,
            morningCharge: 0.0,
            drainRate: -5.0,
            state: .high,
            lastUpdated: Date()
        )

        startRealTimeUpdates()
    }

    // MARK: - Battery Calculation Logic

    func calculateMorningCharge(
        sleepData: SleepData,
        hrvData: HRVData,
        userMode: UserMode
    ) -> Double {
        let sleepScore = calculateSleepScore(sleepData, for: userMode)
        let hrvScore = calculateHRVScore(hrvData)

        let baseCharge = (sleepScore * 0.6) + (hrvScore * 0.4)

        // 前日のバッテリー残量ペナルティ
        let previousDayPenalty = currentBattery.currentLevel < 20 ? 0.9 : 1.0

        return min(100.0, baseCharge * previousDayPenalty)
    }

    func calculateRealTimeDrain(
        activeEnergy: Double,
        stressLevel: Double,
        environmentFactor: Double,
        userMode: UserMode
    ) -> Double {
        let baseDrain = -2.5  // 基礎消費: -2.5%/hour

        let activityDrain = activeEnergy * (userMode == .athlete ? 0.8 : 1.0) * 0.01
        let stressDrain = stressLevel * 0.5
        let environmentDrain = environmentFactor

        return baseDrain - activityDrain - stressDrain - environmentDrain
    }

    private func startRealTimeUpdates() {
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task {
                await self.updateBattery()
            }
        }
    }

    private func updateBattery() async {
        // HealthKit最新データ取得
        let healthData = await healthManager.getLatestHealthData()
        let weatherData = await weatherService.getCurrentWeather()

        // 環境係数計算
        let environmentFactor = calculateEnvironmentFactor(weatherData)

        // ドレイン率計算
        let newDrainRate = calculateRealTimeDrain(
            activeEnergy: healthData.activeEnergy,
            stressLevel: healthData.stressLevel,
            environmentFactor: environmentFactor,
            userMode: UserProfileManager.shared.currentMode
        )

        // バッテリーレベル更新
        let timeDelta = Date().timeIntervalSince(currentBattery.lastUpdated) / 3600.0
        let newLevel = max(0.0, currentBattery.currentLevel + (newDrainRate * timeDelta))

        let newState = getBatteryState(for: newLevel)

        currentBattery = HumanBattery(
            currentLevel: newLevel,
            morningCharge: currentBattery.morningCharge,
            drainRate: newDrainRate,
            state: newState,
            lastUpdated: Date()
        )
    }

    private func calculateEnvironmentFactor(_ weather: WeatherData) -> Double {
        var factor = 0.0

        // 高温多湿 (熱中症リスク)
        if weather.temperature > 30 && weather.humidity > 70 {
            factor += 2.0
        }

        // 気圧急低下 (頭痛リスク)
        if weather.pressureChange < -3.0 {
            factor += 1.5
        }

        return factor
    }
}
```

#### 1.1.3 Service Layer 再構築

**ファイル**: `Services/WeatherService.swift`

**UX コンセプト適用**:

- **Perceived Performance**: キャッシュ戦略で体感速度向上
- **Offline Support**: ネットワーク状態に応じた適切な表示

```swift
struct WeatherData: Codable {
    let temperature: Double
    let humidity: Double
    let surfacePressure: Double
    let pressureChange: Double  // 過去3時間の変化量
    let timestamp: Date
}

@MainActor
class WeatherService: ObservableObject {
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false

    private let apiClient: APIClient
    private let cache = NSCache<NSString, CacheItem>()
    private let cacheExpiry: TimeInterval = 1800 // 30分

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getCurrentWeather() async -> WeatherData? {
        // キャッシュチェック
        if let cachedWeather = getCachedWeather() {
            return cachedWeather
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let weather = try await fetchWeatherFromAPI()
            cacheWeather(weather)
            currentWeather = weather
            return weather
        } catch {
            // オフライン状態の適切な処理
            return handleOfflineWeather()
        }
    }

    private func fetchWeatherFromAPI() async throws -> WeatherData {
        // Open-Meteo API実装
        // バックエンド経由でAPIキー秘匿化
        return try await apiClient.fetchWeather()
    }

    private func handleOfflineWeather() -> WeatherData? {
        // 最後に取得成功したデータを返すか、デフォルト値
        return getCachedWeather() ?? createDefaultWeather()
    }
}
```

### Stage 1.2: コアデータ統合 (2 日)

#### 1.2.1 HealthKit 統合最適化

**ファイル**: `Services/HealthKitManager.swift`

**UX コンセプト適用**:

- **Privacy-First Design**: 最小権限原則
- **Data Transparency**: データソース明示

```swift
struct HealthData: Codable {
    let heartRate: HeartRateData
    let sleepData: SleepData
    let activityData: ActivityData
    let hrvData: HRVData
    let timestamp: Date

    // バッテリー計算用の集約値
    var stressLevel: Double {
        // HRVと心拍数からストレスレベル算出
        return hrvData.calculateStressLevel(heartRate.current)
    }

    var activeEnergy: Double {
        return activityData.activeEnergyBurned
    }
}

@MainActor
class HealthKitManager: ObservableObject {
    @Published var latestHealthData: HealthData?
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined

    private let healthStore = HKHealthStore()
    private let requiredTypes: Set<HKSampleType> = [
        HKSampleType.quantityType(forIdentifier: .heartRate)!,
        HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKSampleType.quantityType(forIdentifier: .stepCount)!,
        HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
    ]

    func requestPermissions() async -> Bool {
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: requiredTypes) { success, error in
                DispatchQueue.main.async {
                    self.authorizationStatus = success ? .sharingAuthorized : .sharingDenied
                    continuation.resume(returning: success)
                }
            }
        }
    }

    func getLatestHealthData() async -> HealthData {
        async let heartRate = getLatestHeartRate()
        async let sleepData = getLatestSleepData()
        async let activityData = getLatestActivityData()
        async let hrvData = getLatestHRVData()

        return HealthData(
            heartRate: await heartRate,
            sleepData: await sleepData,
            activityData: await activityData,
            hrvData: await hrvData,
            timestamp: Date()
        )
    }

    // 個別データ取得メソッド実装
    private func getLatestHeartRate() async -> HeartRateData {
        // HKQuantityType.quantityType(forIdentifier: .heartRate)の取得実装
    }

    // その他のデータ取得メソッド...
}
```

### Stage 1.3: UI コンポーネント実装 (3-4 日)

#### 1.3.1 AdviceHeaderView - 雑誌スタイル大見出し

**ファイル**: `Views/Home/AdviceHeaderView.swift`

**UX コンセプト適用**:

- **Von Restorff Effect**: コントラストで重要性強調
- **Serial Position Effect**: 最重要情報を先頭配置
- **Peak-End Rule**: 印象的な見出しで体験価値向上

```swift
struct AdviceHeaderView: View {
    let headline: AdviceHeadline
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(headline.title)
                        .heroStyle()
                        .foregroundColor(impactColor)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(ColorPalette.gray500)
                        .font(.title3)
                }

                Text(headline.subtitle)
                    .bodyStyle()
                    .foregroundColor(ColorPalette.gray700)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var impactColor: Color {
        switch headline.impactLevel {
        case .high: return ColorPalette.error
        case .medium: return ColorPalette.warning
        case .low: return ColorPalette.richBlack
        }
    }
}

// マガジンスタイルのボタンスタイル
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AdviceHeadline {
    let title: String
    let subtitle: String
    let impactLevel: ImpactLevel

    enum ImpactLevel {
        case high, medium, low
    }
}
```

#### 1.3.2 LiquidBatteryView - 流体アニメーション

**ファイル**: `Views/Home/LiquidBatteryView.swift`

**UX コンセプト適用**:

- **Aesthetic-Usability Effect**: 美しいアニメーションで使いやすさ向上
- **Microinteractions**: 細かなアニメーションで体験向上
- **Performance**: 60fps 維持でスムーズな体験

```swift
struct LiquidBatteryView: View {
    @Binding var batteryLevel: Double  // 0-100
    @State private var waveOffset: CGFloat = 0
    @State private var isAnimating = false

    let batteryState: BatteryState

    var body: some View {
        ZStack {
            // バッテリー外枠
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .stroke(ColorPalette.gray300, lineWidth: 2)
                .frame(height: 80)

            // 液体部分
            GeometryReader { geometry in
                ZStack {
                    // 背景
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .fill(ColorPalette.gray100)

                    // 液体レベル
                    LiquidWaveShape(
                        level: batteryLevel / 100,
                        waveOffset: waveOffset,
                        waveHeight: 8
                    )
                    .fill(
                        LinearGradient(
                            colors: [liquidColor.opacity(0.8), liquidColor],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                }
            }
            .frame(height: 76)

            // バッテリーレベルテキスト
            Text("\(Int(batteryLevel))%")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
        }
        .onAppear {
            startWaveAnimation()
        }
    }

    private var liquidColor: Color {
        switch batteryState {
        case .high: return ColorPalette.success
        case .medium: return ColorPalette.warning
        case .low, .critical: return ColorPalette.error
        }
    }

    private var textColor: Color {
        batteryLevel > 50 ? ColorPalette.pureWhite : ColorPalette.richBlack
    }

    private func startWaveAnimation() {
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            waveOffset = 360
        }
    }
}

struct LiquidWaveShape: Shape {
    let level: Double
    let waveOffset: CGFloat
    let waveHeight: CGFloat

    var animatableData: CGFloat {
        get { waveOffset }
        set { waveOffset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let liquidHeight = height * (1 - level)

        let path = Path { path in
            // 波の形状生成
            path.move(to: CGPoint(x: 0, y: liquidHeight))

            for x in stride(from: 0, through: width, by: 1) {
                let relativeX = x / width
                let sine = sin(relativeX * 4 * .pi + waveOffset * .pi / 180)
                let y = liquidHeight + sine * waveHeight
                path.addLine(to: CGPoint(x: x, y: y))
            }

            // 底面まで塗りつぶし
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
        }

        return path
    }
}
```

#### 1.3.3 IntuitiveCarsView - 3 つの直感的指標

**ファイル**: `Views/Home/IntuitiveCardsView.swift`

**UX コンセプト適用**:

- **Miller's Law**: 3 つに限定して認知負荷軽減
- **Hick's Law**: シンプルな選択肢で決断時間短縮

```swift
struct IntuitiveCardsView: View {
    let healthData: HealthData
    let userMode: UserMode

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.sm) {
            StressLevelCard(stressLevel: healthData.stressLevel)
            RecoveryCard(recoveryScore: healthData.recoveryScore)
            ContextMetricCard(metric: contextMetric, userMode: userMode)
        }
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 3)

    private var contextMetric: ContextMetric {
        switch userMode {
        case .standard:
            return .activity(steps: healthData.stepCount)
        case .athlete:
            return .exertion(strain: healthData.strainScore)
        }
    }
}

struct StressLevelCard: View {
    let stressLevel: Double

    var body: some View {
        MetricCard(
            title: NSLocalizedString("metric.stress", comment: ""),
            value: stressLevel,
            unit: "",
            color: stressColor,
            icon: "brain.head.profile"
        )
    }

    private var stressColor: Color {
        switch stressLevel {
        case 0..<30: return ColorPalette.success
        case 30..<70: return ColorPalette.warning
        default: return ColorPalette.error
        }
    }
}
```

### Stage 1.4: バックエンド連携 (2 日)

#### 1.4.1 動的プロンプト構築

**ファイル**: `Services/AIAnalysisService.swift`

```swift
struct AnalysisRequest: Codable {
    let userMode: UserMode
    let batteryData: HumanBattery
    let healthData: HealthData
    let weatherData: WeatherData?
    let timestamp: Date
}

struct AnalysisResponse: Codable {
    let headline: AdviceHeadline
    let batteryComment: String
    let detailedAnalysis: String
    let recommendations: [Recommendation]
}

@MainActor
class AIAnalysisService: ObservableObject {
    @Published var currentAdvice: AnalysisResponse?
    @Published var isAnalyzing = false

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func requestAnalysis(
        userMode: UserMode,
        battery: HumanBattery,
        health: HealthData,
        weather: WeatherData?
    ) async -> AnalysisResponse? {

        isAnalyzing = true
        defer { isAnalyzing = false }

        let request = AnalysisRequest(
            userMode: userMode,
            batteryData: battery,
            healthData: health,
            weatherData: weather,
            timestamp: Date()
        )

        do {
            let response = try await apiClient.requestAnalysis(request)
            currentAdvice = response
            return response
        } catch {
            // エラーハンドリング
            return createFallbackAdvice()
        }
    }

    private func createFallbackAdvice() -> AnalysisResponse {
        // オフライン時の基本アドバイス
        return AnalysisResponse(
            headline: AdviceHeadline(
                title: NSLocalizedString("fallback.title", comment: ""),
                subtitle: NSLocalizedString("fallback.subtitle", comment: ""),
                impactLevel: .low
            ),
            batteryComment: NSLocalizedString("fallback.battery", comment: ""),
            detailedAnalysis: NSLocalizedString("fallback.analysis", comment: ""),
            recommendations: []
        )
    }
}
```

## 📋 テスト戦略

### 単体テスト

```swift
@testable import TempoAI
import XCTest

class BatteryEngineTests: XCTestCase {
    func testMorningChargeCalculation() {
        // Given
        let sleepData = SleepData.mock(duration: 8.0, quality: 0.85)
        let hrvData = HRVData.mock(baseline: 45, current: 48)

        // When
        let charge = batteryEngine.calculateMorningCharge(
            sleepData: sleepData,
            hrvData: hrvData,
            userMode: .standard
        )

        // Then
        XCTAssertEqual(charge, 87.2, accuracy: 0.1)
    }
}
```

## 📊 成功基準

### 機能完成度

- [ ] UserMode 切り替えが正常動作
- [ ] バッテリーレベルがリアルタイム更新
- [ ] 気象データ統合による環境係数計算
- [ ] AI 分析要求〜応答表示の完全フロー

### UX 品質基準

- [ ] ページ遷移 400ms 以内（Doherty Threshold）
- [ ] タップ反応の即座フィードバック
- [ ] 最小 44x44px タップエリア確保（Fitts's Law）
- [ ] コントラスト比 4.5:1 以上（WCAG 2.1 AA）

### パフォーマンス

- [ ] アプリ起動 3 秒以内
- [ ] バッテリーアニメーション 60fps 維持
- [ ] メモリ使用量 100MB 以下

### 品質保証

- [ ] ゼロコンパイラ警告
- [ ] 80%以上のテストカバレッジ
- [ ] ./scripts/quality-check.sh 通過

---

**推定期間**: 9-11日 (オンボーディング追加により2日延長)  
**完了条件**: 全ステージ完成 + オンボーディング完了 + 品質基準クリア  
**Next Phase**: Phase 2 Focus Tags + 詳細画面実装開始
