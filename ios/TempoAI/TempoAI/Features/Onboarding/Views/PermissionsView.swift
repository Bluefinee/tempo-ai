import SwiftUI
import HealthKit
import CoreLocation

/// 権限リクエスト画面（オンボーディング画面6）
struct PermissionsView: View {

  // MARK: - Properties

  @Bindable var onboardingState: OnboardingState
  @StateObject private var healthKitManager = HealthKitManager()
  @StateObject private var locationManager = LocationManager()
  
  @State private var isRequestingPermissions: Bool = false
  @State private var permissionRequestCompleted: Bool = false
  
  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      // ヘッダー
      ProgressHeader(
        currentStep: onboardingState.currentStep,
        title: "Tempo AIに必要な権限"
      ) {
        onboardingState.goBack()
      }

      // メインコンテンツ
      ScrollView {
        VStack(spacing: 32) {
          // 説明テキスト
          VStack(spacing: 12) {
            Text("パーソナライズされたアドバイスのために")
              .font(.body)
              .foregroundColor(.tempoSecondaryText)
              .multilineTextAlignment(.center)

            Text("以下の権限が必要です。許可していただくとより正確で有用なアドバイスをお届けできます。")
              .font(.subheadline)
              .foregroundColor(.tempoSecondaryText)
              .multilineTextAlignment(.center)
          }
          .padding(.horizontal, 32)
          .padding(.top, 16)

          // 権限説明セクション
          VStack(spacing: 24) {
            PermissionCard(
              icon: "heart.text.square.fill",
              title: "ヘルスケアデータ",
              description: "睡眠や心拍数などのデータを分析し、あなたの健康状態に基づいたアドバイスを提供します。",
              color: Color.tempoSoftCoral
            )

            PermissionCard(
              icon: "location.fill",
              title: "位置情報",
              description: "天気や大気汚染の情報を取得し、環境に配慮したアドバイスをお届けします。",
              color: Color.tempoSageGreen
            )
          }
          .padding(.horizontal, 32)

          // 権限リクエスト結果表示（リクエスト完了後に表示）
          if permissionRequestCompleted {
            PermissionResultsView(
              healthKitStatus: healthKitManager.authorizationStatus,
              locationStatus: locationManager.authorizationStatus
            )
            .padding(.horizontal, 32)
          }

          Spacer(minLength: 100)
        }
      }

      // ボタンエリア
      VStack(spacing: 12) {
        if !permissionRequestCompleted {
          // 初期状態：権限リクエストボタン
          Button {
            Task {
              await requestPermissions()
            }
          } label: {
            HStack {
              if isRequestingPermissions {
                ProgressView()
                  .scaleEffect(0.8)
                  .progressViewStyle(CircularProgressViewStyle(tint: .white))
              } else {
                Image(systemName: "checkmark.shield.fill")
                  .font(.title3)
              }

              Text(isRequestingPermissions ? "⏳ 権限を確認中..." : "許可して始める")
                .font(.headline)
                .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(isRequestingPermissions ? Color.tempoMediumGray : Color.tempoSoftCoral)
            )
          }
          .disabled(isRequestingPermissions)

          Button {
            skipPermissions()
          } label: {
            Text("スキップ（後で設定）")
              .font(.body)
              .foregroundColor(.tempoSecondaryText)
          }
          .disabled(isRequestingPermissions)
        } else {
          // 権限リクエスト完了後：次へボタン
          Button {
            proceedToNext()
          } label: {
            Text("次へ")
              .font(.headline)
              .fontWeight(.semibold)
              .foregroundStyle(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 56)
              .background(
                RoundedRectangle(cornerRadius: 16)
                  .fill(Color.tempoSoftCoral)
              )
          }
        }
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 32)
    }
    .background(Color.tempoLightCream.ignoresSafeArea())
    .onAppear {
      // 既存の権限状態をチェック
      checkExistingPermissions()
    }
  }

  // MARK: - Methods

  /// 既存の権限状態をチェック
  private func checkExistingPermissions() {
    healthKitManager.checkAuthorizationStatus()
    locationManager.checkAuthorizationStatus()
    
    // 両方とも既に決定済みの場合はリクエストをスキップ
    if healthKitManager.authorizationStatus != .notDetermined && 
       locationManager.authorizationStatus != .notDetermined {
      permissionRequestCompleted = true
    }
  }

  /// 権限をリクエスト（設計書のステップフローに従って実装）
  @MainActor
  private func requestPermissions() async {
    isRequestingPermissions = true
    defer { 
      isRequestingPermissions = false 
      permissionRequestCompleted = true
    }

    // ステップ2: HealthKit権限ステータスの確認
    healthKitManager.checkAuthorizationStatus()
    
    if healthKitManager.authorizationStatus == .notDetermined {
      // ステップ3: HealthKit権限ダイアログ表示（未決定時のみ）
      do {
        try await healthKitManager.requestAuthorization()
      } catch {
        print("HealthKit permission request failed: \(error)")
      }
    }

    // 少し待機してからLocationの処理（UX的に自然にするため）
    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒

    // ステップ4: 位置情報権限ステータスの確認
    locationManager.checkAuthorizationStatus()
    
    if locationManager.authorizationStatus == .notDetermined {
      // ステップ5: 位置情報権限ダイアログ表示（未決定時のみ）
      locationManager.requestAuthorization()
      
      // 位置情報ダイアログの結果を待つ
      await waitForLocationPermissionResult()
    }

    // ステップ6: 権限ステータスの保存
    savePermissionStatuses()
  }
  
  /// 位置情報権限の結果を待つ
  private func waitForLocationPermissionResult() async {
    // 最大10秒待機
    let startTime = Date()
    while locationManager.authorizationStatus == .notDetermined && 
          Date().timeIntervalSince(startTime) < 10 {
      try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒ずつチェック
      locationManager.checkAuthorizationStatus()
    }
  }

  /// 権限ステータスを保存
  private func savePermissionStatuses() {
    onboardingState.updateAuthorizationStatus(
      healthKit: healthKitManager.authorizationStatus != .denied,
      location: locationManager.authorizationStatus == .authorized || 
                locationManager.authorizationStatus == .authorizedOnce
    )
  }

  /// 権限をスキップ
  private func skipPermissions() {
    onboardingState.updateAuthorizationStatus(healthKit: false, location: false)
    proceedToNext()
  }

  /// 次の画面へ進む
  private func proceedToNext() {
    onboardingState.proceedToNext()
  }
}

