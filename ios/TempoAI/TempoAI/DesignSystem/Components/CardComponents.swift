import SwiftUI
import UIKit

// MARK: - Basic Card

struct Card<Content: View>: View {
    let content: () -> Content
    let padding: CGFloat
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let elevation: Elevation

    init(
        padding: CGFloat = Spacing.md,
        backgroundColor: Color = ColorPalette.offWhite,
        cornerRadius: CGFloat = CornerRadius.md,
        elevation: Elevation = .low,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.elevation = elevation
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .elevation(elevation)
    }
}

// MARK: - Interactive Card

struct InteractiveCard<Content: View>: View {
    let content: () -> Content
    let action: () -> Void

    @State private var isPressed: Bool = false

    init(
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.content = content
    }

    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }, label: {
            content()
                .padding(Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isPressed ? ColorPalette.pearl : ColorPalette.offWhite)
                .cornerRadius(CornerRadius.md)
                .elevation(isPressed ? .none : .low)
                .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            perform: {
                // Never triggered
            },
            onPressingChanged: { pressing in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isPressed = pressing
                }
            }
        )
    }
}

// MARK: - Expandable Card

struct ExpandableCard<Header: View, Content: View>: View {
    let header: () -> Header
    let content: () -> Content

    @State private var isExpanded: Bool = false
    @State private var isPressed: Bool = false

    init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }, label: {
                HStack {
                    header()

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ColorPalette.gray500)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(Spacing.md)
            }
            .buttonStyle(PlainButtonStyle())

            // Content
            if isExpanded {
                Divider()
                    .background(ColorPalette.gray100)

                content()
                    .padding(Spacing.md)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
            }
        }
        .background(ColorPalette.offWhite)
        .cornerRadius(CornerRadius.md)
        .elevation(isExpanded ? .medium : .low)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
}

// MARK: - Status Card

struct StatusCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let trend: Trend?

    enum Trend {
        case up(String)
        case down(String)
        case neutral
    }

    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = ColorPalette.richBlack,
        trend: Trend? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.trend = trend
    }

    var body: some View {
        Card {
            HStack(spacing: Spacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .frame(width: 48, height: 48)
                    .background(iconColor.opacity(0.1))
                    .cornerRadius(CornerRadius.sm)

                // Content
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .typography(.caption)
                        .foregroundColor(ColorPalette.gray500)

                    Text(value)
                        .typography(.headline)
                        .foregroundColor(ColorPalette.richBlack)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .typography(.caption)
                            .foregroundColor(ColorPalette.gray300)
                    }
                }

                Spacer()

                // Trend
                if let trend = trend {
                    trendView(trend)
                }
            }
        }
    }

    @ViewBuilder
    private func trendView(_ trend: Trend) -> some View {
        switch trend {
        case .up(let value):
            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ColorPalette.success)

                Text(value)
                    .typography(.caption)
                    .foregroundColor(ColorPalette.success)
            }

        case .down(let value):
            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Image(systemName: "arrow.down.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ColorPalette.error)

                Text(value)
                    .typography(.caption)
                    .foregroundColor(ColorPalette.error)
            }

        case .neutral:
            Image(systemName: "minus")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(ColorPalette.gray300)
        }
    }
}

// MARK: - Info Card

struct InfoCard: View {
    let title: String
    let message: String
    let type: InfoType
    let action: (() -> Void)?
    let actionTitle: String?

    enum InfoType {
        case info
        case success
        case warning
        case error

        var backgroundColor: Color {
            switch self {
            case .info: return ColorPalette.infoBackground
            case .success: return ColorPalette.successBackground
            case .warning: return ColorPalette.warningBackground
            case .error: return ColorPalette.errorBackground
            }
        }

        var iconColor: Color {
            switch self {
            case .info: return ColorPalette.info
            case .success: return ColorPalette.success
            case .warning: return ColorPalette.warning
            case .error: return ColorPalette.error
            }
        }

        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
    }

    init(
        title: String,
        message: String,
        type: InfoType = .info,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.type = type
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: type.icon)
                .font(.system(size: 20))
                .foregroundColor(type.iconColor)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .typography(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorPalette.richBlack)

                Text(message)
                    .typography(.footnote)
                    .foregroundColor(ColorPalette.gray700)
                    .fixedSize(horizontal: false, vertical: true)

                if let action = action, let actionTitle = actionTitle {
                    Button(action: action) {
                        Text(actionTitle)
                            .typography(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(type.iconColor)
                    }
                    .padding(.top, Spacing.xs)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .background(type.backgroundColor)
        .cornerRadius(CornerRadius.sm)
    }
}
