# Phase 5.5: コンディション詳細画面 UI 設計書

**フェーズ**: 5.5 / 17  
**Part**: A（iOS UI）  
**前提フェーズ**: Phase 5（コンディショントップ画面）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料

- **[CLAUDE.md](../../CLAUDE.md)** - 開発ガイドライン・基本原則
- **[AI Prompt Design](../ai-prompt-design.md)** - AI 設計指針
- **[UI Specification](../ui-spec.md)** - UI 設計仕様書
- **[Technical Specification](../technical-spec.md)** - 技術仕様書
- **[Travel Mode & Condition Spec](../travel-mode-condition-spec.md)** - コンディション画面詳細仕様

### 📱 Swift/iOS 専用資料

- **[UX Concepts & Principles](../../.claude/ux_concepts.md)** - UX 設計原則
- **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift 開発標準

### ✅ 実装完了後の必須作業

実装完了後は必ず以下を実行してください：

```bash
# リント・フォーマット確認
swiftlint
swift-format --lint --recursive ios/

# テスト実行
swift test
```

---

## このフェーズで実現すること

1. **サーカディアンリズム詳細画面**
2. **HRV 詳細画面**
3. **睡眠詳細画面**
4. **活動量詳細画面**
5. **環境詳細画面**
6. **リズム安定度スコア算出ロジック**
7. **ヒントの条件分岐ロジック**
8. **週間トレンドグラフ共通コンポーネント**

---

## 完了条件

- [ ] コンディショントップから各詳細画面へ遷移できる
- [ ] サーカディアンリズム詳細で 24 時間サークル図が表示される
- [ ] リズム安定度スコアが正しく算出・表示される
- [ ] 条件に応じたヒントが表示される
- [ ] 各詳細画面で週間トレンドグラフが表示される
- [ ] 睡眠詳細で睡眠ステージバーが表示される
- [ ] 環境詳細で大気質情報が表示される
- [ ] 全画面で Mock データが正しく表示される

---

## 画面一覧

| 画面                     | 遷移元           | 主なデータソース   |
| ------------------------ | ---------------- | ------------------ |
| サーカディアンリズム詳細 | リズムセクション | 就寝・起床時刻     |
| HRV 詳細                 | HRV セクション   | HRV、安静時心拍数  |
| 睡眠詳細                 | 睡眠セクション   | 睡眠データ         |
| 活動量詳細               | 活動量セクション | 歩数、運動データ   |
| 環境詳細                 | 環境セクション   | 天気、大気質データ |

---

## 1. サーカディアンリズム詳細画面

### 画面構成

```
┌─────────────────────────────────────────┐
│ ← サーカディアンリズム                   │
├─────────────────────────────────────────┤
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │         [24時間サークル図]          │ │
│ │                                     │ │
│ │   昨夜の就寝 ●━━━━━━━● 今朝の起床   │ │
│ │      23:15           7:05          │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 📊 週間トレンド                         │
│                                         │
│ 就寝時刻                                │
│ ┌─────────────────────────────────────┐ │
│ │ 1:00 ─                              │ │
│ │ 0:00 ─      ·                       │ │
│ │23:00 ─ ·  ·    ·  ·  ·  ·          │ │
│ │22:00 ─                              │ │
│ │       月 火 水 木 金 土 日           │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 起床時刻                                │
│ ┌─────────────────────────────────────┐ │
│ │ 9:00 ─            ·                 │ │
│ │ 8:00 ─                  ·           │ │
│ │ 7:00 ─ ·  ·  ·  ·        ·          │ │
│ │ 6:00 ─                              │ │
│ │       月 火 水 木 金 土 日           │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 📈 リズム安定度                         │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ ████████████████░░░░  82/100        │ │
│ │                                     │ │
│ │ 安定 ✓                              │ │
│ │ 就寝・起床時刻が比較的揃っています   │ │
│ │                                     │ │
│ │ 内訳：                              │ │
│ │ • 就寝のばらつき: 32分（小）        │ │
│ │ • 起床のばらつき: 18分（小）        │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 💡 リズムを整えるヒント                 │
│                                         │
│ • 週末も平日と同じ時間（7:00頃）に      │
│   起きることで、リズムが安定します      │
│                                         │
│ • 朝の光を浴びる（起床後30分以内）      │
│   体内時計のリセットに最も効果的です    │
│                                         │
│ • 就寝2時間前からブルーライトを減らす   │
│                                         │
└─────────────────────────────────────────┘
```

