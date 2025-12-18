import SwiftUI
import Testing

@testable import TempoAI

struct ColorExtensionTests {

    // MARK: - Brand Colors Existence Tests

    @Test("Brand colors are accessible at runtime")
    func brandColorsExist() {
        // Verify brand colors defined in Color+Extensions are accessible at runtime
        #expect(Color.tempoSageGreen != nil)
        #expect(Color.tempoWarmBeige != nil)
        #expect(Color.tempoSoftCoral != nil)
        #expect(Color.tempoLightCream != nil)
    }

    @Test("Text colors are accessible at runtime")
    func textColorsExist() {
        #expect(Color.tempoPrimaryText != nil)
        #expect(Color.tempoSecondaryText != nil)
        #expect(Color.tempoBackground != nil)
    }

    @Test("Semantic colors are accessible at runtime")
    func semanticColorsExist() {
        #expect(Color.tempoSuccess != nil)
        #expect(Color.tempoWarning != nil)
        #expect(Color.tempoError != nil)
        #expect(Color.tempoInfo != nil)
    }

    @Test("Interest category colors are accessible at runtime")
    func interestCategoryColorsExist() {
        #expect(Color.tempoBeauty != nil)
        #expect(Color.tempoFitness != nil)
        #expect(Color.tempoMentalHealth != nil)
        #expect(Color.tempoWorkPerformance != nil)
        #expect(Color.tempoNutrition != nil)
        #expect(Color.tempoSleep != nil)
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

        for interest in allInterests {
            let color = Color.colorForInterest(interest)
            #expect(color != nil)
        }

        #expect(allInterests.count > 0)

        let colorMappings = allInterests.map { Color.colorForInterest($0) }
        #expect(colorMappings.count == allInterests.count)
    }

    // MARK: - Color Distinction Tests

    @Test("Brand and semantic colors are distinct from each other")
    func colorsAreDistinct() {
        #expect(Color.tempoSageGreen != Color.tempoSoftCoral)
        #expect(Color.tempoPrimaryText != Color.tempoSecondaryText)
        #expect(Color.tempoSuccess != Color.tempoError)
    }
}
