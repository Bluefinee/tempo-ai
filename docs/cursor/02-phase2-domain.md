# Phase 2: ドメインモデル・サービス

## 目的

- Rhythm フェーズ計算の実装
- Tempo Score 計算サービスの実装
- Alert 生成サービスの実装
- フォーマットユーティリティの実装

---

## 開始前に読むべきドキュメント

**必ず以下のドキュメントを全て読んでから実装を開始すること:**

| ドキュメント | パス | 確認ポイント |
|-------------|------|-------------|
| CLAUDE.md | `/CLAUDE.md` | DDD原則、SOLID原則、エラーハンドリング |
| React Native規約 | `/.claude/react-native-standards.md` | ドメインモデル・サービスの構成 |
| メトリクス仕様 | `/docs/specs/metrics_spec.md` | **Tempo Score算出ロジック、Rhythmフェーズ計算、Alerts条件** |
| 製品仕様 | `/docs/specs/product_spec.md` | 機能要件 |

**特に重要**: `/docs/specs/metrics_spec.md` の以下セクションを熟読すること:
- Section 2: Tempo Score（算出式、各スコアの計算方法）
- Section 3: Rhythm フェーズ計算（フェーズ定義、エネルギー曲線）
- Section 4: Alerts 条件（トリガー条件）

---

## Task 2.1: Rhythm ドメインモデル

### `app/src/domain/models/rhythm.ts` を新規作成

```typescript
/**
 * Rhythm（サーカディアンリズム）ドメインモデル
 * @see docs/specs/metrics_spec.md Section 3
 */

export type RhythmPhaseName =
  | 'Wake Window'
  | 'Peak Focus'
  | 'Afternoon Dip'
  | 'Second Wind'
  | 'Wind Down'
  | 'Melatonin Window';

export type RhythmPhaseType = 'high' | 'low' | 'transition' | 'sleep';

export interface RhythmPhase {
  readonly name: RhythmPhaseName;
  readonly start: Date;
  readonly end: Date;
  readonly type: RhythmPhaseType;
  readonly isCurrent: boolean;
}

export interface CircadianRhythm {
  readonly phases: readonly RhythmPhase[];
  readonly currentPhase: RhythmPhase | null;
  readonly nextPhase: RhythmPhase | null;
  readonly minutesToNextPhase: number | null;
  readonly sunrise: string;
  readonly sunset: string;
}

export interface EnergyCurvePoint {
  readonly hour: number;
  readonly level: number; // 0-100
}

export type EnergyCurve = readonly EnergyCurvePoint[];
```

---

## Task 2.2: Insight ドメインモデル

### `app/src/domain/models/insight.ts` を新規作成

```typescript
/**
 * Insight（インサイト・アラート）ドメインモデル
 * @see docs/specs/metrics_spec.md Section 4
 */

export type AlertType =
  | 'recovery_needed'
  | 'recovery_complete'
  | 'sleep_deficit'
  | 'late_bedtime'
  | 'weekend_jetlag'
  | 'low_activity';

export type AlertPriority = 'high' | 'medium' | 'low';

export type AlertIcon = '⚠️' | '✓' | '🌙' | '⏰' | '📅' | '🚶';

export interface Alert {
  readonly id: string;
  readonly type: AlertType;
  readonly icon: AlertIcon;
  readonly title: string;
  readonly message: string;
  readonly timestamp: Date;
  readonly priority: AlertPriority;
}

export interface TopDiscovery {
  readonly title: string;
  readonly description: string;
  readonly impact?: string; // e.g., "+18% deep sleep"
}

export interface WeeklyInsight {
  readonly weeklyScores: readonly number[]; // 7日分
  readonly avgScore: number;
  readonly topDiscovery: TopDiscovery | null;
  readonly recentAlerts: readonly Alert[];
}
```

---

## Task 2.3: Tempo Score 計算サービス

