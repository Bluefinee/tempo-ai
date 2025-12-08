import SwiftUI

struct FocusTagsPage: View {
    @Binding var selectedTags: Set<FocusTag>
    let onNext: () -> Void
    let onBack: (() -> Void)?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header section (Serial Position Effect)
                VStack(spacing: Spacing.sm) {
                    Text("関心分野を選択")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(ColorPalette.richBlack)
                        .padding(.top, Spacing.lg)
                    
                    Text("重視したい分野（複数選択可）")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(ColorPalette.gray600)
                }
                
                // Main content area (optimal spacing)
                VStack(spacing: Spacing.md) {
                    LazyVGrid(columns: columns, spacing: Spacing.md) {
                        ForEach(FocusTag.allCases, id: \.self) { tag in
                            FocusTagCard(
                                tag: tag,
                                isSelected: selectedTags.contains(tag)
                            ) { 
                                print("📱 FocusTag toggled: \(tag)")
                                toggleTag(tag) 
                            }
                        }
                    }
                    
                    // Selection feedback (Immediate Feedback principle)
                    if !selectedTags.isEmpty {
                        Text("\(selectedTags.count)個選択済み")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ColorPalette.secondaryAccent)
                            .padding(.top, Spacing.sm)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.xl)
                
                // Bottom action area (Fitts's Law)
                VStack(spacing: Spacing.md) {
                    if !selectedTags.isEmpty {
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
                                print("📱 FocusTagsPage next button tapped")
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
                .frame(height: 80) // Fixed height for bottom area
            }
        }
        .background(ColorPalette.pureWhite)
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

    private var tagColor: Color {
        switch tag {
        case .chill: return ColorPalette.secondaryAccent
        case .work: return ColorPalette.primaryAccent
        case .beauty: return Color(.systemPink)
        case .diet: return ColorPalette.warmAccent
        }
    }

    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 0) {
                // Premium icon header
                VStack(spacing: Spacing.md) {
                    Image(systemName: tag.systemIcon)
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(isSelected ? ColorPalette.pureWhite : tagColor)
                        .frame(height: 40)
                    
                    VStack(spacing: Spacing.xs) {
                        Text(tag.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isSelected ? ColorPalette.pureWhite : ColorPalette.richBlack)
                        
                        Text(tag == .chill ? "ストレス管理" : 
                             tag == .work ? "集中力最適化" :
                             tag == .beauty ? "肌・睡眠重視" : "食事管理")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(isSelected ? ColorPalette.pureWhite.opacity(0.8) : ColorPalette.gray600)
                    }
                }
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(
                    isSelected ? 
                    LinearGradient(
                        colors: [tagColor, tagColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ).opacity(1) :
                    LinearGradient(
                        colors: [ColorPalette.pureWhite, ColorPalette.pearl.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    ).opacity(1)
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(
                        isSelected ? tagColor : ColorPalette.gray300,
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
            .shadow(
                color: ColorPalette.richBlack.opacity(isSelected ? 0.2 : 0.08),
                radius: isSelected ? 6 : 3,
                x: 0,
                y: isSelected ? 3 : 1
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
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
    FocusTagsPage(
        selectedTags: .constant([.work, .beauty]),
        onNext: { print("Next tapped") },
        onBack: { print("Back tapped") }
    )
}
