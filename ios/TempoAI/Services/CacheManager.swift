import Foundation

/// ユーザーデータのキャッシュ管理を担当するマネージャー
/// UserDefaults を使用してローカルストレージに保存
final class CacheManager: Sendable {

  // MARK: - Singleton

  static let shared: CacheManager = CacheManager()

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
      userDefaults.synchronize()
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
    userDefaults.synchronize()
  }

  // MARK: - Onboarding Management

  /// オンボーディング完了フラグを保存
  /// - Parameter completed: 完了状態
  func saveOnboardingCompleted(_ completed: Bool) {
    userDefaults.set(completed, forKey: Keys.onboardingCompleted)
    userDefaults.synchronize()
  }

  /// オンボーディング完了状態を読み込み
  /// - Returns: 完了状態（デフォルト: false）
  func isOnboardingCompleted() -> Bool {
    return userDefaults.bool(forKey: Keys.onboardingCompleted)
  }

  /// オンボーディング状態をリセット
  func resetOnboardingState() {
    userDefaults.removeObject(forKey: Keys.onboardingCompleted)
    userDefaults.synchronize()
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
      userDefaults.synchronize()
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

  /// 全キャッシュデータを削除
  func clearAllCache() {
    let keys: [String] = [
      Keys.userProfile,
      Keys.onboardingCompleted,
      Keys.todayAdvice,
      Keys.recentDailyTries,
      Keys.lastWeeklyTry,
      Keys.lastAdviceDate
    ]

    keys.forEach { userDefaults.removeObject(forKey: $0) }
    userDefaults.synchronize()
  }

  // MARK: - Private Methods

  /// 日付からアドバイスキーを生成
  /// - Parameter date: 対象日
  /// - Returns: ユニークなキー文字列
  private func adviceKey(for date: Date) -> String {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return "advice_\(formatter.string(from: date))"
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
  }
#endif
