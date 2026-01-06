# メトリクス・アルゴリズム仕様書

**バージョン**: 3.0  
**最終更新日**: 2026 年 1 月 6 日

---

## 関連ドキュメント

| ドキュメント                             | 内容           |
| ---------------------------------------- | -------------- |
| [product_spec.md](./product_spec.md)     | プロダクト仕様 |
| [knowledge_base.md](./knowledge_base.md) | 科学的根拠     |

---

## 1. 概要

本ドキュメントは TempoAI の計算ロジックを定義する。

| 項目            | 内容                              |
| --------------- | --------------------------------- |
| Tempo Score     | 総合コンディションスコア（0-100） |
| Rhythm フェーズ | サーカディアンリズムの時間帯算出  |
| Alerts          | 注意喚起のトリガー条件            |

---

## 2. Tempo Score

### 2.1 概要

Tempo Score は「今日のコンディション」を 0-100 で表す総合指標。

```
Tempo Score = HRV Score × 0.40
            + Sleep Score × 0.35
            + Rhythm Score × 0.15
            + Activity Score × 0.10
```

### 2.2 HRV Score（40%）

HRV（心拍変動）のベースライン比較による自律神経状態の評価。

```typescript
function calculateHrvScore(currentHrv: number, baseline30d: number): number {
  if (baseline30d === 0) return 70; // キャリブレーション中

  const ratio = currentHrv / baseline30d;

  // ratio 1.0 = 70点をベースに、±30%で0-100に収める
  const baseScore = 70;
  const deviation = (ratio - 1.0) * 100;

  return clamp(baseScore + deviation, 0, 100);
}
```

| HRV 状態             | ratio     | スコア目安 |
| -------------------- | --------- | ---------- |
| ベースライン+30%以上 | ≥1.30     | 100        |
| ベースライン+10〜20% | 1.10-1.20 | 80-90      |
| ベースライン付近     | 0.90-1.10 | 60-80      |
| ベースライン-20%以下 | ≤0.80     | 40 以下    |

### 2.3 Sleep Score（35%）

睡眠の質と量の評価。

```typescript
function calculateSleepScore(
  durationMinutes: number,
  deepSleepRatio: number, // 0.0-1.0
  remSleepRatio: number // 0.0-1.0
): number {
  // 睡眠時間スコア（7-8時間が100点）
  const durationScore = scoreDuration(durationMinutes);

  // 深い睡眠比率スコア（15-25%が100点）
  const deepScore = scoreDeepSleep(deepSleepRatio);

  // レム睡眠比率スコア（20-25%が100点）
  const remScore = scoreRemSleep(remSleepRatio);

  return durationScore * 0.5 + deepScore * 0.3 + remScore * 0.2;
}

function scoreDuration(minutes: number): number {
  const hours = minutes / 60;
  if (hours >= 7 && hours <= 8) return 100;
  if (hours >= 6 && hours < 7) return 70 + (hours - 6) * 30;
  if (hours > 8 && hours <= 9) return 100 - (hours - 8) * 20;
  if (hours < 6) return Math.max(0, hours * 11.67);
  return 60; // 9時間超
}

function scoreDeepSleep(ratio: number): number {
  // 15-25%が理想
  if (ratio >= 0.15 && ratio <= 0.25) return 100;
  if (ratio < 0.15) return (ratio / 0.15) * 100;
  return Math.max(60, 100 - (ratio - 0.25) * 200);
}

function scoreRemSleep(ratio: number): number {
  // 20-25%が理想
  if (ratio >= 0.2 && ratio <= 0.25) return 100;
  if (ratio < 0.2) return (ratio / 0.2) * 100;
  return Math.max(60, 100 - (ratio - 0.25) * 200);
}
```

### 2.4 Rhythm Score（15%）

就寝・起床時刻の一貫性評価。直近 7 日間の標準偏差を使用。

```typescript
function calculateRhythmScore(
  bedtimeStddevMinutes: number,
  wakeTimeStddevMinutes: number
): number {
  const bedtimeScore = consistencyScore(bedtimeStddevMinutes);
  const wakeScore = consistencyScore(wakeTimeStddevMinutes);

  return (bedtimeScore + wakeScore) / 2;
}

function consistencyScore(stddevMinutes: number): number {
  if (stddevMinutes <= 15) return 100; // 非常に安定
  if (stddevMinutes <= 30) return 85; // 安定
  if (stddevMinutes <= 45) return 70; // やや安定
  if (stddevMinutes <= 60) return 55; // やや不安定
  if (stddevMinutes <= 90) return 40; // 不安定
  return 25; // 非常に不安定
}
```

