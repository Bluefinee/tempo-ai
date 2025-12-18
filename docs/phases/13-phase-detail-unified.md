# Phase 13: 詳細画面（1画面統合版）設計書

**フェーズ**: 13 / 15  
**Part**: D（コンディション画面）  
**前提フェーズ**: Phase 12（コンディショントップ）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料
- **[Product Spec v4.2](../product-spec.md)** - プロダクト仕様書セクション3.3
- **[UI Spec v3.2](../ui-spec.md)** - UI設計仕様書セクション8
- **[Metrics Spec v3.0](../metrics-spec.md)** - メトリクス仕様書セクション10

### 🔧 iOS専用資料
- **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift開発標準

### ✅ 実装完了後の必須作業
```bash
swiftlint
swift-format --lint --recursive ios/
swift test
```

---

## このフェーズで実現すること

コンディショントップの「詳しく見る」から遷移する詳細画面を実装します。

旧仕様では5つの詳細画面（睡眠、HRV、リズム、活動量、ストレス）がありましたが、新仕様では1画面に統合されます。

**実装する要素**:
1. 「あなたのパターン」セクション（散布図 + インサイト文）
2. 「リズムを整えるヒント」セクション（条件分岐による定型文）

---

## 完了条件

- [ ] 詳細画面が1画面で構成されている
- [ ] 散布図が正しく描画される（2週間以上のデータがある場合）
- [ ] インサイト文が条件に応じて正しく生成される
- [ ] データ不足時に「まだパターンを分析中です」メッセージが表示される
- [ ] リズムを整えるヒントが条件分岐で正しく表示される（最大2つ）
- [ ] コンディショントップからの遷移が動作する（右からスライドイン）
- [ ] 戻るボタン / スワイプで戻れる

---

## 画面構成

```
┌─────────────────────────────────────┐
│ ← 詳細                              │
├─────────────────────────────────────┤
│                                     │
│ あなたのパターン                     │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │    [散布図]                      │ │
│ │    縦軸: 翌朝のHRV (ms)          │ │
│ │    横軸: 前日の睡眠時間 (時間)    │ │
│ │                                 │ │
│ │    ・ ・     ・                  │ │
│ │      ・  ・ ・  ・               │ │
│ │    ・   ・ ・                    │ │
│ │  ──────│────────────            │ │
│ │        7h                       │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 7時間以上眠った日は、HRVが平均15%   │
│ 高い傾向があります                   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│ リズムを整えるヒント                 │
│                                     │
│ 💡 毎日同じ時間に寝ることを          │
│    目指しましょう                    │
│                                     │
│ 💡 週末も平日と同じ時間に起きる      │
│    習慣をつけましょう                │
│                                     │
└─────────────────────────────────────┘
```

---

## 1. 「あなたのパターン」セクション

### 表示条件

| 条件 | 表示 |
|------|------|
| データ14日以上 かつ 差分10%以上 | 散布図 + インサイト文 |
| データ14日以上 かつ 差分10%未満 | 「まだパターンを分析中です」 |
| データ14日未満 | 「まだパターンを分析中です。2週間ほどデータを蓄積してください。」 |

### 分析対象パターン（優先度順）

| 優先度 | パターン | X軸 | Y軸 | 閾値 |
|--------|----------|-----|-----|------|
| 1 | 睡眠時間 → HRV | 睡眠時間 | 翌朝のHRV | 7時間 |
| 2 | 就寝時刻 → HRV | 就寝時刻 | 翌朝のHRV | 23:30 |
| 3 | 歩数 → 深い睡眠 | 歩数 | 深い睡眠時間 | 6,000歩 |

### データ構造

```swift
// Models/ScatterPlotData.swift
struct ScatterPlotData {
    let points: [ScatterPoint]
    let xAxisLabel: String
    let yAxisLabel: String
    let thresholdLine: Double?
    let insight: PatternInsight?
}

struct ScatterPoint: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
    let date: Date
}

struct PatternInsight {
    let patternType: PatternType
    let threshold: Double
    let differencePercent: Double
    let description: String
    
    enum PatternType {
        case sleepToHRV
        case bedtimeToHRV
        case stepsToDeepSleep
    }
}
```

### 分析アルゴリズム

