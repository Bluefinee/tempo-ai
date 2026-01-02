//
//  DataSection.swift
//  TempoAI
//
//  Data connection status section for Settings screen
//

import CoreLocation
import SwiftUI

// MARK: - DataSection

/// データ連携状態セクション
struct DataSection: View {

    // MARK: - Properties

    let healthKitStatus: HealthKitAuthorizationStatus
    let locationStatus: CLAuthorizationStatus

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: TempoSpacing.md) {
            SectionHeader("データ", icon: "externaldrive.connected.to.line.below")

            VStack(spacing: TempoSpacing.sm) {
                // HealthKit連携状態
                healthKitRow

                // 位置情報許可状態
                locationRow
            }
        }
    }

    // MARK: - Row Views

    private var healthKitRow: some View {
        FormRowView(label: "HealthKit連携", icon: "heart.text.square") {
            HStack(spacing: TempoSpacing.xs) {
                statusIndicator(isConnected: healthKitStatus.isAuthorized)
                Text(healthKitStatus.displayText)
                    .font(TempoTypography.body)
                    .foregroundStyle(statusColor(isConnected: healthKitStatus.isAuthorized))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HealthKit連携")
        .accessibilityValue(healthKitStatus.displayText)
    }

    private var locationRow: some View {
        FormRowView(label: "位置情報", icon: "location") {
            HStack(spacing: TempoSpacing.xs) {
                statusIndicator(isConnected: isLocationAuthorized)
                Text(locationStatusDisplayText)
                    .font(TempoTypography.body)
                    .foregroundStyle(statusColor(isConnected: isLocationAuthorized))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("位置情報")
        .accessibilityValue(locationStatusDisplayText)
    }

    // MARK: - Private Helpers

    private var isLocationAuthorized: Bool {
        switch locationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    private var locationStatusDisplayText: String {
        switch locationStatus {
        case .notDetermined:
            return "未設定"
        case .restricted:
            return "制限あり"
        case .denied:
            return "拒否"
        case .authorizedAlways:
            return "常に許可"
        case .authorizedWhenInUse:
            return "使用中のみ許可"
        @unknown default:
            return "不明"
        }
    }

    private func statusIndicator(isConnected: Bool) -> some View {
        Circle()
            .fill(statusColor(isConnected: isConnected))
            .frame(width: 8, height: 8)
    }

    private func statusColor(isConnected: Bool) -> Color {
        isConnected ? TempoColors.primary : TempoColors.textTertiary
    }
}

// MARK: - Preview

#if DEBUG
#Preview("DataSection - Connected") {
    ScrollView {
        DataSection(
            healthKitStatus: .authorized,
            locationStatus: .authorizedWhenInUse
        )
        .padding(TempoSpacing.screenPadding)
    }
    .background(TempoColors.background)
}

#Preview("DataSection - Not Connected") {
    ScrollView {
        DataSection(
            healthKitStatus: .notDetermined,
            locationStatus: .notDetermined
        )
        .padding(TempoSpacing.screenPadding)
    }
    .background(TempoColors.background)
}
#endif
