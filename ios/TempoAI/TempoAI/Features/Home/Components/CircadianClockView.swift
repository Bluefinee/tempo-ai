//
//  CircadianClockView.swift
//  TempoAI
//
//  24-hour Circadian Clock with Activity/Rest Zones
//

import SwiftUI

// MARK: - CircadianClockView

/// 24時間サーカディアンクロック
/// クロノタイプに応じて活動ゾーンと休息ゾーンを表示
struct CircadianClockView: View {

    // MARK: - Properties

    let chronotype: Chronotype
    let currentTime: Date

    // MARK: - Private Properties

    private let size: CGFloat = 200
    private let strokeWidth: CGFloat = 20

    // MARK: - Computed Properties

    private var activityZoneStart: Int {
        CircadianClockCalculations.activityZoneStart(for: chronotype)
    }

    private var activityZoneEnd: Int {
        CircadianClockCalculations.activityZoneEnd(for: chronotype)
    }

    private var currentAngle: Double {
        CircadianClockCalculations.angleForDate(currentTime)
    }

    private var currentHour: Int {
        Calendar.current.component(.hour, from: currentTime)
    }

    // MARK: - Body

    var body: some View {
        Canvas { context, canvasSize in
            let center: CGPoint = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let radius: CGFloat = min(canvasSize.width, canvasSize.height) / 2 - strokeWidth / 2

            // Draw rest zone (full circle first)
            drawRestZone(context: context, center: center, radius: radius)

            // Draw activity zone (overlay)
            drawActivityZone(context: context, center: center, radius: radius)

            // Draw hour markers
            drawHourMarkers(context: context, center: center, radius: radius)

            // Draw zone icons
            drawZoneIcons(context: context, center: center, radius: radius)

            // Draw current time marker
            drawCurrentTimeMarker(context: context, center: center, radius: radius)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Drawing Methods

    private func drawRestZone(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let restColor: Color = TempoColors.secondary.opacity(0.6)
        var path: Path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .radians(0),
            endAngle: .radians(2 * .pi),
            clockwise: false
        )
        context.stroke(
            path,
            with: .color(restColor),
            lineWidth: strokeWidth
        )
    }

    private func drawActivityZone(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let activityColor: Color = TempoColors.primary.opacity(0.8)
        let startAngle: Double = CircadianClockCalculations.angleForHour(activityZoneStart)
        let endAngle: Double = CircadianClockCalculations.angleForHour(activityZoneEnd)

        var path: Path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .radians(startAngle),
            endAngle: .radians(endAngle),
            clockwise: false
        )
        context.stroke(
            path,
            with: .color(activityColor),
            lineWidth: strokeWidth
        )
    }

    private func drawHourMarkers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let markerHours: [Int] = [0, 6, 12, 18]
        let labels: [String] = ["24", "6", "12", "18"]

        for (index, hour) in markerHours.enumerated() {
            let angle: Double = CircadianClockCalculations.angleForHour(hour)
            let labelRadius: CGFloat = radius - strokeWidth - 12

            let x: CGFloat = center.x + labelRadius * CGFloat(cos(angle))
            let y: CGFloat = center.y + labelRadius * CGFloat(sin(angle))

            let text: Text = Text(labels[index])
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(TempoColors.textSecondary)

            context.draw(
                text,
                at: CGPoint(x: x, y: y)
            )
        }
    }

    private func drawZoneIcons(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // Activity icon position (middle of activity zone)
        let activityMiddleHour: Int = (activityZoneStart + activityZoneEnd) / 2
        let activityAngle: Double = CircadianClockCalculations.angleForHour(activityMiddleHour)
        let iconRadius: CGFloat = radius - strokeWidth - 30

        let activityX: CGFloat = center.x + iconRadius * CGFloat(cos(activityAngle))
        let activityY: CGFloat = center.y + iconRadius * CGFloat(sin(activityAngle))

        let fireText: Text = Text("🔥")
            .font(.system(size: 16))

        context.draw(fireText, at: CGPoint(x: activityX, y: activityY))

        // Rest icon position (middle of rest zone)
        let restMiddleHour: Int = (activityZoneEnd + activityZoneStart + 24) / 2 % 24
        let restAngle: Double = CircadianClockCalculations.angleForHour(restMiddleHour)

        let restX: CGFloat = center.x + iconRadius * CGFloat(cos(restAngle))
        let restY: CGFloat = center.y + iconRadius * CGFloat(sin(restAngle))

        let moonText: Text = Text("☽")
            .font(.system(size: 16))

        context.draw(moonText, at: CGPoint(x: restX, y: restY))
    }

    private func drawCurrentTimeMarker(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let markerRadius: CGFloat = 8
        let x: CGFloat = center.x + radius * CGFloat(cos(currentAngle))
        let y: CGFloat = center.y + radius * CGFloat(sin(currentAngle))

        // Outer circle (white border)
        var outerPath: Path = Path()
        outerPath.addArc(
            center: CGPoint(x: x, y: y),
            radius: markerRadius + 2,
            startAngle: .radians(0),
            endAngle: .radians(2 * .pi),
            clockwise: false
        )
        context.fill(outerPath, with: .color(.white))

        // Inner circle (accent color)
        var innerPath: Path = Path()
        innerPath.addArc(
            center: CGPoint(x: x, y: y),
            radius: markerRadius,
            startAngle: .radians(0),
            endAngle: .radians(2 * .pi),
            clockwise: false
        )
        context.fill(innerPath, with: .color(TempoColors.accent))
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        CircadianClockCalculations.accessibilityLabel(
            for: chronotype,
            currentHour: currentHour
        )
    }
}

