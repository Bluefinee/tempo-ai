import SwiftUI

struct AdviceHeadline {
    let title: String
    let subtitle: String
    let impactLevel: ImpactLevel

    enum ImpactLevel {
        case high, medium, low

        var color: Color {
            switch self {
            case .high: return ColorPalette.error
            case .medium: return ColorPalette.warning
            case .low: return ColorPalette.richBlack
            }
        }
    }

    static func mock() -> AdviceHeadline {
        return AdviceHeadline(
            title: "エネルギー良好",
            subtitle: "今日は集中作業に適した状態です",
            impactLevel: .medium
        )
    }
}

struct AdviceHeaderView: View {
    let headline: AdviceHeadline
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(headline.title)
                        .typography(.hero)
                        .foregroundColor(headline.impactLevel.color)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(ColorPalette.gray500)
                        .font(.title3)
                }

                Text(headline.subtitle)
                    .typography(.body)
                    .foregroundColor(ColorPalette.gray700)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    AdviceHeaderView(headline: AdviceHeadline.mock()) {
        print("Header tapped")
    }
}