### `app/src/domain/services/tempoScoreCalculator.ts` を新規作成

```typescript
/**
 * Tempo Score 計算サービス
 * @see docs/specs/metrics_spec.md Section 2
 *
 * Tempo Score = HRV Score × 0.40
 *             + Sleep Score × 0.35
 *             + Rhythm Score × 0.15
 *             + Activity Score × 0.10
 */

// ========================================
// Types
// ========================================

export interface SleepMetrics {
  readonly durationMinutes: number;
  readonly deepSleepRatio: number; // 0.0-1.0
  readonly remSleepRatio: number;  // 0.0-1.0
}

export interface HrvMetrics {
  readonly current: number;       // ms
  readonly baseline30d: number;   // ms
}

export interface RhythmMetrics {
  readonly bedtimeStddevMinutes: number;
  readonly wakeTimeStddevMinutes: number;
}

export interface ActivityMetrics {
  readonly steps: number;
  readonly goal?: number; // default: 8000
}

export interface TempoScoreComponents {
  readonly hrvScore: number;
  readonly sleepScore: number;
  readonly rhythmScore: number;
  readonly activityScore: number;
}

export interface TempoScoreResult {
  readonly score: number;
  readonly components: TempoScoreComponents;
  readonly isCalibrating: boolean;
}

// ========================================
// Utility Functions
// ========================================

const clamp = (value: number, min: number, max: number): number =>
  Math.max(min, Math.min(max, value));

// ========================================
// HRV Score (40%)
// ========================================

export const calculateHrvScore = (hrv: HrvMetrics): number => {
  if (hrv.baseline30d === 0) return 70; // キャリブレーション中

  const ratio = hrv.current / hrv.baseline30d;
  const baseScore = 70;
  const deviation = (ratio - 1.0) * 100;

  return clamp(baseScore + deviation, 0, 100);
};

// ========================================
// Sleep Score (35%)
// ========================================

const scoreDuration = (minutes: number): number => {
  const hours = minutes / 60;
  if (hours >= 7 && hours <= 8) return 100;
  if (hours >= 6 && hours < 7) return 70 + (hours - 6) * 30;
  if (hours > 8 && hours <= 9) return 100 - (hours - 8) * 20;
  if (hours < 6) return Math.max(0, hours * 11.67);
  return 60; // 9時間超
};

const scoreDeepSleep = (ratio: number): number => {
  // 15-25%が理想
  if (ratio >= 0.15 && ratio <= 0.25) return 100;
  if (ratio < 0.15) return (ratio / 0.15) * 100;
  return Math.max(60, 100 - (ratio - 0.25) * 200);
};

const scoreRemSleep = (ratio: number): number => {
  // 20-25%が理想
  if (ratio >= 0.2 && ratio <= 0.25) return 100;
  if (ratio < 0.2) return (ratio / 0.2) * 100;
  return Math.max(60, 100 - (ratio - 0.25) * 200);
};

export const calculateSleepScore = (sleep: SleepMetrics): number => {
  const durationScore = scoreDuration(sleep.durationMinutes);
  const deepScore = scoreDeepSleep(sleep.deepSleepRatio);
  const remScore = scoreRemSleep(sleep.remSleepRatio);

  return durationScore * 0.5 + deepScore * 0.3 + remScore * 0.2;
};

// ========================================
// Rhythm Score (15%)
// ========================================

const consistencyScore = (stddevMinutes: number): number => {
  if (stddevMinutes <= 15) return 100; // 非常に安定
  if (stddevMinutes <= 30) return 85;  // 安定
  if (stddevMinutes <= 45) return 70;  // やや安定
  if (stddevMinutes <= 60) return 55;  // やや不安定
  if (stddevMinutes <= 90) return 40;  // 不安定
  return 25; // 非常に不安定
};

export const calculateRhythmScore = (rhythm: RhythmMetrics): number => {
  const bedtimeScore = consistencyScore(rhythm.bedtimeStddevMinutes);
  const wakeScore = consistencyScore(rhythm.wakeTimeStddevMinutes);

  return (bedtimeScore + wakeScore) / 2;
};

// ========================================
// Activity Score (10%)
// ========================================

export const calculateActivityScore = (activity: ActivityMetrics): number => {
  const goal = activity.goal ?? 8000;
  const ratio = activity.steps / goal;

  if (ratio >= 1.0) return 100;
  if (ratio >= 0.75) return 80 + (ratio - 0.75) * 80;
  if (ratio >= 0.5) return 60 + (ratio - 0.5) * 80;
  return ratio * 120;
};

// ========================================
// Tempo Score (Total)
// ========================================

export const calculateTempoScore = (
  hrvMetrics: HrvMetrics | null,
  sleepMetrics: SleepMetrics | null,
  rhythmMetrics: RhythmMetrics | null,
  activityMetrics: ActivityMetrics | null,
  isCalibrating: boolean = false
): TempoScoreResult => {
  // デフォルト値（キャリブレーション中）
  const hrvScore = hrvMetrics ? calculateHrvScore(hrvMetrics) : 70;
  const sleepScore = sleepMetrics ? calculateSleepScore(sleepMetrics) : 70;
  const rhythmScore = rhythmMetrics ? calculateRhythmScore(rhythmMetrics) : 70;
  const activityScore = activityMetrics ? calculateActivityScore(activityMetrics) : 70;

  // 重み付け計算
  const score = clamp(
    hrvScore * 0.40 +
    sleepScore * 0.35 +
    rhythmScore * 0.15 +
    activityScore * 0.10,
    0,
    100
  );

  return {
    score: Math.round(score),
    components: {
      hrvScore: Math.round(hrvScore),
      sleepScore: Math.round(sleepScore),
      rhythmScore: Math.round(rhythmScore),
      activityScore: Math.round(activityScore),
    },
    isCalibrating,
  };
};
```

