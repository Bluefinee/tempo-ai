# Tempo AI メトリクス仕様書

**バージョン**: 5.0
**最終更新日**: 2025年12月31日

---

## 1. 指標の因果関係

### 1.1 概念

Tempo AI の健康メトリクスは、「原因 → 結果」の因果関係を重視して設計されています。

```
日光浴（原因・アクション）
    ↓ 体内時計をリセット
体温リズム（位相）
    ↓ 睡眠の質に影響
睡眠（結果・回復）
    ↓ 自律神経の回復
HRV（結果・状態）
    ↑
歩数（活動）── 適度な活動が睡眠を促進
```

### 1.2 各指標の役割

| 指標   | 役割 | データソース                                        |
| ------ | ---- | --------------------------------------------------- |
| 日光浴 | 原因 | `HKQuantityTypeIdentifier.timeInDaylight`           |
| 体温   | 位相 | `HKQuantityTypeIdentifier.appleSleepingWristTemperature` |
| 睡眠   | 結果 | `HKCategoryTypeIdentifier.sleepAnalysis`            |
| HRV    | 結果 | `HKQuantityTypeIdentifier.heartRateVariabilitySDNN` |
| 歩数   | 活動 | `HKQuantityTypeIdentifier.stepCount`                |

### 1.3 スコアの用途

各指標のスコア（0-100）は、5 段階ゲージに変換して UI に表示します。

