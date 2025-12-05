# SwiftUI UI Tests Implementation Guide

## Overview

This document describes the UI tests implementation for the TempoAI iOS app, including setup instructions, test structure, and CI integration.

## ✅ Implementation Status

- [x] **UIIdentifiers.swift**: Comprehensive accessibility identifier management
- [x] **UI Files Updated**: All target files updated with accessibility identifiers
- [x] **UI Test Files**: Complete test suite covering all major views
- [x] **CI Integration**: Automated UI tests in GitHub Actions workflow
- [ ] **Xcode Scheme Configuration**: Requires manual setup (see instructions below)

## 🗂️ Project Structure

```
ios/TempoAI/
├── TempoAI/
│   ├── Tests/
│   │   └── Shared/
│   │       └── UIIdentifiers.swift          # Accessibility identifiers
│   ├── ContentView.swift                    # Updated with accessibility IDs
│   ├── HomeView.swift                       # Updated with accessibility IDs
│   ├── HomeViewComponents.swift             # Updated with accessibility IDs
│   ├── AdviceView.swift                     # Updated with accessibility IDs
│   └── PermissionsView.swift                # Updated with accessibility IDs
└── TempoAIUITests/
    ├── BaseUITest.swift                     # Base test class with helpers
    ├── ContentViewUITests.swift             # Tab navigation tests
    ├── HomeViewUITests.swift                # Home screen tests (primary)
    ├── PermissionsViewUITests.swift         # Permission flow tests
    └── AdviceViewUITests.swift              # Advice interaction tests
```

## 🔧 Required Manual Configuration

### 1. Xcode Scheme Configuration

**IMPORTANT**: The following steps must be completed manually in Xcode:

1. **Open the project in Xcode**:
   ```bash
   cd ios/TempoAI
   open TempoAI.xcodeproj
   ```

2. **Create UI Test Target**:
   - Select the project in the navigator
   - Click the "+" button to add a new target
   - Choose "UI Testing Bundle"
   - Name: `TempoAIUITests`
   - Add to: `TempoAI` target

3. **Configure Code Coverage**:
   - Go to Product → Scheme → Edit Scheme...
   - Select "Test" in the left panel
   - Click "Options" tab
   - Check "Gather coverage for: TempoAI"
   - Click "Close"

4. **Add UIIdentifiers.swift to both targets**:
   - Select `UIIdentifiers.swift` in Project Navigator
   - In File Inspector, check both:
     - ☑️ TempoAI (main target)
     - ☑️ TempoAIUITests (test target)

5. **Configure Test Plans** (Optional):
   - Create a new Test Plan for organizing tests
   - Add both unit tests and UI tests
   - Configure different test configurations if needed

### 2. Simulator Configuration

Ensure iPhone 15 simulator is available:
```bash
# List available simulators
xcrun simctl list devices

# Create iPhone 15 if not available
xcrun simctl create "iPhone 15" "iPhone 15" "iOS 17.0"
```

## 🧪 Running Tests

### Local Testing

1. **Run UI Tests in Xcode**:
   - Select `TempoAIUITests` scheme
   - Press `Cmd+U` to run all tests
   - Or use Test Navigator to run specific test classes

2. **Run from Command Line**:
   ```bash
   cd ios/TempoAI
   
   # Run all UI tests
   xcodebuild test \
     -project TempoAI.xcodeproj \
     -scheme TempoAI \
     -destination 'platform=iOS Simulator,name=iPhone 15' \
     -only-testing:TempoAIUITests \
     -enableCodeCoverage YES
   
   # Run specific test class
   xcodebuild test \
     -project TempoAI.xcodeproj \
     -scheme TempoAI \
     -destination 'platform=iOS Simulator,name=iPhone 15' \
     -only-testing:TempoAIUITests/HomeViewUITests
   ```

### CI Testing

UI tests run automatically in GitHub Actions when:
- Code is pushed to `main` or `develop` branches
- Pull requests target `main` or `develop` branches
- Changes are made to files in the `ios/` directory

View results in: **Actions** → **iOS CI** → **Run UI Tests**

## 📋 Test Structure

### BaseUITest.swift

Provides common functionality:
- App launch configuration with test environment
- Helper methods for element waiting and interaction
- Screenshot capture utilities
- Common assertions and navigation helpers

### Test Classes

1. **ContentViewUITests**: Tab navigation and app structure
2. **HomeViewUITests**: Core home screen functionality (most comprehensive)
3. **PermissionsViewUITests**: Permission request flows
4. **AdviceViewUITests**: Health advice display and interactions

### Test Patterns

Each test follows **Given-When-Then** structure:
```swift
func testFeatureFunctionality() {
    // Given: Initial state setup
    let element = app.buttons[UIIdentifiers.SomeView.button]
    
    // When: Perform action
    safeTap(element)
    
    // Then: Verify outcome
    XCTAssertTrue(waitForElement(expectedResult))
}
```

