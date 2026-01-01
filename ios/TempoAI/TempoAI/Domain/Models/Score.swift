import Foundation

// MARK: - Score Value Object

/// スコア値オブジェクト - ロジックを内包した不変オブジェクト
/// 0-100の範囲にクランプされ、ステータスとアイコンを自動計算する
struct Score: Equatable, Codable, Sendable {

    // MARK: - Properties

    let value: Int

    // MARK: - Initialization

    init(_ value: Int) {
        self.value = max(0, min(100, value))
    }

    // MARK: - Computed Properties

    var status: Status {
        switch value {
        case 80...100:
            return .excellent
        case 60..<80:
            return .good
        case 40..<60:
            return .fair
        case 20..<40:
            return .poor
        default:
            return .rest
        }
    }

    var icon: String {
        switch status {
        case .excellent:
            return "☀️"
        case .good:
            return "⛅"
        case .fair:
            return "🌥️"
        case .poor:
            return "🌧️"
        case .rest:
            return "⛈️"
        }
    }

    var statusLabel: String {
        status.rawValue
    }

    /// キャリブレーション期間中の表示用
    func displayValue(isCalibrating: Bool) -> String {
        isCalibrating ? "---" : "\(value)"
    }

    // MARK: - Status Enum

    enum Status: String, Codable, Sendable {
        case excellent = "絶好調"
        case good = "良好"
        case fair = "普通"
        case poor = "要休息"
        case rest = "休養優先"
    }
}

// MARK: - CustomStringConvertible

extension Score: CustomStringConvertible {
    var description: String {
        "\(value) (\(statusLabel))"
    }
}
