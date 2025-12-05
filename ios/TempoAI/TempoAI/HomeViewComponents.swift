import SwiftUI

// MARK: - Loading View
internal struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.loadingSpinner)

            Text("Analyzing your health data...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.loadingText)
        }
        .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.loadingView)
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

// MARK: - Error View
internal struct ErrorView: View {
    let message: String
    let onRetry: () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
                .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.errorIcon)

            Text("Something went wrong")
                .font(.headline)
                .fontWeight(.semibold)
                .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.errorTitle)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.errorMessage)

            Button("Try Again") {
                Task {
                    await onRetry()
                }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.errorRetryButton)
        }
        .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.errorView)
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

// MARK: - Empty State View
internal struct EmptyStateView: View {
    let onRefresh: () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.emptyStateIcon)

            Text("No advice available")
                .font(.headline)
                .fontWeight(.semibold)
                .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.emptyStateTitle)

            Text("We couldn't generate advice for you today. Please check your permissions and try again.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.emptyStateMessage)

            Button("Refresh") {
                Task {
                    await onRefresh()
                }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.emptyStateActionButton)
        }
        .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.emptyStateView)
        .padding()
        .frame(maxWidth: .infinity, minHeight: 300)
    }
}

// MARK: - Advice Card Component
internal struct AdviceCard: View {
    let title: String
    let content: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }

            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.adviceCardContent)
        }
        .accessibilityIdentifier(UIIdentifiers.HomeViewComponents.adviceCard)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(content)")
        .accessibilityAddTraits(.isStaticText)
    }
}
