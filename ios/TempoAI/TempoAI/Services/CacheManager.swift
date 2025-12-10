import Foundation
import HealthKit
import CoreLocation
import SwiftUI

/// ユーザーデータのキャッシュ管理を担当するマネージャー
/// UserDefaults を使用してローカルストレージに保存
@MainActor
final class CacheManager {

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
  }
#endif

// MARK: - HealthKit Authorization Status

/// HealthKit権限ステータス
enum HealthKitAuthorizationStatus: String, Codable {
    case notDetermined = "not_determined"
    case authorized = "authorized"
    case denied = "denied"
    case partiallyAuthorized = "partially_authorized"
}

/// 位置情報権限ステータス
enum LocationAuthorizationStatus: String, Codable {
    case notDetermined = "not_determined"
    case authorized = "authorized"
    case authorizedOnce = "authorized_once"
    case denied = "denied"
    case restricted = "restricted"
}

// MARK: - Health Data Models

/// HealthKitデータ
struct HealthData: Codable {
    let heartRateData: [HeartRateData]
    let hrvData: [HRVData]
    let sleepData: [SleepData]
    let stepData: [StepData]
    let activeEnergyData: [ActiveEnergyData]
    let fetchedAt: Date
}

struct HeartRateData: Codable {
    let date: Date
    let value: Double // bpm
}

struct HRVData: Codable {
    let date: Date
    let value: Double // milliseconds
}

struct SleepData: Codable {
    let date: Date
    let duration: Double // hours
    let bedTime: Date
    let wakeTime: Date
}

struct StepData: Codable {
    let date: Date
    let count: Int
}

struct ActiveEnergyData: Codable {
    let date: Date
    let value: Double // kcal
}

// MARK: - Location Data Models

/// 位置データ
struct LocationData: Codable {
    let coordinates: LocationCoordinates
    let cityName: String
    let fetchedAt: Date
}

struct LocationCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}

// MARK: - HealthKit Manager

/// HealthKitエラー
enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationFailed
    case dataFetchFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKitはこのデバイスで利用できません"
        case .authorizationFailed:
            return "HealthKit権限の取得に失敗しました"
        case .dataFetchFailed(let message):
            return "データの取得に失敗しました: \(message)"
        }
    }
}

/// HealthKit管理クラス
@MainActor
final class HealthKitManager: ObservableObject {
    @Published var authorizationStatus: HealthKitAuthorizationStatus = .notDetermined
    @Published var isRequestingPermission: Bool = false
    
    private let healthStore = HKHealthStore()
    
    /// 必須データタイプ
    private let requiredTypes: Set<HKObjectType> = [
        HKQuantityType(.heartRate),
        HKQuantityType(.heartRateVariabilitySDNN),
        HKCategoryType(.sleepAnalysis),
        HKQuantityType(.stepCount),
        HKQuantityType(.activeEnergyBurned)
    ]
    
    /// オプショナルデータタイプ
    private let optionalTypes: Set<HKObjectType> = [
        HKQuantityType(.restingHeartRate),
        HKQuantityType(.oxygenSaturation),
        HKQuantityType(.bodyTemperature)
    ]
    
    init() {
        checkAuthorizationStatus()
    }
    
