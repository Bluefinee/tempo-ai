# Phase 2 iOS Implementation: Deep Personalization

## Overview

Phase 2 introduces advanced **"6 Focus Areas Hyper-Personalization"** UI system with intelligent multi-tag selection, smart suggestions, and persona-driven user experiences.

## 🔧 実装前必須確認事項

### 📚 参照必須ドキュメント

1. **Swift 標準確認**: [.claude/swift-coding-standards.md](../../.claude/swift-coding-standards.md) - Swift 実装ルール
2. **UX 設計原則**: [.claude/ux_concepts.md](../../.claude/ux_concepts.md) - UX 心理学原則
3. **開発ルール確認**: [CLAUDE.md](../../CLAUDE.md) - 開発哲学、品質基準、プロセス
4. **メッセージングガイドライン**: [.claude/messaging_guidelines.md](../../.claude/messaging_guidelines.md) - 健康アドバイスの表現・トーン指針

## 1. 6 Focus Areas UI Implementation

### A. Focus Areas Selection Interface

**Major Design Change**: Eliminated lifestyle modes (Standard/Athlete) - focus areas now drive all personalization.

```swift
struct FocusAreasSelectionView: View {
    @State private var selectedTags: Set<FocusTag> = []
    
    var body: some View {
        VStack(spacing: 20) {
            header
            focusAreasGrid
            continueButton
        }
        .padding()
    }
    
    private var focusAreasGrid: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 16) {
            ForEach(FocusTag.allCases, id: \.self) { tag in
                FocusAreaCard(
                    tag: tag,
                    isSelected: selectedTags.contains(tag)
                ) {
                    toggleSelection(for: tag)
                }
            }
        }
    }
}

struct FocusAreaCard: View {
    let tag: FocusTag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: tag.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : tag.color)
                
                Text(tag.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(tag.subtitle)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .opacity(0.8)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? tag.color : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

### B. Focus Tag Model Definition

```swift
enum FocusTag: String, CaseIterable, Codable {
    case work = "work"
    case beauty = "beauty"
    case diet = "diet"
    case chill = "chill"
    case athlete = "athlete"
    
    var title: String {
        switch self {
        case .work: return "🧠 Deep Focus"
        case .beauty: return "✨ Beauty & Skin"
        case .diet: return "🥗 Diet & Metabolism"
        case .chill: return "🍃 Chill / Relax"
        case .athlete: return "🏃 Athlete Mode"
        }
    }
    
    var subtitle: String {
        switch self {
        case .work: return "Cognitive optimization"
        case .beauty: return "Skin health & glow"
        case .diet: return "Metabolic wellness"
        case .chill: return "Stress management"
        case .athlete: return "Peak performance"
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "brain.head.profile"
        case .beauty: return "sparkles"
        case .diet: return "leaf"
        case .chill: return "heart.fill"
        case .athlete: return "figure.run"
        }
    }
    
    var color: Color {
        switch self {
        case .work: return .blue
        case .beauty: return .pink
        case .diet: return .green
        case .chill: return .purple
        case .athlete: return .orange
        }
    }
    
