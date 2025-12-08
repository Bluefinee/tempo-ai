import SwiftUI

struct WelcomePage: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Enhanced branding with color accents
            VStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.sm) {
                    Text("Tempo")
                        .font(.system(size: 52, weight: .thin, design: .default))
                        .foregroundColor(ColorPalette.richBlack)
                        .tracking(3)
                    
                    Text("AI")
                        .font(.system(size: 28, weight: .semibold, design: .default))
                        .foregroundColor(ColorPalette.primaryAccent)
                        .tracking(6)
                        .offset(y: -10)
                }
                
                // Colorful visual rhythm (Google-inspired)
                HStack(spacing: Spacing.lg) {
                    Circle()
                        .fill(ColorPalette.primaryAccent)
                        .frame(width: 24, height: 24)
                    
                    Rectangle()
                        .fill(ColorPalette.secondaryAccent)
                        .frame(width: 50, height: 3)
                    
                    Circle()
                        .fill(ColorPalette.warmAccent)
                        .frame(width: 16, height: 16)
                }
                .padding(.top, Spacing.md)

                Text("あなたの「テンポ」に\n合わせた\nヘルスケアパートナー")
                    .font(.system(size: 30, weight: .light, design: .default))
                    .foregroundColor(ColorPalette.richBlack)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .tracking(1)
            }

            VStack(spacing: Spacing.lg) {
                Text("ヘルスケアデータをAIが分析し、\nあなたの体調や生活リズムに合わせた\n最適なアドバイスを提供します。\n\n今日のコンディションを把握して、\nより良い一日を過ごしましょう。")
                    .typography(.body)
                    .foregroundColor(ColorPalette.gray700)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, Spacing.lg)
                
                // Colorful start button
                Button(action: {
                    print("✅ Start button tapped!")
                    onNext()
                }) {
                    HStack(spacing: Spacing.sm) {
                        Text("始める")
                            .font(.system(size: 18, weight: .medium))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(ColorPalette.pureWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(ColorPalette.primaryAccent)
                    .cornerRadius(CornerRadius.lg)
                }
                .padding(.horizontal, Spacing.xl)
                .contentShape(Rectangle())
            }

            Spacer()
        }
        .background(ColorPalette.pureWhite)
    }
}


#Preview {
    WelcomePage {
        print("Next tapped")
    }
}
