import SwiftUI
import UIKit

// MARK: - Button Styles

enum ButtonStyle {
    case primary
    case secondary
    case tertiary
    case danger
    case success
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool

    @State private var isPressed: Bool = false

    init(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button {
            if !isDisabled && !isLoading {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                action()
            }
        } label: {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                        .tint(.white)
                }

                Text(title)
                    .typography(.callout)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: LayoutConstants.buttonHeight)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(CornerRadius.md)
            .elevation(isPressed ? .low : .medium)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            perform: {
                // Never triggered
            },
            onPressingChanged: { pressing in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = pressing
                }
            }
        )
    }

    private var backgroundColor: Color {
        if isDisabled {
            return ColorPalette.gray300
        }
        return ColorPalette.richBlack
    }

    private var foregroundColor: Color {
        return ColorPalette.pureWhite
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool

    @State private var isPressed: Bool = false

    init(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button {
            if !isDisabled && !isLoading {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                action()
            }
        } label: {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                        .tint(ColorPalette.richBlack)
                }

                Text(title)
                    .typography(.callout)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: LayoutConstants.buttonHeight)
            .background(backgroundColor)
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(borderColor, lineWidth: 1)
            )
            .foregroundColor(foregroundColor)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            perform: {
                // Never triggered
            },
            onPressingChanged: { pressing in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = pressing
                }
            }
        )
    }

    private var backgroundColor: Color {
        if isPressed {
            return ColorPalette.pearl
        }
        return ColorPalette.pureWhite
    }

    private var foregroundColor: Color {
        if isDisabled {
            return ColorPalette.gray300
        }
        return ColorPalette.richBlack
    }

    private var borderColor: Color {
        if isDisabled {
            return ColorPalette.gray100
        }
        return ColorPalette.gray300
    }
}

// MARK: - Text Button

struct TextButton: View {
    let title: String
    let action: () -> Void
    let isDisabled: Bool

    @State private var isPressed: Bool = false

    init(
        _ title: String,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button {
            if !isDisabled {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                action()
            }
        } label: {
            Text(title)
                .typography(.callout)
                .fontWeight(.medium)
                .foregroundColor(foregroundColor)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(
                    isPressed ? ColorPalette.pearl : Color.clear
                )
                .cornerRadius(CornerRadius.xs)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(isDisabled)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            perform: {
                // Never triggered
            },
            onPressingChanged: { pressing in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = pressing
                }
            }
        )
    }

    private var foregroundColor: Color {
        if isDisabled {
            return ColorPalette.gray300
        }
        return ColorPalette.info
    }
}

// MARK: - Icon Button

struct IconButton: View {
    let icon: String
    let action: () -> Void
    let isDisabled: Bool
    let size: CGFloat

    @State private var isPressed: Bool = false

    init(
        icon: String,
        size: CGFloat = LayoutConstants.IconSize.medium,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button {
            if !isDisabled {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                action()
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(foregroundColor)
                .frame(width: LayoutConstants.minTapTarget, height: LayoutConstants.minTapTarget)
                .background(
                    Circle()
                        .fill(isPressed ? ColorPalette.pearl : Color.clear)
                )
                .scaleEffect(isPressed ? 0.85 : 1.0)
        }
        .disabled(isDisabled)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            perform: {
                // Never triggered
            },
            onPressingChanged: { pressing in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = pressing
                }
            }
        )
    }

    private var foregroundColor: Color {
        if isDisabled {
            return ColorPalette.gray300
        }
        return ColorPalette.gray700
    }
}

// MARK: - Floating Action Button

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(ColorPalette.pureWhite)
                .frame(width: 56, height: 56)
                .background(ColorPalette.richBlack)
                .clipShape(Circle())
                .elevation(isPressed ? .medium : .high)
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            perform: {
                // Never triggered
            },
            onPressingChanged: { pressing in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = pressing
                }
            }
        )
    }
}