---

## Task 2.4: Rhythm 計算サービス

### `app/src/domain/services/rhythmCalculator.ts` を新規作成

```typescript
/**
 * Rhythm（サーカディアンリズム）計算サービス
 * @see docs/specs/metrics_spec.md Section 3
 */

import {
  RhythmPhase,
  RhythmPhaseName,
  RhythmPhaseType,
  CircadianRhythm,
  EnergyCurve,
  EnergyCurvePoint,
} from '../models/rhythm';

// ========================================
// Utility Functions
// ========================================

const parseTime = (timeString: string): Date => {
  const [hours, minutes] = timeString.split(':').map(Number);
  const date = new Date();
  date.setHours(hours, minutes, 0, 0);
  return date;
};

const parseHour = (timeString: string): number => {
  return parseInt(timeString.split(':')[0], 10);
};

const addHours = (date: Date, hours: number): Date => {
  return new Date(date.getTime() + hours * 60 * 60 * 1000);
};

const addMinutes = (date: Date, minutes: number): Date => {
  return new Date(date.getTime() + minutes * 60 * 1000);
};

const isTimeInRange = (time: Date, start: Date, end: Date): boolean => {
  const timeMs = time.getTime();
  const startMs = start.getTime();
  const endMs = end.getTime();

  if (startMs <= endMs) {
    return timeMs >= startMs && timeMs < endMs;
  }
  // 日付をまたぐ場合
  return timeMs >= startMs || timeMs < endMs;
};

const getMinutesBetween = (from: Date, to: Date): number => {
  return Math.round((to.getTime() - from.getTime()) / (1000 * 60));
};

// ========================================
// Phase Calculation
// ========================================

interface PhaseDefinition {
  name: RhythmPhaseName;
  type: RhythmPhaseType;
}

export const calculatePhases = (
  wakeUpTime: string,
  windDownTime: string
): readonly RhythmPhase[] => {
  const wake = parseTime(wakeUpTime);
  const sleep = parseTime(windDownTime);
  const now = new Date();

  const phaseDefinitions: Array<{
    definition: PhaseDefinition;
    start: Date;
    end: Date;
  }> = [
    {
      definition: { name: 'Wake Window', type: 'transition' },
      start: wake,
      end: addHours(wake, 2),
    },
    {
      definition: { name: 'Peak Focus', type: 'high' },
      start: addHours(wake, 2),
      end: addHours(wake, 5),
    },
    {
      definition: { name: 'Afternoon Dip', type: 'low' },
      start: addHours(wake, 7),
      end: addHours(wake, 9),
    },
    {
      definition: { name: 'Second Wind', type: 'high' },
      start: addHours(wake, 10),
      end: addHours(wake, 13),
    },
    {
      definition: { name: 'Wind Down', type: 'transition' },
      start: addMinutes(sleep, -120),
      end: sleep,
    },
    {
      definition: { name: 'Melatonin Window', type: 'sleep' },
      start: addMinutes(sleep, -30),
      end: wake,
    },
  ];

  return phaseDefinitions.map(({ definition, start, end }) => ({
    name: definition.name,
    type: definition.type,
    start,
    end,
    isCurrent: isTimeInRange(now, start, end),
  }));
};

// ========================================
// Circadian Rhythm
// ========================================

export const calculateCircadianRhythm = (
  wakeUpTime: string,
  windDownTime: string,
  sunrise: string,
  sunset: string
): CircadianRhythm => {
  const phases = calculatePhases(wakeUpTime, windDownTime);
  const now = new Date();

  const currentPhase = phases.find((p) => p.isCurrent) ?? null;

  // 次のフェーズを見つける
  let nextPhase: RhythmPhase | null = null;
  let minutesToNextPhase: number | null = null;

  if (currentPhase) {
    const currentIndex = phases.findIndex((p) => p.name === currentPhase.name);
    const nextIndex = (currentIndex + 1) % phases.length;
    nextPhase = phases[nextIndex];
    minutesToNextPhase = getMinutesBetween(now, currentPhase.end);
  }

  return {
    phases,
    currentPhase,
    nextPhase,
    minutesToNextPhase,
    sunrise,
    sunset,
  };
};

// ========================================
// Energy Curve (for Graph)
// ========================================

const getEnergyLevel = (
  hoursSinceWake: number,
  wakeHour: number,
  sleepHour: number
): number => {
  const awakeHours = (sleepHour - wakeHour + 24) % 24;

  // 睡眠中
  if (hoursSinceWake < 0 || hoursSinceWake > awakeHours) {
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
  const hoursUntilSleep = awakeHours - hoursSinceWake;
  if (hoursUntilSleep > 0) {
    return 30 + (hoursUntilSleep / 3) * 20;
  }

  return 30;
};

export const calculateEnergyCurve = (
  wakeUpTime: string,
  windDownTime: string
): EnergyCurve => {
  const wakeHour = parseHour(wakeUpTime);
  const sleepHour = parseHour(windDownTime);

  const curve: EnergyCurvePoint[] = [];

  for (let h = 0; h < 24; h++) {
    const hoursSinceWake = (h - wakeHour + 24) % 24;
    curve.push({
      hour: h,
      level: Math.round(getEnergyLevel(hoursSinceWake, wakeHour, sleepHour)),
    });
  }

  return curve;
};
```

