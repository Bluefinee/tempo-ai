# UX Design Concepts & Principles

This document compiles psychological principles and design concepts for achieving excellent user experience (UX).
Please be mindful of these principles when implementing applications.

## Table of Contents

1. [Cognition and Psychological Effects](#cognition-and-psychological-effects)
2. [Interaction and Feedback](#interaction-and-feedback)
3. [Information Architecture](#information-architecture)
4. [Health & Wellness App-Specific Principles](#health--wellness-app-specific-principles)
5. [Performance and Response](#performance-and-response)
6. [Accessibility](#accessibility)

---

## Cognition and Psychological Effects

### Aesthetic-Usability Effect

**Definition**: The psychological effect where beautiful design makes users perceive something as more usable. Visually refined UI is perceived as more usable than its actual functionality.

**Implementation Points**:

- Unified color palette (clear definition of primary, secondary, and accent colors)
- Consistent typographic hierarchy (clear differentiation between headings, body text, and captions)
- Appropriate spacing and padding (adoption of minimum 8px grid system)
- Visual consistency of UI elements (unified style for buttons, cards, and forms)

### Hick's Law

**Definition**: The more choices available, the longer it takes to make a decision.

**Implementation Points**:

- Limit primary actions to 3 or fewer
- Use progressive disclosure for complex settings
- Keep menu items to 7±2 as a guideline
- Reduce selection burden by providing default values

### Fitts's Law

**Definition**: The larger and closer a target (like a button) is, the easier it is to reach.

**Implementation Points**:

- Ensure minimum 44x44px tap area for important buttons (Apple guideline recommendation)
- Place frequently used features at the bottom of the screen or within thumb's reach
- Position related operations close together
- Place primary actions at the bottom of the screen on mobile

### Miller's Law

**Definition**: Human short-term memory is limited to 7±2 chunks.

**Implementation Points**:

- Display no more than 5-7 items at once
- Group long lists by category
- Emphasize important information with visual hierarchy
- Show progress indicators for multi-step flows to indicate current position

### Serial Position Effect

**Definition**: Items at the beginning and end of a list are most memorable.

**Implementation Points**:

- Place most important information at the beginning and end
- Put call-to-action items at the end of lists
- Place frequently used features at both ends of navigation menus
- Provide table of contents and summary for long content

### Familiarity Bias

**Definition**: Users prefer familiar patterns.

**Implementation Points**:

- Adopt industry-standard UI patterns (e.g., hamburger menu in top-left)
- Follow platform-specific guidelines (iOS HIG, Material Design)
- Don't change the meaning of common icons
- Reference patterns from existing success cases

### Peak-End Rule

**Definition**: The peak moment and ending of an experience determine overall evaluation.

**Implementation Points**:

- Create a sense of achievement at the end of onboarding
- Use congratulatory messages or animations upon task completion
- Provide positive feedback like "Perfect!" when data sync completes
- Provide motivation for next session when closing the app

---

## Interaction and Feedback

### Doherty Threshold

**Definition**: If system response time is within 0.4 seconds, users don't feel they're waiting.

**Implementation Points**:

- Update UI immediately (adopt optimistic UI updates)
- Execute heavy processing asynchronously and display tentative state immediately
- Show loading states only after 400ms (avoid flashing)
- Display frequently used data immediately with caching strategy

### Labor Illusion

**Definition**: When users can see the processing, they perceive more value.

**Implementation Points**:

- Explicitly display that AI is analyzing ("Analyzing health data..." etc.)
- Visualize progress with progress bars or step indicators
- Show explanations for each step in multi-step processes
- Display specific work content rather than generic "Loading..."

### Immediate Feedback

**Definition**: Responding immediately to user actions enhances sense of control.

**Implementation Points**:

- Visual changes on button tap (:active state styling)
- Real-time validation during form input
- Follow animations for swipe or drag operations
- Haptic feedback on success/error (mobile)

### Microinteractions

**Definition**: Small animations and transitions make the experience more lively.

**Implementation Points**:

- Color change or scale change on button hover (transform: scale(1.05))
- Fade in/out when showing/hiding elements
- Slide-in animation when adding list items
- Checkmark animation on success (duration: 300-500ms)

### Skeleton Screen

**Definition**: Display layout skeleton while content is loading to improve perceived speed.

**Implementation Points**:

- Display placeholders that mimic content shape
- Use shimmer effect to suggest loading
- Maintain same layout structure as actual content
- Progressive rendering of important content first

---

## Information Architecture

### Von Restorff Effect (Isolation Effect)

**Definition**: Elements that differ from their surroundings are more memorable.

**Implementation Points**:

- Use contrasting colors for CTA (Call to Action) buttons
- Highlight important warnings with attention colors like red or yellow
- Use larger font sizes and different font weights for key metrics
- Clarify importance with different visual hierarchy

### Tesler's Law (Law of Conservation of Complexity)

**Definition**: Every system has inherent complexity that, if not reduced, shifts to the user.

**Implementation Points**:

- Automate inputs that can be automated (location, device information, etc.)
- Provide intelligent default values
- Explain complex concepts with step-by-step tutorials
- Hide advanced features for experts while keeping them accessible

### Progressive Disclosure

**Definition**: Disclose information gradually to reduce cognitive load.

**Implementation Points**:

- Display only the most important information initially
- Expand additional information with "Show details"
- Separate basic and advanced settings in settings screens
- Provide supplementary information with tooltips or help icons

### Mere Exposure Effect (Zajonc's Law)

**Definition**: Repeated exposure increases favorability.

**Implementation Points**:

- Create exposure opportunities for important features with regular notifications or reminders
- Divide onboarding into multiple sessions
- Introduce new features gradually
- Use brand elements (logo, colors) consistently

---

## Health & Wellness App-Specific Principles

### Data Transparency and Reliability

**Definition**: Build trust by specifying data sources, calculation logic, and accuracy.

**Implementation Points**:

- Specify data sources ("Retrieved from HealthKit," etc.)
- Briefly explain rationale for recommendations ("From your sleep patterns...")
- Note that analysis is AI-generated and not medical advice
- Display data update frequency and timing

### Privacy-First Design

**Definition**: Health data is the most sensitive personal information. Prioritize privacy protection.

**Implementation Points**:

- Specify purpose and scope of data collection in advance
- Principle of least privilege (request only necessary permissions)
- Explain data storage location and encryption method
- Provide explicit data deletion options

### Positive Reinforcement and Motivation

**Definition**: Health improvement is a long-term commitment. Celebrate small successes and support continuity.

**Implementation Points**:

- Set achievable small goals (streak display)
- Visualize progress (charts, badges, statistics)
- Use positive language ("next step" rather than "room for improvement")
- Encouraging messages even on failure ("Let's try again tomorrow")

### Contextual Recommendations

**Definition**: Appropriate suggestions based on user's current situation and time of day.

**Implementation Points**:

- Change recommendations by time of day (breakfast in morning, sleep at night)
- Suggestions considering weather and location
- Predictions based on past behavior patterns
- Reflect user preferences and constraints (allergies, religion, lifestyle)

### Scientific Evidence and Balance

**Definition**: Reliability is crucial for health information. Avoid excessive claims and provide balanced information.

**Implementation Points**:

- Present sources and evidence for recommendations
- Don't follow extreme claims or trends
- Avoid exaggerated expressions like "this alone will solve it"
- Note individual differences ("Generally... but individual results may vary")

---

## Performance and Response

### Perceived Performance

**Definition**: How fast users perceive it is more important than actual speed.

**Implementation Points**:

- Optimize critical rendering path
- Lazy loading for images
- Display high-priority content first
- Make wait times feel shorter with animations

### Offline Support

**Definition**: Provide experience that doesn't depend on network connection.

**Implementation Points**:

- Utilize local cache
- Clear state display when offline
- Basic features work even offline
- Automatic sync when connection recovers

---

## Accessibility

### WCAG 2.1 Compliance

**Definition**: Follow Web Content Accessibility Guidelines to create UI usable by everyone.

**Implementation Points**:

- Color contrast ratio of 4.5:1 or higher (AA standard)
- All features accessible with keyboard only
- Screen reader support (appropriate ARIA attributes)
- Clear display of focus indicators

### Inclusive Design

**Definition**: Design usable regardless of age, ability, or environment.

**Implementation Points**:

- Minimum font size 16px (14px only for supplementary information)
- Ensure sufficient tap area (44x44px or larger)
- Don't rely on color alone for information (use icons and text too)
- Support dark mode to reduce eye strain

---

## General Implementation Guidelines

### Design System Adoption

- Use unified component libraries like shadcn/ui, Chakra UI, MUI
- Minimize custom colors (brand colors only)
- Consistent spacing system (4px, 8px, 16px, 24px, 32px, 48px, etc.)

### Animation Principles

- Standard duration: 200-300ms, important changes: 400-500ms
- Easing: ease-out (entrance), ease-in (exit), ease-in-out (movement)
- Avoid excessive animation (make user-controllable)

### Error Handling

- Error messages should be specific and suggest solutions
- Explain from user perspective rather than technical details
- Provide alternative methods even when errors occur
- Display form errors inline with real-time feedback

### Copywriting

- Concise and clear expression (avoid jargon)
- Use active voice ("We are retrieving data" rather than "Data being retrieved")
- Use second person addressing the user ("your," "today's")
- Use positive expressions ("retry" rather than "failed")

---

Use this guideline as a reference for UI/UX design decision-making.
You don't need to apply all principles at all times, but keep user-centered design in mind
and refer to these concepts as needed.
