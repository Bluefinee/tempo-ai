import SwiftUI

struct SettingsPlaceholderView: View {
  @State private var showResetConfirmation: Bool = false
  @State private var showCompleteResetConfirmation: Bool = false
  @State private var showResetSuccessToast: Bool = false

  var body: some View {
    NavigationStack {
      List {
        // MARK: - Account Section
        Section {
          HStack {
            Image(systemName: "person.circle.fill")
              .font(.title2)
              .foregroundColor(.tempoSageGreen)
            VStack(alignment: .leading, spacing: 4) {
              Text("プロフィール編集")
                .font(.body)
                .foregroundColor(.tempoPrimaryText)
              Text("Phase 6で実装予定")
                .font(.caption)
                .foregroundColor(.tempoSecondaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
              .font(.caption)
              .foregroundColor(.tempoSecondaryText)
          }
          .contentShape(Rectangle())
          .padding(.vertical, 4)
        } header: {
          Text("アカウント")
        }

        // MARK: - App Settings Section
        Section {
          HStack {
            Image(systemName: "bell.fill")
              .font(.title3)
              .foregroundColor(.tempoSageGreen)
            Text("通知設定")
              .font(.body)
              .foregroundColor(.tempoPrimaryText)
            Spacer()
            Image(systemName: "chevron.right")
              .font(.caption)
              .foregroundColor(.tempoSecondaryText)
          }
          .contentShape(Rectangle())
          .padding(.vertical, 4)
        } header: {
          Text("アプリ設定")
        }

        // MARK: - Data Management Section
        Section {
          Button {
            showResetConfirmation = true
          } label: {
            HStack {
              Image(systemName: "arrow.counterclockwise")
                .font(.title3)
                .foregroundColor(.tempoSoftCoral)
              VStack(alignment: .leading, spacing: 4) {
                Text("オンボーディングをやり直す")
                  .font(.body)
                  .foregroundColor(.tempoPrimaryText)
                Text("プロフィール設定をリセットします")
                  .font(.caption)
                  .foregroundColor(.tempoSecondaryText)
              }
              Spacer()
            }
          }
          .padding(.vertical, 4)

          Button {
            showCompleteResetConfirmation = true
          } label: {
            HStack {
              Image(systemName: "trash.fill")
                .font(.title3)
                .foregroundColor(.tempoError)
              VStack(alignment: .leading, spacing: 4) {
                Text("すべてのデータを削除")
                  .font(.body)
                  .foregroundColor(.tempoError)
                Text("アプリを初期状態に戻します")
                  .font(.caption)
                  .foregroundColor(.tempoSecondaryText)
              }
              Spacer()
            }
          }
          .padding(.vertical, 4)
        } header: {
          Text("データ管理")
        } footer: {
          Text("データを削除すると、プロフィール情報やアドバイス履歴がすべて消去されます。")
            .font(.caption2)
        }

        // MARK: - About Section
        Section {
          HStack {
            Text("バージョン")
              .font(.body)
              .foregroundColor(.tempoPrimaryText)
            Spacer()
            Text(appVersion)
              .font(.body)
              .foregroundColor(.tempoSecondaryText)
          }
          .padding(.vertical, 4)

          if let helpURL = URL(string: "https://github.com/Bluefinee/tempo-ai") {
            Link(destination: helpURL) {
              HStack {
                Image(systemName: "questionmark.circle.fill")
                  .font(.title3)
                  .foregroundColor(.tempoSageGreen)
                Text("ヘルプ・お問い合わせ")
                  .font(.body)
                  .foregroundColor(.tempoPrimaryText)
                Spacer()
                Image(systemName: "arrow.up.right")
                  .font(.caption)
                  .foregroundColor(.tempoSecondaryText)
              }
            }
            .padding(.vertical, 4)
          }
        } header: {
          Text("このアプリについて")
        }
      }
      .listStyle(.insetGrouped)
      .background(Color.tempoLightCream.ignoresSafeArea())
      .scrollContentBackground(.hidden)
      .navigationTitle("設定")
      .navigationBarTitleDisplayMode(.large)
      .confirmationDialog(
        "オンボーディングをやり直しますか？",
        isPresented: $showResetConfirmation,
        titleVisibility: .visible
      ) {
        Button("やり直す", role: .destructive) {
          performLightReset()
        }
        Button("キャンセル", role: .cancel) {}
      } message: {
        Text("プロフィール設定がリセットされ、最初から設定し直すことができます。")
      }
      .confirmationDialog(
        "すべてのデータを削除しますか？",
        isPresented: $showCompleteResetConfirmation,
        titleVisibility: .visible
      ) {
        Button("削除する", role: .destructive) {
          performCompleteReset()
        }
        Button("キャンセル", role: .cancel) {}
      } message: {
        Text("この操作は元に戻せません。プロフィール、アドバイス履歴など、すべてのデータが削除されます。")
      }
      .overlay(alignment: .bottom) {
        if showResetSuccessToast {
          resetSuccessToast
        }
      }
    }
  }

  // MARK: - Computed Properties

  private var appVersion: String {
    let version =
      Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "\(version) (\(build))"
  }

  // MARK: - Views

  @ViewBuilder
  private var resetSuccessToast: some View {
    HStack {
      Image(systemName: "checkmark.circle.fill")
        .font(.body)
        .foregroundColor(.tempoSuccess)

      Text("リセットしました")
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.tempoPrimaryText)

      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.white)
        .shadow(
          color: Color.black.opacity(0.15),
          radius: 8,
          x: 0,
          y: 4
        )
    )
    .padding(.horizontal, 24)
    .padding(.bottom, 20)
    .transition(
      .asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .opacity
      )
    )
  }

  // MARK: - Methods

  private func performLightReset() {
    CacheManager.shared.performLightReset()
    showSuccessToast()
  }

  private func performCompleteReset() {
    CacheManager.shared.performCompleteReset()
    showSuccessToast()
  }

  private func showSuccessToast() {
    withAnimation(.easeInOut(duration: 0.3)) {
      showResetSuccessToast = true
    }

    Task { @MainActor in
      try? await Task.sleep(nanoseconds: 2_000_000_000)
      withAnimation(.easeOut(duration: 0.3)) {
        showResetSuccessToast = false
      }
    }
  }
}

#if DEBUG
#Preview {
  SettingsPlaceholderView()
}
#endif
