# AI プロンプト設計 - データ分析・インサイト生成

**バージョン**: 1.0
**最終更新日**: 2025年12月13日
**関連ドキュメント**: [ai-prompt-core.md](./ai-prompt-core.md), [correlation-analysis-spec.md](../correlation-analysis-spec.md), [metrics-algorithm-spec.md](../metrics-algorithm-spec.md)

---

## 目次

1. [概要](#1-概要)
2. [Layer 3: ユーザーデータ構造](#2-layer-3-ユーザーデータ構造)
3. [メトリクスデータのJSON形式](#3-メトリクスデータのjson形式)
4. [相関分析データの活用](#4-相関分析データの活用)
5. [インサイト生成ルール](#5-インサイト生成ルール)
6. [追加アドバイス用プロンプト](#6-追加アドバイス用プロンプト)

---

## 1. 概要

本ドキュメントでは、AI（Claude API）へのデータ送信フォーマットと、相関分析データを活用したインサイト生成のルールを定義します。

### 1.1 新メトリクス体系

Tempo AIは以下の4つのメトリクスとストレスグラフでユーザーの健康状態を可視化します：

| メトリクス | 概念 | スコア範囲 |
|-----------|------|-----------|
| 睡眠 | 睡眠の質と量 | 0-100 |
| HRV | 心拍変動による自律神経状態 | 0-100 |
| リズム | サーカディアンリズムの安定性 | 0-100 |
| 活動量 | 日中の身体活動レベル | 0-100 |
| ストレスグラフ | 24時間の自律神経バランス推移 | -100〜+100 |

詳細なアルゴリズムは [metrics-algorithm-spec.md](../metrics-algorithm-spec.md) を参照。

---

## 2. Layer 3: ユーザーデータ構造

Layer 3は動的なユーザーデータで、キャッシュ対象外です。

### 2.1 基本構造

```xml
<user_data>
  <profile>
    <nickname>健太</nickname>
    <age>32</age>
    <gender>male</gender>
    <weight_kg>72</weight_kg>
    <height_cm>175</height_cm>
    <occupation>ITエンジニア・デスクワーク</occupation>
    <lifestyle_rhythm>夜型</lifestyle_rhythm>
    <exercise_frequency>週3-4回</exercise_frequency>
    <alcohol_frequency>週1-2回</alcohol_frequency>
    <interests>
      <interest priority="1">運動・フィットネス</interest>
      <interest priority="2">エネルギー・パフォーマンス</interest>
    </interests>
  </profile>

  <health_data date="2024-12-09" day_of_week="月曜日">
    <!-- 睡眠データ -->
    <sleep>
      <bedtime>23:30</bedtime>
      <wake_time>06:30</wake_time>
      <duration_hours>7.0</duration_hours>
      <deep_sleep_hours>1.75</deep_sleep_hours>
      <rem_sleep_hours>1.33</rem_sleep_hours>
      <awakenings>1</awakenings>
      <avg_heart_rate>52</avg_heart_rate>
    </sleep>

    <!-- 朝のバイタル -->
    <morning_vitals>
      <resting_hr>53</resting_hr>
      <hrv_ms>72</hrv_ms>
      <blood_oxygen>98</blood_oxygen>
    </morning_vitals>

    <!-- 昨日の活動 -->
    <yesterday>
      <steps>6200</steps>
      <workout>休養日</workout>
      <calories_burned>2100</calories_burned>
    </yesterday>

    <!-- 7日間トレンド -->
    <trends_7d>
      <avg_sleep_hours>6.75</avg_sleep_hours>
      <avg_hrv>68</avg_hrv>
      <avg_resting_hr>55</avg_resting_hr>
      <avg_steps>8500</avg_steps>
      <total_workout_hours>5</total_workout_hours>
    </trends_7d>

    <!-- 新メトリクススコア -->
    <metrics_scores>
      <sleep_score>78</sleep_score>
      <hrv_score>82</hrv_score>
      <rhythm_score>65</rhythm_score>
      <activity_score>71</activity_score>
    </metrics_scores>
  </health_data>

  <environment>
    <weather>
      <condition>晴れ</condition>
      <temp_current_c>8</temp_current_c>
      <temp_max_c>14</temp_max_c>
      <humidity_percent>55</humidity_percent>
      <uv_index>3</uv_index>
      <pressure_hpa>1019</pressure_hpa>
    </weather>
    <air_quality>
      <aqi>42</aqi>
      <pm25>12</pm25>
    </air_quality>
    <location>Tokyo</location>
  </environment>

  <history>
    <recent_daily_try_topics>
      <topic date="12/08">深呼吸法</topic>
      <topic date="12/07">ストレッチ</topic>
      <topic date="12/06">水分補給</topic>
      <topic date="12/05">散歩</topic>
      <topic date="12/04">瞑想</topic>
    </recent_daily_try_topics>
    <last_weekly_try>セサミオイルマッサージ</last_weekly_try>
  </history>

  <context>
    <is_monday>true</is_monday>
    <generate_weekly_try>true</generate_weekly_try>
  </context>
</user_data>
```

---

## 3. メトリクスデータのJSON形式

### 3.1 メトリクススコアブロック

```json
{
  "metrics_scores": {
    "date": "2024-12-09",
    "sleep": {
      "score": 78,
      "status": "good",
      "components": {
        "duration": 32,
        "deep_sleep": 22,
        "rem_sleep": 12,
        "efficiency": 7,
        "timing": 5
      },
      "trend_7d": "stable"
    },
    "hrv": {
      "score": 82,
      "status": "excellent",
      "components": {
        "baseline_comparison": 45,
        "trend_7d": 22,
        "resting_hr": 15
      },
      "trend_7d": "improving"
    },
    "rhythm": {
      "score": 65,
      "status": "good",
      "components": {
        "bedtime_stability": 25,
        "waketime_stability": 20,
        "weekend_shift": 12,
        "ideal_range": 8
      },
      "trend_7d": "declining"
    },
    "activity": {
      "score": 71,
      "status": "good",
      "components": {
        "steps": 28,
        "active_minutes": 22,
        "sedentary_breaks": 15,
        "exercise": 6
      },
      "trend_7d": "stable"
    }
  }
}
```

### 3.2 ストレスグラフデータ

```json
{
  "stress_graph": {
    "date": "2024-12-09",
    "data_points": [
      { "time": "00:00", "balance": 45 },
      { "time": "00:05", "balance": 48 },
      { "time": "06:30", "balance": 32 },
      { "time": "09:00", "balance": -15 },
      { "time": "12:00", "balance": -25 },
      { "time": "15:00", "balance": -40 },
      { "time": "18:00", "balance": -10 },
      { "time": "21:00", "balance": 35 },
      { "time": "23:55", "balance": 50 }
    ],
    "summary": {
      "avg_balance": 8,
      "min_balance": -45,
      "max_balance": 55,
      "peak_stress_time": "15:30",
      "most_relaxed_time": "05:45"
    }
  }
}
```

---

## 4. 相関分析データの活用

### 4.1 相関分析結果の送信フォーマット

```json
{
  "correlations": {
    "analyzed_at": "2024-12-09T06:30:00Z",
    "data_range": {
      "start": "2024-11-25",
      "end": "2024-12-08"
    },
    "sample_size": 14,
    "pairs": [
      {
        "pair": "hrv_sleep",
        "coefficient": 0.72,
        "strength": "strong",
        "is_significant": true,
        "interpretation": "睡眠の質がHRVに大きく影響"
      },
      {
        "pair": "rhythm_sleep",
        "coefficient": 0.55,
        "strength": "moderate",
        "is_significant": true,
        "interpretation": "就寝時刻の安定が睡眠の質に関連"
      },
      {
        "pair": "activity_hrv",
        "coefficient": 0.48,
        "strength": "moderate",
        "is_significant": true,
        "interpretation": "日中の活動がHRV回復を促進"
      }
    ],
    "notable_patterns": [
      "週末の夜更かし後、月曜のHRVが平均15%低下",
      "8000歩以上の日は深い睡眠が20%増加"
    ]
  }
}
```

### 4.2 相関データをプロンプトに組み込む

```xml
<user_correlations>
  <strong_positive>
    <pair name="hrv_sleep">睡眠の質がHRVに大きく影響しています</pair>
  </strong_positive>
  <moderate_positive>
    <pair name="rhythm_sleep">就寝時刻の安定が睡眠の質に関連しています</pair>
    <pair name="activity_hrv">日中の活動がHRV回復を促進しています</pair>
  </moderate_positive>
  <notable_patterns>
    <pattern>週末の夜更かし後、月曜のHRVが平均15%低下する傾向</pattern>
    <pattern>8000歩以上の日は深い睡眠が20%増加する傾向</pattern>
  </notable_patterns>
</user_correlations>
```

---

## 5. インサイト生成ルール

### 5.1 メトリクスステータスに基づくアドバイス方向

| 睡眠 | HRV | リズム | 活動量 | アドバイス方向 |
|-----|-----|-------|-------|--------------|
| 良好 | 良好 | 良好 | 良好 | 「最高のコンディション、チャレンジの日」 |
| 良好 | 良好 | 低下 | 良好 | 「今日は良いが、リズムを整える意識を」 |
| 低下 | 良好 | 良好 | 良好 | 「睡眠負債を返す意識を持ちつつ活動」 |
| 良好 | 低下 | 良好 | 良好 | 「回復優先、激しい活動は避ける」 |
| 低下 | 低下 | 低下 | 良好 | 「休息優先、無理をしない日」 |
| 低下 | 低下 | 低下 | 低下 | 「体が回復を求めています、自分を労わる日」 |

### 5.2 相関データを活用したパーソナライズ

```
IF correlation(hrv_sleep) is strong AND sleep_score < 60:
  THEN highlight: "あなたの場合、睡眠の質がHRVに大きく影響します。今夜の睡眠を改善することで、明日のHRVは大きく回復するはずです。"

IF pattern contains "週末の夜更かし" AND is_monday:
  THEN highlight: "過去のデータから、週末の夜更かしが月曜のコンディションに影響する傾向があります。今週末は就寝時刻を意識してみましょう。"

IF pattern contains "8000歩以上" AND activity_score < 60:
  THEN suggest: "あなたの場合、8000歩以上歩いた日は深い睡眠が増える傾向があります。今日、少し多めに歩いてみませんか？"
```

### 5.3 ストレスグラフを活用したアドバイス

```
IF stress_graph.peak_stress_time is afternoon AND avg_balance < 0:
  THEN suggest: "午後にストレスが高まる傾向があります。15時頃に5分の深呼吸タイムを設けてみましょう。"

IF stress_graph.summary.min_balance < -50:
  THEN highlight: "昨日は強いストレス状態の時間帯がありました。今日は回復を優先しましょう。"
```

---

## 6. 追加アドバイス用プロンプト

### 6.1 昼・夕のフォローアップ

追加アドバイスは Claude Haiku を使用し、軽量なプロンプトで生成します。

```xml
<system_role>
あなたはTempo AIのヘルスケアアドバイザーです。
午後の短いフォローアップアドバイスを提供します。

<character>
- 簡潔に、要点を伝える
- 温かいトーン
- 「〇〇さん」の呼びかけは省略可
</character>

<output_format>
{
  "time_slot": "afternoon" または "evening",
  "greeting": "こんにちは" または "お疲れさまです",
  "message": "（5-8文のアドバイス、改行\\nで区切る）"
}
</output_format>
</system_role>

<user_data>
  <nickname>健太</nickname>
  <time_slot>afternoon</time_slot>
  <morning_data>
    <hrv_ms>72</hrv_ms>
    <resting_hr>53</resting_hr>
    <metrics_scores>
      <sleep_score>78</sleep_score>
      <hrv_score>82</hrv_score>
    </metrics_scores>
  </morning_data>
  <current_data>
    <steps_so_far>3500</steps_so_far>
    <avg_hr_since_morning>75</avg_hr_since_morning>
    <hr_trend>普段より10%高め</hr_trend>
    <stress_current_balance>-25</stress_current_balance>
  </current_data>
  <interests>
    <interest>運動・フィットネス</interest>
  </interests>
</user_data>

<instruction>
午前中のデータに基づいて、短い午後のアドバイスを生成してください。
全体で5-8文以内に収めてください。
</instruction>
```

### 6.2 追加アドバイス出力例

```json
{
  "time_slot": "afternoon",
  "greeting": "こんにちは",
  "message": "午前中の心拍数が普段より10%ほど高めで推移していました。少し緊張や集中が続いていたかもしれませんね。\n\n深呼吸を3回、ゆっくり行ってみてください。5分間、席を立って体を動かすだけでも効果があります。\n\nリセットして、午後も良い時間を過ごしてくださいね。"
}
```

---

## 7. プロンプト送信時の注意事項

### 7.1 指示の追加

```xml
<instruction>
上記のユーザーデータに基づいて、パーソナライズされたアドバイスをJSON形式で生成してください。

注意事項:
- 今日のトライは、recent_daily_try_topicsに含まれるトピックとは異なる新鮮な提案をしてください
- 今週のトライは、last_weekly_tryとは異なる提案をしてください
- 複数のデータを掛け合わせた分析を行ってください（メトリクススコア + 睡眠 + 天気 + 相関分析など）
- 職業を考慮した具体的なアドバイスを含めてください
- 相関分析データがある場合は、ユーザー固有のパターンに言及してください
- ストレスグラフのパターンがある場合は、それを反映したアドバイスを含めてください
</instruction>
```

### 7.2 トークン予算

| レイヤー | 推定トークン | キャッシュ |
|---------|------------|----------|
| Layer 1 | 約1,500 | 対象（TTL: 1時間） |
| Layer 2 | 約2,000 | 対象（TTL: 5分） |
| Layer 3 | 約800-1,200 | 対象外 |
| **合計** | **約4,300-4,700** | - |

※ 相関分析データとストレスグラフを含む場合、Layer 3は最大1,200トークン程度になります。
