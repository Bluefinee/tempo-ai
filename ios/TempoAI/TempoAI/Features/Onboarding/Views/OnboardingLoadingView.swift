import SwiftUI
import HealthKit
import CoreLocation
import os.log

/// データ取得中画面（オンボーディング画面7）
struct OnboardingLoadingView: View {

  // MARK: - Properties

  private let logger: Logger = Logger(subsystem: "com.tempoai", category: "OnboardingLoading")
  
  @Bindable var onboardingState: OnboardingState
  @StateObject private var healthKitManager = HealthKitManager()
  @StateObject private var locationManager = LocationManager()
  
  let onComplete: () -> Void
  
  @State private var currentStep: LoadingStep = .checkingPermissions
  @State private var isCompleted: Bool = false
  @State private var healthData: HealthData?
  @State private var locationData: LocationData?
  
  // MARK: - Loading Steps
  
  enum LoadingStep: CaseIterable {
    case checkingPermissions  // "権限を確認しています..."
    case fetchingSleep        // "睡眠データを取得しています..."
    case fetchingHeartRate    // "心拍数データを取得しています..."
    case fetchingActivity     // "活動データを取得しています..."
    case fetchingLocation     // "位置情報を取得しています..."
    case preparingAdvice      // "アドバイスを準備しています..."
    case almostDone           // "もうすぐ完了です..."
    
    var message: String {
      switch self {
      case .checkingPermissions:
        return "権限を確認しています..."
      case .fetchingSleep:
        return "睡眠データを取得しています..."
      case .fetchingHeartRate:
        return "心拍数データを取得しています..."
      case .fetchingActivity:
        return "活動データを取得しています..."
      case .fetchingLocation:
        return "位置情報を取得しています..."
      case .preparingAdvice:
        return "アドバイスを準備しています..."
      case .almostDone:
        return "もうすぐ完了です..."
      }
    }
  }

  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      Spacer()
      
      // メインコンテンツ
      VStack(spacing: 32) {
        // ローディングインジケーター
        ProgressView()
          .scaleEffect(2.0)
          .progressViewStyle(CircularProgressViewStyle(tint: .tempoSageGreen))
        
        // メインメッセージ
        Text("あなた専用のアドバイスを準備中...")
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.tempoPrimaryText)
          .multilineTextAlignment(.center)
        
        // 進捗メッセージ
        Text(currentStep.message)
          .font(.body)
          .foregroundColor(.tempoSecondaryText)
          .multilineTextAlignment(.center)
          .animation(.easeInOut(duration: 0.3), value: currentStep)
      }
      
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.tempoLightCream.ignoresSafeArea())
    .onAppear {
      Task {
        await startDataLoading()
      }
    }
  }

  // MARK: - Methods

  /// データ取得処理を開始
  @MainActor
  private func startDataLoading() async {
    let steps = LoadingStep.allCases
    
    for (index, step) in steps.enumerated() {
      currentStep = step
      
      // 最低表示時間を確保（0.8秒）
      let startTime = Date()
      
      // 実際の処理を実行
      await performStep(step)
      
      // 最低表示時間の調整
      let elapsed = Date().timeIntervalSince(startTime)
      if elapsed < 0.8 {
        try? await Task.sleep(nanoseconds: UInt64((0.8 - elapsed) * 1_000_000_000))
      }
      
      // 最後のステップでない場合は、フェード効果のための短い間隔
      if index < steps.count - 1 {
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒
      }
    }
    
    // データ取得完了
    completeOnboarding()
  }
  
  /// 各ステップの実際の処理
  private func performStep(_ step: LoadingStep) async {
    switch step {
    case .checkingPermissions:
      healthKitManager.checkAuthorizationStatus()
      locationManager.checkAuthorizationStatus()
      
    case .fetchingSleep, .fetchingHeartRate, .fetchingActivity:
      // HealthKitデータを取得
      if healthKitManager.authorizationStatus == .authorized || 
         healthKitManager.authorizationStatus == .partiallyAuthorized {
        await fetchHealthData()
      }
      
    case .fetchingLocation:
      // 位置情報を取得
      if locationManager.authorizationStatus == .authorized || 
         locationManager.authorizationStatus == .authorizedOnce {
        await fetchLocationData()
      }
      
    case .preparingAdvice:
      // アドバイス準備（将来の実装のためのプレースホルダー）
      await prepareInitialAdvice()
      
    case .almostDone:
      // 最終準備
      break
    }
  }
  
  /// HealthKitデータを取得
  @MainActor
  private func fetchHealthData() async {
    guard healthData == nil else { return } // 重複取得を防ぐ
    
    do {
      let data = try await healthKitManager.fetchInitialData()
      healthData = data
      logger.info("HealthKit data fetched successfully")
    } catch {
      logger.error("HealthKit data fetch failed: \(error.localizedDescription)")
      // エラーの場合はモックデータを使用
      #if DEBUG
      healthData = HealthKitManager.generateMockData()
      logger.debug("Using mock HealthKit data for development")
      #endif
    }
  }
  
  /// 位置情報データを取得
  @MainActor
  private func fetchLocationData() async {
    guard locationData == nil else { return } // 重複取得を防ぐ
    
    do {
      let data = try await locationManager.requestCurrentLocation()
      locationData = data
      logger.info("Location data fetched successfully: \(data.cityName)")
    } catch {
      logger.error("Location data fetch failed: \(error.localizedDescription)")
      // エラーの場合はモックデータを使用
      #if DEBUG
      locationData = LocationManager.generateMockLocationData()
      logger.debug("Using mock location data for development")
      #endif
    }
  }
  
  /// 初期アドバイスを準備
  private func prepareInitialAdvice() async {
    // Phase 2で実装予定のアドバイス生成処理
    // 現在はプレースホルダー
    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
  }
  
  /// オンボーディング完了
  private func completeOnboarding() {
    // データをCacheManagerに保存
    saveCollectedData()
    
    // オンボーディング完了フラグを設定
    onboardingState.isCompleted = true
    CacheManager.shared.saveOnboardingCompleted(true)
    
    // ホーム画面への遷移（1秒後）
    Task { @MainActor in
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      withAnimation(.easeInOut(duration: 0.5)) {
        // ContentViewでハンドリングされるため、重複したフラグ設定を削除
        onComplete()
      }
    }
  }
  
  /// 収集したデータを保存
  private func saveCollectedData() {
    // ユーザープロフィールの保存
    if let userProfile = onboardingState.createUserProfile() {
      do {
        try CacheManager.shared.saveUserProfile(userProfile)
        logger.info("User profile saved successfully")
      } catch {
        logger.error("Failed to save user profile: \(error.localizedDescription)")
      }
    }
    
    // ヘルスデータの保存（今後の実装）
    if let healthData = healthData {
      logger.debug("Health data ready for storage: \(healthData.fetchedAt)")
      // TODO: Phase 2で実装 - ヘルスデータをサーバーに送信または高度なローカル保存
    }
    
    // 位置データの保存（今後の実装）
    if let locationData = locationData {
      logger.debug("Location data ready for storage: \(locationData.cityName)")
      // TODO: Phase 2で実装 - 位置データをサーバーに送信または高度なローカル保存
    }
  }
  
}

// MARK: - Preview

#Preview {
  @MainActor func makePreview() -> OnboardingLoadingView {
    let state = OnboardingState()
    state.currentStep = 7
    state.nickname = "さくら"
    state.interests = [.sleep, .nutrition]

    return OnboardingLoadingView(onboardingState: state) {
      print("Loading completed - Preview")
    }
  }
  
  return makePreview()
}
