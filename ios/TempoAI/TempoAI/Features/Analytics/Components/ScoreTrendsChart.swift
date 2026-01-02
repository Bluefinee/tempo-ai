//
//  ScoreTrendsChart.swift
//  TempoAI
//
//  スコアトレンドグラフ（iOS 16+ Charts）
//

import Charts
import SwiftUI

// MARK: - ScoreType for Chart

/// グラフ用のスコアタイプ
enum ChartScoreType: String, CaseIterable {
    case autonomic = "自律神経"
    case sleep = "睡眠"
    case rhythm = "リズム"
    case activity = "活動量"

    var color: Color {
        switch self {
        case .autonomic:
            return TempoColors.primary
        case .sleep:
            return Color.blue
        case .rhythm:
            return Color.orange
        case .activity:
            return Color.purple
        }
    }

    var icon: String {
        switch self {
        case .autonomic:
            return "heart"
        case .sleep:
            return "moon"
        case .rhythm:
            return "circle.circle"
        case .activity:
            return "figure.walk"
        }
    }
}

// MARK: - ChartDataPoint

/// グラフ表示用データポイント
struct ChartDataPoint: Identifiable {
    let id: UUID = UUID()
    let date: Date
    let scoreType: ChartScoreType
    let value: Int
}

// MARK: - ScoreTrendsChart

/// スコアトレンドを表示する折れ線グラフ
struct ScoreTrendsChart: View {

    // MARK: - Properties

    let snapshots: [DailyScoreSnapshot]
    let period: TimePeriod

    @State private var selectedDate: Date?

    // MARK: - Computed Properties

    private var chartData: [ChartDataPoint] {
        var points: [ChartDataPoint] = []

        for snapshot in snapshots {
            points.append(ChartDataPoint(date: snapshot.date, scoreType: .autonomic, value: snapshot.autonomicScore))
            points.append(ChartDataPoint(date: snapshot.date, scoreType: .sleep, value: snapshot.sleepScore))
            points.append(ChartDataPoint(date: snapshot.date, scoreType: .rhythm, value: snapshot.rhythmScore))
            points.append(ChartDataPoint(date: snapshot.date, scoreType: .activity, value: snapshot.activityScore))
        }

        return points
    }

    private var selectedSnapshot: DailyScoreSnapshot? {
        guard let selectedDate = selectedDate else { return nil }
        return snapshots.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: TempoSpacing.md) {
            // Header
            Text("スコア推移")
                .font(TempoTypography.headline)
                .foregroundStyle(TempoColors.textPrimary)

            // Chart
            Chart(chartData) { dataPoint in
                LineMark(
                    x: .value("日付", dataPoint.date, unit: .day),
                    y: .value("スコア", dataPoint.value)
                )
                .foregroundStyle(by: .value("種類", dataPoint.scoreType.rawValue))
                .symbol(by: .value("種類", dataPoint.scoreType.rawValue))
                .interpolationMethod(.catmullRom)
            }
            .chartForegroundStyleScale([
                ChartScoreType.autonomic.rawValue: TempoColors.primary,
                ChartScoreType.sleep.rawValue: Color.blue,
                ChartScoreType.rhythm.rawValue: Color.orange,
                ChartScoreType.activity.rawValue: Color.purple
            ])
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: period == .weekly ? 1 : 5)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(TempoTypography.caption)
                        }
                    }
                }
            }
            .chartLegend(position: .bottom, alignment: .center, spacing: TempoSpacing.sm)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    let x: CGFloat = value.location.x - geometry[proxy.plotFrame!].origin.x
                                    if let date: Date = proxy.value(atX: x, as: Date.self) {
                                        selectedDate = date
                                    }
                                }
                        )
                }
            }
            .frame(height: 200)

            // Selected value display
            if let snapshot = selectedSnapshot {
                SelectedSnapshotView(snapshot: snapshot)
            }

            // Legend
            ChartLegendView()
        }
        .padding(TempoSpacing.cardPadding)
        .background(TempoColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("過去\(period.days)日間のスコア推移グラフ")
        .accessibilityHint("4種類のスコアの変化を表示しています")
    }
}

// MARK: - Selected Snapshot View

private struct SelectedSnapshotView: View {
    let snapshot: DailyScoreSnapshot

    private var formattedDate: String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: snapshot.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: TempoSpacing.xs) {
            Text(formattedDate)
                .font(TempoTypography.caption)
                .foregroundStyle(TempoColors.textSecondary)

            HStack(spacing: TempoSpacing.md) {
                ScoreLabel(type: .autonomic, value: snapshot.autonomicScore)
                ScoreLabel(type: .sleep, value: snapshot.sleepScore)
                ScoreLabel(type: .rhythm, value: snapshot.rhythmScore)
                ScoreLabel(type: .activity, value: snapshot.activityScore)
            }
        }
        .padding(TempoSpacing.sm)
        .background(TempoColors.background)
        .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.smallCornerRadius))
    }
}

// MARK: - Score Label

private struct ScoreLabel: View {
    let type: ChartScoreType
    let value: Int

    var body: some View {
        HStack(spacing: TempoSpacing.xxs) {
            Circle()
                .fill(type.color)
                .frame(width: 8, height: 8)
            Text("\(value)")
                .font(TempoTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(TempoColors.textPrimary)
        }
    }
}

// MARK: - Chart Legend View

private struct ChartLegendView: View {
    var body: some View {
        HStack(spacing: TempoSpacing.md) {
            ForEach(ChartScoreType.allCases, id: \.self) { type in
                HStack(spacing: TempoSpacing.xxs) {
                    Image(systemName: type.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(type.color)
                    Text(type.rawValue)
                        .font(TempoTypography.caption)
                        .foregroundStyle(TempoColors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Score Trends Chart") {
    let calendar: Calendar = Calendar.current
    let today: Date = calendar.startOfDay(for: Date())
    let snapshots: [DailyScoreSnapshot] = (0..<7).compactMap { offset -> DailyScoreSnapshot? in
        guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
        return DailyScoreSnapshot(
            date: date,
            autonomicScore: 65 + Int.random(in: -10...15),
            sleepScore: 70 + Int.random(in: -15...15),
            rhythmScore: 75 + Int.random(in: -10...10),
            activityScore: 60 + Int.random(in: -15...20)
        )
    }.reversed()

    return ScrollView {
        ScoreTrendsChart(snapshots: snapshots, period: .weekly)
            .padding()
    }
    .background(TempoColors.background)
}
