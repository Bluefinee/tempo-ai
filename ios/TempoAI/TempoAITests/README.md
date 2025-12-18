# TempoAI Tests

## Overview

This test suite uses **Swift Testing** framework (iOS 17+, Xcode 16+) with protocol-based dependency injection for comprehensive test coverage.

## Directory Structure

```
TempoAITests/
├── README.md                           # This file
├── Mocks/                              # Mock implementations
│   ├── MockAPIClient.swift             # APIClientProtocol mock
│   ├── MockCacheManager.swift          # CacheManaging mock
│   ├── MockHealthKitManager.swift      # HealthKitManaging mock
│   └── MockLocationManager.swift       # LocationManaging mock
├── Services/                           # Service layer tests
│   ├── APIClientTests.swift            # API client tests
│   ├── CacheManagerTests.swift         # Cache manager tests
│   ├── DebugResetServiceTests.swift    # Debug reset service tests
│   ├── HealthKitManagerTests.swift     # HealthKit manager tests
│   └── LocationManagerTests.swift      # Location manager tests
├── ColorExtensionTests.swift           # Color extension tests
├── DailyAdviceModelTests.swift         # DailyAdvice model tests
├── HomeComponentsTests.swift           # Home UI component tests
├── MetricDataModelTests.swift          # MetricData model tests
├── TempoAITests.swift                  # Basic app tests
└── UserProfileValidationTests.swift    # UserProfile validation tests
```

## Swift Testing Framework

### Basic Test Structure

```swift
import Testing
@testable import TempoAI

@MainActor
struct MyTests {
    @Test("Description of what is being tested")
    func testSomething() {
        #expect(result == expected)
    }
}
```

### Common Assertions

| Pattern                               | Usage               |
| ------------------------------------- | ------------------- |
| `#expect(a == b)`                     | Equality check      |
| `#expect(x)`                          | Boolean true check  |
| `#expect(!x)`                         | Boolean false check |
| `#expect(x != nil)`                   | Not nil check       |
| `#expect(x == nil)`                   | Nil check           |
| `#expect(a > b)`                      | Greater than        |
| `#expect(throws: ErrorType.self) { }` | Throws check        |
| `Issue.record("message")`             | Record test failure |

### Async Tests

```swift
@Test("Async operation completes successfully")
func asyncTest() async throws {
    let result = try await service.fetchData()
    #expect(result.count > 0)
}
```

## Mock Usage

### MockAPIClient

```swift
// Success scenario
let client = MockAPIClient()
let advice = try await client.generateAdvice(request: request)

// Pre-configured scenarios
let healthy = MockAPIClient.healthy()       // Health check returns true
let unhealthy = MockAPIClient.unhealthy()   // Health check returns false
let networkError = MockAPIClient.networkError()
let serverError = MockAPIClient.serverError()

// Custom stubbed response
client.stubbedAdvice = DailyAdvice.createMock()

// Verification
#expect(client.generateAdviceCalls.count == 1)
#expect(client.healthCheckCallCount == 1)
```

### MockCacheManager

```swift
let cache = MockCacheManager()

// Configure behavior
cache.stubbedUserProfile = UserProfile.sampleData
cache.shouldThrowOnSave = true

// Use in tests
let profile = try cache.loadUserProfile()

// Verification
#expect(cache.saveUserProfileCalls.count == 1)
#expect(cache.loadUserProfileCallCount == 1)
```

### MockHealthKitManager

```swift
let manager = MockHealthKitManager()

// Configure
manager.stubbedHealthData = customHealthData
manager.shouldThrowOnAuthorization = true

// Use
try await manager.requestAuthorization()
let data = try await manager.fetchInitialData()

// Verify
#expect(manager.requestAuthorizationCallCount == 1)
```

### MockLocationManager

```swift
let manager = MockLocationManager()

// Configure
manager.stubbedLocation = LocationData(...)
manager.shouldThrowOnLocation = true

// Use
let location = try await manager.requestCurrentLocation()

// Verify
#expect(manager.requestCurrentLocationCallCount == 1)
```

## Test Patterns

### Testing with Dependency Injection

```swift
@Test("DebugResetService uses injected cache manager")
func testWithInjectedDependency() {
    let mockCache = MockCacheManager()
    let service = DebugResetService(cacheManager: mockCache)

    service.performLightReset()

    #expect(mockCache.deleteUserProfileCallCount == 1)
}
```

### Testing Error Handling

```swift
@Test("Service throws on network error")
func testErrorHandling() async {
    let client = MockAPIClient.networkError()

    do {
        _ = try await client.generateAdvice(request: request)
        Issue.record("Expected error to be thrown")
    } catch let error as APIError {
        if case .networkError = error {
            // Expected
        } else {
            Issue.record("Wrong error type: \(error)")
        }
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
}
```

### Testing State Reset

```swift
@Test("Reset clears all state")
func testReset() async throws {
    let manager = MockHealthKitManager()
    try await manager.requestAuthorization()

    manager.reset()

    #expect(manager.requestAuthorizationCallCount == 0)
    #expect(manager.authorizationStatus == .notDetermined)
}
```

## Running Tests

### Xcode

- `⌘U` - Run all tests
- `⌘⌥U` - Run test at cursor
- Product → Test - Run all tests

### Command Line

```bash
# Run all tests
xcodebuild test \
  -project ios/TempoAI/TempoAI.xcodeproj \
  -scheme TempoAI \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest"

# Run with coverage
xcodebuild test \
  -project ios/TempoAI/TempoAI.xcodeproj \
  -scheme TempoAI \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult

# View coverage report
xcrun xccov view --report TestResults.xcresult
```

## Code Coverage

### CI Threshold

Current threshold: **60%** (to be increased to 80%)

Coverage is enforced in CI via `.github/workflows/ios-ci.yml`.

### Viewing Coverage in Xcode

1. Run tests with `⌘U`
2. Open Report Navigator (`⌘9`)
3. Select test run
4. Click "Coverage" tab

## Adding New Tests

1. Create test file in appropriate directory
2. Import `Testing` and `@testable import TempoAI`
3. Add `@MainActor` if testing MainActor-bound code
4. Use `@Test("description")` attribute
5. Use `#expect()` for assertions

### Example New Test File

```swift
import Foundation
import Testing

@testable import TempoAI

@MainActor
struct NewFeatureTests {

    @Test("Feature does something correctly")
    func featureBasicBehavior() {
        // Arrange
        let sut = NewFeature()

        // Act
        let result = sut.doSomething()

        // Assert
        #expect(result == expected)
    }

    @Test("Feature handles edge case")
    func featureEdgeCase() async throws {
        // ...
    }
}
```

## Protocols for Testing

The app uses protocol-based dependency injection:

| Protocol            | Implementation     | Mock                   |
| ------------------- | ------------------ | ---------------------- |
| `APIClientProtocol` | `APIClient`        | `MockAPIClient`        |
| `CacheManaging`     | `CacheManager`     | `MockCacheManager`     |
| `HealthKitManaging` | `HealthKitManager` | `MockHealthKitManager` |
| `LocationManaging`  | `LocationManager`  | `MockLocationManager`  |

## Best Practices

1. **Use descriptive test names** - `@Test("description")` should explain what's being tested
2. **One assertion focus** - Each test should verify one behavior
3. **Arrange-Act-Assert** - Structure tests clearly
4. **Use mocks for external dependencies** - HealthKit, Location, Network
5. **Reset state between tests** - Use `reset()` methods on mocks
6. **Test both success and failure paths** - Cover error handling
7. **Keep tests fast** - Mock slow operations
