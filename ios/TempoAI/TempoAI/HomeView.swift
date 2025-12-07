import SwiftUI

@MainActor
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var healthScore: Double = 0.75  // Mock score for demonstration

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.lg) {
                    headerSection

                    if viewModel.isAnyLoading && !viewModel.hasData {
                        loadingSection
                    } else if let errorMessage = viewModel.errorMessage {
                        errorSection(errorMessage)
                    } else {
                        contentSection
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.lg)
            }
            .background(ColorPalette.primaryBackground)
            .accessibilityIdentifier(UIIdentifiers.HomeView.scrollView)
            .navigationTitle("")
            .navigationBarHidden(true)
            .refreshable {
                await viewModel.refreshAll()
            }
            .accessibilityIdentifier(UIIdentifiers.HomeView.refreshControl)
            .task {
                await viewModel.initialize()
            }
            .sheet(isPresented: $viewModel.showingPermissions) {
                PermissionsView(
                    locationManager: LocationManager(),
                    onDismiss: viewModel.dismissPermissions
                )
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        DynamicHeader {
            viewModel.showPermissions()
        }
        .accessibilityIdentifier(UIIdentifiers.HomeView.headerSection)
    }

    // MARK: - Content Section

    @ViewBuilder
    private var contentSection: some View {
        VStack(spacing: Spacing.lg) {
            // Permission guidance banner
            if let bannerType = viewModel.permissionBannerType {
                PermissionBannerView(type: bannerType) {
                    viewModel.openPermissionSettings()
                }
                .transition(.scale.combined(with: .opacity))
            }

            // Mock data banner
            if viewModel.shouldShowMockBanner {
                mockDataBanner
                    .transition(.scale.combined(with: .opacity))
            }

            // Health Score Ring
            healthScoreSection

            // Advice section
            adviceSection
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.hasData)
    }

    private var healthScoreSection: some View {
        Card {
            VStack(spacing: Spacing.md) {
                Text(NSLocalizedString("health_overview", comment: "Health Overview"))
                    .headlineStyle()

                HealthScoreRing(score: healthScore)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            // Simulate score update
                            healthScore = Double.random(in: 0.3 ... 0.95)
                        }
                    }

                if let healthAnalysis = viewModel.healthAnalysis {
                    VStack(spacing: Spacing.sm) {
                        ForEach(healthAnalysis.metrics.prefix(3), id: \.category) { metric in
                            CompactMetricRow(metric: metric)
                        }
                    }
                }
            }
        }
        .cardElevation()
    }

    private var adviceSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(NSLocalizedString("todays_advice", comment: "Today's Advice"))
                .headlineStyle()
                .padding(.horizontal, Spacing.xs)

            if let advice = viewModel.todayAdvice {
                EnhancedAdviceCard(
                    advice: advice,
                    priority: .high
                ) { action in
                    handleAdviceAction(action)
                }
            } else if !viewModel.isLoadingAdvice {
                EmptyAdviceCard {
                    await viewModel.refreshAdvice()
                }
            }
        }
    }

    // MARK: - Support Views

    private var loadingSection: some View {
        VStack(spacing: Spacing.xl) {
            HealthScoreRing(score: 0.0)
                .skeleton()

            VStack(spacing: Spacing.md) {
                ForEach(0 ..< 3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(ColorPalette.gray100)
                        .frame(height: 80)
                        .skeleton()
                }
            }
        }
    }

    private func errorSection(_ message: String) -> some View {
        InfoCard(
            title: NSLocalizedString("error_occurred", comment: "Error Occurred"),
            message: message,
            type: .error,
            actionTitle: NSLocalizedString("retry", comment: "Retry")
        ) {
            Task {
                await viewModel.refreshAll()
            }
        }
    }

    private var mockDataBanner: some View {
        InfoCard(
            title: NSLocalizedString("demo_mode", comment: "Demo Mode"),
            message: NSLocalizedString("home_mock_data_banner", comment: "Using demo data"),
            type: .warning
        )
        .accessibilityIdentifier(UIIdentifiers.HomeView.mockDataBanner)
    }

    // MARK: - Helper Views

    private struct CompactMetricRow: View {
        let metric: HealthMetric

        var body: some View {
            HStack {
                Image(systemName: metric.category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(metric.category.color)
                    .frame(width: 24)

                Text(metric.category.displayName)
                    .bodyStyle()

                Spacer()

                CompactHealthScoreRing(
                    score: metric.normalizedValue,
                    size: 24
                )
            }
        }
    }

    private struct EmptyAdviceCard: View {
        let onRefresh: () async -> Void

        var body: some View {
            Card {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 48))
                        .foregroundColor(ColorPalette.gray300)

                    Text(NSLocalizedString("no_advice_available", comment: "No advice available"))
                        .headlineStyle()

                    Text(
                        NSLocalizedString(
                            "check_back_later", comment: "Check back later for personalized recommendations")
                    )
                    .bodyStyle()
                    .multilineTextAlignment(.center)

                    SecondaryButton(NSLocalizedString("refresh", comment: "Refresh")) {
                        Task {
                            await onRefresh()
                        }
                    }
                }
                .padding(Spacing.md)
            }
        }
    }

    // MARK: - Actions

    private func handleAdviceAction(_ action: AdviceAction) {
        HapticFeedback.success.trigger()

        switch action {
        case .markComplete:
            // Handle completion
            break
        case .remindLater:
            // Handle reminder
            break
        case .showDetails:
            // Show detailed view
            break
        }
    }
}

#Preview("Home Screen") {
    HomeView()
}

#Preview("With Health Data") {
    HomeView()
}
