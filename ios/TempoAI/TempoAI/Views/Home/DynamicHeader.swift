import SwiftUI

/// Dynamic header that adapts to time of day with personalized greetings
struct DynamicHeader: View {
    @State private var currentGreeting: TimeBasedGreeting
    @State private var isAnimating: Bool = false

    private let settingsAction: () -> Void

    init(settingsAction: @escaping () -> Void) {
        self.settingsAction = settingsAction
        self._currentGreeting = State(initialValue: TimeBasedGreeting.current())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            headerRow

            subtitleText
        }
        .onAppear {
            startGreetingAnimation()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            updateGreeting()
        }
    }

    private var headerRow: some View {
        HStack {
            greetingSection

            Spacer()

            settingsButton
        }
    }

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(currentGreeting.greeting)
                .titleStyle()
                .opacity(isAnimating ? 1.0 : 0.0)
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .accessibilityIdentifier("dynamic_header_greeting")

            if let subtitle = currentGreeting.subtitle {
                Text(subtitle)
                    .subheadStyle()
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 10)
                    .accessibilityIdentifier("dynamic_header_subtitle")
            }
        }
    }

    private var subtitleText: some View {
        Text(NSLocalizedString("home_subtitle", comment: "Personalized health advice based on your data"))
            .subheadStyle()
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(y: isAnimating ? 0 : 10)
            .accessibilityIdentifier("dynamic_header_description")
    }

    private var settingsButton: some View {
        IconButton(
            icon: "gear",
            size: LayoutConstants.IconSize.medium
        ) {
            settingsAction()
        }
        .accessibilityLabel(NSLocalizedString("settings", comment: "Settings"))
        .accessibilityIdentifier("settings_button")
        .opacity(isAnimating ? 1.0 : 0.0)
        .scaleEffect(isAnimating ? 1.0 : 0.8)
    }

    private func startGreetingAnimation() {
        withAnimation(
            .spring(response: 0.6, dampingFraction: 0.8)
                .delay(0.2)
        ) {
            isAnimating = true
        }
    }

    private func updateGreeting() {
        let newGreeting = TimeBasedGreeting.current()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isAnimating = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentGreeting = newGreeting
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Time-based Greeting Logic

struct TimeBasedGreeting {
    let greeting: String
    let subtitle: String?
    let icon: String?
    let accentColor: Color

    static func current() -> TimeBasedGreeting {
        let hour = Calendar.current.component(.hour, from: Date())
        let calendar = Calendar.current
        let now = Date()

        switch hour {
        case 5 ..< 12:
            return TimeBasedGreeting(
                greeting: NSLocalizedString("greeting_morning", comment: "Good morning"),
                subtitle: NSLocalizedString("morning_message", comment: "Start your day strong"),
                icon: "sun.max.fill",
                accentColor: ColorPalette.warning
            )

        case 12 ..< 17:
            return TimeBasedGreeting(
                greeting: NSLocalizedString("greeting_afternoon", comment: "Good afternoon"),
                subtitle: NSLocalizedString("afternoon_message", comment: "Keep up the momentum"),
                icon: "sun.max.fill",
                accentColor: ColorPalette.info
            )

        case 17 ..< 22:
            return TimeBasedGreeting(
                greeting: NSLocalizedString("greeting_evening", comment: "Good evening"),
                subtitle: NSLocalizedString("evening_message", comment: "Time to wind down"),
                icon: "sunset.fill",
                accentColor: ColorPalette.warning.opacity(0.8)
            )

        default:
            return TimeBasedGreeting(
                greeting: NSLocalizedString("greeting_night", comment: "Good night"),
                subtitle: NSLocalizedString("night_message", comment: "Rest and recharge"),
                icon: "moon.stars.fill",
                accentColor: ColorPalette.gray500
            )
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct DynamicHeader_Previews: PreviewProvider {
        static var previews: some View {
            VStack {
                DynamicHeader(settingsAction: {})
                    .padding()

                Spacer()
            }
            .background(ColorPalette.primaryBackground)
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")

            VStack {
                DynamicHeader(settingsAction: {})
                    .padding()

                Spacer()
            }
            .background(ColorPalette.primaryBackground)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
#endif