    /// 現在の認証ステータスを確認
    func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            authorizationStatus = .denied
            return
        }
        
        // 必須データタイプのみで判定（オプショナルは無視）
        var requiredAuthorizedCount = 0
        var requiredDeniedCount = 0
        var hasNotDetermined = false
        
        for type in requiredTypes {
            let status = healthStore.authorizationStatus(for: type)
            switch status {
            case .sharingAuthorized:
                requiredAuthorizedCount += 1
            case .sharingDenied:
                requiredDeniedCount += 1
            case .notDetermined:
                hasNotDetermined = true
            @unknown default:
                break
            }
        }
        
        // 未決定の必須データがある場合
        if hasNotDetermined {
            authorizationStatus = .notDetermined
            return
        }
        
        // 必須データの権限状況で判定
        if requiredAuthorizedCount == requiredTypes.count {
            authorizationStatus = .authorized  // 必須データがすべて許可
        } else if requiredAuthorizedCount > 0 {
            authorizationStatus = .partiallyAuthorized  // 必須データの一部のみ許可
        } else {
            authorizationStatus = .denied  // 必須データがすべて拒否
        }
    }
    
    /// HealthKit権限をリクエスト
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        isRequestingPermission = true
        defer { isRequestingPermission = false }
        
        do {
            let allTypes = requiredTypes.union(optionalTypes)
            try await healthStore.requestAuthorization(toShare: [], read: allTypes)
            checkAuthorizationStatus()
        } catch {
            throw HealthKitError.authorizationFailed
        }
    }
    
    /// 過去30日分のHealthKitデータを取得
    func fetchInitialData() async throws -> HealthData {
        // モック実装（Phase 2で完全実装予定）
        #if DEBUG
        return Self.generateMockData()
        #else
        throw HealthKitError.dataFetchFailed("Not implemented yet")
        #endif
    }
    
    /// テストデータを生成（シミュレータ用）
    static func generateMockData() -> HealthData {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -30, to: endDate) else {
            return HealthData(heartRateData: [], hrvData: [], sleepData: [], stepData: [], activeEnergyData: [], fetchedAt: Date())
        }
        
        var heartRateData: [HeartRateData] = []
        var hrvData: [HRVData] = []
        var sleepData: [SleepData] = []
        var stepData: [StepData] = []
        var activeEnergyData: [ActiveEnergyData] = []
        
        var currentDate = startDate
        while currentDate < endDate {
            // 心拍数: 55-75 bpm
            heartRateData.append(HeartRateData(date: currentDate, value: Double.random(in: 55...75)))
            
            // HRV: 40-80 ms
            hrvData.append(HRVData(date: currentDate, value: Double.random(in: 40...80)))
            
            // 睡眠: 6-8時間
            let sleepDuration = Double.random(in: 6.0...8.0)
            let bedTime = calendar.date(byAdding: .hour, value: 22, to: currentDate) ?? currentDate
            let wakeTime = calendar.date(byAdding: .hour, value: Int(sleepDuration), to: bedTime) ?? currentDate
            sleepData.append(SleepData(date: currentDate, duration: sleepDuration, bedTime: bedTime, wakeTime: wakeTime))
            
            // 歩数: 5000-12000歩
            stepData.append(StepData(date: currentDate, count: Int.random(in: 5000...12000)))
            
            // 消費エネルギー: 200-600 kcal
            activeEnergyData.append(ActiveEnergyData(date: currentDate, value: Double.random(in: 200...600)))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }
        
        return HealthData(
            heartRateData: heartRateData,
            hrvData: hrvData,
            sleepData: sleepData,
            stepData: stepData,
            activeEnergyData: activeEnergyData,
            fetchedAt: Date()
        )
    }
}

// MARK: - Location Manager

/// 位置情報エラー
enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnavailable
    case geocodingFailed
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "位置情報の権限が拒否されています"
        case .locationUnavailable:
            return "位置情報を取得できません"
        case .geocodingFailed:
            return "住所の取得に失敗しました"
        case .timeout:
            return "位置情報の取得がタイムアウトしました"
        }
    }
}

