//
//  OnboardingInfoPages.swift
//  TempoAI
//
//  Created by Claude for modular architecture on 2024-12-06.
//  Information and feature explanation pages for the onboarding flow
//

import SwiftUI

// MARK: - AI Analysis Page (Page 3: 何がわかるのか)

struct AIAnalysisPageView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.aiAnalysisIcon)

                Text(
                    viewModel.selectedLanguage == .japanese ? "AI分析の特徴" : "AI Analysis Features"
                )
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.aiAnalysisTitle)

                Text(
                    viewModel.selectedLanguage == .japanese
                        ? "Claude AIがあなたのデータを解析して\n個人に最適化されたアドバイスを生成"
                        : "Claude AI analyzes your data to generate\npersonalized advice just for you"
                )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.aiAnalysisDescription)
            }

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.selectedLanguage == .japanese ? "パターン認識" : "Pattern Recognition")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text(
                            viewModel.selectedLanguage == .japanese
                                ? "複数指標の相関関係を発見" : "Discover correlations across multiple metrics"
                        )
                        .font(.body)
                        .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)

                HStack(spacing: 12) {
                    Image(systemName: "target")
                        .foregroundColor(.purple)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.selectedLanguage == .japanese ? "個別最適化" : "Personalization")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text(
                            viewModel.selectedLanguage == .japanese
                                ? "あなたの生活習慣に合わせたアドバイス" : "Advice tailored to your lifestyle"
                        )
                        .font(.body)
                        .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)

                HStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.purple)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.selectedLanguage == .japanese ? "継続改善" : "Continuous Improvement")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text(
                            viewModel.selectedLanguage == .japanese
                                ? "データ蓄積により精度向上" : "Accuracy improves as data accumulates"
                        )
                        .font(.body)
                        .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
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
            .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.aiAnalysisNextButton)
        }
        .padding(.horizontal, 24)
        .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.aiAnalysisPage)
    }
}

// MARK: - Daily Plans Page (Page 4: 何をするアプリか)

struct DailyPlansPageView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dailyPlansIcon)

                Text(
                    viewModel.selectedLanguage == .japanese ? "日々の提案プラン" : "Daily Recommendations"
                )
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dailyPlansTitle)

                Text(
                    viewModel.selectedLanguage == .japanese
                        ? "毎日、あなたに最適なアクションプランを提案" : "Get personalized action plans every day"
                )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dailyPlansDescription)
            }

            VStack(spacing: 12) {
                PlanTypeRow(
                    icon: "moon.stars.fill",
                    title: viewModel.selectedLanguage == .japanese ? "睡眠改善" : "Sleep Optimization",
                    description: viewModel.selectedLanguage == .japanese
                        ? "就寝時間・環境の最適化提案" : "Bedtime and environment optimization"
                )

                PlanTypeRow(
                    icon: "figure.run",
                    title: viewModel.selectedLanguage == .japanese ? "運動プラン" : "Exercise Plans",
                    description: viewModel.selectedLanguage == .japanese
                        ? "体調に合わせた運動強度調整" : "Exercise intensity based on your condition"
                )

                PlanTypeRow(
                    icon: "leaf.fill",
                    title: viewModel.selectedLanguage == .japanese ? "ストレス管理" : "Stress Management",
                    description: viewModel.selectedLanguage == .japanese
                        ? "リラクゼーション・マインドフルネス" : "Relaxation and mindfulness techniques"
                )

                PlanTypeRow(
                    icon: "sun.max.fill",
                    title: viewModel.selectedLanguage == .japanese ? "環境対策" : "Environmental Care",
                    description: viewModel.selectedLanguage == .japanese
                        ? "天候・大気質に応じた行動提案" : "Actions based on weather and air quality"
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
            .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dailyPlansNextButton)
        }
        .padding(.horizontal, 24)
        .accessibilityIdentifier(UIIdentifiers.OnboardingFlow.dailyPlansPage)
    }
}
