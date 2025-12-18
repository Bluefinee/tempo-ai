import SwiftUI
import Testing

@testable import TempoAI

struct MetricDataModelTests {

    // MARK: - MetricType Tests

    @Test("MetricType labels are correctly localized")
    func metricTypeLabel() {
        #expect(MetricType.recovery.label == "回復")
        #expect(MetricType.sleep.label == "睡眠")
        #expect(MetricType.energy.label == "エネルギー")
        #expect(MetricType.stress.label == "ストレス")
    }

    @Test("MetricType has all 4 cases")
    func metricTypeAllCases() {
        #expect(MetricType.allCases.count == 4)
        #expect(MetricType.allCases.contains(.recovery))
        #expect(MetricType.allCases.contains(.sleep))
        #expect(MetricType.allCases.contains(.energy))
        #expect(MetricType.allCases.contains(.stress))
    }

    @Test("MetricType system image names are correct")
    func metricTypeSystemImageName() {
        #expect(MetricType.recovery.systemImageName == "heart.fill")
        #expect(MetricType.sleep.systemImageName == "moon.zzz.fill")
        #expect(MetricType.energy.systemImageName == "bolt.fill")
        #expect(MetricType.stress.systemImageName == "figure.mind.and.body")
    }

    // MARK: - MetricData Creation Tests

    @Test("MetricData can be created with correct values")
    func metricDataCreation() {
        let metric = MetricData(
            type: .recovery,
            score: 78,
            displayValue: "78"
        )

        #expect(metric.type == .recovery)
        #expect(metric.score == 78)
        #expect(metric.displayValue == "78")
    }

    @Test("Different MetricData instances have different IDs")
    func metricDataIdentifiable() {
        let metric1 = MetricData(type: .recovery, score: 78, displayValue: "78")
        let metric2 = MetricData(type: .recovery, score: 78, displayValue: "78")

        #expect(metric1.id != metric2.id)
    }

    // MARK: - Progress Bar Color Tests (Normal Metrics)

    @Test("High score (85) uses success color")
    func progressBarColorForHighScore() {
        let metric = MetricData(type: .recovery, score: 85, displayValue: "85")
        #expect(metric.progressBarColor == Color.tempoSuccess)
    }

    @Test("Good score (70) uses sage green color")
    func progressBarColorForGoodScore() {
        let metric = MetricData(type: .recovery, score: 70, displayValue: "70")
        #expect(metric.progressBarColor == Color.tempoSageGreen)
    }

    @Test("Normal score (50) uses warning color")
    func progressBarColorForNormalScore() {
        let metric = MetricData(type: .recovery, score: 50, displayValue: "50")
        #expect(metric.progressBarColor == Color.tempoWarning)
    }

    @Test("Low score (30) uses soft coral color")
    func progressBarColorForLowScore() {
        let metric = MetricData(type: .recovery, score: 30, displayValue: "30")
        #expect(metric.progressBarColor == Color.tempoSoftCoral)
    }

    // MARK: - Boundary Value Tests

    @Test("Score 40 uses warning color (boundary)")
    func progressBarColorAtBoundary40() {
        let metric = MetricData(type: .recovery, score: 40, displayValue: "40")
        #expect(metric.progressBarColor == Color.tempoWarning)
    }

    @Test("Score 60 uses sage green color (boundary)")
    func progressBarColorAtBoundary60() {
        let metric = MetricData(type: .recovery, score: 60, displayValue: "60")
        #expect(metric.progressBarColor == Color.tempoSageGreen)
    }

    @Test("Score 80 uses success color (boundary)")
    func progressBarColorAtBoundary80() {
        let metric = MetricData(type: .recovery, score: 80, displayValue: "80")
        #expect(metric.progressBarColor == Color.tempoSuccess)
    }

    // MARK: - Stress Color Tests (Inverted: Lower is Better)

    @Test("Low stress (20) uses success color (lower is better)")
    func stressColorForLowScore() {
        let metric = MetricData(type: .stress, score: 20, displayValue: "低")
        #expect(metric.progressBarColor == Color.tempoSuccess)
    }

    @Test("Medium-low stress (30) uses sage green color")
    func stressColorForMediumLowScore() {
        let metric = MetricData(type: .stress, score: 30, displayValue: "やや低")
        #expect(metric.progressBarColor == Color.tempoSageGreen)
    }

    @Test("Medium stress (50) uses warning color")
    func stressColorForMediumScore() {
        let metric = MetricData(type: .stress, score: 50, displayValue: "中")
        #expect(metric.progressBarColor == Color.tempoWarning)
    }

    @Test("High stress (80) uses soft coral color (higher is worse)")
    func stressColorForHighScore() {
        let metric = MetricData(type: .stress, score: 80, displayValue: "高")
        #expect(metric.progressBarColor == Color.tempoSoftCoral)
    }

    // MARK: - Progress Value Tests

    @Test("Progress value calculates correctly for score 78")
    func progressValue() {
        let metric = MetricData(type: .recovery, score: 78, displayValue: "78")
        #expect(abs(metric.progressValue - 0.78) < 0.001)
    }

    @Test("Progress value is 0.0 for score 0")
    func progressValueForZero() {
        let metric = MetricData(type: .recovery, score: 0, displayValue: "0")
        #expect(abs(metric.progressValue - 0.0) < 0.001)
    }

    @Test("Progress value is 1.0 for score 100")
    func progressValueForMax() {
        let metric = MetricData(type: .recovery, score: 100, displayValue: "100")
        #expect(abs(metric.progressValue - 1.0) < 0.001)
    }

    // MARK: - Codable Tests

    @Test("MetricData can be encoded and decoded")
    func metricDataEncodeDecode() throws {
        let original = MetricData(type: .sleep, score: 85, displayValue: "7.0h")

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        #expect(data.count > 0)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(MetricData.self, from: data)

        #expect(decoded.type == original.type)
        #expect(decoded.score == original.score)
        #expect(decoded.displayValue == original.displayValue)
    }

    @Test("MetricType can be encoded and decoded")
    func metricTypeCodable() throws {
        let original = MetricType.energy
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(MetricType.self, from: data)

        #expect(decoded == original)
    }

    // MARK: - Mock Data Tests

    #if DEBUG
    @Test("Mock metrics have 4 items")
    func mockMetricsExist() {
        let metrics = MockData.mockMetrics
        #expect(metrics.count == 4)
    }

    @Test("Mock metrics contain all metric types")
    func mockMetricsTypes() {
        let metrics = MockData.mockMetrics
        let types = metrics.map { $0.type }

        #expect(types.contains(.recovery))
        #expect(types.contains(.sleep))
        #expect(types.contains(.energy))
        #expect(types.contains(.stress))
    }

    @Test("Mock metrics have valid scores (0-100)")
    func mockMetricsScoresAreValid() {
        let metrics = MockData.mockMetrics

        for metric in metrics {
            #expect(metric.score >= 0)
            #expect(metric.score <= 100)
        }
    }

    @Test("Mock additional advice has content")
    func mockAdditionalAdviceExists() {
        let advice = MockData.mockAdditionalAdvice
        #expect(!advice.message.isEmpty)
        #expect(!advice.greeting.isEmpty)
    }
    #endif
}
