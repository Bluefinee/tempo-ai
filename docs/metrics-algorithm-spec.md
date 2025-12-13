# メトリクスアルゴリズム仕様書

**バージョン**: 1.0
**最終更新**: 2025-12-13
**関連ドキュメント**: [product-spec.md](./product-spec.md), [correlation-analysis-spec.md](./correlation-analysis-spec.md)

---

## 1. 概要

Tempo AIの健康メトリクスは、自律神経バランスとサーカディアンリズムを核心コンセプトとして設計されています。本ドキュメントでは、4つのメトリクススコア（睡眠・HRV・リズム・活動量）およびストレスグラフの算出アルゴリズムを定義します。

### 1.1 メトリクス体系

| メトリクス | 概念 | データソース |
|-----------|------|-------------|
| 睡眠 | 睡眠の質と量 | Apple HealthKit (HKCategorySample) |
| HRV | 心拍変動による自律神経状態 | Apple HealthKit (HKQuantityType) |
| リズム | サーカディアンリズムの安定性 | 睡眠データから算出 |
| 活動量 | 日中の身体活動レベル | Apple HealthKit (HKQuantityType) |
| ストレスグラフ | 24時間の自律神経バランス推移 | HRV + 心拍数データから算出 |

---

## 2. スコア算出アルゴリズム

### 2.1 睡眠スコア（0-100）

睡眠スコアは5つのコンポーネントから構成されます。

```
総合スコア = 睡眠時間(35) + 深い睡眠(25) + REM睡眠(15) + 睡眠効率(15) + 就寝タイミング(10)
```

#### コンポーネント詳細

| コンポーネント | 配点 | 算出方法 |
|--------------|-----|---------|
| 睡眠時間 | 35点 | 7-9時間 = 満点、6時間以下/-1時間ごとに-7点、9時間超/+1時間ごとに-5点 |
| 深い睡眠 | 25点 | 総睡眠時間の15-20% = 満点、比率に応じて線形減点 |
| REM睡眠 | 15点 | 総睡眠時間の20-25% = 満点、比率に応じて線形減点 |
| 睡眠効率 | 15点 | (実睡眠時間/ベッド時間) × 100、90%以上 = 満点 |
| 就寝タイミング | 10点 | 理想時間帯(22:00-24:00)からの乖離で減点 |

#### 算出例

```swift
func calculateSleepScore(
    totalSleepMinutes: Int,
    deepSleepMinutes: Int,
    remSleepMinutes: Int,
    timeInBedMinutes: Int,
    bedtimeHour: Int
) -> Int {
    // 睡眠時間スコア (35点)
    let sleepHours = Double(totalSleepMinutes) / 60.0
    let durationScore: Double
    if sleepHours >= 7 && sleepHours <= 9 {
        durationScore = 35
    } else if sleepHours < 7 {
        durationScore = max(0, 35 - (7 - sleepHours) * 7)
    } else {
        durationScore = max(0, 35 - (sleepHours - 9) * 5)
    }

    // 深い睡眠スコア (25点)
    let deepSleepRatio = Double(deepSleepMinutes) / Double(totalSleepMinutes)
    let deepSleepScore = min(25, deepSleepRatio / 0.175 * 25)

    // REM睡眠スコア (15点)
    let remRatio = Double(remSleepMinutes) / Double(totalSleepMinutes)
    let remScore = min(15, remRatio / 0.225 * 15)

    // 睡眠効率スコア (15点)
    let efficiency = Double(totalSleepMinutes) / Double(timeInBedMinutes)
    let efficiencyScore = min(15, efficiency / 0.9 * 15)

    // 就寝タイミングスコア (10点)
    let idealBedtime = 23 // 23:00を理想とする
    let timingDiff = abs(bedtimeHour - idealBedtime)
    let timingScore = max(0, 10 - timingDiff * 3)

    return Int(durationScore + deepSleepScore + remScore + efficiencyScore + Double(timingScore))
}
```

---

### 2.2 HRVスコア（0-100）

HRVスコアは個人のベースラインを基準とした相対評価を重視します。

```
総合スコア = 個人ベースライン比較(50) + 7日トレンド(25) + 安静時心拍数(25)
```

#### コンポーネント詳細

| コンポーネント | 配点 | 算出方法 |
|--------------|-----|---------|
| 個人ベースライン比較 | 50点 | 過去30日平均との比較、±20%以内で満点 |
| 7日トレンド | 25点 | 7日間の変化傾向、上昇傾向で加点 |
| 安静時心拍数 | 25点 | 個人の安静時心拍数ベースラインとの比較 |

#### ベースライン計算

