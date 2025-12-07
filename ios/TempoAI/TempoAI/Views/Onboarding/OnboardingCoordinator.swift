import Combine
import Foundation
import SwiftUI

enum OnboardingPage: Int, CaseIterable {
    case welcome = 0
    case userMode = 1
    case focusTags = 2
    case healthPermission = 3
    case locationPermission = 4
    case completion = 5

    var title: String {
        switch self {
        case .welcome: return "ようこそ"
        case .userMode: return "バッテリーモード"
        case .focusTags: return "関心タグ"
        case .healthPermission: return "健康データ"
        case .locationPermission: return "位置情報"
        case .completion: return "完了"
        }
    }
}

@MainActor
class OnboardingCoordinator: ObservableObject {
    @Published var currentPage: OnboardingPage = .welcome
    @Published var isCompleted: Bool = false
    @Published var canProceed: Bool = false

    @Published var selectedUserMode: UserMode?
    @Published var selectedTags: Set<FocusTag> = []
    @Published var healthPermissionGranted: Bool = false
    @Published var locationPermissionGranted: Bool = false

    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "onboarding_completed"

    init() {
        isCompleted = userDefaults.bool(forKey: onboardingCompletedKey)
        updateCanProceed()
    }

    func nextPage() {
        guard canProceed else { return }

        if let nextPageIndex = OnboardingPage(rawValue: currentPage.rawValue + 1) {
            withAnimation(.easeInOut) {
                currentPage = nextPageIndex
            }
        } else {
            completeOnboarding()
        }

        updateCanProceed()
    }

    func previousPage() {
        if let prevPageIndex = OnboardingPage(rawValue: currentPage.rawValue - 1) {
            withAnimation(.easeInOut) {
                currentPage = prevPageIndex
            }
        }
        updateCanProceed()
    }

    private func updateCanProceed() {
        switch currentPage {
        case .welcome:
            canProceed = true
        case .userMode:
            canProceed = selectedUserMode != nil
        case .focusTags:
            canProceed = !selectedTags.isEmpty
        case .healthPermission:
            canProceed = healthPermissionGranted
        case .locationPermission:
            canProceed = locationPermissionGranted
        case .completion:
            canProceed = true
        }
    }

    private func completeOnboarding() {
        isCompleted = true
        userDefaults.set(true, forKey: onboardingCompletedKey)

        if let mode = selectedUserMode {
            UserProfileManager.shared.updateMode(mode)
        }

        let tagManager = FocusTagManager.shared
        tagManager.activeTags = selectedTags
        tagManager.completeOnboarding()
    }
}
