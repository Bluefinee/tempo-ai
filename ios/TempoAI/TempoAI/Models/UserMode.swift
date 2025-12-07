import Combine
import Foundation

enum UserMode: String, Codable, CaseIterable {
    case standard
    case athlete

    var displayName: String {
        switch self {
        case .standard: return "スタンダード"
        case .athlete: return "アスリート"
        }
    }

    var description: String {
        switch self {
        case .standard:
            return "効率的な日常、メンタルヘルス、疲労回避を重視。バッテリーは「生活するための残り体力」として解釈します。"
        case .athlete:
            return "パフォーマンス向上、トレーニング、肉体改造を重視。バッテリーは「トレーニングの燃料」として解釈します。"
        }
    }
}

@MainActor
class UserProfileManager: ObservableObject {
    @Published var currentMode: UserMode = .standard

    private let userDefaults: UserDefaults = UserDefaults.standard
    private let modeKey: String = "user_mode"

    init() {
        loadSavedMode()
    }

    func updateMode(_ mode: UserMode) {
        currentMode = mode
        userDefaults.set(mode.rawValue, forKey: modeKey)
    }

    private func loadSavedMode() {
        if let savedModeString = userDefaults.string(forKey: modeKey),
            let savedMode = UserMode(rawValue: savedModeString)
        {
            currentMode = savedMode
        }
    }
}

// MARK: - Singleton Access
extension UserProfileManager {
    static let shared = UserProfileManager()
}