### 2.5 Activity Score（10%）

前日の活動量評価。

```typescript
function calculateActivityScore(steps: number, goal: number = 8000): number {
  const ratio = steps / goal;

  if (ratio >= 1.0) return 100;
  if (ratio >= 0.75) return 80 + (ratio - 0.75) * 80;
  if (ratio >= 0.5) return 60 + (ratio - 0.5) * 80;
  return ratio * 120;
}
```

### 2.6 キャリブレーション期間

アプリ利用開始から 7 日間は「学習期間」。

| 期間       | Tempo Score           | 動作                                 |
| ---------- | --------------------- | ------------------------------------ |
| 1-7 日目   | 「Learning...」と表示 | 業界平均値をベースラインとして仮使用 |
| 8 日目以降 | 数値表示              | 個人ベースラインを使用               |

**仮ベースライン（キャリブレーション中）**:

| データ       | 仮値   |
| ------------ | ------ |
| HRV          | 50ms   |
| 睡眠時間     | 7 時間 |
| 安静時心拍数 | 60bpm  |

---

## 3. Rhythm フェーズ計算

### 3.1 概要

Rhythm 画面に表示する 1 日のエネルギーフェーズを算出。

**v1 アプローチ**: 起床時刻を基準とした固定オフセット方式

### 3.2 フェーズ定義

| フェーズ         | 開始時刻       | 終了時刻 | 科学的根拠                   |
| ---------------- | -------------- | -------- | ---------------------------- |
| Wake Window      | 起床           | 起床+2h  | 睡眠慣性からの移行期         |
| Peak Focus       | 起床+2h        | 起床+5h  | コルチゾールピーク、体温上昇 |
| Afternoon Dip    | 起床+7h        | 起床+9h  | サーカディアン低点、体温低下 |
| Second Wind      | 起床+10h       | 起床+13h | 夕方のエネルギー回復         |
| Wind Down        | 就寝目標-2h    | 就寝目標 | メラトニン分泌開始           |
| Melatonin Window | 就寝目標-30min | 起床     | 睡眠期間                     |

### 3.3 算出ロジック

```typescript
interface RhythmPhase {
  name: string;
  start: Date;
  end: Date;
  type: "high" | "low" | "transition" | "sleep";
}

function calculatePhases(
  wakeUpTime: string, // "07:00"
  windDownTime: string // "23:00"
): RhythmPhase[] {
  const wake = parseTime(wakeUpTime);
  const sleep = parseTime(windDownTime);

  return [
    {
      name: "Wake Window",
      start: wake,
      end: addHours(wake, 2),
      type: "transition",
    },
    {
      name: "Peak Focus",
      start: addHours(wake, 2),
      end: addHours(wake, 5),
      type: "high",
    },
    {
      name: "Afternoon Dip",
      start: addHours(wake, 7),
      end: addHours(wake, 9),
      type: "low",
    },
    {
      name: "Second Wind",
      start: addHours(wake, 10),
      end: addHours(wake, 13),
      type: "high",
    },
    {
      name: "Wind Down",
      start: addHours(sleep, -2),
      end: sleep,
      type: "transition",
    },
    {
      name: "Melatonin Window",
      start: addMinutes(sleep, -30),
      end: wake,
      type: "sleep",
    },
  ];
}
```

### 3.4 エネルギー曲線の描画

グラフ用のエネルギーレベルを時間ごとに算出。