---

## Task 2.5: Alert 生成サービス

### `app/src/domain/services/alertGenerator.ts` を新規作成

```typescript
/**
 * Alert 生成サービス
 * @see docs/specs/metrics_spec.md Section 4
 */

import { Alert, AlertType, AlertIcon, AlertPriority } from '../models/insight';
import { HrvMetrics, SleepMetrics, ActivityMetrics } from './tempoScoreCalculator';

// ========================================
// Types
// ========================================

interface AlertInput {
  hrv: HrvMetrics | null;
  sleep: {
    durationMinutes: number;
    bedtime: Date;
    targetBedtime: Date;
  } | null;
  activity: ActivityMetrics | null;
  rhythmData: {
    weekendWakeShiftMinutes: number;
  } | null;
}

interface AlertDefinition {
  type: AlertType;
  icon: AlertIcon;
  title: string;
  message: string;
  priority: AlertPriority;
}

// ========================================
// Alert Generation
// ========================================

const generateId = (): string => {
  return `alert_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
};

export const generateAlerts = (input: AlertInput): readonly Alert[] => {
  const alerts: Alert[] = [];
  const now = new Date();

  // HRV低下
  if (input.hrv && input.hrv.baseline30d > 0) {
    if (input.hrv.current < input.hrv.baseline30d * 0.8) {
      alerts.push({
        id: generateId(),
        type: 'recovery_needed',
        icon: '⚠️',
        title: 'Recovery Needed',
        message: 'Your HRV is lower than usual. Consider taking it easy today.',
        timestamp: now,
        priority: 'high',
      });
    }

    // HRV回復
    if (input.hrv.current > input.hrv.baseline30d * 1.15) {
      alerts.push({
        id: generateId(),
        type: 'recovery_complete',
        icon: '✓',
        title: 'Recovery Complete',
        message: "Your recovery looks great. You're ready for challenges.",
        timestamp: now,
        priority: 'low',
      });
    }
  }

  // 睡眠不足
  if (input.sleep && input.sleep.durationMinutes < 360) {
    const hours = Math.floor(input.sleep.durationMinutes / 60);
    const mins = input.sleep.durationMinutes % 60;
    alerts.push({
      id: generateId(),
      type: 'sleep_deficit',
      icon: '🌙',
      title: 'Sleep Deficit',
      message: `Only ${hours}h ${mins}m of sleep. Try to rest earlier tonight.`,
      timestamp: now,
      priority: 'high',
    });
  }

  // 遅い就寝
  if (input.sleep) {
    const bedtimeDelay =
      (input.sleep.bedtime.getTime() - input.sleep.targetBedtime.getTime()) /
      (1000 * 60);
    if (bedtimeDelay > 60) {
      alerts.push({
        id: generateId(),
        type: 'late_bedtime',
        icon: '⏰',
        title: 'Late Bedtime',
        message: 'You went to bed later than your target. Try to wind down earlier.',
        timestamp: now,
        priority: 'medium',
      });
    }
  }

  // 週末時差ボケ
  if (input.rhythmData && input.rhythmData.weekendWakeShiftMinutes > 120) {
    alerts.push({
      id: generateId(),
      type: 'weekend_jetlag',
      icon: '📅',
      title: 'Weekend Jetlag',
      message: 'Weekend sleep schedule shift detected. This may affect Monday energy.',
      timestamp: now,
      priority: 'medium',
    });
  }

  // 活動量不足
  if (input.activity && input.activity.steps < 3000) {
    alerts.push({
      id: generateId(),
      type: 'low_activity',
      icon: '🚶',
      title: 'Low Activity',
      message: 'Low activity yesterday. A short walk today can help your rhythm.',
      timestamp: now,
      priority: 'low',
    });
  }

  // 優先度でソート
  const priorityOrder: Record<AlertPriority, number> = {
    high: 0,
    medium: 1,
    low: 2,
  };

  return alerts.sort(
    (a, b) => priorityOrder[a.priority] - priorityOrder[b.priority]
  );
};
```

---

## Task 2.6: フォーマットユーティリティ

### `app/src/utils/format.ts` を新規作成

```typescript
/**
 * フォーマットユーティリティ
 * @see docs/specs/i18n_design.md
 */

