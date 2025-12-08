import SwiftUI
import HealthKit

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