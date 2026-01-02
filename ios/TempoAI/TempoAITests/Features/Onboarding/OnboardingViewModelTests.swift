import Foundation
import Testing
@testable import TempoAI

// MARK: - OnboardingViewModelTests

struct OnboardingViewModelTests {

    // MARK: - Navigation Tests

    @Test("Initial step is welcome")
    @MainActor
    func initialStepIsWelcome() {
        let viewModel: OnboardingViewModel = makeViewModel()
        #expect(viewModel.currentStep == .welcome)
    }

    @Test("nextStep advances to next step")
    @MainActor
    func nextStepAdvances() {
        let viewModel: OnboardingViewModel = makeViewModel()
        viewModel.nextStep()
        #expect(viewModel.currentStep == .healthKit)
    }

    @Test("previousStep goes back to previous step")
    @MainActor
    func previousStepGoesBack() {
        let viewModel: OnboardingViewModel = makeViewModel()
        viewModel.goToStep(.nickname)
        viewModel.previousStep()
        #expect(viewModel.currentStep == .healthKit)
    }

    @Test("previousStep does nothing on first step")
    @MainActor
    func previousStepOnFirstStepDoesNothing() {
        let viewModel: OnboardingViewModel = makeViewModel()
        viewModel.previousStep()
        #expect(viewModel.currentStep == .welcome)
    }

    @Test("goToStep navigates to specific step")
    @MainActor
    func goToStepNavigates() {
        let viewModel: OnboardingViewModel = makeViewModel()
        viewModel.goToStep(.lifestyle)
        #expect(viewModel.currentStep == .lifestyle)
    }

    // MARK: - State Tests

    @Test("OnboardingState default values are correct")
    func defaultStateValues() {
        let state: OnboardingState = OnboardingState()
        #expect(state.nickname == "")
        #expect(state.age == 30)
        #expect(state.gender == .preferNotToSay)
        #expect(state.chronotype == .intermediate)
        #expect(!state.healthKitAuthorized)
        #expect(!state.locationAuthorized)
        #expect(!state.chronotypeAutoEstimated)
        #expect(!state.bedtimeAutoEstimated)
    }

    @Test("OnboardingState BMI calculation is correct")
    func bmiCalculation() {
        var state: OnboardingState = OnboardingState()
        state.weight = 70
        state.height = 175
        // BMI = 70 / (1.75 * 1.75) = 22.857...
        #expect(state.bmi > 22.8 && state.bmi < 22.9)
    }

    @Test("OnboardingState BMI handles zero height safely")
    func bmiZeroHeightSafe() {
        var state: OnboardingState = OnboardingState()
        state.height = 0
        #expect(state.bmi == 0)
    }

    // MARK: - Nickname Validation Tests

    @Test("Empty nickname is invalid")
    @MainActor
    func emptyNicknameInvalid() {
        let viewModel: OnboardingViewModel = makeViewModel()
        viewModel.state.nickname = ""
        #expect(!viewModel.state.isNicknameValid)
    }

    @Test("Whitespace-only nickname is invalid")
    @MainActor
    func whitespaceNicknameInvalid() {
        let viewModel: OnboardingViewModel = makeViewModel()
        viewModel.state.nickname = "   "
        #expect(!viewModel.state.isNicknameValid)
    }

    @Test("Valid nickname is accepted")
    @MainActor
    func validNicknameAccepted() {
        let viewModel: OnboardingViewModel = makeViewModel()
        viewModel.state.nickname = "太郎"
        #expect(viewModel.state.isNicknameValid)
    }

    @Test("Nickname over 20 characters is invalid")
    @MainActor
    func longNicknameInvalid() {
        let viewModel: OnboardingViewModel = makeViewModel()
        viewModel.state.nickname = String(repeating: "あ", count: 21)
        #expect(!viewModel.state.isNicknameValid)
    }

    @Test("Nickname with exactly 20 characters is valid")
    @MainActor
    func exactlyMaxNicknameValid() {
        let viewModel: OnboardingViewModel = makeViewModel()
        viewModel.state.nickname = String(repeating: "あ", count: 20)
        #expect(viewModel.state.isNicknameValid)
    }

    // MARK: - Basic Info Validation Tests

    @Test("Valid basic info is accepted")
    func validBasicInfo() {
        var state: OnboardingState = OnboardingState()
        state.age = 30
        state.weight = 65
        state.height = 170
        #expect(state.isBasicInfoValid)
    }

