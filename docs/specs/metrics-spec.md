# Tempo AI メトリクス仕様書

**バージョン**: 4.0  
**最終更新日**: 2025年12月19日

---

## 1. 自律神経の三角形

### 1.1 概念

Tempo AIの健康メトリクスは、**HRV・睡眠・歩数の三角形**を核心コンセプトとして設計されています。

```
        HRV（結果 = 今日のコンディション）
           ▲
          / \
         /   \
        /     \
       ▼───────▼
    睡眠      歩数
   （回復）  （活動）
```

### 1.2 因果関係

| 関係 | 説明 |
|------|------|
| 歩数 → 睡眠 | 日中の適度な活動が睡眠の質を向上 |
| 睡眠 → HRV | 良質な睡眠が自律神経の回復を促進 |
| 歩数 → HRV | 過度な活動・活動不足はHRVに悪影響 |

### 1.3 サーカディアンリズムの位置づけ

サーカディアンリズム（体内時計の安定性）は、三角形全体の**土台**として機能します。

---

## 2. メトリクス一覧

### 2.1 主要メトリクス（三角形）

| メトリクス | 役割 | スコア範囲 | データソース |
|-----------|------|-----------|-------------|
| HRV | 結果指標 | 0-100 | HealthKit |
| 睡眠 | 原因指標（回復） | 0-100 | HealthKit |
| 活動量（歩数） | 原因指標（活動） | 0-100 | HealthKit |

### 2.2 補助メトリクス

| メトリクス | 用途 |
|-----------|------|
| サーカディアンリズム | 三角形の土台、リズム安定度表示 |

---

## 3. サーカディアンリズムスコア

### 3.1 算出式

```
総合スコア = 就寝時刻安定度(35) + 起床時刻安定度(35) + 週末シフト(20) + 理想時間帯(10)
```

### 3.2 コンポーネント

| コンポーネント | 配点 | 算出方法 |
|---------------|------|---------|
| 就寝時刻安定度 | 35点 | 過去7日間の標準偏差、30分以内で満点 |
| 起床時刻安定度 | 35点 | 過去7日間の標準偏差、30分以内で満点 |
| 週末シフト | 20点 | 平日と週末の差、1時間以内で満点 |
| 理想時間帯 | 10点 | 22:00-6:00の範囲内か |

### 3.3 算出ロジック

```swift
func calculateRhythmScore(
    bedtimes: [Date],           // 過去7日間の就寝時刻
    wakeups: [Date],            // 過去7日間の起床時刻
    weekdayBedtimeAvg: Date,
    weekendBedtimeAvg: Date
) -> Int {
    // 就寝時刻安定度 (35点)
    let bedtimeStdDev = calculateStandardDeviation(bedtimes)
    let bedtimeScore = max(0, 35 - (bedtimeStdDev / 60 / 30) * 35)

    // 起床時刻安定度 (35点)
    let wakeupStdDev = calculateStandardDeviation(wakeups)
    let wakeupScore = max(0, 35 - (wakeupStdDev / 60 / 30) * 35)

    // 週末シフト (20点)
    let weekendShiftMinutes = abs(weekdayBedtimeAvg - weekendBedtimeAvg) / 60
    let weekendScore = max(0, 20 - (weekendShiftMinutes / 60) * 10)

    // 理想時間帯 (10点)
    let idealScore = calculateIdealRangeScore(bedtimes, wakeups)

    return Int(bedtimeScore + wakeupScore + weekendScore + idealScore)
}
```

---

## 4. 睡眠スコア

### 4.1 算出式

```
総合スコア = 睡眠時間(40) + 深い睡眠(25) + REM睡眠(20) + 睡眠効率(10) + タイミング(5)
```

### 4.2 コンポーネント

| コンポーネント | 配点 | 算出方法 |
|---------------|------|---------|
| 睡眠時間 | 40点 | 7-9時間で満点 |
| 深い睡眠 | 25点 | 総睡眠の15-20%で満点 |
| REM睡眠 | 20点 | 総睡眠の20-25%で満点 |
| 睡眠効率 | 10点 | 実睡眠/ベッド時間 85%以上で満点 |
| タイミング | 5点 | 22:00-24:00就寝で満点 |

