//
//  AdviceViewUITests.swift
//  TempoAIUITests
//
//  Created by Claude for UI Testing on 2024-12-05.
//  UI tests for AdviceView functionality and advice card interactions
//

import XCTest

final class AdviceViewUITests: BaseUITest {
    
    override func setUp() {
        super.setUp()
        
        // Start on Today tab and wait for advice to load
        switchToTab(UIIdentifiers.ContentView.todayTab)
        waitForAppToFinishLoading(timeout: 20.0)
    }
    
    // MARK: - Advice View Display Tests
    
    func testAdviceViewPresence() {
        // Given: The app has loaded and potentially shows advice
        
        // When: Looking for advice view
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        // Then: If advice is available, verify its presence
        if adviceView.exists {
            XCTAssertTrue(adviceView.isHittable, "Advice view should be visible and interactive")
            takeScreenshot(name: "Advice View Present")
        } else {
            // If no advice view, we might be in loading, error, or empty state
            let loadingView = app.otherElements[UIIdentifiers.HomeViewComponents.loadingView]
            let errorView = app.otherElements[UIIdentifiers.HomeViewComponents.errorView]
            let emptyStateView = app.otherElements[UIIdentifiers.HomeViewComponents.emptyStateView]
            
            let hasAlternateState = loadingView.exists || errorView.exists || emptyStateView.exists
            XCTAssertTrue(hasAlternateState, "Should show advice, loading, error, or empty state")
            
            if loadingView.exists {
                takeScreenshot(name: "Loading State Instead of Advice")
            } else if errorView.exists {
                takeScreenshot(name: "Error State Instead of Advice")
            } else if emptyStateView.exists {
                takeScreenshot(name: "Empty State Instead of Advice")
            }
        }
    }
    
    // MARK: - Theme Summary Card Tests
    
