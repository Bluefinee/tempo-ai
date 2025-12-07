import SwiftUI

struct UserModePage: View {
    @Binding var selectedMode: UserMode?
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            VStack(spacing: Spacing.md) {
                Text("バッテリーの使い方を選択")
                    .typography(.title)
                    .foregroundColor(ColorPalette.richBlack)
                    .multilineTextAlignment(.center)

                Text("あなたの生活スタイルに合わせて、バッテリーの解釈を調整します")
                    .typography(.body)
                    .foregroundColor(ColorPalette.gray600)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.xl)

            VStack(spacing: Spacing.lg) {
                UserModeCard(
                    mode: .standard,
                    isSelected: selectedMode == .standard
                ) { selectedMode = .standard }

                UserModeCard(
                    mode: .athlete,
                    isSelected: selectedMode == .athlete
                ) { selectedMode = .athlete }
            }

            Spacer()

            Button("次へ", action: onNext)
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedMode == nil)
                .padding(.horizontal, Spacing.lg)
        }
        .padding(Spacing.lg)
    }
}

struct UserModeCard: View {
    let mode: UserMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text(mode == .standard ? "🍀" : "🏃")
                            .font(.largeTitle)

                        Text(mode.displayName)
                            .typography(.headline)
                            .foregroundColor(ColorPalette.richBlack)

                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ColorPalette.success)
                                .font(.title2)
                        }
                    }

                    Text(mode.description)
                        .typography(.body)
                        .foregroundColor(ColorPalette.gray600)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(isSelected ? ColorPalette.success.opacity(0.1) : ColorPalette.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .stroke(
                                isSelected ? ColorPalette.success : ColorPalette.gray300,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    UserModePage(selectedMode: .constant(.standard)) {
        print("Next tapped")
    }
}
