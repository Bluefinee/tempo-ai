import XCTest
import SwiftUI
@testable import TempoAI

final class ColorExtensionTests: XCTestCase {
    
    // MARK: - Brand Colors Existence Tests
    
    func testBrandColorsExist() {
        XCTAssertNotNil(Color.tempoSageGreen, "tempoSageGreen should be available")
        XCTAssertNotNil(Color.tempoWarmBeige, "tempoWarmBeige should be available")
        XCTAssertNotNil(Color.tempoSoftCoral, "tempoSoftCoral should be available")
        XCTAssertNotNil(Color.tempoLightCream, "tempoLightCream should be available")
    }
    
    func testTextColorsExist() {
        XCTAssertNotNil(Color.tempoPrimaryText, "tempoPrimaryText should be available")
        XCTAssertNotNil(Color.tempoSecondaryText, "tempoSecondaryText should be available")
        XCTAssertNotNil(Color.tempoBackground, "tempoBackground should be available")
    }
    
    func testSemanticColorsExist() {
        XCTAssertNotNil(Color.tempoSuccess, "tempoSuccess should be available")
        XCTAssertNotNil(Color.tempoWarning, "tempoWarning should be available")
        XCTAssertNotNil(Color.tempoError, "tempoError should be available")
        XCTAssertNotNil(Color.tempoInfo, "tempoInfo should be available")
    }
    
    func testInterestCategoryColorsExist() {
        XCTAssertNotNil(Color.tempoBeauty, "tempoBeauty should be available")
        XCTAssertNotNil(Color.tempoFitness, "tempoFitness should be available")
        XCTAssertNotNil(Color.tempoMentalHealth, "tempoMentalHealth should be available")
        XCTAssertNotNil(Color.tempoWorkPerformance, "tempoWorkPerformance should be available")
        XCTAssertNotNil(Color.tempoNutrition, "tempoNutrition should be available")
        XCTAssertNotNil(Color.tempoSleep, "tempoSleep should be available")
    }
    
    // MARK: - Interest Color Mapping Tests
    
    func testColorForInterestMapping() {
        XCTAssertEqual(Color.colorForInterest(.energyPerformance), Color.tempoWorkPerformance,
                      "Energy performance should map to work performance color")
        XCTAssertEqual(Color.colorForInterest(.nutrition), Color.tempoNutrition,
                      "Nutrition should map to nutrition color")
        XCTAssertEqual(Color.colorForInterest(.fitness), Color.tempoFitness,
                      "Fitness should map to fitness color")
        XCTAssertEqual(Color.colorForInterest(.mentalStress), Color.tempoMentalHealth,
                      "Mental stress should map to mental health color")
        XCTAssertEqual(Color.colorForInterest(.beauty), Color.tempoBeauty,
                      "Beauty should map to beauty color")
        XCTAssertEqual(Color.colorForInterest(.sleep), Color.tempoSleep,
                      "Sleep should map to sleep color")
    }
    
    func testAllInterestsHaveColorMapping() {
        let allInterests = UserProfile.Interest.allCases
        
        for interest in allInterests {
            let color = Color.colorForInterest(interest)
            XCTAssertNotNil(color, "Interest \(interest) should have color mapping")
        }
        
        XCTAssertEqual(allInterests.count, 6, "Should have 6 interest categories")
    }
    
    // MARK: - Color Distinction Tests
    
    func testColorsAreDistinct() {
        XCTAssertNotEqual(Color.tempoSageGreen, Color.tempoSoftCoral, "Brand colors should be distinct")
        XCTAssertNotEqual(Color.tempoPrimaryText, Color.tempoSecondaryText, "Text colors should be distinct")
        XCTAssertNotEqual(Color.tempoSuccess, Color.tempoError, "Semantic colors should be distinct")
    }
}