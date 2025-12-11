import SwiftUI

struct SettingsPlaceholderView: View {
  var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        Spacer()

        VStack(spacing: 16) {
          Image(systemName: "gear")
            .font(.system(size: 60))
            .foregroundColor(.tempoSageGreen.opacity(0.6))

          Text("設定")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.tempoPrimaryText)

          Text("Phase 6で設定画面を実装予定です")
            .font(.subheadline)
            .foregroundColor(.tempoSecondaryText)
            .multilineTextAlignment(.center)
        }

        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.tempoLightCream.ignoresSafeArea())
      .navigationTitle("設定")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

#Preview {
  SettingsPlaceholderView()
}

