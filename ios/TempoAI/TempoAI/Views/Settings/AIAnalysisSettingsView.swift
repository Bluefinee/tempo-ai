import SwiftUI

struct AIAnalysisSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var focusTagManager = FocusTagManager.shared
    @State private var tempSelectedTags: Set<FocusTag>
    
    init() {
        _tempSelectedTags = State(initialValue: FocusTagManager.shared.activeTags)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.lg) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemPurple).opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(Color(.systemPurple))
                        }
                        
                        Text("AI分析とカスタマイズ")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(ColorPalette.richBlack)
                        
                        Text("あなたの興味に合わせて\nAI分析をカスタマイズ")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(ColorPalette.gray600)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    .padding(.top, Spacing.lg)
                    
                    // Current Analysis Summary
                    VStack(spacing: Spacing.md) {
                        Text("現在の分析設定")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(ColorPalette.richBlack)
                        
                        HStack {
                            AnalysisSummaryCard(
                                title: "関心領域",
                                count: "\(tempSelectedTags.count)",
                                subtitle: "選択中",
                                color: Color(.systemPurple)
                            )
                            
                            AnalysisSummaryCard(
                                title: "分析精度",
                                count: analysisAccuracy,
                                subtitle: "推定精度",
                                color: Color(.systemGreen)
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    
                    // Focus Tags Selection
                    VStack(spacing: Spacing.lg) {
                        HStack {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("関心のある健康領域を選択")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(ColorPalette.richBlack)
                                
                                Text("複数選択することで、より詳しい分析が可能です")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(ColorPalette.gray600)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)
                        
                        VStack(spacing: Spacing.sm) {
                            ForEach(FocusTag.allCases, id: \.self) { tag in
                                FocusTagCard(
                                    tag: tag,
                                    isSelected: tempSelectedTags.contains(tag)
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if tempSelectedTags.contains(tag) {
                                            tempSelectedTags.remove(tag)
                                        } else {
                                            tempSelectedTags.insert(tag)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                    
                    // AI Analysis Benefits
                    VStack(spacing: Spacing.md) {
                        HStack {
                            Text("選択した領域での分析内容")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ColorPalette.richBlack)
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)
                        
                        VStack(spacing: Spacing.sm) {
                            ForEach(selectedBenefits, id: \.self) { benefit in
                                HStack(spacing: Spacing.md) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(.systemPurple))
                                    
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
                                .fill(Color(.systemPurple).opacity(0.05))
                        )
                        .padding(.horizontal, Spacing.lg)
                    }
                    
                    // Action Buttons
                    VStack(spacing: Spacing.md) {
                        Button("設定を保存") {
                            for tag in FocusTag.allCases {
                                if tempSelectedTags.contains(tag) {
                                    focusTagManager.addTag(tag)
                                } else {
                                    focusTagManager.removeTag(tag)
                                }
                            }
                            dismiss()
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(ColorPalette.pureWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(.systemPurple))
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
                        for tag in FocusTag.allCases {
                            if tempSelectedTags.contains(tag) {
                                focusTagManager.addTag(tag)
                            } else {
                                focusTagManager.removeTag(tag)
                            }
                        }
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(.systemBlue))
                }
            }
        }
    }
    
    private var analysisAccuracy: String {
        let count = tempSelectedTags.count
        switch count {
        case 0:
            return "基本"
        case 1:
            return "良好"
        case 2:
            return "高精度"
        case 3...4:
            return "最高"
        default:
            return "最適"
        }
    }
    
    private var selectedBenefits: [String] {
        var benefits: [String] = []
        
        if tempSelectedTags.contains(.sleep) {
            benefits.append("睡眠パターン分析と睡眠改善提案")
        }
        if tempSelectedTags.contains(.exercise) {
            benefits.append("運動効果測定とトレーニング最適化")
        }
        if tempSelectedTags.contains(.nutrition) {
            benefits.append("栄養バランス分析と食事提案")
        }
        if tempSelectedTags.contains(.stress) {
            benefits.append("ストレス状態検出とリラクゼーション提案")
        }
        
        if benefits.isEmpty {
            benefits.append("基本的な健康状態モニタリング")
        }
        
        return benefits
    }
}

struct AnalysisSummaryCard: View {
    let title: String
    let count: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(count)
                .font(.system(size: 24, weight: .light))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ColorPalette.richBlack)
            
            Text(subtitle)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(ColorPalette.gray500)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct FocusTagCard: View {
    let tag: FocusTag
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Tag Emoji
                Text(tag.emoji)
                    .font(.system(size: 28))
                
                // Tag Info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(tag.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ColorPalette.richBlack)
                    
                    Text(tag.description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(ColorPalette.gray600)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection Toggle
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color(.systemPurple) : ColorPalette.gray300)
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
                    .fill(isSelected ? Color(.systemPurple).opacity(0.05) : ColorPalette.pureWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .stroke(
                                isSelected ? Color(.systemPurple) : ColorPalette.gray200,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AIAnalysisSettingsView()
}