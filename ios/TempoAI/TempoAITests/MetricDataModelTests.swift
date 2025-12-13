import SwiftUI
import XCTest

@testable import TempoAI

final class MetricDataModelTests: XCTestCase {

  // MARK: - MetricType Tests

  func testMetricTypeLabel() {
    XCTAssertEqual(MetricType.recovery.label, "回復", "Recovery label should be correct")
    XCTAssertEqual(MetricType.sleep.label, "睡眠", "Sleep label should be correct")
    XCTAssertEqual(MetricType.energy.label, "エネルギー", "Energy label should be correct")
    XCTAssertEqual(MetricType.stress.label, "ストレス", "Stress label should be correct")
  }

  func testMetricTypeAllCases() {
    XCTAssertEqual(MetricType.allCases.count, 4, "Should have 4 metric types")
    XCTAssertTrue(MetricType.allCases.contains(.recovery), "Should contain recovery")
    XCTAssertTrue(MetricType.allCases.contains(.sleep), "Should contain sleep")
    XCTAssertTrue(MetricType.allCases.contains(.energy), "Should contain energy")
    XCTAssertTrue(MetricType.allCases.contains(.stress), "Should contain stress")
  }

  func testMetricTypeSystemImageName() {
    XCTAssertEqual(MetricType.recovery.systemImageName, "heart.fill")
    XCTAssertEqual(MetricType.sleep.systemImageName, "moon.zzz.fill")
    XCTAssertEqual(MetricType.energy.systemImageName, "bolt.fill")
    XCTAssertEqual(MetricType.stress.systemImageName, "figure.mind.and.body")
  }

  // MARK: - MetricData Creation Tests

  func testMetricDataCreation() {
    let metric = MetricData(
      type: .recovery,
      score: 78,
      displayValue: "78"
    )

    XCTAssertEqual(metric.type, .recovery, "Type should be recovery")
    XCTAssertEqual(metric.score, 78, "Score should be 78")
    XCTAssertEqual(metric.displayValue, "78", "Display value should be 78")
    XCTAssertNotNil(metric.id, "ID should not be nil")
  }

  func testMetricDataIdentifiable() {
    let metric1 = MetricData(type: .recovery, score: 78, displayValue: "78")
    let metric2 = MetricData(type: .recovery, score: 78, displayValue: "78")

    XCTAssertNotEqual(metric1.id, metric2.id, "Different instances should have different IDs")
  }

  // MARK: - Progress Bar Color Tests (Normal Metrics)

  func testProgressBarColorForHighScore() {
    let metric = MetricData(type: .recovery, score: 85, displayValue: "85")
    XCTAssertEqual(metric.progressBarColor, Color.tempoSuccess, "High score should use success color")
  }

  func testProgressBarColorForGoodScore() {
    let metric = MetricData(type: .recovery, score: 70, displayValue: "70")
    XCTAssertEqual(
      metric.progressBarColor, Color.tempoSageGreen, "Good score should use sage green color")
  }

  func testProgressBarColorForNormalScore() {
    let metric = MetricData(type: .recovery, score: 50, displayValue: "50")
    XCTAssertEqual(
      metric.progressBarColor, Color.tempoWarning, "Normal score should use warning color")
  }

  func testProgressBarColorForLowScore() {
    let metric = MetricData(type: .recovery, score: 30, displayValue: "30")
    XCTAssertEqual(
      metric.progressBarColor, Color.tempoSoftCoral, "Low score should use soft coral color")
  }

  // MARK: - Boundary Value Tests

  func testProgressBarColorAtBoundary40() {
    let metric = MetricData(type: .recovery, score: 40, displayValue: "40")
    XCTAssertEqual(
      metric.progressBarColor, Color.tempoWarning, "Score 40 should use warning color")
  }

  func testProgressBarColorAtBoundary60() {
    let metric = MetricData(type: .recovery, score: 60, displayValue: "60")
    XCTAssertEqual(
      metric.progressBarColor, Color.tempoSageGreen, "Score 60 should use sage green color")
  }

  func testProgressBarColorAtBoundary80() {
    let metric = MetricData(type: .recovery, score: 80, displayValue: "80")
    XCTAssertEqual(
      metric.progressBarColor, Color.tempoSuccess, "Score 80 should use success color")
  }

