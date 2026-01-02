//
//  LoadingView.swift
//  TempoAI
//
//  Loading View Component with Labor Illusion
//

import Combine
import SwiftUI

// MARK: - Loading View

/// ローディング表示コンポーネント
/// - Note: Labor Illusion対応（具体的なステップを表示）
struct LoadingView: View {

    // MARK: - Properties

    let steps: [String]
    @State private var currentStepIndex: Int = 0
    @State private var progress: Double = 0

    // MARK: - Timer

    private let timer = Timer.publish(every: 0.8, on: .main, in: .common).autoconnect()

    // MARK: - Body

    var body: some View {
        VStack(spacing: TempoSpacing.lg) {
            // Spinning indicator
            ProgressView()
                .scaleEffect(1.5)
                .tint(TempoColors.primary)

            // Current step text
            Text(steps[currentStepIndex])
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)
                .multilineTextAlignment(.center)
                .tempoAnimation(currentStepIndex)

            // Progress bar
            ProgressBar(progress: progress)
                .frame(height: 4)
                .frame(maxWidth: 200)
        }
        .onReceive(timer) { _ in
            withAnimation {
                if currentStepIndex < steps.count - 1 {
                    currentStepIndex += 1
                    progress = Double(currentStepIndex + 1) / Double(steps.count)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("読み込み中")
        .accessibilityValue(steps[currentStepIndex])
    }
}

// MARK: - Simple Loading View

/// シンプルなローディング表示
struct SimpleLoadingView: View {

    // MARK: - Properties

    let message: String?

    // MARK: - Initialization

    init(_ message: String? = nil) {
        self.message = message
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: TempoSpacing.md) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(TempoColors.primary)

            if let message = message {
                Text(message)
                    .font(TempoTypography.caption)
                    .foregroundStyle(TempoColors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message ?? "読み込み中")
    }
}

// MARK: - Progress Bar

/// プログレスバーコンポーネント
struct ProgressBar: View {

    // MARK: - Properties

    let progress: Double
    let backgroundColor: Color
    let foregroundColor: Color

    // MARK: - Initialization

    init(
        progress: Double,
        backgroundColor: Color = TempoColors.progressBackground,
        foregroundColor: Color = TempoColors.primary
    ) {
        self.progress = min(max(progress, 0), 1)
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 2)
                    .fill(backgroundColor)

                // Foreground
                RoundedRectangle(cornerRadius: 2)
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * progress)
                    .tempoAnimation(progress)
            }
        }
        .accessibilityValue("\(Int(progress * 100))パーセント")
    }
}

// MARK: - Calibration Progress View

/// キャリブレーション進捗表示
struct CalibrationProgressView: View {

    // MARK: - Properties

    let daysCompleted: Int
    let totalDays: Int

    // MARK: - Computed Properties

    private var progress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(daysCompleted) / Double(totalDays)
    }

    private var remainingDays: Int {
        max(0, totalDays - daysCompleted)
    }

    // MARK: - Body

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TempoSpacing.sm) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 20))
                        .foregroundStyle(TempoColors.primary)

                    Text("あなたのリズムを学習中...")
                        .font(TempoTypography.headline)
                        .foregroundStyle(TempoColors.textPrimary)
                }

                ProgressBar(progress: progress)
                    .frame(height: 8)

                HStack {
                    Text("\(daysCompleted)/\(totalDays)日")
                        .font(TempoTypography.caption)
                        .foregroundStyle(TempoColors.textSecondary)

                    Spacer()

                    if remainingDays > 0 {
                        Text("あと\(remainingDays)日でパーソナライズされたスコアをお届けできます")
                            .font(TempoTypography.caption)
                            .foregroundStyle(TempoColors.textSecondary)
                    } else {
                        Text("キャリブレーション完了!")
                            .font(TempoTypography.caption)
                            .foregroundStyle(TempoColors.primary)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("キャリブレーション進捗")
        .accessibilityValue("\(daysCompleted)日完了、あと\(remainingDays)日")
    }
}

// MARK: - AI Analysis Loading

/// AI分析ローディング（Labor Illusion対応）
struct AIAnalysisLoadingView: View {

    // MARK: - Default Steps

    static let defaultSteps: [String] = [
        "睡眠データを解析中...",
        "自律神経バランスを計算中...",
        "今日の環境を確認中...",
        "あなたへのアドバイスを作成中..."
    ]

    // MARK: - Body

    var body: some View {
        CardView {
            LoadingView(steps: Self.defaultSteps)
                .frame(maxWidth: .infinity)
                .padding(.vertical, TempoSpacing.lg)
        }
    }
}

// MARK: - Preview

#Preview("Loading Views") {
    ScrollView {
        VStack(spacing: TempoSpacing.xl) {
            Text("Simple Loading")
                .font(TempoTypography.headline)

            SimpleLoadingView("読み込み中...")
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .background(TempoColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))

            Divider()

            Text("Progress Bar")
                .font(TempoTypography.headline)

            VStack(spacing: TempoSpacing.sm) {
                ProgressBar(progress: 0.0)
                    .frame(height: 8)
                ProgressBar(progress: 0.3)
                    .frame(height: 8)
                ProgressBar(progress: 0.7)
                    .frame(height: 8)
                ProgressBar(progress: 1.0)
                    .frame(height: 8)
            }

            Divider()

            Text("Calibration Progress")
                .font(TempoTypography.headline)

            CalibrationProgressView(daysCompleted: 5, totalDays: 7)

            Divider()

            Text("AI Analysis Loading")
                .font(TempoTypography.headline)

            AIAnalysisLoadingView()
        }
        .screenPadding()
        .padding(.vertical, TempoSpacing.md)
    }
    .background(TempoColors.background)
}
