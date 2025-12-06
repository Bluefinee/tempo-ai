# Code Rabbit Review Issues - PR #8

## Critical Issues (Must Fix)

### 1. HealthKitManager.swift - Compilation Errors

**Issue**: Sleep efficiency type mismatch
- **Location**: Line 162
- **Problem**: Returns integer (92) but SleepData.efficiency expects Double
- **Fix Required**: Use `92.0` instead of `92`

**Issue**: Async let parallel execution not working
- **Location**: Lines 81-87  
- **Problem**: Tuple syntax runs sequentially, not in parallel
- **Fix Required**: Use individual `async let` declarations

**Issue**: File length exceeds 400 line limit
- **Location**: Overall file (401 lines)
- **Problem**: Violates swift-coding-standards.md
- **Fix Required**: Extract components (Sleep manager, Background observation)

**Issue**: Integer division precision loss
- **Location**: Lines 219-229
- **Problem**: Integer division before Double conversion loses precision
- **Fix Required**: Convert to Double before division

### 2. APIClient.swift - Missing Timeout & Exponential Backoff

**Issue**: No request timeout
- **Location**: Lines 20-56
- **Problem**: Requests can hang indefinitely
- **Fix Required**: Add `urlRequest.timeoutInterval = 30.0`

**Issue**: Fixed delay instead of exponential backoff  
- **Location**: Lines 100-130
- **Problem**: Uses fixed 2-second delay for retries
- **Fix Required**: Implement exponential backoff with jitter

### 3. Backend prompts.ts - Missing String Validation

**Issue**: No length validation for optional parameters
- **Location**: Lines 26-29
- **Problem**: recentAdviceHistory & weeklyHealthPatterns need constraints
- **Fix Required**: Add validation in buildPrompt function
  - recentAdviceHistory: max 2000 chars
  - weeklyHealthPatterns: max 1000 chars

### 4. Test Files - Inconsistencies

**Issue**: Activity level enum mismatch
- **Location**: HealthStatusAnalyzerTests.swift line 21
- **Problem**: Uses `.moderate` instead of `.moderatelyActive`
- **Fix Required**: Use consistent enum values

**Issue**: Missing test coverage for new prompt parameters
- **Location**: backend/tests/utils/prompts.test.ts
- **Problem**: No tests for recentAdviceHistory and weeklyHealthPatterns
- **Fix Required**: Add comprehensive test cases

## Accessibility & UX Improvements (Should Fix)

### 5. OnboardingFlowView.swift - Accessibility

**Issue**: Missing accessibility improvements
- **Location**: Throughout file
- **Problem**: Could improve screen reader support
- **Fix Suggested**: Add accessibility labels and hints

**Issue**: Component reusability
- **Location**: Throughout file  
- **Problem**: Could extract reusable components
- **Fix Suggested**: Create reusable onboarding page component

## Documentation Issues (Minor)

### 6. Phase 2 Documentation

**Issue**: Scope change not clearly documented
- **Location**: guidelines/development-plans/phase-2-enhanced-user-experience.md line 348
- **Problem**: "Phase 5から前倒し" not in heading
- **Fix Required**: Update heading to clarify scope change

## Implementation Status

- [x] Fix HealthKitManager compilation errors (sleep efficiency Double, async let parallel)
- [x] Implement exponential backoff in APIClient with jitter
- [x] Add timeout settings to APIClient (30s)
- [x] Add string validation to backend prompts (2000/1000 char limits)
- [x] Fix test inconsistencies (enum values .moderatelyActive)
- [x] Add missing test coverage for prompt parameters and validation
- [ ] Improve accessibility in OnboardingFlowView (optional)
- [ ] Update documentation clarity (minor)
- [ ] Run comprehensive CI checks
- [ ] Push all fixes to remote
- [ ] Report completion to Code Rabbit

## Priority Order

1. **Critical compilation fixes** (HealthKitManager sleep efficiency, async let)
2. **Backend validation** (prompts.ts string validation)
3. **Test fixes** (enum consistency, missing coverage)
4. **Performance improvements** (exponential backoff, timeout)
5. **File organization** (HealthKitManager length reduction)
6. **Accessibility enhancements**
7. **Documentation updates**