# Claude API 完全ベストプラクティスガイド

## トークン最適化とコスト削減に焦点を当てた実践的ガイド

### 最終更新: 2025 年 12 月

---

## 📋 目次

1. [エグゼクティブサマリー](#エグゼクティブサマリー)
2. [モデル選択戦略](#1-モデル選択戦略)
3. [プロンプトエンジニアリング](#2-プロンプトエンジニアリング)
4. [Prompt Caching（最大 90%コスト削減）](#3-prompt-caching)
5. [Token-Efficient Tool Use（最大 70%削減）](#4-token-efficient-tool-use)
6. [コスト最適化戦略](#5-コスト最適化戦略)
7. [実装パターン](#6-実装パターン)
8. [パフォーマンス最適化](#7-パフォーマンス最適化)
9. [エラーハンドリング](#8-エラーハンドリング)
10. [モニタリングとデバッグ](#9-モニタリングとデバッグ)

---

## エグゼクティブサマリー

### 最重要ポイント

Claude API を効果的に使用するための 5 つの黄金律:

1. **Prompt Caching を活用** → 最大 90%のコスト削減
2. **XML 構造化を徹底** → 精度向上とトークン効率化
3. **適切なモデルを選択** → Haiku は 12 分の 1 のコスト
4. **Token-Efficient Tool Use を有効化** → 平均 14%のトークン削減
5. **不要なデータを削除** → シンプルな最適化で大きな効果

### コスト削減の実績

| 最適化手法                | コスト削減率    | 実装難易度 |
| ------------------------- | --------------- | ---------- |
| Prompt Caching            | 最大 90%        | 低         |
| Haiku モデル使用          | 92% (vs Sonnet) | 非常に低   |
| Token-Efficient Tools     | 14-70%          | 低         |
| Tool Search Tool          | 85%             | 中         |
| Programmatic Tool Calling | 37%             | 高         |
| データ圧縮                | 20-40%          | 低         |

---

## 1. モデル選択戦略

### 1.1 最新モデル比較（2025 年 12 月現在）

#### Claude Sonnet 4.5 (`claude-sonnet-4-5-20250929`)

```yaml
特徴:
  - 最高レベルの推論能力
  - 最もスマートなモデル
  - 長文生成と複雑な分析に最適

価格:
  input: $3/MTok
  output: $15/MTok

推奨ユースケース:
  - 週次/月次の健康レポート生成
  - 複数データソースの統合分析
  - 複雑な医療アドバイス
  - パーソナライズされた長期計画
  - 医学論文レベルの詳細説明

避けるべき用途:
  - 簡単なチャット応答
  - データ分類
  - JSON整形
```

#### Claude Sonnet 4 (`claude-sonnet-4-20250514`)

```yaml
特徴:
  - バランスの取れた性能
  - ヘルスケアアプリに最適
  - 日常的なタスクに十分な品質

価格:
  input: $3/MTok
  output: $15/MTok

推奨ユースケース:
  - 日次健康アドバイス (推奨)
  - 睡眠・運動データ分析
  - 栄養情報提供
  - 中程度の複雑さのチャット

実装例:
  model: "claude-sonnet-4-20250514"
```

#### Claude Haiku 4.5 (`claude-haiku-4-5-20251001`)

```yaml
特徴:
  - 高速かつ低コスト
  - シンプルなタスクに最適
  - Sonnetの12分の1のコスト！

価格:
  input: $0.25/MTok
  output: $1.25/MTok

推奨ユースケース:
  - チャットの相槌・簡単な応答
  - JSON/データ整形
  - 単純な計算
  - タグ付け・分類
  - リアルタイムフィードバック

コスト比較:
  Sonnet: 1000トークン = $0.003
  Haiku:  1000トークン = $0.00025
  → 92%のコスト削減！
```

### 1.2 動的モデル選択の実装

```typescript
// model-selector.ts
interface TaskAnalysis {
  complexity: "simple" | "moderate" | "complex";
  dataPoints: number;
  requiresReasoning: boolean;
  outputLength: "short" | "medium" | "long";
  userTier: "free" | "premium";
}

class SmartModelSelector {
  selectOptimalModel(task: TaskAnalysis): {
    model: string;
    estimatedCost: number;
    rationale: string;
  } {
    // 複雑度スコア計算
    const score = this.calculateComplexityScore(task);

    // Premium ユーザー + 高複雑度
    if (task.userTier === "premium" && score > 7) {
      return {
        model: "claude-sonnet-4-5-20250929",
        estimatedCost: this.estimateCost("sonnet-4.5", task),
        rationale: "複雑な分析とプレミアム品質が必要",
      };
    }

    // シンプルなタスク
    if (score < 3 && task.outputLength === "short") {
      return {
        model: "claude-haiku-4-5-20251001",
        estimatedCost: this.estimateCost("haiku", task),
        rationale: "シンプルで高速な応答、コスト効率最高",
      };
    }

    // デフォルト: バランス型
    return {
      model: "claude-sonnet-4-20250514",
      estimatedCost: this.estimateCost("sonnet-4", task),
      rationale: "バランスの取れた品質とコスト",
    };
  }

  private calculateComplexityScore(task: TaskAnalysis): number {
    let score = 0;

    // 複雑度評価
    if (task.complexity === "complex") score += 5;
    if (task.complexity === "moderate") score += 3;

    // データポイント
    if (task.dataPoints > 50) score += 3;
    else if (task.dataPoints > 20) score += 2;
    else if (task.dataPoints > 10) score += 1;

    // 推論の必要性
    if (task.requiresReasoning) score += 4;

    // 出力長
    if (task.outputLength === "long") score += 2;

    return score;
  }

  private estimateCost(model: string, task: TaskAnalysis): number {
    const rates = {
      "sonnet-4.5": { input: 3, output: 15 },
      "sonnet-4": { input: 3, output: 15 },
      haiku: { input: 0.25, output: 1.25 },
    };

    // トークン数推定
    const estimatedInput = task.dataPoints * 100 + 500;
    const estimatedOutput =
      task.outputLength === "long"
        ? 1500
        : task.outputLength === "medium"
        ? 800
        : 300;

    const rate = rates[model];
    return (
      (estimatedInput * rate.input + estimatedOutput * rate.output) / 1_000_000
    );
  }
}

// 使用例
const selector = new SmartModelSelector();

// ケース1: 週次レポート
const weeklyReport = selector.selectOptimalModel({
  complexity: "complex",
  dataPoints: 168, // 7日×24時間
  requiresReasoning: true,
  outputLength: "long",
  userTier: "premium",
});
// → Sonnet 4.5 を選択
// 理由: 複雑な分析とプレミアム品質が必要
// 推定コスト: $0.0294

// ケース2: 簡単なチャット
const simpleChat = selector.selectOptimalModel({
  complexity: "simple",
  dataPoints: 1,
  requiresReasoning: false,
  outputLength: "short",
  userTier: "free",
});
// → Haiku を選択
// 理由: シンプルで高速な応答、コスト効率最高
// 推定コスト: $0.00045 (98%削減！)
```

### 1.3 パラメータ設定ベストプラクティス

```typescript
// api-config.ts
interface ClaudeConfig {
  temperature: number;
  max_tokens: number;
  top_p?: number;
  top_k?: number;
  stop_sequences?: string[];
}

class ConfigPresets {
  // ヘルスケアアドバイス（推奨）
  static healthAdvice(): ClaudeConfig {
    return {
      temperature: 0.3, // 安定性重視
      max_tokens: 2500,
      top_p: 0.9,
      stop_sequences: ["</response>", "\n\n---\n\n"],
    };
  }

  // データ分析（最も決定論的）
  static dataAnalysis(): ClaudeConfig {
    return {
      temperature: 0.2, // 一貫性最優先
      max_tokens: 4096,
      top_p: 0.85,
    };
  }

  // JSON生成（完全決定論的）
  static jsonOutput(): ClaudeConfig {
    return {
      temperature: 0.0, // 完全決定論的
      max_tokens: 2000,
      top_p: 1.0,
      stop_sequences: ["}", "}\n"],
    };
  }

  // チャット（自然な会話）
  static conversational(): ClaudeConfig {
    return {
      temperature: 0.5, // 多様性あり
      max_tokens: 1500,
      top_p: 0.95,
    };
  }
}

// Temperature選択ガイド
const TEMPERATURE_GUIDE = {
  "0.0-0.2": {
    description: "完全に決定論的",
    useCases: ["JSON生成", "データ分類", "医学的事実"],
    pros: "同じ入力で常に同じ出力",
    cons: "創造性がない",
  },
  "0.3-0.5": {
    description: "バランス型（ヘルスケア推奨）",
    useCases: ["健康アドバイス", "症状分析", "推奨事項"],
    pros: "安定性と適度な多様性",
    cons: "時々予測可能すぎる",
  },
  "0.6-0.8": {
    description: "創造的",
    useCases: ["モチベーションメッセージ", "パーソナライズ"],
    pros: "ユニークで魅力的",
    cons: "一貫性が下がる",
  },
  "0.9-1.0": {
    description: "高度に創造的",
    useCases: ["ストーリー", "詩的表現"],
    pros: "非常にユニーク",
    cons: "医療用途には不適切",
  },
};
```

---

## 2. プロンプトエンジニアリング

### 2.1 XML 構造化の重要性

### 最重要ルール: 必ず XML タグで情報を構造化する

Claude は**XML タグによる構造化**を最も得意とします。自然言語で羅列するよりも、明確な境界を持つセクションに分割してください。

#### ❌ 悪い例（非構造化）

```text
ユーザーは32歳の男性で、最近不眠症に悩んでいます。昨日の歩数は4500歩で、
睡眠時間は4時間30分でした。平均心拍数は72でした。このデータを分析して
睡眠不足の原因を教えてください。
```

**問題点:**

- 情報の境界が不明確
- Claude がパースしにくい
- 優先順位が不明
- 拡張性が低い

#### ✅ 良い例（XML 構造化）

```xml
<system_role>
あなたは睡眠医学に精通した健康アドバイザーです。
科学的根拠に基づき、実行可能なアドバイスを提供してください。
</system_role>

<user_profile>
  <basic_info>
    <age>32</age>
    <gender>male</gender>
    <primary_concern>insomnia</primary_concern>
  </basic_info>
  <health_goals>
    <goal priority="1">睡眠の質を改善</goal>
    <goal priority="2">日中の活力向上</goal>
  </health_goals>
</user_profile>

<health_data date="2025-12-08">
  <activity>
    <steps>4500</steps>
    <active_minutes>45</active_minutes>
  </activity>
  <sleep>
    <duration>4h 30m</duration>
    <deep_sleep>1h 15m</deep_sleep>
    <rem_sleep>45m</rem_sleep>
    <quality_score>58</quality_score>
  </sleep>
  <vitals>
    <heart_rate_avg>72</heart_rate_avg>
    <hrv>35</hrv>
  </vitals>
</health_data>

<historical_context>
  <sleep_trend period="7days">
    平均睡眠時間: 5h 15m
    最良: 6h 30m (12/5)
    最悪: 4h 00m (12/7)
  </sleep_trend>
</historical_context>

<instruction>
以下の分析を行ってください:
1. 睡眠不足の主要原因を3つ特定
2. 各原因に対する具体的な改善策
3. 今夜から実行できるアクション

<output_format>
{
  "causes": [
    {"cause": "...", "evidence": "..."},
    ...
  ],
  "recommendations": [
    {"action": "...", "rationale": "...", "priority": "high|medium|low"},
    ...
  ],
  "immediate_actions": [...]
}
</output_format>
</instruction>
```

**利点:**

- 情報の階層が明確
- Claude が各セクションを正確に認識
- 優先順位が明示的
- 拡張性が高い
- デバッグが容易

### 2.2 推奨 XML タグ一覧

```xml
<!-- システム指示 -->
<system_role>システムの役割と振る舞い</system_role>

<!-- ユーザー情報 -->
<user_profile>
  <basic_info>基本情報</basic_info>
  <preferences>好み・設定</preferences>
  <constraints>制約条件</constraints>
</user_profile>

<!-- 入力データ -->
<data>
  <context>コンテキスト</context>
  <metrics>メトリクス</metrics>
  <history>履歴情報</history>
</data>

<!-- 指示 -->
<instruction>
  <task>実行するタスク</task>
  <output_format>出力形式</output_format>
  <constraints>制約</constraints>
</instruction>

<!-- 例示（Few-shot Learning） -->
<examples>
  <example>
    <input>入力例</input>
    <output>期待される出力</output>
  </example>
</examples>

<thinking>
内部的な推論プロセス（ユーザーには非表示）
</thinking>

<!-- 最終出力 -->
<response>
  <summary>要約</summary>
  <details>詳細</details>
  <next_steps>次のステップ</next_steps>
</response>
```

### 2.3 プロンプトテンプレート実装

```typescript
// prompt-builder.ts
export class HealthPromptBuilder {
  /**
   * 日次健康アドバイス生成
   * 推定トークン: 800-1200 input
   */
  buildDailyAdvice(params: {
    userName: string;
    age: number;
    todayData: HealthMetrics;
    weather: WeatherInfo;
    previousAdvice?: string;
  }): string {
    return `
<system_role>
あなたは経験豊富な健康アドバイザーAIです。
ユーザーの健康データと気象情報を統合し、実行可能で具体的なアドバイスを提供します。
専門用語を避け、親しみやすく励ましのトーンを使用してください。

<guidelines>
1. ポジティブなフィードバックから始める
2. 改善点は1つに絞り込む
3. 具体的な行動を提案する
4. 気象条件を考慮する
</guidelines>
</system_role>

<user_profile>
  <name>${params.userName}</name>
  <age>${params.age}</age>
  <fitness_level>${params.todayData.fitnessLevel}</fitness_level>
</user_profile>

<today_data date="${params.todayData.date}">
  <activity>
    <steps>${params.todayData.steps}</steps>
    <active_calories>${params.todayData.activeCalories}</active_calories>
    <exercise_minutes>${params.todayData.exerciseMinutes}</exercise_minutes>
  </activity>
  <sleep>
    <duration>${params.todayData.sleepDuration}</duration>
    <quality_score>${params.todayData.sleepScore}/100</quality_score>
  </sleep>
  <vitals>
    <resting_hr>${params.todayData.restingHR}</resting_hr>
    <hrv>${params.todayData.hrv}</hrv>
  </vitals>
</today_data>

<weather>
  <temperature>${params.weather.temp}°C</temperature>
  <condition>${params.weather.condition}</condition>
  <humidity>${params.weather.humidity}%</humidity>
  <aqi>${params.weather.aqi}</aqi>
</weather>

${
  params.previousAdvice
    ? `
<previous_advice>
昨日のアドバイス: ${params.previousAdvice}
※ 繰り返しを避け、新しい視点を提供してください
</previous_advice>
`
    : ""
}

<instruction>
以下の3つのセクションでアドバイスを生成してください:

1. **今日のハイライト** (50文字以内)
   - データから見える良い点を1つ具体的に褒める
   - 数値を含めて説得力を持たせる

2. **改善のヒント** (100文字以内)
   - 最も重要な改善点を1つだけ選択
   - 具体的な行動ステップを提示
   - "今日は〜してみましょう"の形式

3. **気象アドバイス** (80文字以内)
   - 今日の天気を考慮した運動・活動の提案
   - 実行しやすい具体的な提案

<output_format>
<response>
  <highlight>...</highlight>
  <improvement>...</improvement>
  <weather_tip>...</weather_tip>
</response>
</output_format>

<tone>
励まし、ポジティブ、具体的、親しみやすい
</tone>
</instruction>
`;
  }

  /**
   * 週次レポート生成
   * 推定トークン: 2000-3000 input
   */
  buildWeeklyReport(params: {
    userName: string;
    weekData: HealthMetrics[];
    goals: Goal[];
  }): string {
    const summary = this.summarizeWeek(params.weekData);

    return `
<system_role>
あなたは健康データアナリストです。
1週間の健康データを分析し、トレンド、達成度、改善領域を特定します。
データに基づく客観的な分析と、前向きな改善提案を組み合わせてください。
</system_role>

<user_profile>
  <name>${params.userName}</name>
  <goals>
${params.goals
  .map(
    (g, i) => `    <goal id="${i + 1}" type="${g.type}" target="${g.target}">
      ${g.description}
    </goal>`
  )
  .join("\n")}
  </goals>
</user_profile>

<week_data period="${summary.startDate} - ${summary.endDate}">
  <activity_summary>
    <total_steps>${summary.totalSteps.toLocaleString()}</total_steps>
    <avg_daily_steps>${summary.avgDailySteps.toLocaleString()}</avg_daily_steps>
    <active_days>${summary.activeDays}/7</active_days>
    <total_exercise_minutes>${
      summary.totalExerciseMinutes
    }</total_exercise_minutes>
  </activity_summary>
  
  <sleep_summary>
    <avg_duration>${summary.avgSleepDuration}</avg_duration>
    <avg_quality>${summary.avgSleepScore}/100</avg_quality>
    <consistency>${summary.sleepConsistency}/100</consistency>
    <best_night date="${summary.bestSleepDate}">${
      summary.bestSleepDuration
    }</best_night>
    <worst_night date="${summary.worstSleepDate}">${
      summary.worstSleepDuration
    }</worst_night>
  </sleep_summary>
  
  <trends>
    <steps>${summary.stepsTrend}</steps>
    <sleep>${summary.sleepTrend}</sleep>
    <hrv>${summary.hrvTrend}</hrv>
  </trends>
  
  <weekly_highlights>
${summary.highlights.map((h) => `    <highlight>${h}</highlight>`).join("\n")}
  </weekly_highlights>
</week_data>

<instruction>
以下の構造でレポートを生成してください:

## 📊 週間サマリー
- 全体的な健康スコア (0-100、算出ロジックを簡潔に説明)
- 最も良かった点を1つ (具体的な数値付き)
- 最も改善が必要な点を1つ (データ根拠付き)

## 🎯 ゴール達成度
各ゴールについて:
- 達成率 (%)
- 分析コメント (50-80文字)
- 来週の調整案 (具体的)

## 📈 トレンド分析
- 活動量: 先週との比較とパターン
- 睡眠: 質と一貫性の分析
- 注目すべき相関関係 (例: 運動と睡眠の関係)

## 💡 来週のアクションプラン
1. 最優先アクション (今すぐ実行可能、測定可能)
2. 継続すべき良い習慣 (データに基づく)
3. 調整が必要な領域 (小さな改善から)

<output_format>
Markdown形式
</output_format>

<constraints>
- 全体で800-1200文字
- 各セクション独立して理解可能に
- 専門用語には簡単な説明を付ける
- データの数値を必ず引用
</constraints>

<tone>
客観的、励まし、実行可能、前向き
</tone>
</instruction>
`;
  }

  private summarizeWeek(weekData: HealthMetrics[]): WeeklySummary {
    // 週間データの集計ロジック
    return {
      startDate: weekData[0].date,
      endDate: weekData[6].date,
      totalSteps: weekData.reduce((sum, d) => sum + d.steps, 0),
      avgDailySteps: Math.round(
        weekData.reduce((sum, d) => sum + d.steps, 0) / 7
      ),
      activeDays: weekData.filter((d) => d.steps > 5000).length,
      totalExerciseMinutes: weekData.reduce(
        (sum, d) => sum + d.exerciseMinutes,
        0
      ),
      avgSleepDuration: this.formatDuration(
        weekData.reduce((sum, d) => sum + d.sleepDuration, 0) / 7
      ),
      avgSleepScore: Math.round(
        weekData.reduce((sum, d) => sum + d.sleepScore, 0) / 7
      ),
      sleepConsistency: this.calculateConsistency(
        weekData.map((d) => d.sleepDuration)
      ),
      bestSleepDate: this.findBestSleep(weekData).date,
      bestSleepDuration: this.formatDuration(
        this.findBestSleep(weekData).duration
      ),
      worstSleepDate: this.findWorstSleep(weekData).date,
      worstSleepDuration: this.formatDuration(
        this.findWorstSleep(weekData).duration
      ),
      stepsTrend: this.calculateTrend(weekData.map((d) => d.steps)),
      sleepTrend: this.calculateTrend(weekData.map((d) => d.sleepScore)),
      hrvTrend: this.calculateTrend(weekData.map((d) => d.hrv)),
      highlights: this.extractHighlights(weekData),
    };
  }
}
```

### 2.4 Few-Shot Learning（例示学習）

複雑なタスクには良い例と悪い例の両方を含めます:

```typescript
const promptWithExamples = `
<system_role>
睡眠データを分析し、実行可能なアドバイスを提供します。
</system_role>

<examples>
  <example type="good">
    <input>
      <sleep_duration>4.5h</sleep_duration>
      <sleep_score>55</sleep_score>
      <deep_sleep>1.0h</deep_sleep>
    </input>
    <output>
睡眠時間が4.5時間と短く、推奨される7-9時間を大きく下回っています。
深い睡眠は1時間確保できているものの、総睡眠時間が不足しています。

今夜の具体的アクション:
1. 就寝時刻を1時間早め、22:00には布団に入る
2. 就寝30分前にスマホ・PCを遠ざける
3. 寝室の温度を18-20°Cに調整する
    </output>
    <why_good>
- 具体的な数値で現状を説明
- 推奨値と比較
- 実行可能なアクションを3つ提示
- 測定可能な目標設定
    </why_good>
  </example>
  
  <example type="bad">
    <input>
      <sleep_duration>4.5h</sleep_duration>
      <sleep_score>55</sleep_score>
      <deep_sleep>1.0h</deep_sleep>
    </input>
    <output>
睡眠が短いです。もっと寝てください。
早く寝ることが大切です。
    </output>
    <why_bad>
- 具体性がない
- 実行可能なアクションがない
- データを活用していない
- 測定不可能
    </why_bad>
  </example>
  
  <example type="good">
    <input>
      <sleep_duration>7.5h</sleep_duration>
      <sleep_score>42</sleep_score>
      <deep_sleep>0.8h</deep_sleep>
      <wake_count>12</wake_count>
    </input>
    <output>
睡眠時間は7.5時間と十分ですが、睡眠の質に課題があります。
12回の中途覚醒と深い睡眠0.8時間(理想は1.5-2時間)が低スコアの原因です。

睡眠の質を改善するアクション:
1. 寝室の遮光性を改善(遮光カーテン導入)
2. 就寝前のカフェイン摂取を14時以降控える
3. 寝る2時間前から照明を暖色系に切り替える
    </output>
    <why_good>
- 時間は十分だが質に問題があると正確に診断
- 複数のデータポイントを関連付けて分析
- 質改善に特化した具体的アクション
    </why_good>
  </example>
</examples>

<current_data>
  ${actualUserData}
</current_data>

<instruction>
上記の good_output の形式とスタイルで、current_data を分析してください。
bad_output のような曖昧で実行不可能なアドバイスは避けてください。
</instruction>
`;
```

---

## 3. Prompt Caching

### 3.1 概要

### 最も重要なコスト削減機能: Prompt Caching

- **コスト削減**: 最大 90%
- **レイテンシ削減**: 最大 85%
- **キャッシュ期間**: デフォルト 5 分、オプションで 1 時間
- **最小キャッシュサイズ**:
  - Claude 3.5 Haiku / 3 Haiku: 2048 トークン
  - その他のモデル: 1024 トークン

### 3.2 価格体系

| モデル            | 通常入力   | キャッシュ書き込み | キャッシュ読み取り | 削減率  |
| ----------------- | ---------- | ------------------ | ------------------ | ------- |
| Claude Sonnet 4.5 | $3/MTok    | $3.75/MTok (+25%)  | $0.30/MTok         | **90%** |
| Claude Sonnet 4   | $3/MTok    | $3.75/MTok (+25%)  | $0.30/MTok         | **90%** |
| Claude Haiku 4.5  | $0.25/MTok | $0.30/MTok (+20%)  | $0.03/MTok         | **88%** |

**コスト計算例:**

```typescript
// 3000トークンのシステムプロンプトを再利用する場合

// キャッシュなし（毎回）
const costWithoutCache = ((3000 * 3) / 1_000_000) * 100; // 100リクエスト
// = $0.90

// キャッシュあり
const costWithCache =
  (3000 * 3.75) / 1_000_000 + // 初回書き込み: $0.01125
  ((3000 * 0.3) / 1_000_000) * 99; // 99回読み取り: $0.0891
// = $0.1004

// 削減率: 89% 🎉
```

### 3.3 実装パターン

#### パターン 1: システムプロンプトのキャッシュ（基本）

```typescript
// basic-caching.ts
const request = {
  model: "claude-sonnet-4-20250514",
  max_tokens: 2000,
  system: [
    {
      type: "text",
      text: "あなたは経験豊富な健康アドバイザーです...（長い指示: 1500トークン）",
      // キャッシュ指定
      cache_control: { type: "ephemeral" },
    },
  ],
  messages: [
    {
      role: "user",
      content: `<today_data>${userData}</today_data>`, // 動的データ
    },
  ],
};

// 初回コール: キャッシュ作成
// input_tokens: 0
// cache_creation_input_tokens: 1500
// コスト: 1500 * $3.75/MTok = $0.005625

// 2回目以降: キャッシュ読み取り（5分以内）
// cache_read_input_tokens: 1500
// input_tokens: 100 (ユーザーデータのみ)
// コスト: 1500 * $0.30/MTok + 100 * $3/MTok = $0.00075
// → 87%削減！
```

#### パターン 2: 複数キャッシュポイント（上級）

```typescript
// multi-cache-points.ts
const request = {
  model: "claude-sonnet-4-20250514",
  max_tokens: 2000,
  system: [
    {
      type: "text",
      text: "システムプロンプト（1000トークン）",
      cache_control: { type: "ephemeral" }, // キャッシュポイント1
    },
    {
      type: "text",
      text: "医学知識ベース（5000トークン）",
      cache_control: { type: "ephemeral" }, // キャッシュポイント2
    },
    {
      type: "text",
      text: "ユーザープロファイル（500トークン）",
      cache_control: { type: "ephemeral" }, // キャッシュポイント3
    },
  ],
  messages: [
    {
      role: "user",
      content: "今日の健康データ（200トークン）",
    },
  ],
};

// 合計: 6700トークンのうち6500トークンをキャッシュ
// 97%のコンテキストをキャッシュ！
```

#### パターン 3: 会話履歴のキャッシュ

```typescript
// conversation-caching.ts
const conversationRequest = {
  model: "claude-sonnet-4-20250514",
  max_tokens: 1000,
  system: [
    {
      type: "text",
      text: "システムプロンプト",
      cache_control: { type: "ephemeral" },
    },
  ],
  messages: [
    { role: "user", content: "こんにちは" },
    { role: "assistant", content: "こんにちは！" },
    { role: "user", content: "昨日の睡眠について" },
    { role: "assistant", content: "昨日は7時間..." },
    // ... 長い会話履歴 ...
    {
      role: "user",
      content: [
        {
          type: "text",
          text: "今日の新しい質問",
          cache_control: { type: "ephemeral" }, // 会話履歴全体をキャッシュ
        },
      ],
    },
  ],
};

// ターン1: 会話開始
// ターン2: 前回の会話をキャッシュ読み取り + 新メッセージ追加
// ターン3: 更に長い履歴をキャッシュ読み取り
// → 会話が長くなるほどコスト削減効果大！
```

### 3.4 1 時間キャッシュの活用

```typescript
// long-ttl-caching.ts
const longCacheRequest = {
  model: "claude-sonnet-4-20250514",
  max_tokens: 2000,
  system: [
    {
      type: "text",
      text: "大量の医学知識（10000トークン）",
      cache_control: {
        type: "ephemeral",
        ttl: "1h", // 1時間キャッシュ
      },
    },
  ],
  messages: [
    {
      role: "user",
      content: "ユーザーの質問",
    },
  ],
};

// 1時間キャッシュが適切なケース:
// - バックグラウンドタスク（5分以上かかる）
// - ユーザー応答待ち（通常5分以上）
// - レイテンシが重要で、かつ頻度が低い場合

// 価格（Claude Sonnet 4）:
// 5分キャッシュ読み取り: $0.30/MTok
// 1時間キャッシュ読み取り: $0.42/MTok (+40%)
// 通常入力: $3.00/MTok

// 1時間キャッシュでも86%削減！
```

### 3.5 キャッシュのベストプラクティス

```typescript
class CacheOptimizer {
  // ❌ アンチパターン1: 小さすぎるキャッシュ
  badExample1() {
    return {
      system: [
        {
          type: "text",
          text: "あなたは親切なAIです。", // 10トークン未満
          cache_control: { type: "ephemeral" }, // 最小1024トークン必要！
        },
      ],
    };
  }

  // ❌ アンチパターン2: 動的データをキャッシュ
  badExample2(userData: string) {
    return {
      system: [
        {
          type: "text",
          text: `ユーザーデータ: ${userData}`, // 毎回変わる！
          cache_control: { type: "ephemeral" }, // キャッシュヒット率0%
        },
      ],
    };
  }

  // ❌ アンチパターン3: キャッシュ順序が逆
  badExample3() {
    return {
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: "今日のデータ（動的）",
              cache_control: { type: "ephemeral" }, // ❌ 先にキャッシュ
            },
            {
              type: "text",
              text: "大量の静的コンテキスト（10000トークン）",
              // キャッシュなし → 無駄！
            },
          ],
        },
      ],
    };
  }

  // ✅ ベストプラクティス1: 静的コンテンツを最初に
  goodExample1() {
    return {
      system: [
        {
          type: "text",
          text: "静的な長いシステムプロンプト（2000トークン）",
          // キャッシュなし
        },
        {
          type: "text",
          text: "大量の医学知識（10000トークン）",
          cache_control: { type: "ephemeral" }, // ✅ 最後にキャッシュ
        },
      ],
      messages: [
        {
          role: "user",
          content: "動的データ", // キャッシュ外
        },
      ],
    };
  }

  // ✅ ベストプラクティス2: レイヤード・キャッシング
  goodExample2() {
    return {
      system: [
        {
          type: "text",
          text: "基本システムプロンプト（1000トークン）",
          cache_control: { type: "ephemeral", ttl: "1h" }, // Layer 1: 1時間
        },
        {
          type: "text",
          text: "ユーザープロファイル（変更頻度: 週1回）",
          cache_control: { type: "ephemeral", ttl: "1h" }, // Layer 2: 1時間
        },
        {
          type: "text",
          text: "セッション情報（変更頻度: 日1回）",
          cache_control: { type: "ephemeral" }, // Layer 3: 5分
        },
      ],
    };
  }

  // ✅ ベストプラクティス3: Cache-Aware Rate Limits活用
  async goodExample3() {
    // Claude Sonnet 4.5では、キャッシュ読み取りトークンが
    // Input Tokens Per Minute (ITPM)制限にカウントされない！

    // 10000トークンのキャッシュ + 100トークンの新規入力
    // ITPM制限: 100トークンのみカウント
    // → スループット10倍以上！

    return {
      model: "claude-sonnet-4-5-20250929", // Cache-aware ITPM対応
      system: [
        {
          type: "text",
          text: "大量のドキュメント（10000トークン）",
          cache_control: { type: "ephemeral" },
        },
      ],
      messages: [
        {
          role: "user",
          content: "新しい質問（100トークン）",
        },
      ],
    };
  }
}
```

### 3.6 キャッシュモニタリング

```typescript
// cache-monitor.ts
interface CacheMetrics {
  input_tokens: number;
  cache_creation_input_tokens: number;
  cache_read_input_tokens: number;
  output_tokens: number;
}

class CacheMonitor {
  analyzeCachePerformance(usage: CacheMetrics): {
    cacheHitRate: number;
    costSavings: number;
    recommendations: string[];
  } {
    const totalInput =
      usage.input_tokens +
      usage.cache_creation_input_tokens +
      usage.cache_read_input_tokens;

    const cacheHitRate = usage.cache_read_input_tokens / totalInput;

    // コスト計算（Sonnet 4の場合）
    const costWithoutCache = (totalInput * 3) / 1_000_000;
    const costWithCache =
      (usage.input_tokens * 3 +
        usage.cache_creation_input_tokens * 3.75 +
        usage.cache_read_input_tokens * 0.3) /
      1_000_000;

    const costSavings =
      ((costWithoutCache - costWithCache) / costWithoutCache) * 100;

    const recommendations: string[] = [];

    if (cacheHitRate < 0.5) {
      recommendations.push(
        "❗ キャッシュヒット率が50%未満です。" +
          "プロンプトの静的部分を増やすことを検討してください。"
      );
    }

    if (usage.cache_creation_input_tokens < 1024) {
      recommendations.push(
        "⚠️ キャッシュサイズが最小値未満です。" +
          "より大きな静的コンテンツをキャッシュしてください。"
      );
    }

    if (cacheHitRate > 0.8) {
      recommendations.push(
        "✅ 優れたキャッシュ戦略です！" +
          `${costSavings.toFixed(1)}%のコスト削減を達成しています。`
      );
    }

    return {
      cacheHitRate,
      costSavings,
      recommendations,
    };
  }

  // 使用例
  example() {
    const usage: CacheMetrics = {
      input_tokens: 100,
      cache_creation_input_tokens: 0,
      cache_read_input_tokens: 5000,
      output_tokens: 500,
    };

    const analysis = this.analyzeCachePerformance(usage);
    console.log(
      `キャッシュヒット率: ${(analysis.cacheHitRate * 100).toFixed(1)}%`
    );
    console.log(`コスト削減: ${analysis.costSavings.toFixed(1)}%`);
    analysis.recommendations.forEach((r) => console.log(r));
  }
}
```

---

## 4. Token-Efficient Tool Use

### 4.1 概要

### 2025 年 2 月リリースの最新機能

- **削減率**: 平均 14%、最大 70%
- **対応モデル**: Claude Sonnet 4.5 (`claude-sonnet-4-5-20250929`)
- **有効化**: ヘッダーに`anthropic-beta: token-efficient-tools-2025-02-19`を追加

### 4.2 実装例

```typescript
// token-efficient-tools.ts
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

async function callWithEfficientTools() {
  const response = await client.messages.create({
    model: "claude-sonnet-4-5-20250929",
    max_tokens: 1024,
    // ✨ Token-efficient tools を有効化
    betas: ["token-efficient-tools-2025-02-19"],
    tools: [
      {
        name: "get_health_data",
        description: "ユーザーの健康データを取得",
        input_schema: {
          type: "object",
          properties: {
            date: {
              type: "string",
              description: "データ取得日 (YYYY-MM-DD)",
            },
            metrics: {
              type: "array",
              items: { type: "string" },
              description: "取得するメトリクス (steps, sleep, heart_rate)",
            },
          },
          required: ["date"],
        },
      },
      {
        name: "calculate_nutrition",
        description: "カロリーと栄養素を計算",
        input_schema: {
          type: "object",
          properties: {
            food_items: {
              type: "array",
              items: { type: "string" },
            },
          },
        },
      },
    ],
    messages: [
      {
        role: "user",
        content: "昨日の歩数と睡眠時間を教えてください",
      },
    ],
  });

  console.log("Token usage:", response.usage);
  // 通常: input_tokens: 450, output_tokens: 150
  // Efficient: input_tokens: 380, output_tokens: 45 (70%削減!)

  return response;
}

// トークン削減の仕組み:
//
// ❌ 通常のTool Use:
// {
//   "type": "tool_use",
//   "id": "toolu_01A09q90qw90lq917835lq9",
//   "name": "get_health_data",
//   "input": {
//     "date": "2025-12-07",
//     "metrics": ["steps", "sleep"]
//   }
// }
//
// ✅ Token-Efficient Tool Use:
// <tool>get_health_data:2025-12-07:steps,sleep</tool>
// → 圧縮された形式で70%削減！
```

### 4.3 ベストプラクティス

```typescript
class ToolEfficiencyOptimizer {
  // ✅ Do: シンプルで明確なツール定義
  goodToolDefinition() {
    return {
      name: "search_health_records", // 短く明確
      description: "健康記録を検索", // 簡潔
      input_schema: {
        type: "object",
        properties: {
          query: { type: "string" }, // 最小限のプロパティ
          limit: { type: "number", default: 10 },
        },
        required: ["query"],
      },
    };
  }

  // ❌ Don't: 複雑すぎるツール定義
  badToolDefinition() {
    return {
      name: "search_and_analyze_comprehensive_health_records_with_filtering",
      description: `
        This tool searches through comprehensive health records
        and performs detailed analysis with advanced filtering
        capabilities including date ranges, metric types,
        statistical aggregations, and more...
        （500文字の長い説明）
      `, // 長すぎる説明
      input_schema: {
        type: "object",
        properties: {
          // 20個以上のプロパティ...
        },
      },
    };
  }

  // ✅ Do: 複数の小さなツールに分割
  betterApproach() {
    return [
      {
        name: "search_records",
        description: "記録を検索",
        input_schema: {
          /* シンプル */
        },
      },
      {
        name: "analyze_records",
        description: "記録を分析",
        input_schema: {
          /* シンプル */
        },
      },
      {
        name: "filter_by_date",
        description: "日付でフィルター",
        input_schema: {
          /* シンプル */
        },
      },
    ];
  }
}
```

---

## 5. コスト最適化戦略

### 5.1 コスト削減チェックリスト

```markdown
## 即座に実装可能（難易度: 低）

- [ ] **Prompt Caching を有効化** → 90%削減

  - システムプロンプトに cache_control を追加
  - 推定削減額: $XXX/月

- [ ] **シンプルなタスクで Haiku を使用** → 92%削減

  - JSON 整形、相槌、分類タスク
  - 推定削減額: $XXX/月

- [ ] **Token-Efficient Tools を有効化** → 14-70%削減

  - ヘッダーに beta フラグを追加
  - 推定削減額: $XXX/月

- [ ] **不要なデータを削除**

  - 詳細なタイムスタンプ配列を削除
  - メタデータを最小限に
  - 推定削減額: $XXX/月

- [ ] **max_tokens を最適化**
  - タスクに応じて適切な値を設定
  - 推定削減額: $XXX/月

## 中期的に実装（難易度: 中）

- [ ] **データを要約して送信**

  - 7 日分の詳細データ → 集計値
  - 推定削減額: $XXX/月

- [ ] **会話履歴を制限**

  - 直近 5-10 メッセージのみ
  - 2000 トークン以下に制限
  - 推定削減額: $XXX/月

- [ ] **Tool Search Tool を導入** → 85%削減

  - ツール定義を動的にロード
  - 推定削減額: $XXX/月

- [ ] **動的モデル選択を実装**
  - タスク複雑度に応じて自動選択
  - 推定削減額: $XXX/月

## 高度な最適化（難易度: 高）

- [ ] **Programmatic Tool Calling を導入** → 37%削減

  - 複雑なワークフロー向け
  - 推定削減額: $XXX/月

- [ ] **バッチ処理を活用**

  - 非同期タスクをまとめて処理
  - 推定削減額: $XXX/月

- [ ] **レスポンス圧縮**
  - 必要な情報のみ抽出
  - 推定削減額: $XXX/月
```

### 5.2 コスト最適化実装例

```typescript
// cost-optimizer.ts
class ComprehensiveCostOptimizer {
  /**
   * 戦略1: データ圧縮
   */
  compressHealthData(weekData: HealthMetrics[]): string {
    // ❌ 非圧縮: 7日 × 24時間 = 168データポイント = ~5000トークン
    const inefficient = JSON.stringify(weekData);

    // ✅ 圧縮: 集計値のみ = ~300トークン (94%削減!)
    const compressed = {
      summary: {
        avg_steps: this.average(weekData.map((d) => d.steps)),
        avg_sleep: this.average(weekData.map((d) => d.sleepDuration)),
        avg_hr: this.average(weekData.map((d) => d.restingHR)),
        total_active_days: weekData.filter((d) => d.steps > 5000).length,
      },
      trends: {
        steps: this.calculateTrend(weekData.map((d) => d.steps)),
        sleep: this.calculateTrend(weekData.map((d) => d.sleepDuration)),
      },
      highlights: {
        best_day: this.findBestDay(weekData),
        worst_day: this.findWorstDay(weekData),
      },
    };

    return `
<week_summary>
  <averages>
    <steps>${compressed.summary.avg_steps}</steps>
    <sleep>${compressed.summary.avg_sleep}</sleep>
    <resting_hr>${compressed.summary.avg_hr}</resting_hr>
  </averages>
  <active_days>${compressed.summary.total_active_days}/7</active_days>
  <trends>
    <steps>${compressed.trends.steps}</steps>
    <sleep>${compressed.trends.sleep}</sleep>
  </trends>
  <highlights>
    <best>${compressed.highlights.best_day}</best>
    <worst>${compressed.highlights.worst_day}</worst>
  </highlights>
</week_summary>
    `;
  }

  /**
   * 戦略2: 会話履歴の賢い管理
   */
  optimizeConversationHistory(
    messages: Message[],
    maxTokens: number = 2000
  ): Message[] {
    // 最新メッセージから逆順で追加
    let totalTokens = 0;
    const optimized: Message[] = [];

    for (let i = messages.length - 1; i >= 0; i--) {
      const msg = messages[i];
      const msgTokens = this.estimateTokens(msg.content);

      if (totalTokens + msgTokens > maxTokens) {
        // 制限を超える場合、要約を追加
        const summary = this.summarizeOldMessages(messages.slice(0, i + 1));
        optimized.unshift({
          role: "system",
          content: `<conversation_summary>${summary}</conversation_summary>`,
        });
        break;
      }

      optimized.unshift(msg);
      totalTokens += msgTokens;
    }

    return optimized;
  }

  /**
   * 戦略3: 条件付き詳細化
   */
  adjustDetailLevel(params: {
    userTier: "free" | "premium";
    complexity: number;
    budgetRemaining: number;
  }): "minimal" | "standard" | "detailed" {
    // 予算が少ない場合
    if (params.budgetRemaining < 0.01) {
      // $0.01未満
      return "minimal";
    }

    // Freeユーザー + 高複雑度
    if (params.userTier === "free" && params.complexity > 5) {
      return "standard";
    }

    // Premiumユーザー
    if (params.userTier === "premium") {
      return "detailed";
    }

    return "standard";
  }

  /**
   * 戦略4: バッチ処理
   */
  async processBatch(tasks: Task[], batchSize: number = 10): Promise<Result[]> {
    const results: Result[] = [];

    // タスクをバッチに分割
    for (let i = 0; i < tasks.length; i += batchSize) {
      const batch = tasks.slice(i, i + batchSize);

      // 1つのプロンプトに複数タスクを含める
      const combinedPrompt = this.createBatchPrompt(batch);

      const response = await this.callClaude({
        model: "claude-haiku-4-5-20251001", // 高速・低コスト
        prompt: combinedPrompt,
      });

      const batchResults = this.parseBatchResponse(response);
      results.push(...batchResults);
    }

    return results;
  }

  private createBatchPrompt(tasks: Task[]): string {
    return `
<batch_processing>
以下の${tasks.length}個のタスクを処理してください:

${tasks
  .map(
    (task, i) => `
<task id="${i + 1}">
  <input>${task.input}</input>
  <action>${task.action}</action>
</task>
`
  )
  .join("\n")}

<output_format>
各タスクの結果をJSON配列で返してください:
[
  {"task_id": 1, "result": "..."},
  {"task_id": 2, "result": "..."},
  ...
]
</output_format>
</batch_processing>
    `;
  }

  /**
   * 戦略5: レスポンスキャッシュ（アプリケーションレベル）
   */
  private responseCache = new Map<string, CachedResponse>();

  async getAdviceWithCache(userId: string, date: string): Promise<string> {
    const cacheKey = `${userId}-${date}`;
    const cached = this.responseCache.get(cacheKey);

    // キャッシュヒット（1時間以内）
    if (cached && Date.now() - cached.timestamp < 3600000) {
      console.log("✅ Application cache hit - $0.00");
      return cached.response;
    }

    // Claude API呼び出し
    const response = await this.callClaude({
      userId,
      date,
    });

    // キャッシュに保存
    this.responseCache.set(cacheKey, {
      response,
      timestamp: Date.now(),
    });

    return response;
  }

  /**
   * コスト推定と警告
   */
  async estimateAndWarnCost(params: APICallParams): Promise<{
    estimatedCost: number;
    shouldProceed: boolean;
    recommendation: string;
  }> {
    const inputTokens = this.estimateTokens(params.prompt);
    const outputTokens = params.max_tokens || 2000;

    const cost = this.calculateCost(inputTokens, outputTokens, params.model);

    // コスト警告閾値
    const HIGH_COST_THRESHOLD = 0.1; // $0.10

    if (cost > HIGH_COST_THRESHOLD) {
      return {
        estimatedCost: cost,
        shouldProceed: false,
        recommendation: `
推定コストが高額です: $${cost.toFixed(4)}

コスト削減の提案:
1. Haikuモデルを使用 → 推定 $${(cost * 0.08).toFixed(4)}
2. プロンプトを圧縮 → 推定 $${(cost * 0.6).toFixed(4)}
3. Prompt Cachingを有効化 → 推定 $${(cost * 0.1).toFixed(4)}
        `,
      };
    }

    return {
      estimatedCost: cost,
      shouldProceed: true,
      recommendation: "コストは適正範囲内です",
    };
  }
}

// 使用例
const optimizer = new ComprehensiveCostOptimizer();

// 週間データを圧縮
const compressed = optimizer.compressHealthData(weekData);
// 5000トークン → 300トークン (94%削減)

// 会話履歴を最適化
const optimized = optimizer.optimizeConversationHistory(messages, 2000);
// 10000トークン → 2000トークン (80%削減)

// コスト警告
const estimation = await optimizer.estimateAndWarnCost({
  prompt: longPrompt,
  model: "claude-sonnet-4-5-20250929",
  max_tokens: 3000,
});

if (!estimation.shouldProceed) {
  console.log(estimation.recommendation);
}
```

---

## 6. 実装パターン

### 6.1 完全な API 呼び出し例

```typescript
// api-client-complete.ts
import Anthropic from "@anthropic-ai/sdk";

interface AdviceRequest {
  userId: string;
  userName: string;
  age: number;
  healthData: HealthMetrics;
  weather: WeatherInfo;
  preferences: UserPreferences;
  conversationHistory?: Message[];
}

interface AdviceResponse {
  highlight: string;
  improvement: string;
  weatherTip: string;
  metadata: {
    model: string;
    inputTokens: number;
    outputTokens: number;
    cacheHitTokens: number;
    cost: number;
    latency: number;
  };
}

export class OptimizedClaudeService {
  private anthropic: Anthropic;
  private rateLimiter: RateLimiter;
  private cacheMonitor: CacheMonitor;

  // 静的プロンプト（キャッシュ対象）
  private static SYSTEM_PROMPT = `
あなたは経験豊富な健康アドバイザーAIです。
ユーザーの健康データと気象情報を統合し、実行可能で具体的なアドバイスを提供します。

<guidelines>
1. ポジティブなフィードバックから始める
2. 改善点は1つに絞り込む（多すぎると圧倒される）
3. 具体的で測定可能な行動を提案する
4. 気象条件を必ず考慮する
5. 専門用語は避け、わかりやすい言葉を使う
</guidelines>

<medical_knowledge>
[大量の医学知識: 5000トークン]
</medical_knowledge>
  `.trim();

  constructor(apiKey: string) {
    this.anthropic = new Anthropic({ apiKey });
    this.rateLimiter = new RateLimiter({ requestsPerMinute: 50 });
    this.cacheMonitor = new CacheMonitor();
  }

  async generateAdvice(req: AdviceRequest): Promise<AdviceResponse> {
    const startTime = Date.now();

    try {
      // 1. モデル選択
      const model = this.selectOptimalModel(req);

      // 2. プロンプト生成
      const userPrompt = this.buildUserPrompt(req);

      // 3. 会話履歴の最適化
      const optimizedHistory = this.optimizeHistory(req.conversationHistory);

      // 4. API呼び出し（レート制限付き）
      const response = await this.rateLimiter.enqueue(() =>
        this.anthropic.messages.create({
          model,
          max_tokens: 2000,
          temperature: 0.3,
          // Prompt Cachingを有効化
          system: [
            {
              type: "text",
              text: OptimizedClaudeService.SYSTEM_PROMPT,
              cache_control: { type: "ephemeral" },
            },
          ],
          messages: [
            ...optimizedHistory,
            {
              role: "user",
              content: userPrompt,
            },
          ],
        })
      );

      // 5. レスポンスパース
      const parsed = this.parseResponse(response.content[0].text);

      // 6. メトリクス収集
      const metadata = this.collectMetrics(response, model, startTime);

      // 7. キャッシュ分析
      this.cacheMonitor.track(response.usage);

      return {
        ...parsed,
        metadata,
      };
    } catch (error) {
      return this.handleError(error, req);
    }
  }

  private selectOptimalModel(req: AdviceRequest): string {
    const selector = new SmartModelSelector();

    const analysis: TaskAnalysis = {
      complexity: this.assessComplexity(req.healthData),
      dataPoints: this.countDataPoints(req.healthData),
      requiresReasoning: this.needsDeepReasoning(req),
      outputLength: "medium",
      userTier: req.preferences.tier,
    };

    return selector.selectOptimalModel(analysis).model;
  }

  private buildUserPrompt(req: AdviceRequest): string {
    // データ圧縮
    const compressedData = this.compressData(req.healthData);

    return `
<user_profile>
  <name>${req.userName}</name>
  <age>${req.age}</age>
  <preferences>
    <tone>${req.preferences.tone}</tone>
    <detail_level>${req.preferences.detailLevel}</detail_level>
  </preferences>
</user_profile>

<today_data date="${req.healthData.date}">
  ${compressedData}
</today_data>

<weather>
  <temperature>${req.weather.temp}°C</temperature>
  <condition>${req.weather.condition}</condition>
  <aqi>${req.weather.aqi}</aqi>
</weather>

<instruction>
3つのセクションでアドバイスを生成してください:
1. highlight: 今日の良かった点（50文字）
2. improvement: 改善のヒント（100文字）
3. weather_tip: 天気を考慮した提案（80文字）

<output_format>
<response>
  <highlight>...</highlight>
  <improvement>...</improvement>
  <weather_tip>...</weather_tip>
</response>
</output_format>
</instruction>
    `;
  }

  private optimizeHistory(history?: Message[]): Message[] {
    if (!history || history.length === 0) return [];

    const optimizer = new ComprehensiveCostOptimizer();
    return optimizer.optimizeConversationHistory(history, 2000);
  }

  private parseResponse(xml: string): Omit<AdviceResponse, "metadata"> {
    const extractTag = (tag: string): string => {
      const match = xml.match(new RegExp(`<${tag}>(.*?)</${tag}>`, "s"));
      return match ? match[1].trim() : "";
    };

    return {
      highlight: extractTag("highlight"),
      improvement: extractTag("improvement"),
      weatherTip: extractTag("weather_tip"),
    };
  }

  private collectMetrics(
    response: any,
    model: string,
    startTime: number
  ): AdviceResponse["metadata"] {
    const latency = Date.now() - startTime;
    const usage = response.usage;

    return {
      model,
      inputTokens: usage.input_tokens || 0,
      outputTokens: usage.output_tokens || 0,
      cacheHitTokens: usage.cache_read_input_tokens || 0,
      cost: this.calculateDetailedCost(usage, model),
      latency,
    };
  }

  private calculateDetailedCost(usage: any, model: string): number {
    const rates = this.getModelRates(model);

    return (
      ((usage.input_tokens || 0) * rates.input +
        (usage.cache_creation_input_tokens || 0) * rates.cacheWrite +
        (usage.cache_read_input_tokens || 0) * rates.cacheRead +
        (usage.output_tokens || 0) * rates.output) /
      1_000_000
    );
  }

  private getModelRates(model: string) {
    const rates = {
      "claude-sonnet-4-5-20250929": {
        input: 3,
        cacheWrite: 3.75,
        cacheRead: 0.3,
        output: 15,
      },
      "claude-sonnet-4-20250514": {
        input: 3,
        cacheWrite: 3.75,
        cacheRead: 0.3,
        output: 15,
      },
      "claude-haiku-4-5-20251001": {
        input: 0.25,
        cacheWrite: 0.3,
        cacheRead: 0.03,
        output: 1.25,
      },
    };

    return rates[model] || rates["claude-sonnet-4-20250514"];
  }

  private handleError(error: any, req: AdviceRequest): AdviceResponse {
    console.error("Claude API Error:", error);

    // フォールバックレスポンス
    return {
      highlight: "今日もお疲れさまでした！",
      improvement: "明日も健康的な一日を過ごしましょう。",
      weatherTip: "天気に合わせて活動を調整してください。",
      metadata: {
        model: "fallback",
        inputTokens: 0,
        outputTokens: 0,
        cacheHitTokens: 0,
        cost: 0,
        latency: 0,
      },
    };
  }
}

// 使用例
const service = new OptimizedClaudeService(process.env.ANTHROPIC_API_KEY!);

const advice = await service.generateAdvice({
  userId: "user123",
  userName: "Masakazu",
  age: 28,
  healthData: {
    date: "2025-12-08",
    steps: 8500,
    sleepDuration: "7h 15m",
    sleepScore: 78,
    restingHR: 58,
    hrv: 65,
    activeCalories: 450,
    exerciseMinutes: 45,
  },
  weather: {
    temp: 12,
    condition: "晴れ",
    aqi: 45,
  },
  preferences: {
    tier: "premium",
    tone: "encouraging",
    detailLevel: "standard",
  },
});

console.log("Advice:", advice);
console.log("Cost:", `$${advice.metadata.cost.toFixed(6)}`);
console.log("Cache Hit:", advice.metadata.cacheHitTokens, "tokens");
console.log("Latency:", advice.metadata.latency, "ms");
```

---

## 7. パフォーマンス最適化

### 7.1 ストリーミング実装

```typescript
// streaming-implementation.ts
import Anthropic from '@anthropic-ai/sdk';

class StreamingService {
  private anthropic: Anthropic;

  constructor(apiKey: string) {
    this.anthropic = new Anthropic({ apiKey });
  }

  async *streamAdvice(request: AdviceRequest): AsyncGenerator<string> {
    const stream = await this.anthropic.messages.stream({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 2000,
      temperature: 0.3,
      system: [{
        type: 'text',
        text: 'システムプロンプト',
        cache_control: { type: 'ephemeral' }
      }],
      messages: [{
        role: 'user',
        content: this.buildPrompt(request)
      }]
    });

    for await (const chunk of stream) {
      if (chunk.type === 'content_block_delta' &&
          chunk.delta.type === 'text_delta') {
        yield chunk.delta.text;
      }
    }

    // 最終メッセージ取得
    const message = await stream.finalMessage();
    console.log('Total tokens:', message.usage);
  }
}

// Cloudflare Workers での使用例
app.post('/api/advice/stream', async (c) => {
  const { userId, healthData } = await c.req.json();

  const service = new StreamingService(c.env.ANTHROPIC_API_KEY);

  // ReadableStream を返す
  const readable = new ReadableStream({
    async start(controller) {
      try {
        for await (const chunk of service.streamAdvice({ userId, healthData })) {
          const encoded = new TextEncoder().encode(
            `data: ${JSON.stringify({ text: chunk })}\n\n`
          );
          controller.enqueue(encoded);
        }
        controller.close();
      } catch (error) {
        controller.error(error);
      }
    }
  });

  return new Response(readable, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive'
    }
  });
});

// iOS SwiftUI での受信
class AdviceViewModel: ObservableObject {
    @Published var streamingText: String = ""
    @Published var isStreaming: Bool = false

    func fetchStreamingAdvice() async {
        isStreaming = true
        streamingText = ""

        let url = URL(string: "https://api.yourapp.com/advice/stream")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        do {
            let (bytes, _) = try await URLSession.shared.bytes(for: request)

            for try await line in bytes.lines {
                if line.hasPrefix("data: ") {
                    let jsonStr = String(line.dropFirst(6))
                    if let data = jsonStr.data(using: .utf8),
                       let chunk = try? JSONDecoder().decode(StreamChunk.self, from: data) {
                        await MainActor.run {
                            streamingText += chunk.text
                        }
                    }
                }
            }
        } catch {
            print("Streaming error:", error)
        }

        isStreaming = false
    }
}
```

### 7.2 並列処理とバッチング

```typescript
// parallel-processing.ts
class ParallelProcessor {
  async processBulkAdvice(
    requests: AdviceRequest[]
  ): Promise<AdviceResponse[]> {
    // 並列実行制限（同時5リクエスト）
    const concurrencyLimit = 5;
    const results: AdviceResponse[] = [];

    for (let i = 0; i < requests.length; i += concurrencyLimit) {
      const batch = requests.slice(i, i + concurrencyLimit);

      // 並列実行
      const batchResults = await Promise.all(
        batch.map((req) => this.generateAdvice(req))
      );

      results.push(...batchResults);

      // レート制限対策: 1秒待機
      if (i + concurrencyLimit < requests.length) {
        await new Promise((resolve) => setTimeout(resolve, 1000));
      }
    }

    return results;
  }

  // バッチ処理（複数タスクを1リクエストに）
  async processBatchInSingleRequest(tasks: Task[]): Promise<Result[]> {
    const batchPrompt = `
<batch_request>
${tasks
  .map(
    (task, i) => `
<task id="${i + 1}">
  <user_id>${task.userId}</user_id>
  <data>${JSON.stringify(task.data)}</data>
</task>
`
  )
  .join("\n")}

<instruction>
各タスクを処理し、JSON配列で結果を返してください:
[
  {"task_id": 1, "result": {...}},
  {"task_id": 2, "result": {...}},
  ...
]
</instruction>
</batch_request>
    `;

    const response = await this.callClaude({
      model: "claude-haiku-4-5-20251001", // 高速処理
      prompt: batchPrompt,
      max_tokens: 4096,
    });

    return JSON.parse(response);
  }
}
```

---

## 8. エラーハンドリング

### 8.1 包括的なエラー処理

```typescript
// error-handler.ts
class RobustErrorHandler {
  async callWithRetry<T>(
    fn: () => Promise<T>,
    options: {
      maxRetries?: number;
      initialDelay?: number;
      maxDelay?: number;
      onRetry?: (attempt: number, error: any) => void;
    } = {}
  ): Promise<T> {
    const {
      maxRetries = 3,
      initialDelay = 1000,
      maxDelay = 10000,
      onRetry
    } = options;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await fn();
      } catch (error: any) {
        const shouldRetry = this.isRetryable(error);
        const isLastAttempt = attempt === maxRetries - 1;

        if (!shouldRetry || isLastAttempt) {
          throw this.enhanceError(error);
        }

        // Exponential backoff with jitter
        const delay = Math.min(
          initialDelay * Math.pow(2, attempt),
          maxDelay
        );
        const jitter = delay * (0.8 + Math.random() * 0.4);

        if (onRetry) {
          onRetry(attempt + 1, error);
        }

        await this.sleep(jitter);
      }
    }

    throw new Error('Max retries exceeded');
  }

  private isRetryable(error: any): boolean {
    // リトライ可能なエラータイプ
    const retryableErrors = [
      'overloaded_error',      // サーバー過負荷
      'rate_limit_error',      // レート制限
      'timeout_error',         // タイムアウト
      'connection_error',      // 接続エラー
      'ECONNRESET',           // 接続リセット
      'ETIMEDOUT'             // タイムアウト
    ];

    return retryableErrors.some(type =>
      error.type === type ||
      error.code === type ||
      error.message?.includes(type)
    );
  }

  private enhanceError(error: any): Error {
    // エラーの詳細情報を追加
    const enhanced = new Error(
      `Claude API Error: ${error.message || error.type}`
    );

    (enhanced as any).originalError = error;
    (enhanced as any).type = error.type;
    (enhanced as any).statusCode = error.status;
    (enhanced as any).retryable = this.isRetryable(error);

    return enhanced;
  }

  handleSpecificErrors(error: any): {
    userMessage: string;
    shouldNotify: boolean;
    fallbackAction?: () => Promise<any>;
  } {
    switch (error.type) {
      case 'invalid_request_error':
        return {
          userMessage: 'リクエストの形式が正しくありません。',
          shouldNotify: true, // 開発者に通知
          fallbackAction: undefined
        };

      case 'rate_limit_error':
        return {
          userMessage: '現在、多くのリクエストを処理中です。少しお待ちください。',
          shouldNotify: false,
          fallbackAction: () => this.useHaikuFallback()
        };

      case 'overloaded_error':
        return {
          userMessage: 'サーバーが混雑しています。少し時間をおいてお試しください。',
          shouldNotify: false,
          fallbackAction: () => this.useCachedResponse()
        };

      case 'authentication_error':
        return {
          userMessage: '認証エラーが発生しました。',
          shouldNotify: true,
          fallbackAction: undefined
        };

      default:
        return {
          userMessage: 'エラーが発生しました。後ほど再試行してください。',
          shouldNotify: true,
          fallbackAction: () => this.useDefaultResponse()
        };
    }
  }

  private async sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// 使用例
const errorHandler = new RobustErrorHandler();

try {
  const result = await errorHandler.callWithRetry(
    () => claude.messages.create({...}),
    {
      maxRetries: 3,
      onRetry: (attempt, error) => {
        console.log(`Retry attempt ${attempt}: ${error.type}`);
      }
    }
  );
} catch (error: any) {
  const handling = errorHandler.handleSpecificErrors(error);
  console.error(handling.userMessage);

  if (handling.fallbackAction) {
    return await handling.fallbackAction();
  }
}
```

### 8.2 レート制限管理

```typescript
// rate-limiter.ts
class AdvancedRateLimiter {
  private queue: Array<{
    fn: () => Promise<any>;
    resolve: (value: any) => void;
    reject: (error: any) => void;
  }> = [];

  private processing = false;
  private requestsPerMinute: number;
  private tokensPerMinute: number;
  private requestCount = 0;
  private tokenCount = 0;
  private resetTime = Date.now() + 60000;

  constructor(config: {
    requestsPerMinute: number;
    tokensPerMinute: number;
  }) {
    this.requestsPerMinute = config.requestsPerMinute;
    this.tokensPerMinute = config.tokensPerMinute;
  }

  async enqueue<T>(
    fn: () => Promise<T>,
    estimatedTokens: number
  ): Promise<T> {
    return new Promise((resolve, reject) => {
      this.queue.push({
        fn: async () => {
          // トークン数を推定
          if (this.tokenCount + estimatedTokens > this.tokensPerMinute) {
            throw new Error('Token limit would be exceeded');
          }

          const result = await fn();
          this.tokenCount += estimatedTokens;
          return result;
        },
        resolve,
        reject
      });

      this.processQueue();
    });
  }

  private async processQueue(): Promise<void> {
    if (this.processing || this.queue.length === 0) return;

    this.processing = true;

    while (this.queue.length > 0) {
      // レート制限リセット
      if (Date.now() >= this.resetTime) {
        this.requestCount = 0;
        this.tokenCount = 0;
        this.resetTime = Date.now() + 60000;
      }

      // リクエスト数制限チェック
      if (this.requestCount >= this.requestsPerMinute) {
        const waitTime = this.resetTime - Date.now();
        console.log(`Rate limit reached. Waiting ${waitTime}ms...`);
        await this.sleep(waitTime);
        continue;
      }

      const item = this.queue.shift();
      if (!item) break;

      try {
        this.requestCount++;
        const result = await item.fn();
        item.resolve(result);
      } catch (error) {
        item.reject(error);
      }

      // 最小間隔（60s / RPM）
      const minInterval = 60000 / this.requestsPerMinute;
      await this.sleep(minInterval);
    }

    this.processing = false;
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// 使用例
const rateLimiter = new AdvancedRateLimiter({
  requestsPerMinute: 50,
  tokensPerMinute: 40000
});

const result = await rateLimiter.enqueue(
  () => claude.messages.create({...}),
  1500 // 推定トークン数
);
```

---

## 9. モニタリングとデバッグ

### 9.1 包括的なロギング

```typescript
// monitoring.ts
interface APICallLog {
  requestId: string;
  timestamp: string;
  model: string;
  userId: string;
  prompt: {
    inputTokens: number;
    estimatedCost: number;
  };
  response: {
    outputTokens: number;
    cacheHitTokens: number;
    latency: number;
    cost: number;
  };
  cachePerformance: {
    hitRate: number;
    savings: number;
  };
  error?: {
    type: string;
    message: string;
  };
}

class ComprehensiveMonitor {
  private logs: APICallLog[] = [];

  logAPICall(log: APICallLog): void {
    this.logs.push(log);

    // リアルタイムアラート
    if (log.response.cost > 0.1) {
      this.alert(`High cost API call: $${log.response.cost.toFixed(4)}`);
    }

    if (log.response.latency > 5000) {
      this.alert(`Slow response: ${log.response.latency}ms`);
    }

    // 外部ログサービスへ送信（例: DataDog, CloudWatch）
    this.sendToExternalLogger(log);
  }

  getDailyReport(): {
    totalCalls: number;
    totalCost: number;
    avgLatency: number;
    avgCacheHitRate: number;
    costByModel: Record<string, number>;
    errorRate: number;
  } {
    const today = new Date().toISOString().split("T")[0];
    const todayLogs = this.logs.filter((log) =>
      log.timestamp.startsWith(today)
    );

    const totalCost = todayLogs.reduce(
      (sum, log) => sum + log.response.cost,
      0
    );

    const avgLatency =
      todayLogs.reduce((sum, log) => sum + log.response.latency, 0) /
      todayLogs.length;

    const avgCacheHitRate =
      todayLogs.reduce((sum, log) => sum + log.cachePerformance.hitRate, 0) /
      todayLogs.length;

    const costByModel = todayLogs.reduce((acc, log) => {
      acc[log.model] = (acc[log.model] || 0) + log.response.cost;
      return acc;
    }, {} as Record<string, number>);

    const errorRate =
      todayLogs.filter((log) => log.error).length / todayLogs.length;

    return {
      totalCalls: todayLogs.length,
      totalCost,
      avgLatency,
      avgCacheHitRate,
      costByModel,
      errorRate,
    };
  }

  generateOptimizationReport(): string {
    const report = this.getDailyReport();

    return `
# Claude API 最適化レポート
日付: ${new Date().toISOString().split("T")[0]}

## サマリー
- 総コール数: ${report.totalCalls}
- 総コスト: $${report.totalCost.toFixed(4)}
- 平均レイテンシ: ${report.avgLatency.toFixed(0)}ms
- 平均キャッシュヒット率: ${(report.avgCacheHitRate * 100).toFixed(1)}%
- エラー率: ${(report.errorRate * 100).toFixed(2)}%

## モデル別コスト
${Object.entries(report.costByModel)
  .map(([model, cost]) => `- ${model}: $${cost.toFixed(4)}`)
  .join("\n")}

## 最適化推奨事項
${this.generateRecommendations(report).join("\n")}
    `;
  }

  private generateRecommendations(report: any): string[] {
    const recommendations: string[] = [];

    if (report.avgCacheHitRate < 0.5) {
      recommendations.push(
        "⚠️ キャッシュヒット率が50%未満です。" +
          "Prompt Cachingの設定を見直してください。"
      );
    }

    if (report.avgLatency > 3000) {
      recommendations.push(
        "⚠️ 平均レイテンシが3秒を超えています。" +
          "Haikuモデルまたはストリーミングの使用を検討してください。"
      );
    }

    const haikuCost = report.costByModel["claude-haiku-4-5-20251001"] || 0;
    const sonnetCost = report.costByModel["claude-sonnet-4-20250514"] || 0;

    if (haikuCost < sonnetCost * 0.1) {
      recommendations.push(
        "💡 シンプルなタスクでHaikuの使用を増やすと、" +
          `推定で$${(sonnetCost * 0.5 * 0.92).toFixed(
            4
          )}のコスト削減が可能です。`
      );
    }

    return recommendations;
  }

  private alert(message: string): void {
    console.warn(`[ALERT] ${message}`);
    // Slack, Discord, Email等への通知
  }

  private sendToExternalLogger(log: APICallLog): void {
    // 外部ログサービスへの送信実装
    // 例: DataDog, CloudWatch, Logflare等
  }
}
```

---

## 10. まとめ

### クイックリファレンス

```markdown
## 即座に適用すべきトップ 5

1. **Prompt Caching**
   - cache_control: { type: 'ephemeral' }
   - 削減率: 最大 90%
2. **Haiku モデル使用**
   - シンプルなタスクで使用
   - 削減率: 92%
3. **XML タグ構造化**
   - すべてのプロンプトを XML で構造化
   - 効果: 精度向上 + トークン効率化
4. **データ圧縮**
   - 詳細配列 → 集計値
   - 削減率: 40-60%
5. **max_tokens 最適化**
   - タスクに応じて適切に設定
   - 削減率: 20-30%

## コスト削減の実績（実測値）

| 最適化         | Before       | After       | 削減率 |
| -------------- | ------------ | ----------- | ------ |
| Prompt Caching | $0.90        | $0.10       | 89%    |
| Haiku 使用     | $0.003       | $0.00025    | 92%    |
| データ圧縮     | 5000 tokens  | 300 tokens  | 94%    |
| 会話履歴制限   | 10000 tokens | 2000 tokens | 80%    |

## 月間コスト削減シミュレーション

想定: 1 日 1000 リクエスト、30 日間

### シナリオ A: 最適化なし

- モデル: Sonnet 4
- プロンプト: 2000 トークン（キャッシュなし）
- 出力: 500 トークン
- コスト/リクエスト: $0.0135
- 月間コスト: **$405**

### シナリオ B: 基本最適化

- Prompt Caching 有効化
- データ圧縮
- コスト/リクエスト: $0.003
- 月間コスト: **$90**
- **削減額: $315 (78%削減)**

### シナリオ C: 完全最適化

- Prompt Caching + Haiku 使用
- データ圧縮 + 動的モデル選択
- コスト/リクエスト: $0.0008
- 月間コスト: **$24**
- **削減額: $381 (94%削減)**
```

### 最後に

このガイドで紹介した技術を組み合わせることで、**Claude API のコストを最大 94%削減**しながら、**高品質な健康アドバイス**を提供できます。

最も重要なのは:

1. **Prompt Caching を必ず使う**
2. **シンプルなタスクは Haiku を使う**
3. **XML タグで構造化する**
4. **定期的にモニタリングする**

これらを実践することで、持続可能で cost-effective なヘルスケアアプリケーションを構築できます。

---

**参考リンク:**

- [Anthropic 公式ドキュメント](https://docs.anthropic.com)
- [Prompt Caching Guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching)
- [Token-Efficient Tools](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/token-efficient-tool-use)
- [Anthropic Pricing](https://www.anthropic.com/pricing)
