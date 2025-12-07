//
//  OnboardingPageViews.swift
//  TempoAI
//
//  Created by Claude for modular architecture on 2024-12-06.
//  Individual page implementations for the onboarding flow
//

import SwiftUI

// MARK: - Language Selection Page (Page 0: 言語選択)

struct LanguageSelectionPageView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Language Icon
            Image(systemName: "globe")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.languageSelectionIcon)

            VStack(spacing: 16) {
                Text("Choose Your Language")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.languageSelectionTitle)

                Text("言語を選択してください")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                Button(action: {
                    viewModel.setLanguage(.japanese)
                    viewModel.nextPage()
                }) {
                    HStack {
                        Text("🇯🇵")
                            .font(.title)
                        Text("日本語")
                            .font(.title2)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.japaneseButton)

                Button(action: {
                    viewModel.setLanguage(.english)
                    viewModel.nextPage()
                }) {
                    HStack {
                        Text("🇺🇸")
                            .font(.title)
                        Text("English")
                            .font(.title2)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.englishButton)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
        .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.languageSelectionPage)
    }
}

// MARK: - Welcome Page (Page 1: ようこそ)

struct WelcomePageView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // App Icon or Logo
            Image(systemName: "heart.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.welcomeIcon)

            VStack(spacing: 16) {
                Text(viewModel.selectedLanguage == .japanese ? "TempoAIへようこそ" : "Welcome to TempoAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.welcomeTitle)

                Text(
                    viewModel.selectedLanguage == .japanese
                        ? "あなたの健康データを分析し、\n毎日のアドバイスを提供します"
                        : "Analyze your health data and\nprovide daily personalized advice"
                )
                .font(.title2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.welcomeDescription)
            }

            Spacer()

            Button(action: {
                viewModel.nextPage()
            }) {
                Text(viewModel.selectedLanguage == .japanese ? "はじめる" : "Get Started")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.welcomeNextButton)
        }
        .padding(.horizontal, 24)
        .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.welcomePage)
    }
}

// MARK: - Data Sources Page (Page 2: 何を見るのか)

struct DataSourcesPageView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dataSourcesIcon)

                Text(
                    viewModel.selectedLanguage == .japanese ? "分析対象のデータ" : "Health Data We Analyze"
                )
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dataSourcesTitle)

                Text(
                    viewModel.selectedLanguage == .japanese
                        ? "これらの健康指標を総合的に分析します" : "We comprehensively analyze these health metrics"
                )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dataSourcesDescription)
            }

            LazyVStack(spacing: 12) {
                DataSourceCard(
                    icon: "bed.double.fill",
                    title: viewModel.selectedLanguage == .japanese ? "睡眠分析" : "Sleep Analysis",
                    description: viewModel.selectedLanguage == .japanese
                        ? "睡眠時間・質・深度の分析" : "Duration, quality, and depth analysis"
                )

                DataSourceCard(
                    icon: "heart.fill",
                    title: viewModel.selectedLanguage == .japanese ? "心拍変動" : "Heart Rate Variability",
                    description: viewModel.selectedLanguage == .japanese
                        ? "自律神経の状態を測定" : "Autonomic nervous system measurement"
                )

                DataSourceCard(
                    icon: "figure.walk",
                    title: viewModel.selectedLanguage == .japanese ? "活動量" : "Activity Levels",
                    description: viewModel.selectedLanguage == .japanese
                        ? "歩数・運動強度・カロリー" : "Steps, exercise intensity, calories"
                )

                DataSourceCard(
                    icon: "location.fill",
                    title: viewModel.selectedLanguage == .japanese ? "環境データ" : "Environmental Data",
                    description: viewModel.selectedLanguage == .japanese
                        ? "位置情報による気候・大気" : "Climate and air quality by location"
                )
            }

            Spacer()

            Button(action: {
                viewModel.nextPage()
            }) {
                Text(viewModel.selectedLanguage == .japanese ? "次へ" : "Next")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dataSourcesNextButton)
        }
        .padding(.horizontal, 24)
        .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dataSourcesPage)
    }
}
