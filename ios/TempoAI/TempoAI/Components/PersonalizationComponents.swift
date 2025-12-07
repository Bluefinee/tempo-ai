import SwiftUI

// MARK: - Personalization UI Components

struct SectionTitle: View {
    let icon: String
    let title: String
    let subtitle: String?

    init(icon: String, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(ColorPalette.info)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(Typography.headline.font)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.richBlack)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Typography.caption.font)
                        .foregroundColor(ColorPalette.gray500)
                }
            }

            Spacer()
        }
    }
}

struct GoalCard: View {
    let goal: HealthGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        InteractiveCard(action: onTap) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: goal.icon)
                    .font(.system(size: 32))
                    .foregroundColor(goal.color)

                Text(goal.title)
                    .font(Typography.callout.font)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.richBlack)
                    .multilineTextAlignment(.center)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ColorPalette.success)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .background(isSelected ? ColorPalette.successBackground : ColorPalette.offWhite)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(isSelected ? ColorPalette.success : ColorPalette.gray100, lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct ActivityLevelCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        InteractiveCard(action: onTap) {
            HStack(spacing: Spacing.md) {
                Image(systemName: level.icon)
                    .font(.system(size: 24))
                    .foregroundColor(level.color)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(level.title)
                        .font(Typography.callout.font)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.richBlack)

                    Text(level.description)
                        .font(Typography.caption.font)
                        .foregroundColor(ColorPalette.gray500)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ColorPalette.success)
                }
            }
        }
    }
}

struct InterestChip: View {
    let interest: HealthInterest
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: interest.icon)
                    .font(.system(size: 16))

                Text(interest.title)
                    .font(Typography.footnote.font)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? ColorPalette.pureWhite : ColorPalette.richBlack)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? ColorPalette.info : ColorPalette.offWhite)
            .cornerRadius(CornerRadius.pill(height: 32))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.pill(height: 32))
                    .stroke(isSelected ? ColorPalette.info : ColorPalette.gray100, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

struct NotificationTimeCard: View {
    let time: Date
    let onTap: () -> Void

    var body: some View {
        InteractiveCard(action: onTap) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 20))
                    .foregroundColor(ColorPalette.info)

                Text(DateFormatter.timeOnly.string(from: time))
                    .font(Typography.headline.font)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.richBlack)

                Spacer()

                Text(NSLocalizedString("tap_to_change", comment: "Tap to change"))
                    .font(Typography.caption.font)
                    .foregroundColor(ColorPalette.gray500)

                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(ColorPalette.gray300)
            }
        }
    }
}

struct NotificationToggleCard: View {
    @State private var isEnabled: Bool = true

    var body: some View {
        Card {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(NSLocalizedString("enable_notifications", comment: "Enable notifications"))
                        .font(Typography.callout.font)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.richBlack)

                    Text(NSLocalizedString("notification_help", comment: "You can change this in Settings later"))
                        .font(Typography.caption.font)
                        .foregroundColor(ColorPalette.gray500)
                }

                Spacer()

                Toggle("", isOn: $isEnabled)
                    .toggleStyle(SwitchToggleStyle())
            }
        }
    }
}