// MARK: - CircadianClockCalculations

/// CircadianClock用の計算ロジック（テスト可能）
enum CircadianClockCalculations {

    // MARK: - Activity Zone

    /// 活動ゾーン開始時刻（クロノタイプ別）
    static func activityZoneStart(for chronotype: Chronotype) -> Int {
        switch chronotype {
        case .morning:
            return 6
        case .intermediate:
            return 8
        case .evening:
            return 10
        }
    }

    /// 活動ゾーン終了時刻（クロノタイプ別）
    static func activityZoneEnd(for chronotype: Chronotype) -> Int {
        switch chronotype {
        case .morning:
            return 18
        case .intermediate:
            return 20
        case .evening:
            return 22
        }
    }

    // MARK: - Angle Calculation

    /// 時刻から角度を計算（12時が上、時計回り）
    /// - Parameter hour: 時（0-23）
    /// - Returns: ラジアン角度
    static func angleForHour(_ hour: Int) -> Double {
        // 0時が上（-π/2）から開始、時計回りに進む
        let hourFraction: Double = Double(hour) / 24.0
        return hourFraction * 2 * .pi - .pi / 2
    }

    /// Dateから角度を計算（分も考慮）
    static func angleForDate(_ date: Date) -> Double {
        let calendar: Calendar = Calendar.current
        let hour: Int = calendar.component(.hour, from: date)
        let minute: Int = calendar.component(.minute, from: date)
        let hourWithMinutes: Double = Double(hour) + Double(minute) / 60.0
        return hourWithMinutes / 24.0 * 2 * .pi - .pi / 2
    }

    // MARK: - Zone Check

    /// 指定時刻が活動ゾーン内かどうか
    static func isInActivityZone(hour: Int, chronotype: Chronotype) -> Bool {
        let start: Int = activityZoneStart(for: chronotype)
        let end: Int = activityZoneEnd(for: chronotype)
        return hour >= start && hour < end
    }

    // MARK: - Accessibility

    /// アクセシビリティラベル生成
    static func accessibilityLabel(for chronotype: Chronotype, currentHour: Int) -> String {
        let start: Int = activityZoneStart(for: chronotype)
        let end: Int = activityZoneEnd(for: chronotype)
        let isActive: Bool = isInActivityZone(hour: currentHour, chronotype: chronotype)
        let zoneType: String = isActive ? "活動" : "休息"

        return "24時間サークル。現在\(currentHour)時、\(zoneType)ゾーンです。活動ゾーンは\(start)時から\(end)時までです。"
    }
}

// MARK: - Preview

#Preview("CircadianClockView - Morning") {
    VStack(spacing: 20) {
        Text("朝型")
            .font(TempoTypography.headline)
        CircadianClockView(
            chronotype: .morning,
            currentTime: Date()
        )
    }
    .padding()
    .background(TempoColors.background)
}

#Preview("CircadianClockView - Intermediate") {
    VStack(spacing: 20) {
        Text("中間型")
            .font(TempoTypography.headline)
        CircadianClockView(
            chronotype: .intermediate,
            currentTime: Date()
        )
    }
    .padding()
    .background(TempoColors.background)
}

#Preview("CircadianClockView - Evening") {
    VStack(spacing: 20) {
        Text("夜型")
            .font(TempoTypography.headline)
        CircadianClockView(
            chronotype: .evening,
            currentTime: Date()
        )
    }
    .padding()
    .background(TempoColors.background)
}
