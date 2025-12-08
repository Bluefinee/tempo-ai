import Combine
import Foundation
import SwiftUI

enum OnboardingPage: Int, CaseIterable {
    case welcome = 0
    case focusTags = 1
    case healthPermission = 2
    case locationPermission = 3
    case completion = 4

    var title: String {
        switch self {
        case .welcome: return "ようこそ"
        case .focusTags: return "関心分野"
        case .healthPermission: return "ヘルスケアデータ"
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

    @Published var selectedTags: Set<FocusTag> = []
    @Published var healthPermissionGranted: Bool = false
    @Published var locationPermissionGranted: Bool = false

    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "onboarding_completed"

    init() {
        isCompleted = userDefaults.bool(forKey: onboardingCompletedKey)

        // 完了済みの場合はcurrentPageをcompletionに設定
        if isCompleted {
            currentPage = .completion
        }

        print("🔍 OnboardingCoordinator init - currentPage: \(currentPage), isCompleted: \(isCompleted)")
        updateCanProceed()
        print("🔍 After init updateCanProceed - canProceed: \(canProceed)")
    }

    func nextPage() {
        print("nextPage called - currentPage: \(currentPage), canProceed: \(canProceed)")

        // Check current page requirements directly
        switch currentPage {
        case .welcome:
            break  // Always can proceed
        case .focusTags:
            guard !selectedTags.isEmpty else {
                print("nextPage blocked - no FocusTags selected")
                return
            }
        case .healthPermission:
            // Can always proceed (permission optional)
            break
        case .locationPermission:
            // Can always proceed (permission optional)
            break
        case .completion:
            break
        }

        if let nextPageIndex = OnboardingPage(rawValue: currentPage.rawValue + 1) {
            print("Moving to next page: \(nextPageIndex)")
            currentPage = nextPageIndex
            updateCanProceed()
        } else {
            print("Completing onboarding")
            completeOnboarding()
        }
    }

    func previousPage() {
        if let prevPageIndex = OnboardingPage(rawValue: currentPage.rawValue - 1) {
            currentPage = prevPageIndex
            updateCanProceed()
        }
    }

    private func updateCanProceed() {
        let oldCanProceed = canProceed
        switch currentPage {
        case .welcome:
            canProceed = true
        case .focusTags:
            canProceed = !selectedTags.isEmpty
        case .healthPermission:
            canProceed = healthPermissionGranted
        case .locationPermission:
            canProceed = locationPermissionGranted
        case .completion:
            canProceed = true
        }
        print(
            "🔍 updateCanProceed - page: \(currentPage), oldCanProceed: \(oldCanProceed), newCanProceed: \(canProceed)")
        if currentPage == .focusTags {
            print("🔍 FocusTags state - selectedTags: \(selectedTags)")
        }
    }

    func completeOnboarding() {
        isCompleted = true
        userDefaults.set(true, forKey: onboardingCompletedKey)

        let tagManager = FocusTagManager.shared
        tagManager.activeTags = selectedTags
        tagManager.completeOnboarding()
    }
}
