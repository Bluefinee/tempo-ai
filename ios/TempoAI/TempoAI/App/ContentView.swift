import SwiftUI
import Foundation

extension Notification.Name {
  static let onboardingReset = Notification.Name("onboardingReset")
}

struct ContentView: View {

  // MARK: - Properties

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
        HomeView(userProfile: userProfile)
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
        userProfile = profile
        isOnboardingCompleted = true
      } catch {
        print("Failed to load user profile: \(error)")
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

// MARK: - Home View (Placeholder)

private struct HomeView: View {
  let userProfile: UserProfile
  @State private var showingResetAlert = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          // ユーザーグリーティング
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text("こんにちは、\(userProfile.nickname)さん")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.tempoPrimaryText)

              Text("今日もあなたのペースで過ごしましょう")
                .font(.subheadline)
                .foregroundColor(.tempoSecondaryText)
            }

            Spacer()

            // リセットボタン（開発用）
            Button {
              showingResetAlert = true
            } label: {
              Image(systemName: "arrow.clockwise")
                .font(.title2)
                .foregroundColor(.tempoSageGreen)
            }
          }
          .padding(.horizontal, 24)
          .padding(.top, 16)

          // プレースホルダーコンテンツ
          VStack(spacing: 16) {
            PlaceholderCard(
              title: "今日のアドバイス",
              subtitle: "準備中...",
              icon: "lightbulb.fill",
              color: Color.tempoSoftCoral
            )

            PlaceholderCard(
              title: "健康データ",
              subtitle: "HealthKitと連携中...",
              icon: "heart.text.square.fill",
              color: Color.tempoSageGreen
            )
          }
          .padding(.horizontal, 24)

          Spacer(minLength: 100)
        }
      }
      .background(Color.tempoLightCream.ignoresSafeArea())
      .navigationBarHidden(true)
      .alert("オンボーディングをリセット", isPresented: $showingResetAlert) {
        Button("キャンセル", role: .cancel) { }
        Button("リセット", role: .destructive) {
          resetOnboarding()
        }
      } message: {
        Text("オンボーディングをリセットしますか？保存されたデータは削除されます。\n\nHealthKitと位置情報の権限も再設定が必要になる場合があります。")
      }
    }
  }

  private func resetOnboarding() {
    // リセット機能を一元管理されたCacheManagerに委譲
    CacheManager.shared.performCompleteReset()
  }
}

// MARK: - Placeholder Card

private struct PlaceholderCard: View {
  let title: String
  let subtitle: String
  let icon: String
  let color: Color

  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(color)
        .frame(width: 40)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.tempoPrimaryText)

        Text(subtitle)
          .font(.subheadline)
          .foregroundColor(.tempoSecondaryText)
          .lineLimit(2)
      }

      Spacer()
    }
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(.white.opacity(0.8))
        .stroke(Color.tempoLightGray.opacity(0.3), lineWidth: 1)
    )
  }
}

#Preview {
  ContentView()
}
