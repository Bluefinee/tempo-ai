import SwiftUI

struct LiquidBatteryView: View {
    let battery: HumanBattery

    @State private var waveOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(ColorPalette.gray300, lineWidth: 2)
                    .frame(height: 80)

                GeometryReader { _ in
                    ZStack {
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .fill(ColorPalette.gray100)

                        LiquidWaveShape(
                            level: battery.currentLevel / 100,
                            waveOffset: waveOffset,
                            waveHeight: 8
                        )
                        .fill(
                            LinearGradient(
                                colors: [liquidColor.opacity(0.8), liquidColor],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                    }
                }
                .frame(height: 76)

                Text("\(Int(battery.currentLevel))%")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
            }

            Text(battery.batteryComment)
                .typography(.caption)
                .foregroundColor(ColorPalette.gray500)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            startWaveAnimation()
        }
    }

    private var liquidColor: Color {
        return battery.state.color
    }

    private var textColor: Color {
        battery.currentLevel > 50 ? ColorPalette.pureWhite : ColorPalette.richBlack
    }

    private func startWaveAnimation() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            waveOffset = 360
        }
    }
}

struct LiquidWaveShape: Shape {
    let level: Double
    var waveOffset: CGFloat
    let waveHeight: CGFloat

    var animatableData: CGFloat {
        get { waveOffset }
        set { waveOffset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let liquidHeight = height * (1 - level)

        let path = Path { path in
            path.move(to: CGPoint(x: 0, y: liquidHeight))

            for xPos in stride(from: 0, through: width, by: 2) {
                let relativeX = xPos / width
                let sine = sin(relativeX * 4 * .pi + waveOffset * .pi / 180)
                let yPos = liquidHeight + sine * waveHeight
                path.addLine(to: CGPoint(x: xPos, y: yPos))
            }

            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
        }

        return path
    }
}

#Preview {
    let mockBattery = HumanBattery(
        currentLevel: 75.0,
        morningCharge: 85.0,
        drainRate: -3.5,
        state: .high,
        lastUpdated: Date()
    )

    LiquidBatteryView(battery: mockBattery)
        .padding()
}
