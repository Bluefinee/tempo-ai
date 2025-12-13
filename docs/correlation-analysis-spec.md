# 相関分析仕様書

**バージョン**: 1.0
**最終更新**: 2025-12-13
**関連ドキュメント**: [metrics-algorithm-spec.md](./metrics-algorithm-spec.md), [ai-prompt-design.md](./ai-prompt-design.md)

---

## 1. 概要

Tempo AIは、4つのメトリクス（睡眠・HRV・リズム・活動量）およびストレスグラフ間の相関関係を分析し、ユーザーにパーソナライズされたインサイトを提供します。本ドキュメントでは、相関分析のロジックとインサイト生成ルールを定義します。

### 1.1 目的

- ユーザー固有の健康パターンを発見
- 因果関係の仮説をもとにした行動提案
- データに基づいた説得力のあるアドバイス生成

---

## 2. 分析対象の相関ペア

### 2.1 主要相関ペア

| ペア | 相関の意味 | アドバイス方向 |
|------|-----------|--------------|
| HRV ↔ 睡眠 | 睡眠の質がHRV回復に影響 | 「深い睡眠が増えるとHRVが改善」 |
| リズム ↔ 睡眠 | リズム安定が睡眠の質に影響 | 「就寝時刻を固定すると睡眠の質が向上」 |
| 活動量 ↔ HRV | 適度な活動がHRV向上に寄与 | 「日中の活動がHRV回復を促進」 |
| リズム ↔ HRV | リズム安定がHRV安定に影響 | 「規則正しい生活がHRV安定につながる」 |
| 活動量 ↔ 睡眠 | 活動量が睡眠の質に影響 | 「適度な活動で深い睡眠が増加」 |
| ストレスグラフ ↔ HRV | 日中ストレスとHRV朝値の関係 | 「午後のストレス軽減がHRV改善に」 |

### 2.2 分析に必要なデータ期間

| 分析種類 | 最小期間 | 推奨期間 | 精度向上期間 |
|---------|---------|---------|------------|
| 短期相関 | 7日 | 14日 | 21日 |
| 長期トレンド | 30日 | 60日 | 90日 |
| 週末シフト分析 | 14日 | 28日 | 42日 |

---

## 3. 相関係数の算出と解釈

### 3.1 相関係数の閾値と解釈

| 相関係数 (r) | 強度 | ユーザーへの表現 |
|-------------|-----|----------------|
| 0.7 〜 1.0 | 強い正の相関 | 「明らかな関連があります」 |
| 0.4 〜 0.7 | 中程度の正の相関 | 「関連が見られます」 |
| 0.2 〜 0.4 | 弱い正の相関 | 「わずかに関連があるかもしれません」 |
| -0.2 〜 0.2 | 相関なし | （言及しない） |
| -0.4 〜 -0.2 | 弱い負の相関 | 「わずかに逆の関連があるかもしれません」 |
| -0.7 〜 -0.4 | 中程度の負の相関 | 「逆の関連が見られます」 |
| -1.0 〜 -0.7 | 強い負の相関 | 「明らかな逆の関連があります」 |

### 3.2 相関係数の算出

```swift
func calculatePearsonCorrelation(x: [Double], y: [Double]) -> Double {
    guard x.count == y.count, x.count > 2 else { return 0 }

    let n = Double(x.count)
    let sumX = x.reduce(0, +)
    let sumY = y.reduce(0, +)
    let sumXY = zip(x, y).map(*).reduce(0, +)
    let sumX2 = x.map { $0 * $0 }.reduce(0, +)
    let sumY2 = y.map { $0 * $0 }.reduce(0, +)

    let numerator = n * sumXY - sumX * sumY
    let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))

    guard denominator != 0 else { return 0 }
    return numerator / denominator
}
```

### 3.3 統計的有意性

- **最小サンプルサイズ**: n ≥ 7
- **p値閾値**: p < 0.05 で有意と判定
- **信頼区間**: 95%信頼区間を計算し、0を含まない場合に報告

---

## 4. インサイト生成ルール

### 4.1 条件分岐ロジック

```swift
struct CorrelationInsight {
    let pair: MetricPair
    let correlation: Double
    let strength: CorrelationStrength
    let message: String
    let actionSuggestion: String?
}

enum MetricPair: String {
    case hrvSleep = "hrv_sleep"
    case rhythmSleep = "rhythm_sleep"
    case activityHrv = "activity_hrv"
    case rhythmHrv = "rhythm_hrv"
    case activitySleep = "activity_sleep"
    case stressHrv = "stress_hrv"
}

func generateInsight(
    pair: MetricPair,
    correlation: Double,
    recentData: MetricsData
) -> CorrelationInsight? {
    // 弱すぎる相関は報告しない
    guard abs(correlation) >= 0.2 else { return nil }

    let strength = CorrelationStrength.from(correlation)
    let (message, action) = generateMessageAndAction(
        pair: pair,
        correlation: correlation,
        strength: strength,
        recentData: recentData
    )

    return CorrelationInsight(
        pair: pair,
        correlation: correlation,
        strength: strength,
        message: message,
        actionSuggestion: action
    )
}
```

### 4.2 ペア別インサイトテンプレート

#### HRV ↔ 睡眠

| 条件 | インサイト | アクション提案 |
|-----|----------|--------------|
| 強い正相関 + 睡眠低下 | 「睡眠の質がHRVに大きく影響しています」 | 「今夜は30分早く就寝してみましょう」 |
| 中程度正相関 + 深い睡眠不足 | 「深い睡眠とHRVに関連が見られます」 | 「寝室の温度を18-20度に調整してみては」 |
| 弱い正相関 | 「睡眠とHRVにわずかな関連があるようです」 | （なし） |

#### リズム ↔ 睡眠

