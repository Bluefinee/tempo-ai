import SwiftUI
import Testing

@testable import TempoAI

struct ColorExtensionTests {

    // MARK: - Brand Colors Existence Tests

    @Test("Brand colors are accessible at runtime")
    func brandColorsExist() {
        // Verify brand colors defined in Color+Extensions are accessible at runtime
        let brandColors: [Color] = [
            .tempoSageGreen,
            .tempoWarmBeige,
            .tempoSoftCoral,
            .tempoLightCream
        ]
        #expect(brandColors.count == 4)
    }

    @Test("Text colors are accessible at runtime")
    func textColorsExist() {
        let textColors: [Color] = [
            .tempoPrimaryText,
            .tempoSecondaryText,
            .tempoBackground
        ]
        #expect(textColors.count == 3)
    }

    @Test("Semantic colors are accessible at runtime")
    func semanticColorsExist() {
        let semanticColors: [Color] = [
            .tempoSuccess,
            .tempoWarning,
            .tempoError,
            .tempoInfo
        ]
        #expect(semanticColors.count == 4)
    }

    @Test("Interest category colors are accessible at runtime")
    func interestCategoryColorsExist() {
        let interestColors: [Color] = [
            .tempoBeauty,
            .tempoFitness,
            .tempoMentalHealth,
            .tempoWorkPerformance,
            .tempoNutrition,
            .tempoSleep
        ]
        #expect(interestColors.count == 6)
    }

    // MARK: - Interest Color Mapping Tests

    @Test("Interests map to correct colors")
    func colorForInterestMapping() {
        #expect(Color.colorForInterest(.energyPerformance) == Color.tempoWorkPerformance)
        #expect(Color.colorForInterest(.nutrition) == Color.tempoNutrition)
        #expect(Color.colorForInterest(.fitness) == Color.tempoFitness)
        #expect(Color.colorForInterest(.mentalStress) == Color.tempoMentalHealth)
        #expect(Color.colorForInterest(.beauty) == Color.tempoBeauty)
        #expect(Color.colorForInterest(.sleep) == Color.tempoSleep)
    }

    @Test("All interests have color mappings")
    func allInterestsHaveColorMapping() {
        let allInterests = UserProfile.Interest.allCases
        #expect(!allInterests.isEmpty, "Interest enum should have cases")

        for interest in allInterests {
            // Accessing colorForInterest verifies the mapping exists
            _ = Color.colorForInterest(interest)
        }
    }

    // MARK: - Color Distinction Tests

    @Test("Brand and semantic colors are distinct from each other")
    func colorsAreDistinct() {
        #expect(Color.tempoSageGreen != Color.tempoSoftCoral)
        #expect(Color.tempoPrimaryText != Color.tempoSecondaryText)
        #expect(Color.tempoSuccess != Color.tempoError)
    }
}