### 4.3 フォールバック

深い睡眠/REM睡眠データがない場合：総睡眠時間から推定（深い睡眠17%、REM22%）

---

## 5. HRVスコア

### 5.1 算出式

```
総合スコア = 個人ベースライン比較(50) + 7日トレンド(25) + 安静時心拍数(25)
```

### 5.2 コンポーネント

| コンポーネント | 配点 | 算出方法 |
|---------------|------|---------|
| ベースライン比較 | 50点 | 過去30日平均との比較、±20%以内で満点 |
| 7日トレンド | 25点 | 上昇傾向で加点 |
| 安静時心拍数 | 25点 | 個人のベースラインとの比較 |

### 5.3 フォールバック

HRVベースラインがない場合：初回は絶対値で判定、2週間後から相対評価

---

## 6. 活動量スコア

### 6.1 算出式

```
総合スコア = 歩数(40) + アクティブ時間(30) + 座りっぱなし回避(20) + 運動完了(10)
```

### 6.2 コンポーネント

| コンポーネント | 配点 | 算出方法 |
|---------------|------|---------|
| 歩数 | 40点 | 目標8,000歩に対する達成率 |
| アクティブ時間 | 30点 | 中〜高強度30分以上で満点 |
| 座りっぱなし回避 | 20点 | 1時間以上の連続座位回避 |
| 運動完了 | 10点 | 設定した運動目標の達成 |

---

## 7. ステータス判定

### 7.1 共通判定ルール

| スコア範囲 | ステータス |
|-----------|----------|
| 80-100 | 最高 |
| 60-79 | 良好 |
| 40-59 | 普通 |
| 20-39 | やや低下 |
| 0-19 | 要改善 |

---

## 8. 24時間サークル図

### 8.1 データ構造

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
}

struct HRVData {
    let currentValue: Double
    let sevenDayAverage: Double
    
    var differencePercent: Double {
        ((currentValue - sevenDayAverage) / sevenDayAverage) * 100
    }
}
```

### 8.2 角度計算

```swift
// 時刻を角度に変換（0:00 = 0度、12:00 = 180度）
func angleForTime(_ date: Date) -> Double {
    let hour = Calendar.current.component(.hour, from: date)
    let minute = Calendar.current.component(.minute, from: date)
    let totalMinutes = Double(hour * 60 + minute)
    return (totalMinutes / 1440.0) * 360.0 - 90.0
}
```

---

## 9. データ要件

### 9.1 必要なHealthKitデータ

| メトリクス | HealthKit Type | 必須/任意 |
|-----------|---------------|----------|
| 睡眠 | HKCategoryType(.sleepAnalysis) | 必須 |
| 深い睡眠 | HKCategoryValueSleepAnalysis.asleepDeep | 任意 |
| REM睡眠 | HKCategoryValueSleepAnalysis.asleepREM | 任意 |
| HRV | HKQuantityType(.heartRateVariabilitySDNN) | 必須 |
| 心拍数 | HKQuantityType(.heartRate) | 必須 |
| 歩数 | HKQuantityType(.stepCount) | 必須 |

### 9.2 更新タイミング

| メトリクス | 更新頻度 |
|-----------|---------|
| サーカディアンリズム | 1日1回（睡眠データ更新時） |
| 睡眠 | 1日1回（起床検知時） |
| HRV | 1日1回（起床後の安静時） |
| 活動量 | 15分ごと（バックグラウンド更新） |

---

## 10. v1.1予定：相関分析

> **注意**: この機能はMVPスコープ外です。

### 10.1 概要

「あなたのパターン」として、ユーザー固有の相関を散布図とインサイト文で可視化。

### 10.2 表示条件

14日以上のデータ蓄積後

### 10.3 分析対象

| 分析 | 縦軸 | 横軸 |
|------|------|------|
| 睡眠時間→HRV | 翌朝HRV | 前日睡眠時間 |
| 就寝時刻→HRV | 翌朝HRV | 前日就寝時刻 |
| 歩数→深い睡眠 | 深い睡眠時間 | 前日歩数 |

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [product-spec.md](./product-spec.md) | 機能要件 |
| [ui-spec.md](./ui-spec.md) | UI表示方法 |
