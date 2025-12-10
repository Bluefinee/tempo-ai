import SwiftUI

extension Color {

  // MARK: - Tempo AI Brand Colors

  /// Primary Brand Color: Soft Sage Green
  static let tempoSageGreen: Color = Color(red: 0.57, green: 0.70, blue: 0.62)  // #92B39F

  /// Secondary Brand Color: Warm Beige
  static let tempoWarmBeige: Color = Color(red: 0.94, green: 0.90, blue: 0.84)  // #F0E5D6

  /// Accent Color: Soft Coral (CTA Buttons)
  static let tempoSoftCoral: Color = Color(red: 0.89, green: 0.55, blue: 0.48)  // #E38B7A

  /// Background Color: Light Cream
  static let tempoLightCream: Color = Color(red: 0.98, green: 0.96, blue: 0.94)  // #FAF5F0

  /// Text Primary: Deep Charcoal
  static let tempoDeepCharcoal: Color = Color(red: 0.20, green: 0.22, blue: 0.24)  // #33373D

  /// Text Secondary: Medium Gray
  static let tempoMediumGray: Color = Color(red: 0.48, green: 0.52, blue: 0.56)  // #7A858F

  /// Text Tertiary: Light Gray
  static let tempoLightGray: Color = Color(red: 0.69, green: 0.73, blue: 0.77)  // #B0BAC4

  // MARK: - Semantic Colors

  /// Success Color: Gentle Green
  static let tempoSuccess: Color = Color(red: 0.40, green: 0.71, blue: 0.48)  // #66B57A

  /// Warning Color: Warm Orange
  static let tempoWarning: Color = Color(red: 0.95, green: 0.73, blue: 0.42)  // #F3BA6B

  /// Error Color: Soft Red
  static let tempoError: Color = Color(red: 0.91, green: 0.43, blue: 0.43)  // #E86E6E

  /// Info Color: Calm Blue
  static let tempoInfo: Color = Color(red: 0.42, green: 0.68, blue: 0.86)  // #6BAEDC

  // MARK: - Interest Category Colors

  /// Beauty & Skincare: Soft Pink
  static let tempoBeauty: Color = Color(red: 0.95, green: 0.75, blue: 0.82)  // #F3BFD1

  /// Fitness & Training: Energy Orange
  static let tempoFitness: Color = Color(red: 0.95, green: 0.72, blue: 0.51)  // #F3B782

  /// Mental Health: Calming Lavender
  static let tempoMentalHealth: Color = Color(red: 0.78, green: 0.72, blue: 0.90)  // #C7B8E6

  /// Work Performance: Professional Blue
  static let tempoWorkPerformance: Color = Color(red: 0.51, green: 0.68, blue: 0.86)  // #82AEDC

  /// Nutrition: Fresh Green
  static let tempoNutrition: Color = Color(red: 0.67, green: 0.85, blue: 0.67)  // #ABD9AB

  /// Sleep: Night Blue
  static let tempoSleep: Color = Color(red: 0.46, green: 0.58, blue: 0.78)  // #7594C7

  // MARK: - Component Colors

  /// Input Field Background
  static let tempoInputBackground: Color = .white.opacity(0.9)

  /// Input Field Border
  static let tempoInputBorder: Color = tempoLightGray.opacity(0.7)

  /// Input Field Border (Active)
  static let tempoInputBorderActive: Color = tempoSageGreen

  /// Progress Bar Background
  static let tempoProgressBackground: Color = tempoLightGray.opacity(0.3)

  // MARK: - Fixed Text Colors (Light Mode Only)

  /// Primary text color (fixed for light mode)
  static let tempoPrimaryText: Color = tempoDeepCharcoal

  /// Secondary text color (fixed for light mode)
  static let tempoSecondaryText: Color = tempoMediumGray

  /// Background color (fixed for light mode)
  static let tempoBackground: Color = tempoLightCream

  // MARK: - Methods

  /// Interest タグに対応する色を取得
  /// - Parameter interest: 関心ごと
  /// - Returns: 対応する色
  static func colorForInterest(_ interest: UserProfile.Interest) -> Color {
    switch interest {
    case .energyPerformance:
      return tempoWorkPerformance
    case .nutrition:
      return tempoNutrition
    case .fitness:
      return tempoFitness
    case .mentalStress:
      return tempoMentalHealth
    case .beauty:
      return tempoBeauty
    case .sleep:
      return tempoSleep
    }
  }
}