```typescript
function calculateEnergyCurve(
  wakeUpTime: string,
  windDownTime: string
): { hour: number; level: number }[] {
  const wake = parseHour(wakeUpTime);
  const sleep = parseHour(windDownTime);

  const curve: { hour: number; level: number }[] = [];

  for (let h = 0; h < 24; h++) {
    const hoursSinceWake = (h - wake + 24) % 24;
    curve.push({
      hour: h,
      level: getEnergyLevel(hoursSinceWake, wake, sleep),
    });
  }

  return curve;
}

function getEnergyLevel(
  hoursSinceWake: number,
  wakeHour: number,
  sleepHour: number
): number {
  // 0-100のエネルギーレベルを返す

  // 睡眠中
  if (hoursSinceWake < 0 || hoursSinceWake > (sleepHour - wakeHour + 24) % 24) {
    return 10;
  }

  // Wake Window (0-2h): 30→60に上昇
  if (hoursSinceWake < 2) {
    return 30 + (hoursSinceWake / 2) * 30;
  }

  // Peak Focus (2-5h): 60→90に上昇
  if (hoursSinceWake < 5) {
    return 60 + ((hoursSinceWake - 2) / 3) * 30;
  }

  // Post-Peak (5-7h): 90→70に下降
  if (hoursSinceWake < 7) {
    return 90 - ((hoursSinceWake - 5) / 2) * 20;
  }

  // Afternoon Dip (7-9h): 70→50に下降
  if (hoursSinceWake < 9) {
    return 70 - ((hoursSinceWake - 7) / 2) * 20;
  }

  // Recovery (9-10h): 50→70に上昇
  if (hoursSinceWake < 10) {
    return 50 + (hoursSinceWake - 9) * 20;
  }

  // Second Wind (10-13h): 70→80
  if (hoursSinceWake < 13) {
    return 70 + ((hoursSinceWake - 10) / 3) * 10;
  }

  // Wind Down (13h+): 80→30に下降
  const hoursUntilSleep = ((sleepHour - wakeHour + 24) % 24) - hoursSinceWake;
  if (hoursUntilSleep > 0) {
    return 30 + (hoursUntilSleep / 3) * 20;
  }

  return 30;
}
```

---

## 4. Alerts 条件

### 4.1 RECENT ALERTS トリガー

Insights 画面に表示するアラートの生成条件。

| 条件                   | アラートタイプ    | アイコン | 優先度 |
| ---------------------- | ----------------- | -------- | ------ |
| HRV < ベースライン-20% | Recovery Needed   | ⚠️       | 高     |
| HRV > ベースライン+15% | Recovery Complete | ✓        | 低     |
| 睡眠時間 < 6 時間      | Sleep Deficit     | 🌙       | 高     |
| 就寝時刻 > 目標+1 時間 | Late Bedtime      | ⏰       | 中     |
| 週末起床ズレ > 2 時間  | Weekend Jetlag    | 📅       | 中     |
| 活動量 < 3000 歩       | Low Activity      | 🚶       | 低     |

### 4.2 アラート生成ロジック

```typescript
interface Alert {
  type: string;
  icon: string;
  message: string;
  timestamp: Date;
  priority: "high" | "medium" | "low";
}

function generateAlerts(
  hrv: { current: number; baseline: number },
  sleep: { duration: number; bedtime: Date; targetBedtime: Date },
  activity: { steps: number },
  rhythmData: { weekendWakeShift: number }
): Alert[] {
  const alerts: Alert[] = [];
  const now = new Date();

  // HRV低下
  if (hrv.current < hrv.baseline * 0.8) {
    alerts.push({
      type: "recovery_needed",
      icon: "⚠️",
      message: "Your HRV is lower than usual. Consider taking it easy today.",
      timestamp: now,
      priority: "high",
    });
  }

  // HRV回復
  if (hrv.current > hrv.baseline * 1.15) {
    alerts.push({
      type: "recovery_complete",
      icon: "✓",
      message: "Your recovery looks great. You're ready for challenges.",
      timestamp: now,
      priority: "low",
    });
  }

  // 睡眠不足
  if (sleep.duration < 360) {
    // 6時間未満
    alerts.push({
      type: "sleep_deficit",
      icon: "🌙",
      message: `Only ${Math.floor(sleep.duration / 60)}h ${
        sleep.duration % 60
      }m of sleep. Try to rest earlier tonight.`,
      timestamp: now,
      priority: "high",
    });
  }

  // 遅い就寝
  const bedtimeDelay =
    (sleep.bedtime.getTime() - sleep.targetBedtime.getTime()) / (1000 * 60);
  if (bedtimeDelay > 60) {
    alerts.push({
      type: "late_bedtime",
      icon: "⏰",
      message:
        "You went to bed later than your target. Try to wind down earlier.",
      timestamp: now,
      priority: "medium",
    });
  }

  // 週末時差ボケ
  if (rhythmData.weekendWakeShift > 120) {
    // 2時間以上
    alerts.push({
      type: "weekend_jetlag",
      icon: "📅",
      message:
        "Weekend sleep schedule shift detected. This may affect Monday energy.",
      timestamp: now,
      priority: "medium",
    });
  }

  // 活動量不足
  if (activity.steps < 3000) {
    alerts.push({
      type: "low_activity",
      icon: "🚶",
      message:
        "Low activity yesterday. A short walk today can help your rhythm.",
      timestamp: now,
      priority: "low",
    });
  }

  return alerts.sort((a, b) => {
    const priorityOrder = { high: 0, medium: 1, low: 2 };
    return priorityOrder[a.priority] - priorityOrder[b.priority];
  });
}
```

