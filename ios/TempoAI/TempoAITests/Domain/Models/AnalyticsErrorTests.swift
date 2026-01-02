//
//  AnalyticsErrorTests.swift
//  TempoAITests
//

import Testing
@testable import TempoAI

struct AnalyticsErrorTests {

    // MARK: - Error Description Tests

    @Test("dataLoadFailed has correct error description")
    func dataLoadFailedDescription() {
        let error: AnalyticsError = .dataLoadFailed
        #expect(error.errorDescription == "データの読み込みに失敗しました")
    }

    @Test("insufficientData has correct error description")
    func insufficientDataDescription() {
        let error: AnalyticsError = .insufficientData
        #expect(error.errorDescription == "十分なデータがありません")
    }

    @Test("calculationError has correct error description")
    func calculationErrorDescription() {
        let error: AnalyticsError = .calculationError
        #expect(error.errorDescription == "計算中にエラーが発生しました")
    }

    // MARK: - Identifiable Tests

    @Test("AnalyticsError has unique identifiers")
    func hasUniqueIdentifiers() {
        #expect(AnalyticsError.dataLoadFailed.id == "dataLoadFailed")
        #expect(AnalyticsError.insufficientData.id == "insufficientData")
        #expect(AnalyticsError.calculationError.id == "calculationError")
    }

    // MARK: - Equatable Tests

    @Test("Same AnalyticsErrors are equal")
    func sameErrorsAreEqual() {
        #expect(AnalyticsError.dataLoadFailed == AnalyticsError.dataLoadFailed)
        #expect(AnalyticsError.insufficientData == AnalyticsError.insufficientData)
        #expect(AnalyticsError.calculationError == AnalyticsError.calculationError)
    }

    @Test("Different AnalyticsErrors are not equal")
    func differentErrorsAreNotEqual() {
        #expect(AnalyticsError.dataLoadFailed != AnalyticsError.insufficientData)
        #expect(AnalyticsError.insufficientData != AnalyticsError.calculationError)
    }
}
