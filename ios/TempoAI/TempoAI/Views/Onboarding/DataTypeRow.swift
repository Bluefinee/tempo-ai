import SwiftUI

struct DataTypeRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Premium icon with subtle background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(friendlyTitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ColorPalette.richBlack)

                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(ColorPalette.gray600)
            }

            Spacer()

            // Subtle indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ColorPalette.gray400)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(ColorPalette.pureWhite)
                .shadow(
                    color: ColorPalette.richBlack.opacity(0.05),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        )
    }

    private var friendlyTitle: String {
        switch icon {
        case "heart.fill": return "心拍の状態"
        case "bed.double.fill": return "睡眠の質"
        case "figure.walk": return "日々の活動"
        case "plus.circle": return "その他の情報"
        case "thermometer": return "気温と湿度"
        case "cloud.fill": return "空気の質"
        case "sun.max.fill": return "紫外線情報"
        case "shield.lefthalf.filled": return "安心保護"
        default: return title
        }
    }

    private var subtitle: String {
        switch icon {
        case "heart.fill": return "ストレスや体調の把握"
        case "bed.double.fill": return "回復状態の分析"
        case "figure.walk": return "エネルギー消費の追跡"
        case "plus.circle": return "総合的な健康分析"
        case "thermometer": return "体感への影響予測"
        case "cloud.fill": return "呼吸への影響チェック"
        case "sun.max.fill": return "外出時のケア提案"
        case "shield.lefthalf.filled": return "市町村レベルのみ使用"
        default: return ""
        }
    }
}