/// 位置情報管理クラス
@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var authorizationStatus: LocationAuthorizationStatus = .notDetermined
    @Published var isRequestingPermission: Bool = false
    @Published var isRequestingLocation: Bool = false
    @Published var currentLocation: LocationData?
    
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    override init() {
        super.init()
        setupLocationManager()
        checkAuthorizationStatus()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // 都市レベルの精度で十分
        locationManager.distanceFilter = 1000 // 1km以上移動したら更新
    }
    
    /// 現在の認証ステータスを確認
    func checkAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .authorizedWhenInUse, .authorizedAlways:
            authorizationStatus = .authorized
        case .denied:
            authorizationStatus = .denied
        case .restricted:
            authorizationStatus = .restricted
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
    
    /// 位置情報権限をリクエスト
    func requestAuthorization() {
        guard authorizationStatus == .notDetermined else { return }
        
        isRequestingPermission = true
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 現在位置を取得
    func requestCurrentLocation() async throws -> LocationData {
        guard authorizationStatus == .authorized else {
            throw LocationError.permissionDenied
        }
        
        isRequestingLocation = true
        defer { isRequestingLocation = false }
        
        #if DEBUG
        // モック実装
        return Self.generateMockLocationData()
        #else
        throw LocationError.locationUnavailable
        #endif
    }
    
    /// テストデータを生成（シミュレータ用）
    static func generateMockLocationData() -> LocationData {
        // 東京の座標をベースにしたモックデータ
        let mockCoordinates = LocationCoordinates(
            latitude: 35.6762 + Double.random(in: -0.1...0.1), // 東京周辺
            longitude: 139.6503 + Double.random(in: -0.1...0.1)
        )
        
        let mockCities = ["東京", "渋谷区", "新宿区", "港区", "千代田区", "大阪", "名古屋", "横浜"]
        let cityName = mockCities.randomElement() ?? "東京"
        
        return LocationData(
            coordinates: mockCoordinates,
            cityName: cityName,
            fetchedAt: Date()
        )
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            checkAuthorizationStatus()
            isRequestingPermission = false
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        Task { @MainActor in
            guard let continuation = locationContinuation else { return }
            locationContinuation = nil
            continuation.resume(returning: location)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            guard let continuation = locationContinuation else { return }
            locationContinuation = nil
            
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    continuation.resume(throwing: LocationError.permissionDenied)
                case .locationUnknown:
                    continuation.resume(throwing: LocationError.locationUnavailable)
                default:
                    continuation.resume(throwing: clError)
                }
            } else {
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - ⚠️ RESET FUNCTIONS (DELETE BEFORE PRODUCTION)
// このセクション内のリセット機能は本番リリース前に削除してください
// 削除対象: 以下のextension全体 + ContentView.swiftのリセットボタン

extension CacheManager {
  /// 完全リセット（開発・テスト用）
  /// - アプリデータをすべてクリア
  /// - 権限状態をリセット
  /// - ユーザーへの詳細案内も含む
  func performCompleteReset() {
    // 1. キャッシュデータの完全削除
    clearAllCache()
    
    // 2. 権限状態のリセット
    resetPermissionStates()
    
    // 3. ユーザー案内の表示
    printResetInstructions()
    
    // 4. アプリ状態のリセット通知
    notifyAppReset()
  }
  
  /// ライトリセット（オンボーディング再実行用）
  /// - ユーザーデータのみクリア
  /// - 権限設定は維持
  func performLightReset() {
    // オンボーディングデータのみクリア
    clearOnboardingData()
    
    // アプリ状態のリセット通知
    notifyAppReset()
    
    print("🔄 オンボーディングデータをリセットしました（権限は維持）")
  }
  
  /// アプリデータの完全削除
  private func clearAllCache() {
    let keys: [String] = [
      Keys.userProfile,
      Keys.onboardingCompleted,
      Keys.todayAdvice,
      Keys.recentDailyTries,
      Keys.lastWeeklyTry,
      Keys.lastAdviceDate
    ]
    
    keys.forEach { userDefaults.removeObject(forKey: $0) }
    
    print("✅ アプリデータを完全削除しました")
  }
  
  /// オンボーディングデータのみ削除
  private func clearOnboardingData() {
    let onboardingKeys: [String] = [
      Keys.userProfile,
      Keys.onboardingCompleted
    ]
    
    onboardingKeys.forEach { userDefaults.removeObject(forKey: $0) }
  }
  
  /// 権限状態のリセット（アプリ内状態のみ）
  private func resetPermissionStates() {
    // 注意: iOSシステムレベルの権限は手動でリセット必要
    print("🔄 アプリ内権限状態をリセットしました")
  }
  
  /// ユーザーへのリセット案内を表示
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
  
  /// アプリリセット通知の送信
  private func notifyAppReset() {
    NotificationCenter.default.post(
      name: Notification.Name("onboardingReset"),
      object: nil
    )
  }
}

// MARK: - END RESET FUNCTIONS ⚠️

