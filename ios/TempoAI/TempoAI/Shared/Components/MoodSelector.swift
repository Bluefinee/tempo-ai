//
//  MoodSelector.swift
//  TempoAI
//
//  Mood Selector Component
//

import SwiftUI

// MARK: - Mood

/// 気分の5段階
enum Mood: Int, CaseIterable, Codable, Sendable {
    case veryBad = 1
    case bad = 2
    case neutral = 3
    case good = 4
    case veryGood = 5

    /// 表示用アイコン（モノクロ顔文字）
    var icon: String {
        switch self {
        case .veryBad: return "(´･_･`)"
        case .bad: return "(._.)"
        case .neutral: return "(-_-)"
        case .good: return "(･ω･)"
        case .veryGood: return "(^_^)"
        }
    }

    /// アクセシビリティ用ラベル
    var accessibilityLabel: String {
        switch self {
        case .veryBad: return "とても悪い"
        case .bad: return "悪い"
        case .neutral: return "普通"
        case .good: return "良い"
        case .veryGood: return "とても良い"
        }
    }
}

// MARK: - Today Mode Extensions

/// TodayModeのUI表示用拡張
/// - Note: TodayModeはAdviceRequestDTO.swiftで定義済み
extension TodayMode: CaseIterable {

    /// すべてのケース
    public static var allCases: [TodayMode] {
        [.normal, .challenge, .holiday]
    }

    /// 表示用ラベル
    var label: String {
        displayName
    }

    /// アイコン
    var icon: String {
        switch self {
        case .normal: return "clock"
        case .challenge: return "flame"
        case .holiday: return "leaf"
        }
    }

    /// 説明文
    var description: String {
        switch self {
        case .normal: return "普段通りの1日"
        case .challenge: return "重要な予定がある日"
        case .holiday: return "リラックス優先"
        }
    }
}

// MARK: - Mood Selector

/// 気分選択UI
struct MoodSelector: View {

    // MARK: - Properties

    @Binding var selectedMood: Mood?

    // MARK: - Body

    var body: some View {
        HStack(spacing: TempoSpacing.sm) {
            ForEach(Mood.allCases, id: \.self) { mood in
                MoodButton(
                    mood: mood,
                    isSelected: selectedMood == mood,
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMood = mood
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Mood Button

/// 個別の気分ボタン
private struct MoodButton: View {

    // MARK: - Properties

    let mood: Mood
    let isSelected: Bool
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            Text(mood.icon)
                .font(.system(size: 20))
                .frame(width: 48, height: 48)
                .background(
                    isSelected ? TempoColors.primary.opacity(0.15) : Color.clear
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            isSelected ? TempoColors.primary : TempoColors.textTertiary.opacity(0.3),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        }
        .accessibilityLabel(mood.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Today Mode Selector

/// 今日のモード選択UI
struct TodayModeSelector: View {

    // MARK: - Properties

    @Binding var selectedMode: TodayMode?

    // MARK: - Body

    var body: some View {
        HStack(spacing: TempoSpacing.sm) {
            ForEach(TodayMode.allCases, id: \.self) { mode in
                TodayModeButton(
                    mode: mode,
                    isSelected: selectedMode == mode,
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMode = mode
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Today Mode Button

/// 個別のモードボタン
private struct TodayModeButton: View {

    // MARK: - Properties

    let mode: TodayMode
    let isSelected: Bool
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: TempoSpacing.xxs) {
                Image(systemName: mode.icon)
                    .font(.system(size: 14, weight: .medium))
                Text(mode.label)
                    .font(TempoTypography.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .white : TempoColors.textSecondary)
            .padding(.horizontal, TempoSpacing.sm)
            .padding(.vertical, TempoSpacing.xs)
            .background(
                isSelected ? TempoColors.primary : TempoColors.cardBackground
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : TempoColors.textTertiary.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .accessibilityLabel(mode.label)
        .accessibilityHint(mode.description)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Morning Check-In Card

/// 朝のチェックインカード（気分 + 今日のモード）
struct MorningCheckInCard: View {

    // MARK: - Properties

    @Binding var mood: Mood?
    @Binding var todayMode: TodayMode?
    let onComplete: () -> Void

    // MARK: - Body

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TempoSpacing.md) {
                // Mood Section
                VStack(alignment: .leading, spacing: TempoSpacing.xs) {
                    Text("今の気分は？")
                        .font(TempoTypography.subheadline)
                        .foregroundStyle(TempoColors.textSecondary)

                    MoodSelector(selectedMood: $mood)
                }

                Divider()

                // Today Mode Section
                VStack(alignment: .leading, spacing: TempoSpacing.xs) {
                    Text("今日は？")
                        .font(TempoTypography.subheadline)
                        .foregroundStyle(TempoColors.textSecondary)

                    TodayModeSelector(selectedMode: $todayMode)
                }

                // Complete Button
                if mood != nil && todayMode != nil {
                    PrimaryButton("記録する", icon: "checkmark") {
                        onComplete()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Mood & Mode Selectors") {
    struct PreviewContainer: View {
        @State private var mood: Mood? = .good
        @State private var todayMode: TodayMode? = .normal

        var body: some View {
            ScrollView {
                VStack(spacing: TempoSpacing.xl) {
                    Text("Mood Selector")
                        .font(TempoTypography.headline)

                    MoodSelector(selectedMood: $mood)
                        .padding()
                        .background(TempoColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.cardCornerRadius))

                    if let mood = mood {
                        Text("選択中: \(mood.accessibilityLabel)")
                            .font(TempoTypography.caption)
                            .foregroundStyle(TempoColors.textSecondary)
                    }

                    Divider()

                    Text("Today Mode Selector")
                        .font(TempoTypography.headline)

                    TodayModeSelector(selectedMode: $todayMode)

                    if let mode = todayMode {
                        Text("選択中: \(mode.label) - \(mode.description)")
                            .font(TempoTypography.caption)
                            .foregroundStyle(TempoColors.textSecondary)
                    }

                    Divider()

                    Text("Morning Check-In Card")
                        .font(TempoTypography.headline)

                    MorningCheckInCard(
                        mood: $mood,
                        todayMode: $todayMode,
                        onComplete: {
                            print("Check-in completed!")
                        }
                    )
                }
                .screenPadding()
                .padding(.vertical, TempoSpacing.md)
            }
            .background(TempoColors.background)
        }
    }

    return PreviewContainer()
}