    var personaDescription: String {
        switch self {
        case .work: return "Executive Assistant - Cognitive capacity optimization"
        case .beauty: return "Aesthetician Coach - Skin health & beauty enhancement"
        case .diet: return "Nutrition Expert - Metabolic wellness guidance"
        case .chill: return "Nervous System Expert - Stress management & relaxation"
        case .athlete: return "Sports Science Coach - Performance optimization"
        }
    }
}
```

## 2. Smart Suggestion Cards Implementation

### A. Contextual Mini-Cards

Insert contextual suggestions below the Battery _only when relevant_.

```swift
struct SmartSuggestionCard: View {
    let suggestion: SmartSuggestion
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: suggestion.icon)
                .foregroundColor(suggestion.urgencyColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(suggestion.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Button("Try") {
                suggestion.action?()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(suggestion.backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(suggestion.urgencyColor.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SmartSuggestion {
    let title: String
    let message: String
    let icon: String
    let urgency: SuggestionUrgency
    let action: (() -> Void)?
    
    var urgencyColor: Color {
        switch urgency {
        case .info: return .blue
        case .warning: return .orange
        case .critical: return .red
        }
    }
    
    var backgroundColor: Color {
        urgencyColor.opacity(0.1)
    }
}

enum SuggestionUrgency {
    case info, warning, critical
}
```

### B. Context-Aware Suggestion Logic

```swift
class SmartSuggestionEngine: ObservableObject {
    @Published var currentSuggestions: [SmartSuggestion] = []
    
    func generateSuggestions(
        for tags: Set<FocusTag>,
        with healthData: HealthData,
        and environmentalData: EnvironmentalData
    ) {
        var suggestions: [SmartSuggestion] = []
        
        // Work Tag + Low Pressure (Weather)
        if tags.contains(.work) && environmentalData.pressureTrend < -5 {
            suggestions.append(SmartSuggestion(
                title: "Headache Risk",
                message: "Focus on tasks now before pressure drops further",
                icon: "brain.head.profile",
                urgency: .warning,
                action: { /* Navigate to work optimization */ }
            ))
        }
        
        // Beauty Tag + Low Humidity (Weather)
        if tags.contains(.beauty) && environmentalData.humidity < 40 {
            suggestions.append(SmartSuggestion(
                title: "Dry Skin Alert",
                message: "Hydrate more than usual today",
                icon: "drop.fill",
                urgency: .info,
                action: { /* Navigate to hydration tracking */ }
            ))
        }
        
        // Chill Tag + Stress Detection
        if tags.contains(.chill) && healthData.hrvDrop > 15 {
            suggestions.append(SmartSuggestion(
                title: "Stress Detected",
                message: "2-minute breathing exercise recommended",
                icon: "heart.fill",
                urgency: .critical,
                action: { /* Start breathing exercise */ }
            ))
        }
        
        // Athlete Tag + HRV Analysis
        if tags.contains(.athlete) {
            if healthData.hrvTrend > 10 {
                suggestions.append(SmartSuggestion(
                    title: "Performance Window",
                    message: "Your body is ready for intensity today",
                    icon: "figure.run",
                    urgency: .info,
                    action: { /* Navigate to workout planning */ }
                ))
            } else if healthData.hrvTrend < -10 {
                suggestions.append(SmartSuggestion(
                    title: "Recovery Priority",
                    message: "Active recovery only - trust your body",
                    icon: "bed.double.fill",
                    urgency: .warning,
                    action: { /* Navigate to recovery activities */ }
                ))
            }
        }
        
        currentSuggestions = suggestions
    }
}
```

## 3. Detail View Customization

### A. Tag-Based Content Customization

Customize the `DetailView` content based on active tags.

```swift
struct EnhancedDetailView: View {
    let metric: HealthMetric
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        VStack(spacing: 20) {
            metricHeader
            customizedContent
            actionRecommendations
        }
        .padding()
    }
    
    @ViewBuilder
    private var customizedContent: some View {
        switch metric.type {
        case .sleep:
            SleepDetailContent(
                sleepData: metric.sleepData,
                activeTags: userPreferences.activeTags
            )
        case .vitals:
            VitalsDetailContent(
                vitalsData: metric.vitalsData,
                activeTags: userPreferences.activeTags
            )
        case .activity:
            ActivityDetailContent(
                activityData: metric.activityData,
                activeTags: userPreferences.activeTags
            )
        }
    }
}

struct SleepDetailContent: View {
    let sleepData: SleepData
    let activeTags: Set<FocusTag>
    
    var body: some View {
        VStack(spacing: 16) {
            // Base sleep metrics
            baseSleepMetrics
            
            // Tag-specific insights
            if activeTags.contains(.beauty) {
                beautyFocusedSleepInsights
            }
            
            if activeTags.contains(.work) {
                workFocusedSleepInsights
            }
            
            if activeTags.contains(.athlete) {
                athleteFocusedSleepInsights
            }
            
            if activeTags.contains(.chill) {
                chillFocusedSleepInsights
            }
        }
    }
    
    private var beautyFocusedSleepInsights: some View {
        InsightCard(
            title: "Skin Repair Time",
            value: "\(sleepData.deepSleepMinutes) min",
            insight: "Deep sleep drives growth hormone production for cellular repair",
            color: .pink,
            icon: "sparkles"
        )
    }
    
    private var workFocusedSleepInsights: some View {
        InsightCard(
            title: "Mental Restoration",
            value: "\(sleepData.remSleepMinutes) min",
            insight: "REM sleep consolidates memories and clears mental fatigue",
            color: .blue,
            icon: "brain.head.profile"
        )
    }
    
    private var athleteFocusedSleepInsights: some View {
        InsightCard(
            title: "Recovery Quality",
            value: sleepData.recoveryScore.formatted(.percent),
            insight: "Sleep efficiency determines training adaptation capacity",
            color: .orange,
            icon: "figure.run"
        )
    }
    
    private var chillFocusedSleepInsights: some View {
        InsightCard(
            title: "Nervous System Reset",
            value: sleepData.sleepQuality.formatted(.percent),
            insight: "Quality sleep balances autonomic nervous system",
            color: .purple,
            icon: "heart.fill"
        )
    }
}

struct VitalsDetailContent: View {
    let vitalsData: VitalsData
    let activeTags: Set<FocusTag>
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 16) {
            // Always show core vitals
            coreVitalsCards
            
            // Highlight tag-specific vitals
            if activeTags.contains(.diet) {
                highlightedVitalCard(
                    title: "Active Calories",
                    value: "\(vitalsData.activeCalories)",
                    color: .green,
                    icon: "flame"
                )
            }
            
            if activeTags.contains(.chill) {
                highlightedVitalCard(
                    title: "HRV",
                    value: "\(vitalsData.hrv) ms",
                    color: .purple,
                    icon: "heart.fill"
                )
            }
            
            if activeTags.contains(.athlete) {
                highlightedVitalCard(
                    title: "Training Load",
                    value: vitalsData.trainingLoad.formatted(.percent),
                    color: .orange,
                    icon: "figure.run"
                )
            }
        }
    }
}
```

## 4. Monday Weekly Analysis Display

### A. Weekly Insight View

```swift
struct WeeklyAnalysisView: View {
    let analysis: WeeklyAnalysis
    @State private var showingFullAnalysis = false
    
    var body: some View {
        VStack(spacing: 20) {
            weeklyHeader
            personalizedMessage
            weeklyTryCard
            culturalWisdomCard
            progressInsights
        }
        .padding()
        .background(Color(.systemGray6))
        .sheet(isPresented: $showingFullAnalysis) {
            FullWeeklyAnalysisView(analysis: analysis)
        }
    }
    
    private var personalizedMessage: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今週への温かいメッセージ")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(analysis.personalizedMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 2)
        )
    }
    
    private var weeklyTryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("今週のトライ")
                    .font(.headline)
            }
            
            Text(analysis.weeklyTryRecommendation)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            Button("詳細を見る") {
                showingFullAnalysis = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    private var culturalWisdomCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                Text("東洋の知恵")
                    .font(.headline)
            }
            
            Text(analysis.culturalWisdom)
                .font(.body)
                .multilineTextAlignment(.leading)
                .italic()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
        )
    }
}
```

### B. Monday Morning Notification System

```swift
class WeeklyAnalysisNotificationManager: ObservableObject {
    func scheduleWeeklyAnalysisNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "今週の健康サポート"
        content.body = "新しい週次分析と個人的なトライ提案をご確認ください"
        content.sound = .default
        
