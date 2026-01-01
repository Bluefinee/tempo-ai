# TempoAI メトリクス・スコアリング仕様書

**バージョン**: 1.0  
**最終更新日**: 2025年1月1日

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [tempoai_product_spec.md](./tempoai_product_spec.md) | プロダクト仕様 |
| [tempoai_technical_spec.md](./tempoai_technical_spec.md) | 技術仕様 |
| [tempoai_ai_prompt_spec.md](./tempoai_ai_prompt_spec.md) | AIプロンプト仕様 |
| [tempoai_knowledge_base.md](./tempoai_knowledge_base.md) | 科学的根拠・ナレッジベース |

---

## 1. スコア体系概要

TempoAIでは、サーカディアンリズムと自律神経の状態を4つのスコアで評価する。

| スコア | 評価対象 | 重要度 |
|--------|---------|--------|
| **Autonomic Score** | 自律神経のバランス（HRV中心） | ★★★ |
| **Sleep Score** | 睡眠の質と量 | ★★★ |
| **Rhythm Score** | 生活リズムの規則性 | ★★☆ |
| **Activity Score** | 活動量の適切さ | ★☆☆ |

---

## 2. Autonomic Score（自律神経スコア）

### 2.1 概要

HRV（心拍変動）を中心に、自律神経の回復状態を0〜100で評価。

> **科学的根拠**: HRVが高いほど副交感神経が優位でリラックス・回復状態。低いほど交感神経優位で過緊張状態。詳細は [tempoai_knowledge_base.md](./tempoai_knowledge_base.md) Section 2参照。

### 2.2 計算ロジック

#### Step 1: ベースライン確立

```
baseline_hrv = 直近30日のHRV平均値
※夜間・安静時の測定値を優先（最も信頼性が高い）
```

#### Step 2: 日次比較

```
hrv_ratio = today_hrv / baseline_hrv
```

#### Step 3: 正規化（0〜100）

```
// ベースライン = 70点を基準
base_score = 70

// 差分をスコアに反映（±30%で±30点）
deviation = (hrv_ratio - 1.0) * 100  // パーセント差分
raw_score = base_score + deviation

// 0〜100にクランプ
autonomic_score = clamp(raw_score, 0, 100)
```

#### Step 4: 補正要素の適用（オプション）

| 補正要素 | 条件 | 補正値 |
|---------|------|--------|
| 深い睡眠不足 | deep_sleep_ratio < 0.15 | -5 |
| 安静時心拍数上昇 | resting_hr > baseline + 5 | -5 |
| 睡眠時間不足 | sleep_hours < 6 | -5 |

### 2.3 ステータスアイコン

| スコア範囲 | アイコン | ラベル |
|-----------|---------|--------|
| 80〜100 | ☀️ | 絶好調 |
| 60〜79 | ⛅ | 良好 |
| 40〜59 | 🌥️ | 普通 |
| 20〜39 | 🌧️ | 要休息 |
| 0〜19 | ⛈️ | 休養優先 |

### 2.4 AIコメント対応

| スコア範囲 | コメント例 |
|-----------|-----------|
| 80-100 | 「今日は絶好調ですね」「最高のコンディションです」 |
| 60-79 | 「いいコンディションです」「調子は良さそうですね」 |
| 40-59 | 「無理せずペース配分を」「今日は程よく休憩を」 |
| 20-39 | 「今日は休息を優先しましょう」「回復を意識した1日に」 |
| 0-19 | 「しっかり休んでくださいね」「まずは休養が大切です」 |

---

## 3. Sleep Score（睡眠スコア）

### 3.1 概要

睡眠の質と量を総合的に0〜100で評価。

### 3.2 計算ロジック

#### 構成要素と重み

| 要素 | 重み | 評価基準 |
|------|------|---------|
| **睡眠時間** | 40% | 目標時間に対する達成度 |
| **深い睡眠** | 30% | 全体の15-25%が理想 |
| **レム睡眠** | 20% | 全体の20-25%が理想 |
| **入眠効率** | 10% | 就寝から入眠までの時間 |

#### 睡眠時間スコア

```
// 目標: 7-8時間
if (sleep_hours >= 7 && sleep_hours <= 8) {
  duration_score = 100
} else if (sleep_hours >= 6 && sleep_hours < 7) {
  duration_score = 80
} else if (sleep_hours > 8 && sleep_hours <= 9) {
  duration_score = 90
} else if (sleep_hours >= 5 && sleep_hours < 6) {
  duration_score = 60
} else {
  duration_score = 40
}
```