## 🏗️ Accessibility Architecture

### UIIdentifiers Enum

Centralized accessibility identifier management:
```swift
enum UIIdentifiers {
    enum HomeView {
        static let settingsButton = "homeView.settings.button"
        static let greetingText = "homeView.greeting.text"
        // ...
    }
}
```

### Usage in Views

```swift
Button("Settings") { /* action */ }
    .accessibilityIdentifier(UIIdentifiers.HomeView.settingsButton)

Text(greeting)
    .accessibilityIdentifier(UIIdentifiers.HomeView.greetingText)
```

### Test Access

```swift
let settingsButton = app.buttons[UIIdentifiers.HomeView.settingsButton]
let greetingText = app.staticTexts[UIIdentifiers.HomeView.greetingText]
```

## 🔍 Test Coverage Areas

### Navigation
- ✅ Tab switching between all main screens
- ✅ Modal presentation (permissions view)
- ✅ Navigation state preservation

### User Interactions
- ✅ Button taps and accessibility
- ✅ Pull-to-refresh gestures
- ✅ Scrolling and content discovery
- ✅ Form interactions (permission requests)

### State Management
- ✅ Loading states display
- ✅ Error state handling and recovery
- ✅ Empty state presentation
- ✅ Mock data banner display

### Content Validation
- ✅ Dynamic greeting text based on time
- ✅ Advice cards display and interaction
- ✅ Permission status indicators
- ✅ Data quality validation

### Performance
- ✅ Tab switching performance
- ✅ Scrolling responsiveness
- ✅ Refresh operation timing
- ✅ UI rendering performance

## 🛠️ Troubleshooting

### Common Issues

1. **Simulator Not Booting**:
   ```bash
   # Reset simulator
   xcrun simctl shutdown all
   xcrun simctl erase all
   ```

2. **Tests Timing Out**:
   - Increase timeout values in `waitForElement()` calls
   - Check for app crashes in simulator logs
   - Verify accessibility identifiers are correctly set

3. **Element Not Found**:
   - Use Xcode's Accessibility Inspector
   - Verify element exists and is hittable
   - Check spelling of accessibility identifiers

4. **Coverage Not Generated**:
   - Ensure scheme has "Gather coverage" enabled
   - Check that main app target is selected for coverage
   - Verify tests are actually running (not skipping)

### Debug Commands

```bash
# List simulators
xcrun simctl list devices

# Boot specific simulator
xcrun simctl boot "iPhone 15"

# Check app logs
xcrun simctl spawn booted log stream --predicate 'process == "TempoAI"'

# Take simulator screenshot
xcrun simctl io booted screenshot screenshot.png
```

## 📊 Coverage Goals

- **Target Coverage**: 80%+ for UI components
- **Critical Paths**: 100% coverage for core user flows
- **Performance**: All UI interactions complete within 5 seconds

### Coverage Reports

Coverage reports are generated in CI and include:
- Line coverage percentages
- Function coverage details
- Uncovered code regions
- Performance metrics

## 🚀 Future Enhancements

### Planned Improvements

1. **Visual Regression Testing**: Screenshot comparisons
2. **Accessibility Testing**: VoiceOver automation
3. **Performance Monitoring**: Frame rate and memory usage
4. **Cross-Device Testing**: Multiple simulator configurations
5. **Flakiness Reduction**: More robust wait conditions

### Advanced Features

- **Test Recording**: Xcode UI test recording for complex flows
- **Parallel Testing**: Multiple simulator execution
- **Custom Assertions**: Domain-specific test helpers
- **Test Data Management**: Controlled test environments

## 📝 Contributing

### Adding New Tests

1. **Create Test Method**:
   ```swift
   func testNewFeature() {
       // Given-When-Then structure
   }
   ```

2. **Add Accessibility IDs**:
   - Update `UIIdentifiers.swift`
   - Add identifiers to UI elements
   - Update both main and test targets

3. **Follow Patterns**:
   - Use `BaseUITest` helpers
   - Include screenshots for visual verification
   - Add performance tests for interactive features

### Best Practices

- ⭐ **Stable Selectors**: Use accessibility identifiers, not text
- ⭐ **Independent Tests**: Each test should run in isolation
- ⭐ **Clear Intent**: Test names should describe expected behavior
- ⭐ **Error Handling**: Tests should handle app state variations
- ⭐ **Performance Aware**: Minimize test execution time

---

## 📞 Support

For questions about the UI test implementation:

1. Check this documentation first
2. Review existing test patterns in the codebase
3. Use Xcode's built-in UI testing tools
4. Refer to Apple's UI Testing documentation

**Status**: Implementation complete, ready for manual Xcode configuration and testing.