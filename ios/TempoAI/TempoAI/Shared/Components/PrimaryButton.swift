//
//  PrimaryButton.swift
//  TempoAI
//
//  Primary Button Component
//

import SwiftUI

// MARK: - Primary Button

/// プライマリボタン - メインアクション用
/// - Note: Soft Sage Green背景、白テキスト
struct PrimaryButton: View {

    // MARK: - Properties

    let title: String
    let icon: String?
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    // MARK: - Initialization

    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: TempoSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(TempoTypography.headline)
                }
            }
            .fillWidth()
            .frame(height: 50)
            .foregroundStyle(.white)
            .background(
                isEnabled ? TempoColors.primary : TempoColors.textTertiary
            )
            .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.buttonCornerRadius))
        }
        .disabled(!isEnabled || isLoading)
        .buttonAccessibility(label: title, isLoading: isLoading)
    }
}

// MARK: - Accent Button

/// アクセントボタン - CTAアクション用
/// - Note: Soft Coral背景、白テキスト
struct AccentButton: View {

    // MARK: - Properties

    let title: String
    let icon: String?
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    // MARK: - Initialization

    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: TempoSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(TempoTypography.headline)
                }
            }
            .fillWidth()
            .frame(height: 50)
            .foregroundStyle(.white)
            .background(
                isEnabled ? TempoColors.accent : TempoColors.textTertiary
            )
            .clipShape(RoundedRectangle(cornerRadius: TempoSpacing.buttonCornerRadius))
        }
        .disabled(!isEnabled || isLoading)
        .buttonAccessibility(label: title, isLoading: isLoading)
    }
}

// MARK: - Preview

#Preview("Primary Button") {
    VStack(spacing: TempoSpacing.md) {
        PrimaryButton("次へ進む", icon: "arrow.right") {
            print("Tapped")
        }

        PrimaryButton("保存する") {
            print("Save")
        }

        PrimaryButton("読み込み中", isLoading: true) {
            print("Loading")
        }

        PrimaryButton("無効", isEnabled: false) {
            print("Disabled")
        }

        AccentButton("始める", icon: "play.fill") {
            print("Start")
        }
    }
    .padding()
    .tempoBackground()
}