// ========================================
// Duration Formatting
// ========================================

export const formatDuration = (
  totalMinutes: number,
  locale: string = 'ja'
): string => {
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;

  if (locale === 'ja') {
    if (hours > 0 && minutes > 0) {
      return `${hours}時間${minutes}分`;
    }
    if (hours > 0) {
      return `${hours}時間`;
    }
    return `${minutes}分`;
  }

  // English
  if (hours > 0 && minutes > 0) {
    return `${hours}h ${minutes}m`;
  }
  if (hours > 0) {
    return `${hours}h`;
  }
  return `${minutes}m`;
};

export const formatDurationShort = (totalMinutes: number): string => {
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  return `${hours}h ${minutes}m`;
};

// ========================================
// Time Formatting
// ========================================

export const formatTime = (date: Date, locale: string = 'ja'): string => {
  return date.toLocaleTimeString(locale === 'ja' ? 'ja-JP' : 'en-US', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: locale !== 'ja',
  });
};

export const formatTimeRange = (
  start: Date,
  end: Date,
  locale: string = 'ja'
): string => {
  return `${formatTime(start, locale)} - ${formatTime(end, locale)}`;
};

// ========================================
// Date Formatting
// ========================================

export const formatDate = (date: Date, locale: string = 'ja'): string => {
  return date.toLocaleDateString(locale === 'ja' ? 'ja-JP' : 'en-US', {
    month: 'short',
    day: 'numeric',
  });
};

