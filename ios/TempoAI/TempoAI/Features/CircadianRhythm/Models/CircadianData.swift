import Foundation

/// Data model for the Circadian Rhythm screen
/// Contains HRV data, sleep times, rhythm stability, and AI insight
struct CircadianData {
  /// Current HRV value in milliseconds
  let hrvValue: Int

  /// 7-day average HRV in milliseconds
  let hrvAverage: Int

  /// Last night's bedtime
  let bedtime: Date?

  /// This morning's wake time
  let wakeTime: Date?

  /// Rhythm stability score (0-100)
  let rhythmScore: Int

  /// Number of consecutive days with stable rhythm
  let consecutiveStableDays: Int

  /// Health scores for HRV, sleep, rhythm, and activity
  let scores: HealthScores

  /// AI insight text with causal relationships
  let insight: String

  /// Percentage difference from 7-day average
  var hrvDifferencePercent: Double {
    guard hrvAverage > 0 else { return 0 }
    return ((Double(hrvValue) - Double(hrvAverage)) / Double(hrvAverage)) * 100
  }

  /// Formatted HRV difference string (e.g., "+9%" or "-5%")
  var hrvDifferenceText: String {
    let percent = Int(hrvDifferencePercent.rounded())
    if percent >= 0 {
      return "+\(percent)%"
    } else {
      return "\(percent)%"
    }
  }

  /// Formatted bedtime string (e.g., "23:15")
  var bedtimeText: String {
    guard let bedtime else { return "--:--" }
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: bedtime)
  }

  /// Formatted wake time string (e.g., "7:05")
  var wakeTimeText: String {
    guard let wakeTime else { return "--:--" }
    let formatter = DateFormatter()
    formatter.dateFormat = "H:mm"
    return formatter.string(from: wakeTime)
  }
}

// MARK: - Rhythm Status

extension CircadianData {
  /// Rhythm stability status based on score and consecutive days
  enum RhythmStatus {
    case excellent(days: Int)
    case good
    case unstable
    case poor

    var displayText: String {
      switch self {
      case .excellent(let days):
        return "\(days)日連続で安定 → 回復効率アップ中"
      case .good:
        return "リズムが整っています"
      case .unstable:
        return "就寝時刻にばらつきがあります"
      case .poor:
        return "リズムの乱れが回復を妨げています"
      }
    }

    var statusLabel: String {
      switch self {
      case .excellent:
        return "良好"
      case .good:
        return "良好"
      case .unstable:
        return "やや不安定"
      case .poor:
        return "不安定"
      }
    }

    var filledDots: Int {
      switch self {
      case .excellent:
        return 5
      case .good:
        return 4
      case .unstable:
        return 3
      case .poor:
        return 2
      }
    }
  }

  var rhythmStatus: RhythmStatus {
    switch rhythmScore {
    case 70...100:
      if consecutiveStableDays >= 3 {
        return .excellent(days: consecutiveStableDays)
      } else {
        return .good
      }
    case 50..<70:
      return .unstable
    default:
      return .poor
    }
  }
}

// MARK: - Mock Data

extension CircadianData {
  /// Mock data for development and previews
  static var mock: CircadianData {
    let calendar = Calendar.current
    let now = Date()

    // Create bedtime at 23:15 last night
    var bedtimeComponents = calendar.dateComponents([.year, .month, .day], from: now)
    bedtimeComponents.day! -= 1
    bedtimeComponents.hour = 23
    bedtimeComponents.minute = 15
    let bedtime = calendar.date(from: bedtimeComponents)

    // Create wake time at 7:05 this morning
    var wakeComponents = calendar.dateComponents([.year, .month, .day], from: now)
    wakeComponents.hour = 7
    wakeComponents.minute = 5
    let wakeTime = calendar.date(from: wakeComponents)

    return CircadianData(
      hrvValue: 72,
      hrvAverage: 66,
      bedtime: bedtime,
      wakeTime: wakeTime,
      rhythmScore: 78,
      consecutiveStableDays: 3,
      scores: HealthScores(hrv: 85, sleep: 82, rhythm: 78, activity: 70),
      insight: "昨夜は就寝が30分早かったため、HRVが+9%改善しました。3日連続でリズムが安定しているため、回復効率がアップしています。"
    )
  }

  /// Mock data with poor rhythm for testing
  static var mockPoorRhythm: CircadianData {
    CircadianData(
      hrvValue: 45,
      hrvAverage: 55,
      bedtime: nil,
      wakeTime: nil,
      rhythmScore: 35,
      consecutiveStableDays: 0,
      scores: HealthScores(hrv: 45, sleep: 40, rhythm: 35, activity: 55),
      insight: "睡眠リズムが不安定なため、HRVが低下しています。まずは就寝時刻を一定に保つことから始めてみましょう。"
    )
  }
}
