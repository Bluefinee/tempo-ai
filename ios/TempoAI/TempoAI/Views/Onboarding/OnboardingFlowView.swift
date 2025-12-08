import SwiftUI
import HealthKit
import CoreLocation

struct PermissionItem: Identifiable {
    let id: UUID = UUID()
    let icon: String
    let title: String
    let description: String
}

struct OnboardingFlowView: View {
    @EnvironmentObject private var coordinator: OnboardingCoordinator

    var body: some View {
        NavigationStack {
            ZStack {
                ColorPalette.pureWhite
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Simple progress indicator (Labor Illusion)
                    if coordinator.currentPage != .welcome && coordinator.currentPage != .completion {
                        HStack {
                            ForEach(0..<OnboardingPage.allCases.count, id: \.self) { index in
                                Circle()
                                    .fill(index <= coordinator.currentPage.rawValue ? 
                                          ColorPalette.richBlack : ColorPalette.gray300)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, Spacing.lg)
                    }

                    // Direct page rendering (no TabView complexity)
                    Group {
                        switch coordinator.currentPage {
                        case .welcome:
                            WelcomePage(onNext: coordinator.nextPage)
                        case .userMode:
                            UserModePage(
                                selectedMode: $coordinator.selectedUserMode,
                                onNext: coordinator.nextPage,
                                onBack: coordinator.previousPage
                            )
                        case .focusTags:
                            FocusTagsPage(
                                selectedTags: $coordinator.selectedTags,
                                onNext: coordinator.nextPage,
                                onBack: coordinator.previousPage
                            )
                        case .healthPermission:
                            HealthPermissionPage(
                                isGranted: $coordinator.healthPermissionGranted,
                                onNext: coordinator.nextPage,
                                onBack: coordinator.previousPage
                            )
                        case .locationPermission:
                            LocationPermissionPage(
                                isGranted: $coordinator.locationPermissionGranted,
                                onNext: coordinator.nextPage,
                                onBack: coordinator.previousPage
                            )
                        case .completion:
                            CompletionPage {
                                coordinator.completeOnboarding()
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - Simplified Permission Pages

struct HealthPermissionPage: View {
    @Binding var isGranted: Bool
    let onNext: () -> Void
    let onBack: (() -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header section (Serial Position Effect)
                VStack(spacing: Spacing.lg) {
                    Text("ヘルスケア連携")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(ColorPalette.richBlack)
                        .padding(.top, Spacing.lg)
                    
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Color(.systemRed))
                    
                    Text("より正確な分析のため\nヘルスケアデータを使用")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(ColorPalette.richBlack)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                
                // Premium data showcase
                VStack(spacing: Spacing.md) {
                    DataTypeRow(icon: "heart.fill", title: "", color: Color(.systemRed))
                    DataTypeRow(icon: "bed.double.fill", title: "", color: Color(.systemIndigo))
                    DataTypeRow(icon: "figure.walk", title: "", color: Color(.systemGreen))
                    DataTypeRow(icon: "plus.circle", title: "", color: ColorPalette.gray500)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.xl)
                
                // Bottom action area (Fitts's Law)
                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.md) {
                        Button(action: {
                            print("Health permission back button tapped")
                            onBack?()
                        }) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .medium))
                                Text("戻る")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(ColorPalette.gray600)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(ColorPalette.gray100)
                            .cornerRadius(CornerRadius.lg)
                        }
                        .contentShape(Rectangle())
                        
                        Button("ヘルスケアで許可") {
                            print("📱 Health permission button tapped")
                            Task {
                                let granted = await requestHealthPermissions()
                                isGranted = granted
                                onNext()
                            }
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(ColorPalette.pureWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(.systemRed))
                        .cornerRadius(CornerRadius.lg)
                        .contentShape(Rectangle())
                    }
                    
                    Button("後で設定") {
                        print("📱 Skip health permission tapped")
                        onNext()
                    }
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(ColorPalette.gray600)
                    .contentShape(Rectangle())
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
                .frame(height: 120) // Fixed height for bottom area
            }
        }
        .background(ColorPalette.pureWhite)
    }
    
    private func requestHealthPermissions() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit not available on this device")
            return false
        }
        
        let healthStore = HKHealthStore()
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            print("✅ HealthKit permission requested")
            return true
        } catch {
            print("❌ HealthKit permission error: \(error)")
            return false
        }
    }
}

