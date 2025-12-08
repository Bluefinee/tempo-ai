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
        case .userMode: return "ライフスタイル設定"
        case .focusTags: return "関心タグ"
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

    @Published var selectedUserMode: UserMode?
    @Published var selectedTags: Set<FocusTag> = []
    @Published var healthPermissionGranted: Bool = false
    @Published var locationPermissionGranted: Bool = false

    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "onboarding_completed"

    init() {
        isCompleted = userDefaults.bool(forKey: onboardingCompletedKey)
        print("🔍 OnboardingCoordinator init - currentPage: \(currentPage), isCompleted: \(isCompleted)")
        updateCanProceed()
        print("🔍 After init updateCanProceed - canProceed: \(canProceed)")
    }

    func nextPage() {
        print("nextPage called - currentPage: \(currentPage), canProceed: \(canProceed)")
        
        // Check current page requirements directly instead of relying on canProceed
        switch currentPage {
        case .welcome:
            break // Always can proceed
        case .userMode:
            guard selectedUserMode != nil else {
                print("nextPage blocked - no UserMode selected")
                return
            }
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
        print("🔍 updateCanProceed - page: \(currentPage), oldCanProceed: \(oldCanProceed), newCanProceed: \(canProceed)")
        if currentPage == .userMode {
            print("🔍 UserMode state - selectedUserMode: \(String(describing: selectedUserMode))")
        }
        if currentPage == .focusTags {
            print("🔍 FocusTags state - selectedTags: \(selectedTags)")
        }
    }

    func completeOnboarding() {
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
