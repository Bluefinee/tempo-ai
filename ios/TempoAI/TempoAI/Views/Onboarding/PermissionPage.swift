import SwiftUI

struct PermissionItem {
    let icon: String
    let title: String
    let description: String
}

struct PermissionPage: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let items: [PermissionItem]
    @Binding var isGranted: Bool
    let onNext: () -> Void
    let requestPermission: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            PermissionHeroIcon(systemName: icon, color: iconColor)

            VStack(spacing: Spacing.lg) {
                Text(title)
                    .typography(.title)
                    .foregroundColor(ColorPalette.richBlack)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .typography(.body)
                    .foregroundColor(ColorPalette.gray600)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)

                PermissionDetailList(items: items)
            }

            Spacer()

            VStack(spacing: Spacing.md) {
                if !isGranted {
                    Button("\(title)を許可") {
                        requestPermission()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ColorPalette.success)
                            .font(.title2)

                        Text("許可済み")
                            .typography(.headline)
                            .foregroundColor(ColorPalette.success)
                    }
                    .padding(.vertical, Spacing.sm)

                    Button("次へ", action: onNext)
                        .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(Spacing.lg)
    }
}

struct PermissionHeroIcon: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 64))
            .foregroundColor(color)
            .padding(Spacing.xl)
            .background(
                Circle()
                    .fill(color.opacity(0.1))
            )
    }
}

struct PermissionDetailList: View {
    let items: [PermissionItem]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]

                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(ColorPalette.success)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .typography(.subhead)
                            .foregroundColor(ColorPalette.richBlack)

                        Text(item.description)
                            .typography(.caption)
                            .foregroundColor(ColorPalette.gray500)
                    }

                    Spacer()
                }
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(ColorPalette.pearl)
        )
    }
}

struct CompletionPage: View {
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(ColorPalette.success.opacity(0.1))
                        .frame(width: 120, height: 120)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(ColorPalette.success)
                }

                VStack(spacing: Spacing.md) {
                    Text("設定完了！")
                        .typography(.hero)
                        .foregroundColor(ColorPalette.richBlack)

                    Text("あなた専用のHuman Batteryが準備できました。\nさっそく今日のエネルギー状態をチェックしてみましょう。")
                        .typography(.body)
                        .foregroundColor(ColorPalette.gray600)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.md)
                }
            }

            Spacer()

            Button("ホーム画面へ", action: onComplete)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, Spacing.lg)
        }
        .padding(Spacing.lg)
        .background(
            LinearGradient(
                colors: [ColorPalette.success.opacity(0.05), ColorPalette.pureWhite],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    PermissionPage(
        title: "健康データへのアクセス",
        subtitle: "バッテリー計算に必要なデータの取得を許可してください",
        icon: "heart.text.square",
        iconColor: ColorPalette.error,
        items: [
            PermissionItem(icon: "heart", title: "心拍数", description: "ストレスレベル計算のため"),
            PermissionItem(icon: "bed.double", title: "睡眠データ", description: "朝のバッテリー充電量計算のため"),
        ],
        isGranted: .constant(false),
        onNext: { print("Next") },
        requestPermission: { print("Request permission") }
    )
}
