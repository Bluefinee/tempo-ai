import SwiftUI
import XCTest

@testable import TempoAI

final class MetricDataModelTests: XCTestCase {

  // MARK: - MetricType Tests

  func testMetricTypeIcon() {
    XCTAssertEqual(MetricType.recovery.icon, "💚", "Recovery icon should be green heart")
    XCTAssertEqual(MetricType.sleep.icon, "😴", "Sleep icon should be sleeping face")
    XCTAssertEqual(MetricType.energy.icon, "⚡", "Energy icon should be lightning bolt")
    XCTAssertEqual(MetricType.stress.icon, "🧘", "Stress icon should be meditation")
  }

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

  // MARK: - Status Calculation Tests

  func testStatusForHighScore() {
    let metric = MetricData(type: .recovery, score: 85, displayValue: "85")
    XCTAssertEqual(metric.status, "最高", "Score 85 should return '最高'")
  }

  func testStatusForScore80() {
    let metric = MetricData(type: .recovery, score: 80, displayValue: "80")
    XCTAssertEqual(metric.status, "最高", "Score 80 should return '最高'")
  }

  func testStatusForGoodScore() {
    let metric = MetricData(type: .recovery, score: 70, displayValue: "70")
    XCTAssertEqual(metric.status, "良好", "Score 70 should return '良好'")
  }

  func testStatusForScore60() {
    let metric = MetricData(type: .recovery, score: 60, displayValue: "60")
    XCTAssertEqual(metric.status, "良好", "Score 60 should return '良好'")
  }

  func testStatusForNormalScore() {
    let metric = MetricData(type: .recovery, score: 50, displayValue: "50")
    XCTAssertEqual(metric.status, "普通", "Score 50 should return '普通'")
  }

  func testStatusForScore40() {
    let metric = MetricData(type: .recovery, score: 40, displayValue: "40")
    XCTAssertEqual(metric.status, "普通", "Score 40 should return '普通'")
  }

  func testStatusForLowScore() {
    let metric = MetricData(type: .recovery, score: 30, displayValue: "30")
    XCTAssertEqual(metric.status, "やや低め", "Score 30 should return 'やや低め'")
  }

  func testStatusForScore20() {
    let metric = MetricData(type: .recovery, score: 20, displayValue: "20")
    XCTAssertEqual(metric.status, "やや低め", "Score 20 should return 'やや低め'")
  }

  func testStatusForVeryLowScore() {
    let metric = MetricData(type: .recovery, score: 15, displayValue: "15")
    XCTAssertEqual(metric.status, "注意", "Score 15 should return '注意'")
  }

  func testStatusForZeroScore() {
    let metric = MetricData(type: .recovery, score: 0, displayValue: "0")
    XCTAssertEqual(metric.status, "注意", "Score 0 should return '注意'")
  }

  func testStatusForMaxScore() {
    let metric = MetricData(type: .recovery, score: 100, displayValue: "100")
    XCTAssertEqual(metric.status, "最高", "Score 100 should return '最高'")
  }

  // MARK: - Progress Bar Color Tests

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