---

## 5. 将来拡張

### 5.1 クロノタイプ判定（v2 以降）

30 日以上のデータ蓄積後、個人のクロノタイプを判定。

| クロノタイプ  | 説明     | 判定基準                |
| ------------- | -------- | ----------------------- |
| Early Morning | 超朝型   | 睡眠中央値 < 2:00 AM    |
| Morning       | 朝型     | 睡眠中央値 2:00-3:00 AM |
| Late Morning  | やや朝型 | 睡眠中央値 3:00-4:00 AM |
| Early Evening | やや夜型 | 睡眠中央値 4:00-5:00 AM |
| Evening       | 夜型     | 睡眠中央値 5:00-6:00 AM |
| Late Evening  | 超夜型   | 睡眠中央値 > 6:00 AM    |

### 5.2 Cosinor 分析（v2 以降）

HRV の日内変動パターンから個人のアクロフェーズ（ピーク時刻）を算出。

```typescript
interface CosinorParams {
  mesor: number; // 平均レベル
  amplitude: number; // 振幅
  acrophase: number; // ピーク時刻（時間）
}

function cosinorFit(
  hourlyData: { hour: number; value: number }[]
): CosinorParams {
  // y = M + A * cos(2π * (t - φ) / 24)
  // 最小二乗法でM, A, φを推定

  const n = hourlyData.length;
  const period = 24;

  // コサイン・サイン成分を計算
  let sumY = 0,
    sumCos = 0,
    sumSin = 0;
  let sumYCos = 0,
    sumYSin = 0;
  let sumCos2 = 0,
    sumSin2 = 0;

  for (const { hour, value } of hourlyData) {
    const theta = (2 * Math.PI * hour) / period;
    const cosTheta = Math.cos(theta);
    const sinTheta = Math.sin(theta);

    sumY += value;
    sumCos += cosTheta;
    sumSin += sinTheta;
    sumYCos += value * cosTheta;
    sumYSin += value * sinTheta;
    sumCos2 += cosTheta * cosTheta;
    sumSin2 += sinTheta * sinTheta;
  }

  const mesor = sumY / n;
  const beta =
    (sumYCos - (sumY * sumCos) / n) / (sumCos2 - (sumCos * sumCos) / n);
  const gamma =
    (sumYSin - (sumY * sumSin) / n) / (sumSin2 - (sumSin * sumSin) / n);

  const amplitude = Math.sqrt(beta * beta + gamma * gamma);
  const acrophase = (Math.atan2(gamma, beta) * 12) / Math.PI;

  return {
    mesor,
    amplitude,
    acrophase: (acrophase + 24) % 24,
  };
}
```

### 5.3 パーソナライズされたフェーズ計算（v2 以降）

7-30 日のデータから実際の HRV・活動パターンを分析し、個人のエネルギーピーク/ディップを検出。

| 入力データ            | 分析内容                   |
| --------------------- | -------------------------- |
| HRV の時間帯別平均    | 副交感神経優位時間帯を特定 |
| 活動量の時間帯別平均  | 自然な活動ピークを特定     |
| 手首体温（Series 8+） | 深部体温リズムを推定       |

---

## 6. ユーティリティ関数

```typescript
function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

function normalize(value: number, min: number, max: number): number {
  return clamp((value - min) / (max - min), 0, 1) * 100;
}

function parseTime(timeString: string): Date {
  const [hours, minutes] = timeString.split(":").map(Number);
  const date = new Date();
  date.setHours(hours, minutes, 0, 0);
  return date;
}

function parseHour(timeString: string): number {
  return parseInt(timeString.split(":")[0], 10);
}

function addHours(date: Date, hours: number): Date {
  return new Date(date.getTime() + hours * 60 * 60 * 1000);
}

function addMinutes(date: Date, minutes: number): Date {
  return new Date(date.getTime() + minutes * 60 * 1000);
}
```

---

## 改訂履歴

| バージョン | 日付       | 変更内容                                |
| ---------- | ---------- | --------------------------------------- |
| 1.0        | 2025-01-01 | 初版作成                                |
| 2.0        | 2026-01-06 | Tempo Score 中心に簡素化                |
| 3.0        | 2026-01-06 | Rhythm フェーズ計算、Cosinor 分析を追加 |