| 条件 | インサイト | アクション提案 |
|-----|----------|--------------|
| 強い正相関 + リズム乱れ | 「就寝時刻のばらつきが睡眠の質に影響しています」 | 「平日・週末とも同じ時間に寝ることを意識してみましょう」 |
| 中程度正相関 + 週末シフト大 | 「週末の夜更かしが睡眠パターンに影響しているようです」 | 「週末も平日+1時間以内の就寝を目指しては」 |

#### 活動量 ↔ HRV

| 条件 | インサイト | アクション提案 |
|-----|----------|--------------|
| 強い正相関 + 活動量不足 | 「日中の活動がHRV回復に大きく寄与しています」 | 「午前中に15分の散歩を取り入れてみましょう」 |
| 逆U字型パターン | 「適度な活動がベストですが、過度な運動後はHRVが低下する傾向があります」 | 「激しい運動の翌日は休息を意識して」 |

#### 活動量 ↔ 睡眠

| 条件 | インサイト | アクション提案 |
|-----|----------|--------------|
| 強い正相関 + 座りっぱなし | 「日中の活動と睡眠の質に明らかな関連があります」 | 「1時間に1回立ち上がることを意識してみましょう」 |
| 中程度正相関 | 「体を動かした日は深い睡眠が増える傾向があります」 | 「夕方の軽い運動がおすすめです」 |

#### ストレスグラフ ↔ HRV

| 条件 | インサイト | アクション提案 |
|-----|----------|--------------|
| 午後ストレス高 → 翌朝HRV低 | 「午後のストレスが翌朝のHRV回復に影響しています」 | 「15時頃に5分の深呼吸タイムを設けてみては」 |
| 夜間ストレス高 | 「就寝前のストレスレベルが高めです」 | 「寝る前1時間はスマホを控えてみましょう」 |

---

## 5. インサイトの優先順位付け

### 5.1 優先度スコアリング

```swift
func calculateInsightPriority(insight: CorrelationInsight, userData: UserData) -> Int {
    var score = 0

    // 相関強度による基礎スコア
    switch insight.strength {
    case .strong: score += 30
    case .moderate: score += 20
    case .weak: score += 10
    }

    // 改善可能性によるボーナス
    if hasActionableSuggestion(insight) {
        score += 20
    }

    // ユーザーの関心事項によるボーナス
    if matchesUserConcerns(insight, concerns: userData.concerns) {
        score += 25
    }

    // 最近の変化によるボーナス
    if showsRecentChange(insight) {
        score += 15
    }

    return score
}
```

### 5.2 表示ルール

1. **1日に表示するインサイト数**: 最大2件
2. **同一ペアの繰り返し**: 7日間は同じペアのインサイトを表示しない
3. **アクション提案付き優先**: アクションがあるインサイトを優先
4. **ポジティブバランス**: ネガティブなインサイトの後は、必ずポジティブな側面も

---

## 6. データ構造

### 6.1 相関分析結果

```swift
struct CorrelationAnalysisResult {
    let analyzedAt: Date
    let dataRange: DateInterval
    let sampleSize: Int
    let correlations: [MetricPairCorrelation]
    let insights: [CorrelationInsight]
}

struct MetricPairCorrelation {
    let pair: MetricPair
    let coefficient: Double          // -1.0 to 1.0
    let pValue: Double              // 統計的有意性
    let confidenceInterval: (lower: Double, upper: Double)
    let isSignificant: Bool         // p < 0.05
}
```

### 6.2 API レスポンスフォーマット

```json
{
  "correlations": {
    "analyzed_at": "2025-01-15T09:00:00Z",
    "data_range": {
      "start": "2025-01-01",
      "end": "2025-01-14"
    },
    "pairs": [
      {
        "pair": "hrv_sleep",
        "coefficient": 0.72,
        "p_value": 0.001,
        "is_significant": true
      },
      {
        "pair": "rhythm_sleep",
        "coefficient": 0.55,
        "p_value": 0.02,
        "is_significant": true
      }
    ],
    "insights": [
      {
        "pair": "hrv_sleep",
        "strength": "strong",
        "message": "睡眠の質がHRVに大きく影響しています",
        "action": "今夜は30分早く就寝してみましょう"
      }
    ]
  }
}
```

---

## 7. AI連携

### 7.1 Claude APIへのデータ送信

相関分析結果はAIプロンプトの一部としてClaudeに送信され、よりパーソナライズされたアドバイス生成に活用されます。

```json
{
  "user_correlations": {
    "strong_positive": ["hrv_sleep", "activity_hrv"],
    "moderate_positive": ["rhythm_sleep"],
    "notable_patterns": [
      "週末の夜更かし後、月曜のHRVが平均15%低下",
      "8000歩以上の日は深い睡眠が20%増加"
    ]
  }
}
```

### 7.2 プロンプトへの組み込み

詳細は [ai-prompt-analysis.md](./ai/ai-prompt-analysis.md) を参照。

---

## 8. プライバシーとデータ保持

### 8.1 データ保持期間

| データ種類 | 保持期間 | 理由 |
|-----------|---------|-----|
| 日次スコア | 365日 | 年間トレンド分析 |
| 相関分析結果 | 90日 | パターン追跡 |
| インサイト履歴 | 30日 | 重複防止 |

### 8.2 データ削除

ユーザーはいつでも以下を削除可能:
- 全ての健康データ
- 相関分析結果
- インサイト履歴

---

## 9. 将来の拡張

### 9.1 検討中の機能

- **季節変動分析**: 季節による相関パターンの変化
- **外部要因統合**: 天気、気圧との相関
- **予測モデル**: 相関データに基づく翌日スコア予測
- **グループ比較**: 匿名化された集団データとの比較インサイト
