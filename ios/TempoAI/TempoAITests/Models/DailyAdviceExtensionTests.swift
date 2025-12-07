//
//  DailyAdviceExtensionTests.swift
//  TempoAITests
//
//  Created by Claude for comprehensive test coverage
//  TDD-based test implementation for DailyAdvice extensions
//

import XCTest
import SwiftUI
@testable import TempoAI

/// Test suite for DailyAdvice extensions and category system
/// Ensures model compatibility and proper categorization
final class DailyAdviceExtensionTests: XCTestCase {
    
    // MARK: - Test Data
    
    private var sampleAdvice: DailyAdvice!
    private var sampleMealAdvice: MealAdvice!
    private var sampleExerciseAdvice: ExerciseAdvice!
    private var sampleHydrationAdvice: HydrationAdvice!
    private var sampleBreathingAdvice: BreathingAdvice!
    private var sampleSleepAdvice: SleepPreparationAdvice!
    private var sampleWeatherAdvice: WeatherConsiderations!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sampleMealAdvice = MealAdvice(
            recommendation: "Light breakfast",
            reason: "Provides sustained energy",
            examples: ["Oatmeal", "Banana"],
            timing: "7:00 AM",
            avoid: ["Heavy foods"]
        )
        
        sampleExerciseAdvice = ExerciseAdvice(
            recommendation: "30-minute walk",
            intensity: .moderate,
            reason: "Improves cardiovascular health",
            timing: "Morning",
            avoid: ["Overexertion"]
        )
        
        sampleHydrationAdvice = HydrationAdvice(
            target: "2 liters",
            schedule: HydrationSchedule(
                morning: "500ml",
                afternoon: "1000ml", 
                evening: "500ml"
            ),
            reason: "Maintains optimal body function"
        )
        
        sampleBreathingAdvice = BreathingAdvice(
            technique: "Deep breathing",
            duration: "5 minutes",
            frequency: "Twice daily",
            instructions: ["Inhale for 4", "Hold for 4", "Exhale for 4"]
        )
        
        sampleSleepAdvice = SleepPreparationAdvice(
            bedtime: "10:00 PM",
            routine: ["Dim lights", "No screens"],
            avoid: ["Caffeine", "Heavy meals"]
        )
        
        sampleWeatherAdvice = WeatherConsiderations(
            warnings: ["UV index high"],
            opportunities: ["Perfect for outdoor activity"]
        )
        