```swift
// Services/PatternAnalyzer.swift
struct PatternAnalyzer {
    static func analyze(dailyData: [DailyHealthData]) -> ScatterPlotData? {
        // データが14日未満の場合は分析不可
        guard dailyData.count >= 14 else { return nil }
        
        // 各パターンを分析し、最も差が大きいものを選択
        let patterns: [(PatternType, Double)] = [
            (.sleepToHRV, 7.0),
            (.bedtimeToHRV, 23.5),  // 23:30 = 23.5
            (.stepsToDeepSleep, 6000)
        ]
        
        var bestResult: ScatterPlotData?
        var maxDifference: Double = 0
        
        for (patternType, threshold) in patterns {
            if let result = analyzePattern(
                dailyData: dailyData,
                patternType: patternType,
                threshold: threshold
            ) {
                if abs(result.insight?.differencePercent ?? 0) > maxDifference {
                    maxDifference = abs(result.insight?.differencePercent ?? 0)
                    bestResult = result
                }
            }
        }
        
        // 差が10%未満の場合はインサイトなし
        guard maxDifference >= 10 else {
            return bestResult.map { ScatterPlotData(
                points: $0.points,
                xAxisLabel: $0.xAxisLabel,
                yAxisLabel: $0.yAxisLabel,
                thresholdLine: $0.thresholdLine,
                insight: nil  // インサイトなし
            )}
        }
        
        return bestResult
    }
    
    private static func analyzePattern(
        dailyData: [DailyHealthData],
        patternType: PatternType,
        threshold: Double
    ) -> ScatterPlotData? {
        // XY値の抽出
        let xyPairs: [(x: Double, y: Double, date: Date)] = dailyData.compactMap { data in
            switch patternType {
            case .sleepToHRV:
                guard let hrv = data.nextMorningHRV else { return nil }
                return (data.sleepHours, hrv, data.date)
            case .bedtimeToHRV:
                guard let hrv = data.nextMorningHRV else { return nil }
                return (data.bedtimeHour, hrv, data.date)
            case .stepsToDeepSleep:
                return (Double(data.steps), Double(data.deepSleepMinutes), data.date)
            }
        }
        
        // 閾値で2群に分ける
        let aboveThreshold = xyPairs.filter { $0.x >= threshold }
        let belowThreshold = xyPairs.filter { $0.x < threshold }
        
        // 各群に5日以上必要
        guard aboveThreshold.count >= 5, belowThreshold.count >= 5 else {
            return nil
        }
        
        // 各群のY平均を計算
        let avgYAbove = aboveThreshold.map { $0.y }.reduce(0, +) / Double(aboveThreshold.count)
        let avgYBelow = belowThreshold.map { $0.y }.reduce(0, +) / Double(belowThreshold.count)
        
        // 差分を%で算出
        let difference = ((avgYAbove - avgYBelow) / avgYBelow) * 100
        
        // 散布図データ作成
        let points = xyPairs.map { ScatterPoint(x: $0.x, y: $0.y, date: $0.date) }
        
        // インサイト文生成
        let insight = PatternInsight(
            patternType: patternType,
            threshold: threshold,
            differencePercent: difference,
            description: generateInsightText(patternType: patternType, threshold: threshold, difference: difference)
        )
        
        return ScatterPlotData(
            points: points,
            xAxisLabel: xAxisLabelFor(patternType),
            yAxisLabel: yAxisLabelFor(patternType),
            thresholdLine: threshold,
            insight: insight
        )
    }
    
    private static func generateInsightText(
        patternType: PatternType,
        threshold: Double,
        difference: Double
    ) -> String {
        let diffText = difference > 0 ? "高い" : "低い"
        let diffPercent = Int(abs(difference))
        
        switch patternType {
        case .sleepToHRV:
            return "\(Int(threshold))時間以上眠った日は、HRVが平均\(diffPercent)%\(diffText)傾向があります"
        case .bedtimeToHRV:
            let hour = Int(threshold)
            let minute = Int((threshold - Double(hour)) * 60)
            return "\(hour):\(String(format: "%02d", minute))前に就寝した日は、HRVが平均\(diffPercent)%\(diffText)傾向があります"
        case .stepsToDeepSleep:
            return "\(Int(threshold).formatted())歩以上歩いた日は、深い睡眠が平均\(diffPercent)%\(diffText)傾向があります"
        }
    }
    
    private static func xAxisLabelFor(_ type: PatternType) -> String {
        switch type {
        case .sleepToHRV: return "睡眠時間（時間）"
        case .bedtimeToHRV: return "就寝時刻"
        case .stepsToDeepSleep: return "歩数"
        }
    }
    
    private static func yAxisLabelFor(_ type: PatternType) -> String {
        switch type {
        case .sleepToHRV, .bedtimeToHRV: return "翌朝のHRV（ms）"
        case .stepsToDeepSleep: return "深い睡眠（分）"
        }
    }
}
```

### 散布図コンポーネント