        // Schedule for every Monday at 8:00 AM
        var dateComponents = DateComponents()
        dateComponents.weekday = 2 // Monday
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "weekly_analysis",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
```

## 5. Tag Persona Display System

### A. Persona-Driven UI Adaptation

```swift
class PersonaUIManager: ObservableObject {
    @Published var currentPersona: UIPersona?
    
    func updatePersona(for tags: Set<FocusTag>) {
        currentPersona = generateUnifiedPersona(for: tags)
    }
    
    private func generateUnifiedPersona(for tags: Set<FocusTag>) -> UIPersona {
        switch tags {
        case let tags where tags.contains(.work) && tags.contains(.beauty):
            return UIPersona(
                name: "High-Performance Wellness Expert",
                greeting: "今日も美しく、賢く。",
                primaryColor: .blue,
                accentColor: .pink,
                icon: "brain.head.profile"
            )
            
        case let tags where tags.contains(.work) && tags.contains(.chill):
            return UIPersona(
                name: "Mindful Performance Expert",
                greeting: "冷静さが最高のパフォーマンスを生む。",
                primaryColor: .blue,
                accentColor: .purple,
                icon: "heart.fill"
            )
            
        case let tags where tags.contains(.beauty) && tags.contains(.chill):
            return UIPersona(
                name: "Holistic Wellness Sage",
                greeting: "内なる平和が真の美しさを輝かせる。",
                primaryColor: .pink,
                accentColor: .purple,
                icon: "sparkles"
            )
            
        default:
            return UIPersona(
                name: "Personal Health Guide",
                greeting: "今日も健やかに。",
                primaryColor: .blue,
                accentColor: .green,
                icon: "heart.fill"
            )
        }
    }
}

struct UIPersona {
    let name: String
    let greeting: String
    let primaryColor: Color
    let accentColor: Color
    let icon: String
    
    var gradientColors: [Color] {
        [primaryColor, accentColor]
    }
}
```

### B. Adaptive Main View Header

```swift
struct PersonaAwareHeader: View {
    @EnvironmentObject var personaManager: PersonaUIManager
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let persona = personaManager.currentPersona {
                HStack {
                    Image(systemName: persona.icon)
                        .foregroundColor(.white)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text(persona.greeting)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(persona.name)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: persona.gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(16)
                )
            }
            
