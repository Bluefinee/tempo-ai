//
//  EnvironmentCard.swift
//  TempoAI
//
//  Environment Information Card (Weather Data)
//

import SwiftUI

// MARK: - EnvironmentCard

/// 環境情報カード
/// 気温、気圧（傾向）、UV指数を表示
struct EnvironmentCard: View {

    // MARK: - Properties

    let weather: WeatherData?

    // MARK: - Body

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TempoSpacing.sm) {
                // Header
                HStack {
                    Image(systemName: "cloud.sun")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(TempoColors.primary)

                    Text("環境")
                        .font(TempoTypography.subheadline)
                        .foregroundStyle(TempoColors.textSecondary)
                }

                if let weather = weather {
                    weatherContent(weather)
                } else {
                    placeholderContent
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Weather Content

    private func weatherContent(_ weather: WeatherData) -> some View {
        HStack(spacing: TempoSpacing.lg) {
            // Temperature
            environmentItem(
                icon: "thermometer",
                value: weather.temperatureString,
                label: nil
            )

            // Pressure with trend
            environmentItem(
                icon: weather.pressureTrend.icon,
                value: String(format: "%.0f", weather.pressure),
                label: "hPa"
            )

            // UV Index
            environmentItem(
                icon: "sun.max",
                value: "UV \(weather.uvIndex)",
                label: weather.uvLevel.rawValue
            )
        }
    }

    // MARK: - Environment Item

    private func environmentItem(
        icon: String,
        value: String,
        label: String?
    ) -> some View {
        VStack(spacing: TempoSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(TempoColors.textSecondary)

            Text(value)
                .font(TempoTypography.headline)
                .foregroundStyle(TempoColors.textPrimary)

            if let label = label {
                Text(label)
                    .font(TempoTypography.caption2)
                    .foregroundStyle(TempoColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Placeholder Content

    private var placeholderContent: some View {
        HStack {
            Spacer()
            Text("天気データを取得中...")
                .font(TempoTypography.caption)
                .foregroundStyle(TempoColors.textTertiary)
            Spacer()
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        guard let weather = weather else {
            return "環境情報: データ取得中"
        }

        return "環境情報。気温\(weather.temperatureString)、気圧\(Int(weather.pressure))ヘクトパスカル\(weather.pressureTrend.accessibilityLabel)、紫外線\(weather.uvLevel.accessibilityLabel)"
    }
}

// MARK: - Preview

#Preview("EnvironmentCard - With Data") {
    VStack {
        EnvironmentCard(
            weather: .mock()
        )
    }
    .padding()
    .background(TempoColors.background)
}

#Preview("EnvironmentCard - Loading") {
    VStack {
        EnvironmentCard(
            weather: nil
        )
    }
    .padding()
    .background(TempoColors.background)
}
