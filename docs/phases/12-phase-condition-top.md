# Phase 12: コンディショントップ設計書

**フェーズ**: 12 / 15  
**Part**: D（コンディション画面）  
**前提フェーズ**: Phase 10（Backend調整）、Phase 11（タブバー拡張）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料
- **[Product Spec v4.2](../product-spec.md)** - プロダクト仕様書（新仕様）セクション3
- **[UI Spec v3.2](../ui-spec.md)** - UI設計仕様書セクション7
- **[Metrics Spec v3.0](../metrics-spec.md)** - メトリクス仕様書

### 🔧 iOS専用資料
- **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift開発標準
- **[UX Concepts & Principles](../../.claude/ux_concepts.md)** - UX設計原則

### ✅ 実装完了後の必須作業
```bash
swiftlint
swift-format --lint --recursive ios/
swift test
```

---

## このフェーズで実現すること

Phase 11で作成したプレースホルダーを置き換え、新設計のコンディション画面を実装します。

**実装する要素**:
1. 24時間サークル図 + HRV統合表示
2. リズム安定度表示
3. 要因マップ（睡眠・環境・活動）
4. AIの見立て
5. 「詳しく見る」ボタン

---

## 完了条件

- [ ] 24時間サークル図が正しく描画される
- [ ] HRV値と7日平均との差分が中央に表示される
- [ ] リズム安定度が条件分岐で正しく表示される
- [ ] 要因マップの3要因（睡眠・環境・活動）が表示される
- [ ] 各要因の貢献度が正しく算出・表示される
- [ ] AIの見立て（condition_insight）が表示される
- [ ] 「詳しく見る」から詳細画面への遷移が動作する

---

## 画面構成

```
┌─────────────────────────────────────┐
│ コンディション                       │
├─────────────────────────────────────┤
│    ┌─────────────────────────┐     │
│    │   [24時間サークル図]      │     │
│    │      HRV 72ms           │     │
│    │      ▲+9%               │     │
│    │   就寝 23:15 / 起床 7:05 │     │
│    └─────────────────────────┘     │
│                                     │
│    リズム安定度                      │
│    ●●●○○ 良好                      │
│    「3日連続で安定 → 回復効率アップ中」 │
├─────────────────────────────────────┤
│    要因マップ                        │
│    睡眠 ████████░░ 回復に貢献        │
│    環境 ██░░░░░░░░ やや負荷あり      │
│    活動 █████░░░░░ 影響少なめ        │
├─────────────────────────────────────┤
│    今日の見立て                      │
│    マサさん、今朝の自律神経の...      │
├─────────────────────────────────────┤
│         [詳しく見る >]               │
└─────────────────────────────────────┘
```

---

## 1. 24時間サークル図 + HRV統合表示

### データ構造

```swift
struct CircadianCircleData {
    let sleepRecords: [SleepRecord]  // 過去7日間
    let todaySleep: SleepRecord?
    let hrv: HRVData
}

struct SleepRecord {
    let date: Date
    let bedtime: Date
    let wakeTime: Date
    var durationHours: Double { ... }
    var deepSleepMinutes: Int { ... }
}

struct HRVData {
    let currentValue: Double
    let sevenDayAverage: Double
    
    var differencePercent: Double {
        guard sevenDayAverage > 0 else { return 0 }
        return ((currentValue - sevenDayAverage) / sevenDayAverage) * 100
    }
    
    var differenceText: String {
        let diff = differencePercent
        return diff >= 0 ? "▲+\(Int(diff))%" : "▼\(Int(diff))%"
    }
}
```

### サークル描画

```swift
struct CircadianCircleView: View {
    let data: CircadianCircleData
    private let circleSize: CGFloat = 240
    
    var body: some View {
        ZStack {
            // 外周円
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 2)
            
            // 時刻目盛り（0:00, 6:00, 12:00, 18:00）
            TimeMarkers()
            
            // 過去7日間のドット
            ForEach(data.sleepRecords.indices, id: \.self) { index in
                let record = data.sleepRecords[index]
                let isToday = index == data.sleepRecords.count - 1
                
                Circle()
                    .fill(isToday ? Color.primary : Color.primary.opacity(0.4))
                    .frame(width: isToday ? 10 : 6)
                    .offset(offsetForTime(record.bedtime))
                
                Circle()
                    .fill(isToday ? Color.primary : Color.primary.opacity(0.4))
                    .frame(width: isToday ? 10 : 6)
                    .offset(offsetForTime(record.wakeTime))
            }
            
            // 昨夜の睡眠帯
            if let todaySleep = data.todaySleep {
                SleepArc(bedtime: todaySleep.bedtime, wakeTime: todaySleep.wakeTime)
                    .fill(Color.primary.opacity(0.2))
            }
            
            // 中央のHRV
            VStack(spacing: 4) {
                Text("\(Int(data.hrv.currentValue))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                Text("ms")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(data.hrv.differenceText)
                    .font(.subheadline)
                    .foregroundColor(data.hrv.differencePercent >= 0 ? .green : .orange)
            }
        }
        .frame(width: circleSize, height: circleSize)
    }
    
    private func offsetForTime(_ date: Date) -> CGSize {
        let angle = angleForTime(date) * .pi / 180.0
        let radius = circleSize / 2 - 20
        return CGSize(width: cos(angle) * radius, height: sin(angle) * radius)
    }
    
    private func angleForTime(_ date: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let totalMinutes = Double(hour * 60 + minute)
        return (totalMinutes / 1440.0) * 360.0 - 90.0
    }
}
```