| スコア範囲 | ゲージ | 色                |
| ---------- | ------ | ----------------- |
| 80-100     | ●●●●●  | Primary (#7CB342) |
| 60-79      | ●●●●○  | Primary (#7CB342) |
| 40-59      | ●●●○○  | Yellow (#FFC107)  |
| 20-39      | ●●○○○  | Orange (#FF9800)  |
| 0-19       | ●○○○○  | Red (#F44336)     |

---

## 2. メトリクス一覧

### 2.1 主要メトリクス

| メトリクス | 役割         | スコア範囲 | データソース |
| ---------- | ------------ | ---------- | ------------ |
| HRV        | 結果指標     | 0-100      | HealthKit    |
| 睡眠       | 結果指標     | 0-100      | HealthKit    |
| 歩数       | 活動指標     | 0-100      | HealthKit    |
| 日光浴     | 原因指標     | 0-100      | HealthKit    |
| 体温       | 位相（ズレ） | ステータス | HealthKit    |

---

## 3. HRV スコア

### 3.1 算出式

```
総合スコア = ベースライン比較(70) + トレンド(30)
```

### 3.2 コンポーネント

| コンポーネント   | 配点  | 算出方法                                       |
| ---------------- | ----- | ---------------------------------------------- |
| ベースライン比較 | 70 点 | 7 日平均との比較。100%で 70 点、比例配分       |
| トレンド         | 30 点 | 昨日より上昇: 30 点、横ばい: 20 点、下降: 10 点 |

### 3.3 算出ロジック

```swift
struct HRVMetric {
    let todayValue: Double      // 今日のHRV (ms)
    let average7d: Double       // 7日平均
    let yesterdayValue: Double  // 昨日のHRV

    var score: Int {
        let baselineScore = min(70, Int((todayValue / average7d) * 70))

        let trendScore: Int
        if todayValue > yesterdayValue * 1.05 {
            trendScore = 30  // 5%以上上昇
        } else if todayValue >= yesterdayValue * 0.95 {
            trendScore = 20  // 横ばい（±5%）
        } else {
            trendScore = 10  // 5%以上下降
        }

        return min(100, baselineScore + trendScore)
    }

    var differencePercent: Int {
        Int(((todayValue - average7d) / average7d) * 100)
    }

    var comment: String {
        switch score {
        case 80...100: return "自律神経は最高の状態"
        case 60..<80: return "良いコンディションです"
        case 40..<60: return "少し疲れ気味かも"
        case 20..<40: return "休息を意識しましょう"
        default: return "しっかり休んでください"
        }
    }
}
```

---

## 4. 睡眠スコア

### 4.1 算出式

```
総合スコア = 睡眠時間(50) + 深い睡眠(30) + タイミング(20)
```

### 4.2 コンポーネント

| コンポーネント | 配点  | 算出方法                                             |
| -------------- | ----- | ---------------------------------------------------- |
| 睡眠時間       | 50 点 | 7-9 時間で満点、6 時間で 35 点、5 時間以下で 20 点   |
| 深い睡眠       | 30 点 | 総睡眠の 15%以上で満点、10%で 20 点、それ以下で 10 点 |
| タイミング     | 20 点 | 22-24 時就寝で満点、24-1 時で 15 点、1 時以降で 5 点  |

### 4.3 算出ロジック

```swift
struct SleepMetric {
    let duration: TimeInterval      // 総睡眠時間（秒）
    let deepSleep: TimeInterval     // 深い睡眠時間（秒）
    let bedtime: Date               // 就寝時刻

    var hours: Double {
        duration / 3600
    }

    var score: Int {
        // 睡眠時間（50点満点）
        let durationScore: Int
        switch hours {
        case 7...9: durationScore = 50
        case 6..<7: durationScore = 35
        case 5..<6: durationScore = 25
        default: durationScore = 15
        }

        // 深い睡眠（30点満点）
        let deepRatio = duration > 0 ? deepSleep / duration : 0
        let deepScore: Int
        switch deepRatio {
        case 0.15...: deepScore = 30
        case 0.10..<0.15: deepScore = 20
        default: deepScore = 10
        }

        // タイミング（20点満点）
        let hour = Calendar.current.component(.hour, from: bedtime)
        let timingScore: Int
        switch hour {
        case 22, 23: timingScore = 20
        case 0: timingScore = 15
        case 1: timingScore = 10
        default: timingScore = 5
        }

        return durationScore + deepScore + timingScore
    }

    var comment: String {
        switch score {
        case 80...100: return "理想的な睡眠でした"
        case 60..<80: return "十分な睡眠時間"
        case 40..<60: return "もう少し眠れると◎"
        case 20..<40: return "睡眠不足気味です"
        default: return "睡眠を優先しましょう"
        }
    }
}
```

### 4.4 フォールバック

深い睡眠データがない場合: 総睡眠時間から推定（深い睡眠 17%と仮定）

---

## 5. 歩数スコア

### 5.1 算出式

```
総合スコア = 歩数達成(70) + 7日平均比較(30)
```

### 5.2 コンポーネント

| コンポーネント | 配点  | 算出方法                                         |
| -------------- | ----- | ------------------------------------------------ |
| 歩数達成       | 70 点 | 8000 歩で満点、比例配分（上限 8000 歩）          |
| 7 日平均比較   | 30 点 | 平均以上: 30 点、80-100%: 20 点、80%未満: 10 点  |

### 5.3 算出ロジック

```swift
struct StepsMetric {
    let todaySteps: Int     // 今日の歩数
    let average7d: Int      // 7日平均

    static let targetSteps = 8000

    var score: Int {
        // 歩数達成（70点満点）
        let achievementScore = min(70, (todaySteps * 70) / Self.targetSteps)

        // 7日平均比較（30点満点）
        let ratio = average7d > 0 ? Double(todaySteps) / Double(average7d) : 1.0
        let comparisonScore: Int
        switch ratio {
        case 1.0...: comparisonScore = 30
        case 0.8..<1.0: comparisonScore = 20
        default: comparisonScore = 10
        }

        return min(100, achievementScore + comparisonScore)
    }

    var comment: String {
        switch score {
        case 80...100: return "素晴らしい活動量"
        case 60..<80: return "良いペースです"
        case 40..<60: return "もう少し動けると◎"
        case 20..<40: return "少し歩いてみましょう"
        default: return "体を動かしましょう"
        }
    }
}
```

---

## 6. 日光浴スコア

### 6.1 データソース

HealthKit `HKQuantityTypeIdentifier.timeInDaylight`

### 6.2 算出式

```
総合スコア = 日光時間(70) + タイミング(30)
```

### 6.3 コンポーネント

| コンポーネント | 配点  | 算出方法                                                   |
| -------------- | ----- | ---------------------------------------------------------- |
| 日光時間       | 70 点 | 30 分で満点、比例配分                                      |
| タイミング     | 30 点 | 午前中（12 時まで）に 10 分以上: 30 点、午後のみ: 15 点、なし: 0 点 |

### 6.4 算出ロジック

```swift
struct DaylightMetric {
    let totalMinutes: Int       // 総日光浴時間（分）
    let morningMinutes: Int     // 午前中の日光浴時間（分）

    static let targetMinutes = 30

    var score: Int {
        // 日光時間（70点満点）
        let durationScore = min(70, (totalMinutes * 70) / Self.targetMinutes)

        // タイミング（30点満点）- 午前中の光浴を重視
        let timingScore: Int
        if morningMinutes >= 10 {
            timingScore = 30
        } else if totalMinutes > 0 {
            timingScore = 15
        } else {
            timingScore = 0
        }

        return min(100, durationScore + timingScore)
    }

    var remainingMinutes: Int {
        max(0, Self.targetMinutes - totalMinutes)
    }

    var needsWarning: Bool {
        totalMinutes < 20
    }

    var comment: String {
        if remainingMinutes > 0 {
            return "あと\(remainingMinutes)分浴びましょう"
        }
        switch score {
        case 80...100: return "十分な日光を浴びています"
        case 60..<80: return "あと少しで目標達成"
        default: return "外に出て日光を浴びましょう"
        }
    }
}
```

### 6.5 午前中の日光が重要な理由

朝の光（特に起床後 2 時間以内）は、体内時計のリセットに最も効果的です。
午後の光では体内時計のリセット効果が弱まるため、タイミングに 30 点を配分しています。

---

## 7. 手首皮膚温（位相ズレ）

### 7.1 データソース

HealthKit `HKQuantityTypeIdentifier.appleSleepingWristTemperature`

### 7.2 対応機種

- Apple Watch Series 8 以降
- Apple Watch Ultra 以降

### 7.3 用途

体内時計の「位相（Phase）」を推定するために使用。
皮膚温のリズム（夜高く、朝下がる）から、体内時計のズレを検出します。

**注意**: スコア化せず、ステータス表示のみ。

### 7.4 算出ロジック

```swift
struct TemperatureMetric {
    let phaseShiftHours: Double     // 位相ズレ（時間）。正=遅れ、負=進み
    let isAvailable: Bool           // データが利用可能か
    let nightsOfData: Int           // データ収集日数

    static let requiredNights = 5

    var hasEnoughData: Bool {
        nightsOfData >= Self.requiredNights
    }

    var status: PhaseStatus {
        guard hasEnoughData else { return .collecting }

        switch phaseShiftHours {
        case -0.5...0.5: return .synced
        case 0.5..<1.5: return .slightlyLate
        case 1.5...: return .late
        case -1.5..<(-0.5): return .slightlyEarly
        default: return .early
        }
    }

    var comment: String {
        switch status {
        case .collecting:
            return "データ収集中（あと\(Self.requiredNights - nightsOfData)晩）"
        case .synced:
            return "体内時計は整っています"
        case .slightlyLate:
            return "少し遅れ気味です"
        case .late:
            return "⚠️ 朝の光浴を増やしましょう"
        case .slightlyEarly:
            return "少し進み気味です"
        case .early:
            return "⚠️ 夕方の光を控えましょう"
        }
    }

    var gaugeLevel: Int {
        switch status {
        case .synced: return 5
        case .slightlyLate, .slightlyEarly: return 3
        case .late, .early: return 2
        case .collecting: return 0  // ゲージ非表示
        }
    }
}

enum PhaseStatus {
    case collecting     // データ収集中
    case synced         // 同期（±30分）
    case slightlyLate   // やや遅れ（+30分〜+1.5時間）
    case late           // 遅れ（+1.5時間以上）
    case slightlyEarly  // やや進み（-30分〜-1.5時間）
    case early          // 進み（-1.5時間以上）
}
```

### 7.5 表示条件

- 非対応機種: 項目自体を非表示
- データ不足時: 「データ収集中（あと ◯ 晩）」と表示、ゲージ非表示
- データ十分時: ステータス + コメント + ゲージ

---

## 8. 統合ドメインモデル

### 8.1 設計原則

スコア算出ロジックは各指標のドメインモデルに凝集させ、View 層や Service 層に分散させない。

### 8.2 ファイル構成

```
ios/TempoAI/TempoAI/Domain/
├── Models/
│   ├── RhythmMetrics.swift         # 全指標を統合
│   ├── HRVMetric.swift             # HRV指標
│   ├── SleepMetric.swift           # 睡眠指標
│   ├── StepsMetric.swift           # 歩数指標
│   ├── DaylightMetric.swift        # 日光浴指標
│   └── TemperatureMetric.swift     # 体温指標
```

### 8.3 統合モデル

```swift
struct RhythmMetrics {
    let hrv: HRVMetric
    let sleep: SleepMetric
    let steps: StepsMetric
    let daylight: DaylightMetric
    let temperature: TemperatureMetric?  // 対応機種のみ

    let fetchedAt: Date

    /// 5段階ゲージに変換
    static func scoreToGauge(_ score: Int) -> Int {
        switch score {
        case 80...100: return 5
        case 60..<80: return 4
        case 40..<60: return 3
        case 20..<40: return 2
        default: return 1
        }
    }
}
```

### 8.4 責務の分離

| レイヤー              | 責務                                     |
| --------------------- | ---------------------------------------- |
| Domain/Models         | スコア算出、コメント生成、バリデーション |
| Services/HealthKitManager | HealthKit からの生データ取得のみ     |
| Features/Views        | 表示のみ（ロジックを持たない）           |

---

## 9. 24 時間サークル図

### 9.1 データ構造

```swift
struct CircadianCircleData {
    let sunriseTime: Date           // 日の出時刻
    let sunsetTime: Date            // 日の入り時刻
    let currentTime: Date           // 現在時刻
    let phaseShiftHours: Double?    // 体内時計のズレ（体温データから推定）
}
```

### 9.2 角度計算

```swift
// 時刻を角度に変換（0:00 = -90度、6:00 = 0度、12:00 = 90度、18:00 = 180度）
func angleForTime(_ date: Date) -> Double {
    let hour = Calendar.current.component(.hour, from: date)
    let minute = Calendar.current.component(.minute, from: date)
    let totalMinutes = Double(hour * 60 + minute)
    return (totalMinutes / 1440.0) * 360.0 - 90.0
}
```

---

## 10. データ要件

### 10.1 必要な HealthKit データ

| メトリクス | HealthKit Type                                       | 必須/任意 |
| ---------- | ---------------------------------------------------- | --------- |
| 睡眠       | HKCategoryType(.sleepAnalysis)                       | 必須      |
| 深い睡眠   | HKCategoryValueSleepAnalysis.asleepDeep              | 任意      |
| HRV        | HKQuantityType(.heartRateVariabilitySDNN)            | 必須      |
| 歩数       | HKQuantityType(.stepCount)                           | 必須      |
| 日光浴     | HKQuantityType(.timeInDaylight)                      | 任意      |
| 皮膚温     | HKQuantityType(.appleSleepingWristTemperature)       | 任意      |

### 10.2 更新タイミング

| メトリクス | 更新頻度                           |
| ---------- | ---------------------------------- |
| HRV        | 1 日 1 回（起床後の安静時）        |
| 睡眠       | 1 日 1 回（起床検知時）            |
| 歩数       | 15 分ごと（バックグラウンド更新） |
| 日光浴     | 15 分ごと（バックグラウンド更新） |
| 皮膚温     | 1 日 1 回（睡眠データ更新時）      |

---

## 11. v1.1 予定：相関分析

> **注意**: この機能は MVP スコープ外です。

### 11.1 概要

「あなたのパターン」として、ユーザー固有の相関を散布図とインサイト文で可視化。

### 11.2 表示条件

14 日以上のデータ蓄積後

### 11.3 分析対象

| 分析           | 縦軸       | 横軸         |
| -------------- | ---------- | ------------ |
| 睡眠時間→HRV   | 翌朝 HRV   | 前日睡眠時間 |
| 就寝時刻→HRV   | 翌朝 HRV   | 前日就寝時刻 |
| 歩数→深い睡眠  | 深い睡眠時間 | 前日歩数     |
| 日光浴→睡眠    | 睡眠スコア | 前日日光浴時間 |

---

## 関連ドキュメント

| ドキュメント                         | 内容       |
| ------------------------------------ | ---------- |
| [product-spec.md](./product-spec.md) | 機能要件   |
| [ui-spec.md](./ui-spec.md)           | UI 表示方法 |
