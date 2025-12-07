import SwiftUI

struct PermissionItem: Identifiable {
    let id: UUID = UUID()
    let icon: String
    let title: String
    let description: String
}

struct OnboardingFlowView: View {
    @EnvironmentObject private var coordinator: OnboardingCoordinator

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }

                VStack {
                    if coordinator.currentPage != .welcome {
                        OnboardingProgressBar(
                            currentPage: coordinator.currentPage,
                            totalPages: OnboardingPage.allCases.count
                        )
                        .padding(.top, Spacing.md)
                    }

                    TabView(selection: $coordinator.currentPage) {
                        WelcomePage(onNext: coordinator.nextPage)
                            .tag(OnboardingPage.welcome)

                        UserModePage(
                            selectedMode: $coordinator.selectedUserMode,
                            onNext: coordinator.nextPage
                        )
                        .tag(OnboardingPage.userMode)

                        FocusTagsPage(
                            selectedTags: $coordinator.selectedTags,
                            onNext: coordinator.nextPage
                        )
                        .tag(OnboardingPage.focusTags)

                        PermissionPage(
                            title: "健康データへのアクセス",
                            subtitle: "バッテリー計算に必要なデータの取得を許可してください",
                            icon: "heart.text.square",
                            iconColor: ColorPalette.error,
                            items: healthPermissionItems,
                            isGranted: $coordinator.healthPermissionGranted,
                            onNext: coordinator.nextPage
                        ) {
                            Task {
                                coordinator.healthPermissionGranted = await requestHealthPermissions()
                            }
                        }
                        .tag(OnboardingPage.healthPermission)

                        PermissionPage(
                            title: "位置情報アクセス",
                            subtitle: "気象データ取得のための位置情報アクセスを許可してください",
                            icon: "location",
                            iconColor: ColorPalette.info,
                            items: locationPermissionItems,
                            isGranted: $coordinator.locationPermissionGranted,
                            onNext: coordinator.nextPage
                        ) {
                            Task {
                                coordinator.locationPermissionGranted = await requestLocationPermissions()
                            }
                        }
                        .tag(OnboardingPage.locationPermission)

                        CompletionPage {
                            coordinator.completeOnboarding()
                        }
                            .tag(OnboardingPage.completion)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .disabled(true)

                    if coordinator.currentPage != .welcome && coordinator.currentPage != .completion {
                        OnboardingNavigationBar(
                            canGoBack: coordinator.currentPage.rawValue > 0,
                            canProceed: coordinator.canProceed,
                            onBack: coordinator.previousPage,
                            onNext: coordinator.nextPage
                        )
                        .padding(.bottom, Spacing.md)
                    }
                }
            }
        }
    }

    private let healthPermissionItems = [
        PermissionItem(icon: "heart", title: "心拍数", description: "ストレスレベル計算のため"),
        PermissionItem(icon: "bed.double", title: "睡眠データ", description: "朝のバッテリー充電量計算のため"),
        PermissionItem(icon: "figure.walk", title: "活動量", description: "バッテリー消費量計算のため"),
    ]

    private let locationPermissionItems = [
        PermissionItem(icon: "thermometer", title: "気温・湿度", description: "バッテリー消費への環境影響分析"),
        PermissionItem(icon: "barometer", title: "気圧", description: "頭痛リスク予測のため"),
        PermissionItem(icon: "shield.lefthalf.filled", title: "プライバシー保護", description: "市町村レベルの座標のみ使用"),
    ]

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func requestHealthPermissions() async -> Bool {
        // TODO: Implement actual HealthKit authorization
        // HKHealthStore.isHealthDataAvailable() check required per swift-coding-standards.md
        return true
    }

    private func requestLocationPermissions() async -> Bool {
        // TODO: Implement actual CLLocationManager authorization
        return true
    }
}

struct OnboardingProgressBar: View {
    let currentPage: OnboardingPage
    let totalPages: Int

    private var progress: Double {
        Double(currentPage.rawValue) / Double(totalPages - 1)
    }

    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                Text("ステップ \(currentPage.rawValue + 1) / \(totalPages)")
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray500)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .typography(.caption)
                    .foregroundColor(ColorPalette.gray500)
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: ColorPalette.success))
                .frame(height: 4)
        }
        .padding(.horizontal, Spacing.lg)
    }
}

struct OnboardingNavigationBar: View {
    let canGoBack: Bool
    let canProceed: Bool
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button("戻る", action: onBack)
                .buttonStyle(SecondaryButtonStyle())
                .opacity(canGoBack ? 1.0 : 0.3)
                .disabled(!canGoBack)
                .frame(maxWidth: .infinity)

            Button("次へ", action: onNext)
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canProceed)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, Spacing.lg)
    }
}

#Preview {
    OnboardingFlowView()
}
