import SwiftUI

/// 24時間サークル（Solar Sync）
/// 外周: 太陽の動き、内周: 体内時計、中央: 現在ステータス
struct SolarSyncCircleView: View {
    let sunriseTime: Date
    let sunsetTime: Date
    let phaseShiftHours: Double?

    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private let outerRingWidth: CGFloat = 16
    private let innerRingWidth: CGFloat = 12
    private let markerSize: CGFloat = 24

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let outerRadius = (size / 2) - 24
            let innerRadius = outerRadius - outerRingWidth - 8

            ZStack {
                // 背景リング（24時間全体）
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: outerRingWidth)
                    .frame(width: outerRadius * 2, height: outerRadius * 2)

                // 外周: 昼間アーク（日の出〜日の入り）
                SunArc(
                    startAngle: angleForTime(sunriseTime),
                    endAngle: angleForTime(sunsetTime)
                )
                .stroke(
                    Color.tempoSageGreen.opacity(0.3),
                    style: StrokeStyle(lineWidth: outerRingWidth, lineCap: .round)
                )
                .frame(width: outerRadius * 2, height: outerRadius * 2)

                // 内周: 体内時計（体温データがある場合のみ）
                if let shift = phaseShiftHours {
                    Circle()
                        .stroke(Color.tempoSageGreen.opacity(0.5), lineWidth: innerRingWidth)
                        .frame(width: innerRadius * 2, height: innerRadius * 2)
                        .rotationEffect(.degrees(shift * 15))
                }

                // 時刻目盛り
                timeMarkers(radius: outerRadius + 20)

                // 現在地マーカー
                currentTimeMarker(radius: outerRadius - outerRingWidth / 2)

                // 中央コンテンツ
                centerContent
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: size / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    // MARK: - Time Markers

    @ViewBuilder
    private func timeMarkers(radius: CGFloat) -> some View {
        ForEach([0, 6, 12, 18], id: \.self) { hour in
            let angle = angleForHour(hour)
            let radians = angle * .pi / 180
            let x = radius * cos(radians)
            let y = radius * sin(radians)

            Text("\(hour)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.tempoSecondaryText)
                .offset(x: x, y: y)
        }
    }

    // MARK: - Current Time Marker

    @ViewBuilder
    private func currentTimeMarker(radius: CGFloat) -> some View {
        let angle = angleForTime(currentTime)
        let radians = angle * .pi / 180
        let x = radius * cos(radians)
        let y = radius * sin(radians)

        Image(systemName: markerIcon)
            .font(.system(size: markerSize))
            .foregroundColor(.tempoSageGreen)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            .offset(x: x, y: y)
    }

    private var markerIcon: String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        return (hour >= 6 && hour < 18) ? "sun.max.fill" : "moon.fill"
    }

    // MARK: - Center Content

    private var centerContent: some View {
        VStack(spacing: 4) {
            Text(currentTimeText)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.tempoPrimaryText)

            Text(statusMessage)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.tempoSecondaryText)
                .multilineTextAlignment(.center)
        }
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm"
        return formatter
    }()

    private var currentTimeText: String {
        Self.timeFormatter.string(from: currentTime)
    }

    private var statusMessage: String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch hour {
        case 5..<8: return "目覚めの時間"
        case 8..<12: return "覚醒のピーク"
        case 12..<14: return "リラックスタイム"
        case 14..<17: return "活動の時間"
        case 17..<21: return "くつろぎの時間"
        default: return "休息の時間"
        }
    }

    // MARK: - Angle Calculation

    private func angleForTime(_ date: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let totalMinutes = Double(hour * 60 + minute)
        // 0:00 = -90°, 6:00 = 0°, 12:00 = 90°, 18:00 = 180°
        return (totalMinutes / 1440.0) * 360.0 - 90.0
    }

    private func angleForHour(_ hour: Int) -> Double {
        (Double(hour) / 24.0) * 360.0 - 90.0
    }
}

// MARK: - Sun Arc Shape

private struct SunArc: Shape {
    let startAngle: Double
    let endAngle: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )

        return path
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Solar Sync Circle - Day") {
    let calendar = Calendar.current
    let now = Date()
    let sunrise = calendar.date(bySettingHour: 6, minute: 45, second: 0, of: now)!
    let sunset = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: now)!

    return SolarSyncCircleView(
        sunriseTime: sunrise,
        sunsetTime: sunset,
        phaseShiftHours: 0.5
    )
    .frame(width: 280, height: 280)
    .padding()
    .background(Color.tempoBackground)
}

#Preview("Solar Sync Circle - No Temperature") {
    let calendar = Calendar.current
    let now = Date()
    let sunrise = calendar.date(bySettingHour: 6, minute: 45, second: 0, of: now)!
    let sunset = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: now)!

    return SolarSyncCircleView(
        sunriseTime: sunrise,
        sunsetTime: sunset,
        phaseShiftHours: nil
    )
    .frame(width: 280, height: 280)
    .padding()
    .background(Color.tempoBackground)
}
#endif
