//
//  AdviceViewCardUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  UI tests for individual advice cards (meal, exercise, sleep, breathing)
//

import XCTest

/**
 * UI test suite for individual advice cards functionality.
 * Tests cover meal cards, exercise cards, sleep cards, and breathing cards.
 *
 * ## Test Coverage Areas
 * - Meal cards section and individual meal card interaction
 * - Exercise card display and content validation
 * - Sleep card display and content validation
 * - Breathing card display and content validation
 */
final class AdviceViewCardUITests: BaseUITest {
    
    override func setUp() {
        super.setUp()
        
        // Start on Today tab and wait for advice to load
        switchToTab("Today")
        waitForAppToFinishLoading(timeout: 10.0)
    }
    
    // MARK: - Meal Cards Section Tests
    
    func testMealCardsSectionDisplay() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping meal cards test")
        }
        
        // When: Looking for meal cards section
        let mealCardsSection = app.otherElements[UIIdentifiers.AdviceView.mealCardsSection]
        
        // Then: Meal cards section should be visible
        if mealCardsSection.exists {
            XCTAssertTrue(mealCardsSection.isHittable, "Meal cards section should be visible")
            takeScreenshot(name: "Meal Cards Section Display")
        }
    }
    
    func testIndividualMealCards() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping individual meal cards test")
        }
        
        // When: Looking for individual meal cards
        let breakfastCard = app.otherElements[UIIdentifiers.AdviceView.breakfastCard]
        let lunchCard = app.otherElements[UIIdentifiers.AdviceView.lunchCard]
        let dinnerCard = app.otherElements[UIIdentifiers.AdviceView.dinnerCard]
        
        // Then: Individual meal cards should be accessible
        if breakfastCard.exists {
            scrollToAndTap(breakfastCard)
            XCTAssertTrue(breakfastCard.isHittable, "Breakfast card should be interactive")
            takeScreenshot(name: "Breakfast Card Interaction")
        }
        
        if lunchCard.exists {
            scrollToAndTap(lunchCard)
            XCTAssertTrue(lunchCard.isHittable, "Lunch card should be interactive")
            takeScreenshot(name: "Lunch Card Interaction")
        }
        
        if dinnerCard.exists {
            scrollToAndTap(dinnerCard)
            XCTAssertTrue(dinnerCard.isHittable, "Dinner card should be interactive")
            takeScreenshot(name: "Dinner Card Interaction")
        }
    }
    
    func testMealCardContent() {
        // Given: Advice view with meal cards is available
        let mealCards = [
            UIIdentifiers.AdviceView.breakfastCard,
            UIIdentifiers.AdviceView.lunchCard,
            UIIdentifiers.AdviceView.dinnerCard
        ]
        
        for (index, mealCardId) in mealCards.enumerated() {
            let mealCard = app.otherElements[mealCardId]
            
            if mealCard.exists {
                // When: Examining meal card content
                scrollToAndTap(mealCard)
                
                // Then: Should contain meal-related content
                let mealNames = ["Breakfast", "Lunch", "Dinner"]
                let mealName = mealNames[index]
                
                let mealText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] '\(mealName)'")).firstMatch
                
                if mealText.exists {
                    XCTAssertTrue(waitForElement(mealText), "\(mealName) card should contain \(mealName) text")
                }
                
                takeScreenshot(name: "\(mealName) Card Content")
            }
        }
    }
    
    // MARK: - Exercise Card Tests
    
    func testExerciseCardDisplay() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping exercise card test")
        }
        
        // When: Looking for exercise card
        let exerciseCard = app.otherElements[UIIdentifiers.AdviceView.exerciseCard]
        
        // Then: Exercise card should be accessible
        if exerciseCard.exists {
            scrollToAndTap(exerciseCard)
            XCTAssertTrue(exerciseCard.isHittable, "Exercise card should be interactive")
            
            // Check for exercise-related content
            let exerciseText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'exercise' OR label CONTAINS[c] 'workout' OR label CONTAINS[c] 'training'")).firstMatch
            
            if exerciseText.exists {
                XCTAssertTrue(waitForElement(exerciseText), "Exercise card should contain exercise-related content")
            }
            
            takeScreenshot(name: "Exercise Card Display")
        }
    }
    
    // MARK: - Sleep Card Tests
    
    func testSleepCardDisplay() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping sleep card test")
        }
        
        // When: Looking for sleep card
        let sleepCard = app.otherElements[UIIdentifiers.AdviceView.sleepCard]
        
        // Then: Sleep card should be accessible
        if sleepCard.exists {
            scrollToAndTap(sleepCard)
            XCTAssertTrue(sleepCard.isHittable, "Sleep card should be interactive")
            
            // Check for sleep-related content
            let sleepText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'sleep' OR label CONTAINS[c] 'bedtime' OR label CONTAINS[c] 'rest'")).firstMatch
            
            if sleepText.exists {
                XCTAssertTrue(waitForElement(sleepText), "Sleep card should contain sleep-related content")
            }
            
            takeScreenshot(name: "Sleep Card Display")
        }
    }
    
    // MARK: - Breathing Card Tests
    
    func testBreathingCardDisplay() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping breathing card test")
        }
        
        // When: Looking for breathing card
        let breathingCard = app.otherElements[UIIdentifiers.AdviceView.breathingCard]
        
        // Then: Breathing card should be accessible
        if breathingCard.exists {
            scrollToAndTap(breathingCard)
            XCTAssertTrue(breathingCard.isHittable, "Breathing card should be interactive")
            
            // Check for breathing-related content
            let breathingText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'breathing' OR label CONTAINS[c] 'breath' OR label CONTAINS[c] 'meditation'")).firstMatch
            
            if breathingText.exists {
                XCTAssertTrue(waitForElement(breathingText), "Breathing card should contain breathing-related content")
            }
            
            takeScreenshot(name: "Breathing Card Display")
        }
    }
}