```swift
struct HRVBaseline {
    let average30Day: Double      // 過去30日間の平均RMSSD
    let standardDeviation: Double // 標準偏差
    let restingHeartRate: Double  // 安静時心拍数の平均
}

func calculateHRVScore(
    currentHRV: Double,
    baseline: HRVBaseline,
    last7Days: [Double]
) -> Int {
    // ベースライン比較スコア (50点)
    let deviationRatio = (currentHRV - baseline.average30Day) / baseline.average30Day
    let baselineScore: Double
    if abs(deviationRatio) <= 0.2 {
        baselineScore = 50
    } else if deviationRatio > 0.2 {
        baselineScore = min(50, 50 + deviationRatio * 25) // 高い方が良い
    } else {
        baselineScore = max(0, 50 + deviationRatio * 100) // 低いとペナルティ
    }

    // 7日トレンドスコア (25点)
    let trend = calculateTrend(last7Days)
    let trendScore: Double
    switch trend {
    case .improving: trendScore = 25
    case .stable: trendScore = 20
    case .declining: trendScore = 10
    }

    // 安静時心拍数スコア (25点)
    // 低いほど良いが、個人差を考慮
    let restingHRScore = 25.0 // ベースラインとの比較で算出

    return Int(baselineScore + trendScore + restingHRScore)
}
```

---

### 2.3 リズムスコア（0-100）

サーカディアンリズムの安定性を評価します。

```
総合スコア = 就寝時刻安定度(35) + 起床時刻安定度(35) + 週末シフト(20) + 理想時間帯(10)
```

#### コンポーネント詳細

| コンポーネント | 配点 | 算出方法 |
|--------------|-----|---------|
| 就寝時刻安定度 | 35点 | 過去7日間の就寝時刻の標準偏差、30分以内で満点 |
| 起床時刻安定度 | 35点 | 過去7日間の起床時刻の標準偏差、30分以内で満点 |
| 週末シフト | 20点 | 平日と週末の睡眠時間帯の差、1時間以内で満点 |
| 理想時間帯 | 10点 | 22:00-6:00の範囲内で就寝・起床しているか |

#### 算出例

```swift
func calculateRhythmScore(
    bedtimes: [Date],    // 過去7日間の就寝時刻
    wakeups: [Date],     // 過去7日間の起床時刻
    weekdayBedtimeAvg: Date,
    weekendBedtimeAvg: Date
) -> Int {
    // 就寝時刻安定度 (35点)
    let bedtimeStdDev = calculateStandardDeviation(bedtimes.map { $0.timeIntervalSince1970 })
    let bedtimeStabilityScore = max(0, 35 - (bedtimeStdDev / 60 / 30) * 35)

    // 起床時刻安定度 (35点)
    let wakeupStdDev = calculateStandardDeviation(wakeups.map { $0.timeIntervalSince1970 })
    let wakeupStabilityScore = max(0, 35 - (wakeupStdDev / 60 / 30) * 35)

    // 週末シフト (20点)
    let weekendShiftMinutes = abs(weekdayBedtimeAvg.timeIntervalSince(weekendBedtimeAvg)) / 60
    let weekendShiftScore = max(0, 20 - (weekendShiftMinutes / 60) * 10)

    // 理想時間帯 (10点)
    let idealRangeScore = calculateIdealRangeScore(bedtimes: bedtimes, wakeups: wakeups)

    return Int(bedtimeStabilityScore + wakeupStabilityScore + weekendShiftScore + idealRangeScore)
}
```

---

### 2.4 活動量スコア（0-100）

日中の身体活動レベルを総合的に評価します。

```
総合スコア = 歩数(40) + アクティブ時間(30) + 座りっぱなし回避(20) + 運動完了(10)
```

#### コンポーネント詳細

| コンポーネント | 配点 | 算出方法 |
|--------------|-----|---------|
| 歩数 | 40点 | 目標歩数（デフォルト8,000歩）に対する達成率 |
| アクティブ時間 | 30点 | 中〜高強度活動時間、30分以上で満点 |
| 座りっぱなし回避 | 20点 | 1時間以上の連続座位回避、毎時間動いていれば満点 |
| 運動完了 | 10点 | 設定した運動目標の達成 |

#### 算出例

```swift
func calculateActivityScore(
    steps: Int,
    targetSteps: Int = 8000,
    activeMinutes: Int,
    sedentaryBreaks: Int, // 座位中断回数
    exerciseCompleted: Bool
) -> Int {
    // 歩数スコア (40点)
    let stepRatio = Double(steps) / Double(targetSteps)
    let stepsScore = min(40, stepRatio * 40)

    // アクティブ時間スコア (30点)
    let activeScore = min(30, Double(activeMinutes) / 30.0 * 30)

    // 座りっぱなし回避スコア (20点)
    // 理想: 起きている16時間で16回以上の座位中断
    let sedentaryScore = min(20, Double(sedentaryBreaks) / 16.0 * 20)

    // 運動完了スコア (10点)
    let exerciseScore = exerciseCompleted ? 10 : 0

    return Int(stepsScore + activeScore + sedentaryScore + Double(exerciseScore))
}
```

---

## 3. ストレスグラフ

