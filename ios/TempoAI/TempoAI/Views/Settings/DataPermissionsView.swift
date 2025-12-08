import SwiftUI
import HealthKit

struct DataPermissionsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var healthService = HealthService()
    @State private var showingExpandedPermissions = false
    @State private var showingAdvancedPermissions = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.lg) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(Color(.systemRed))
                        
                        Text("データ連携設定")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(ColorPalette.richBlack)
                        
                        Text("より詳しいデータで\nAI分析の精度を向上")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(ColorPalette.gray600)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    .padding(.top, Spacing.lg)
                    
                    // Current Status Summary
                    VStack(spacing: Spacing.md) {
                        Text("現在の設定状況")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(ColorPalette.richBlack)
                        
                        HStack {
                            StatusCard(
                                title: "基本データ",
                                count: "6項目",
                                subtitle: "心拍数、睡眠等",
                                color: Color(.systemGreen)
                            )
                            
                            StatusCard(
                                title: "拡張データ",
                                count: "0項目",
                                subtitle: "体温、血圧等",
                                color: Color(.systemOrange)
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    
                    // Basic Data Types (Always Visible)
                    VStack(spacing: Spacing.md) {
                        HStack {
                            Text("基本データ（現在許可済み）")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ColorPalette.richBlack)
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)
                        
                        VStack(spacing: Spacing.sm) {
                            DataPermissionRow(
                                icon: "heart.fill",
                                title: "心拍の状態",
                                subtitle: "心拍数、心拍変動、安静時心拍数",
                                isEnabled: true,
                                color: Color(.systemRed)
                            )
                            
                            DataPermissionRow(
                                icon: "bed.double.fill",
                                title: "睡眠の質",
                                subtitle: "睡眠時間、睡眠パターン分析",
                                isEnabled: true,
                                color: Color(.systemIndigo)
                            )
                            
                            DataPermissionRow(
                                icon: "figure.walk",
                                title: "日々の活動",
                                subtitle: "歩数、消費エネルギー",
                                isEnabled: true,
                                color: Color(.systemGreen)
                            )
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                    
                    // Expanded Data Types (Progressive Disclosure)
                    VStack(spacing: Spacing.md) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingExpandedPermissions.toggle()
                            }
                        }) {
                            HStack {
                                Text("拡張データで分析精度を向上")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(ColorPalette.richBlack)
                                
                                Spacer()
                                
                                Image(systemName: showingExpandedPermissions ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(.systemBlue))
                            }
                            .padding(.horizontal, Spacing.lg)
                        }
                        
                        if showingExpandedPermissions {
                            VStack(spacing: Spacing.sm) {
                                DataPermissionRow(
                                    icon: "thermometer",
                                    title: "体温データ",
                                    subtitle: "基礎体温、体調変化の検出",
                                    isEnabled: false,
                                    color: Color(.systemOrange)
                                )
                                
                                DataPermissionRow(
                                    icon: "drop.fill",
                                    title: "血圧・血中酸素",
                                    subtitle: "循環器系の健康状態",
                                    isEnabled: false,
                                    color: Color(.systemTeal)
                                )
                                
                                DataPermissionRow(
                                    icon: "scalemass.fill",
                                    title: "体重・体組成",
                                    subtitle: "体重、体脂肪率、筋肉量",
                                    isEnabled: false,
                                    color: Color(.systemPurple)
                                )
                                
                                DataPermissionRow(
                                    icon: "cup.and.saucer.fill",
                                    title: "栄養・水分摂取",
                                    subtitle: "水分摂取量、カフェイン摂取",
                                    isEnabled: false,
                                    color: Color(.systemBrown)
                                )
                            }
                            .padding(.horizontal, Spacing.lg)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                        }
                    }
                    
                    // Advanced Data Types (Expert Level)
                    if showingExpandedPermissions {
                        VStack(spacing: Spacing.md) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showingAdvancedPermissions.toggle()
                                }
                            }) {
                                HStack {
                                    Text("高度なデータ（上級者向け）")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(ColorPalette.richBlack)
                                    
                                    Spacer()
                                    
                                    Image(systemName: showingAdvancedPermissions ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(.systemBlue))
                                }
                                .padding(.horizontal, Spacing.lg)
                            }
                            
                            if showingAdvancedPermissions {
                                VStack(spacing: Spacing.sm) {
                                    DataPermissionRow(
                                        icon: "lungs.fill",
                                        title: "呼吸器データ",
                                        subtitle: "呼吸数、肺機能測定",
                                        isEnabled: false,
                                        color: Color(.systemMint)
                                    )
                                    
                                    DataPermissionRow(
                                        icon: "brain.head.profile",
                                        title: "メンタルヘルス",
                                        subtitle: "ストレスレベル、マインドフルネス",
                                        isEnabled: false,
                                        color: Color(.systemPink)
                                    )
                                    
                                    DataPermissionRow(
                                        icon: "location.fill",
                                        title: "環境データ",
                                        subtitle: "UV曝露、騒音レベル、気圧変化",
                                        isEnabled: false,
                                        color: Color(.systemYellow)
                                    )
                                }
                                .padding(.horizontal, Spacing.lg)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: Spacing.md) {
                        Button("新しいデータタイプを許可") {
                            // TODO: Present health permission flow
                            Task {
                                let _ = await requestExpandedPermissions()
                            }
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(ColorPalette.pureWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(.systemRed))
                        .cornerRadius(CornerRadius.lg)
                        .padding(.horizontal, Spacing.lg)
                        
                        Button("後で設定") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(ColorPalette.gray600)
                    }
                    .padding(.top, Spacing.lg)
                    
                    Spacer()
                }
            }
            .background(ColorPalette.pureWhite)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(.systemBlue))
                }
            }
        }
    }
    
    private func requestExpandedPermissions() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit not available on this device")
            return false
        }
        
        let healthStore = HKHealthStore()
        
        // Expanded data types for better analysis
        let expandedTypes: Set<HKObjectType> = [
            // Current basic types
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            
            // Expanded types
            HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!,
            HKObjectType.quantityType(forIdentifier: .leanBodyMass)!,
            HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCaffeine)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.quantityType(forIdentifier: .vo2Max)!
        ].compactMap { $0 }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: expandedTypes)
            print("✅ Expanded HealthKit permissions requested")
            return true
        } catch {
            print("❌ HealthKit permission error: \(error)")
            return false
        }
    }
}

struct StatusCard: View {
    let title: String
    let count: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(count)
                .font(.system(size: 24, weight: .light))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ColorPalette.richBlack)
            
            Text(subtitle)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(ColorPalette.gray500)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct DataPermissionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isEnabled: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(ColorPalette.richBlack)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(ColorPalette.gray600)
            }
            
            Spacer()
            
            // Status
            HStack(spacing: Spacing.xs) {
                if isEnabled {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(.systemGreen))
                    
                    Text("許可済み")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(.systemGreen))
                } else {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(.systemBlue))
                    
                    Text("追加可能")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(.systemBlue))
                }
            }
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(isEnabled ? Color(.systemGray6) : ColorPalette.pureWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(isEnabled ? Color(.systemGray4) : ColorPalette.gray200, lineWidth: 1)
                )
        )
    }
}

#Preview {
    DataPermissionsView()
}