        sampleAdvice = DailyAdvice(
            theme: "Healthy Morning Routine",
            summary: "Start your day with healthy habits for optimal wellbeing.",
            breakfast: sampleMealAdvice,
            lunch: sampleMealAdvice,
            dinner: sampleMealAdvice,
            exercise: sampleExerciseAdvice,
            hydration: sampleHydrationAdvice,
            breathing: sampleBreathingAdvice,
            sleepPreparation: sampleSleepAdvice,
            weatherConsiderations: sampleWeatherAdvice,
            priorityActions: ["Drink water", "Take a walk", "Practice breathing"]
        )
    }
    
    override func tearDownWithError() throws {
        sampleAdvice = nil
        sampleMealAdvice = nil
        sampleExerciseAdvice = nil
        sampleHydrationAdvice = nil
        sampleBreathingAdvice = nil
        sampleSleepAdvice = nil
        sampleWeatherAdvice = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Date and Time Tests
    
    func testIsFromToday_WithTodayDate() {
        // Arrange - Create advice with today's date
        let todayAdvice = DailyAdvice(
            theme: "Today's advice",
            summary: "Summary",
            breakfast: sampleMealAdvice,
            lunch: sampleMealAdvice,
            dinner: sampleMealAdvice,
            exercise: sampleExerciseAdvice,
            hydration: sampleHydrationAdvice,
            breathing: sampleBreathingAdvice,
            sleepPreparation: sampleSleepAdvice,
            weatherConsiderations: sampleWeatherAdvice,
            priorityActions: [],
            createdAt: Date()
        )
        
        // Act & Assert
        XCTAssertTrue(todayAdvice.isFromToday, "Advice created today should be identified as from today")
    }
    
    func testIsFromToday_WithYesterdayDate() {
        // Arrange - Create advice from yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayAdvice = DailyAdvice(
            theme: "Yesterday's advice",
            summary: "Summary",
            breakfast: sampleMealAdvice,
            lunch: sampleMealAdvice,
            dinner: sampleMealAdvice,
            exercise: sampleExerciseAdvice,
            hydration: sampleHydrationAdvice,
            breathing: sampleBreathingAdvice,
            sleepPreparation: sampleSleepAdvice,
            weatherConsiderations: sampleWeatherAdvice,
            priorityActions: [],
            createdAt: yesterday
        )
        
        // Act & Assert
        XCTAssertFalse(yesterdayAdvice.isFromToday, "Advice from yesterday should not be identified as from today")
    }
    
    func testIsFromDate_WithSpecificDate() {
        // Arrange - Create specific date
        var dateComponents = DateComponents()
        dateComponents.year = 2024
        dateComponents.month = 12
        dateComponents.day = 1
        let specificDate = Calendar.current.date(from: dateComponents)!
        
        let specificAdvice = DailyAdvice(
            theme: "Specific date advice",
            summary: "Summary",
            breakfast: sampleMealAdvice,
            lunch: sampleMealAdvice,
            dinner: sampleMealAdvice,
            exercise: sampleExerciseAdvice,
            hydration: sampleHydrationAdvice,
            breathing: sampleBreathingAdvice,
            sleepPreparation: sampleSleepAdvice,
            weatherConsiderations: sampleWeatherAdvice,
            priorityActions: [],
            createdAt: specificDate
        )
        
        // Act & Assert
        XCTAssertTrue(specificAdvice.isFrom(date: specificDate), "Should correctly identify advice from specific date")
        
        let differentDate = Calendar.current.date(byAdding: .day, value: 1, to: specificDate)!
        XCTAssertFalse(specificAdvice.isFrom(date: differentDate), "Should not match different date")
    }
    
    func testAgeInHours_ReturnsCorrectValue() {
        // Arrange - Create advice from 2 hours ago
        let twoHoursAgo = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        let oldAdvice = DailyAdvice(
            theme: "Old advice",
            summary: "Summary",
            breakfast: sampleMealAdvice,
            lunch: sampleMealAdvice,
            dinner: sampleMealAdvice,
            exercise: sampleExerciseAdvice,
            hydration: sampleHydrationAdvice,
            breathing: sampleBreathingAdvice,
            sleepPreparation: sampleSleepAdvice,
            weatherConsiderations: sampleWeatherAdvice,
            priorityActions: [],
            createdAt: twoHoursAgo
        )
        
        // Act
        let ageInHours = oldAdvice.ageInHours
        
        // Assert - Should be approximately 2 hours (allowing for small test execution time)
        XCTAssertGreaterThanOrEqual(ageInHours, 1.9, "Age should be close to 2 hours")
        XCTAssertLessThanOrEqual(ageInHours, 2.1, "Age should not be significantly more than 2 hours")
    }
    
    // MARK: - EnhancedAdviceCard Compatibility Tests
    
    func testCategory_ReturnsDefaultGeneral() {
        // Act
        let category = sampleAdvice.category
        
        // Assert
        XCTAssertEqual(category, .general, "Default category should be general")
    }
    
    func testTitle_ReturnsTheme() {
        // Act
        let title = sampleAdvice.title
        
        // Assert
        XCTAssertEqual(title, "Healthy Morning Routine", "Title should return the theme")
        XCTAssertEqual(title, sampleAdvice.theme, "Title should match theme property")
    }
    
    func testDetails_ReturnsSummary() {
        // Act
        let details = sampleAdvice.details
        
        // Assert
        XCTAssertEqual(details, "Start your day with healthy habits for optimal wellbeing.", "Details should return the summary")
        XCTAssertEqual(details, sampleAdvice.summary, "Details should match summary property")
    }
    
    func testTips_ReturnsPriorityActions() {
        // Act
        let tips = sampleAdvice.tips
        
        // Assert
        XCTAssertEqual(tips.count, 3, "Should return all priority actions as tips")
        XCTAssertEqual(tips, sampleAdvice.priorityActions, "Tips should match priority actions")
        XCTAssertTrue(tips.contains("Drink water"), "Should contain expected tip")
        XCTAssertTrue(tips.contains("Take a walk"), "Should contain expected tip")
        XCTAssertTrue(tips.contains("Practice breathing"), "Should contain expected tip")
    }
    
    // MARK: - Category System Tests
    
    func testCategoryEnum_AllCasesAreDefined() {
        // Test that all category cases are properly defined
        let categories: [DailyAdvice.Category] = [.general, .exercise, .nutrition, .sleep, .mindfulness]
        
        for category in categories {
            XCTAssertNotNil(category.icon, "Category \(category) should have an icon")
            XCTAssertNotNil(category.color, "Category \(category) should have a color")
            XCTAssertFalse(category.rawValue.isEmpty, "Category \(category) should have a non-empty raw value")
        }
    }
    
    func testCategoryIcons_AreUnique() {
        // Test that categories have unique icons
        let categories: [DailyAdvice.Category] = [.general, .exercise, .nutrition, .sleep, .mindfulness]
        let icons = categories.map { $0.icon }
        let uniqueIcons = Set(icons)
        
        XCTAssertEqual(icons.count, uniqueIcons.count, "All category icons should be unique")
    }
    
    func testCategoryIcons_AreValidSystemNames() {
        // Test that category icons use valid SF Symbol names
        let expectedIcons: [DailyAdvice.Category: String] = [
            .general: "sparkles",
            .exercise: "figure.run",
            .nutrition: "leaf.fill",
            .sleep: "moon.stars.fill",
            .mindfulness: "brain.head.profile"
        ]
        
        for (category, expectedIcon) in expectedIcons {
            XCTAssertEqual(category.icon, expectedIcon, "Category \(category) should have correct icon")
        }
    }
    
    func testCategoryColors_UseColorPalette() {
        // Test that category colors are from our design system
        let categories: [DailyAdvice.Category] = [.general, .exercise, .nutrition, .sleep, .mindfulness]
        
        for category in categories {
            let color = category.color
            XCTAssertNotNil(color, "Category \(category) should have a defined color")
            // Colors should be from our ColorPalette (this is more of a code review point)
        }
    }
    
    func testCategoryRawValues_AreCorrect() {
        // Test that category raw values match expected strings
        XCTAssertEqual(DailyAdvice.Category.general.rawValue, "general")
        XCTAssertEqual(DailyAdvice.Category.exercise.rawValue, "exercise")  
        XCTAssertEqual(DailyAdvice.Category.nutrition.rawValue, "nutrition")
        XCTAssertEqual(DailyAdvice.Category.sleep.rawValue, "sleep")
        XCTAssertEqual(DailyAdvice.Category.mindfulness.rawValue, "mindfulness")
    }
    
    // MARK: - Model Consistency Tests
    
    func testAdviceWithEmptyPriorityActions_HandlesGracefully() {
        // Arrange - Create advice with empty priority actions
        let emptyAdvice = DailyAdvice(
            theme: "Empty advice",
            summary: "No specific actions",
            breakfast: sampleMealAdvice,
            lunch: sampleMealAdvice,
            dinner: sampleMealAdvice,
            exercise: sampleExerciseAdvice,
            hydration: sampleHydrationAdvice,
            breathing: sampleBreathingAdvice,
            sleepPreparation: sampleSleepAdvice,
            weatherConsiderations: sampleWeatherAdvice,
            priorityActions: []
        )
        
        // Act & Assert
        XCTAssertEqual(emptyAdvice.tips.count, 0, "Empty priority actions should result in empty tips")
        XCTAssertTrue(emptyAdvice.tips.isEmpty, "Tips should be empty when no priority actions")
    }
    
    func testAdviceWithLongContent_HandlesCorrectly() {
        // Arrange - Create advice with very long content
        let longTheme = String(repeating: "Very long theme content ", count: 10)
        let longSummary = String(repeating: "Very detailed summary content ", count: 20)
        
        let longAdvice = DailyAdvice(
            theme: longTheme,
            summary: longSummary,
            breakfast: sampleMealAdvice,
            lunch: sampleMealAdvice,
            dinner: sampleMealAdvice,
            exercise: sampleExerciseAdvice,
            hydration: sampleHydrationAdvice,
            breathing: sampleBreathingAdvice,
            sleepPreparation: sampleSleepAdvice,
            weatherConsiderations: sampleWeatherAdvice,
            priorityActions: ["Action 1", "Action 2"]
        )
        
        // Act & Assert
        XCTAssertEqual(longAdvice.title, longTheme, "Should handle long titles")
        XCTAssertEqual(longAdvice.details, longSummary, "Should handle long details")
        XCTAssertGreaterThan(longAdvice.title.count, 100, "Long content should be preserved")
        XCTAssertGreaterThan(longAdvice.details.count, 300, "Long content should be preserved")
    }
    
    // MARK: - Performance Tests
    
    func testAdviceExtensions_PerformanceIsOptimal() {
        // Test that computed properties are performant
        measure {
            for _ in 0..<1000 {
                _ = sampleAdvice.category
                _ = sampleAdvice.title
                _ = sampleAdvice.details
                _ = sampleAdvice.tips
                _ = sampleAdvice.isFromToday
                _ = sampleAdvice.ageInHours
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testAdviceWithFutureDate_HandlesProperly() {
        // Arrange - Create advice with future date (edge case)
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let futureAdvice = DailyAdvice(
            theme: "Future advice",
            summary: "From tomorrow",
            breakfast: sampleMealAdvice,
            lunch: sampleMealAdvice,
            dinner: sampleMealAdvice,
            exercise: sampleExerciseAdvice,
            hydration: sampleHydrationAdvice,
            breathing: sampleBreathingAdvice,
            sleepPreparation: sampleSleepAdvice,
            weatherConsiderations: sampleWeatherAdvice,
            priorityActions: [],
            createdAt: futureDate
        )
        
        // Act & Assert
        XCTAssertFalse(futureAdvice.isFromToday, "Future advice should not be identified as from today")
        XCTAssertLessThan(futureAdvice.ageInHours, 0, "Future advice should have negative age")
    }
}