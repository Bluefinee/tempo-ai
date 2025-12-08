import SwiftUI

struct SettingsCardRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let status: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.lg) {
                // Icon with subtle background (consistent with DataTypeRow)
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ColorPalette.richBlack)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(ColorPalette.gray600)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(status)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(ColorPalette.gray700)
                        .multilineTextAlignment(.trailing)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ColorPalette.gray400)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(ColorPalette.pureWhite)
                    .shadow(
                        color: ColorPalette.richBlack.opacity(0.08),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        SettingsCardRow(
            icon: "person.circle.fill",
            title: "あなたのプロフィール",
            subtitle: "AIがあなたに合わせて最適化",
            status: "アスリート",
            color: Color(.systemBlue)
        ) {
            print("Profile tapped")
        }
        
        SettingsCardRow(
            icon: "heart.text.square.fill",
            title: "データ連携",
            subtitle: "さらに詳しい分析で精度向上",
            status: "6項目許可済み",
            color: Color(.systemRed)
        ) {
            print("Data permissions tapped")
        }
        
        SettingsCardRow(
            icon: "brain.head.profile",
            title: "AI分析とカスタマイズ",
            subtitle: "睡眠、運動、栄養、ストレス",
            status: "4つの関心領域",
            color: Color(.systemPurple)
        ) {
            print("AI settings tapped")
        }
    }
    .padding()
    .background(ColorPalette.gray50)
}