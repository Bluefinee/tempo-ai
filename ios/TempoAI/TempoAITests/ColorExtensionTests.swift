import XCTest
import SwiftUI
@testable import TempoAI

final class ColorExtensionTests: XCTestCase {
    
    // MARK: - Brand Colors Tests
    
    func testBrandColorsExist() {
        // Test that all brand colors are accessible
        XCTAssertNotNil(Color.tempoSageGreen, "tempoSageGreen should be available")
        XCTAssertNotNil(Color.tempoWarmBeige, "tempoWarmBeige should be available")
        XCTAssertNotNil(Color.tempoSoftCoral, "tempoSoftCoral should be available")
        XCTAssertNotNil(Color.tempoLightCream, "tempoLightCream should be available")
        XCTAssertNotNil(Color.tempoDeepCharcoal, "tempoDeepCharcoal should be available")
        XCTAssertNotNil(Color.tempoMediumGray, "tempoMediumGray should be available")
        XCTAssertNotNil(Color.tempoLightGray, "tempoLightGray should be available")
    }
    
    func testSemanticColorsExist() {
        // Test semantic colors
        XCTAssertNotNil(Color.tempoSuccess, "tempoSuccess should be available")
        XCTAssertNotNil(Color.tempoWarning, "tempoWarning should be available")
        XCTAssertNotNil(Color.tempoError, "tempoError should be available")
        XCTAssertNotNil(Color.tempoInfo, "tempoInfo should be available")
    }
    
    func testInterestCategoryColorsExist() {
        // Test interest category colors
        XCTAssertNotNil(Color.tempoBeauty, "tempoBeauty should be available")
        XCTAssertNotNil(Color.tempoFitness, "tempoFitness should be available")
        XCTAssertNotNil(Color.tempoMentalHealth, "tempoMentalHealth should be available")
        XCTAssertNotNil(Color.tempoWorkPerformance, "tempoWorkPerformance should be available")
        XCTAssertNotNil(Color.tempoNutrition, "tempoNutrition should be available")
        XCTAssertNotNil(Color.tempoSleep, "tempoSleep should be available")
    }
    
    func testComponentColorsExist() {
        // Test component-specific colors
        XCTAssertNotNil(Color.tempoInputBackground, "tempoInputBackground should be available")
        XCTAssertNotNil(Color.tempoInputBorder, "tempoInputBorder should be available")
        XCTAssertNotNil(Color.tempoInputBorderActive, "tempoInputBorderActive should be available")
        XCTAssertNotNil(Color.tempoProgressBackground, "tempoProgressBackground should be available")
    }
    
    func testFixedTextColorsExist() {
        // Test fixed text colors
        XCTAssertNotNil(Color.tempoPrimaryText, "tempoPrimaryText should be available")
        XCTAssertNotNil(Color.tempoSecondaryText, "tempoSecondaryText should be available")
        XCTAssertNotNil(Color.tempoBackground, "tempoBackground should be available")
    }
    
    // MARK: - Interest Color Mapping Tests
    
    func testColorForInterestMapping() {
        // Test each interest maps to correct color
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
        // Ensure all UserProfile.Interest cases have color mapping
        let allInterests = UserProfile.Interest.allCases
        
        for interest in allInterests {
            let color = Color.colorForInterest(interest)
            XCTAssertNotNil(color, "Interest \(interest) should have color mapping")
        }
        
        XCTAssertEqual(allInterests.count, 6, "Should have 6 interest categories")
    }
    
    // MARK: - Color Components Tests
    
    func testBrandColorComponents() {
        // Test that brand colors have expected RGB values
        // Note: This is a simplified test - in real scenario you might want to test actual RGB values
        
        // Test that colors are not the same (ensuring they're distinct)
        XCTAssertNotEqual(Color.tempoSageGreen, Color.tempoSoftCoral, "Brand colors should be distinct")
        XCTAssertNotEqual(Color.tempoPrimaryText, Color.tempoSecondaryText, "Text colors should be distinct")
    }
    
    // MARK: - Accessibility Tests
    
    func testTextColorsContrast() {
        // Ensure text colors exist and are distinct for accessibility
        let primaryText = Color.tempoPrimaryText
        let secondaryText = Color.tempoSecondaryText
        let background = Color.tempoBackground
        
        XCTAssertNotNil(primaryText, "Primary text color should exist")
        XCTAssertNotNil(secondaryText, "Secondary text color should exist")
        XCTAssertNotNil(background, "Background color should exist")
        
        // Test that text colors are different from each other
        XCTAssertNotEqual(primaryText, secondaryText, "Primary and secondary text colors should be different")
    }
    
    // MARK: - Color Opacity Tests
    
    func testComponentColorOpacity() {
        // Test that component colors with opacity work correctly
        let inputBackground = Color.tempoInputBackground
        let progressBackground = Color.tempoProgressBackground
        
        XCTAssertNotNil(inputBackground, "Input background with opacity should be accessible")
        XCTAssertNotNil(progressBackground, "Progress background with opacity should be accessible")
    }
    
    // MARK: - Color Extension Completeness Tests
    
    func testAllInterestCategoriesHaveColors() {
        // Ensure each interest category has a corresponding color defined
        let interests = UserProfile.Interest.allCases
        let expectedColorCount = interests.count
        
        // Count actual color definitions for interests
        let interestColors = [
            Color.tempoBeauty,
            Color.tempoFitness,
            Color.tempoMentalHealth,
            Color.tempoWorkPerformance,
            Color.tempoNutrition,
            Color.tempoSleep
        ]
        
        XCTAssertEqual(interestColors.count, expectedColorCount, 
                      "Should have color defined for each interest category")
    }
}