//
//  HomeView.swift
//  TempoAI
//
//  Home Screen with 6 Sections
//

import SwiftUI

// MARK: - HomeView

/// ホーム画面メインビュー
/// 6セクション構成: AI Insight, Morning Check-in, Scores, Clock, Environment, Quick Action
struct HomeView: View {

    // MARK: - Properties

    @StateObject private var viewModel: HomeViewModel = HomeViewModel()
    @State private var showInsightDetail: Bool = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TempoSpacing.lg) {
                    // [A] AI Daily Insight
                    aiInsightSection

                    // [B] Morning Check-in
                    morningCheckInSection

                    // [C] Scores
                    scoresSection

                    // [D] Circadian Clock
                    circadianClockSection

                    // [E] Environment + [F] Quick Action (side by side on larger screens)
                    HStack(alignment: .top, spacing: TempoSpacing.md) {
                        environmentSection
                        quickActionSection
                    }
                }
                .padding(.horizontal, TempoSpacing.screenPadding)
                .padding(.vertical, TempoSpacing.md)
            }
            .background(TempoColors.background)
            .refreshable {
                await viewModel.refreshData()
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showInsightDetail) {
                if let advice = viewModel.dailyAdvice {
                    InsightDetailView(
                        advice: advice,
                        onFeedback: { isHelpful in
                            Task {
                                await viewModel.submitFeedback(isHelpful)
                            }
                        }
                    )
                } else {
                    ProgressView("読み込み中...")
                }
            }
            .task {
                await viewModel.loadDashboardData()
            }
            .alert("エラー", isPresented: showingError) {
                Button("再試行") {
                    Task {
                        await viewModel.loadDashboardData()
                    }
                }
                Button("閉じる", role: .cancel) {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.errorDescription ?? "不明なエラー")
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var showingError: Binding<Bool> {
        Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )
    }

    // MARK: - Section Views

    private var aiInsightSection: some View {
        AIDailyInsightCard(
            greeting: viewModel.greeting,
            insight: viewModel.dailyAdvice,
            isLoading: viewModel.isLoading,
            loadingStep: viewModel.loadingStep,
            onReadMore: {
                showInsightDetail = true
            }
        )
    }

    private var morningCheckInSection: some View {
        MorningCheckInSection(
            mood: $viewModel.mood,
            todayMode: $viewModel.todayMode,
            isCompleted: viewModel.isMorningCheckInCompleted,
            onComplete: {
                Task {
                    await viewModel.submitMorningCheckIn()
                }
            }
        )
    }

    private var scoresSection: some View {
        ScoresSection(
            autonomicScore: viewModel.conditionAssessment?.autonomicScore.value,
            sleepScore: viewModel.conditionAssessment?.sleepScore.value,
            rhythmScore: viewModel.conditionAssessment?.rhythmScore.value,
            calibrationState: viewModel.calibrationState,
            onScoreTap: nil // TODO: Navigate to score detail
        )
    }

    private var circadianClockSection: some View {
        VStack(alignment: .leading, spacing: TempoSpacing.sm) {
            SectionHeader("体内リズム", icon: "clock")

            CardView {
                HStack {
                    Spacer()
                    CircadianClockView(
                        chronotype: viewModel.userProfile?.chronotype ?? .intermediate,
                        currentTime: Date()
                    )
                    Spacer()
                }
            }
        }
    }

    private var environmentSection: some View {
        EnvironmentCard(weather: viewModel.weather)
    }

    private var quickActionSection: some View {
        QuickActionCard(
            action: viewModel.dailyAdvice?.recommendedAction,
            onTap: {
                // TODO: Execute quick action
            }
        )
    }
}

// MARK: - Preview

#Preview("HomeView") {
    HomeView()
}

#Preview("HomeView - Loading") {
    HomeView()
}
