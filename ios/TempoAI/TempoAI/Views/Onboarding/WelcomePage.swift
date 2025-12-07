import SwiftUI

struct WelcomePage: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            BatteryHeroAnimation()
                .frame(height: 200)

            VStack(spacing: Spacing.lg) {
                Text("Meet Your Human Battery")
                    .typography(.hero)
                    .foregroundColor(ColorPalette.richBlack)
                    .multilineTextAlignment(.center)

                Text("あなたの体力を「スマホのバッテリー」のように可視化。今日は攻めるべき？休むべき？AIがリアルタイムでアドバイスします。")
                    .typography(.body)
                    .foregroundColor(ColorPalette.gray700)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)
            }

            Spacer()

            Button("始める", action: onNext)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, Spacing.lg)
        }
        .padding(Spacing.lg)
        .background(
            LinearGradient(
                colors: [ColorPalette.pureWhite, ColorPalette.pearl],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct BatteryHeroAnimation: View {
    @State private var animationProgress: Double = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorPalette.gray300, lineWidth: 3)
                .frame(width: 120, height: 200)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [ColorPalette.success, ColorPalette.success.opacity(0.7)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 110, height: 190 * animationProgress)
                .clipShape(RoundedRectangle(cornerRadius: 17))
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animationProgress)

            Text("\(Int(animationProgress * 100))%")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(animationProgress > 0.5 ? ColorPalette.pureWhite : ColorPalette.richBlack)
        }
        .onAppear {
            animationProgress = 1.0
        }
    }
}

#Preview {
    WelcomePage {
        print("Next tapped")
    }
}
