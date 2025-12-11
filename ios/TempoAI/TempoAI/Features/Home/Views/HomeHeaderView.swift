import SwiftUI

struct HomeHeaderView: View {
  let userProfile: UserProfile
  @State private var isTravelModeOn: Bool = false
  @State private var showToast: Bool = false
  @State private var toastMessage: String = ""
  @State private var showTooltip: Bool = false

  var body: some View {
    VStack(spacing: 0) {
      // Top row: Date (left) + Travel Mode (right)
      HStack {
        #if DEBUG
        Text(MockData.getCurrentDateString())
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.tempoPrimaryText)
        #endif
        
        Spacer()
        
        // Travel mode toggle with tooltip
        VStack {
          Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
              isTravelModeOn.toggle()
              
              // Show toast notification
              toastMessage = isTravelModeOn ? "トラベルモードがONになりました" : "トラベルモードがOFFになりました"
              showToast = true
              
              // Auto-hide toast after 2 seconds
              DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                  showToast = false
                }
              }
            }
          }) {
            HStack(spacing: 6) {
              Image(systemName: isTravelModeOn ? "suitcase.fill" : "suitcase")
                .font(.subheadline)
                .foregroundColor(isTravelModeOn ? .tempoSoftCoral : .tempoSecondaryText)
              
              Text(isTravelModeOn ? "ON" : "OFF")
                .font(.subheadline)
                .fontWeight(isTravelModeOn ? .semibold : .medium)
                .foregroundColor(isTravelModeOn ? .tempoSoftCoral : .tempoSecondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(isTravelModeOn ? Color.tempoSoftCoral.opacity(0.15) : Color.tempoSecondaryText.opacity(0.1))
                .animation(.easeInOut(duration: 0.3), value: isTravelModeOn)
            )
          }
          .onLongPressGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
              showTooltip = true
            }
            
            // Auto-hide tooltip after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
              withAnimation(.easeOut(duration: 0.3)) {
                showTooltip = false
              }
            }
          }
          
          // Tooltip
          if showTooltip {
            VStack(alignment: .leading, spacing: 8) {
              Text("🧳 トラベルモード")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.tempoPrimaryText)
              
              Text("旅行先で体内時計のずれを\n調整するためのモードです")
                .font(.caption2)
                .foregroundColor(.tempoSecondaryText)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(
                  color: Color.black.opacity(0.12),
                  radius: 6,
                  x: 0,
                  y: 3
                )
            )
            .frame(width: 160)
            .transition(
              .asymmetric(
                insertion: .scale(scale: 0.9).combined(with: .opacity),
                removal: .opacity
              )
            )
          }
        }
      }
      .padding(.horizontal, 24)
      .padding(.top, 16)
      .padding(.bottom, 2)
      
      // Weather information row
      HStack {
        #if DEBUG
        Text(
          "\(MockData.mockWeather.weatherIcon) \(MockData.mockWeather.cityName) "
            + "\(MockData.mockWeather.temperature)°C"
        )
        .font(.subheadline)
        .foregroundColor(.tempoSecondaryText)
        #endif
        
        Spacer()
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      
      // Greeting section (independent, left-aligned)
      HStack {
        #if DEBUG
        Text(MockData.getCurrentGreeting(nickname: userProfile.nickname))
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.tempoPrimaryText)
          .multilineTextAlignment(.leading)
        #endif
        
        Spacer()
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 8)
    }
    .background(
      Color.tempoLightCream
        .ignoresSafeArea(edges: .top)
    )
    .overlay(
      // Toast notification
      VStack {
        if showToast {
          HStack {
            Image(systemName: "checkmark.circle.fill")
              .font(.caption)
              .foregroundColor(.tempoSuccess)
            
            Text(toastMessage)
              .font(.caption)
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
          .transition(
            .asymmetric(
              insertion: .move(edge: .top).combined(with: .opacity),
              removal: .opacity
            )
          )
        }
        
        Spacer()
      }
      .padding(.top, 8)
    )
  }
}

#Preview {
  HomeHeaderView(userProfile: UserProfile.sampleData)
}