#### 深い睡眠スコア

```
deep_ratio = deep_sleep_minutes / total_sleep_minutes

// 理想: 15-25%
if (deep_ratio >= 0.15 && deep_ratio <= 0.25) {
  deep_score = 100
} else if (deep_ratio >= 0.10 && deep_ratio < 0.15) {
  deep_score = 70
} else if (deep_ratio > 0.25 && deep_ratio <= 0.30) {
  deep_score = 80
} else {
  deep_score = 50
}
```

#### 総合スコア計算

```
sleep_score = 
  duration_score * 0.4 +
  deep_score * 0.3 +
  rem_score * 0.2 +
  efficiency_score * 0.1
```

---

## 4. Rhythm Score（リズム規則性スコア）

### 4.1 概要

サーカディアンリズムの規則性を0〜100で評価。

> **科学的根拠**: 就寝・起床時刻の一貫性がサーカディアンリズムの安定に直結。詳細は [tempoai_knowledge_base.md](./tempoai_knowledge_base.md) Section 1参照。

### 4.2 計算ロジック

#### 構成要素と重み

| 要素 | 重み | 評価方法 |
|------|------|---------|
| **就寝時刻の一貫性** | 35% | 過去7日間の標準偏差 |
| **起床時刻の一貫性** | 35% | 過去7日間の標準偏差 |
| **手首体温パターン** | 20% | 夜間の正常な低下（対応機種のみ） |
| **睡眠ステージ移行** | 10% | 深い睡眠→レム睡眠の正常な移行 |

#### 時刻一貫性スコア

```
// 標準偏差（分）からスコアを算出
function consistencyScore(stddev_minutes) {
  if (stddev_minutes <= 15) return 100  // 非常に安定
  if (stddev_minutes <= 30) return 85   // 安定
  if (stddev_minutes <= 45) return 70   // やや安定
  if (stddev_minutes <= 60) return 55   // やや不安定
  if (stddev_minutes <= 90) return 40   // 不安定
  return 25                              // 非常に不安定
}

bedtime_score = consistencyScore(bedtime_stddev)
waketime_score = consistencyScore(waketime_stddev)
```

#### 手首体温パターンスコア（対応機種のみ）

| パターン | スコア | 判定基準 |
|---------|--------|---------|
| normal | 100 | 夜間に0.3-0.5℃低下 |
| slightly_delayed | 70 | 低下開始が1時間以上遅延 |
| abnormal | 40 | 低下パターンが不明確 |

#### 総合スコア計算

```
// 手首体温データがある場合
rhythm_score = 
  bedtime_score * 0.35 +
  waketime_score * 0.35 +
  temperature_score * 0.20 +
  stage_transition_score * 0.10

// 手首体温データがない場合（重み再配分）
rhythm_score = 
  bedtime_score * 0.45 +
  waketime_score * 0.45 +
  stage_transition_score * 0.10
```

### 4.3 リズム安定度ステータス

連続して安定したリズムを維持している日数を追跡。

| 連続安定日数 | ステータス |
|-------------|-----------|
| 5日以上 | 「安定」 |
| 3-4日 | 「回復中」 |
| 0-2日 | 「乱れ気味」 |

**安定の条件**: Rhythm Score ≥ 70

---

## 5. Activity Score（活動量スコア）

### 5.1 概要

活動量の適切さを0〜100で評価。

### 5.2 計算ロジック

#### 構成要素と重み

| 要素 | 重み | 評価基準 |
|------|------|---------|
| **歩数** | 60% | 目標歩数に対する達成度 |
| **運動時間** | 40% | アクティブな時間 |

#### 歩数スコア

```
// 目標: 8,000歩
step_ratio = steps / 8000

if (step_ratio >= 1.0) {
  step_score = 100
} else if (step_ratio >= 0.75) {
  step_score = 80 + (step_ratio - 0.75) * 80  // 80-100
} else if (step_ratio >= 0.5) {
  step_score = 60 + (step_ratio - 0.5) * 80   // 60-80
} else {
  step_score = step_ratio * 120               // 0-60
}
```

#### 総合スコア計算

```
activity_score = step_score * 0.6 + exercise_score * 0.4
```

---

## 6. 補助データの活用

### 6.1 日光暴露時間

