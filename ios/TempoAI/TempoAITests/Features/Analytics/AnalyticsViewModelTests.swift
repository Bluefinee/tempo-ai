//
//  AnalyticsViewModelTests.swift
//  TempoAITests
//

import Foundation
import Testing
@testable import TempoAI

// MARK: - Mock Classes

final class MockLocalStorageForAnalytics: LocalStorageProtocol, @unchecked Sendable {
    var storage: [String: Any] = [:]
    var calibrationState: CalibrationState?

    func save<T: Codable>(_ value: T, forKey key: String) throws {
        storage[key] = value
    }

    func load<T: Codable>(forKey key: String) -> T? {
        if key == StorageKeys.calibrationState {
            return calibrationState as? T
        }
        return storage[key] as? T
    }

    func remove(forKey key: String) {
        storage.removeValue(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        storage[key] != nil
    }
}

// MARK: - AnalyticsViewModelTests

@MainActor
struct AnalyticsViewModelTests {

    // MARK: - Initial State Tests

    @Test("Initial state has weekly selected period")
    func initialStateHasWeeklySelectedPeriod() {
        let viewModel: AnalyticsViewModel = createViewModel()
        #expect(viewModel.selectedPeriod == .weekly)
    }

    @Test("Initial state has isLoading false")
    func initialStateHasIsLoadingFalse() {
        let viewModel: AnalyticsViewModel = createViewModel()
        #expect(viewModel.isLoading == false)
    }

    @Test("Initial state has error nil")
    func initialStateHasErrorNil() {
        let viewModel: AnalyticsViewModel = createViewModel()
        #expect(viewModel.error == nil)
    }

    @Test("Initial state has empty scoreSnapshots")
    func initialStateHasEmptyScoreSnapshots() {
        let viewModel: AnalyticsViewModel = createViewModel()
        #expect(viewModel.scoreSnapshots.isEmpty)
    }

    @Test("Initial state has nil rhythmAnalysis")
    func initialStateHasNilRhythmAnalysis() {
        let viewModel: AnalyticsViewModel = createViewModel()
        #expect(viewModel.rhythmAnalysis == nil)
    }

    @Test("Initial state has empty insights")
    func initialStateHasEmptyInsights() {
        let viewModel: AnalyticsViewModel = createViewModel()
        #expect(viewModel.insights.isEmpty)
    }

    // MARK: - Calibration Tests

    @Test("isCalibrating is true when calibration not complete")
    func isCalibratingTrueWhenNotComplete() async {
        let mockStorage: MockLocalStorageForAnalytics = MockLocalStorageForAnalytics()
        mockStorage.calibrationState = CalibrationState(
            startDate: Date(),
            daysCompleted: 3
        )

        let viewModel: AnalyticsViewModel = createViewModel(localStorage: mockStorage)
        await viewModel.loadAnalyticsData()

        #expect(viewModel.isCalibrating == true)
        #expect(viewModel.calibrationDaysCompleted == 3)
    }

    @Test("isCalibrating is false when calibration complete")
    func isCalibratingFalseWhenComplete() async {
        let mockStorage: MockLocalStorageForAnalytics = MockLocalStorageForAnalytics()
        mockStorage.calibrationState = CalibrationState(
            startDate: Date(),
            daysCompleted: 7
        )

        let viewModel: AnalyticsViewModel = createViewModel(localStorage: mockStorage)
        await viewModel.loadAnalyticsData()

        #expect(viewModel.isCalibrating == false)
    }

    @Test("isCalibrating is true when no calibration state exists")
    func isCalibratingTrueWhenNoState() async {
        let mockStorage: MockLocalStorageForAnalytics = MockLocalStorageForAnalytics()
        // calibrationStateを設定しない

        let viewModel: AnalyticsViewModel = createViewModel(localStorage: mockStorage)
        await viewModel.loadAnalyticsData()

        #expect(viewModel.isCalibrating == true)
        #expect(viewModel.calibrationDaysCompleted == 0)
    }

    // MARK: - Period Change Tests

    @Test("changePeriod updates selectedPeriod")
    func changePeriodUpdatesSelectedPeriod() async {
        let mockStorage: MockLocalStorageForAnalytics = MockLocalStorageForAnalytics()
        mockStorage.calibrationState = CalibrationState(startDate: Date(), daysCompleted: 7)

        let viewModel: AnalyticsViewModel = createViewModel(localStorage: mockStorage)

        #expect(viewModel.selectedPeriod == .weekly)

        await viewModel.changePeriod(.monthly)

        #expect(viewModel.selectedPeriod == .monthly)
    }

    @Test("changePeriod does not reload if same period")
    func changePeriodNoReloadIfSamePeriod() async {
        let mockStorage: MockLocalStorageForAnalytics = MockLocalStorageForAnalytics()
        mockStorage.calibrationState = CalibrationState(startDate: Date(), daysCompleted: 7)

        let viewModel: AnalyticsViewModel = createViewModel(localStorage: mockStorage)

        await viewModel.changePeriod(.weekly) // Same as default

        // Should still be weekly without triggering full reload
        #expect(viewModel.selectedPeriod == .weekly)
    }

    // MARK: - TimePeriod Tests

    @Test("TimePeriod weekly has 7 days")
    func timePeriodWeeklyHas7Days() {
        #expect(TimePeriod.weekly.days == 7)
    }

    @Test("TimePeriod monthly has 30 days")
    func timePeriodMonthlyHas30Days() {
        #expect(TimePeriod.monthly.days == 30)
    }

    // MARK: - Helpers

    private func createViewModel(
        localStorage: LocalStorageProtocol = MockLocalStorageForAnalytics()
    ) -> AnalyticsViewModel {
        AnalyticsViewModel(
            healthKitManager: HealthKitManager.mock(),
            scoreCalculator: ScoreCalculator(),
            localStorage: localStorage
        )
    }
}
