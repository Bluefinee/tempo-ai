import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "heart.fill")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Tempo AI")
        .font(.title)
        .fontWeight(.bold)
      Text("Your Personalized Health Assistant")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
