import SwiftUI

struct CircadianRhythmPlaceholderView: View {
  var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        Image(systemName: "clock.arrow.2.circlepath")
          .font(.system(size: 64))
          .foregroundColor(.tempoSageGreen)

        Text("サーカディアンリズム")
          .font(.title2)
          .fontWeight(.semibold)

        Text("Phase 12で実装予定")
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.tempoBackground)
      .navigationTitle("リズム")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

#if DEBUG
#Preview {
  CircadianRhythmPlaceholderView()
}
#endif
