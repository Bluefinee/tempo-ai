//
//  ScoresSection.swift
//  TempoAI
//
//  Scores Section with Calibration Support
//

import SwiftUI

// MARK: - ScoresSection

/// スコアセクション
/// キャリブレーション期間中は「---」表示 + CalibrationProgressView
struct ScoresSection: View {

    // MARK: - Properties

    let autonomicScore: Int?
    let sleepScore: Int?
    let rhythmScore: Int?
    let calibrationState: CalibrationState?
    let onScoreTap: ((ScoreCard.ScoreType) -> Void)?

    // MARK: - Computed Properties

    private var isCalibrating: Bool {
        guard let state = calibrationState else { return true }
        return !state.isComplete
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: TempoSpacing.sm) {
            // Section Header
            SectionHeader("今日のスコア", icon: "chart.bar")

            // Calibration Progress (if calibrating)
            if isCalibrating, let state = calibrationState {
                CalibrationProgressView(
                    daysCompleted: state.daysCompleted,
                    totalDays: CalibrationState.requiredDays
                )
            }

            // Score Card
            ScoreCard(
                autonomicScore: isCalibrating ? nil : autonomicScore,
                sleepScore: isCalibrating ? nil : sleepScore,
                rhythmScore: isCalibrating ? nil : rhythmScore,
                isCalibrating: isCalibrating,
                onTap: onScoreTap
            )
        }
    }
}

// MARK: - Preview

#Preview("ScoresSection - Calibrating") {
    VStack {
        ScoresSection(
            autonomicScore: nil,
            sleepScore: nil,
            rhythmScore: nil,
            calibrationState: CalibrationState(startDate: Date(), daysCompleted: 3),
            onScoreTap: nil
        )
    }
    .padding()
    .background(TempoColors.background)
}

#Preview("ScoresSection - With Scores") {
    VStack {
        ScoresSection(
            autonomicScore: 85,
            sleepScore: 72,
            rhythmScore: 88,
            calibrationState: CalibrationState(startDate: Date(), daysCompleted: 7),
            onScoreTap: { type in print("Tapped: \(type)") }
        )
    }
    .padding()
    .background(TempoColors.background)
}
