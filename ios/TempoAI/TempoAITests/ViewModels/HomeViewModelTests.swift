//
//  HomeViewModelTests.swift
//  TempoAITests
//
//  Created by Claude for comprehensive test coverage
//  TDD-based test implementation for HomeViewModel
//

import XCTest
import Combine
@testable import TempoAI

/// Test suite for HomeViewModel
/// Ensures proper state management, data fetching, and user interactions
@MainActor
final class HomeViewModelTests: XCTestCase {
    
    // MARK: - Test Properties
    
    private var viewModel: HomeViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = HomeViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        cancellables?.removeAll()
        viewModel = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState_IsCorrect() {
        // Assert initial state
        XCTAssertFalse(viewModel.isLoading, "Should not be loading initially")
        XCTAssertNil(viewModel.currentAdvice, "Should have no advice initially")
        XCTAssertNil(viewModel.errorMessage, "Should have no error initially")
        XCTAssertNotNil(viewModel.mockHealthData, "Should have mock health data")
    }
    
    func testMockHealthData_IsValid() {
        // Test that mock data is properly structured
        let mockData = viewModel.mockHealthData
        
        XCTAssertNotNil(mockData.sleep, "Mock data should have sleep data")
        XCTAssertNotNil(mockData.hrv, "Mock data should have HRV data")
        XCTAssertNotNil(mockData.heartRate, "Mock data should have heart rate data")
        XCTAssertNotNil(mockData.activity, "Mock data should have activity data")
        
        // Validate sleep data ranges
        XCTAssertGreaterThan(mockData.sleep.duration, 0, "Sleep duration should be positive")
        XCTAssertLessThanOrEqual(mockData.sleep.duration, 24, "Sleep duration should be reasonable")
        XCTAssertGreaterThanOrEqual(mockData.sleep.efficiency, 0, "Sleep efficiency should be non-negative")
        XCTAssertLessThanOrEqual(mockData.sleep.efficiency, 1, "Sleep efficiency should be at most 1")
        
        // Validate activity data
        XCTAssertGreaterThanOrEqual(mockData.activity.steps, 0, "Steps should be non-negative")
        XCTAssertGreaterThanOrEqual(mockData.activity.calories, 0, "Calories should be non-negative")
    }
    
    // MARK: - Data Loading Tests
    
    func testLoadTodayAdvice_SetsLoadingState() {
        // Act
        viewModel.loadTodayAdvice()
        
        // Assert
        XCTAssertTrue(viewModel.isLoading, "Should be loading when loadTodayAdvice is called")
    }
    
    func testLoadTodayAdvice_ClearsErrorState() {
        // Arrange - Set initial error state
        viewModel.errorMessage = "Previous error"
        
        // Act
        viewModel.loadTodayAdvice()
        
        // Assert
        XCTAssertNil(viewModel.errorMessage, "Should clear error message when loading")
    }
    
