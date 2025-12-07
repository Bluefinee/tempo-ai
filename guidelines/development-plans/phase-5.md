# Phase 5 Technical Specification: Cleanup & Optimization

## Theme: Refactoring, Standardization, and Performance

### 1. Overview

After the iterative feature additions of Phases 3 and 4, Phase 5 is strictly for **removing technical debt**.
No new features are to be added. The goal is to make the codebase clean, readable, and performant.

### 2. Cleanup Targets

#### A. Remove Legacy Logic

- **Score System:** Completely remove any code related to the old "0-100 Health Score" if it contradicts the "Battery" logic.
- **Unused Views:** Delete old Dashboard views, cards, or assets that do not fit the "Digital Cockpit" (Black/Neon) design system.
- **Hardcoded Text:** Move any hardcoded strings to `Localizable.strings` (English/Japanese).

#### B. Architecture Standardization

- **MVVM Strictness:** Ensure no business logic exists inside SwiftUI Views. All logic must be in ViewModels.
- **Service Layer:** Consolidate HealthKit queries and API calls into dedicated Services (`HealthService`, `WeatherService`, `AIService`).
- **Dependency Injection:** Ensure Services are injected into ViewModels for testability.

### 3. Data Model Refactoring

- **UserProfile:** Ensure `focusTags` (Set) and `userMode` (Enum) are the single source of truth. Remove conflicting flags.
- **Type Safety:** Verify that all JSON parsing from the Backend is strictly typed using `Codable` (Swift) and Zod (TypeScript).

### 4. UI Polish & Performance

- **View Hierarchy:** Reduce the depth of `VStack`/`HStack` embedding to improve rendering performance.
- **Animation:** Ensure the Liquid Battery animation does not cause high CPU usage (optimize frames or use efficient libraries).
- **Error States:** Implement user-friendly error views (e.g., "Offline Mode", "Weather Unavailable") instead of generic alerts.

### 5. Backend Optimization

- **Prompt Optimization:** Review the constructed prompts to ensure they are not exceeding token limits efficiently.
- **Dead Code:** Remove unused API routes or helper functions in Cloudflare Workers.

### 6. Deliverables

- A clean project structure with separate `Models`, `Views`, `ViewModels`, `Services`, `Utils`.
- Zero compiler warnings.
- Updated `README.md` and `CLAUDE.md` reflecting the final architecture.
