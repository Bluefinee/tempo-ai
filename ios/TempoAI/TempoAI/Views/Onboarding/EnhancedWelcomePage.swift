import SwiftUI

/// Enhanced welcome page with animated logo and language selection
struct EnhancedWelcomePage: View {
    @Binding var selectedLanguage: String
    let onContinue: () -> Void

    @State private var logoScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0.0
    @State private var languageOptionsOpacity: Double = 0.0
    @State private var continueButtonOpacity: Double = 0.0
    @State private var backgroundGradientOpacity: Double = 0.0

    private let animationDuration: Double = 0.8
    private let staggerDelay: Double = 0.2

    var body: some View {
        GeometryReader { _ in
            ZStack {
                backgroundGradient

                VStack(spacing: Spacing.xl) {
                    Spacer()

                    logoSection

                    titleSection

                    Spacer()

                    languageSelectionSection

                    continueButtonSection
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.lg)
                .frame(maxWidth: LayoutConstants.maxContentWidth)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            startWelcomeAnimation()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(NSLocalizedString("welcome_screen", comment: "Welcome screen"))
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                ColorPalette.primaryBackground,
                ColorPalette.pearl.opacity(0.3),
                ColorPalette.primaryBackground,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .opacity(backgroundGradientOpacity)
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                // Background circle with subtle animation
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorPalette.info.opacity(0.1),
                                ColorPalette.success.opacity(0.05),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(logoScale * 0.9)

                // Logo image or icon
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ColorPalette.info, ColorPalette.success],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(logoScale)
            }
            .accessibility(hidden: true)
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: Spacing.sm) {
            Text("TempoAI")
                .font(Typography.hero.font)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.richBlack)
                .opacity(titleOpacity)
                .accessibilityIdentifier("welcome_app_title")

            Text(NSLocalizedString("welcome_subtitle", comment: "Your AI-powered health companion"))
                .font(Typography.body.font)
                .foregroundColor(ColorPalette.gray500)
                .multilineTextAlignment(.center)
                .opacity(titleOpacity)
                .accessibilityIdentifier("welcome_subtitle")
        }
    }

    // MARK: - Language Selection

    private var languageSelectionSection: some View {
        VStack(spacing: Spacing.lg) {
            VStack(spacing: Spacing.sm) {
                Text(NSLocalizedString("choose_language", comment: "Choose your language"))
                    .font(Typography.headline.font)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.richBlack)

                Text(NSLocalizedString("language_help_text", comment: "You can change this later in settings"))
                    .font(Typography.caption.font)
                    .foregroundColor(ColorPalette.gray500)
            }
            .opacity(languageOptionsOpacity)

            VStack(spacing: Spacing.md) {
                LanguageOptionCard(
                    language: "日本語",
                    code: "ja",
                    flag: "🇯🇵",
                    isSelected: selectedLanguage == "ja"
                ) {
                    selectLanguage("ja")
                }

                LanguageOptionCard(
                    language: "English",
                    code: "en",
                    flag: "🇺🇸",
                    isSelected: selectedLanguage == "en"
                ) {
                    selectLanguage("en")
                }
            }
            .opacity(languageOptionsOpacity)
        }
    }

    // MARK: - Continue Button

    private var continueButtonSection: some View {
        VStack(spacing: Spacing.md) {
            PrimaryButton(NSLocalizedString("continue", comment: "Continue")) {
                onContinue()
            }
            .opacity(continueButtonOpacity)
            .disabled(selectedLanguage.isEmpty)

            Text(NSLocalizedString("welcome_privacy_note", comment: "Your privacy is our priority"))
                .font(Typography.caption.font)
                .foregroundColor(ColorPalette.gray300)
                .multilineTextAlignment(.center)
                .opacity(continueButtonOpacity)
        }
    }

    // MARK: - Animation Methods

    private func startWelcomeAnimation() {
        // Background appears first
        withAnimation(.easeOut(duration: animationDuration)) {
            backgroundGradientOpacity = 1.0
        }

        // Logo animation with bounce
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            logoScale = 1.0
        }

        // Title appears after logo
        withAnimation(.easeOut(duration: animationDuration).delay(0.8)) {
            titleOpacity = 1.0
        }

        // Language options slide in
        withAnimation(.easeOut(duration: animationDuration).delay(1.2)) {
            languageOptionsOpacity = 1.0
        }

        // Continue button appears last
        withAnimation(.easeOut(duration: animationDuration).delay(1.6)) {
            continueButtonOpacity = 1.0
        }
    }

    private func selectLanguage(_ languageCode: String) {
        HapticFeedback.selection.trigger()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedLanguage = languageCode
        }

        // Update app language if needed
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Language Option Card

struct LanguageOptionCard: View {
    let language: String
    let code: String
    let flag: String
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                Text(flag)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(language)
                        .font(Typography.headline.font)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.richBlack)

                    Text(code.uppercased())
                        .font(Typography.caption.font)
                        .foregroundColor(ColorPalette.gray500)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ColorPalette.success)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(Spacing.md)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(CornerRadius.md)
            .scaleEffect(isPressed ? ScaleEffect.active : 1.0)
            .elevation(isSelected ? .medium : .low)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity) {
            // Never triggered
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .accessibilityElement()
        .accessibilityLabel("\(language), \(isSelected ? NSLocalizedString("selected", comment: "selected") : "")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("language_option_\(code)")
    }

    private var backgroundColor: Color {
        if isSelected {
            return ColorPalette.successBackground
        }
        return isPressed ? ColorPalette.pearl : ColorPalette.offWhite
    }

    private var borderColor: Color {
        if isSelected {
            return ColorPalette.success
        }
        return ColorPalette.gray100
    }
}

// MARK: - Preview

#if DEBUG
    struct EnhancedWelcomePage_Previews: PreviewProvider {
        @State static var selectedLanguage: String = "ja"

        static var previews: some View {
            EnhancedWelcomePage(
                selectedLanguage: $selectedLanguage
            ) {
                print("Continue tapped")
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")

            EnhancedWelcomePage(
                selectedLanguage: $selectedLanguage
            ) {
                print("Continue tapped")
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
#endif
