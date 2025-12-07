# Phase 3 Technical Specification: "The Digital Cockpit"

## Theme: Insight First, Human Battery, and Environmental Context

### 1. Overview

In Phase 3, we fundamentally restructure the app from a "Data Dashboard" to a **"Digital Cockpit"**.
The core value proposition shifts from "monitoring numbers" to **"providing immediate answers"** based on internal biology (HealthKit) and external environment (Open-Meteo).

### 2. Core Architecture Updates

#### A. User Mode (The Foundation)

Define `UserMode` to determine the "interpretation logic" of the battery.

- **Standard Mode (Default):** Focus on daily energy management, stress reduction, and wellness.
- **Athlete Mode:** Focus on training intensity, physical recovery, and peaking performance.

#### B. The Human Battery Engine

Implement the logic to calculate the user's "Body Battery" (0-100%).

- **Morning Charge:** Calculated from Sleep Duration, Sleep Quality (Deep/REM), and HRV relative to baseline.
- **Real-time Drain:**
  - Decreases based on `ActiveEnergyBurned`, `StepCount`, and `Stress` (HRV dips).
  - **Environmental Factor:** If the **Weather API** indicates extreme conditions (e.g., Heatstroke Alert, Low Pressure), the drain rate should technically increase (or the max capacity lowers).

#### C. External Data Integration (Open-Meteo)

Fetch weather data to provide context to the AI.

- **Data Points:** Temperature, Humidity, Apparent Temperature, Precipitation, **Surface Pressure** (crucial for headaches), Air Quality (AQI).
- **Usage:** These data points are _not_ just displayed but sent to the Claude API to generate context-aware advice (e.g., "Pressure is dropping; your battery might feel lower than actual").

### 3. Home Screen UI Specification (The "Answer First" Layout)

The UI must follow a strict vertical hierarchy. Do not use generic greetings.

#### Section 1: The Daily Headline (Top Priority)

- **Component:** `AdviceHeaderView`
- **Visual:** Large, magazine-style typography.
- **Logic:** The AI generates a "Verdict" (Headline) and "Reasoning" (Subtitle).
  - _Example:_ "Low Pressure Warning" (Headline) / "Headaches likely. Take it easy." (Subtitle)
- **Interaction:** Tapping opens `AdviceDetailView` for the full analysis.

#### Section 2: The Liquid Battery

- **Component:** `BatteryView`
- **Visual:** A horizontal container with a fluid animation representing energy.
- **States:** High (Green/Neon), Medium (Yellow), Low (Red).

#### Section 3: Intuitive Metrics (The 3 Cards)

Replace generic rings with meaningful state cards.

1.  **Stress Level (Internal Load):**
    - _Data:_ Inverse of HRV + Resting Heart Rate.
    - _UI:_ Gauge. High Stress = Warning Color.
2.  **Recovery:**
    - _Data:_ Sleep Quality + Previous Strain.
3.  **Sleep:**
    - _Data:_ Duration + Efficiency.

#### Section 4: Vital Grid (Bottom)

- **Component:** `VitalGridView`
- **UI:** Horizontal scroll showing raw numbers (Steps, HR, Temp, AQI) for quick reference.

### 4. Backend Logic (Cloudflare Workers)

- **Input Schema:** Update `AnalysisRequest` to include:
  - `UserMode`
  - `WeatherData` (from Open-Meteo)
  - `HealthMetrics`
- **Prompt Engineering:**
  - Instruct Claude to prioritize the **Headline**.
  - Synthesize Weather + Health. (e.g., "Poor Sleep" + "Rain" = "Depressive mood warning").
