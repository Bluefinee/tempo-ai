# CodeRabbit PR #59 - 未修正コメント一覧

**抽出日**: 2026-01-07
**総未修正件数**: 159件

---

## ✅ 修正済み項目

- ✅ health.ts分割完了 (547行 → 4ファイル)
- ✅ Timeframe型重複削除完了
- ✅ PrimaryButton未使用import削除完了
- ✅ mockData.ts分割完了 (918行 → 6ファイル)
- ✅ healthStore.ts分割完了 (503行 → 3ファイル)

---

## 📊 未修正サマリー

- 🔴 **Critical**: 13件
- 🟠 **Major**: 99件
- 🟡 **Minor**: 0件
- 💡 **Suggestions**: 47件
- **合計**: 159件

---


## 🔴 Critical Issues (13 件)


### 1. app/app/(main)/index.tsx
   **Line**: 613

```
_⚠️ Potential issue_ | _🔴 Critical_

**Critical: File exceeds 400-line limit (617 lines).**

This screen component is 54% over the 400-line maximum specified in the coding guidelines. The file should be decomposed into smaller, focused components.



<details>
<summary>♻️ Suggested refactoring approach</summary>

Extract these inline components to separate files:

1. **MetricGridCard component** (lines 198-248) → `app/src/components/today/MetricGridCard.tsx`
2. **HealthSummaryCard component** (l
```


### 2. app/package.json
   **Line**: 51

```
_⚠️ Potential issue_ | _🔴 Critical_

<details>
<summary>🧩 Analysis chain</summary>

🏁 Script executed:

```shell
#!/bin/bash
cd app

# Check for jest config files
echo "=== Jest Configuration Files ==="
ls -la jest.config.* 2>/dev/null || echo "No jest.config.* files found"

# Check package.json for jest config
echo -e "\n=== Jest config in package.json ==="
cat package.json | jq '.jest' 2>/dev/null || echo "No inline jest config in package.json"

# Check devDependencies for jest-related package
```


### 3. app/src/constants/mockData/screens.ts
   **Line**: 13

```
_⚠️ Potential issue_ | _🔴 Critical_

<details>
<summary>🧩 Analysis chain</summary>

🏁 Script executed:

```shell
#!/bin/bash
# Search for PressureTrend type definitions and usage patterns
echo "=== Frontend PressureTrend type definitions ==="
rg -n "PressureTrend" --type=ts --type=tsx -B2 -A2

echo ""
echo "=== Pressure trend related types and values ==="
rg -n "rising|falling|pressure.*trend" --type=ts --type=tsx | head -50
```

Repository: Bluefinee/tempo-ai

Length of output: 231

---

🏁 Scri
```


### 4. app/src/stores/healthStore/index.ts
   **Line**: 289

```
_⚠️ Potential issue_ | _🔴 Critical_

**Type assertion masks potential null spread issue.**

When `currentSnapshot` is `null`, spreading it produces an empty object, causing `calculatedAt` (required by `DailySnapshot`) to be missing. This will create an invalid object despite the type assertion.


<details>
<summary>🐛 Suggested fix</summary>

```diff
-const currentSnapshot = get().dailySnapshot;
-set({
-  dailySnapshot: {
-    ...currentSnapshot,
-    date: formatDateString(new Date()),
-    scor
```


### 5. app/app/(main)/breathe.tsx
   **Line**: 26

```
_⚠️ Potential issue_ | _🔴 Critical_

**Critical: Move hook call inside component and remove unused variable.**

`useWindowDimensions()` is a React Hook and **cannot be called at module top level**. This violates React's rules-of-hooks and will cause a lint/build failure.

Additionally, `SCREEN_HEIGHT` is declared but never used.



<details>
<summary>🔧 Proposed fix</summary>

Move the hook call inside the component and compute dependent values dynamically:

```diff
-const DEEP_NAVY = '#0F172A';