```swift
// Features/Condition/Views/ScatterPlotView.swift
import SwiftUI
import Charts

struct ScatterPlotView: View {
    let data: ScatterPlotData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // タイトル
            Text("あなたのパターン")
                .font(.headline)
            
            // 散布図
            Chart {
                // データ点
                ForEach(data.points) { point in
                    PointMark(
                        x: .value(data.xAxisLabel, point.x),
                        y: .value(data.yAxisLabel, point.y)
                    )
                    .foregroundStyle(Color.primary.opacity(0.7))
                    .symbolSize(40)
                }
                
                // 閾値線
                if let threshold = data.thresholdLine {
                    RuleMark(x: .value("閾値", threshold))
                        .foregroundStyle(Color.secondary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .annotation(position: .bottom, alignment: .leading) {
                            Text(formatThreshold(threshold, for: data.xAxisLabel))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                }
            }
            .chartXAxisLabel(data.xAxisLabel)
            .chartYAxisLabel(data.yAxisLabel)
            .frame(height: 200)
            
            // インサイト文
            if let insight = data.insight {
                Text(insight.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.top, 8)
            } else {
                Text("まだパターンを分析中です")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func formatThreshold(_ value: Double, for label: String) -> String {
        if label.contains("時刻") {
            let hour = Int(value)
            let minute = Int((value - Double(hour)) * 60)
            return "\(hour):\(String(format: "%02d", minute))"
        } else if label.contains("時間") {
            return "\(Int(value))h"
        } else {
            return "\(Int(value).formatted())"
        }
    }
}

// データ不足時のプレースホルダー
struct PatternPlaceholderView: View {
    let daysOfData: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("あなたのパターン")
                .font(.headline)
            
            VStack(spacing: 12) {
                Image(systemName: "chart.dots.scatter")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                
                Text("まだパターンを分析中です")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if daysOfData < 14 {
                    Text("あと\(14 - daysOfData)日ほどデータを蓄積してください")
                        .font(.caption)
                        .foregroundColor(.tertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
```

---

## 2. 「リズムを整えるヒント」セクション

### 条件分岐ロジック

| 条件 | 表示するヒント |
|------|----------------|
| 就寝時刻の標準偏差 > 60分 | 「毎日同じ時間に寝ることを目指しましょう」 |
| 平均起床時刻 > 8:00 | 「起床時刻を少しずつ早めて、朝の光を浴びましょう」 |
| 週末シフト > 2時間 | 「週末も平日と同じ時間に起きる習慣をつけましょう」 |
| 平均就寝時刻 > 24:00 | 「就寝を毎日15-30分ずつ早めてみましょう」 |
| 特に問題なし | 「このリズムを維持できると良いですね」 |

**最大2つまで表示**

### ヒント生成ロジック

```swift
// Services/HintGenerator.swift
struct HintGenerator {
    static func generate(from sleepRecords: [SleepRecord]) -> [String] {
        var hints: [String] = []
        
        guard sleepRecords.count >= 7 else {
            return ["データを蓄積中です。1週間ほどお待ちください。"]
        }
        
        // 就寝時刻の標準偏差（分）
        let bedtimeStdDev = calculateBedtimeStdDev(sleepRecords)
        if bedtimeStdDev > 60 {
            hints.append("毎日同じ時間に寝ることを目指しましょう")
        }
        
        // 平均起床時刻
        let avgWakeMinutes = calculateAverageWakeTime(sleepRecords)
        if avgWakeMinutes > 8 * 60 {  // 8:00 = 480分
            hints.append("起床時刻を少しずつ早めて、朝の光を浴びましょう")
        }
        
        // 週末シフト
        let weekendShift = calculateWeekendShift(sleepRecords)
        if weekendShift > 120 {  // 2時間 = 120分
            hints.append("週末も平日と同じ時間に起きる習慣をつけましょう")
        }
        
        // 平均就寝時刻
        let avgBedMinutes = calculateAverageBedtime(sleepRecords)
        if avgBedMinutes > 24 * 60 {  // 24:00以降
            hints.append("就寝を毎日15-30分ずつ早めてみましょう")
        }
        
        // 特に問題なし
        if hints.isEmpty {
            hints.append("このリズムを維持できると良いですね")
        }
        
        return Array(hints.prefix(2))
    }
    
    private static func calculateBedtimeStdDev(_ records: [SleepRecord]) -> Double {
        let bedtimeMinutes = records.map { minutesFromMidnight($0.bedtime) }
        return standardDeviation(bedtimeMinutes)
    }
    
    private static func calculateAverageWakeTime(_ records: [SleepRecord]) -> Double {
        let wakeMinutes = records.map { minutesFromMidnight($0.wakeTime) }
        return wakeMinutes.reduce(0, +) / Double(wakeMinutes.count)
    }
    
    private static func calculateWeekendShift(_ records: [SleepRecord]) -> Double {
        let calendar = Calendar.current
        
        let weekdayRecords = records.filter { !calendar.isDateInWeekend($0.date) }
        let weekendRecords = records.filter { calendar.isDateInWeekend($0.date) }
        
        guard !weekdayRecords.isEmpty, !weekendRecords.isEmpty else { return 0 }
        
        let avgWeekdayWake = weekdayRecords.map { minutesFromMidnight($0.wakeTime) }.reduce(0, +) / Double(weekdayRecords.count)
        let avgWeekendWake = weekendRecords.map { minutesFromMidnight($0.wakeTime) }.reduce(0, +) / Double(weekendRecords.count)
        
        return abs(avgWeekendWake - avgWeekdayWake)
    }
    
    private static func calculateAverageBedtime(_ records: [SleepRecord]) -> Double {
        let bedtimeMinutes = records.map { minutesFromMidnight($0.bedtime) }
        return bedtimeMinutes.reduce(0, +) / Double(bedtimeMinutes.count)
    }
    
    private static func minutesFromMidnight(_ date: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        var totalMinutes = Double(hour * 60 + minute)
        
        // 深夜0時以降の就寝は24時間+として扱う
        if hour < 6 {
            totalMinutes += 24 * 60
        }
        
        return totalMinutes
    }
    
    private static func standardDeviation(_ values: [Double]) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        return sqrt(variance)
    }
}
```

