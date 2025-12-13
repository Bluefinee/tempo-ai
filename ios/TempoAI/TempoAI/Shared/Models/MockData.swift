import Foundation
import SwiftUI

// MARK: - Metric Data Model

/**
 * Represents a single health metric for display on the home screen
 * Used in the 2x2 metrics grid
 */
struct MetricData: Codable, Identifiable {
  let id: UUID = UUID()
  let type: MetricType
  let score: Int  // 0-100
  let displayValue: String  // "78" or "7.0h" or "低"

  private enum CodingKeys: String, CodingKey {
    case type, score, displayValue
  }

  /**
   * Progress bar color based on score ranges
   * Note: For stress, lower is better (inverted logic)
   */
  var progressBarColor: Color {
    let effectiveScore = type == .stress ? (100 - score) : score
    switch effectiveScore {
    case 80...100:
      return .tempoSuccess
    case 60..<80:
      return .tempoSageGreen
    case 40..<60:
      return .tempoWarning
    default:
      return .tempoSoftCoral
    }
  }

  /**
   * Progress value for progress bar (0.0 to 1.0)
   */
  var progressValue: Double {
    return Double(score) / 100.0
  }
}

// MARK: - Metric Type

enum MetricType: String, Codable, CaseIterable {
  case recovery = "recovery"
  case sleep = "sleep"
  case energy = "energy"
  case stress = "stress"

  var label: String {
    switch self {
    case .recovery:
      return "回復"
    case .sleep:
      return "睡眠"
    case .energy:
      return "エネルギー"
    case .stress:
      return "ストレス"
    }
  }

  var systemImageName: String {
    switch self {
    case .recovery:
      return "heart.fill"
    case .sleep:
      return "moon.zzz.fill"
    case .energy:
      return "bolt.fill"
    case .stress:
      return "figure.mind.and.body"
    }
  }
}

#if DEBUG
  struct MockData {

    // MARK: - Time-based Greeting

    static func getCurrentGreeting(nickname: String) -> String {
      let hour: Int = Calendar.current.component(.hour, from: Date())
      let timeOfDay: String

      switch hour {
      case 6..<13:
        timeOfDay = "おはようございます"
      case 13..<18:
        timeOfDay = "こんにちは"
      default:
        timeOfDay = "お疲れさまです"
      }

      return "\(nickname)さん、\(timeOfDay)"
    }

    // MARK: - Weather Mock Data

    static let mockWeather: WeatherInfo = WeatherInfo(
      cityName: "東京",
      temperature: 24,
      weatherIcon: "☀️"
    )

    // MARK: - Date Formatting

    static func getCurrentDateString() -> String {
      let formatter: DateFormatter = DateFormatter()
      formatter.dateFormat = "M月d日 EEEE"
      formatter.locale = Locale(identifier: "ja_JP")
      return formatter.string(from: Date())
    }

    // MARK: - Mock Metrics Data

    static let mockMetrics: [MetricData] = [
      MetricData(type: .recovery, score: 78, displayValue: "78"),
      MetricData(type: .sleep, score: 85, displayValue: "7.0h"),
      MetricData(type: .energy, score: 62, displayValue: "62"),
      MetricData(type: .stress, score: 45, displayValue: "低")
    ]

    // MARK: - Mock Additional Advice

    static let mockAdditionalAdvice: AdditionalAdvice = AdditionalAdvice(
      timeSlot: .afternoon,
      greeting: "お疲れさまです",
      message: "午前中の心拍数が普段より10%ほど高めで推移していました。深呼吸を3回、ゆっくり行ってみてください。",
      generatedAt: Date()
    )
  }

  struct WeatherInfo {
    let cityName: String
    let temperature: Int
    let weatherIcon: String
  }
#endif


