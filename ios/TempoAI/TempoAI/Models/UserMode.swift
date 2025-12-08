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
    
    var appealingTitle: String {
        switch self {
        case .standard: return "バランスの取れた毎日を"
        case .athlete: return "日々のパフォーマンスを最大化"
        }
    }

    var description: String {
        switch self {
        case .standard:
            return "無理なく続けられる健康習慣で、心身のコンディションを整えます。日常生活の質を高めたいあなたへ"
        case .athlete:
            return "仕事、トレーニング、あらゆる場面で最高のコンディションを。戦略的なリカバリーで、持続的な高パフォーマンスを実現したいあなたへ"
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