### リズム安定度スコアの算出

```swift
// RhythmCalculator.swift

struct RhythmCalculator {

    /// リズム安定度スコアを算出
    /// - Parameters:
    ///   - bedtimeStdDev: 就寝時刻の標準偏差（分）
    ///   - wakeTimeStdDev: 起床時刻の標準偏差（分）
    /// - Returns: 0-100のスコア
    static func calculateStabilityScore(
        bedtimeStdDev: Double,
        wakeTimeStdDev: Double
    ) -> Int {
        // 係数（就寝の方を重視）
        let bedtimeCoefficient = 2.5
        let wakeTimeCoefficient = 2.0

        // 分→時間に変換
        let bedtimeHours = bedtimeStdDev / 60.0
        let wakeTimeHours = wakeTimeStdDev / 60.0

        // スコア算出
        let score = 100.0
            - (bedtimeHours * bedtimeCoefficient * 10)
            - (wakeTimeHours * wakeTimeCoefficient * 10)

        return max(0, min(100, Int(score.rounded())))
    }

    /// スコアからステータスを取得
    static func getStatus(score: Int) -> StabilityStatus {
        switch score {
        case 90...100: return .veryStable
        case 75..<90:  return .stable
        case 60..<75:  return .unstable
        default:       return .veryUnstable
        }
    }
}

enum StabilityStatus {
    case veryStable    // 90-100
    case stable        // 75-89
    case unstable      // 60-74
    case veryUnstable  // 0-59

    var displayText: String {
        switch self {
        case .veryStable:   return "非常に安定 ✓✓"
        case .stable:       return "安定 ✓"
        case .unstable:     return "やや不安定 △"
        case .veryUnstable: return "不安定 ▽"
        }
    }
}
```

**計算例**:

```
就寝時刻の標準偏差: 30分（0.5時間）
起床時刻の標準偏差: 20分（0.33時間）

スコア = 100 - (0.5 × 2.5 × 10) - (0.33 × 2.0 × 10)
      = 100 - 12.5 - 6.6
      = 80.9 ≒ 81
```

### ヒントの条件分岐ロジック

```swift
// HintGenerator.swift

struct HintGenerator {

    /// リズムに応じたヒントを生成
    static func generateRhythmHints(
        avgBedtime: String,        // "23:15" 形式
        bedtimeStdDev: Double,     // 分
        wakeTimeStdDev: Double,    // 分
        stabilityScore: Int
    ) -> [String] {
        var hints: [String] = []

        // 就寝時刻が遅い場合（24:00以降）
        if isLateNightBedtime(avgBedtime) {
            hints.append("就寝を毎日15-30分ずつ早めてみましょう")
            hints.append("21時以降はブルーライトを減らしましょう")
        }

        // 起床時刻のばらつきが大きい（標準偏差 > 60分）
        if wakeTimeStdDev > 60 {
            hints.append("週末も平日と同じ時間に起きることが大切です")
            hints.append("目覚ましを固定時刻にセットしましょう")
        }

        // 就寝時刻のばらつきが大きい（標準偏差 > 60分）
        if bedtimeStdDev > 60 {
            hints.append("就寝前のルーティンを作りましょう")
            hints.append("寝る1時間前から同じ行動を繰り返すと、体が眠りの準備を始めます")
        }

        // リズムが安定している場合
        if stabilityScore > 85 {
            hints.append("素晴らしいリズムです。この調子を維持しましょう")
            hints.append("朝の光を浴びる習慣を続けてください")
        }

        // デフォルトヒント（条件に関係なく表示）
        let defaultHints = [
            "朝の光を浴びる（起床後30分以内）",
            "就寝2時間前からブルーライトを減らす"
        ]

        // ヒントが少ない場合はデフォルトを追加
        if hints.count < 2 {
            hints.append(contentsOf: defaultHints)
        }

        // 最大3つまで
        return Array(hints.prefix(3))
    }

    private static func isLateNightBedtime(_ time: String) -> Bool {
        // "0:30" や "1:15" などを深夜と判定
        guard let hour = Int(time.split(separator: ":").first ?? "0") else {
            return false
        }
        return hour >= 0 && hour < 5
    }
}
```

---

## 2. HRV 詳細画面

### 画面構成

