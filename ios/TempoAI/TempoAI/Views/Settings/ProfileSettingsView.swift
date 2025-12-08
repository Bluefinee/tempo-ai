import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var userProfileManager = UserProfileManager.shared
    @State private var selectedMode: UserMode

    init() {
        _selectedMode = State(initialValue: UserProfileManager.shared.currentMode)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.lg) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemBlue).opacity(0.15))
                                .frame(width: 80, height: 80)

                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(Color(.systemBlue))
                        }

                        Text("あなたのプロフィール")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(ColorPalette.richBlack)

                        Text("AIがあなたに最適な\nアドバイスを提供するために")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(ColorPalette.gray600)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    .padding(.top, Spacing.lg)

                    // Lifestyle Mode Selection
                    VStack(spacing: Spacing.lg) {
                        HStack {
                            Text("ライフスタイル設定")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(ColorPalette.richBlack)
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)

                        VStack(spacing: Spacing.sm) {
                            ForEach(UserMode.allCases, id: \.self) { mode in
                                ProfileUserModeCard(
                                    mode: mode,
                                    isSelected: selectedMode == mode
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedMode = mode
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }

                    // Benefits Section
                    VStack(spacing: Spacing.md) {
                        HStack {
                            Text("選択中のプロフィールの特徴")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ColorPalette.richBlack)
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)

                        VStack(spacing: Spacing.sm) {
                            ForEach(selectedMode.benefits, id: \.self) { benefit in
                                HStack(spacing: Spacing.md) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(.systemGreen))

                                    Text(benefit)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(ColorPalette.gray700)

                                    Spacer()
                                }
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.xs)
                            }
                        }
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.lg)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.horizontal, Spacing.lg)
                    }

                    // Action Buttons
                    VStack(spacing: Spacing.md) {
                        Button("設定を保存") {
                            saveAndDismiss()
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(ColorPalette.pureWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(.systemBlue))
                        .cornerRadius(CornerRadius.lg)
                        .padding(.horizontal, Spacing.lg)

                        Button("キャンセル") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(ColorPalette.gray600)
                    }
                    .padding(.top, Spacing.lg)

                    Spacer()
                }
            }
            .background(ColorPalette.pureWhite)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        saveAndDismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(.systemBlue))
                }
            }
        }
    }

    private func saveAndDismiss() {
        userProfileManager.updateMode(selectedMode)
        dismiss()
    }
}

struct ProfileUserModeCard: View {
    let mode: UserMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Mode Icon
                ZStack {
                    Circle()
                        .fill(mode.color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: mode.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(mode.color)
                }

                // Mode Info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(mode.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ColorPalette.richBlack)

                    Text(mode.detailedDescription)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(ColorPalette.gray600)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // Selection Indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(.systemBlue) : ColorPalette.gray300)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(ColorPalette.pureWhite)
                    }
                }
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(isSelected ? Color(.systemBlue).opacity(0.05) : ColorPalette.pureWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .stroke(
                                isSelected ? Color(.systemBlue) : ColorPalette.gray200,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Extensions to provide additional mode information
extension UserMode {
    var icon: String {
        switch self {
        case .standard:
            return "person.fill"
        case .athlete:
            return "figure.run"
        }
    }

    var color: Color {
        switch self {
        case .standard:
            return Color(.systemBlue)
        case .athlete:
            return Color(.systemOrange)
        }
    }

    var description: String {
        switch self {
        case .standard:
            return "日常生活を重視した健康管理とバランス重視のアドバイス"
        case .athlete:
            return "運動パフォーマンス向上と高強度トレーニングに特化"
        }
    }

    var benefits: [String] {
        switch self {
        case .standard:
            return [
                "日常生活に無理のない健康アドバイス",
                "ストレス管理と睡眠改善に重点",
                "仕事とプライベートのバランス考慮",
                "段階的な健康習慣の構築をサポート",
            ]
        case .athlete:
            return [
                "トレーニング効果を最大化するアドバイス",
                "回復とパフォーマンスの最適化",
                "競技特性を考慮したデータ分析",
                "高強度トレーニングの疲労管理",
            ]
        }
    }
}

#Preview {
    ProfileSettingsView()
}
