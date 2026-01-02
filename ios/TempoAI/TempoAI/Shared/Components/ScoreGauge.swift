//
//  ScoreGauge.swift
//  TempoAI
//
//  Score Gauge Component
//

import SwiftUI

// MARK: - Score Gauge

/// スコア表示ゲージコンポーネント
/// - Note: スコア値とアイコン、ラベルを表示
struct ScoreGauge: View {

    // MARK: - Properties

    let label: String
    let icon: String
    let score: Int?
    let isCalibrating: Bool

    // MARK: - Initialization

    /// スコアゲージを作成
    /// - Parameters:
    ///   - label: ラベル（例: "自律神経"）
    ///   - icon: SF Symbolsアイコン名（例: "heart"）
    ///   - score: スコア値（0-100）、nilの場合は「---」表示
    ///   - isCalibrating: キャリブレーション中かどうか
    init(
        label: String,
        icon: String,
        score: Int?,
        isCalibrating: Bool = false
    ) {
        self.label = label
        self.icon = icon
        self.score = score
        self.isCalibrating = isCalibrating
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: TempoSpacing.xs) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(scoreColor)

            // Score Value
            if isCalibrating || score == nil {
                Text("---")
                    .font(TempoTypography.title2)
                    .foregroundStyle(TempoColors.textTertiary)
            } else if let score = score {
                Text("\(score)")
                    .font(TempoTypography.scoreValue)
                    .foregroundStyle(scoreColor)
            }

            // Label
            Text(label)
                .font(TempoTypography.caption)
                .foregroundStyle(TempoColors.textSecondary)

            // Calibrating indicator
            if isCalibrating {
                Text("学習中")
                    .font(TempoTypography.caption2)
                    .foregroundStyle(TempoColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .scoreAccessibility(label: label, value: score, isCalibrating: isCalibrating)
    }

    // MARK: - Computed Properties

    private var scoreColor: Color {
        guard let score = score, !isCalibrating else {
            return TempoColors.textTertiary
        }
        return TempoColors.scoreColor(for: score)
    }
}

// MARK: - Score Card

/// スコアカードコンポーネント（横並び3スコア表示用）
struct ScoreCard: View {

    // MARK: - Properties

    let autonomicScore: Int?
    let sleepScore: Int?
    let rhythmScore: Int?
    let isCalibrating: Bool
    let onTap: ((ScoreType) -> Void)?

    // MARK: - Score Type

    enum ScoreType {
        case autonomic
        case sleep
        case rhythm
    }

    // MARK: - Initialization

    init(
        autonomicScore: Int? = nil,
        sleepScore: Int? = nil,
        rhythmScore: Int? = nil,
        isCalibrating: Bool = false,
        onTap: ((ScoreType) -> Void)? = nil
    ) {
        self.autonomicScore = autonomicScore
        self.sleepScore = sleepScore
        self.rhythmScore = rhythmScore
        self.isCalibrating = isCalibrating
        self.onTap = onTap
    }

    // MARK: - Body

    var body: some View {
        CardView {
            HStack(spacing: 0) {
                scoreGaugeButton(
                    label: "自律神経",
                    icon: "heart",
                    score: autonomicScore,
                    type: .autonomic
                )

                Divider()
                    .frame(height: 60)
                    .padding(.horizontal, TempoSpacing.xs)

                scoreGaugeButton(
                    label: "睡眠",
                    icon: "moon",
                    score: sleepScore,
                    type: .sleep
                )

                Divider()
                    .frame(height: 60)
                    .padding(.horizontal, TempoSpacing.xs)

                scoreGaugeButton(
                    label: "リズム",
                    icon: "circle.circle",
                    score: rhythmScore,
                    type: .rhythm
                )
            }
        }
    }

    // MARK: - Private Methods

    @ViewBuilder
    private func scoreGaugeButton(
        label: String,
        icon: String,
        score: Int?,
        type: ScoreType
    ) -> some View {
        if let onTap = onTap {
            Button {
                onTap(type)
            } label: {
                ScoreGauge(
                    label: label,
                    icon: icon,
                    score: score,
                    isCalibrating: isCalibrating
                )
            }
            .buttonStyle(.plain)
        } else {
            ScoreGauge(
                label: label,
                icon: icon,
                score: score,
                isCalibrating: isCalibrating
            )
        }
    }
}

// MARK: - Compact Score Badge

/// コンパクトスコアバッジ（小さなスペース用）
struct CompactScoreBadge: View {

    // MARK: - Properties

    let icon: String
    let score: Int?

    // MARK: - Body

    var body: some View {
        HStack(spacing: TempoSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            if let score = score {
                Text("\(score)")
                    .font(TempoTypography.caption)
                    .fontWeight(.semibold)
            } else {
                Text("--")
                    .font(TempoTypography.caption)
            }
        }
        .foregroundStyle(score.map { TempoColors.scoreColor(for: $0) } ?? TempoColors.textTertiary)
        .padding(.horizontal, TempoSpacing.xs)
        .padding(.vertical, TempoSpacing.xxs)
        .background(TempoColors.cardBackground)
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview("Score Gauges") {
    ScrollView {
        VStack(spacing: TempoSpacing.xl) {
            Text("Individual Score Gauges")
                .font(TempoTypography.headline)

            HStack(spacing: TempoSpacing.lg) {
                ScoreGauge(label: "自律神経", icon: "heart", score: 85)
                ScoreGauge(label: "睡眠", icon: "moon", score: 72)
                ScoreGauge(label: "リズム", icon: "circle.circle", score: 45)
            }
            .padding()
            .background(TempoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))

            Divider()

            Text("Score Card (Calibrating)")
                .font(TempoTypography.headline)

            ScoreCard(isCalibrating: true)

            Divider()

            Text("Score Card (With Data)")
                .font(TempoTypography.headline)

            ScoreCard(
                autonomicScore: 85,
                sleepScore: 72,
                rhythmScore: 88,
                onTap: { type in
                    print("Tapped: \(type)")
                }
            )

            Divider()

            Text("Compact Score Badges")
                .font(TempoTypography.headline)

            HStack(spacing: TempoSpacing.sm) {
                CompactScoreBadge(icon: "heart", score: 85)
                CompactScoreBadge(icon: "moon", score: 50)
                CompactScoreBadge(icon: "circle.circle", score: nil)
            }
        }
        .screenPadding()
        .padding(.vertical, TempoSpacing.md)
    }
    .background(TempoColors.background)
}
