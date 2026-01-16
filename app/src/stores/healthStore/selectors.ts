/**
 * HealthStore セレクター関数
 */

import type { HealthState } from "./types";
import type {
	DailySnapshot,
	RealtimeMetrics,
	RecoveryDetailWithChart,
	SleepDetailWithChart,
	RhythmDetailWithChart,
	EnergyDetailWithChart,
} from "../../domain/models";
import type { EnvironmentData } from "../../domain/models/environment";
import type { RhythmPhase, WindowCardData } from "../../domain/models/rhythm";
import type { RhythmDataPoint } from "../../domain/services/rhythmCalculator";
import { formatDateString } from "../../constants/mockDataFactory";
import { useHealthStore } from "./index";

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

// =============================================================================
// Detail Data Selectors (React Hooks)
// =============================================================================

/**
 * Hook to get recovery detail data with chart
 */
export const useRecoveryDetail = (): RecoveryDetailWithChart | null => {
  return useHealthStore((state) => state.detailData.recovery as RecoveryDetailWithChart | null);
};

/**
 * Hook to get sleep detail data with chart
 */
export const useSleepDetail = (): SleepDetailWithChart | null => {
  return useHealthStore((state) => state.detailData.sleep as SleepDetailWithChart | null);
};

/**
 * Hook to get rhythm detail data with chart
 */
export const useRhythmDetail = (): RhythmDetailWithChart | null => {
  return useHealthStore((state) => state.detailData.rhythm as RhythmDetailWithChart | null);
};

/**
 * Hook to get energy detail data with chart
 */
export const useEnergyDetail = (): EnergyDetailWithChart | null => {
  return useHealthStore((state) => state.detailData.energy as EnergyDetailWithChart | null);
};

// =============================================================================
// Environment Data Selectors
// =============================================================================

/**
 * Hook to get environment data (sunrise/sunset, weather, pressure, UV, moon phase)
 */
export const useEnvironmentData = (): EnvironmentData | null => {
  return useHealthStore((state) => state.environmentData);
};

// =============================================================================
// Chart Data Selectors
// =============================================================================

/**
 * Hook to get rhythm chart data for the rhythm screen
 * Returns RhythmDataPoint[] converted from energy curve, or null if not available
 */
export const useRhythmChartData = (): RhythmDataPoint[] | null => {
  return useHealthStore((state) => {
    const energyCurve = state.energyCurve;
    if (!energyCurve) return null;

    // Convert EnergyCurve to RhythmDataPoint format
    const formatHourTo12H = (hour: number): string => {
      const h = hour % 24;
      if (h === 0) return "12 AM";
      if (h === 12) return "12 PM";
      return h > 12 ? `${h - 12} PM` : `${h} AM`;
    };

    return energyCurve
      .filter((point) => point.hour >= 6 && point.hour <= 24)
      .map((point) => ({
        time: formatHourTo12H(point.hour),
        hour: point.hour,
        energy: point.level,
      }));
  });
};

/**
 * Upcoming windows data for rhythm screen
 */
interface UpcomingWindows {
  peakFocus: WindowCardData | null;
  melatoninWindow: WindowCardData | null;
}

/**
 * Hook to get upcoming activity windows from circadian rhythm
 */
export const useUpcomingWindows = (): UpcomingWindows => {
  return useHealthStore((state) => {
    const circadianRhythm = state.circadianRhythm;

    if (!circadianRhythm || !circadianRhythm.phases) {
      return { peakFocus: null, melatoninWindow: null };
    }

    // Find Peak Focus phase
    const peakFocusPhase = circadianRhythm.phases.find(
      (p) => p.name === "Peak Focus"
    );
    const peakFocus: WindowCardData | null = peakFocusPhase
      ? {
          title: "Peak Focus",
          timeRange: `${peakFocusPhase.start.getHours()}:00 - ${peakFocusPhase.end.getHours()}:00`,
          description: "Optimal time for focused work",
          icon: "sun",
          theme: "day",
          isActive: peakFocusPhase.isCurrent,
        }
      : null;

    // Find Melatonin Window phase
    const melatoninPhase = circadianRhythm.phases.find(
      (p) => p.name === "Melatonin Window"
    );
    const melatoninWindow: WindowCardData | null = melatoninPhase
      ? {
          title: "Melatonin Window",
          timeRange: `${melatoninPhase.start.getHours()}:00 - ${melatoninPhase.end.getHours()}:00`,
          description: "Natural sleep onset window",
          icon: "moon",
          theme: "night",
          isActive: melatoninPhase.isCurrent,
        }
      : null;

    return { peakFocus, melatoninWindow };
  });
};

/**
 * Hook to get score chart data for today's main screen
 * Returns simple number arrays for sparkline charts
 */
export const useScoreChartDataForToday = (): {
  recovery: number[];
  sleep: number[];
  rhythm: number[];
  energy: number[];
} => {
  return useHealthStore((state) => {
    const defaultData: number[] = [];

    const mapHistory = (history: { samples: { date: Date; value: number }[] } | null): number[] => {
      if (!history || history.samples.length === 0) return defaultData;
      return history.samples.slice(0, 7).map((s) => s.value);
    };

    return {
      recovery: mapHistory(state.scoreHistories.recovery),
      sleep: mapHistory(state.scoreHistories.sleep),
      rhythm: mapHistory(state.scoreHistories.rhythm),
      energy: mapHistory(state.scoreHistories.energy),
    };
  });
};
