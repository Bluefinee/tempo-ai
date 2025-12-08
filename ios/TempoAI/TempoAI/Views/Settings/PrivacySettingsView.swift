import SwiftUI

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var locationEnabled = true
    @State private var analyticsEnabled = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.lg) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGreen).opacity(0.15))
                                .frame(width: 80, height: 80)

                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(Color(.systemGreen))
                        }

                        Text("プライバシーと通知")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(ColorPalette.richBlack)

                        Text("あなたのプライバシーを\n最優先で保護します")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(ColorPalette.gray600)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    .padding(.top, Spacing.lg)

                    // Privacy Principles
                    VStack(spacing: Spacing.md) {
                        HStack {
                            Text("プライバシー保護の原則")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(ColorPalette.richBlack)
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)

                        VStack(spacing: Spacing.sm) {
                            PrivacyPrincipleRow(
                                icon: "lock.iphone",
                                title: "デバイス内処理",
                                description: "個人データはあなたのデバイス内で安全に処理",
                                color: Color(.systemGreen)
                            )

                            PrivacyPrincipleRow(
                                icon: "eye.slash.fill",
                                title: "匿名化処理",
                                description: "送信されるデータは完全に匿名化",
                                color: Color(.systemBlue)
                            )

                            PrivacyPrincipleRow(
                                icon: "trash.fill",
                                title: "削除の権利",
                                description: "いつでもデータの削除が可能",
                                color: Color(.systemRed)
                            )

                            PrivacyPrincipleRow(
                                icon: "hand.raised.fill",
                                title: "透明性重視",
                                description: "データの使用目的を明確に説明",
                                color: Color(.systemOrange)
                            )
                        }
                        .padding(.horizontal, Spacing.lg)
                    }

                    // Settings Controls
                    VStack(spacing: Spacing.lg) {
                        HStack {
                            Text("設定とコントロール")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(ColorPalette.richBlack)
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)

                        VStack(spacing: Spacing.sm) {
                            PrivacyControlRow(
                                icon: "bell.fill",
                                title: "通知",
                                subtitle: "健康アドバイスとリマインダー",
                                isEnabled: $notificationsEnabled,
                                color: Color(.systemBlue)
                            )

                            PrivacyControlRow(
                                icon: "location.fill",
                                title: "位置情報",
                                subtitle: "気象データによる環境分析",
                                isEnabled: $locationEnabled,
                                color: Color(.systemTeal)
                            )

                            PrivacyControlRow(
                                icon: "chart.bar.fill",
                                title: "使用統計",
                                subtitle: "アプリ改善のための匿名データ（オプション）",
                                isEnabled: $analyticsEnabled,
                                color: Color(.systemPurple)
                            )
                        }
                        .padding(.horizontal, Spacing.lg)
                    }

                    // Data Management Actions
                    VStack(spacing: Spacing.md) {
                        HStack {
                            Text("データ管理")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(ColorPalette.richBlack)
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)

                        VStack(spacing: Spacing.sm) {
                            Button(action: {
                                // TODO: Implement data export
                                print("Export data tapped")
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color(.systemBlue))

                                    Text("データをエクスポート")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(.systemBlue))

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(ColorPalette.gray400)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.md)
                                        .fill(Color(.systemBlue).opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                                .stroke(Color(.systemBlue).opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }

                            Button(action: {
                                // TODO: Implement data deletion
                                print("Delete data tapped")
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color(.systemRed))

                                    Text("すべてのデータを削除")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(.systemRed))

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(ColorPalette.gray400)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.md)
                                        .fill(Color(.systemRed).opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                                .stroke(Color(.systemRed).opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }

                    // Legal Links
                    VStack(spacing: Spacing.sm) {
                        Button("プライバシーポリシーを表示") {
                            // TODO: Open privacy policy
                            print("Privacy policy tapped")
                        }
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(.systemBlue))

                        Button("利用規約を表示") {
                            // TODO: Open terms of service
                            print("Terms of service tapped")
                        }
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(.systemBlue))
                    }
                    .padding(.top, Spacing.md)

                    Spacer()
                }
            }
            .background(ColorPalette.pureWhite)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(.systemBlue))
                }
            }
        }
    }
}

struct PrivacyPrincipleRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(ColorPalette.richBlack)

                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(ColorPalette.gray600)
            }

            Spacer()
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct PrivacyControlRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isEnabled: Bool
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(ColorPalette.richBlack)

                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(ColorPalette.gray600)
            }

            Spacer()

            Toggle("", isOn: $isEnabled)
                .scaleEffect(0.9)
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(ColorPalette.pureWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(ColorPalette.gray200, lineWidth: 1)
                )
        )
    }
}

#Preview {
    PrivacySettingsView()
}