  // MARK: - Stress Color Tests (Inverted: Lower is Better)

  func testStressColorForLowScore() {
    // Low stress (score 20) = good = green
    let metric = MetricData(type: .stress, score: 20, displayValue: "低")
    XCTAssertEqual(
      metric.progressBarColor, Color.tempoSuccess,
      "Low stress score should use success color (lower is better)")
  }

  func testStressColorForMediumLowScore() {
    // Medium-low stress (score 30) = good = sage green
    let metric = MetricData(type: .stress, score: 30, displayValue: "やや低")
    XCTAssertEqual(
      metric.progressBarColor, Color.tempoSageGreen,
      "Medium-low stress should use sage green color")
  }

  func testStressColorForMediumScore() {
    // Medium stress (score 50) = warning = yellow
    let metric = MetricData(type: .stress, score: 50, displayValue: "中")
    XCTAssertEqual(
      metric.progressBarColor, Color.tempoWarning,
      "Medium stress should use warning color")
  }

  func testStressColorForHighScore() {
    // High stress (score 80) = bad = coral
    let metric = MetricData(type: .stress, score: 80, displayValue: "高")
    XCTAssertEqual(
      metric.progressBarColor, Color.tempoSoftCoral,
      "High stress score should use soft coral color (higher is worse)")
  }

  // MARK: - Progress Value Tests

  func testProgressValue() {
    let metric = MetricData(type: .recovery, score: 78, displayValue: "78")
    XCTAssertEqual(metric.progressValue, 0.78, accuracy: 0.001, "Progress value should be 0.78")
  }

  func testProgressValueForZero() {
    let metric = MetricData(type: .recovery, score: 0, displayValue: "0")
    XCTAssertEqual(metric.progressValue, 0.0, accuracy: 0.001, "Progress value should be 0.0")
  }

  func testProgressValueForMax() {
    let metric = MetricData(type: .recovery, score: 100, displayValue: "100")
    XCTAssertEqual(metric.progressValue, 1.0, accuracy: 0.001, "Progress value should be 1.0")
  }

  // MARK: - Codable Tests

  func testMetricDataEncodeDecode() throws {
    let original = MetricData(type: .sleep, score: 85, displayValue: "7.0h")

    let encoder = JSONEncoder()
    let data = try encoder.encode(original)
    XCTAssertGreaterThan(data.count, 0, "Encoded data should not be empty")

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(MetricData.self, from: data)

    XCTAssertEqual(decoded.type, original.type, "Type should match after decode")
    XCTAssertEqual(decoded.score, original.score, "Score should match after decode")
    XCTAssertEqual(decoded.displayValue, original.displayValue, "Display value should match after decode")
  }

  func testMetricTypeCodable() throws {
    let original = MetricType.energy
    let encoder = JSONEncoder()
    let data = try encoder.encode(original)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(MetricType.self, from: data)

    XCTAssertEqual(decoded, original, "MetricType should encode/decode correctly")
  }

  // MARK: - Mock Data Tests

  #if DEBUG
    func testMockMetricsExist() {
      let metrics = MockData.mockMetrics
      XCTAssertEqual(metrics.count, 4, "Should have 4 mock metrics")
    }

    func testMockMetricsTypes() {
      let metrics = MockData.mockMetrics
      let types = metrics.map { $0.type }

      XCTAssertTrue(types.contains(.recovery), "Mock metrics should contain recovery")
      XCTAssertTrue(types.contains(.sleep), "Mock metrics should contain sleep")
      XCTAssertTrue(types.contains(.energy), "Mock metrics should contain energy")
      XCTAssertTrue(types.contains(.stress), "Mock metrics should contain stress")
    }

    func testMockMetricsScoresAreValid() {
      let metrics = MockData.mockMetrics

      for metric in metrics {
        XCTAssertGreaterThanOrEqual(metric.score, 0, "Score should be >= 0")
        XCTAssertLessThanOrEqual(metric.score, 100, "Score should be <= 100")
      }
    }

    func testMockAdditionalAdviceExists() {
      let advice = MockData.mockAdditionalAdvice
      XCTAssertFalse(advice.message.isEmpty, "Mock additional advice message should not be empty")
      XCTAssertFalse(advice.greeting.isEmpty, "Mock additional advice greeting should not be empty")
    }
  #endif
}
