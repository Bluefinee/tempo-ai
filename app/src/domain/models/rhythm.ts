/**
 * Rhythm（サーカディアンリズム）ドメインモデル
 * @see docs/specs/metrics_spec.md Section 3
 */

export type RhythmPhaseName =
  | "Wake Window"
  | "Peak Focus"
  | "Afternoon Dip"
  | "Second Wind"
  | "Wind Down"
  | "Melatonin Window";

export type RhythmPhaseType = "high" | "low" | "transition" | "sleep";

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

/**
 * RhythmAreaChart用のデータポイント
 */
export interface RhythmPoint {
  readonly time: string; // "6時", "12時" など
  readonly hour: number; // 6, 12, 18 など（計算用）
  readonly energy: number; // 0-100
  readonly label?: string; // "ピーク", "低迷期" など
}

/**
 * Upcoming Windowsカード用のデータ
 */
export interface WindowCardData {
  readonly title: string;
  readonly timeRange: string;
  readonly description: string;
  readonly icon: "sun" | "moon";
  readonly theme: "day" | "night";
  readonly isActive?: boolean;
}

/**
 * 日の出/日の入りデータ
 */
export interface SunData {
  readonly sunrise: string; // "7:12"
  readonly sunset: string; // "17:45"
}
