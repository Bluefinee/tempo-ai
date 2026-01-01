import Foundation
import os.log

// MARK: - LocalStorage

/// UserDefaultsベースのローカルストレージ実装
final class LocalStorage: LocalStorageProtocol, @unchecked Sendable {

    // MARK: - Properties

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private static let logger: Logger = Logger(subsystem: "com.tempoai", category: "LocalStorage")

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
            Self.logger.error("Failed to encode \(key): \(error.localizedDescription)")
            #if DEBUG
            assertionFailure("LocalStorage encoding failed for key: \(key)")
            #endif
        }
    }

    func load<T: Codable>(forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            Self.logger.error("Failed to decode \(key): \(error.localizedDescription)")
            #if DEBUG
            assertionFailure("LocalStorage decoding failed for key: \(key)")
            #endif
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

    /// キャッシュされたISO8601DateFormatter
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    /// 日付ベースのアドバイスキー
    static func advice(for date: Date) -> String {
        "advice_\(isoFormatter.string(from: date))"
    }

    /// 気分ログキー
    static let moodLogs: String = "mood_logs"

    /// 今日のモードログキー
    static let todayModeLogs: String = "today_mode_logs"

    /// フィードバックログキー
    static let feedbackLogs: String = "feedback_logs"
}