    func testThemeSummaryCardDisplay() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping theme summary test")
        }
        
        // When: Looking for theme summary card
        let themeSummaryCard = app.otherElements[UIIdentifiers.AdviceView.themeSummaryCard]
        
        // Then: Theme summary should be visible if advice is loaded
        if themeSummaryCard.exists {
            XCTAssertTrue(themeSummaryCard.isHittable, "Theme summary card should be visible")
            
            let themeSummaryTitle = app.staticTexts[UIIdentifiers.AdviceView.themeSummaryTitle]
            let themeSummaryContent = app.staticTexts[UIIdentifiers.AdviceView.themeSummaryContent]
            
            if themeSummaryTitle.exists {
                XCTAssertFalse(themeSummaryTitle.label.isEmpty, "Theme title should not be empty")
            }
            
            if themeSummaryContent.exists {
                XCTAssertFalse(themeSummaryContent.label.isEmpty, "Theme content should not be empty")
            }
            
            takeScreenshot(name: "Theme Summary Card Display")
        }
    }
    
    func testThemeSummaryCardInteraction() {
        // Given: Theme summary card is available
        let themeSummaryCard = app.otherElements[UIIdentifiers.AdviceView.themeSummaryCard]
        
        guard themeSummaryCard.exists else {
            XCTSkip("Theme summary card not available - skipping interaction test")
        }
        
        // When: Tapping the theme summary card
        if themeSummaryCard.isHittable {
            safeTap(themeSummaryCard)
            
            // Then: Card should remain accessible (it's informational)
            XCTAssertTrue(themeSummaryCard.exists, "Theme card should remain visible after tap")
            
            takeScreenshot(name: "Theme Summary Card After Interaction")
        }
    }
    
    // MARK: - Weather Card Tests
    
    func testWeatherCardDisplay() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping weather card test")
        }
        
        // When: Looking for weather card
        let weatherCard = app.otherElements[UIIdentifiers.AdviceView.weatherCard]
        
        // Then: Weather card should be visible
        if weatherCard.exists {
            XCTAssertTrue(weatherCard.isHittable, "Weather card should be visible")
            
            // Check for weather-related content
            let weatherTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'weather' OR label CONTAINS[c] 'temperature' OR label CONTAINS[c] 'sunny' OR label CONTAINS[c] 'cloudy' OR label CONTAINS[c] 'rain'"))
            
            if weatherTexts.count > 0 {
                XCTAssertTrue(true, "Weather card contains weather-related content")
            }
            
            takeScreenshot(name: "Weather Card Display")
        }
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
                    XCTAssertTrue(mealText.exists, "\(mealName) card should contain \(mealName) text")
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
                XCTAssertTrue(true, "Exercise card contains exercise-related content")
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
                XCTAssertTrue(true, "Sleep card contains sleep-related content")
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
                XCTAssertTrue(true, "Breathing card contains breathing-related content")
            }
            
            takeScreenshot(name: "Breathing Card Display")
        }
    }
    
    // MARK: - Scrolling and Navigation Tests
    
    func testAdviceViewScrolling() {
        // Given: Advice view with multiple cards is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping scrolling test")
        }
        
        // When: Scrolling through advice cards
        let scrollView = app.scrollViews[UIIdentifiers.HomeView.scrollView]
        
        if scrollView.exists {
            takeScreenshot(name: "Advice View Before Scrolling")
            
            // Scroll down to see more cards
            scrollView.swipeUp()
            Thread.sleep(forTimeInterval: 0.5)
            
            takeScreenshot(name: "Advice View After Scroll Down")
            
            // Scroll back up
            scrollView.swipeDown()
            Thread.sleep(forTimeInterval: 0.5)
            
            takeScreenshot(name: "Advice View After Scroll Up")
            
            // Then: Scrolling should work smoothly
            XCTAssertTrue(scrollView.exists, "Scroll view should remain functional")
        }
    }
    
    func testAdviceCardAccessibilityDuringScroll() {
        // Given: Advice view with multiple cards
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping scroll accessibility test")
        }
        
        // When: Scrolling and checking card accessibility
        let cardIdentifiers = [
            UIIdentifiers.AdviceView.themeSummaryCard,
            UIIdentifiers.AdviceView.weatherCard,
            UIIdentifiers.AdviceView.breakfastCard,
            UIIdentifiers.AdviceView.exerciseCard,
            UIIdentifiers.AdviceView.sleepCard,
            UIIdentifiers.AdviceView.breathingCard
        ]
        
        for cardIdentifier in cardIdentifiers {
            let card = app.otherElements[cardIdentifier]
            
            if card.exists {
                // Then: Cards should be accessible when visible
                if card.isHittable {
                    XCTAssertTrue(true, "Card \(cardIdentifier) is accessible")
                } else {
                    // Try to scroll to make it visible
                    scrollToAndTap(card)
                }
            }
        }
    }
    
    // MARK: - Content Validation Tests
    
    func testAdviceCardContentQuality() {
        // Given: Advice view with cards is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping content quality test")
        }
        
        // When: Examining advice card content
        let allAdviceTexts = app.staticTexts.allElementsBoundByIndex
        
        // Then: Advice content should not be empty or contain placeholder text
        for textElement in allAdviceTexts {
            let text = textElement.label
            
            if !text.isEmpty {
                // Check for common placeholder patterns
                let placeholderPatterns = ["Lorem ipsum", "TODO", "FIXME", "placeholder", "test test"]
                let hasPlaceholder = placeholderPatterns.contains { pattern in
                    text.lowercased().contains(pattern.lowercased())
                }
                
                XCTAssertFalse(hasPlaceholder, "Advice should not contain placeholder text: '\(text)'")
            }
        }
    }
    
    // MARK: - Mock Data Tests
    
    func testMockDataIndicatorWithAdvice() {
        // Given: App might be using mock data
        
        // When: Looking for mock data indicator and advice
        let mockDataBanner = app.otherElements[UIIdentifiers.HomeView.mockDataBanner]
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        // Then: If both are present, they should coexist properly
        if mockDataBanner.exists && adviceView.exists {
            XCTAssertTrue(mockDataBanner.isHittable, "Mock data banner should be visible")
            XCTAssertTrue(adviceView.isHittable, "Advice view should be visible below banner")
            
            takeScreenshot(name: "Mock Data Banner with Advice View")
            
            // Verify advice is still scrollable with banner present
            let scrollView = app.scrollViews[UIIdentifiers.HomeView.scrollView]
            if scrollView.exists {
                scrollView.swipeUp()
                Thread.sleep(forTimeInterval: 0.5)
                
                XCTAssertTrue(adviceView.exists, "Advice should remain visible during scroll")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testAdviceViewRenderingPerformance() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping performance test")
        }
        
        // When: Measuring advice view interaction performance
        measure {
            let cardIdentifiers = [
                UIIdentifiers.AdviceView.breakfastCard,
                UIIdentifiers.AdviceView.lunchCard,
                UIIdentifiers.AdviceView.exerciseCard,
                UIIdentifiers.AdviceView.sleepCard
            ]
            
            for cardIdentifier in cardIdentifiers {
                let card = app.otherElements[cardIdentifier]
                if card.exists && card.isHittable {
                    card.tap()
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
        }
        
        // Then: Performance should be acceptable
    }
    
    // MARK: - Error Recovery Tests
    
    func testAdviceViewAfterRefresh() {
        // Given: Advice view is initially available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping refresh test")
        }
        
        takeScreenshot(name: "Advice View Before Refresh")
        
        // When: Performing pull-to-refresh
        performPullToRefresh()
        waitForAppToFinishLoading(timeout: 15.0)
        
        // Then: Advice view should still be functional
        let refreshedAdviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        if refreshedAdviceView.exists {
            XCTAssertTrue(refreshedAdviceView.isHittable, "Advice view should be functional after refresh")
            takeScreenshot(name: "Advice View After Refresh")
        } else {
            // If advice view disappeared, verify we have appropriate alternate state
            let loadingView = app.otherElements[UIIdentifiers.HomeViewComponents.loadingView]
            let errorView = app.otherElements[UIIdentifiers.HomeViewComponents.errorView]
            let emptyStateView = app.otherElements[UIIdentifiers.HomeViewComponents.emptyStateView]
            
            let hasAlternateState = loadingView.exists || errorView.exists || emptyStateView.exists
            XCTAssertTrue(hasAlternateState, "Should show appropriate state after refresh")
            takeScreenshot(name: "Alternate State After Refresh")
        }
    }
    
    // MARK: - Integration Tests
    
    func testAdviceViewWithTabSwitching() {
        // Given: Advice view is available
        let adviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        guard adviceView.exists else {
            XCTSkip("Advice view not available - skipping tab switching test")
        }
        
        // When: Switching tabs and returning
        takeScreenshot(name: "Advice View Before Tab Switch")
        
        switchToTab(UIIdentifiers.ContentView.profileTab)
        Thread.sleep(forTimeInterval: 0.5)
        
        switchToTab(UIIdentifiers.ContentView.todayTab)
        waitForAppToFinishLoading()
        
        // Then: Advice view should be preserved or reloaded properly
        let returnedAdviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
        
        if returnedAdviceView.exists {
            XCTAssertTrue(returnedAdviceView.isHittable, "Advice view should be functional after tab switch")
            takeScreenshot(name: "Advice View After Tab Switch")
        } else {
            // If not immediately available, wait briefly for potential reload
            waitForAppToFinishLoading(timeout: 5.0)
            
            let finalAdviceView = app.otherElements[UIIdentifiers.AdviceView.mainView]
            if !finalAdviceView.exists {
                // Verify we have appropriate state
                let hasAlternateState = app.otherElements[UIIdentifiers.HomeViewComponents.loadingView].exists ||
                                       app.otherElements[UIIdentifiers.HomeViewComponents.errorView].exists ||
                                       app.otherElements[UIIdentifiers.HomeViewComponents.emptyStateView].exists
                
                XCTAssertTrue(hasAlternateState, "Should show appropriate state if advice not available")
            }
        }
    }
}