---

## 2. リズム安定度表示

### ロジック

```swift
struct RhythmStability {
    let rhythmScore: Int
    let consecutiveStableDays: Int
    
    enum Status: String {
        case good = "良好"
        case slightlyUnstable = "やや不安定"
        case unstable = "不安定"
    }
    
    var status: Status {
        rhythmScore >= 70 ? .good : rhythmScore >= 50 ? .slightlyUnstable : .unstable
    }
    
    var indicatorLevel: Int {
        switch rhythmScore {
        case 80...: return 5
        case 70..<80: return 4
        case 60..<70: return 3
        case 50..<60: return 2
        default: return 1
        }
    }
    
    var description: String {
        switch status {
        case .good:
            return consecutiveStableDays >= 3 
                ? "\(consecutiveStableDays)日連続で安定 → 回復効率アップ中"
                : "リズムが整っています"
        case .slightlyUnstable:
            return "就寝時刻にばらつきがあります"
        case .unstable:
            return "リズムの乱れが回復を妨げています"
        }
    }
}
```

### UIコンポーネント

```swift
struct RhythmStabilityView: View {
    let stability: RhythmStability
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("リズム安定度")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                // 5段階インジケーター
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { level in
                        Circle()
                            .fill(level <= stability.indicatorLevel 
                                  ? statusColor : Color.secondary.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(stability.status.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
            }
            
            Text(stability.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch stability.status {
        case .good: return .green
        case .slightlyUnstable: return .yellow
        case .unstable: return .orange
        }
    }
}
```

---

## 3. 要因マップ

### データ構造

```swift
struct Factor {
    let type: FactorType
    let contribution: ContributionLevel
    let detail: String
    
    enum FactorType {
        case sleep, environment, activity
        
        var icon: String {
            switch self {
            case .sleep: return "moon.zzz.fill"
            case .environment: return "cloud.sun.fill"
            case .activity: return "figure.walk"
            }
        }
        
        var label: String {
            switch self {
            case .sleep: return "睡眠"
            case .environment: return "環境"
            case .activity: return "活動"
            }
        }
    }
}

enum ContributionLevel: String, Codable {
    case highPositive, positive, neutral, negative, highNegative
    
    var displayText: String {
        switch self {
        case .highPositive: return "回復に大きく貢献"
        case .positive: return "回復に貢献"
        case .neutral: return "影響少なめ"
        case .negative: return "やや負荷あり"
        case .highNegative: return "負荷あり"
        }
    }
    
    var progress: Double {
        switch self {
        case .highPositive: return 0.9
        case .positive: return 0.7
        case .neutral: return 0.5
        case .negative: return 0.3
        case .highNegative: return 0.15
        }
    }
}
```

### UIコンポーネント

```swift
struct FactorMapView: View {
    let factors: [Factor]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("要因マップ")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(factors, id: \.type) { factor in
                FactorRowView(factor: factor)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct FactorRowView: View {
    let factor: Factor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: factor.type.icon)
                    .font(.system(size: 14))
                Text(factor.type.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(factor.contribution.displayText)
                    .font(.caption)
                    .foregroundColor(factor.contribution.color)
            }
            
            // プログレスバー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.1))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(factor.contribution.color)
                        .frame(width: geometry.size.width * factor.contribution.progress)
                }
            }
            .frame(height: 8)
            
            Text(factor.detail)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
```

---

## 4. AIの見立て

```swift
struct InsightView: View {
    let insight: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.primary)
                Text("今日の見立て")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(insight)
                .font(.body)
                .lineSpacing(6)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
```

---

## 5. 貢献度算出ロジック

### 睡眠

