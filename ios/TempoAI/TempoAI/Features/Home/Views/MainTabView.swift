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

      SettingsPlaceholderView()
        .tabItem {
          Image(systemName: "gearshape.fill")
          Text("設定")
        }
        .tag(1)
    }
    .accentColor(.tempoSageGreen)
  }
}

#if DEBUG
#Preview {
  MainTabView(userProfile: UserProfile.sampleData)
}
#endif

