/**
 * Detail Screen Data Types
 * Types for dynamically calculated detail screen data
 */

import type { TrendDirection } from "./healthHistory";

// =============================================================================
// Common Types
// =============================================================================

/**
 * Metric with trend information
 */
export interface MetricWithTrend {
	value: number;
	unit: string;
	baseline: number;
	changePercent: number;
	trend: TrendDirection;
}

/**
 * Contributing factor information for Energy detail
 */
export interface FactorInfo {
	value: number;
	label: string;
	trend: TrendDirection;
	trendText: string; // "+5%", "Stable", "-3%"
	detail: string;
}

/**
 * Consistency information for Rhythm detail
 */
export interface ConsistencyInfo {
	target: string;
	deviationMinutes: number;
	deviationText: string; // "±12 min"
}

/**
 * Time range for energy curve
 */
export interface TimeRange {
	start: string;
	end: string;
}

/**
 * Sleep stage information
 */
export interface SleepStageInfo {
	stage: "deep" | "rem" | "light" | "awake";
	minutes: number;
	percentage: number;
}

/**
 * Duration information for Sleep detail
 */
export interface DurationInfo {
	hours: number;
	minutes: number;
	totalMinutes: number;
	percentage: number; // vs target
	target: {
		hours: number;
		minutes: number;
	};
}

/**
 * Quality information for Sleep detail
 */
export interface QualityInfo {
	percentage: number;
	deepRatio: number;
	remRatio: number;
}

/**
 * Timing information for Sleep detail
 */
export interface TimingInfo {
	bedtime: {
		actual: string;
		target: string;
		diffMinutes: number;
		diffText: string; // "15 min late", "on time"
	};
	wakeTime: {
		actual: string;
		target: string;
		diffMinutes: number;
		diffText: string;
	};
}

// =============================================================================
// Detail Data Types
// =============================================================================

/**
 * Recovery Detail Data
 * Used by recovery-detail.tsx
 */
export interface RecoveryDetailData {
	score: number;
	status: string;
	hrv: MetricWithTrend;
	rhr: MetricWithTrend;
	analysis: string;
	calculatedAt: string;
	weeklyAverage: number;
}

/**
 * Sleep Detail Data
 * Used by sleep-detail.tsx
 */
export interface SleepDetailData {
	score: number;
	status: string;
	duration: DurationInfo;
	quality: QualityInfo;
	stages: SleepStageInfo[];
	timing: TimingInfo;
	analysis: string;
}

/**
 * Rhythm Detail Data (SIMPLIFIED)
 * Used by rhythm-detail.tsx
 * Note: Simplified from original design - removed Contributing Factors grid and Weekly Pattern
 */
export interface RhythmDetailData {
	score: number;
	status: string;
	consistency: {
		bedtime: ConsistencyInfo;
		wakeTime: ConsistencyInfo;
	};
	analysis: string;
}

/**
 * Energy Detail Data
 * Used by energy-detail.tsx
 */
export interface EnergyDetailData {
	score: number;
	status: string;
	contributingFactors: {
		recovery: FactorInfo;
		sleep: FactorInfo;
		activity: FactorInfo;
		weather: FactorInfo;
	};
	peakFocus: TimeRange;
	afternoonDip: TimeRange;
	analysis: string;
}

// =============================================================================
// Combined Detail Data
// =============================================================================

/**
 * All detail data combined
 * Stored in HealthStore
 */
export interface AllDetailData {
	recovery: RecoveryDetailData | null;
	sleep: SleepDetailData | null;
	rhythm: RhythmDetailData | null;
	energy: EnergyDetailData | null;
}

// =============================================================================
// Chart Data Types
// =============================================================================

/**
 * Chart data point for HealthAreaChart
 */
export interface ChartDataPoint {
	day: string;
	value: number;
}

/**
 * Chart data grouped by timeframe
 */
export interface TimeframeChartData {
	"7D": ChartDataPoint[];
	"30D": ChartDataPoint[];
	"60D": ChartDataPoint[];
}

/**
 * Detail data with chart data for UI
 */
export interface RecoveryDetailWithChart extends RecoveryDetailData {
	chartData: TimeframeChartData;
}

export interface SleepDetailWithChart extends SleepDetailData {
	chartData: TimeframeChartData;
}

export interface RhythmDetailWithChart extends RhythmDetailData {
	chartData: TimeframeChartData;
}

export interface EnergyDetailWithChart extends EnergyDetailData {
	chartData: TimeframeChartData;
}

// =============================================================================
// Sleep Timing History (for Rhythm calculations)
// =============================================================================

/**
 * Single sleep timing sample
 */
export interface SleepTimingSample {
	date: Date;
	bedtime: Date;
	wakeTime: Date;
	durationMinutes: number;
}

/**
 * Sleep timing history for consistency calculations
 */
export interface SleepTimingHistory {
	samples: SleepTimingSample[];
}
