//
//  AnalyticsView.swift
//  TempoAI
//
//  Analytics画面メインView
//

import SwiftUI

// MARK: - AnalyticsView

/// 期間別スコアトレンド、リズム一貫性、インサイトを表示するAnalytics画面
struct AnalyticsView: View {

    // MARK: - Properties

    @StateObject private var viewModel: AnalyticsViewModel

    // MARK: - Initialization

    init(healthKitManager: HealthKitManager) {
        _viewModel = StateObject(wrappedValue: AnalyticsViewModel(healthKitManager: healthKitManager))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                TempoColors.background
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    SimpleLoadingView("分析中...")
                } else if viewModel.isCalibrating {
                    AnalyticsCalibrationView(
                        daysCompleted: viewModel.calibrationDaysCompleted,
                        requiredDays: CalibrationState.requiredDays
                    )
                } else {
                    analyticsContent
                }
            }
            .navigationTitle("分析")
            .navigationBarTitleDisplayMode(.large)
            .alert(item: $viewModel.error) { error in
                Alert(
                    title: Text("エラー"),
                    message: Text(error.errorDescription ?? "不明なエラー"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .task {
                await viewModel.loadAnalyticsData()
            }
        }
    }

    // MARK: - Analytics Content

    private var analyticsContent: some View {
        ScrollView {
            VStack(spacing: TempoSpacing.lg) {
                // Period Selector
                PeriodSelector(selectedPeriod: $viewModel.selectedPeriod)
                    .onChange(of: viewModel.selectedPeriod) { _, newValue in
                        Task {
                            await viewModel.changePeriod(newValue)
                        }
                    }

                // Score Trends Chart
                if !viewModel.scoreSnapshots.isEmpty {
                    ScoreTrendsChart(
                        snapshots: viewModel.scoreSnapshots,
                        period: viewModel.selectedPeriod
                    )
                }

                // Rhythm Consistency Card
                if let rhythmAnalysis = viewModel.rhythmAnalysis {
                    RhythmConsistencyCard(rhythmAnalysis: rhythmAnalysis)
                }

                // Insights Card
                InsightsCard(insights: viewModel.insights)
            }
            .padding(.horizontal, TempoSpacing.screenPadding)
            .padding(.vertical, TempoSpacing.md)
        }
        .refreshable {
            await viewModel.loadAnalyticsData()
        }
    }
}

// MARK: - Analytics Calibration View

/// Analytics画面専用のキャリブレーション表示（フルスクリーン）
private struct AnalyticsCalibrationView: View {

    // MARK: - Properties

    let daysCompleted: Int
    let requiredDays: Int

    private var progress: Double {
        guard requiredDays > 0 else { return 0 }
        return Double(daysCompleted) / Double(requiredDays)
    }

    private var remainingDays: Int {
        max(0, requiredDays - daysCompleted)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: TempoSpacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 64))
                .foregroundStyle(TempoColors.primary)

            // Title
            Text("データを収集中...")
                .font(TempoTypography.title2)
                .foregroundStyle(TempoColors.textPrimary)

            // Description
            VStack(spacing: TempoSpacing.sm) {
                Text("まだ十分なデータがありません。")
                    .font(TempoTypography.body)
                    .foregroundStyle(TempoColors.textSecondary)

                Text("\(requiredDays)日間のデータが蓄積されると、")
                    .font(TempoTypography.body)
                    .foregroundStyle(TempoColors.textSecondary)

                Text("詳細な分析をご覧いただけます。")
                    .font(TempoTypography.body)
                    .foregroundStyle(TempoColors.textSecondary)
            }
            .multilineTextAlignment(.center)

            // Progress
            VStack(spacing: TempoSpacing.sm) {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(TempoColors.primary)
                    .frame(maxWidth: 200)

                Text("現在: \(daysCompleted)/\(requiredDays)日 完了")
                    .font(TempoTypography.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(TempoColors.primary)

                if remainingDays > 0 {
                    Text("あと\(remainingDays)日")
                        .font(TempoTypography.caption)
                        .foregroundStyle(TempoColors.textTertiary)
                }
            }

            Spacer()
        }
        .padding(TempoSpacing.screenPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("データ収集中、\(daysCompleted)日完了、あと\(remainingDays)日")
    }
}

// MARK: - Preview

#Preview("Analytics View - With Data") {
    AnalyticsView(healthKitManager: HealthKitManager.mock())
}

#Preview("Analytics View - Calibrating") {
    AnalyticsCalibrationView(daysCompleted: 3, requiredDays: 7)
        .background(TempoColors.background)
}
