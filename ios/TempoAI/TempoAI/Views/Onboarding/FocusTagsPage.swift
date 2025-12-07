import SwiftUI

struct FocusTagsPage: View {
    @Binding var selectedTags: Set<FocusTag>
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            VStack(spacing: Spacing.md) {
                Text("関心タグを選択")
                    .typography(.title)
                    .foregroundColor(ColorPalette.richBlack)
                    .multilineTextAlignment(.center)

                Text("AIの分析視点をカスタマイズします（複数選択可）")
                    .typography(.body)
                    .foregroundColor(ColorPalette.gray600)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.xl)

            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(FocusTag.allCases, id: \.self) { tag in
                    FocusTagCard(
                        tag: tag,
                        isSelected: selectedTags.contains(tag)
                    ) { toggleTag(tag) }
                }
            }

            if !selectedTags.isEmpty {
                VStack(spacing: Spacing.sm) {
                    Text("選択中: \(selectedTags.count)/4")
                        .typography(.caption)
                        .foregroundColor(ColorPalette.gray500)

                    HStack {
                        ForEach(Array(selectedTags), id: \.self) { tag in
                            Text(tag.emoji)
                                .font(.title3)
                        }
                    }
                }
                .padding(.vertical, Spacing.sm)
                .padding(.horizontal, Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(ColorPalette.pearl)
                )
            }

            Spacer()

            Button("次へ", action: onNext)
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedTags.isEmpty)
                .padding(.horizontal, Spacing.lg)
        }
        .padding(Spacing.lg)
    }

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: 2)

    private func toggleTag(_ tag: FocusTag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}

struct FocusTagCard: View {
    let tag: FocusTag
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: Spacing.sm) {
                Text(tag.emoji)
                    .font(.system(size: 36))

                Text(tag.displayName)
                    .typography(.subhead)
                    .foregroundColor(ColorPalette.richBlack)
                    .multilineTextAlignment(.center)

                Text(tag.description)
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray500)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(isSelected ? tag.themeColor.opacity(0.1) : ColorPalette.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .stroke(
                                isSelected ? tag.themeColor : ColorPalette.gray300,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

extension FocusTag {
    var themeColor: Color {
        switch self {
        case .work: return ColorPalette.info
        case .beauty: return .pink
        case .diet: return .green
        case .chill: return .mint
        }
    }
}

#Preview {
    FocusTagsPage(selectedTags: .constant([.work, .beauty])) {
        print("Next tapped")
    }
}
