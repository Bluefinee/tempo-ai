import SwiftUI

/// 5段階ゲージコンポーネント
/// Level 5: Green, Level 4: Green, Level 3: Yellow, Level 2: Orange, Level 1: Red
struct FiveStageGaugeView: View {
    let level: Int

    private let totalDots: Int = 5

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<totalDots, id: \.self) { index in
                Circle()
                    .fill(index < level ? filledColor : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private var filledColor: Color {
        switch level {
        case 5, 4: return .gaugeGreen
        case 3: return .gaugeYellow
        case 2: return .gaugeOrange
        default: return .gaugeRed
        }
    }
}

// MARK: - Gauge Colors

extension Color {
    /// ゲージ用グリーン (#7CB342)
    static let gaugeGreen = Color(red: 0.486, green: 0.702, blue: 0.259)
    /// ゲージ用イエロー (#FFC107)
    static let gaugeYellow = Color(red: 1.0, green: 0.757, blue: 0.027)
    /// ゲージ用オレンジ (#FF9800)
    static let gaugeOrange = Color(red: 1.0, green: 0.596, blue: 0.0)
    /// ゲージ用レッド (#F44336)
    static let gaugeRed = Color(red: 0.957, green: 0.263, blue: 0.212)
}

// MARK: - Preview

#if DEBUG
#Preview("5-Stage Gauge - All Levels") {
    VStack(spacing: 16) {
        ForEach(0...5, id: \.self) { level in
            HStack {
                Text("Level \(level)")
                    .frame(width: 60, alignment: .leading)
                FiveStageGaugeView(level: level)
            }
        }
    }
    .padding()
}
#endif