    @Test("Age below 18 is invalid")
    func ageBelowMinInvalid() {
        var state: OnboardingState = OnboardingState()
        state.age = 17
        #expect(!state.isBasicInfoValid)
    }

    @Test("Age above 100 is invalid")
    func ageAboveMaxInvalid() {
        var state: OnboardingState = OnboardingState()
        state.age = 101
        #expect(!state.isBasicInfoValid)
    }

    @Test("Zero weight is invalid")
    func zeroWeightInvalid() {
        var state: OnboardingState = OnboardingState()
        state.weight = 0
        #expect(!state.isBasicInfoValid)
    }

    @Test("Zero height is invalid")
    func zeroHeightInvalid() {
        var state: OnboardingState = OnboardingState()
        state.height = 0
        #expect(!state.isBasicInfoValid)
    }

    // MARK: - Chronotype Estimation Tests

    @Test("Chronotype estimation returns intermediate with insufficient data")
    @MainActor
    func chronotypeInsufficientData() {
        let viewModel: OnboardingViewModel = makeViewModel(sleepHistory: [])
        let (chronotype, autoEstimated): (Chronotype, Bool) = viewModel.estimateChronotype()
        #expect(chronotype == .intermediate)
        #expect(!autoEstimated)
    }

    @Test("Chronotype classification returns morning for early MSFsc")
    @MainActor
    func chronotypeMorning() {
        // 早い就寝時刻（21:00）+ 7時間睡眠 → MSFsc = 24.5h (0:30) < 27h → morning
        let sleepHistory: [SleepMetrics] = generateSleepHistory(bedtimeHour: 21, count: 10)
        let viewModel: OnboardingViewModel = makeViewModel(sleepHistory: sleepHistory)
        let (chronotype, autoEstimated): (Chronotype, Bool) = viewModel.estimateChronotype()
        #expect(chronotype == .morning)
        #expect(autoEstimated)
    }

    @Test("Chronotype classification returns intermediate for middle MSFsc")
    @MainActor
    func chronotypeIntermediate() {
        // 中間就寝時刻（23:30）+ 7時間睡眠 → MSFsc = 27.0h (3:00) → intermediate
        let sleepHistory: [SleepMetrics] = generateSleepHistory(bedtimeHour: 23, bedtimeMinute: 30, count: 10)
        let viewModel: OnboardingViewModel = makeViewModel(sleepHistory: sleepHistory)
        let (chronotype, autoEstimated): (Chronotype, Bool) = viewModel.estimateChronotype()
        #expect(chronotype == .intermediate)
        #expect(autoEstimated)
    }

    @Test("Chronotype classification returns evening for late MSFsc")
    @MainActor
    func chronotypeEvening() {
        // 遅い就寝時刻（2:00）+ 7時間睡眠 → MSFsc = 29.5h (5:30) >= 29h → evening
        let sleepHistory: [SleepMetrics] = generateSleepHistory(bedtimeHour: 2, count: 10)
        let viewModel: OnboardingViewModel = makeViewModel(sleepHistory: sleepHistory)
        let (chronotype, autoEstimated): (Chronotype, Bool) = viewModel.estimateChronotype()
        #expect(chronotype == .evening)
        #expect(autoEstimated)
    }

    // MARK: - Bedtime Goal Estimation Tests

    @Test("Bedtime goal returns default with insufficient data")
    @MainActor
    func bedtimeGoalInsufficientData() {
        let viewModel: OnboardingViewModel = makeViewModel(sleepHistory: [])
        let (_, autoEstimated): (Date, Bool) = viewModel.estimateBedtimeGoal()
        #expect(!autoEstimated)
    }

    @Test("Bedtime goal is rounded to 30 minutes - round down")
    @MainActor
    func bedtimeGoalRoundedDown() {
        // 23:10 → 23:00に丸める
        let sleepHistory: [SleepMetrics] = generateSleepHistory(bedtimeHour: 23, bedtimeMinute: 10, count: 10)
        let viewModel: OnboardingViewModel = makeViewModel(sleepHistory: sleepHistory)
        let (bedtime, autoEstimated): (Date, Bool) = viewModel.estimateBedtimeGoal()

        #expect(autoEstimated)
        let calendar: Calendar = Calendar.current
        let minute: Int = calendar.component(.minute, from: bedtime)
        #expect(minute == 0)
    }

