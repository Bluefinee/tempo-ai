import SwiftUI

struct MainTabView: View {
  let userProfile: UserProfile

  var body: some View {
    TabView {
      HomeView(userProfile: userProfile)
        .tabItem {
          Image(systemName: "house.fill")
          Text("ホーム")
        }
        .tag(0)

      CircadianRhythmPlaceholderView()
        .tabItem {
          Image(systemName: "clock.arrow.2.circlepath")
          Text("リズム")
        }
        .tag(1)

      SettingsPlaceholderView()
        .tabItem {
          Image(systemName: "gearshape.fill")
          Text("設定")
        }
        .tag(2)
    }
    .accentColor(.tempoSageGreen)
  }
}

#if DEBUG
#Preview {
  MainTabView(userProfile: UserProfile.sampleData)
}
#endif
