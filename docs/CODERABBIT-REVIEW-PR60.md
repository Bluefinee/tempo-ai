# CodeRabbit Review Comments for PR #60

**Total Comments:** 30
**Extracted Date:** 2026-01-07T10:48:14.821Z

---

## [1] app/app/(main)/breathe.tsx
**Line:** 43
**Date:** 2026-01-07T09:52:39Z

_⚠️ Potential issue_ | _🟡 Minor_

**Remove unused variable `SCREEN_HEIGHT`.**

The `SCREEN_HEIGHT` variable is destructured but never used in the component. Remove it to keep the code clean.



<details>
<summary>🧹 Proposed fix</summary>

```diff
-  const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = useWindowDimensions();
+  const { width: SCREEN_WIDTH } = useWindowDimensions();
```
</details>

As per coding guidelines, unused variables should be removed.

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
  const { width: SCREEN_WIDTH } = useWindowDimensions();
```

</details>

<!-- suggestion_end -->

<details>
<summary>🧰 Tools</summary>

<details>
<summary>🪛 GitHub Actions: App CI</summary>

[warning] 43-43: ESLint: 'SCREEN_HEIGHT' is assigned a value but never used. (@typescript-eslint/no-unused-vars)

</details>
<details>
<summary>🪛 GitHub Check: 🧹 Lint</summary>

[warning] 43-43: 
'SCREEN_HEIGHT' is assigned a value but never used     

</details>

</details>

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/breathe.tsx at line 43, The destructured SCREEN_HEIGHT from
useWindowDimensions is unused; remove SCREEN_HEIGHT and only destructure width
as SCREEN_WIDTH (e.g., change "const { width: SCREEN_WIDTH, height:
SCREEN_HEIGHT } = useWindowDimensions();" to only extract width) so the
component no longer has an unused variable; ensure all references still use
SCREEN_WIDTH and that useWindowDimensions is imported/used correctly.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

✅ Addressed in commits 064b587 to 7551c0a

---

## [2] app/app/(onboarding)/complete.tsx
**Line:** 22
**Date:** 2026-01-07T09:52:40Z

_⚠️ Potential issue_ | _🟡 Minor_

**Remove unused window dimension variables.**

Both `width` and `height` from `useWindowDimensions()` are unused after converting blob positioning to fixed pixel values (lines 114-115, 124-125). The entire hook call and import can be removed.



<details>
<summary>🧹 Proposed cleanup</summary>

```diff
 const CompleteScreen = (): JSX.Element => {
   const router = useRouter();
-  const { width, height } = useWindowDimensions();
   const completeOnboarding = useUserStore((state) => state.completeOnboarding);
```

Also remove from imports:
```diff
-import { View, Text, StyleSheet, useWindowDimensions } from 'react-native';
+import { View, Text, StyleSheet } from 'react-native';
```
</details>

As per coding guidelines, unused imports and variables must be removed.

<details>
<summary>🧰 Tools</summary>

<details>
<summary>🪛 GitHub Actions: App CI</summary>

[warning] 22-22: ESLint: 'width' is assigned a value but never used. (@typescript-eslint/no-unused-vars)

---

[warning] 22-22: ESLint: 'height' is assigned a value but never used. (@typescript-eslint/no-unused-vars)

</details>

</details>

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(onboarding)/complete.tsx at line 22, The useWindowDimensions hook
call and its returned variables are unused; remove the call "const { width,
height } = useWindowDimensions()" and delete the corresponding import of
useWindowDimensions (and any related unused identifiers) from the top of the
file so the component no longer references width/height; ensure no other code
relies on those variables (the blob positioning now uses fixed pixel values at
lines where width/height were previously used).
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

✅ Addressed in commits 064b587 to 7551c0a

---

## [3] app/app/(onboarding)/healthkit.tsx
**Line:** 20
**Date:** 2026-01-07T09:52:40Z

_⚠️ Potential issue_ | _🟡 Minor_

**Remove unused `width` and `height` from `useWindowDimensions`.**

Both variables are destructured but never used. The decorative blob positioning now uses fixed pixel values (lines 107-108, 117-118) instead of dynamic dimensions.



<details>
<summary>🔧 Proposed fix</summary>

```diff
-  const { width, height } = useWindowDimensions();
+  // Dimensions not needed - blobs use fixed positioning
```
</details>


> Committable suggestion skipped: line range outside the PR's diff.

<details>
<summary>🧰 Tools</summary>

<details>
<summary>🪛 GitHub Actions: App CI</summary>

[warning] 20-20: ESLint: 'width' is assigned a value but never used. (@typescript-eslint/no-unused-vars)

---

[warning] 20-20: ESLint: 'height' is assigned a value but never used. (@typescript-eslint/no-unused-vars)

</details>

</details>

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(onboarding)/healthkit.tsx at line 20, Remove the unused width and
height variables from the useWindowDimensions destructuring in the HealthKit
component: stop doing "const { width, height } = useWindowDimensions()" and
either call useWindowDimensions without destructuring (if other values are used)
or remove the hook call and its import entirely since decorative blob
positioning uses fixed pixel values; ensure no unused variables or imports
remain and run the linter to confirm.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

✅ Addressed in commits 064b587 to 7551c0a

---

## [4] app/app/(onboarding)/index.tsx
**Line:** 17
**Date:** 2026-01-07T09:52:40Z

_⚠️ Potential issue_ | _🟡 Minor_

**Remove unused window dimension variables.**

Both `width` and `height` from `useWindowDimensions()` are no longer used after changing the blob positioning to fixed pixel values (lines 74-75, 85-86). The entire hook call can be removed.



<details>
<summary>🧹 Proposed cleanup</summary>

```diff
 const WelcomeScreen = (): JSX.Element => {
   const router = useRouter();
-  const { width, height } = useWindowDimensions();

   const handleStart = () => {
```

Also remove the unused import:
```diff
-import { View, Text, StyleSheet, useWindowDimensions } from "react-native";
+import { View, Text, StyleSheet } from "react-native";
```
</details>

As per coding guidelines, unused imports and variables must be removed.

<details>
<summary>🧰 Tools</summary>

<details>
<summary>🪛 GitHub Actions: App CI</summary>

[warning] 17-17: ESLint: 'width' is assigned a value but never used. (@typescript-eslint/no-unused-vars)

</details>

</details>

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(onboarding)/index.tsx at line 17, Remove the unused
useWindowDimensions hook and its returned variables: delete the import/use of
useWindowDimensions and remove "const { width, height } =
useWindowDimensions();" as width and height are not used; ensure any import
statement that brought in useWindowDimensions is also removed from the top of
the file so there are no unused imports remaining.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

✅ Addressed in commits 064b587 to 7551c0a

---

## [5] app/app/(onboarding)/location.tsx
**Line:** 20
**Date:** 2026-01-07T09:52:40Z

_⚠️ Potential issue_ | _🟡 Minor_

**Remove unused `width` from `useWindowDimensions` destructuring.**

The decorative blob positioning now uses fixed pixel values (lines 107-108, 117-118) instead of dynamic dimensions, making `width` unnecessary. The `height` variable is also unused.



<details>
<summary>🔧 Proposed fix</summary>

```diff
-  const { width, height } = useWindowDimensions();
+  // Dimensions not needed - blobs use fixed positioning
```

Or if you plan to use dimensions for responsive design later, remove the destructuring until then.
</details>

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion

```

</details>

<!-- suggestion_end -->

<details>
<summary>🧰 Tools</summary>

<details>
<summary>🪛 GitHub Actions: App CI</summary>

[warning] 20-20: ESLint: 'width' is assigned a value but never used. (@typescript-eslint/no-unused-vars)

</details>

</details>

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(onboarding)/location.tsx at line 20, Remove the unused
destructuring from the useWindowDimensions call: delete the line "const { width,
height } = useWindowDimensions();" (or if the hook must be invoked for side
effects, replace it with a bare "useWindowDimensions();" call). This removes the
unused symbols width and height referenced in the component (no other changes to
the decorative blob pixel positions).
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

✅ Addressed in commits 064b587 to 7551c0a

---

## [6] app/app/(onboarding)/nickname.tsx
**Line:** 21
**Date:** 2026-01-07T09:52:40Z

_⚠️ Potential issue_ | _🟡 Minor_

**Remove unused window dimension variables.**

Both `width` and `height` from `useWindowDimensions()` are unused after converting blob positioning to fixed pixel values (lines 118-119, 128-129). The entire hook call and import can be removed.



<details>
<summary>🧹 Proposed cleanup</summary>

```diff
 const NicknameScreen = (): JSX.Element => {
   const router = useRouter();
-  const { width, height } = useWindowDimensions();
   const setDraftNickname = useUserStore((state) => state.setDraftNickname);
```

Also remove from imports:
```diff
-import { View, Text, StyleSheet, useWindowDimensions, KeyboardAvoidingView, Platform } from 'react-native';
+import { View, Text, StyleSheet, KeyboardAvoidingView, Platform } from 'react-native';
```
</details>

As per coding guidelines, unused imports and variables must be removed.

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
const NicknameScreen = (): JSX.Element => {
  const router = useRouter();
  const setDraftNickname = useUserStore((state) => state.setDraftNickname);
```

</details>

<!-- suggestion_end -->

<details>
<summary>🧰 Tools</summary>

<details>
<summary>🪛 GitHub Actions: App CI</summary>

[warning] 21-21: ESLint: 'width' is assigned a value but never used. (@typescript-eslint/no-unused-vars)

</details>

</details>

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(onboarding)/nickname.tsx at line 21, Remove the unused window
dimension hook and its variables: delete the import of useWindowDimensions and
remove the line "const { width, height } = useWindowDimensions();" from the top
of nickname.tsx; ensure no remaining references to width or height remain (they
were replaced by fixed pixel values) so the file has no unused imports or
variables.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

✅ Addressed in commits 064b587 to 7551c0a

---

## [7] app/jest.setup.js
**Line:** 76
**Date:** 2026-01-07T09:52:40Z

_⚠️ Potential issue_ | _🔴 Critical_

**Fix ESLint configuration to recognize Jest globals.**

ESLint is reporting `'jest' is not defined` errors throughout this file, causing the pipeline to fail. This is a configuration issue—the `jest` global is available in Jest's test environment but ESLint doesn't recognize it without proper configuration.



<details>
<summary>🔧 Proposed fix</summary>

Add an ESLint environment directive at the top of the file:

```diff
+/* eslint-env jest */
+
 // Mock NativeWind
 jest.mock('nativewind', () => ({
   styled: () => (Component) => Component,
```

**Alternative solution:** Configure ESLint globally to recognize Jest in your ESLint config file by adding:

```json
{
  "env": {
    "jest": true
  }
}
```

This would apply to all test files without needing per-file comments.
</details>

<details>
<summary>🧰 Tools</summary>

<details>
<summary>🪛 GitHub Actions: App CI</summary>

[error] 2-2: ESLint: 'jest' is not defined. (no-undef)

</details>
<details>
<summary>🪛 GitHub Check: 🧹 Lint</summary>

[failure] 38-38: 
'jest' is not defined

---

[failure] 37-37: 
'jest' is not defined

---

[failure] 36-36: 
'jest' is not defined

---

[failure] 34-34: 
'jest' is not defined

---

[failure] 29-29: 
'jest' is not defined

---

[failure] 22-22: 
'jest' is not defined

---

[failure] 13-13: 
'jest' is not defined

---

[failure] 12-12: 
'jest' is not defined

---

[failure] 7-7: 
'jest' is not defined

---

[failure] 2-2: 
'jest' is not defined

</details>

</details>

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/jest.setup.js around lines 1 - 76, ESLint flags `'jest' is not defined`
because the test file uses Jest globals like the jest.mock calls (e.g.,
jest.mock('nativewind', ...), jest.mock('expo-linear-gradient', ...)) but the
linter doesn't know the Jest environment; fix by adding an ESLint environment
directive for Jest at the top of the test setup file so the jest globals are
recognized, or alternatively enable "jest": true under env in the project ESLint
config to apply this to all test files.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [8] app/src/components/fix-react-fc.sh
**Line:** 37
**Date:** 2026-01-07T09:52:40Z

_⚠️ Potential issue_ | _🟠 Major_

<details>
<summary>🧩 Analysis chain</summary>

🏁 Script executed:

```shell
# Check if the script file exists
find . -name "fix-react-fc.sh" -type f
```

Repository: Bluefinee/tempo-ai

Length of output: 98

---

🏁 Script executed:

```shell
# List the app/src/components directory to understand structure
ls -la app/src/components/ 2>/dev/null | head -30
```

Repository: Bluefinee/tempo-ai

Length of output: 1745

---

🏁 Script executed:

```shell
# Search for the component files mentioned in the script
fd "HealthMetricDetail|InputField|MetricGridCard|MiniBarChart" app/src/components/
```

Repository: Bluefinee/tempo-ai

Length of output: 255

---

🏁 Script executed:

```shell
# Check if components already have type annotations
echo "=== HealthMetricDetail.tsx ===" 
grep -n "export const HealthMetricDetail" app/src/components/HealthMetricDetail.tsx

echo -e "\n=== InputField.tsx ===" 
grep -n "export const InputField" app/src/components/InputField.tsx

echo -e "\n=== MetricGridCard.tsx ===" 
grep -n "export const MetricGridCard" app/src/components/MetricGridCard.tsx

echo -e "\n=== ScoreGauge.tsx ===" 
grep -n "export const ScoreGauge" app/src/components/ScoreGauge.tsx

echo -e "\n=== SecondaryButton.tsx ===" 
grep -n "export const SecondaryButton" app/src/components/SecondaryButton.tsx
```

Repository: Bluefinee/tempo-ai

Length of output: 374

---

🏁 Script executed:

```shell
# Check for any `any` types in components (per CR learning)
rg ":\s*any" app/src/components/*.tsx | head -20
```

Repository: Bluefinee/tempo-ai

Length of output: 44

---

🏁 Script executed:

```shell
# Read the script to understand what it's supposed to do
cat -n app/src/components/fix-react-fc.sh
```

Repository: Bluefinee/tempo-ai

Length of output: 1943

---

🏁 Script executed:

```shell
# Check if type annotations are actually present after the component declaration
echo "=== HealthMetricDetail.tsx (lines 84-87) ===" 
sed -n '84,87p' app/src/components/HealthMetricDetail.tsx

echo -e "\n=== InputField.tsx (lines 18-21) ===" 
sed -n '18,21p' app/src/components/InputField.tsx

echo -e "\n=== SecondaryButton.tsx (lines 21-24) ===" 
sed -n '21,24p' app/src/components/SecondaryButton.tsx

echo -e "\n=== WindowCard.tsx export ===" 
rg -n "export const WindowCard" app/src/components/WindowCard.tsx -A 2
```

Repository: Bluefinee/tempo-ai

Length of output: 461

---

🏁 Script executed:

```shell
# Check if the script is even referenced or imported anywhere
rg "fix-react-fc" --type ts --type tsx --type json
```

Repository: Bluefinee/tempo-ai

Length of output: 89

---

🏁 Script executed:

```shell
# Check git history to see if this script was recently added
git log --oneline --all -- "app/src/components/fix-react-fc.sh" 2>/dev/null | head -10
```

Repository: Bluefinee/tempo-ai

Length of output: 114

---



</details>

**Delete this temporary refactoring script.**

This shell script was committed but never executed—the target components still lack type annotations. Since the refactoring work is incomplete and the script is not part of the build process, it should be removed from the repository. Per coding guidelines, temporary scripts and build artifacts must not be committed.

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/src/components/fix-react-fc.sh around lines 1 - 37, The committed shell
script fix-react-fc.sh is a temporary, never-run refactoring artifact that
should be removed; delete fix-react-fc.sh from the repo, remove any references
to it in CI/config or docs if present, and ensure the actual type fixes are
applied directly to the component files (e.g., HealthMetricDetail.tsx,
InputField.tsx, MetricGridCard.tsx, etc.) rather than relying on a thrown-away
script.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [9] app/src/components/today/HealthSummaryCard.tsx
**Line:** 135
**Date:** 2026-01-07T09:52:40Z

_⚠️ Potential issue_ | _🟠 Major_

**Replace all inline styles with StyleSheet.create().**

The component uses extensive inline style objects throughout (lines 47-61, 68-91, 94-115, etc.), violating the project's React Native best practices. Inline styles create new objects on every render and reduce maintainability.



<details>
<summary>♻️ Refactor to use StyleSheet.create()</summary>

Move all inline style definitions to a `styles` object at the bottom of the file using `StyleSheet.create()`. This improves performance and follows the established pattern in other screens like `rhythm.tsx` and `complete.tsx`.

Example structure:
```diff
  return (
-   <View
-     key={card.id}
-     style={{
-       width: 140,
-       aspectRatio: 1,
-       backgroundColor: colors.white,
-       ...
-     }}
-   >
+   <View style={styles.cardContainer}>
      <Pressable
-       onPress={() => router.push("/health-detail")}
-       style={({ pressed }) => [pressed && { opacity: 0.7 }]}
+       onPress={() => router.push("/health-detail")}
+       style={({ pressed }) => [styles.pressable, pressed && styles.pressed]}
      >
-       <View style={{ flexDirection: "row", alignItems: "center", gap: 6 }}>
+       <View style={styles.header}>
          ...
```

Then add at the bottom:
```typescript
const styles = StyleSheet.create({
  cardContainer: {
    width: 140,
    aspectRatio: 1,
    backgroundColor: colors.white,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: colors.stone[100],
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 3,
    overflow: "hidden",
    padding: 16,
  },
  pressable: {},
  pressed: { opacity: 0.7 },
  header: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
  },
  // ... etc
});
```
</details>

As per coding guidelines, StyleSheet.create() is required for all style definitions in React Native components.


> Committable suggestion skipped: line range outside the PR's diff.

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/src/components/today/HealthSummaryCard.tsx around lines 44 - 133, The
component HealthSummaryCard uses many inline style objects; extract them into a
StyleSheet created via StyleSheet.create() and replace the inline objects with
references to that styles object (e.g., cardContainer, pressable, pressed,
header, iconWrapper, labelText, valueText, unitText, chartContainer) inside the
HealthSummaryCard return; create the styles const at the bottom of the file,
move all static style properties (the View wrapping key={card.id}, the Pressable
style callback, header row, icon wrapper, Text styles, and chart container) into
named entries, and update usages to style={styles.cardContainer},
style={({pressed})=>[styles.pressable, pressed && styles.pressed]}, etc.,
keeping dynamic values (card.colorIcon, lineColor, points, lastY) inline where
needed. Ensure you import StyleSheet from react-native and do not change
component behavior or props.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [10] app/src/components/today/HealthSummaryCard.tsx
**Line:** 48
**Date:** 2026-01-07T09:52:40Z

_🧹 Nitpick_ | _🔵 Trivial_

**Remove unnecessary key prop.**

The `key={card.id}` prop on the root View (line 46) is unnecessary since this component renders a single card. The `key` should be applied by the parent component when mapping over an array of cards.



<details>
<summary>🧹 Proposed cleanup</summary>

```diff
  return (
    <View
-     key={card.id}
      style={{
        width: 140,
```
</details>

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
  return (
    <View
      style={{
        width: 140,
```

</details>

<!-- suggestion_end -->

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/src/components/today/HealthSummaryCard.tsx at line 46, Remove the
unnecessary key prop from the root View in the HealthSummaryCard component:
delete the key={card.id} usage on the top-level JSX element inside
HealthSummaryCard (where the component renders a single card) and ensure any
array mapping that renders multiple HealthSummaryCard instances applies the key
at the parent level instead.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [11] app/src/components/today/MetricGridCard.tsx
**Line:** 37
**Date:** 2026-01-07T09:52:40Z

_⚠️ Potential issue_ | _🟡 Minor_

**Remove unnecessary key prop.**

The `key` prop on line 30 is unnecessary because this `Pressable` is not being rendered as part of a list or array iteration. The `key` prop is only needed when rendering multiple elements in a `.map()` or similar iteration.



<details>
<summary>🧹 Proposed fix</summary>

```diff
     <Pressable
-      key={metric.id}
       onPress={() => router.push(metric.route)}
       className="bg-white p-5 rounded-3xl border border-stone-100"
```
</details>

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
    <Pressable
      onPress={() => router.push(metric.route)}
      className="bg-white p-5 rounded-3xl border border-stone-100"
```

</details>

<!-- suggestion_end -->

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/src/components/today/MetricGridCard.tsx around lines 29 - 31, Remove the
unnecessary key prop from the Pressable in MetricGridCard; locate the Pressable
element that currently includes key={metric.id} and simply delete the key
attribute (the onPress handler router.push(metric.route) and metric usage remain
unchanged) so the component no longer supplies a key when it isn’t part of a
list iteration.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [12] app/app/(main)/breathe.tsx
**Line:** 64
**Date:** 2026-01-07T10:05:05Z

_⚠️ Potential issue_ | _🟠 Major_

**Memoize responsive sizing to avoid recalculation on every render.**

The responsive sizing constants (`CIRCLE_SIZE`, `SVG_RADIUS`, `CIRCUMFERENCE`) are now recalculated on every render. Since this component updates frequently (every second for the timer, plus phase changes), these calculations are wasted computation when `SCREEN_WIDTH` hasn't changed.



<details>
<summary>⚡ Proposed performance fix using useMemo</summary>

```diff
+import React, { useCallback, useEffect, useRef, useState, useMemo } from 'react';

  const BreatheScreen = (): React.ReactElement => {
    const router = useRouter();
    const insets = useSafeAreaInsets();
    const { width: SCREEN_WIDTH } = useWindowDimensions();
    const [isActive, setIsActive] = useState(false);
    const [phase, setPhase] = useState<'idle' | 'inhale' | 'hold' | 'exhale'>('idle');
    const [timeLeft, setTimeLeft] = useState(60);

    const previousPhaseRef = useRef(phase);
    const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
    const phaseTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

-  // Responsive circle size
-  const CIRCLE_SIZE = Math.min(SCREEN_WIDTH * 0.65, 280);
-  const SVG_RADIUS = CIRCLE_SIZE * 0.47;
-  const CIRCUMFERENCE = 2 * Math.PI * SVG_RADIUS;
+  // Responsive circle size - memoized to avoid recalculation
+  const { CIRCLE_SIZE, SVG_RADIUS, CIRCUMFERENCE } = useMemo(() => {
+    const circleSize = Math.min(SCREEN_WIDTH * 0.65, 280);
+    const svgRadius = circleSize * 0.47;
+    const circumference = 2 * Math.PI * svgRadius;
+    return { CIRCLE_SIZE: circleSize, SVG_RADIUS: svgRadius, CIRCUMFERENCE: circumference };
+  }, [SCREEN_WIDTH]);
```
</details>

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
import React, { useCallback, useEffect, useRef, useState, useMemo } from 'react';

const BreatheScreen = (): React.ReactElement => {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { width: SCREEN_WIDTH } = useWindowDimensions();
  const [isActive, setIsActive] = useState(false);
  const [phase, setPhase] = useState<'idle' | 'inhale' | 'hold' | 'exhale'>('idle');
  const [timeLeft, setTimeLeft] = useState(60);

  const previousPhaseRef = useRef(phase);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const phaseTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Responsive circle size - memoized to avoid recalculation
  const { CIRCLE_SIZE, SVG_RADIUS, CIRCUMFERENCE } = useMemo(() => {
    const circleSize = Math.min(SCREEN_WIDTH * 0.65, 280);
    const svgRadius = circleSize * 0.47;
    const circumference = 2 * Math.PI * svgRadius;
    return { CIRCLE_SIZE: circleSize, SVG_RADIUS: svgRadius, CIRCUMFERENCE: circumference };
  }, [SCREEN_WIDTH]);
```

</details>

<!-- suggestion_end -->

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/breathe.tsx around lines 52 - 56, The responsive sizing
constants CIRCLE_SIZE, SVG_RADIUS and CIRCUMFERENCE are being recomputed on
every render; wrap their calculation in a useMemo that depends on SCREEN_WIDTH
(e.g. const {CIRCLE_SIZE, SVG_RADIUS, CIRCUMFERENCE} = useMemo(() => { const c =
Math.min(SCREEN_WIDTH * 0.65, 280); const r = c * 0.47; return { CIRCLE_SIZE: c,
SVG_RADIUS: r, CIRCUMFERENCE: 2 * Math.PI * r }; }, [SCREEN_WIDTH])) and import
useMemo from React so they only recalc when SCREEN_WIDTH changes. Ensure you
replace the existing top-level constant declarations with the memoized values
used by the component.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [13] app/app/(main)/energy-detail.tsx
**Line:** 98
**Date:** 2026-01-07T10:05:05Z

_🛠️ Refactor suggestion_ | _🟠 Major_

**Consider using named exports instead of default exports.**

The coding guidelines specify "Use named exports instead of default exports for better refactoring and tree-shaking." While this PR consistently applies arrow functions with trailing default exports across multiple files, consider converting to named exports for improved maintainability.



<details>
<summary>♻️ Example with named export</summary>

```diff
-const EnergyDetailScreen = (): React.ReactElement => {
+export const EnergyDetailScreen = (): React.ReactElement => {
   // ... component body
 }

-export default EnergyDetailScreen;
```

Usage would then be: `import { EnergyDetailScreen } from '...'`
</details>

As per coding guidelines, named exports are preferred over default exports.


Also applies to: 384-384

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/energy-detail.tsx at line 89, The component is currently
exported as a default export; update it to a named export to follow the project
guideline (use named exports for better refactoring and tree-shaking). Change
the declaration/export for EnergyDetailScreen from a default export to a named
export (export const EnergyDetailScreen = ...), and update any corresponding
import sites to use the named import form (import { EnergyDetailScreen } from
'...'); repeat the same conversion for the other occurrence referenced (line
~384) to ensure consistency across the file.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [14] app/app/(main)/health-detail.tsx
**Line:** 202
**Date:** 2026-01-07T10:05:05Z

_🛠️ Refactor suggestion_ | _🟠 Major_

**Consider using named exports instead of default exports.**

Per coding guidelines, named exports are preferred over default exports for better refactoring and tree-shaking capabilities.



<details>
<summary>♻️ Example conversion</summary>

```diff
-const HealthDetailScreen = (): React.ReactElement => {
+export const HealthDetailScreen = (): React.ReactElement => {
   // ... component body
 }

-export default HealthDetailScreen;
```
</details>

As per coding guidelines, this improves maintainability across the codebase.


Also applies to: 720-720

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [15] app/app/(onboarding)/healthkit.tsx
**Line:** 18
**Date:** 2026-01-07T10:05:05Z

_🛠️ Refactor suggestion_ | _🟠 Major_

**Consider using named exports instead of default exports.**

Consistent with the pattern across this PR, consider converting to named exports per coding guidelines for improved refactoring and tree-shaking.



As per coding guidelines, named exports are preferred over default exports.


Also applies to: 222-222

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(onboarding)/healthkit.tsx at line 18, The component currently uses
a default export; change it to a named export by exporting HealthKitScreen as a
named export (export const HealthKitScreen = ...) and remove any default export
statements (also update the other occurrence at line 222 to use a named export).
Update all imports that reference this module to import { HealthKitScreen } (and
the second named export) instead of default importing, to keep exports
consistent with the PR guideline and enable better tree-shaking and refactoring.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [16] app/app/(onboarding)/location.tsx
**Line:** 18
**Date:** 2026-01-07T10:05:05Z

_🛠️ Refactor suggestion_ | _🟠 Major_

**Consider using named exports instead of default exports.**

Consistent with the refactor pattern in this PR, consider converting to named exports per coding guidelines for improved maintainability and tree-shaking.



As per coding guidelines, named exports are preferred over default exports.


Also applies to: 222-222

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(onboarding)/location.tsx at line 18, Convert the component from a
default export to a named export: change the declaration to export const
LocationScreen = (): JSX.Element => { ... } (or if it remains const without
export, replace the final export default LocationScreen with export {
LocationScreen }) and update any imports elsewhere to use named import syntax
(import { LocationScreen } from '...'); apply the same change for the other
occurrence referenced (line ~222) to keep exports consistent.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [17] app/app/(onboarding)/nickname.tsx
**Line:** 25
**Date:** 2026-01-07T10:05:05Z

_🛠️ Refactor suggestion_ | _🟠 Major_

**Consider using named exports instead of default exports.**

As per coding guidelines, named exports are preferred over default exports for better refactoring and tree-shaking. This applies to all onboarding screens in this PR.



<details>
<summary>♻️ Example conversion</summary>

```diff
-const NicknameScreen = (): JSX.Element => {
+export const NicknameScreen = (): JSX.Element => {
   // ... component body
 }

-export default NicknameScreen;
```
</details>

As per coding guidelines, named exports improve maintainability.


Also applies to: 192-192

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(onboarding)/nickname.tsx at line 19, Change the component from a
default export to a named export: export the NicknameScreen function as a named
export (e.g., export const NicknameScreen = ...) instead of default, update any
export statement that currently does default export, and then update all imports
that reference the default (e.g., import NicknameScreen from '...') to use a
named import (e.g., import { NicknameScreen } from '...'); apply the same
conversion for other onboarding screens mentioned.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [18] app/src/components/SunInfoCard.tsx
**Line:** 25
**Date:** 2026-01-07T10:05:05Z

_⚠️ Potential issue_ | _🔴 Critical_

**`any` type is forbidden — replace with explicit icon props type.**

The return type annotation uses `React.ComponentType<any>`, which violates the coding guideline "any型は絶対禁止" (any type is absolutely forbidden). This eliminates type safety for the Icon component.



<details>
<summary>🔒 Proposed fix: Define explicit icon props type</summary>

```diff
+interface IconProps {
+  size?: number;
+  color?: string;
+  strokeWidth?: number;
+}
+
-const getTypeConfig = (type: SunType): { Icon: React.ComponentType<any>; iconColor: string; iconBgColor: string; labelColor: string; defaultLabel: string } => {
+const getTypeConfig = (type: SunType): { Icon: React.ComponentType<IconProps>; iconColor: string; iconBgColor: string; labelColor: string; defaultLabel: string } => {
```
</details>

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
interface IconProps {
  size?: number;
  color?: string;
  strokeWidth?: number;
}

const getTypeConfig = (type: SunType): { Icon: React.ComponentType<IconProps>; iconColor: string; iconBgColor: string; labelColor: string; defaultLabel: string } => {
```

</details>

<!-- suggestion_end -->

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/src/components/SunInfoCard.tsx at line 25, The return type of
getTypeConfig uses React.ComponentType<any>, which violates the no-any rule;
define an explicit IconProps interface (e.g., props like size?: number; color?:
string; className?: string or the actual props your icons accept) and replace
React.ComponentType<any> with React.ComponentType<IconProps> (or
React.FC<IconProps>) in the function signature and any places that render the
Icon, ensuring the Icon is typed consistently across getTypeConfig and its
consumers.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [19] app/app/(main)/rhythm.tsx
**Line:** 107
**Date:** 2026-01-07T10:14:40Z

_🛠️ Refactor suggestion_ | _🟠 Major_

**Replace default export with named export and consider file size.**

1. Default exports hinder refactoring per coding guidelines.
2. This file is 528 lines, exceeding the recommended 400-line limit. After removing the unused StyleSheet (83 lines), it will drop to ~445 lines—still slightly over. Consider extracting environmental data cards into a separate component.



<details>
<summary>♻️ Proposed fix for export</summary>

```diff
-export default RhythmScreen;
+export { RhythmScreen };
```

Update consuming files to use named import:
```diff
-import RhythmScreen from './(main)/rhythm';
+import { RhythmScreen } from './(main)/rhythm';
```

</details>

As per coding guidelines, use named exports for better refactoring and tree-shaking.


Also applies to: 442-442, 528-528

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/rhythm.tsx at line 87, The file uses a default export for the
RhythmScreen component and exceeds the preferred size; change the export from
default to a named export (export const RhythmScreen) and update all consuming
modules to import { RhythmScreen } instead of the default import; also reduce
file size by extracting the environmental data cards into a new component (e.g.,
EnvironmentalDataCards) and move their JSX and related logic out of
RhythmScreen, keeping only props/state wiring, and ensure any local helper
functions or types used by the new component are moved or exported as needed so
imports compile cleanly.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [20] app/app/(main)/rhythm.tsx
**Line:** 518
**Date:** 2026-01-07T10:14:40Z

_⚠️ Potential issue_ | _🔴 Critical_

**Remove 83 lines of unused StyleSheet definitions.**

The `styles` object is created but never referenced—all styling remains inline throughout the JSX. This is dead code that inflates the file and confuses intent.



<details>
<summary>🧹 Proposed cleanup</summary>

```diff
-const styles = StyleSheet.create({
-  dateContainer: {
-    gap: 8,
-  },
-  dateText: {
-    letterSpacing: 1.5,
-  },
-  titleText: {
-    fontFamily: FontFamily.serif,
-  },
-  timeText: {
-    fontFamily: 'monospace',
-  },
-  sectionTitle: {
-    letterSpacing: 1.5,
-  },
-  windowCardsContainer: {
-    gap: 16,
-  },
-  peakEnergyCard: {
-    padding: 20,
-    borderWidth: 2,
-    borderColor: colors.amber[400],
-    shadowColor: colors.amber[500],
-    shadowOffset: { width: 0, height: 6 },
-    shadowOpacity: 0.15,
-    shadowRadius: 12,
-    elevation: 6,
-  },
-  melatoninCard: {
-    padding: 20,
-    borderWidth: 2,
-    borderColor: colors.indigo[400],
-    shadowColor: colors.indigo[500],
-    shadowOffset: { width: 0, height: 6 },
-    shadowOpacity: 0.15,
-    shadowRadius: 12,
-    elevation: 6,
-  },
-  windowCardContent: {
-    gap: 16,
-  },
-  windowIconContainer: {
-    flex: 1,
-  },
-  peakIconBg: {
-    backgroundColor: colors.amber[100],
-  },
-  melatoninIconBg: {
-    backgroundColor: colors.indigo[100],
-  },
-  envRow: {
-    gap: 12,
-  },
-  envCard: {
-    padding: 16,
-    borderWidth: 1,
-    borderColor: colors.stone[100],
-    shadowColor: '#000',
-    shadowOffset: { width: 0, height: 4 },
-    shadowOpacity: 0.06,
-    shadowRadius: 10,
-    elevation: 4,
-  },
-  sunriseIconBg: {
-    backgroundColor: colors.amber[100],
-  },
-  sunsetIconBg: {
-    backgroundColor: colors.rose[100],
-  },
-  weatherIconBg: {
-    backgroundColor: colors.blue[50],
-  },
-  pressureIconBg: {
-    backgroundColor: colors.emerald[100],
-  },
-  uvIconBg: {
-    backgroundColor: colors.amber[50],
-  },
-  moonIconBg: {
-    backgroundColor: colors.purple[50],
-  },
-});
-
```

Also remove the unused `StyleSheet` import:
```diff
-import { View, Text, ScrollView, Pressable, StyleSheet } from 'react-native';
+import { View, Text, ScrollView, Pressable } from 'react-native';
```

</details>

As per coding guidelines, delete unused code instead of leaving it commented out or defined.

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
// Lines 444-526 are removed entirely
// The StyleSheet import should also be removed from the import statement at the top of the file
```

</details>

<!-- suggestion_end -->

<details>
<summary>🧰 Tools</summary>

<details>
<summary>🪛 GitHub Actions: App CI</summary>

[warning] 444-444: ESLint: 'styles' is assigned a value but never used. (no-unused-vars)

</details>
<details>
<summary>🪛 GitHub Check: 🧹 Lint</summary>

[warning] 444-444: 
'styles' is assigned a value but never used

</details>

</details>

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/rhythm.tsx around lines 444 - 526, Remove the unused styles
object and its StyleSheet import: the const styles = StyleSheet.create({...})
block and the StyleSheet import at the top are dead because JSX uses inline
styles; delete the entire styles declaration (all style keys like dateContainer,
peakEnergyCard, melatoninCard, envCard, etc.) and remove the StyleSheet import
to clean up unused code and satisfy linting.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [21] app/app/(onboarding)/index.tsx
**Line:** 147
**Date:** 2026-01-07T10:14:41Z

_🛠️ Refactor suggestion_ | _🟠 Major_

**Replace default export with named export.**

Default exports hinder refactoring and tree-shaking. Use `export { WelcomeScreen };` instead.



<details>
<summary>♻️ Proposed fix</summary>

```diff
-export default WelcomeScreen;
+export { WelcomeScreen };
```

Update the consuming `_layout.tsx` to use a named import:
```diff
-import WelcomeScreen from './index';
+import { WelcomeScreen } from './index';
```

</details>

As per coding guidelines, named exports are required for better refactoring and tree-shaking.

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
export { WelcomeScreen };
```

</details>

<!-- suggestion_end -->

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(onboarding)/index.tsx at line 147, Replace the default export of
the WelcomeScreen component with a named export: remove "export default
WelcomeScreen" and instead export it as a named export (export { WelcomeScreen
}); then update any consumers (e.g., the _layout.tsx file) to import using the
named import syntax (import { WelcomeScreen } from '...') so tree-shaking and
refactoring work correctly.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [22] app/app/(main)/energy-detail.tsx
**Line:** 462
**Date:** 2026-01-07T10:22:02Z

_🧹 Nitpick_ | _🔵 Trivial_

**Convert to named export as per coding guidelines.**

The component is still exported as a default export. As previously noted, the coding guidelines specify using named exports for better refactoring and tree-shaking.

As per coding guidelines, named exports are preferred over default exports.



<details>
<summary>♻️ Refactor to named export</summary>

```diff
-export default EnergyDetailScreen;
+export { EnergyDetailScreen };
```

Then update import sites to use:
```typescript
import { EnergyDetailScreen } from '...';
```
</details>

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
export { EnergyDetailScreen };
```

</details>

<!-- suggestion_end -->

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/energy-detail.tsx at line 422, The file currently uses a
default export for the React component (export default EnergyDetailScreen);
change this to a named export by exporting EnergyDetailScreen as a named export
(e.g., export { EnergyDetailScreen } or export const EnergyDetailScreen = ...)
and update all import sites to use the named import syntax (import {
EnergyDetailScreen } from '...') so the component follows the project's
named-export guideline and supports proper refactoring/tree-shaking.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [23] app/app/(main)/index.tsx
**Line:** 41
**Date:** 2026-01-07T10:22:02Z

_⚠️ Potential issue_ | _🟡 Minor_

**Unused `HealthCard` type import.**

The `HealthCard` type is imported but not used in this file. This was flagged in a previous review.



<details>
<summary>🧹 Proposed fix</summary>

```diff
 import { MetricGridCard, type MetricCard } from "../../src/components/today/MetricGridCard";
-import { HealthSummaryCard, type HealthCard } from "../../src/components/today/HealthSummaryCard";
+import { HealthSummaryCard } from "../../src/components/today/HealthSummaryCard";
```
</details>

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
import { MetricGridCard, type MetricCard } from "../../src/components/today/MetricGridCard";
import { HealthSummaryCard } from "../../src/components/today/HealthSummaryCard";
```

</details>

<!-- suggestion_end -->

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/index.tsx around lines 40 - 41, The file imports the type
HealthCard but never uses it; remove the unused type import by changing the
import line that currently reads 'import { HealthSummaryCard, type HealthCard }
from "../../src/components/today/HealthSummaryCard";' to only import
HealthSummaryCard (keep MetricGridCard/MetricCard import as-is), or if you
intended to use HealthCard elsewhere, reference the type where needed; ensure no
other references to HealthCard remain so the unused import warning is resolved.
```

</details>

<!-- fingerprinting:phantom:medusa:ocelot -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [24] app/app/(main)/index.tsx
**Line:** 432
**Date:** 2026-01-07T10:22:02Z

_🧹 Nitpick_ | _🔵 Trivial_

**Use centralized color token for shadowColor.**

Line 406 uses hardcoded `"#000"` while other parts of the codebase use `colors.black`. For consistency with the theme system:


<details>
<summary>♻️ Proposed fix</summary>

```diff
   insightCardShadow: {
-    shadowColor: "#000",
+    shadowColor: colors.black,
     shadowOffset: { width: 0, height: 4 },
     shadowOpacity: 0.06,
     shadowRadius: 8,
     elevation: 3,
   },
```
</details>

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
  insightCardShadow: {
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 3,
  },
```

</details>

<!-- suggestion_end -->

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/index.tsx around lines 405 - 411, The shadowColor in the
insightCardShadow style is hardcoded as "#000"; replace it with the centralized
token colors.black (i.e., set shadowColor: colors.black) and ensure the colors
symbol is imported/available in this module (add the existing theme/colors
import if missing) so the style uses the shared color token for consistency.
```

</details>

<!-- fingerprinting:phantom:medusa:ocelot -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [25] app/app/(main)/index.tsx
**Line:** 470
**Date:** 2026-01-07T10:22:02Z

_🧹 Nitpick_ | _🔵 Trivial_

**Prefer named export over default export.**

Per coding guidelines, use named exports for better refactoring and tree-shaking support.


<details>
<summary>♻️ Proposed fix</summary>

```diff
-export default TodayScreen;
+export { TodayScreen };
```

Note: This may require updating the expo-router configuration if it expects default exports for route files. Verify compatibility before applying.
</details>


> Committable suggestion skipped: line range outside the PR's diff.

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/index.tsx at line 449, Replace the default export of the
component with a named export: remove "export default TodayScreen" and instead
export the TodayScreen symbol as a named export (e.g., "export { TodayScreen }"
or "export const TodayScreen = ..."), then update any imports or references that
import the default to use the named import; also verify and adjust expo-router
route configuration if it requires default exports so routes still resolve
correctly.
```

</details>

<!-- fingerprinting:phantom:medusa:ocelot -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [26] app/app/(main)/rhythm.tsx
**Line:** 62
**Date:** 2026-01-07T10:22:02Z

_🛠️ Refactor suggestion_ | _🟠 Major_

**Eliminate code duplication by importing from the centralized module.**

This function duplicates `getPressureTrendIcon` already exported from `app/src/domain/models/weather.ts`. Import and use the shared implementation instead of maintaining a local copy.




<details>
<summary>♻️ Proposed fix</summary>

```diff
+import { getPressureTrendIcon, type PressureTrend } from '../../src/domain/models/weather';
+
 // モックデータ: 24時間分のエネルギーレベル (sozai版と同じデータ形式)
 const RHYTHM_DATA: RhythmDataPoint[] = [
...
-// 気圧トレンドのアイコンを取得
-const getPressureTrendIcon = (trend: 'rising' | 'stable' | 'falling'): string => {
-  switch (trend) {
-    case 'rising':
-      return '↑';
-    case 'stable':
-      return '→';
-    case 'falling':
-      return '↓';
-  }
-};
-
```

</details>

As per coding guidelines, eliminate duplicate code to maintain a single source of truth.

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
import { getPressureTrendIcon, type PressureTrend } from '../../src/domain/models/weather';

// モックデータ: 24時間分のエネルギーレベル (sozai版と同じデータ形式)
const RHYTHM_DATA: RhythmDataPoint[] = [
  // ... rest of the component continues
```

</details>

<!-- suggestion_end -->

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/rhythm.tsx around lines 53 - 62, Remove the local duplicate
getPressureTrendIcon implementation and import the shared getPressureTrendIcon
exported by the domain weather module instead; replace the local function with
an import statement and ensure all local usages (calls to getPressureTrendIcon)
now reference the imported symbol, keeping the same signature ('rising' |
'stable' | 'falling') so no call sites change.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [27] app/app/(main)/rhythm.tsx
**Line:** 520
**Date:** 2026-01-07T10:22:03Z

_🛠️ Refactor suggestion_ | _🟠 Major_

**Replace default export with named export.**

Default exports hinder refactoring and tree-shaking. Use a named export instead.




<details>
<summary>♻️ Proposed fix</summary>

```diff
-export default RhythmScreen;
+export { RhythmScreen };
```

Update consuming files to use named import:
```typescript
import { RhythmScreen } from './(main)/rhythm';
```

</details>

As per coding guidelines, use named exports for better refactoring and tree-shaking.

> Committable suggestion skipped: line range outside the PR's diff.

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/rhythm.tsx at line 408, Replace the default export for
RhythmScreen with a named export: remove the "export default RhythmScreen" and
export the existing RhythmScreen symbol as a named export (e.g., export {
RhythmScreen }) and then update all consumers to import it using named imports
(import { RhythmScreen } from './(main)/rhythm'). Ensure any files that
previously used a default import are updated to the new named import.
```

</details>

<!-- fingerprinting:phantom:poseidon:puma -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [28] app/app/(main)/energy-detail.tsx
**Line:** 441
**Date:** 2026-01-07T10:25:17Z

_⚠️ Potential issue_ | _🟡 Minor_

**`borderStyle: 'dashed'` has no effect here.**

The `currentTimeMarker` style sets `borderStyle: 'dashed'` but uses `backgroundColor` with `width: 2` to render the marker. In React Native, `borderStyle` only affects border rendering when `borderWidth` is set—it won't make the background color appear dashed. If you want a dashed vertical line, you'd need a different approach (e.g., SVG dashed line or alternating small views).

If a solid marker is acceptable, remove the unused `borderStyle` property to avoid confusion.



<details>
<summary>🧹 Proposed fix (remove unused property)</summary>

```diff
  currentTimeMarker: {
    position: 'absolute',
    top: 0,
    bottom: 20,
    width: 2,
    backgroundColor: colors.amber[400],
-   borderStyle: 'dashed',
  },
```
</details>

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/energy-detail.tsx around lines 398 - 405, The
currentTimeMarker style sets borderStyle: 'dashed' which has no effect because
there is no borderWidth and the marker is drawn via backgroundColor/width;
remove the unused borderStyle property from the currentTimeMarker style to avoid
confusion, or if a dashed vertical line is required replace this view with an
SVG Line using strokeDasharray or render a sequence of small stacked Views to
simulate dashes (referencing currentTimeMarker, backgroundColor, width).
```

</details>

<!-- fingerprinting:phantom:medusa:ocelot -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [29] app/app/(main)/index.tsx
**Line:** 468
**Date:** 2026-01-07T10:25:17Z

_🧹 Nitpick_ | _🔵 Trivial_

**File length at 452 lines approaches the practical limit.**

With the StyleSheet accounting for ~90 lines, the component logic itself is manageable. If this file grows further, consider extracting the StyleSheet to a separate `styles.ts` file or splitting additional sections into sub-components.

<!-- fingerprinting:phantom:medusa:ocelot -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

## [30] app/app/(main)/index.tsx
**Line:** 432
**Date:** 2026-01-07T10:25:18Z

_🧹 Nitpick_ | _🔵 Trivial_

**Use `colors.black` instead of hardcoded `"#000"`.**

This file uses `"#000"` for `shadowColor` while `energy-detail.tsx` uses `colors.black`. For consistency with the theme system, use the centralized color token.




<details>
<summary>♻️ Proposed fix</summary>

```diff
  insightCardShadow: {
-   shadowColor: "#000",
+   shadowColor: colors.black,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 3,
  },
```
</details>

<!-- suggestion_start -->

<details>
<summary>📝 Committable suggestion</summary>

> ‼️ **IMPORTANT**
> Carefully review the code before committing. Ensure that it accurately replaces the highlighted code, contains no missing lines, and has no issues with indentation. Thoroughly test & benchmark the code to ensure it meets the requirements.

```suggestion
  insightCardShadow: {
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 3,
  },
```

</details>

<!-- suggestion_end -->

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In @app/app/(main)/index.tsx around lines 408 - 414, Replace the hardcoded
shadow color in the insightCardShadow style: change shadowColor: "#000" to use
the theme token (colors.black) in the object named insightCardShadow; if colors
is not already imported in this file, add the appropriate import for the colors
export (the same token used in energy-detail.tsx) and use colors.black for
consistency with the theme system.
```

</details>

<!-- fingerprinting:phantom:medusa:ocelot -->

<!-- This is an auto-generated comment by CodeRabbit -->

---