// MARK: - Permission Results

private struct PermissionResults {
  var healthKitGranted: Bool = false
  var locationGranted: Bool = false
  var hasResults: Bool = false
  
  var allGranted: Bool {
    hasResults && healthKitGranted && locationGranted
  }
  
  var someGranted: Bool {
    hasResults && (healthKitGranted || locationGranted)
  }
}

// MARK: - Permission Results View

private struct PermissionResultsView: View {
  let healthKitStatus: HealthKitAuthorizationStatus
  let locationStatus: LocationAuthorizationStatus
  
  var body: some View {
    VStack(spacing: 20) {
      // 全体的な結果サマリー
      VStack(spacing: 16) {
        // アイコンとメインメッセージ
        VStack(spacing: 12) {
          // 結果アイコン
          Image(systemName: resultIcon)
            .font(.system(size: 32, weight: .medium))
            .foregroundColor(resultColor)
            .frame(width: 60, height: 60)
            .background(
              Circle()
                .fill(resultColor.opacity(0.15))
            )
          
          // メインメッセージ
          Text(resultMessage)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.tempoPrimaryText)
            .multilineTextAlignment(.center)
            .lineLimit(2)
        }
        
        // 詳細説明
        if !allGranted {
          Text(detailMessage)
            .font(.body)
            .foregroundColor(.tempoSecondaryText)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .padding(.vertical, 20)
      .padding(.horizontal, 24)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(resultColor.opacity(0.05))
          .stroke(resultColor.opacity(0.2), lineWidth: 1.5)
      )
      
      // 個別権限状況
      VStack(spacing: 12) {
        Text("権限状況")
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(.tempoPrimaryText)
          .frame(maxWidth: .infinity, alignment: .leading)
        
        VStack(spacing: 8) {
          PermissionStatusRow(
            icon: "heart.text.square.fill",
            title: "ヘルスケアデータ",
            status: healthKitPermissionStatus,
            color: Color.tempoSoftCoral
          )
          
          PermissionStatusRow(
            icon: "location.fill",
            title: "位置情報",
            status: locationPermissionStatus,
            color: Color.tempoSageGreen
          )
        }
      }
      .padding(.all, 20)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(.white.opacity(0.8))
          .stroke(Color.tempoLightGray.opacity(0.3), lineWidth: 1)
      )
    }
  }
  
  // MARK: - Computed Properties
  
  private var allGranted: Bool {
    (healthKitStatus == .authorized) &&
    (locationStatus == .authorized || locationStatus == .authorizedOnce)
  }
  
  private var someGranted: Bool {
    (healthKitStatus == .authorized || healthKitStatus == .partiallyAuthorized) ||
    (locationStatus == .authorized || locationStatus == .authorizedOnce)
  }
  
  private var resultIcon: String {
    if allGranted {
      return "checkmark.circle.fill"
    } else if someGranted {
      return "exclamationmark.triangle.fill"
    } else {
      return "xmark.circle.fill"
    }
  }
  
  private var resultColor: Color {
    if allGranted {
      return Color.tempoSuccess
    } else if someGranted {
      return Color.tempoWarning
    } else {
      return Color.tempoError
    }
  }
  
  private var resultMessage: String {
    if allGranted {
      return "すべての権限が許可されました"
    } else if someGranted {
      return "一部の権限が許可されました"
    } else {
      return "権限が許可されませんでした"
    }
  }
  
  private var detailMessage: String {
    if someGranted {
      return "許可されなかった機能については、設定アプリから後で変更することができます。"
    } else {
      return "パーソナライズされたアドバイス機能が制限されますが、基本機能はご利用いただけます。設定アプリから権限を変更することもできます。"
    }
  }
  
  private var healthKitPermissionStatus: PermissionStatus {
    switch healthKitStatus {
    case .authorized:
      return .granted
    case .partiallyAuthorized:
      return .partial
    case .denied:
      return .denied
    case .notDetermined:
      return .pending
    }
  }
  
  private var locationPermissionStatus: PermissionStatus {
    switch locationStatus {
    case .authorized, .authorizedOnce:
      return .granted
    case .denied, .restricted:
      return .denied
    case .notDetermined:
      return .pending
    }
  }
}