```
┌─────────────────────────────────────────┐
│ ← HRV                                   │
├─────────────────────────────────────────┤
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │            💚                       │ │
│ │                                     │ │
│ │           65 ms                     │ │
│ │        （今朝の値）                 │ │
│ │                                     │ │
│ │    7日平均 63ms との差: +2ms        │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 📊 週間トレンド                         │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 80 ─                                │ │
│ │ 70 ─      ╭─╮                       │ │
│ │ 60 ─ ╭─╮╯   ╰─╮   ╭─╮              │ │
│ │ 50 ─╯           ╰─╯   ╰─           │ │
│ │ 40 ─                                │ │
│ │     月 火 水 木 金 土 日             │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 📋 詳細データ                           │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 今朝のHRV           65 ms          │ │
│ │ 7日平均             63 ms          │ │
│ │ 30日平均            61 ms          │ │
│ │ ───────────────────────────────── │ │
│ │ 安静時心拍数（今朝） 52 bpm        │ │
│ │ 安静時心拍数（7日平均）54 bpm      │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ ℹ️ HRVについて                          │
│                                         │
│ HRV（心拍変動）は自律神経の状態を        │
│ 反映します。高いほど回復力があり、       │
│ ストレスへの適応力が高いとされます。     │
│                                         │
└─────────────────────────────────────────┘
```

---

## 3. 睡眠詳細画面

### 画面構成

```
┌─────────────────────────────────────────┐
│ ← 睡眠                                  │
├─────────────────────────────────────────┤
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │            😴                       │ │
│ │                                     │ │
│ │         7h 45m                      │ │
│ │        （昨夜）                     │ │
│ │                                     │ │
│ │    22:30 就寝 → 6:15 起床           │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 睡眠ステージ                            │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ ██████░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ │
│ │ 深い    REM        浅い    覚醒     │ │
│ │                                     │ │
│ │ 深い睡眠    1h 45m  (23%)           │ │
│ │ REM睡眠     1h 30m  (19%)           │ │
│ │ 浅い睡眠    4h 30m  (58%)           │ │
│ │ 覚醒        2回                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 📊 週間トレンド                         │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 9h ─                                │ │
│ │ 8h ─           █                    │ │
│ │ 7h ─ █  █  █  █     █  █            │ │
│ │ 6h ─                                │ │
│ │ 5h ─                                │ │
│ │     月 火 水 木 金 土 日             │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 📋 7日間の平均                          │
│                                         │
│ 睡眠時間          7h 20m               │
│ 就寝時刻          23:15                │
│ 起床時刻          6:35                 │
│ 深い睡眠          20%                  │
│                                         │
└─────────────────────────────────────────┘
```

### 睡眠ステージバー

```swift
// SleepStageBar.swift

struct SleepStageBar: View {
    let deepSleep: Double     // 時間
    let remSleep: Double      // 時間
    let lightSleep: Double    // 時間

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.deepSleep)  // 濃い青紫
                    .frame(width: geometry.size.width * deepRatio)

                Rectangle()
                    .fill(Color.remSleep)   // 青
                    .frame(width: geometry.size.width * remRatio)

                Rectangle()
                    .fill(Color.lightSleep) // 水色
                    .frame(width: geometry.size.width * lightRatio)
            }
            .cornerRadius(4)
        }
        .frame(height: 12)
    }

    private var total: Double { deepSleep + remSleep + lightSleep }
    private var deepRatio: CGFloat { CGFloat(deepSleep / total) }
    private var remRatio: CGFloat { CGFloat(remSleep / total) }
    private var lightRatio: CGFloat { CGFloat(lightSleep / total) }
}
```

---

## 4. 活動量詳細画面

### 画面構成

```
┌─────────────────────────────────────────┐
│ ← 活動量                                │
├─────────────────────────────────────────┤
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │            🏃                       │ │
│ │                                     │ │
│ │         8,234 歩                    │ │
│ │        （今日）                     │ │
│ │                                     │ │
│ │    ████████████████░░░░  82%        │ │
│ │    目標 10,000歩                    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 📊 週間トレンド                         │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 12k ─           █                   │ │
│ │ 10k ─     █  █                      │ │
│ │  8k ─ █           █  █              │ │
│ │  6k ─                    █          │ │
│ │  4k ─                         █     │ │
│ │      月 火 水 木 金 土 日            │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 今日のアクティビティ                    │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 歩数             8,234 歩          │ │
│ │ 消費カロリー     2,150 kcal        │ │
│ │ アクティブ時間   45 分             │ │
│ │ 距離             5.8 km            │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 昨日の運動                              │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🏋️ ランニング                       │ │
│ │ 30分 / 320 kcal                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 📋 過去7日間                            │
│                                         │
│ 平均歩数          7,850 歩             │
│ 総運動時間        3h 20m               │
│ 運動回数          3 回                 │
│                                         │
└─────────────────────────────────────────┘
```

