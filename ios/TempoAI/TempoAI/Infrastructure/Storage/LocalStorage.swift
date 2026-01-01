import Foundation

// MARK: - LocalStorage

/// UserDefaultsベースのローカルストレージ実装
final class LocalStorage: LocalStorageProtocol, @unchecked Sendable {

    // MARK: - Properties

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // MARK: - Initialization

    init(
        defaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
    }

    // MARK: - Public Methods

    func save<T: Codable>(_ value: T, forKey key: String) {
        do {
            let data: Data = try encoder.encode(value)
            defaults.set(data, forKey: key)
        } catch {
            print("LocalStorage: Failed to save \(key): \(error.localizedDescription)")
        }
    }

    func load<T: Codable>(forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("LocalStorage: Failed to load \(key): \(error.localizedDescription)")
            return nil
        }
    }

    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }
}

// MARK: - StorageKeys

/// ストレージキー定数
enum StorageKeys {
    static let userProfile: String = "user_profile"
    static let calibrationState: String = "calibration_state"
    static let onboardingCompleted: String = "onboarding_completed"

    /// 日付ベースのアドバイスキー
    static func advice(for date: Date) -> String {
        let formatter: ISO8601DateFormatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return "advice_\(formatter.string(from: date))"
    }

    /// 気分ログキー
    static let moodLogs: String = "mood_logs"

    /// 今日のモードログキー
    static let todayModeLogs: String = "today_mode_logs"

    /// フィードバックログキー
    static let feedbackLogs: String = "feedback_logs"
}