### 3.1 概要

ストレスグラフは24時間の自律神経バランスを視覚化するコンポーネントです。メトリクスカードとは別に独立して表示されます。

### 3.2 仕様

| 項目 | 値 |
|-----|---|
| 時間範囲 | 24時間（過去24時間または当日00:00-24:00） |
| データ間隔 | 5分間隔 |
| Y軸範囲 | -100（ストレス）〜 +100（リラックス） |
| 表示形式 | 折れ線グラフ with グラデーション塗りつぶし |

### 3.3 バランススコア算出

```swift
struct AutonomicBalancePoint {
    let timestamp: Date
    let score: Double  // -100 to +100
    let hrvValue: Double
    let heartRate: Double
}

func calculateAutonomicBalance(
    hrv: Double,
    heartRate: Double,
    baseline: HRVBaseline
) -> Double {
    // HRV比率（ベースライン比）
    let hrvRatio = hrv / baseline.average30Day

    // 心拍数比率（ベースライン比、逆転）
    let hrRatio = baseline.restingHeartRate / heartRate

    // バランススコア算出
    // HRV高い＆心拍数低い = リラックス（+）
    // HRV低い＆心拍数高い = ストレス（-）
    let rawScore = (hrvRatio - 1) * 100 + (hrRatio - 1) * 50

    return max(-100, min(100, rawScore))
}
```

### 3.4 色グラデーション

| スコア範囲 | 色 | 状態 |
|----------|---|------|
| +60 〜 +100 | 緑 (#4CAF50) | 深いリラックス |
| +20 〜 +59 | 黄緑 (#8BC34A) | リラックス |
| -19 〜 +19 | 黄 (#FFC107) | 中間 |
| -59 〜 -20 | オレンジ (#FF9800) | 軽度ストレス |
| -100 〜 -60 | 赤 (#F44336) | 高ストレス |

---

## 4. ステータス判定

全メトリクスに共通するステータス判定ルールです。

### 4.1 判定閾値

| スコア範囲 | ステータス | 表示 | 色 |
|----------|----------|-----|---|
| 80-100 | 最高 | Excellent | Primary (#7CB342) |
| 60-79 | 良好 | Good | Primary (#7CB342) |
| 40-59 | 普通 | Fair | Yellow (#FFC107) |
| 20-39 | やや低下 | Low | Orange (#FF9800) |
| 0-19 | 要改善 | Poor | Red (#F44336) |

### 4.2 ステータス判定関数

```swift
enum MetricStatus: String {
    case excellent = "最高"
    case good = "良好"
    case fair = "普通"
    case low = "やや低下"
    case poor = "要改善"

    static func from(score: Int) -> MetricStatus {
        switch score {
        case 80...100: return .excellent
        case 60..<80: return .good
        case 40..<60: return .fair
        case 20..<40: return .low
        default: return .poor
        }
    }

    var color: Color {
        switch self {
        case .excellent, .good: return .primaryGreen
        case .fair: return .yellow
        case .low: return .orange
        case .poor: return .red
        }
    }
}
```

---

## 5. データ要件

### 5.1 必要なHealthKitデータ

| メトリクス | HealthKit Type | 必須/任意 |
|-----------|---------------|----------|
| 睡眠 | HKCategoryTypeIdentifier.sleepAnalysis | 必須 |
| 深い睡眠 | HKCategoryValueSleepAnalysis.asleepDeep | 任意 |
| REM睡眠 | HKCategoryValueSleepAnalysis.asleepREM | 任意 |
| HRV | HKQuantityTypeIdentifier.heartRateVariabilitySDNN | 必須 |
| 心拍数 | HKQuantityTypeIdentifier.heartRate | 必須 |
| 歩数 | HKQuantityTypeIdentifier.stepCount | 必須 |
| アクティブ時間 | HKQuantityTypeIdentifier.appleExerciseTime | 任意 |

### 5.2 フォールバック処理

データが不足している場合のフォールバック:

1. **深い睡眠/REM睡眠データなし**: 総睡眠時間から推定（深い睡眠17%、REM22%）
2. **HRVベースラインなし**: 初回は絶対値で判定、2週間後から相対評価
3. **活動量データ一部欠損**: 取得できたコンポーネントのみで按分計算

---

## 6. 更新タイミング

| メトリクス | 更新頻度 | トリガー |
|-----------|---------|---------|
| 睡眠 | 1日1回 | 起床検知時 |
| HRV | 1日1回 | 起床後の安静時HRV取得時 |
| リズム | 1日1回 | 睡眠データ更新時 |
| 活動量 | リアルタイム | 15分ごとのバックグラウンド更新 |
| ストレスグラフ | 5分ごと | バックグラウンド更新 |

---

## 7. 参考文献

- Apple HealthKit Documentation
- 心拍変動解析ガイドライン（日本自律神経学会）
- サーカディアンリズムと健康に関する研究
