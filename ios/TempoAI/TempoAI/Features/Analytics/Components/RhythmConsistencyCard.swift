//
//  RhythmConsistencyCard.swift
//  TempoAI
//
//  リズム一貫性表示カード
//

import SwiftUI

// MARK: - RhythmConsistencyCard

/// リズムの一貫性を表示するカード
struct RhythmConsistencyCard: View {

    // MARK: - Properties

    let rhythmAnalysis: RhythmAnalysis

    // MARK: - Body

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TempoSpacing.md) {
                // Header
                Text("リズムの一貫性")
                    .font(TempoTypography.headline)
                    .foregroundStyle(TempoColors.textPrimary)

                // Consistency rows
                ConsistencyRow(
                    label: "就寝時刻のばらつき",
                    value: "\(Int(rhythmAnalysis.bedtimeStddevMinutes))分",
                    status: rhythmAnalysis.bedtimeConsistencyStatus
                )

                Divider()

                ConsistencyRow(
                    label: "起床時刻のばらつき",
                    value: "\(Int(rhythmAnalysis.wakeTimeStddevMinutes))分",
                    status: rhythmAnalysis.wakeTimeConsistencyStatus
                )

                Divider()

                // Consecutive stable days
                HStack {
                    Text("連続安定日数")
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textSecondary)
                    Spacer()
                    Text("\(rhythmAnalysis.consecutiveStableDays)日")
                        .font(TempoTypography.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(TempoColors.textPrimary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("連続安定日数、\(rhythmAnalysis.consecutiveStableDays)日")
            }
        }
    }
}

// MARK: - ConsistencyRow

/// 一貫性行コンポーネント
private struct ConsistencyRow: View {

    // MARK: - Properties

    let label: String
    let value: String
    let status: ConsistencyStatus

    // MARK: - Body

    var body: some View {
        HStack {
            Text(label)
                .font(TempoTypography.body)
                .foregroundStyle(TempoColors.textSecondary)

            Spacer()

            HStack(spacing: TempoSpacing.xs) {
                Text(value)
                    .font(TempoTypography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(TempoColors.textPrimary)

                StatusBadge(status: status)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label)、\(value)、\(status.rawValue)")
    }
}

// MARK: - StatusBadge

/// ステータスバッジコンポーネント
private struct StatusBadge: View {

    // MARK: - Properties

    let status: ConsistencyStatus

    // MARK: - Body

    var body: some View {
        Text(status.rawValue)
            .font(TempoTypography.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, TempoSpacing.xs)
            .padding(.vertical, TempoSpacing.xxs)
            .background(TempoColors.consistencyColor(for: status))
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview("Rhythm Consistency Card") {
    VStack(spacing: TempoSpacing.lg) {
        // Stable rhythm
        RhythmConsistencyCard(
            rhythmAnalysis: RhythmAnalysis(
                bedtimeStddevMinutes: 25,
                wakeTimeStddevMinutes: 20,
                consecutiveStableDays: 5,
                wristTemperature: nil
            )
        )

        // Recovering rhythm
        RhythmConsistencyCard(
            rhythmAnalysis: RhythmAnalysis(
                bedtimeStddevMinutes: 35,
                wakeTimeStddevMinutes: 40,
                consecutiveStableDays: 3,
                wristTemperature: nil
            )
        )

        // Unstable rhythm
        RhythmConsistencyCard(
            rhythmAnalysis: RhythmAnalysis(
                bedtimeStddevMinutes: 55,
                wakeTimeStddevMinutes: 60,
                consecutiveStableDays: 1,
                wristTemperature: nil
            )
        )
    }
    .padding()
    .background(TempoColors.background)
}