struct LocationPermissionPage: View {
    @Binding var isGranted: Bool
    let onNext: () -> Void
    let onBack: (() -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header section (Serial Position Effect)
                VStack(spacing: Spacing.lg) {
                    Text("環境データ取得")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(ColorPalette.richBlack)
                        .padding(.top, Spacing.lg)
                    
                    Image(systemName: "location.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Color(.systemBlue))
                    
                    Text("気象・大気質情報で\nより正確なアドバイス")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(ColorPalette.richBlack)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                
                // Premium environmental showcase
                VStack(spacing: Spacing.md) {
                    DataTypeRow(icon: "thermometer", title: "", color: Color(.systemOrange))
                    DataTypeRow(icon: "cloud.fill", title: "", color: Color(.systemTeal))
                    DataTypeRow(icon: "sun.max.fill", title: "", color: Color(.systemYellow))
                    DataTypeRow(icon: "shield.lefthalf.filled", title: "", color: Color(.systemGreen))
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.xl)
                
                // Bottom action area (Fitts's Law)
                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.md) {
                        Button(action: {
                            print("Location permission back button tapped")
                            onBack?()
                        }) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .medium))
                                Text("戻る")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(ColorPalette.gray600)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(ColorPalette.gray100)
                            .cornerRadius(CornerRadius.lg)
                        }
                        .contentShape(Rectangle())
                        
                        Button("位置情報を許可") {
                            print("📱 Location permission button tapped")
                            Task {
                                let granted = await requestLocationPermissions()
                                isGranted = granted
                                onNext()
                            }
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(ColorPalette.pureWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(.systemBlue))
                        .cornerRadius(CornerRadius.lg)
                        .contentShape(Rectangle())
                    }
                    
                    Button("後で設定") {
                        print("📱 Skip location permission tapped")
                        onNext()
                    }
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(ColorPalette.gray600)
                    .contentShape(Rectangle())
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
                .frame(height: 120) // Fixed height for bottom area
            }
        }
        .background(ColorPalette.pureWhite)
    }
    
    private func requestLocationPermissions() async -> Bool {
        let locationManager = CLLocationManager()
        
        return await withCheckedContinuation { continuation in
            // Create a temporary delegate to handle the permission response
            let delegate = LocationPermissionDelegate { granted in
                continuation.resume(returning: granted)
            }
            
            locationManager.delegate = delegate
            
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                print("❌ Location permission denied or restricted")
                continuation.resume(returning: false)
            case .authorizedWhenInUse, .authorizedAlways:
                print("✅ Location already authorized")
                continuation.resume(returning: true)
            @unknown default:
                continuation.resume(returning: false)
            }
            
            // Keep delegate alive during permission request
            withExtendedLifetime(delegate) { }
        }
    }
}

// MARK: - Permission Helpers

class LocationPermissionDelegate: NSObject, CLLocationManagerDelegate {
    private let completion: (Bool) -> Void
    
    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location permission granted")
            completion(true)
        case .denied, .restricted:
            print("❌ Location permission denied")
            completion(false)
        case .notDetermined:
            // Wait for user decision
            break
        @unknown default:
            completion(false)
        }
    }
}

struct DataTypeRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Premium icon with subtle background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(friendlyTitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ColorPalette.richBlack)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(ColorPalette.gray600)
            }
            
            Spacer()
            
            // Subtle indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ColorPalette.gray400)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(ColorPalette.pureWhite)
                .shadow(
                    color: ColorPalette.richBlack.opacity(0.05),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        )
    }
    
    private var friendlyTitle: String {
        switch icon {
        case "heart.fill": return "心拍の状態"
        case "bed.double.fill": return "睡眠の質"
        case "figure.walk": return "日々の活動"
        case "plus.circle": return "その他の情報"
        case "thermometer": return "気温と湿度"
        case "cloud.fill": return "空気の質"
        case "sun.max.fill": return "紫外線情報"
        case "shield.lefthalf.filled": return "安心保護"
        default: return title
        }
    }
    
    private var subtitle: String {
        switch icon {
        case "heart.fill": return "ストレスや体調の把握"
        case "bed.double.fill": return "回復状態の分析"
        case "figure.walk": return "エネルギー消費の追跡"
        case "plus.circle": return "総合的な健康分析"
        case "thermometer": return "体感への影響予測"
        case "cloud.fill": return "呼吸への影響チェック"
        case "sun.max.fill": return "外出時のケア提案"
        case "shield.lefthalf.filled": return "市町村レベルのみ使用"
        default: return ""
        }
    }
}

struct OnboardingProgressBar: View {
    let currentPage: OnboardingPage
    let totalPages: Int

    private var progress: Double {
        Double(currentPage.rawValue) / Double(totalPages - 1)
    }

    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                Text("ステップ \(currentPage.rawValue + 1) / \(totalPages)")
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray500)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray500)
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: ColorPalette.success))
                .frame(height: 4)
        }
        .padding(.horizontal, Spacing.lg)
    }
}

struct OnboardingNavigationBar: View {
    let canGoBack: Bool
    let canProceed: Bool
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button("戻る", action: onBack)
                .buttonStyle(SecondaryButtonStyle())
                .opacity(canGoBack ? 1.0 : 0.3)
                .disabled(!canGoBack)
                .frame(maxWidth: .infinity)

            Button("次へ", action: onNext)
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canProceed)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, Spacing.lg)
    }
}

#Preview {
    OnboardingFlowView()
}