            activeTagsDisplay
        }
    }
    
    private var activeTagsDisplay: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(userPreferences.activeTags), id: \.self) { tag in
                    TagChip(tag: tag)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct TagChip: View {
    let tag: FocusTag
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: tag.icon)
                .font(.caption)
            Text(tag.title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tag.color.opacity(0.2))
        .foregroundColor(tag.color)
        .cornerRadius(8)
    }
}
```

## 6. Environmental Insights UI

### A. Environmental Impact Cards

```swift
struct EnvironmentalInsightsSection: View {
    let insights: [EnvironmentalInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "環境要因の影響", icon: "cloud.sun.fill")
            
            ForEach(insights, id: \.factor) { insight in
                EnvironmentalInsightCard(insight: insight)
            }
        }
    }
}

struct EnvironmentalInsightCard: View {
    let insight: EnvironmentalInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: insight.factor.icon)
                    .foregroundColor(insight.factor.color)
                
                Text(insight.factor.displayName)
                    .font(.headline)
                
                Spacer()
                
                ConfidenceBadge(confidence: insight.confidence)
            }
            
            Text(insight.impact)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(insight.recommendation)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(insight.factor.color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(insight.factor.color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ConfidenceBadge: View {
    let confidence: Double
    
    var body: some View {
        Text("\(Int(confidence * 100))%")
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(confidenceColor.opacity(0.2))
            .foregroundColor(confidenceColor)
            .cornerRadius(4)
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case 0.8...: return .green
        case 0.6..<0.8: return .orange
        default: return .red
        }
    }
}

extension EnvironmentalFactor {
    var icon: String {
        switch self {
        case .pressure: return "barometer"
        case .humidity: return "humidity.fill"
        case .temperature: return "thermometer"
        case .uv: return "sun.max.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .pressure: return .blue
        case .humidity: return .cyan
        case .temperature: return .orange
        case .uv: return .yellow
        }
    }
    
    var displayName: String {
        switch self {
        case .pressure: return "気圧"
        case .humidity: return "湿度"
        case .temperature: return "気温"
        case .uv: return "紫外線"
        }
    }
}
```

## 7. Chill Tag Integration UI

### A. Micro-Intervention Overlay

```swift
struct ChillInterventionOverlay: View {
    @StateObject private var chillManager = ChillInterventionManager()
    @State private var showingBreathingExercise = false
    
    var body: some View {
        ZStack {
            if chillManager.showStressAlert {
                stressInterventionCard
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showingBreathingExercise) {
            BreathingExerciseView()
        }
    }
    
    private var stressInterventionCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("ストレス検出")
                    .font(.headline)
                Spacer()
                Button("×") {
                    chillManager.dismissAlert()
                }
            }
            
            Text("自律神経の乱れを感知しました。2分間のリセットをお試しください。")
                .font(.body)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button("呼吸法") {
                    showingBreathingExercise = true
                }
                .buttonStyle(.borderedProminent)
                
                Button("後で") {
                    chillManager.snoozeAlert()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 10)
        )
        .padding()
    }
}

class ChillInterventionManager: ObservableObject {
    @Published var showStressAlert = false
    
    func checkForStressSignals(_ healthData: HealthData) {
        // Check for HRV drops, elevated heart rate, etc.
        if healthData.hrvDrop > 15 || healthData.stressLevel > 0.7 {
            showStressAlert = true
        }
    }
    
    func dismissAlert() {
        withAnimation {
            showStressAlert = false
        }
    }
    
    func snoozeAlert() {
        showStressAlert = false
        // Schedule to check again in 30 minutes
    }
}
```

## 8. Implementation Priority

### Phase 2.1: Core UI Infrastructure
1. FocusAreasSelectionView and tag model
2. Basic tag-based content customization
3. SmartSuggestionCard implementation

### Phase 2.2: Enhanced Personalization
1. PersonaUIManager and adaptive headers
2. Detail view customization logic
3. Environmental insights display

### Phase 2.3: Weekly Analysis UI
1. WeeklyAnalysisView implementation
2. Monday notification system
3. Cultural wisdom integration

### Phase 2.4: Advanced Interactions
1. Chill tag micro-interventions
2. Advanced persona synthesis
3. Performance optimizations

## Testing Requirements

- Unit tests for tag selection logic
- UI tests for multi-tag combinations
- Integration tests with backend API
- Accessibility testing for all new components
- Performance testing for real-time updates

## Dependencies

- Enhanced backend API responses
- Real-time health data updates
- Environmental data integration
- Notification permissions and scheduling
- Proper localization support

## UI/UX Considerations

- Smooth transitions between tag selections
- Clear visual hierarchy for persona-driven content
- Gentle, non-intrusive micro-interventions
- Accessibility compliance for all new features
- Consistent design language with existing app