---

## 5. 環境詳細画面

### 画面構成

```
┌─────────────────────────────────────────┐
│ ← 環境                                  │
├─────────────────────────────────────────┤
│                                         │
│ 📍 東京                                 │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ ☀️ 12°C                             │ │
│ │ 晴れ                                │ │
│ │                                     │ │
│ │ 体感温度: 10°C                      │ │
│ │ 最高/最低: 15°C / 8°C               │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 詳細データ                              │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 湿度           45%                  │ │
│ │ 気圧           1018 hPa（安定）     │ │
│ │ 風速           3 m/s               │ │
│ │ UV指数         3（中程度）          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 大気質                                  │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ AQI            42（良好）           │ │
│ │ ████████░░░░░░░░░░░░                │ │
│ │                                     │ │
│ │ PM2.5          12 µg/m³            │ │
│ │ PM10           28 µg/m³            │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 💡 今日の環境アドバイス                 │
│                                         │
│ • 気温が低めです。外出時は暖かい服装を  │
│ • UV指数は中程度。長時間の外出には      │
│   日焼け止めを                          │
│ • 大気質は良好。屋外運動に適しています  │
│                                         │
└─────────────────────────────────────────┘
```

---

## 共通コンポーネント

### TrendLineChart（折れ線グラフ）

```swift
// TrendLineChart.swift

import SwiftUI
import Charts

struct TrendLineChart: View {
    let data: [DailyValue]
    let yAxisLabel: String

    var body: some View {
        Chart(data) { item in
            LineMark(
                x: .value("Day", item.day),
                y: .value(yAxisLabel, item.value)
            )
            .foregroundStyle(Color.primary)

            PointMark(
                x: .value("Day", item.day),
                y: .value(yAxisLabel, item.value)
            )
            .foregroundStyle(Color.primary)
        }
        .frame(height: 150)
    }
}

struct DailyValue: Identifiable {
    let id = UUID()
    let day: String  // "月", "火", etc.
    let value: Double
}
```

### TrendBarChart（棒グラフ）

```swift
// TrendBarChart.swift

import SwiftUI
import Charts

struct TrendBarChart: View {
    let data: [DailyValue]
    let yAxisLabel: String
    let goal: Double?

    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Day", item.day),
                    y: .value(yAxisLabel, item.value)
                )
                .foregroundStyle(Color.primary.opacity(0.7))
            }

            if let goal = goal {
                RuleMark(y: .value("Goal", goal))
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(dash: [5, 5]))
            }
        }
        .frame(height: 150)
    }
}
```

### DataRow（データ項目の行）

```swift
// DataRow.swift

struct DataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}
```

---

## 実装コンポーネント一覧

### Views（Features/Condition/Views/）

```
Features/
└── Condition/
    └── Views/
        └── Detail/
            ├── CircadianRhythmDetailView.swift
            ├── HRVDetailView.swift
            ├── SleepDetailView.swift
            ├── ActivityDetailView.swift
            └── EnvironmentDetailView.swift
```

### Models（Features/Condition/Models/）

```
Features/
└── Condition/
    └── Models/
        ├── CircadianRhythmDetail.swift
        ├── HRVDetail.swift
        ├── SleepDetail.swift
        ├── ActivityDetail.swift
        └── EnvironmentDetail.swift
```

### Services

```
Features/
└── Condition/
    └── Services/
        ├── RhythmCalculator.swift    ← リズム安定度スコア算出
        └── HintGenerator.swift       ← 条件分岐ヒント生成
```

### Shared Components

```
Shared/
└── Components/
    ├── TrendLineChart.swift
    ├── TrendBarChart.swift
    ├── SleepStageBar.swift
    ├── CircularProgress.swift
    ├── DataRow.swift
    └── CircularTimeChart.swift  ← 24時間サークル図
```

---

## Mock データ（詳細用）

