/**
 * HealthStore セレクター関数
 */

import type { HealthState } from "./types";
import type { DailySnapshot, RealtimeMetrics } from "../../domain/models";
import type { RhythmPhase } from "../../domain/models/rhythm";
import { formatDateString } from "../../constants/mockDataFactory";

export const selectIsHealthDataStale = (state: HealthState): boolean => {
  if (!state.lastMetricsUpdate) return true;
  const hoursSinceUpdate =
    (Date.now() - state.lastMetricsUpdate.getTime()) / (1000 * 60 * 60);
  return hoursSinceUpdate > 6;
};

export const selectTempoScore = (state: HealthState): number | null =>
  state.tempoScore?.score ?? null;

export const selectIsCalibrating = (state: HealthState): boolean =>
  state.tempoScore?.isCalibrating ?? true;

export const selectCurrentPhase = (state: HealthState): RhythmPhase | null =>
  state.circadianRhythm?.currentPhase ?? null;

export const selectCalibrationProgress = (state: HealthState): number =>
  state.calibrationDaysCompleted / 7;

// HealthKit 対応: 新規セレクター
export const selectDailySnapshot = (state: HealthState): DailySnapshot | null =>
  state.dailySnapshot;

export const selectRealtimeMetrics = (
  state: HealthState,
): RealtimeMetrics | null => state.realtimeMetrics;

export const selectShouldCalculateSnapshot = (state: HealthState): boolean => {
  const today = formatDateString(new Date());
  return state.lastSnapshotDate !== today;
};
