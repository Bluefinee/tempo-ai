import SwiftUI

@MainActor
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection

                    if viewModel.isAnyLoading && !viewModel.hasData {
                        LoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage) {
                            await viewModel.refreshAll()
                        }
                    } else {
                        contentSection
                    }
                }
                .padding()
            }
            .accessibilityIdentifier(UIIdentifiers.HomeView.scrollView)
            .navigationTitle(NSLocalizedString("tab_today", comment: "Today"))
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refreshAll()
            }
            .accessibilityIdentifier(UIIdentifiers.HomeView.refreshControl)
            .task {
                await viewModel.initialize()
            }
            .sheet(isPresented: $viewModel.showingPermissions) {
                PermissionsView(
                    healthKitManager: HealthKitManager(),
                    locationManager: LocationManager(),
                    onDismiss: viewModel.dismissPermissions
                )
            }
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        VStack(spacing: 16) {
            // Mock data banner
            if viewModel.shouldShowMockBanner {
                mockDataBanner
            }

            // Health status card
            if let healthAnalysis = viewModel.healthAnalysis {
                HealthStatusCard(
                    healthAnalysis: healthAnalysis,
                    isLoading: viewModel.isLoadingHealth
                )
            }

            // Advice section
            if let advice = viewModel.todayAdvice {
                AdviceView(advice: advice)
            } else if !viewModel.isLoadingAdvice {
                EmptyStateView {
                    await viewModel.refreshAdvice()
                }
            }
        }
    }

    private var mockDataBanner: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .accessibilityIdentifier(UIIdentifiers.HomeView.mockDataIcon)
            Text(NSLocalizedString("home_mock_data_banner", comment: "Using demo data"))
                .font(.caption)
                .foregroundColor(.orange)
                .accessibilityIdentifier(UIIdentifiers.HomeView.mockDataText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.orange.opacity(0.1))
        .cornerRadius(8)
        .accessibilityIdentifier(UIIdentifiers.HomeView.mockDataBanner)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(viewModel.timeBasedGreeting)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier(UIIdentifiers.HomeView.greetingText)

                Spacer()

                Button {
                    viewModel.showPermissions()
                } label: {
                    Image(systemName: "gear")
                        .font(.title3)
                }
                .accessibilityIdentifier(UIIdentifiers.HomeView.settingsButton)
            }

            Text(NSLocalizedString("home_subtitle", comment: "Personalized health advice based on your data"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .accessibilityIdentifier(UIIdentifiers.HomeView.subtitleText)
        }
        .accessibilityIdentifier(UIIdentifiers.HomeView.headerSection)
    }

}

#Preview("Home Screen") {
    HomeView()
}

#Preview("With Health Data") {
    HomeView()
}
