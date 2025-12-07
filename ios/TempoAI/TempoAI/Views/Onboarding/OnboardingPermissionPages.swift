//
//  OnboardingPermissionPages.swift
//  TempoAI
//
//  Created by Claude for modular architecture on 2024-12-06.
//  Permission request pages for HealthKit and Location access
//

import SwiftUI

// MARK: - HealthKit Permission Page

struct HealthKitPermissionPageView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.healthKitIcon)

                Text(
                    viewModel.selectedLanguage == .japanese ? "HealthKit連携" : "HealthKit Integration"
                )
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.healthKitTitle)

                Text(
                    viewModel.selectedLanguage == .japanese
                        ? "より正確な分析のため、\nHealthKitデータへのアクセスを許可してください"
                        : "Allow access to HealthKit data\nfor more accurate analysis"
                )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.healthKitDescription)
            }

            VStack(spacing: 16) {
                PermissionFeatureRow(
                    icon: "bed.double.fill",
                    title: viewModel.selectedLanguage == .japanese ? "睡眠データ" : "Sleep Data",
                    description: viewModel.selectedLanguage == .japanese
                        ? "睡眠時間と質の分析" : "Sleep duration and quality analysis"
                )

                PermissionFeatureRow(
                    icon: "heart.fill",
                    title: viewModel.selectedLanguage == .japanese ? "心拍数・HRV" : "Heart Rate & HRV",
                    description: viewModel.selectedLanguage == .japanese
                        ? "自律神経とストレス状態" : "Autonomic nervous system and stress"
                )

                PermissionFeatureRow(
                    icon: "figure.walk",
                    title: viewModel.selectedLanguage == .japanese ? "活動データ" : "Activity Data",
                    description: viewModel.selectedLanguage == .japanese
                        ? "歩数・運動・カロリー消費" : "Steps, exercise, calorie burn"
                )
            }

            if viewModel.healthKitStatus == .granted {
                PermissionStatusRow(
                    status: .granted,
                    message: viewModel.selectedLanguage == .japanese
                        ? "HealthKitアクセスが許可されました" : "HealthKit access granted"
                )
            }

            Spacer()

            VStack(spacing: 12) {
                if viewModel.healthKitStatus != .granted {
                    Button(action: {
                        Task {
                            await viewModel.requestHealthKitPermission()
                        }
                    }) {
                        Text(
                            viewModel.selectedLanguage == .japanese ? "HealthKitを許可" : "Allow HealthKit"
                        )
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.healthKitAllowButton)

                    Button(action: {
                        viewModel.nextPage()
                    }) {
                        Text(
                            viewModel.selectedLanguage == .japanese ? "スキップ" : "Skip"
                        )
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    }
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.healthKitSkipButton)
                } else {
                    Button(action: {
                        viewModel.nextPage()
                    }) {
                        Text(
                            viewModel.selectedLanguage == .japanese ? "次へ" : "Next"
                        )
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.healthKitNextButton)
                }
            }
        }
        .padding(.horizontal, 24)
        .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.healthKitPage)
    }
}

// MARK: - Location Permission Page

struct LocationPermissionPageView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.locationIcon)

                Text(
                    viewModel.selectedLanguage == .japanese ? "位置情報の利用" : "Location Access"
                )
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.locationTitle)

                Text(
                    viewModel.selectedLanguage == .japanese
                        ? "環境データ（気温・湿度・大気質）を取得し、\nより精密な健康アドバイスを提供します"
                        : "Access environmental data (temperature, humidity, air quality)\nfor more precise health advice"
                )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.locationDescription)
            }

            VStack(spacing: 16) {
                PermissionFeatureRow(
                    icon: "thermometer",
                    title: viewModel.selectedLanguage == .japanese ? "気温・湿度" : "Temperature & Humidity",
                    description: viewModel.selectedLanguage == .japanese
                        ? "睡眠・運動への気候影響" : "Climate effects on sleep and exercise"
                )

                PermissionFeatureRow(
                    icon: "aqi.medium",
                    title: viewModel.selectedLanguage == .japanese ? "大気質" : "Air Quality",
                    description: viewModel.selectedLanguage == .japanese
                        ? "屋外活動の最適なタイミング" : "Optimal timing for outdoor activities"
                )

                PermissionFeatureRow(
                    icon: "sun.max.fill",
                    title: viewModel.selectedLanguage == .japanese ? "天候情報" : "Weather Conditions",
                    description: viewModel.selectedLanguage == .japanese ? "活動プランの最適化" : "Activity plan optimization"
                )
            }

            if viewModel.locationStatus == .granted {
                PermissionStatusRow(
                    status: .granted,
                    message: viewModel.selectedLanguage == .japanese ? "位置情報アクセスが許可されました" : "Location access granted"
                )
            }

            Spacer()

            VStack(spacing: 12) {
                if viewModel.locationStatus != .granted {
                    Button(action: {
                        Task {
                            await viewModel.requestLocationPermission()
                        }
                    }) {
                        Text(
                            viewModel.selectedLanguage == .japanese ? "位置情報を許可" : "Allow Location"
                        )
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.locationAllowButton)

                    Button(action: {
                        viewModel.completeOnboarding()
                    }) {
                        Text(
                            viewModel.selectedLanguage == .japanese ? "位置情報なしで続行" : "Continue without location"
                        )
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    }
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.locationSkipButton)
                } else {
                    Button(action: {
                        viewModel.completeOnboarding()
                    }) {
                        Text(
                            viewModel.selectedLanguage == .japanese ? "完了" : "Complete"
                        )
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.locationCompleteButton)
                }
            }
        }
        .padding(.horizontal, 24)
        .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.locationPage)
    }
}