// MARK: - Permission Status

enum PermissionStatus {
    case granted
    case partial
    case denied
    case pending
    
    var displayText: String {
        switch self {
        case .granted:
            return "許可"
        case .partial:
            return "一部許可"
        case .denied:
            return "拒否"
        case .pending:
            return "未設定"
        }
    }
    
    var statusColor: Color {
        switch self {
        case .granted:
            return Color.tempoSuccess
        case .partial:
            return Color.tempoWarning
        case .denied:
            return Color.tempoError
        case .pending:
            return Color.tempoMediumGray
        }
    }
    
    var icon: String {
        switch self {
        case .granted:
            return "checkmark.circle.fill"
        case .partial:
            return "exclamationmark.triangle.fill"
        case .denied:
            return "xmark.circle.fill"
        case .pending:
            return "clock.circle.fill"
        }
    }
}

// MARK: - Permission Status Row

private struct PermissionStatusRow: View {
    let icon: String
    let title: String
    let status: PermissionStatus
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // 機能アイコン
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            
            // タイトル
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.tempoPrimaryText)
            
            Spacer()
            
            // ステータス表示
            HStack(spacing: 6) {
                Image(systemName: status.icon)
                    .font(.caption)
                    .foregroundColor(status.statusColor)
                
                Text(status.displayText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(status.statusColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(status.statusColor.opacity(0.1))
                    .stroke(status.statusColor.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.tempoInputBackground)
        )
    }
}

// MARK: - Permission Result Row

private struct PermissionResultRow: View {
  let title: String
  let isGranted: Bool
  
  var body: some View {
    HStack {
      Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
        .font(.body)
        .foregroundColor(isGranted ? Color.green : Color.red)
      
      Text(title)
        .font(.body)
        .foregroundColor(.tempoPrimaryText)
      
      Spacer()
      
      Text(isGranted ? "許可" : "拒否")
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(isGranted ? Color.green : Color.red)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
          RoundedRectangle(cornerRadius: 6)
            .fill((isGranted ? Color.green : Color.red).opacity(0.1))
        )
    }
  }
}

// MARK: - Permission Card

private struct PermissionCard: View {
  let icon: String
  let title: String
  let description: String
  let color: Color

  var body: some View {
    HStack(spacing: 16) {
      // アイコン
      Image(systemName: icon)
        .font(.system(size: 28, weight: .medium))
        .foregroundStyle(color)
        .frame(width: 48, height: 48)
        .background(
          Circle()
            .fill(color.opacity(0.15))
        )

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.tempoPrimaryText)

        Text(description)
          .font(.body)
          .foregroundColor(.tempoSecondaryText)
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 20)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(.white.opacity(0.8))
        .stroke(color.opacity(0.3), lineWidth: 1)
    )
  }
}

// MARK: - Preview

#Preview {
  let state = OnboardingState()
  state.currentStep = 6
  return PermissionsView(onboardingState: state)
}
