import SwiftUI
import Foundation
import os.log

extension Notification.Name {
  static let onboardingReset = Notification.Name("onboardingReset")
}

struct ContentView: View {

  // MARK: - Properties

  private let logger: Logger = Logger(subsystem: "com.tempoai", category: "ContentView")
  
  @State private var isOnboardingCompleted: Bool = false
  @State private var userProfile: UserProfile?
  @State private var isCheckingOnboardingStatus: Bool = true

  // MARK: - Body

  var body: some View {
    Group {
      if isCheckingOnboardingStatus {
        // 起動時のローディング画面
        LaunchLoadingView()
      } else if isOnboardingCompleted, let userProfile = userProfile {
        // メイン画面（オンボーディング完了済み）
        MainTabView(userProfile: userProfile)
      } else {
        // オンボーディング画面
        OnboardingContainerView { completedProfile in
          handleOnboardingCompletion(with: completedProfile)
        }
      }
    }
    .onAppear {
      checkOnboardingStatus()
    }
    .onReceive(NotificationCenter.default.publisher(for: .onboardingReset)) { _ in
      checkOnboardingStatus()
    }
  }

  // MARK: - Methods

  private func checkOnboardingStatus() {
    let isCompleted = CacheManager.shared.isOnboardingCompleted()

    if isCompleted {
      do {
        let profile = try CacheManager.shared.loadUserProfile()
        if let profile = profile {
          userProfile = profile
          isOnboardingCompleted = true
        } else {
          logger.warning("Onboarding completed but profile is nil, resetting state")
          CacheManager.shared.resetOnboardingState()
          isOnboardingCompleted = false
        }
      } catch {
        logger.error("Failed to load user profile: \(error.localizedDescription)")
        CacheManager.shared.deleteUserProfile()
        isOnboardingCompleted = false
      }
    } else {
      isOnboardingCompleted = false
    }

    isCheckingOnboardingStatus = false
  }

  private func handleOnboardingCompletion(with profile: UserProfile) {
    userProfile = profile
    isOnboardingCompleted = true
  }
}

// MARK: - Launch Loading View

private struct LaunchLoadingView: View {
  var body: some View {
    ZStack {
      Color.tempoLightCream
        .ignoresSafeArea()

      VStack(spacing: 24) {
        ZStack {
          Circle()
            .fill(
              LinearGradient(
                colors: [
                  Color.tempoSageGreen.opacity(0.8),
                  Color.tempoSageGreen.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 100, height: 100)

          Image(systemName: "heart.fill")
            .font(.system(size: 50))
            .foregroundStyle(.white)
        }

        VStack(spacing: 8) {
          Text("Tempo AI")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.tempoPrimaryText)

          Text("あなたのテンポで健やかな毎日を")
            .font(.subheadline)
            .foregroundColor(.tempoSecondaryText)
        }
      }
    }
  }
}


#Preview {
  ContentView()
}