```swift
// ConditionDetailMockData.swift

struct ConditionDetailMockData {

    // MARK: - サーカディアンリズム

    static let circadianRhythm = CircadianRhythmDetail(
        avgBedtime: "23:15",
        avgWakeTime: "7:05",
        lastNightBedtime: "23:30",
        lastNightWakeTime: "7:15",
        stabilityScore: 82,
        stabilityStatus: .stable,
        bedtimeStdDev: 32,  // 分
        wakeTimeStdDev: 18, // 分
        weeklyBedtimes: ["23:00", "23:15", "0:30", "23:20", "23:45", "0:15", "23:30"],
        weeklyWakeTimes: ["7:00", "7:10", "7:05", "7:00", "8:30", "8:00", "7:15"]
    )

    // MARK: - HRV

    static let hrv = HRVDetail(
        current: 65,
        avg7d: 63,
        avg30d: 61,
        restingHR: 52,
        restingHRAvg7d: 54,
        trend: .stable,
        weeklyData: [58, 62, 70, 68, 55, 60, 65]
    )

    // MARK: - 睡眠

    static let sleep = SleepDetail(
        lastNight: SleepNight(
            bedtime: "22:30",
            wakeTime: "6:15",
            duration: 7.75,
            deepSleep: 1.75,
            remSleep: 1.5,
            lightSleep: 4.5,
            awakenings: 2
        ),
        avg7d: SleepAverage(
            duration: 7.33,
            bedtime: "23:15",
            wakeTime: "6:35",
            deepSleepPercent: 20
        ),
        weeklyDurations: [7.5, 6.8, 7.2, 7.0, 6.5, 8.0, 7.75]
    )

    // MARK: - 活動量

    static let activity = ActivityDetail(
        today: ActivityToday(
            steps: 8234,
            stepGoal: 10000,
            calories: 2150,
            activeMinutes: 45,
            distance: 5.8
        ),
        yesterday: Workout(
            type: "ランニング",
            minutes: 30,
            calories: 320
        ),
        avg7d: ActivityAverage(
            steps: 7850,
            totalWorkoutMinutes: 200,
            workoutCount: 3
        ),
        weeklySteps: [8200, 9500, 10200, 7800, 8100, 6500, 4200]
    )

    // MARK: - 環境

    static let environment = EnvironmentDetail(
        city: "東京",
        current: WeatherCurrent(
            temp: 12,
            feelsLike: 10,
            weatherCode: "sunny",
            weatherDescription: "晴れ",
            tempMax: 15,
            tempMin: 8,
            humidity: 45,
            pressure: 1018,
            pressureTrend: .stable,
            windSpeed: 3,
            uvIndex: 3
        ),
        airQuality: AirQuality(
            aqi: 42,
            aqiStatus: "良好",
            pm25: 12,
            pm10: 28
        )
    )
}
```

---

## カラー定義

```swift
// Colors+Condition.swift

extension Color {
    // 安定度
    static let stabilityHigh = Color.green        // 90-100
    static let stabilityGood = Color.primary      // 75-89
    static let stabilityLow = Color.yellow        // 60-74
    static let stabilityVeryLow = Color.orange    // 0-59

    // 睡眠ステージ
    static let deepSleep = Color(hex: "#3B2E7E")  // 濃い青紫
    static let remSleep = Color(hex: "#5B7FBF")   // 青
    static let lightSleep = Color(hex: "#87CEEB") // 水色

    // トレンド
    static let trendUp = Color.green
    static let trendStable = Color.primary
    static let trendDown = Color.orange
}
```

---

## 今後のフェーズとの関係

### Phase 11 で変更

- Mock データを API レスポンスに置き換え
- 実際の HealthKit データを使用

### トラベルモード追加時（Phase 16-17）

- サーカディアンリズム詳細に「今日のリセットポイント」セクション追加
- 環境詳細に「環境差分」情報追加
- トラベルモード時の特別なヒント表示

---

## 関連ドキュメント

- `05-phase-condition-top.md` - Phase 5（コンディショントップ画面）
- `travel-mode-condition-spec.md` - セクション 4「コンディション画面設計」
- `technical-spec.md` - セクション 2.3「データモデル」
- `ui-spec.md` - セクション 7「詳細画面群」

---

## 改訂履歴

| バージョン | 日付       | 変更内容                               |
| ---------- | ---------- | -------------------------------------- |
| 1.0        | 2025-12-11 | 初版作成（Phase 5 を分割、詳細画面群） |