export const formatDateWithDayOfWeek = (
  date: Date,
  locale: string = 'ja'
): string => {
  return date.toLocaleDateString(locale === 'ja' ? 'ja-JP' : 'en-US', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
  });
};

// ========================================
// Number Formatting
// ========================================

export const formatNumber = (
  value: number,
  locale: string = 'ja'
): string => {
  return value.toLocaleString(locale === 'ja' ? 'ja-JP' : 'en-US');
};

export const formatPercentage = (
  value: number,
  locale: string = 'ja'
): string => {
  const percentage = Math.round(value * 100);
  return locale === 'ja' ? `${percentage}%` : `${percentage}%`;
};

// ========================================
// Score Formatting
// ========================================

export const formatScore = (score: number): string => {
  return Math.round(score).toString();
};

export const formatScoreWithMax = (score: number, max: number = 100): string => {
  return `${Math.round(score)}/${max}`;
};
```

---

## Task 2.7: ドメインモデル index 更新

### `app/src/domain/models/index.ts` を更新

```typescript
export * from './rhythm';
export * from './insight';
// 既存のエクスポートも維持
```

### `app/src/domain/services/index.ts` を更新

```typescript
export * from './tempoScoreCalculator';
export * from './rhythmCalculator';
export * from './alertGenerator';
// 既存のエクスポートも維持
```

---

## Phase 2 完了時の検証

### 必須コマンド（全てパスすること）

```bash
cd app

# 1. 型チェック
pnpm typecheck

# 2. リント
pnpm lint

# 3. テスト実行（既存テストが壊れていないか確認）
pnpm test

# 4. ビルド確認
pnpm ios --no-dev
```

### 完了チェックリスト

- [ ] `app/src/domain/models/rhythm.ts` が作成されている
- [ ] `app/src/domain/models/insight.ts` が作成されている
- [ ] `app/src/domain/services/tempoScoreCalculator.ts` が作成されている
- [ ] `app/src/domain/services/rhythmCalculator.ts` が作成されている
- [ ] `app/src/domain/services/alertGenerator.ts` が作成されている
- [ ] `app/src/utils/format.ts` が作成されている
- [ ] 全ての関数に明示的な戻り値型がある
- [ ] `any` 型を使用していない
- [ ] **`pnpm typecheck` でエラーなし**
- [ ] **`pnpm lint` でエラーなし**
- [ ] **`pnpm test` で既存テストが全てパス**
- [ ] **iOS ビルドが成功する**

---

## 次のフェーズ

Phase 2 の全てのチェックが完了したら、`03-phase3-components.md` に進む。
