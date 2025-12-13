import Foundation

/// ユーザーデータのキャッシュ管理を担当するマネージャー
/// UserDefaults を使用してローカルストレージに保存
/// CacheManagingプロトコルに準拠し、テスト時にモック実装を注入可能
@MainActor
final class CacheManager: CacheManaging {

    // MARK: - Singleton

    static let shared: CacheManager = CacheManager()

    // MARK: - DateFormatter Cache

    private static let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - Properties

    private let userDefaults: UserDefaults = UserDefaults.standard
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()

    // MARK: - Keys

    private enum Keys {
        static let userProfile: String = "userProfile"
        static let onboardingCompleted: String = "onboardingCompleted"
        static let todayAdvice: String = "todayAdvice"
        static let recentDailyTries: String = "recentDailyTries"
        static let lastWeeklyTry: String = "lastWeeklyTry"
        static let lastAdviceDate: String = "lastAdviceDate"
    }

    // MARK: - Initialization

    private init() {
        // JSONEncoder/Decoderの設定
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - User Profile Management

    /// ユーザープロフィールを保存
    /// - Parameter profile: 保存するユーザープロフィール
    /// - Throws: エンコードエラー
    func saveUserProfile(_ profile: UserProfile) throws {
        do {
            let data: Data = try encoder.encode(profile)
            userDefaults.set(data, forKey: Keys.userProfile)
        } catch {
            throw CacheError.encodingFailed(error)
        }
    }

    /// ユーザープロフィールを読み込み
    /// - Returns: 保存されたユーザープロフィール、またはnil
    /// - Throws: デコードエラー
    func loadUserProfile() throws -> UserProfile? {
        guard let data: Data = userDefaults.data(forKey: Keys.userProfile) else {
            return nil
        }

        do {
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            throw CacheError.decodingFailed(error)
        }
    }

    /// ユーザープロフィールを削除
    func deleteUserProfile() {
        userDefaults.removeObject(forKey: Keys.userProfile)
    }

    // MARK: - Onboarding Management

    /// オンボーディング完了フラグを保存
    /// - Parameter completed: 完了状態
    func saveOnboardingCompleted(_ completed: Bool) {
        userDefaults.set(completed, forKey: Keys.onboardingCompleted)
    }

    /// オンボーディング完了状態を読み込み
    /// - Returns: 完了状態（デフォルト: false）
    func isOnboardingCompleted() -> Bool {
        return userDefaults.bool(forKey: Keys.onboardingCompleted)
    }

    /// オンボーディング状態をリセット
    func resetOnboardingState() {
        userDefaults.removeObject(forKey: Keys.onboardingCompleted)
    }

    // MARK: - Advice Cache Management

    /// 当日のアドバイスを保存
    /// - Parameters:
    ///   - advice: 保存するアドバイス
    ///   - date: 対象日
    /// - Throws: エンコードエラー
    func saveAdvice<T: Codable>(_ advice: T, for date: Date) throws {
        let dateKey: String = adviceKey(for: date)

        do {
            let data: Data = try encoder.encode(advice)
            userDefaults.set(data, forKey: dateKey)
            userDefaults.set(date, forKey: Keys.lastAdviceDate)
        } catch {
            throw CacheError.encodingFailed(error)
        }
    }

    /// 指定日のアドバイスを読み込み
    /// - Parameters:
    ///   - date: 対象日
    ///   - type: アドバイスの型
    /// - Returns: 保存されたアドバイス、またはnil
    /// - Throws: デコードエラー
    func loadAdvice<T: Codable>(for date: Date, type: T.Type) throws -> T? {
        let dateKey: String = adviceKey(for: date)

        guard let data: Data = userDefaults.data(forKey: dateKey) else {
            return nil
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw CacheError.decodingFailed(error)
        }
    }

    /// 指定日にアドバイスがキャッシュされているかチェック
    /// - Parameter date: 対象日
    /// - Returns: キャッシュの有無
    func isAdviceCached(for date: Date) -> Bool {
        let dateKey: String = adviceKey(for: date)
        return userDefaults.data(forKey: dateKey) != nil
    }

    // MARK: - Private Methods

    /// 日付からアドバイスキーを生成
    /// - Parameter date: 対象日
    /// - Returns: ユニークなキー文字列
    private func adviceKey(for date: Date) -> String {
        return "advice_\(Self.dateFormatter.string(from: date))"
    }
}

// MARK: - Error Types

extension CacheManager {
    enum CacheError: Error, LocalizedError {
        case encodingFailed(Error)
        case decodingFailed(Error)
        case invalidData

        var errorDescription: String? {
            switch self {
            case .encodingFailed(let error):
                return "データの保存に失敗しました: \(error.localizedDescription)"
            case .decodingFailed(let error):
                return "データの読み込みに失敗しました: \(error.localizedDescription)"
            case .invalidData:
                return "無効なデータです"
            }
        }

        var recoverySuggestion: String? {
            switch self {
            case .encodingFailed, .decodingFailed:
                return "アプリを再起動してもう一度お試しください"
            case .invalidData:
                return "データをリセットしてください"
            }
        }
    }
}

// MARK: - Debug Extensions

#if DEBUG
extension CacheManager {
    /// テスト用サンプルデータを保存
    func setupSampleData() throws {
        let sampleProfile: UserProfile = UserProfile.sampleData
        try saveUserProfile(sampleProfile)
        saveOnboardingCompleted(true)
    }

    /// デバッグ情報を出力
    func printDebugInfo() {
        print("=== CacheManager Debug Info ===")
        print("Onboarding completed: \(isOnboardingCompleted())")
        print("User profile exists: \((try? loadUserProfile()) != nil)")
        print("==============================")
    }

    /// ライトリセット（オンボーディング再実行用）
    func performLightReset() {
        deleteUserProfile()
        resetOnboardingState()
        NotificationCenter.default.post(name: .onboardingReset, object: nil)
        print("🔄 オンボーディングデータをリセットしました（権限は維持）")
    }

    /// 完全リセット（開発・テスト用）
    func performCompleteReset() {
        deleteUserProfile()
        resetOnboardingState()
        printResetInstructions()
        NotificationCenter.default.post(name: .onboardingReset, object: nil)
    }

    private func printResetInstructions() {
        let separator = String(repeating: "=", count: 50)
        print(separator)
        print("🎯 RESET COMPLETED")
        print(separator)
        print("")
        print("✅ アプリデータが完全にリセットされました")
        print("")
        print("⚠️  iOS権限の完全リセットには手動操作が必要です:")
        print("")
        print("📱 HealthKit権限のリセット:")
        print("   設定アプリ > プライバシーとセキュリティ > HealthKit")
        print("   > Tempo AI > すべてのカテゴリをオフにする")
        print("")
        print("📍 位置情報権限のリセット:")
        print("   設定アプリ > プライバシーとセキュリティ > 位置情報")
        print("   > Tempo AI > 「なし」を選択")
        print("")
        print("🔄 完了後、アプリを再起動してオンボーディングを再テストできます")
        print(separator)
    }
}
#endif
