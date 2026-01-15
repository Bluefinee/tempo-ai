/**
 * HealthStore セレクター関数
 */

import { useMemo } from "react";
import { DATA_STALE_THRESHOLD_HOURS } from "../../constants/chartConstants";
import { formatDateString } from "../../constants/mockDataFactory";
import type {
	DailySnapshot,
	EnergyDetailData,
	EnergyDetailWithChart,
	HealthMetricHistory,
	RealtimeMetrics,
	RecoveryDetailData,
	RecoveryDetailWithChart,
	RhythmDetailData,
	RhythmDetailWithChart,
	SleepDetailData,
	SleepDetailWithChart,
} from "../../domain/models";
import type { EnvironmentData } from "../../domain/models/environment";
import type { EnergyCurve, RhythmPhase } from "../../domain/models/rhythm";
import {
	convertEnergyCurveToRhythmData,
	type RhythmDataPoint,
} from "../../domain/services/rhythmCalculator";
import { t } from "../../i18n";
import { useHealthStore } from "./index";
import type { HealthState } from "./types";

export const selectIsHealthDataStale = (state: HealthState): boolean => {
	if (!state.lastMetricsUpdate) return true;
	const hoursSinceUpdate =
		(Date.now() - state.lastMetricsUpdate.getTime()) / (1000 * 60 * 60);
	return hoursSinceUpdate > DATA_STALE_THRESHOLD_HOURS;
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
// Detail Screen Selectors
// =============================================================================

/**
 * Chart data point format for HealthAreaChart
 */
export interface ChartDataPoint {
	day: string;
	value: number;
}

/**
 * Transform HealthMetricHistory to chart data format
 * Compatible with HealthAreaChart (uses 'day' property)
 */
const transformToChartData = (
	history: HealthMetricHistory | null,
): {
	"7D": ChartDataPoint[];
	"30D": ChartDataPoint[];
	"60D": ChartDataPoint[];
} => {
	if (!history || history.samples.length === 0) {
		return { "7D": [], "30D": [], "60D": [] };
	}

	const formatDay = (date: Date): string => {
		const dayKeys = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"] as const;
		return t(`common.weekdays.short.${dayKeys[date.getDay()]}`);
	};

	const _formatWeek = (index: number, total: number): string => {
		if (index === total - 1) return "Now";
		const weeksAgo = Math.floor((total - 1 - index) / 7);
		return `W${weeksAgo + 1}`;
	};

	const transform7D = (samples: { date: Date; value: number }[]) =>
		samples.map((s) => ({
			day: formatDay(s.date),
			value: Math.round(s.value),
		}));

	const transform30D = (samples: { date: Date; value: number }[]) => {
		// Group into 5 data points for 30D view
		const labels = [
			t("common.period.weeksAgo", { count: 4 }),
			t("common.period.weeksAgo", { count: 3 }),
			t("common.period.weeksAgo", { count: 2 }),
			t("common.period.weeksAgo", { count: 1 }),
			t("common.period.now"),
		];
		const chunkSize = Math.ceil(samples.length / 5);
		return labels.map((label, i) => {
			const start = i * chunkSize;
			const chunk = samples.slice(start, start + chunkSize);
			const avg = chunk.reduce((sum, s) => sum + s.value, 0) / chunk.length;
			return { day: label, value: Math.round(avg) };
		});
	};

	const transform60D = (samples: { date: Date; value: number }[]) => {
		// Group into 5 data points for 60D view
		const labels = [
			t("common.period.weeksAgo", { count: 8 }),
			t("common.period.weeksAgo", { count: 6 }),
			t("common.period.weeksAgo", { count: 4 }),
			t("common.period.weeksAgo", { count: 2 }),
			t("common.period.now"),
		];
		const chunkSize = Math.ceil(samples.length / 5);
		return labels.map((label, i) => {
			const start = i * chunkSize;
			const chunk = samples.slice(start, start + chunkSize);
			const avg = chunk.reduce((sum, s) => sum + s.value, 0) / chunk.length;
			return { day: label, value: Math.round(avg) };
		});
	};

	return {
		"7D": transform7D(history.samples.slice(-7)),
		"30D": transform30D(history.samples.slice(-30)),
		"60D": transform60D(history.samples),
	};
};

/**
 * Select Recovery Detail with chart data
 */
export const selectRecoveryDetail = (
	state: HealthState,
): RecoveryDetailData | null => state.detailData.recovery;

export const selectRecoveryDetailWithChart = (
	state: HealthState,
): RecoveryDetailWithChart | null => {
	const detail = state.detailData.recovery;
	const history = state.scoreHistories.recovery;

	if (!detail) return null;

	return {
		...detail,
		chartData: transformToChartData(history),
	};
};

/**
 * Select Sleep Detail with chart data
 */
export const selectSleepDetail = (state: HealthState): SleepDetailData | null =>
	state.detailData.sleep;

export const selectSleepDetailWithChart = (
	state: HealthState,
): SleepDetailWithChart | null => {
	const detail = state.detailData.sleep;
	const history = state.scoreHistories.sleep;

	if (!detail) return null;

	return {
		...detail,
		chartData: transformToChartData(history),
	};
};

/**
 * Select Rhythm Detail with chart data
 */
export const selectRhythmDetail = (
	state: HealthState,
): RhythmDetailData | null => state.detailData.rhythm;

export const selectRhythmDetailWithChart = (
	state: HealthState,
): RhythmDetailWithChart | null => {
	const detail = state.detailData.rhythm;
	const history = state.scoreHistories.rhythm;

	if (!detail) return null;

	return {
		...detail,
		chartData: transformToChartData(history),
	};
};

/**
 * Select Energy Detail with chart data
 */
export const selectEnergyDetail = (
	state: HealthState,
): EnergyDetailData | null => state.detailData.energy;

export const selectEnergyDetailWithChart = (
	state: HealthState,
): EnergyDetailWithChart | null => {
	const detail = state.detailData.energy;
	const history = state.scoreHistories.energy;

	if (!detail) return null;

	return {
		...detail,
		chartData: transformToChartData(history),
	};
};

// =============================================================================
// Hook-based Selectors (with memoization)
// =============================================================================

/**
 * Hook to get Recovery Detail with chart data
 */
export const useRecoveryDetail = (): RecoveryDetailWithChart | null => {
	const detail = useHealthStore((s) => s.detailData.recovery);
	const history = useHealthStore((s) => s.scoreHistories.recovery);

	return useMemo(() => {
		if (!detail) return null;
		return {
			...detail,
			chartData: transformToChartData(history),
		};
	}, [detail, history]);
};

/**
 * Hook to get Sleep Detail with chart data
 */
export const useSleepDetail = (): SleepDetailWithChart | null => {
	const detail = useHealthStore((s) => s.detailData.sleep);
	const history = useHealthStore((s) => s.scoreHistories.sleep);

	return useMemo(() => {
		if (!detail) return null;
		return {
			...detail,
			chartData: transformToChartData(history),
		};
	}, [detail, history]);
};

/**
 * Hook to get Rhythm Detail with chart data
 */
export const useRhythmDetail = (): RhythmDetailWithChart | null => {
	const detail = useHealthStore((s) => s.detailData.rhythm);
	const history = useHealthStore((s) => s.scoreHistories.rhythm);

	return useMemo(() => {
		if (!detail) return null;
		return {
			...detail,
			chartData: transformToChartData(history),
		};
	}, [detail, history]);
};

/**
 * Hook to get Energy Detail with chart data
 */
export const useEnergyDetail = (): EnergyDetailWithChart | null => {
	const detail = useHealthStore((s) => s.detailData.energy);
	const history = useHealthStore((s) => s.scoreHistories.energy);

	return useMemo(() => {
		if (!detail) return null;
		return {
			...detail,
			chartData: transformToChartData(history),
		};
	}, [detail, history]);
};

// =============================================================================
// Rhythm Screen Selectors
// =============================================================================

/**
 * Select EnergyCurve
 */
export const selectEnergyCurve = (state: HealthState): EnergyCurve | null =>
	state.energyCurve;

/**
 * Select EnvironmentData
 */
export const selectEnvironmentData = (
	state: HealthState,
): EnvironmentData | null => state.environmentData;

/**
 * Select EnergyCurve transformed to RhythmDataPoint[] for chart
 */
export const selectRhythmChartData = (
	state: HealthState,
): readonly RhythmDataPoint[] | null => {
	if (!state.energyCurve) return null;
	return convertEnergyCurveToRhythmData(state.energyCurve);
};

/**
 * Hook to get Rhythm chart data with memoization
 */
export const useRhythmChartData = (): readonly RhythmDataPoint[] | null => {
	const energyCurve = useHealthStore((s) => s.energyCurve);

	return useMemo(() => {
		if (!energyCurve) return null;
		return convertEnergyCurveToRhythmData(energyCurve);
	}, [energyCurve]);
};

/**
 * Hook to get Environment data
 */
export const useEnvironmentData = (): EnvironmentData | null => {
	return useHealthStore((s) => s.environmentData);
};

// =============================================================================
// Score Chart Data Selector for Today Screen
// =============================================================================

/**
 * Extract last 7 days of score values from HealthMetricHistory
 * Returns array of 7 numbers for chart display
 */
const extractLast7DaysScores = (
	history: HealthMetricHistory | null,
): number[] => {
	if (!history?.samples?.length) {
		return [0, 0, 0, 0, 0, 0, 0];
	}
	const samples = [...history.samples];
	const last7 = samples.slice(-7);
	// Pad with first value if less than 7 samples
	while (last7.length < 7) {
		last7.unshift(last7[0] ?? { value: 0, date: new Date() });
	}
	return last7.map((s) => Math.round(s.value));
};

/**
 * Hook to get score chart data for Today screen 4 metric cards
 */
export const useScoreChartDataForToday = (): {
	recovery: number[];
	sleep: number[];
	rhythm: number[];
	energy: number[];
} => {
	const recoveryHistory = useHealthStore((s) => s.scoreHistories.recovery);
	const sleepHistory = useHealthStore((s) => s.scoreHistories.sleep);
	const rhythmHistory = useHealthStore((s) => s.scoreHistories.rhythm);
	const energyHistory = useHealthStore((s) => s.scoreHistories.energy);

	return useMemo(
		() => ({
			recovery: extractLast7DaysScores(recoveryHistory),
			sleep: extractLast7DaysScores(sleepHistory),
			rhythm: extractLast7DaysScores(rhythmHistory),
			energy: extractLast7DaysScores(energyHistory),
		}),
		[recoveryHistory, sleepHistory, rhythmHistory, energyHistory],
	);
};

// =============================================================================
// Upcoming Windows Selector
// =============================================================================

/**
 * Format Date to HH:MM string
 */
const formatTimeToHHMM = (date: Date): string => {
	const hours = date.getHours().toString().padStart(2, "0");
	const minutes = date.getMinutes().toString().padStart(2, "0");
	return `${hours}:${minutes}`;
};

/**
 * Upcoming window data structure
 */
export interface UpcomingWindow {
	name: string;
	timeRange: string;
	isCurrent: boolean;
}

/**
 * Hook to get Upcoming Windows (Peak Focus & Melatonin Window) with formatted times
 */
export const useUpcomingWindows = (): {
	peakFocus: UpcomingWindow | null;
	melatoninWindow: UpcomingWindow | null;
} => {
	const phases = useHealthStore((s) => s.circadianRhythm?.phases);

	return useMemo(() => {
		if (!phases || phases.length === 0) {
			return { peakFocus: null, melatoninWindow: null };
		}

		const peakPhase = phases.find((p) => p.name === "Peak Focus");
		const melatoninPhase = phases.find((p) => p.name === "Melatonin Window");

		const now = new Date();
		const currentHour = now.getHours();

		// Check if "now" is within peak focus time
		const isPeakCurrent = peakPhase
			? currentHour >= peakPhase.start.getHours() &&
				currentHour < peakPhase.end.getHours()
			: false;

		const peakFocus = peakPhase
			? {
					name: peakPhase.name,
					timeRange: isPeakCurrent
						? `Now — ${formatTimeToHHMM(peakPhase.end)}`
						: `${formatTimeToHHMM(peakPhase.start)} — ${formatTimeToHHMM(peakPhase.end)}`,
					isCurrent: isPeakCurrent,
				}
			: null;

		const melatoninWindow = melatoninPhase
			? {
					name: melatoninPhase.name,
					timeRange: `${formatTimeToHHMM(melatoninPhase.start)} — ${formatTimeToHHMM(melatoninPhase.end)}`,
					isCurrent: melatoninPhase.isCurrent,
				}
			: null;

		return { peakFocus, melatoninWindow };
	}, [phases]);
};