### UIコンポーネント

```swift
// Features/Condition/Views/HintsView.swift
struct HintsView: View {
    let hints: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("リズムを整えるヒント")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(hints, id: \.self) { hint in
                    HintRow(hint: hint)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct HintRow: View {
    let hint: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 16))
            
            Text(hint)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
```

---

## 3. 詳細画面全体

```swift
// Features/Condition/Views/ConditionDetailView.swift
import SwiftUI

struct ConditionDetailView: View {
    @ObservedObject var viewModel: ConditionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // あなたのパターン
                if let scatterData = viewModel.scatterPlotData {
                    ScatterPlotView(data: scatterData)
                } else {
                    PatternPlaceholderView(daysOfData: viewModel.daysOfData)
                }
                
                // リズムを整えるヒント
                HintsView(hints: viewModel.hints)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}
```

---

## ディレクトリ構造

```
ios/TempoAI/Features/Condition/
├── Views/
│   ├── ConditionView.swift           # Phase 12で実装
│   ├── ConditionDetailView.swift     # 詳細画面（本フェーズ）
│   ├── ScatterPlotView.swift         # 散布図
│   ├── PatternPlaceholderView.swift  # データ不足時のプレースホルダー
│   └── HintsView.swift               # ヒント表示
├── ViewModels/
│   └── ConditionViewModel.swift      # Phase 12で実装（拡張）
└── Models/
    └── ScatterPlotData.swift         # 散布図データ

ios/TempoAI/Services/
├── PatternAnalyzer.swift             # パターン分析
└── HintGenerator.swift               # ヒント生成
```

---

## テスト観点

### UI確認

- [ ] 詳細画面が表示される
- [ ] 散布図が正しく描画される（データ14日以上の場合）
- [ ] データ点が正しい位置にプロットされる
- [ ] 閾値線が表示される
- [ ] インサイト文が表示される
- [ ] データ不足時にプレースホルダーが表示される
- [ ] ヒントが最大2つ表示される
- [ ] 戻るボタンで前画面に戻れる

### ロジック確認

- [ ] 睡眠時間 → HRVパターンが正しく分析される
- [ ] 就寝時刻 → HRVパターンが正しく分析される
- [ ] 歩数 → 深い睡眠パターンが正しく分析される
- [ ] 差分が10%未満の場合、インサイトが表示されない
- [ ] ヒントの条件分岐が正しく動作する

### 境界値確認

- [ ] データ13日（表示されない）
- [ ] データ14日（表示される）
- [ ] 差分9%（インサイトなし）
- [ ] 差分10%（インサイトあり）
- [ ] 就寝時刻標準偏差60分（ヒントなし）
- [ ] 就寝時刻標準偏差61分（ヒントあり）

---

## 今後のフェーズとの関係

### Phase 14（UI結合）

- 実APIデータでの動作確認
- キャッシュからのデータ取得

### Phase 15（ポリッシュ）

- アニメーションの追加
- エラー状態のハンドリング

---

## 関連ドキュメント

- `ui-spec.md` - セクション8「詳細画面群」
- `product-spec.md` - セクション3.3「詳細画面」
- `metrics-spec.md` - セクション10「あなたのパターンの相関分析」

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-19 | 初版作成 |