> 対応機種: watchOS 10+ (SE2, Series 6以降)

| 昨日の日光暴露 | ステータス | AIへの示唆 |
|---------------|-----------|-----------|
| 45分以上 | 十分 | 言及不要 |
| 30-44分 | やや不足 | 軽い言及 |
| 30分未満 | 不足 | 因果関係で説明 |

**AIでの活用例**:
- 日光不足 + 入眠遅延 → 「日光浴不足によるメラトニン分泌遅延」として言及
- 日光十分 + 睡眠良好 → ポジティブな因果関係として言及

### 6.2 手首体温

> 対応機種: Series 8+, Ultra

| 偏差 | ステータス | 意味 |
|------|-----------|------|
| ±0.2℃以内 | 安定 | 正常なサーカディアンリズム |
| ±0.2-0.5℃ | やや変動 | 軽度のリズム乱れの可能性 |
| ±0.5℃以上 | 変動大 | 体内時計の乱れ or 体調変化 |

**AIでの活用例**:
- 皮膚温変動大 + HRV低下 → 「体内時計の後退」として因果説明
- 皮膚温安定 → 言及不要（正常時は省略）

---

## 7. スコアの総合活用

### 7.1 Claudeへの送信形式

```xml
<scores>
  <sleep>78</sleep>
  <hrv>85</hrv>
  <rhythm>72</rhythm>
  <activity>52</activity>
</scores>
<rhythm_stability>
  <status>良好</status>
  <consecutive_stable_days>3</consecutive_stable_days>
</rhythm_stability>
```

### 7.2 AIインサイト生成への活用

| 最もスコアが低い項目 | インサイトの焦点 |
|-------------------|----------------|
| Sleep Score | 睡眠改善の因果説明 |
| Autonomic Score | 回復・休息の必要性 |
| Rhythm Score | リズム調整の提案 |
| Activity Score | 活動量増加の提案 |

### 7.3 Daily Try選択への活用

1. 最もスコアが低いメトリクスを特定
2. そのメトリクス改善に関連するDaily Tryを優先
3. 過去2週間と重複しないものを選択

---

## 8. 実装上の注意点

### 8.1 キャリブレーション期間（初期7日間）

**目的**: HRVベースラインやリズムの標準偏差を正確に計算するためのデータ蓄積期間。

**UI表示**:
- スコアは「---」と表示（数値を出さない）
- 「あなたのリズムを学習中... あと○日」のプログレスバー

**判定ロジック**:
```swift
struct CalibrationManager {
    static let requiredDays = 7
    
    static func shouldShowScores(healthDataDays: Int, existingDataDays: Int) -> Bool {
        // 既に30日以上のデータがある場合はスキップ
        if existingDataDays >= 30 { return true }
        // 7日以上のデータがある場合はスコア表示
        return healthDataDays >= requiredDays
    }
    
    static func progressRatio(healthDataDays: Int) -> Double {
        min(1.0, Double(healthDataDays) / Double(requiredDays))
    }
}
```

**スコア計算の代替**:
- ベースラインがない場合、業界平均値を仮のベースラインとして使用
- ただしUIではスコアを表示せず、AIコメント主体で対応

| データ | 仮ベースライン |
|--------|---------------|
| HRV | 50ms |
| 安静時心拍数 | 60bpm |
| 睡眠時間 | 7時間 |

### 8.2 データ不足時の対応

| 状況 | 対応 |
|------|------|
| HRVデータが3日未満 | ベースラインを業界平均（50ms）で代替 |
| 睡眠データなし | Sleep Scoreを算出せず、AIに「データ不足」を伝達 |
| 手首体温非対応機種 | Rhythm Scoreの重み再配分 |

### 8.3 異常値の除外

```
// HRVの異常値フィルタ
if (hrv_value < 10 || hrv_value > 200) {
  // 測定エラーとして除外
}

// 睡眠時間の異常値フィルタ
if (sleep_hours < 1 || sleep_hours > 14) {
  // 記録エラーとして除外
}
```

### 8.4 計算タイミング

- **起動時**: 全スコアを再計算
- **Pull-to-refresh時**: 全スコアを再計算
- **バックグラウンド**: 1日1回（起床予定時刻の1時間前）に事前計算

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-01-01 | 初版作成 |
| 2.0 | 2025-01-01 | Geminiフィードバック反映: キャリブレーション期間の対応を追加 |
