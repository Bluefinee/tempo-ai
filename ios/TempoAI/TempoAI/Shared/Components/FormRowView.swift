import SwiftUI

// MARK: - FormRowView

/// フォーム行を表示する共通コンポーネント
/// オンボーディングのBasicInfoStepViewやLifestyleStepViewで使用
struct FormRowView<Content: View>: View {

    // MARK: - Properties

    let label: String
    let icon: String?
    let content: Content

    // MARK: - Initialization

    init(
        label: String,
        icon: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.icon = icon
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        CardView {
            HStack {
                HStack(spacing: TempoSpacing.sm) {
                    if let icon: String = icon {
                        Image(systemName: icon)
                            .foregroundStyle(TempoColors.primary)
                            .frame(width: 24)
                    }
                    Text(label)
                        .font(TempoTypography.body)
                        .foregroundStyle(TempoColors.textPrimary)
                }
                Spacer()
                content
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("With Icon") {
    VStack(spacing: TempoSpacing.md) {
        FormRowView(label: "職業", icon: "briefcase.fill") {
            Text("会社員")
                .foregroundStyle(TempoColors.textSecondary)
        }
        FormRowView(label: "運動頻度", icon: "figure.run") {
            Text("週3回以上")
                .foregroundStyle(TempoColors.textSecondary)
        }
    }
    .padding()
    .tempoBackground()
}

#Preview("Without Icon") {
    VStack(spacing: TempoSpacing.md) {
        FormRowView(label: "年齢") {
            Text("30歳")
                .foregroundStyle(TempoColors.textPrimary)
        }
        FormRowView(label: "BMI") {
            Text("22.5")
                .foregroundStyle(TempoColors.textPrimary)
                .fontWeight(.medium)
        }
    }
    .padding()
    .tempoBackground()
}
#endif
