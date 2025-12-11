import SwiftUI

/**
 * Floating popup displaying additional advice
 * Appears at the bottom of the screen above the tab bar
 */
struct AdditionalAdvicePopup: View {
  let advice: AdditionalAdvice
  @Binding var isVisible: Bool

  var body: some View {
    VStack(spacing: 0) {
      Spacer()

      if isVisible {
        VStack(alignment: .leading, spacing: 12) {
          // Header with icon and close button
          HStack(alignment: .top, spacing: 8) {
            Text("💬")
              .font(.title3)

            Spacer()

            Button {
              withAnimation(.easeOut(duration: 0.25)) {
                isVisible = false
              }
            } label: {
              Image(systemName: "xmark")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.tempoSecondaryText)
                .frame(width: 24, height: 24)
            }
          }

          // Greeting
          Text(advice.greeting)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.tempoPrimaryText)

          // Message
          Text(advice.message)
            .font(.subheadline)
            .foregroundColor(.tempoSecondaryText)
            .lineLimit(5)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(
              color: Color.black.opacity(0.12),
              radius: 12,
              x: 0,
              y: -4
            )
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .transition(
          .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
          )
        )
      }
    }
    .animation(.easeOut(duration: 0.3), value: isVisible)
  }
}

// MARK: - Preview

#Preview("Visible Popup") {
  ZStack {
    Color.tempoLightCream.ignoresSafeArea()

    AdditionalAdvicePopup(
      advice: AdditionalAdvice(
        timeSlot: .afternoon,
        greeting: "お疲れさまです",
        message: "午前中の心拍数が普段より10%ほど高めで推移していました。深呼吸を3回、ゆっくり行ってみてください。",
        generatedAt: Date()
      ),
      isVisible: .constant(true)
    )
  }
}

#Preview("Hidden Popup") {
  ZStack {
    Color.tempoLightCream.ignoresSafeArea()

    AdditionalAdvicePopup(
      advice: AdditionalAdvice(
        timeSlot: .afternoon,
        greeting: "お疲れさまです",
        message: "午前中の心拍数が普段より10%ほど高めで推移していました。",
        generatedAt: Date()
      ),
      isVisible: .constant(false)
    )
  }
}

#Preview("Long Message") {
  ZStack {
    Color.tempoLightCream.ignoresSafeArea()

    AdditionalAdvicePopup(
      advice: AdditionalAdvice(
        timeSlot: .evening,
        greeting: "お疲れさまです",
        message: "今日は移動が多く、通常より歩数が30%増加していました。夕食後は軽いストレッチを10分ほど行うことで、筋肉の疲労回復を促進できます。特にふくらはぎと太ももを重点的にケアしましょう。",
        generatedAt: Date()
      ),
      isVisible: .constant(true)
    )
  }
}