    func testLoadTodayAdvice_WithMockData_CompletesSuccessfully() async {
        // Arrange
        let expectation = expectation(description: "Advice loaded")
        
        // Observe isLoading changes
        viewModel.$isLoading
            .dropFirst() // Skip initial value
            .sink { isLoading in
                if !isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.loadTodayAdvice()
        
        // Wait for completion
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertFalse(viewModel.isLoading, "Should not be loading after completion")
        XCTAssertNotNil(viewModel.currentAdvice, "Should have advice after successful load")
        XCTAssertNil(viewModel.errorMessage, "Should have no error after successful load")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling_SetsErrorMessage() {
        // This test would require dependency injection to simulate API failures
        // For now, test error state management
        
        // Arrange - Simulate error condition
        let testError = "Network connection failed"
        
        // Act - Manually set error (in real implementation, this would come from failed API call)
        viewModel.errorMessage = testError
        
        // Assert
        XCTAssertEqual(viewModel.errorMessage, testError, "Should preserve error message")
        XCTAssertFalse(viewModel.isLoading, "Should not be loading when there's an error")
    }
    
    // MARK: - Advice Management Tests
    
    func testCurrentAdvice_InitiallyNil() {
        XCTAssertNil(viewModel.currentAdvice, "Current advice should be nil initially")
    }
    
    func testAdviceUpdate_TriggersPropertyChange() async {
        // Arrange
        let expectation = expectation(description: "Advice updated")
        
        // Observe currentAdvice changes
        viewModel.$currentAdvice
            .dropFirst() // Skip initial nil value
            .sink { advice in
                if advice != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.loadTodayAdvice()
        
        // Wait for update
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertNotNil(viewModel.currentAdvice, "Should have advice after update")
    }
    
    // MARK: - State Consistency Tests
    
    func testStateConsistency_LoadingAndError() {
        // Test that loading and error states are mutually exclusive
        
        // Arrange - Set error state
        viewModel.errorMessage = "Test error"
        
        // Act - Start loading
        viewModel.loadTodayAdvice()
        
        // Assert - Loading should clear error
        XCTAssertTrue(viewModel.isLoading, "Should be loading")
        XCTAssertNil(viewModel.errorMessage, "Error should be cleared when loading starts")
    }
    
    func testStateConsistency_AfterSuccessfulLoad() async {
        // Test state after successful load
        
        // Arrange
        let loadingExpectation = expectation(description: "Loading complete")
        
        viewModel.$isLoading
            .sink { isLoading in
                if !isLoading && self.viewModel.currentAdvice != nil {
                    loadingExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.loadTodayAdvice()
        
        // Wait
        await fulfillment(of: [loadingExpectation], timeout: 5.0)
        
        // Assert consistent state
        XCTAssertFalse(viewModel.isLoading, "Should not be loading")
        XCTAssertNotNil(viewModel.currentAdvice, "Should have advice")
        XCTAssertNil(viewModel.errorMessage, "Should have no error")
    }
    
    // MARK: - Mock Data Validation Tests
    
    func testMockHealthData_HasReasonableValues() {
        let mockData = viewModel.mockHealthData
        
        // Sleep validation
        XCTAssertGreaterThan(mockData.sleep.duration, 4, "Sleep duration should be reasonable (>4h)")
        XCTAssertLessThan(mockData.sleep.duration, 12, "Sleep duration should be reasonable (<12h)")
        
        // HRV validation
        XCTAssertGreaterThan(mockData.hrv.average, 10, "HRV should be reasonable")
        XCTAssertLessThan(mockData.hrv.average, 100, "HRV should be reasonable")
        
        // Heart rate validation
        XCTAssertGreaterThan(mockData.heartRate.resting, 40, "Resting HR should be reasonable")
        XCTAssertLessThan(mockData.heartRate.resting, 100, "Resting HR should be reasonable")
        
        // Activity validation
        XCTAssertLessThan(mockData.activity.steps, 50000, "Steps should be reasonable")
        XCTAssertLessThan(mockData.activity.calories, 5000, "Calories should be reasonable")
    }
    
    // MARK: - Published Property Tests
    
    func testPublishedProperties_AreMarkedCorrectly() {
        // Test that @Published properties trigger updates
        var isLoadingUpdates = 0
        var currentAdviceUpdates = 0
        var errorMessageUpdates = 0
        
        // Subscribe to all published properties
        viewModel.$isLoading
            .sink { _ in isLoadingUpdates += 1 }
            .store(in: &cancellables)
        
        viewModel.$currentAdvice
            .sink { _ in currentAdviceUpdates += 1 }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .sink { _ in errorMessageUpdates += 1 }
            .store(in: &cancellables)
        
        // Act - Trigger changes
        viewModel.loadTodayAdvice()
        
        // Wait a moment for changes to propagate
        let expectation = expectation(description: "Properties updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        // Assert - Should have received updates
        XCTAssertGreaterThan(isLoadingUpdates, 1, "isLoading should have updated")
        // Note: Other properties may not update in mock scenario
    }
    
    // MARK: - Performance Tests
    
    func testHomeViewModel_InitializationPerformance() {
        // Test that ViewModel initialization is performant
        measure {
            for _ in 0..<100 {
                let testViewModel = HomeViewModel()
                XCTAssertNotNil(testViewModel)
            }
        }
    }
    
    func testMockDataAccess_Performance() {
        // Test that mock data access is performant
        measure {
            for _ in 0..<1000 {
                let _ = viewModel.mockHealthData
            }
        }
    }
    
    // MARK: - Memory Management Tests
    
    func testViewModel_DoesNotRetainReferences() {
        weak var weakViewModel: HomeViewModel?
        
        autoreleasepool {
            let testViewModel = HomeViewModel()
            weakViewModel = testViewModel
            XCTAssertNotNil(weakViewModel)
        }
        
        // ViewModel should be deallocated
        XCTAssertNil(weakViewModel, "ViewModel should not retain references")
    }
    
    // MARK: - Edge Cases
    
    func testMultipleLoadCalls_HandledGracefully() {
        // Test calling loadTodayAdvice multiple times
        
        // Act - Call multiple times rapidly
        viewModel.loadTodayAdvice()
        viewModel.loadTodayAdvice()
        viewModel.loadTodayAdvice()
        
        // Assert - Should handle gracefully (not crash)
        XCTAssertTrue(viewModel.isLoading, "Should be in loading state")
    }
    
    func testViewModelAfterErrorState() {
        // Test ViewModel behavior after error state
        
        // Arrange - Set error state
        viewModel.errorMessage = "Test error"
        
        // Act - Try to recover
        viewModel.loadTodayAdvice()
        
        // Assert - Should clear error and start loading
        XCTAssertTrue(viewModel.isLoading, "Should start loading")
        XCTAssertNil(viewModel.errorMessage, "Should clear error")
    }
}