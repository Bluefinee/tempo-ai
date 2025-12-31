import SwiftUI

/// 24-hour circular visualization with zones, time cursor, and HRV display
struct CircadianCircleView: View {
  let data: CircadianData

  /// Current time for cursor position (updates every minute)
  @State private var currentTime = Date()

  /// Timer for updating current time
  private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

  /// Circle radius relative to view size
  private let circleRadius: CGFloat = 0.4

  var body: some View {
    GeometryReader { geometry in
      let size = min(geometry.size.width, geometry.size.height)
      let center = CGPoint(x: geometry.size.width / 2, y: size / 2)
      let radius = size * circleRadius

      ZStack {
        // Background circle
        Circle()
          .stroke(Color.gray.opacity(0.2), lineWidth: 2)
          .frame(width: radius * 2, height: radius * 2)

        // Zone arcs
        zoneArcs(radius: radius)

        // Time ticks
        timeTicks(radius: radius)

        // Current time cursor
        timeCursor(radius: radius)

        // Center content
        centerContent
      }
      .frame(width: geometry.size.width, height: size)
      .position(center)
    }
    .aspectRatio(1, contentMode: .fit)
    .onReceive(timer) { _ in
      currentTime = Date()
    }
  }

  // MARK: - Zone Arcs

  @ViewBuilder
  private func zoneArcs(radius: CGFloat) -> some View {
    // Sleep zone: 22:00 - 6:00
    ZoneArc(
      startHour: 22,
      endHour: 6,
      radius: radius,
      color: .tempoSleepZone,
      opacity: 0.3
    )

    // Morning focus zone: 9:00 - 12:00
    ZoneArc(
      startHour: 9,
      endHour: 12,
      radius: radius,
      color: .tempoSageGreen,
      opacity: 0.15
    )

    // Lunch rest zone: 12:00 - 14:00
    ZoneArc(
      startHour: 12,
      endHour: 14,
      radius: radius,
      color: .tempoWarmBeige,
      opacity: 0.25
    )

    // Afternoon focus zone: 14:00 - 17:00
    ZoneArc(
      startHour: 14,
      endHour: 17,
      radius: radius,
      color: .tempoSageGreen,
      opacity: 0.15
    )
  }

  // MARK: - Time Ticks

  @ViewBuilder
  private func timeTicks(radius: CGFloat) -> some View {
    ForEach([0, 6, 12, 18], id: \.self) { hour in
      let angle = angleForHour(hour)
      let tickRadius = radius + 15

      Text(hourLabel(hour))
        .font(.system(size: 12, weight: .medium))
        .foregroundColor(.tempoSecondaryText)
        .position(
          x: tickRadius * cos(angle * .pi / 180),
          y: tickRadius * sin(angle * .pi / 180)
        )
        .offset(x: radius, y: radius)
    }
  }

  private func hourLabel(_ hour: Int) -> String {
    if hour == 0 {
      return "0"
    }
    return "\(hour)"
  }

  // MARK: - Time Cursor

  @ViewBuilder
  private func timeCursor(radius: CGFloat) -> some View {
    let angle = angleForTime(currentTime)
    let cursorRadius = radius - 15

    Image(systemName: cursorIcon)
      .font(.system(size: 24))
      .foregroundColor(.tempoSageGreen)
      .position(
        x: cursorRadius * cos(angle * .pi / 180) + radius,
        y: cursorRadius * sin(angle * .pi / 180) + radius
      )
  }

  private var cursorIcon: String {
    let hour = Calendar.current.component(.hour, from: currentTime)
    // Day: 6:00 - 18:00, Night: 18:00 - 6:00
    if hour >= 6 && hour < 18 {
      return "sun.max.fill"
    } else {
      return "moon.fill"
    }
  }

  // MARK: - Center Content

  private var centerContent: some View {
    VStack(spacing: 4) {
      // HRV value
      Text("\(data.hrvValue)")
        .font(.system(size: 36, weight: .bold, design: .rounded))
        .foregroundColor(.tempoPrimaryText)

      Text("ms")
        .font(.system(size: 14))
        .foregroundColor(.tempoSecondaryText)

      // Difference from average
      HStack(spacing: 2) {
        Image(systemName: data.hrvDifferencePercent >= 0 ? "arrow.up" : "arrow.down")
          .font(.system(size: 10))
        Text(data.hrvDifferenceText)
          .font(.system(size: 12, weight: .medium))
      }
      .foregroundColor(data.hrvDifferencePercent >= 0 ? .tempoSuccess : .tempoWarning)

      // Sleep times
      Text("就寝 \(data.bedtimeText) / 起床 \(data.wakeTimeText)")
        .font(.system(size: 11))
        .foregroundColor(.tempoSecondaryText)
        .padding(.top, 4)
    }
  }

  // MARK: - Angle Calculations

  /// Convert hour to angle (0:00 = top = -90 degrees)
  private func angleForHour(_ hour: Int) -> Double {
    (Double(hour) / 24.0) * 360.0 - 90.0
  }

  /// Convert time to angle
  private func angleForTime(_ date: Date) -> Double {
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let minute = calendar.component(.minute, from: date)
    let totalMinutes = Double(hour * 60 + minute)
    return (totalMinutes / 1440.0) * 360.0 - 90.0
  }
}

// MARK: - Zone Arc Shape

private struct ZoneArc: View {
  let startHour: Int
  let endHour: Int
  let radius: CGFloat
  let color: Color
  let opacity: Double

  var body: some View {
    Path { path in
      let startAngle = angleForHour(startHour)
      let endAngle = angleForHour(endHour)

      path.addArc(
        center: CGPoint(x: radius, y: radius),
        radius: radius,
        startAngle: .degrees(startAngle),
        endAngle: .degrees(endAngle),
        clockwise: startHour > endHour ? true : false
      )
    }
    .stroke(color.opacity(opacity), lineWidth: 20)
  }

  private func angleForHour(_ hour: Int) -> Double {
    (Double(hour) / 24.0) * 360.0 - 90.0
  }
}

// MARK: - Preview

#if DEBUG
#Preview("Circadian Circle") {
  CircadianCircleView(data: .mock)
    .frame(width: 300, height: 300)
    .padding()
}

#Preview("Circadian Circle - Poor Rhythm") {
  CircadianCircleView(data: .mockPoorRhythm)
    .frame(width: 300, height: 300)
    .padding()
}
#endif