    @Test("Bedtime goal is rounded to 30 minutes - round to 30")
    @MainActor
    func bedtimeGoalRoundedTo30() {
        // 23:25 → 23:30に丸める
        let sleepHistory: [SleepMetrics] = generateSleepHistory(bedtimeHour: 23, bedtimeMinute: 25, count: 10)
        let viewModel: OnboardingViewModel = makeViewModel(sleepHistory: sleepHistory)
        let (bedtime, autoEstimated): (Date, Bool) = viewModel.estimateBedtimeGoal()

        #expect(autoEstimated)
        let calendar: Calendar = Calendar.current
        let minute: Int = calendar.component(.minute, from: bedtime)
        #expect(minute == 30)
    }

    @Test("Bedtime goal is rounded to 30 minutes - round up")
    @MainActor
    func bedtimeGoalRoundedUp() {
        // 23:50 → 00:00に丸める
        let sleepHistory: [SleepMetrics] = generateSleepHistory(bedtimeHour: 23, bedtimeMinute: 50, count: 10)
        let viewModel: OnboardingViewModel = makeViewModel(sleepHistory: sleepHistory)
        let (bedtime, autoEstimated): (Date, Bool) = viewModel.estimateBedtimeGoal()

        #expect(autoEstimated)
        let calendar: Calendar = Calendar.current
        let hour: Int = calendar.component(.hour, from: bedtime)
        let minute: Int = calendar.component(.minute, from: bedtime)
        #expect(hour == 0)
        #expect(minute == 0)
    }

    // MARK: - Conversion Tests

    @Test("OnboardingState converts to UserProfile correctly")
    func stateToUserProfile() {
        var state: OnboardingState = OnboardingState()
        state.nickname = "テスト太郎"
        state.age = 35
        state.gender = .male
        state.weight = 68.5
        state.height = 172.0
        state.occupation = .deskWork
        state.chronotype = .morning
        state.exerciseFrequency = .threeOrMore
        state.alcoholFrequency = .weekly

        let profile: UserProfile = state.toUserProfile()

        #expect(profile.nickname == "テスト太郎")
        #expect(profile.age == 35)
        #expect(profile.gender == .male)
        #expect(profile.weight == 68.5)
        #expect(profile.height == 172.0)
        #expect(profile.occupation == .deskWork)
        #expect(profile.chronotype == .morning)
        #expect(profile.exerciseFrequency == .threeOrMore)
        #expect(profile.alcoholFrequency == .weekly)
    }

    // MARK: - canProceed Tests

    @Test("canProceed is true on welcome step")
    @MainActor
    func canProceedOnWelcome() {
        let viewModel: OnboardingViewModel = makeViewModel()
        #expect(viewModel.canProceed)
    }

    @Test("canProceed is false on nickname step with empty nickname")
    @MainActor
    func cannotProceedWithEmptyNickname() {
        let viewModel: OnboardingViewModel = makeViewModel()
        viewModel.goToStep(.nickname)
        viewModel.state.nickname = ""
        #expect(!viewModel.canProceed)
    }

    @Test("canProceed is true on nickname step with valid nickname")
    @MainActor
    func canProceedWithValidNickname() {
        let viewModel: OnboardingViewModel = makeViewModel()
        viewModel.goToStep(.nickname)
        viewModel.state.nickname = "太郎"
        #expect(viewModel.canProceed)
    }

    // MARK: - Helper Methods

    @MainActor
    private func makeViewModel(sleepHistory: [SleepMetrics] = []) -> OnboardingViewModel {
        OnboardingViewModel(
            healthKitManager: HealthKitManager.mock(),
            locationManager: LocationManager.mock(),
            localStorage: MockLocalStorage(),
            initialSleepHistory: sleepHistory
        )
    }

    private func generateSleepHistory(
        bedtimeHour: Int,
        bedtimeMinute: Int = 0,
        count: Int
    ) -> [SleepMetrics] {
        let calendar: Calendar = Calendar.current
        return (0..<count).map { dayOffset in
            var bedtimeComponents: DateComponents = DateComponents()
            bedtimeComponents.hour = bedtimeHour
            bedtimeComponents.minute = bedtimeMinute
            let bedtime: Date = calendar.date(from: bedtimeComponents) ?? Date()
            let wakeTime: Date = bedtime.addingTimeInterval(7 * 3600) // 7時間睡眠

            return SleepMetrics(
                bedtime: bedtime,
                wakeTime: wakeTime,
                durationMinutes: 420,
                deepSleepMinutes: 90,
                remSleepMinutes: 100
            )
        }
    }
}
