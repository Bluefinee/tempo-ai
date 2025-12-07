# Phase 4 Technical Specification: Deep Personalization

## Theme: Focus Tags, Multi-Context Logic, and "Chill" Integration

### 1. Overview

Phase 4 introduces "Focus Tags," allowing users to customize the AI's advice engine.
Crucially, **users can select MULTIPLE tags**. The system must handle conflicting or overlapping advice intelligently.
We also introduce a "Chill / Relax" concept (formerly Sauna) as a subtle, omnipresent support feature rather than a dominant mode.

### 2. Focus Tags Architecture

#### A. Tag Definitions (Enum)

Users can toggle these On/Off in Settings/Onboarding.

1.  **🧠 Deep Focus (Work):** Focus on brain fog, productivity windows, and mental clarity.
2.  **✨ Beauty & Skin:** Focus on hydration, sleep for growth hormones, and UV protection.
3.  **🥗 Diet & Metabolism:** Focus on meal timing, digestion, and active calorie balance.
4.  **🍃 Chill / Relax:** Focus on autonomic nervous system balance, "To-tonoi" (Sauna/Bathing), and mental reset.

#### B. Multi-Select Logic (The "Mixer" Engine)

Since a user can select `[Work, Beauty]`, the AI prompt generation must "mix" these contexts.

- **Prompt Strategy:**
  - _Base:_ Standard/Athlete Mode logic.
  - _Injection:_ Append specific instructions for _each_ active tag.
  - _Conflict Resolution:_ If tags conflict (e.g., Work says "Push", Chill says "Rest"), prioritize **Biological Safety** (Battery Level).
    - _Example (Work + Chill, Battery Low):_ "Your brain is tired (Work). Prioritize a reset bath (Chill) to recover for tomorrow."

### 3. "Chill / Relax" Implementation (Subtle Integration)

Unlike other tags that might drive activity, "Chill / Relax" is a passive support layer.

- **Not a main mode:** It does not change the UI color scheme or main structure.
- **Trigger-based Advice:**
  - If `Tag == Chill` AND `Stress == High`: Show a "Sauna/Bath Opportunity" card in the Smart Suggestion area.
  - _Advice Content:_ "Sympathetic nerves are overactive. A 3-minute cold shower or 10-minute lukewarm bath is recommended."
- **Detail View:** In the "Stress Detail View", add a small "Autonomic Balance" section if this tag is active.

### 4. UI Updates: Smart Suggestions & Detail Personalization

#### A. Smart Suggestion Cards

Insert contextual mini-cards below the Battery _only when relevant_.

- _Work Tag + Low Pressure (Weather):_ "Headache Risk: Focus on tasks now before pressure drops."
- _Beauty Tag + Low Humidity (Weather):_ "Dry Skin Alert: Hydrate more than usual."

#### B. Detail View Customization

Customize the `DetailView` content based on active tags.

- **Sleep Detail:**
  - _If Beauty:_ Show "Skin Repair Time" (Deep Sleep duration).
  - _If Work:_ Show "Mental Restoration" (REM Sleep duration).
- **Vital Grid:**
  - _If Diet:_ Highlight "Active Calories".
  - _If Chill:_ Highlight "HRV".

### 5. Backend Logic Updates

- **Prompt Builder:**
  - Iterate through `activeTags` array.
  - Inject specific "Lenses" for the AI.
    - _Beauty Lens:_ "Analyze weather humidity and UV."
    - _Chill Lens:_ "Analyze stress spikes and recommend recovery rituals."
- **Response Structure:**
  - Ensure the JSON response includes specific `tagSuggestions` that the frontend can render as appropriate icons/cards.