```swift
struct SleepContributionCalculator {
    static func calculate(sleepHours: Double, deepSleepMinutes: Int, avg7dSleepHours: Double) -> (level: ContributionLevel, detail: String) {
        let sleepDelta = (sleepHours - avg7dSleepHours) / avg7dSleepHours
        
        let level: ContributionLevel
        if sleepHours >= 7 && sleepDelta >= 0.1 { level = .highPositive }
        else if sleepHours >= 7 { level = .positive }
        else if sleepHours >= 6 { level = .neutral }
        else if sleepHours >= 5 { level = .negative }
        else { level = .highNegative }
        
        let detail = String(format: "%.1fh / 深い睡眠 %.1fh", sleepHours, Double(deepSleepMinutes) / 60.0)
        return (level, detail)
    }
}
```

### 環境

```swift
struct EnvironmentContributionCalculator {
    static func calculate(pressureHpa: Int, pressureChange6h: Int, tempC: Int) -> (level: ContributionLevel, detail: String) {
        let absChange = abs(pressureChange6h)
        
        let level: ContributionLevel
        if absChange <= 3 && pressureHpa >= 1010 && pressureHpa <= 1025 { level = .positive }
        else if absChange <= 5 { level = .neutral }
        else if absChange <= 10 { level = .negative }
        else { level = .highNegative }
        
        let detail: String
        if pressureChange6h < -5 { detail = "午後から低気圧 (\(pressureHpa)hPa)" }
        else { detail = "晴れ \(tempC)°C / 気圧安定" }
        
        return (level, detail)
    }
}
```

### 活動

```swift
struct ActivityContributionCalculator {
    static func calculate(stepsYesterday: Int, avg7dSteps: Int, activeMinutes: Int) -> (level: ContributionLevel, detail: String) {
        let stepRatio = Double(stepsYesterday) / Double(avg7dSteps)
        
        let level: ContributionLevel
        if stepRatio >= 0.8 && stepRatio <= 1.3 && activeMinutes >= 20 { level = .positive }
        else if stepRatio >= 0.5 && stepRatio <= 1.5 { level = .neutral }
        else { level = .negative }
        
        let detail: String
        if stepsYesterday >= 8000 { detail = "昨日 \(stepsYesterday.formatted())歩 / 活動的な1日" }
        else if stepsYesterday >= 5000 { detail = "昨日 \(stepsYesterday.formatted())歩 / 適度な活動" }
        else { detail = "昨日 \(stepsYesterday.formatted())歩 / 軽めの1日" }
        
        return (level, detail)
    }
}
```

---

## 6. ViewModel

```swift
@MainActor
final class ConditionViewModel: ObservableObject {
    @Published var circadianData: CircadianCircleData?
    @Published var rhythmStability: RhythmStability?
    @Published var factors: [Factor] = []
    @Published var conditionInsight: String?
    @Published var isLoading = false
    
    private let healthKitManager = HealthKitManager.shared
    private let cacheManager = CacheManager.shared
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let sleepRecords = try await healthKitManager.fetchSleepRecords(days: 7)
            let hrvData = try await healthKitManager.fetchHRVData()
            let activityData = try await healthKitManager.fetchActivityData()
            
            circadianData = CircadianCircleData(
                sleepRecords: sleepRecords,
                todaySleep: sleepRecords.last,
                hrv: hrvData
            )
            
            rhythmStability = calculateRhythmStability(sleepRecords: sleepRecords)
            factors = await buildFactors(sleep: sleepRecords, activity: activityData)
            
            if let cachedAdvice = cacheManager.loadAdvice(for: Date()) {
                conditionInsight = cachedAdvice.conditionInsight
            }
        } catch {
            print("Error loading condition data: \(error)")
        }
    }
}
```

---

## ディレクトリ構造

```
ios/TempoAI/Features/Condition/
├── Views/
│   ├── ConditionView.swift
│   ├── CircadianCircleView.swift
│   ├── RhythmStabilityView.swift
│   ├── FactorMapView.swift
│   └── InsightView.swift
├── ViewModels/
│   └── ConditionViewModel.swift
└── Models/
    ├── CircadianCircleData.swift
    ├── RhythmStability.swift
    └── Factor.swift

ios/TempoAI/Services/Calculators/
├── RhythmScoreCalculator.swift
├── SleepContributionCalculator.swift
├── EnvironmentContributionCalculator.swift
└── ActivityContributionCalculator.swift
```

---

## 関連ドキュメント

- `ui-spec.md` - セクション7「コンディション画面」
- `product-spec.md` - セクション3「コンディション画面」
- `metrics-spec.md` - セクション3, 9

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-19 | 初版作成 |
