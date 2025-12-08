import SwiftUI

struct UserModePage: View {
    @Binding var selectedMode: UserMode?
    let onNext: () -> Void
    let onBack: (() -> Void)?

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                // Header section (Serial Position Effect - important info at top)
                VStack(spacing: Spacing.md) {
                    Text("ライフスタイル選択")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(ColorPalette.richBlack)
                        .padding(.top, Spacing.lg)
                }

                // Main content area (balanced distribution)
                VStack(spacing: Spacing.lg) {
                    ForEach(UserMode.allCases, id: \.self) { mode in
                        UserModeCard(
                            mode: mode,
                            isSelected: selectedMode == mode
                        ) {
                            print("📱 UserMode selected: \(mode)")
                            selectedMode = mode
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.xl)

                // Bottom action area (Fitts's Law)
                VStack(spacing: Spacing.md) {
                    if selectedMode != nil {
                        HStack(spacing: Spacing.md) {
                            Button(action: {
                                print("Back button tapped")
                                onBack?()
                            }) {
                                HStack(spacing: Spacing.xs) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("戻る")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(ColorPalette.gray600)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(ColorPalette.gray100)
                                .cornerRadius(CornerRadius.lg)
                            }
                            .contentShape(Rectangle())

                            Button("次へ") {
                                print("📱 UserModePage next button tapped")
                                onNext()
                            }
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(ColorPalette.pureWhite)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(ColorPalette.primaryAccent)
                            .cornerRadius(CornerRadius.lg)
                            .contentShape(Rectangle())
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
                .frame(height: 80)  // Fixed height for bottom area
            }
        }
        .background(ColorPalette.pureWhite)
    }
}

struct UserModeCard: View {
    let mode: UserMode
    let isSelected: Bool
    let onTap: () -> Void

    private var cardColor: Color {
        mode == .standard ? ColorPalette.secondaryAccent : ColorPalette.warmAccent
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Premium header with gradient background
                VStack(spacing: Spacing.sm) {
                    HStack {
                        Image(systemName: mode == .standard ? "leaf" : "bolt")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(ColorPalette.pureWhite)

                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ColorPalette.pureWhite)
                                .font(.title2)
                        }
                    }

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(mode.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ColorPalette.pureWhite.opacity(0.8))

                        Text(mode.appealingTitle)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(ColorPalette.pureWhite)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Spacing.lg)
                .background(
                    LinearGradient(
                        colors: [
                            cardColor,
                            cardColor.opacity(0.8),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // Content area with clean white background
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(mode == .standard ? "日常の体調管理と無理のないペース配分を重視" : "パフォーマンスの最大化と効率的なリカバリーを重視")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(ColorPalette.gray700)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                }
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ColorPalette.pureWhite)
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(
                        isSelected ? cardColor : ColorPalette.gray300,
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
            .shadow(
                color: ColorPalette.richBlack.opacity(isSelected ? 0.15 : 0.08),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

#Preview {
    UserModePage(
        selectedMode: .constant(.standard),
        onNext: { print("Next tapped") },
        onBack: { print("Back tapped") }
    )
}