```


### 6. app/app/(onboarding)/complete.tsx
   **Line**: 19

```
_⚠️ Potential issue_ | _🔴 Critical_

**Critical: `useWindowDimensions` cannot be called at module level.**

This violates React's Rules of Hooks. Move the Hook call inside `CompleteScreen`.


<details>
<summary>🛠️ Proposed fix</summary>

```diff
-const { width, height } = useWindowDimensions();
 const CURRENT_STEP = 9;
 const TOTAL_STEPS = 9;

 export default function CompleteScreen(): JSX.Element {
   const router = useRouter();
+  const { width, height } = useWindowDimensions();
   const compl
```


### 7. app/app/(onboarding)/healthkit.tsx
   **Line**: 17

```
_⚠️ Potential issue_ | _🔴 Critical_

**Critical: `useWindowDimensions` cannot be called at module level.**

This violates React's Rules of Hooks. The Hook must be called inside `HealthKitScreen`.


<details>
<summary>🛠️ Proposed fix</summary>

```diff
-const { width, height } = useWindowDimensions();
 const CURRENT_STEP = 2;
 const TOTAL_STEPS = 9;

 export default function HealthKitScreen(): JSX.Element {
   const router = useRouter();
+  const { width, height } = useWindowDimensions();
```
</d
```


### 8. app/app/(onboarding)/index.tsx
   **Line**: 15

```
_⚠️ Potential issue_ | _🔴 Critical_

**Critical: `useWindowDimensions` cannot be called at module level.**

This violates React's Rules of Hooks. The Hook must be called inside the `WelcomeScreen` component.


<details>
<summary>🛠️ Proposed fix</summary>

```diff
-const { width, height } = useWindowDimensions();

 export default function WelcomeScreen(): JSX.Element {
+  const { width, height } = useWindowDimensions();
   const router = useRouter();
```
</details>

<!-- suggestion_start -->

<de
```


### 9. app/app/(onboarding)/nickname.tsx
   **Line**: 18

```
_⚠️ Potential issue_ | _🔴 Critical_

**Critical: `useWindowDimensions` cannot be called at module level.**

React Hooks must be called inside a React function component or custom Hook. Calling `useWindowDimensions()` at the top level violates the Rules of Hooks and will cause a runtime error.

Move this inside the component and compute blob styles dynamically.


<details>
<summary>🛠️ Proposed fix</summary>

```diff
-const { width, height } = useWindowDimensions();
 const CURRENT_STEP = 3;
 const
```


### 10. app/fix-component-types.sh
   **Line**: 5

```
_⚠️ Potential issue_ | _🔴 Critical_

**Hard-coded absolute path breaks portability.**

The script uses an absolute path specific to one developer's machine. This will fail in CI/CD, for other team members, and when the repository is cloned elsewhere.



<details>
<summary>🔧 Proposed fix</summary>

```diff
-cd /Users/masakazuiwahara/Development/tempo-ai/app/src/components
+cd "$(dirname "$0")/../src/components" || exit 1
```

This makes the path relative to the script location and adds error hand
```


### 11. app/fix-component-types.sh
   **Line**: 22

```
_⚠️ Potential issue_ | _🔴 Critical_

**Props type extracted but never used in replacements.**

The script extracts `PROPS_NAME` from interface/type definitions but never applies it in the sed replacements. The current logic only adds `: React.ReactElement` without actually typing the props parameter.

Expected transformation:
```typescript
// Before
export const Component = ({ prop1, prop2 }) => { ... }

// After (should be)
export const Component = ({ prop1, prop2 }: ComponentProps): React.Reac
```


### 12. app/fix-component-types.sh
   **Line**: 21

```
_⚠️ Potential issue_ | _🔴 Critical_

**Overly broad sed pattern will corrupt code.**

Line 21's pattern `s/) => {/): React.ReactElement => {/g` matches **all** occurrences of `) => {` in the file, not just the component declaration. This will incorrectly modify callbacks, event handlers, map functions, and other arrow functions.

Example of unintended modifications:
```typescript
// Component declaration (intended target)
export const MyComponent = () => { ... }

// Callback (will be incorrectly
```


### 13. General

```
## ❌ Critical Issues: 0/3 解決 (前回と同じ)

```


## 🟠 Major Issues (99 件)


### 1. app/app/(main)/index.tsx

```
_⚠️ Potential issue_ | _🟠 Major_

**Replace default export with named export.**

The coding guidelines require named exports for better refactoring and tree-shaking.



<details>
<summary>🔧 Proposed fix</summary>

```diff
-export default function TodayScreen(): React.ReactElement {
+export const Tod
```


### 2. app/app/(main)/index.tsx

```
_⚠️ Potential issue_ | _🟠 Major_

**Refactor inline styles to use StyleSheet.create().**

Multiple inline style objects violate React Native best practices. Inline styles have performance implications as they create new objects on each render.



<details>
<summary>♻️ Proposed refactoring pattern</s
```


### 3. app/src/components/BarChart.tsx

```
_⚠️ Potential issue_ | _🟠 Major_

**Add explicit return type annotation.**

Per coding guidelines, all functions must declare explicit return types. The component should specify its return type.



<details>
<summary>🔧 Proposed fix</summary>

```diff
-export const BarChart: React.FC<BarChartProps> =
```


### 4. app/src/components/BarChart.tsx

```
_⚠️ Potential issue_ | _🟠 Major_

**Add explicit return types to helper functions.**

Per coding guidelines, all functions must have explicit return type annotations.



<details>
<summary>🔧 Proposed fix</summary>

```diff
-const addHours = (date: Date, hours: number) => {
+const addHours = (date: D
```


### 5. app/src/components/CircularProgress.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Add explicit return type annotation for component.**

The `CircularProgress` component is missing an explicit return type. Per TypeScript coding guidelines, all functions must declare explicit return types.



<details>
<summary>📝 Proposed fix</summary>

```diff
-
```


### 6. app/src/components/DualRingProgress.tsx

```
_⚠️ Potential issue_ | _🟠 Major_

**Add explicit return type for the component.**

According to TypeScript best practices in the coding guidelines, all functions must declare explicit return types. Add `: JSX.Element` to the component function.



<details>
<summary>🔧 Proposed fix</summary>

```diff
```


### 7. app/src/components/DualRingProgress.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Remove shared values from useEffect dependency array.**

`innerProgressValue` and `outerProgressValue` are refs created by `useSharedValue` and never change identity, so they shouldn't be in the dependency array. This may trigger ESLint warnings and is unnecessary
```


### 8. app/src/components/MetricGridCard.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Inconsistent use of design tokens.**

The `colors` theme is imported (line 11) and used once for the chevron color (line 47), but the StyleSheet contains several hardcoded color values:
- `#FFFFFF` (line 79)
- `#000` (line 86)
- `#A8A29E` (line 105)

For consisten
```


### 9. app/src/components/MiniBarChart.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Remove unused import `TextStyle`.**

The `TextStyle` type is imported but never used in this file.



<details>
<summary>🧹 Proposed fix</summary>

```diff
-import { View, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native';
+import { View, Text, StyleShee
```


### 10. app/src/components/MiniBarChart.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Add explicit return type for the component.**

Per coding guidelines, all functions must declare explicit return types.



<details>
<summary>📝 Proposed fix</summary>

```diff
-export const MiniBarChart: React.FC<MiniBarChartProps> = ({
+export const MiniBarChart 
```


### 11. app/src/components/MiniBarChart.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Add explicit return type for `renderBar` function.**

The `renderBar` function should declare its return type explicitly.



<details>
<summary>📝 Proposed fix</summary>

```diff
-  const renderBar = (item: MiniBarChartData, index: number) => {
+  const renderBar =
```


### 12. app/src/components/SleepStagesBar.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Add explicit return type annotation for component.**

The `SleepStagesBar` component is missing an explicit return type. Per TypeScript coding guidelines, all functions (including React components) must declare explicit return types.



<details>
<summary>📝 Propos
```


### 13. app/src/components/SunInfoCard.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Add explicit return type for `getTypeConfig`.**

The helper function lacks an explicit return type annotation. Per coding guidelines, all functions should declare explicit return types.



<details>
<summary>📝 Proposed fix</summary>

```diff
+type TypeConfig = {
+
```


### 14. app/src/components/SunInfoCard.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Add explicit return type for the component.**

While `React.FC` provides an implicit return type, coding guidelines require explicit return type declarations for all functions.



<details>
<summary>📝 Proposed fix</summary>

```diff
-export const SunInfoCard: Reac
```


### 15. app/src/config/dataSource.ts

```
_⚠️ Potential issue_ | _🟡 Minor_

**Add explicit return type to getDataSourceConfig.**

The function is missing an explicit return type annotation, which is required per coding guidelines.



<details>
<summary>🔧 Add explicit return type</summary>

```diff
 /**
  * 設定の取得(将来的に環境変数から読み込む可能性も考慮)
  */
-
```


### 16. app/src/domain/models/index.ts

```
_⚠️ Potential issue_ | _🟡 Minor_

<details>
<summary>🧩 Analysis chain</summary>

🏁 Script executed:

```shell
# List files in domain/models to confirm they exist
ls -la app/src/domain/models/
```

Repository: Bluefinee/tempo-ai

Length of output: 786

---

🏁 Script executed:

```shell
# Check the ex
```


### 17. app/src/hooks/useFadeIn.ts

```
_⚠️ Potential issue_ | _🟡 Minor_

**Add explicit return type annotation.**

The function `useFadeIn` is missing an explicit return type. Per TypeScript coding guidelines, all functions must declare explicit return types.



<details>
<summary>📝 Proposed fix</summary>

```diff
-export const useFadeIn
```


### 18. app/src/hooks/useFadeIn.ts

```
_⚠️ Potential issue_ | _🟡 Minor_

**Add explicit return type annotation.**

The function `createFadeInStyle` is missing an explicit return type.



<details>
<summary>📝 Proposed fix</summary>

```diff
-export const createFadeInStyle = (opacity: Animated.Value, translateY: Animated.Value) => ({
+expo
```


### 19. app/src/i18n/index.ts

```
_⚠️ Potential issue_ | _🟡 Minor_

**Remove trailing empty lines.**

Per cleanup guidelines, unnecessary empty lines at the end of files should be removed.



<details>
<summary>🧹 Proposed cleanup</summary>

```diff
 export default i18n;
-
-
-
-
```
</details>

<!-- suggestion_start -->

<details>
<s
```


### 20. app/src/stores/insightStore.ts

```
_⚠️ Potential issue_ | _🟠 Major_

**Avoid type assertions - fix the underlying type definitions instead.**

Multiple `as` casts suggest the `UserProfile` type in `userStore` doesn't match the expected shape. This bypasses TypeScript's safety guarantees.



<details>
<summary>🔧 Recommended fix</summa
```


### 21. app/app/(main)/action-detail.tsx

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**Duplicate `useFadeIn` hook - consider reusing or consolidating.**

A `useFadeIn` hook already exists at `app/src/hooks/useFadeIn.ts` (see relevant code snippets). This local definition creates code duplication. Note that the implementations differ (this uses r
```


### 22. app/app/(main)/action-detail.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Hardcoded Japanese text should use i18n.**

The button text `{todayOneThing.time}にリマインド` mixes data interpolation with hardcoded Japanese. Use the `t()` function with interpolation for consistency.


<details>
<summary>🌐 Proposed fix</summary>

```diff
-          
```


### 23. app/app/(main)/breathe.tsx

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**File exceeds 400-line limit (431 lines).**

Per coding guidelines, files should be under 400 lines. Consider extracting the breathing animation logic or the visual components into separate files.



Potential extractions:
- `BreathingCircle` component (lines 2
```


### 24. app/app/(main)/insight-detail.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

<details>
<summary>🧩 Analysis chain</summary>

🏁 Script executed:

```shell
# Check if the shared useFadeIn hook exists and find all useFadeIn usages
rg -n "useFadeIn" --type=ts --type=tsx -g '!node_modules' | head -50
```

Repository: Bluefinee/tempo-ai

Length of 
```


### 25. app/app/(main)/rhythm-detail.tsx

```
_⚠️ Potential issue_ | _🟠 Major_

**Inconsistent data sources: `rhythmScore` vs `data.score`.**

The component fetches `rhythmScore` from `healthStore.dailySnapshot` (Line 90) but also uses `data` from `MOCK_DETAIL.rhythm` (Line 92). At Line 239, `getRhythmStatus(data.score)` uses mock data while Li
```


### 26. app/app/(main)/rhythm-detail.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Hardcoded Japanese text should use i18n.**

Lines 184-185 contain hardcoded Japanese strings ("目標からのズレ", "上: 早い / 下: 遅い") while the rest of the file uses `t()` for localization. This inconsistency will cause issues if the app needs to support multiple languages.


```


### 27. app/app/(main)/settings.tsx

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**Duplicate `useFadeIn` hook - third instance in codebase.**

This is the same `useFadeIn` hook duplicated in `action-detail.tsx` and defined in `app/src/hooks/useFadeIn.ts`. This violates DRY principles. Consider consolidating to a single reanimated-based imple
```


### 28. app/app/(main)/settings.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Profile card Pressable has no onPress handler.**

The `Pressable` wrapping the chevron icon (Line 253-255) has no `onPress` handler, making it a non-interactive element styled as a button. Either add navigation to a profile edit screen or replace with a `View`.



```


### 29. app/app/(main)/settings.tsx

```
_⚠️ Potential issue_ | _🟠 Major_

**Sign Out button has no onPress handler.**

The Sign Out `Pressable` (Lines 342-351) has no `onPress` handler. This is a critical user action that should either be implemented or the button should be disabled/hidden until ready.


<details>
<summary>🐛 Proposed fix<
```


### 30. app/src/api/client.ts

```
_⚠️ Potential issue_ | _🟠 Major_

<details>
<summary>🧩 Analysis chain</summary>

🏁 Script executed:

```shell
find . -maxdepth 3 -name "app.config.*" -type f
```

Repository: Bluefinee/tempo-ai

Length of output: 44

---

🏁 Script executed:

```shell
ls -la | grep -E "app\.|\.config" | head -20
```

```


### 31. app/src/components/HealthMetricCard.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

<details>
<summary>🧩 Analysis chain</summary>

🏁 Script executed:

```shell
#!/bin/bash
# Check for IconType definition and usage
echo "=== Searching for IconType definition and usage ==="
rg -n "IconType" --type=ts --type=tsx

echo -e "\n=== Searching for HealthMet
```


### 32. app/src/components/RhythmInteractiveChart.tsx

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**Add explicit return types to tooltip handlers.**


<details>
<summary>Suggested fix</summary>

```diff
   const showTooltip = useCallback(
-    (index: number) => {
+    (index: number): void => {
       // ...
     },
     [tooltipOpacity, tooltipScale, curso
```


### 33. app/src/components/WindowCard.tsx

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**Add explicit return type for `getThemeConfig`.**

The helper function lacks an explicit return type annotation.


<details>
<summary>Suggested fix</summary>

```diff
+interface ThemeConfig {
+  iconBgColor: string;
+  iconColor: string;
+  timeColor: string;
+
```


### 34. app/src/domain/services/energyCurveGenerator.ts

```
_⚠️ Potential issue_ | _🟠 Major_

**Non-deterministic output will cause UI inconsistency.**

Using `Math.random()` in the energy calculation means the curve will be different on every call, potentially causing chart flickering on re-renders.



<details>
<summary>🐛 Suggested fix</summary>

```diff
 
```


### 35. app/src/domain/services/energyCurveGenerator.ts

```
_⚠️ Potential issue_ | _🟡 Minor_

**Unused variable: `hoursToBedtime` is calculated but never used.**

The variable is computed but the energy calculation on line 51 doesn't reference it.



<details>
<summary>🐛 Fix: Remove or use the variable</summary>

```diff
     } else {
       // Wind Down: 就寝
```


### 36. app/src/i18n/index.ts

```
_⚠️ Potential issue_ | _🟡 Minor_

**Replace default export with named export.**

Per coding guidelines, named exports should be used instead of default exports for better refactoring and tree-shaking. Based on learnings, this applies to all TypeScript/JavaScript files.



<details>
<summary>📝 Propos
```


### 37. app/src/stores/breatheStore.ts

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**Duplicate action methods detected.**

The interface declares both short-form (`start`, `pause`, `resume`, `stop`) and long-form (`startSession`, `pauseSession`, `resumeSession`, `stopSession`) actions that perform identical operations. This creates unnecessary
```


### 38. app/app/(main)/breathe.tsx

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**Remove unused SVG imports `Defs`, `RadialGradient`, and `Stop`.**


<details>
<summary>♻️ Proposed fix</summary>

```diff
-import Svg, { Circle, Defs, RadialGradient, Stop } from 'react-native-svg';
+import Svg, { Circle } from 'react-native-svg';
```
</detail
```


### 39. app/app/(main)/breathe.tsx

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**Remove unused animation imports `withRepeat` and `withSequence`.**


<details>
<summary>♻️ Proposed fix</summary>

```diff
 import Animated, {
   useSharedValue,
   useAnimatedStyle,
   withTiming,
-  withRepeat,
-  withSequence,
   Easing,
 } from 'react-nati
```


### 40. app/app/(main)/energy-detail.tsx

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**Remove unused imports `Circle` and `Line`.**

Static analysis indicates these SVG components are imported but never used.


<details>
<summary>♻️ Proposed fix</summary>

```diff
-import Svg, { Path, Line, Circle, Defs, LinearGradient, Stop } from 'react-native
```


### 41. app/app/(main)/energy-detail.tsx

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**Remove unused variable `markerX`.**

This variable is calculated but never used in the component.


<details>
<summary>♻️ Proposed fix</summary>

```diff
     const currentPosition = Math.max(0, Math.min(100, ((currentHour - 6) / 16) * 100));
-    const marker
```


### 42. app/app/(main)/energy-detail.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Inconsistent score source: uses `data.score` instead of `energyScore`.**

The circular display at line 263 correctly uses `energyScore` from the store, but the status badge here uses `data.score` from mock data. This inconsistency could display mismatched values.

```


### 43. app/app/(main)/insights.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Discovery card missing `onPress` handler.**

`AnimatedPressable` is used but no `onPress` is provided. Either add navigation/action or use a regular `Animated.View` if no interaction is intended.


<details>
<summary>🐛 Add onPress or change to View</summary>

```d
```


### 44. app/app/(main)/rhythm.tsx

```
_⚠️ Potential issue_ | _🟠 Major_

**File exceeds 400-line limit - component splitting required.**

This file contains 442 lines, exceeding the 400-line limit specified in the coding guidelines. Please split this component into smaller, focused components.

Suggested splits:
1. Extract `UpcomingWindo
```


### 45. app/app/(main)/rhythm.tsx

```
_⚠️ Potential issue_ | _🟠 Major_

**Use arrow function instead of function declaration.**

Convert to const arrow function per coding guidelines.



<details>
<summary>♻️ Proposed fix</summary>

```diff
-export default function RhythmScreen(): React.ReactElement {
+const RhythmScreen = (): React.Rea
```


### 46. app/app/(main)/rhythm.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Add explicit return type to handleSeeDetails.**



<details>
<summary>♻️ Proposed fix</summary>

```diff
-  const handleSeeDetails = () => {
+  const handleSeeDetails = (): void => {
     router.push('/rhythm-detail');
   };
```
</details>

<details>
<summary>🤖 Pr
```


### 47. app/app/(main)/rhythm.tsx

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**Extract inline styles to StyleSheet.create().**

This file extensively uses inline styles, violating the coding guidelines. Extract all inline styles to a `styles` object using `StyleSheet.create()`.



Based on coding guidelines: "**StyleSheet.create()** でスタイ
```


### 48. app/app/(main)/sleep-detail.tsx

```
_⚠️ Potential issue_ | _🟠 Major_

**Use arrow function instead of function declaration.**

The coding guidelines require arrow functions consistently instead of function declarations. Convert this to a const arrow function.



<details>
<summary>♻️ Proposed fix</summary>

```diff
-export default fun
```


### 49. app/app/(main)/sleep-detail.tsx

```
_⚠️ Potential issue_ | _🟡 Minor_

**Add explicit return type to handleBack.**

All functions should declare explicit return types per coding guidelines.



<details>
<summary>♻️ Proposed fix</summary>

```diff
-  const handleBack = () => {
+  const handleBack = (): void => {
     router.back();
   }
```


### 50. app/app/(main)/sleep-detail.tsx

```
_🛠️ Refactor suggestion_ | _🟠 Major_

**Extract inline styles to StyleSheet.create().**

The coding guidelines require using `StyleSheet.create()` for style definitions and prohibit inline styles. This file has extensive inline style usage throughout the component.

Consider extracting all inline st
```


## 💡 Suggestions (47 件)

- .claude/settings.local.json: 1件
- app/app/(main)/action-detail.tsx: 1件
- app/app/(main)/breathe.tsx: 2件
- app/app/(main)/health-detail.tsx: 4件
- app/app/(main)/insights.tsx: 2件
- app/app/(main)/rhythm-detail.tsx: 1件
- app/app/(onboarding)/basic-info.tsx: 2件
- app/app/(onboarding)/complete.tsx: 1件
- app/app/(onboarding)/healthkit.tsx: 1件
- app/app/(onboarding)/index.tsx: 2件
- app/app/(onboarding)/lifestyle.tsx: 1件
- app/app/(onboarding)/location.tsx: 1件
- app/src/api/helpers/adviceRequestBuilder.ts: 2件
- app/src/components/BarChart.tsx: 2件
- app/src/components/DualRingProgress.tsx: 2件
- app/src/components/HealthAreaChart.tsx: 2件
- app/src/components/HealthMetricCard.tsx: 1件
- app/src/components/HealthMetricDetail.tsx: 1件
- app/src/components/MetricGridCard.tsx: 1件
- app/src/constants/mockDataFactory.test.ts: 1件
- app/src/domain/models/insight.ts: 1件
- app/src/domain/models/rhythm.ts: 1件
- app/src/domain/services/alertGenerator.ts: 1件
- app/src/domain/services/rhythmCalculator.ts: 1件
- app/src/domain/services/tempoScoreCalculator.ts: 2件
- app/src/hooks/useAdvice.ts: 3件
- app/src/hooks/useWeather.ts: 1件
- app/src/i18n/index.ts: 1件
- app/src/services/dataSourceAdapter.ts: 1件
- app/src/stores/breatheStore.ts: 1件
- app/src/stores/healthStore/selectors.ts: 2件
- app/src/stores/insightStore.ts: 1件