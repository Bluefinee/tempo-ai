/**
 * Detail Screen Calculator
 *
 * Calculates data for detail screens (Recovery, Sleep, Rhythm, Energy)
 * from raw health metrics and historical data.
 */

import {
	ACTIVITY_GOALS,
	getConsistencyScore,
	SCORE_STATUS_THRESHOLDS,
	SLEEP_STAGE_THRESHOLDS,
} from "../../constants/scoreConstants";
import type {
	ActivityMetrics,
	ConsistencyInfo,
	DailyHealthSample,
	DurationInfo,
	EnergyDetailData,
	FactorInfo,
	HealthMetricHistory,
	HRVMetrics,
	MetricWithTrend,
	QualityInfo,
	RecoveryDetailData,
	RHRMetrics,
	RhythmDetailData,
	SimpleWeatherData,
	SleepDetailData,
	SleepMetrics,
	SleepStageInfo,
	SleepTimingHistory,
	TimeRange,
	TimingInfo,
	TrendDirection,
} from "../models";
import { getHRVStatus, getRHRStatus, getSleepDerivedMetrics } from "../models";

// =============================================================================
// Helper Functions
// =============================================================================

/**
 * Calculate trend from historical samples
 * Compares last 7 days average vs 7-14 days ago average
 */
export const calculateTrendFromHistory = (
	samples: DailyHealthSample[],
): { percent: number; direction: TrendDirection } => {
	if (samples.length < 7) {
		return { percent: 0, direction: "stable" };
	}

	const recent = samples.slice(-7);
	const previous = samples.slice(-14, -7);

	if (previous.length === 0) {
		return { percent: 0, direction: "stable" };
	}

	const recentAvg = recent.reduce((a, b) => a + b.value, 0) / recent.length;
	const previousAvg =
		previous.reduce((a, b) => a + b.value, 0) / previous.length;

	if (previousAvg === 0) {
		return { percent: 0, direction: "stable" };
	}

	const percent = ((recentAvg - previousAvg) / previousAvg) * 100;

	let direction: TrendDirection = "stable";
	if (percent > 5) direction = "improving";
	else if (percent < -5) direction = "declining";

	return { percent: Math.round(percent * 10) / 10, direction };
};

/**
 * Calculate standard deviation of time values (in minutes from midnight)
 */
const calculateTimeStdDev = (times: Date[]): number => {
	if (times.length < 2) return 0;

	const minutesFromMidnight = times.map((t) => {
		const h = t.getHours();
		const m = t.getMinutes();
		// Handle overnight times (e.g., 23:00 = -60, 01:00 = 60 from midnight)
		if (h >= 20) return (h - 24) * 60 + m;
		return h * 60 + m;
	});

	const mean =
		minutesFromMidnight.reduce((a, b) => a + b, 0) / minutesFromMidnight.length;
	const squaredDiffs = minutesFromMidnight.map((x) => (x - mean) ** 2);
	const variance =
		squaredDiffs.reduce((a, b) => a + b, 0) / minutesFromMidnight.length;

	return Math.round(Math.sqrt(variance));
};

/**
 * Format time as HH:MM string
 */
const formatTime = (date: Date): string => {
	const hours = date.getHours().toString().padStart(2, "0");
	const minutes = date.getMinutes().toString().padStart(2, "0");
	return `${hours}:${minutes}`;
};

/**
 * Get status label based on score
 * Note: Returns i18n keys for internationalization
 */
const getScoreStatus = (score: number): string => {
	if (score >= SCORE_STATUS_THRESHOLDS.EXCELLENT) return "excellent";
	if (score >= SCORE_STATUS_THRESHOLDS.GOOD) return "good";
	if (score >= SCORE_STATUS_THRESHOLDS.FAIR) return "fair";
	return "low";
};

/**
 * Format deviation text
 */
const formatDeviationText = (minutes: number): string => {
	return `±${minutes} min`;
};

/**
 * Calculate difference text for timing
 */
const formatTimeDiffText = (diffMinutes: number): string => {
	const absDiff = Math.abs(diffMinutes);
	if (absDiff <= 5) return "on time";
	if (diffMinutes > 0) return `${absDiff} min late`;
	return `${absDiff} min early`;
};

/**
 * Format trend text
 */
const formatTrendText = (percent: number): string => {
	if (Math.abs(percent) < 1) return "Stable";
	return `${percent > 0 ? "+" : ""}${Math.round(percent)}%`;
};

// =============================================================================
// Recovery Detail Calculator
// =============================================================================

export interface RecoveryCalculatorInput {
	hrvMetrics: HRVMetrics;
	rhrMetrics: RHRMetrics;
	sleepScore: number;
	hrvHistory: HealthMetricHistory;
	rhrHistory: HealthMetricHistory;
	recoveryScoreHistory: HealthMetricHistory;
}

export const calculateRecoveryDetail = (
	input: RecoveryCalculatorInput,
): RecoveryDetailData => {
	const {
		hrvMetrics,
		rhrMetrics,
		sleepScore,
		hrvHistory,
		rhrHistory,
		recoveryScoreHistory,
	} = input;

	// Calculate HRV trend
	const hrvTrend = calculateTrendFromHistory(hrvHistory.samples);

	// Calculate RHR trend (inverted - lower is better)
	const rhrTrendRaw = calculateTrendFromHistory(rhrHistory.samples);
	// For RHR, declining is improving (lower heart rate is better)
	const rhrTrend: { percent: number; direction: TrendDirection } = {
		percent: rhrTrendRaw.percent,
		direction:
			rhrTrendRaw.direction === "improving"
				? "declining"
				: rhrTrendRaw.direction === "declining"
					? "improving"
					: "stable",
	};

	// Calculate recovery score from components
	// HRV (60%) + RHR (20%) + Sleep (20%)
	const hrvRatio =
		hrvMetrics.baseline30d > 0 ? hrvMetrics.value / hrvMetrics.baseline30d : 1;
	const hrvScore = Math.min(100, Math.max(0, ((hrvRatio - 0.7) / 0.6) * 100));

	const rhrRatio =
		rhrMetrics.value > 0 ? rhrMetrics.baseline30d / rhrMetrics.value : 1;
	const rhrScore = Math.min(100, Math.max(0, ((rhrRatio - 0.85) / 0.3) * 100));

	const score = Math.round(hrvScore * 0.6 + rhrScore * 0.2 + sleepScore * 0.2);

	// Calculate weekly average from recovery score history
	const recentScores = recoveryScoreHistory.samples.slice(-7);
	const weeklyAverage =
		recentScores.length > 0
			? Math.round(
					recentScores.reduce((a, b) => a + b.value, 0) / recentScores.length,
				)
			: score;

	// Build HRV metric with trend
	const hrvWithTrend: MetricWithTrend = {
		value: hrvMetrics.value,
		unit: "ms",
		baseline: hrvMetrics.baseline30d,
		changePercent: hrvTrend.percent,
		trend: hrvTrend.direction,
	};

	// Build RHR metric with trend
	const rhrWithTrend: MetricWithTrend = {
		value: rhrMetrics.value,
		unit: "bpm",
		baseline: rhrMetrics.baseline30d,
		changePercent: rhrTrend.percent,
		trend: rhrTrend.direction,
	};

	return {
		score,
		status: getScoreStatus(score),
		hrv: hrvWithTrend,
		rhr: rhrWithTrend,
		analysis: "", // Will be filled by analysisTemplates
		calculatedAt: new Date().toISOString(),
		weeklyAverage,
	};
};

// =============================================================================
// Sleep Detail Calculator
// =============================================================================

export interface SleepCalculatorInput {
	sleepMetrics: SleepMetrics;
	targetBedtime: string; // "HH:MM"
	targetWakeTime: string; // "HH:MM"
	targetDurationMinutes: number;
	sleepScoreHistory: HealthMetricHistory;
}

export const calculateSleepDetail = (
	input: SleepCalculatorInput,
): SleepDetailData => {
	const {
		sleepMetrics,
		targetBedtime,
		targetWakeTime,
		targetDurationMinutes,
		sleepScoreHistory,
	} = input;

	// Get derived metrics
	const derived = getSleepDerivedMetrics(sleepMetrics);

	// Calculate score from components
	// Duration (40%) + Quality (40%) + Timing (20%)
	const durationRatio = sleepMetrics.durationMinutes / targetDurationMinutes;
	const durationScore = Math.min(100, Math.max(0, durationRatio * 100));

	const { deep: deepThresholds, rem: remThresholds } = SLEEP_STAGE_THRESHOLDS;

	const deepScore =
		derived.deepSleepRatio >= deepThresholds.min &&
		derived.deepSleepRatio <= deepThresholds.max
			? 100
			: derived.deepSleepRatio < deepThresholds.min
				? (derived.deepSleepRatio / deepThresholds.min) * 100
				: Math.max(
						0,
						100 - (derived.deepSleepRatio - deepThresholds.max) * 200,
					);

	const remScore =
		derived.remSleepRatio >= remThresholds.min &&
		derived.remSleepRatio <= remThresholds.max
			? 100
			: derived.remSleepRatio < remThresholds.min
				? (derived.remSleepRatio / remThresholds.min) * 100
				: Math.max(0, 100 - (derived.remSleepRatio - remThresholds.max) * 200);

	const qualityScore = deepScore * 0.5 + remScore * 0.5;

	// Calculate timing score
	const parseTime = (timeStr: string): { hours: number; minutes: number } => {
		const [h, m] = timeStr.split(":").map(Number);
		return { hours: h, minutes: m };
	};

	const targetBed = parseTime(targetBedtime);
	const targetWake = parseTime(targetWakeTime);

	const actualBedMinutes =
		sleepMetrics.bedtime.getHours() * 60 + sleepMetrics.bedtime.getMinutes();
	const targetBedMinutes = targetBed.hours * 60 + targetBed.minutes;

	const actualWakeMinutes =
		sleepMetrics.wakeTime.getHours() * 60 + sleepMetrics.wakeTime.getMinutes();
	const targetWakeMinutes = targetWake.hours * 60 + targetWake.minutes;

	// Handle overnight bedtimes
	let bedtimeDiff = actualBedMinutes - targetBedMinutes;
	if (bedtimeDiff > 720) bedtimeDiff -= 1440; // wrap around midnight
	if (bedtimeDiff < -720) bedtimeDiff += 1440;

	const wakeDiff = actualWakeMinutes - targetWakeMinutes;

	const timingScore = Math.min(
		100,
		Math.max(0, 100 - (Math.abs(bedtimeDiff) + Math.abs(wakeDiff)) / 4),
	);

	const score = Math.round(
		durationScore * 0.4 + qualityScore * 0.4 + timingScore * 0.2,
	);

	// Build duration info
	const duration: DurationInfo = {
		hours: Math.floor(sleepMetrics.durationMinutes / 60),
		minutes: sleepMetrics.durationMinutes % 60,
		totalMinutes: sleepMetrics.durationMinutes,
		percentage: Math.round(
			(sleepMetrics.durationMinutes / targetDurationMinutes) * 100,
		),
		target: {
			hours: Math.floor(targetDurationMinutes / 60),
			minutes: targetDurationMinutes % 60,
		},
	};

	// Build quality info
	const quality: QualityInfo = {
		percentage: Math.round(qualityScore),
		deepRatio: Math.round(derived.deepSleepRatio * 100),
		remRatio: Math.round(derived.remSleepRatio * 100),
	};

	// Build stages info
	const stages: SleepStageInfo[] = [
		{
			stage: "deep",
			minutes: sleepMetrics.deepSleepMinutes,
			percentage: Math.round(derived.deepSleepRatio * 100),
		},
		{
			stage: "rem",
			minutes: sleepMetrics.remSleepMinutes,
			percentage: Math.round(derived.remSleepRatio * 100),
		},
		{
			stage: "light",
			minutes: derived.lightSleepMinutes,
			percentage: Math.round(
				(1 - derived.deepSleepRatio - derived.remSleepRatio) * 100,
			),
		},
	];

	// Build timing info
	const timing: TimingInfo = {
		bedtime: {
			actual: formatTime(sleepMetrics.bedtime),
			target: targetBedtime,
			diffMinutes: bedtimeDiff,
			diffText: formatTimeDiffText(bedtimeDiff),
		},
		wakeTime: {
			actual: formatTime(sleepMetrics.wakeTime),
			target: targetWakeTime,
			diffMinutes: wakeDiff,
			diffText: formatTimeDiffText(wakeDiff),
		},
	};

	return {
		score,
		status: getScoreStatus(score),
		duration,
		quality,
		stages,
		timing,
		analysis: "", // Will be filled by analysisTemplates
	};
};

// =============================================================================
// Rhythm Detail Calculator
// =============================================================================

export interface RhythmCalculatorInput {
	sleepTimingHistory: SleepTimingHistory;
	targetBedtime: string; // "HH:MM"
	targetWakeTime: string; // "HH:MM"
	rhythmScoreHistory: HealthMetricHistory;
}

export const calculateRhythmDetail = (
	input: RhythmCalculatorInput,
): RhythmDetailData => {
	const {
		sleepTimingHistory,
		targetBedtime,
		targetWakeTime,
		rhythmScoreHistory,
	} = input;

	// Calculate consistency (standard deviation) for bedtime and wake time
	const bedtimes = sleepTimingHistory.samples.map((s) => s.bedtime);
	const wakeTimes = sleepTimingHistory.samples.map((s) => s.wakeTime);

	const bedtimeStdDev = calculateTimeStdDev(bedtimes);
	const wakeTimeStdDev = calculateTimeStdDev(wakeTimes);

	// Calculate score using the same logic as scoreCalculator
	const bedtimeScore = getConsistencyScore(bedtimeStdDev);
	const wakeScore = getConsistencyScore(wakeTimeStdDev);
	const score = Math.round((bedtimeScore + wakeScore) / 2);

	// Build consistency info
	const bedtimeConsistency: ConsistencyInfo = {
		target: targetBedtime,
		deviationMinutes: bedtimeStdDev,
		deviationText: formatDeviationText(bedtimeStdDev),
	};

	const wakeTimeConsistency: ConsistencyInfo = {
		target: targetWakeTime,
		deviationMinutes: wakeTimeStdDev,
		deviationText: formatDeviationText(wakeTimeStdDev),
	};

	return {
		score,
		status: getScoreStatus(score),
		consistency: {
			bedtime: bedtimeConsistency,
			wakeTime: wakeTimeConsistency,
		},
		analysis: "", // Will be filled by analysisTemplates
	};
};

// =============================================================================
// Energy Detail Calculator
// =============================================================================

export interface EnergyCalculatorInput {
	recoveryScore: number;
	sleepScore: number;
	activityMetrics: ActivityMetrics;
	weather: SimpleWeatherData;
	targetWakeTime: string; // "HH:MM"
	energyScoreHistory: HealthMetricHistory;
	recoveryScoreHistory: HealthMetricHistory;
	sleepScoreHistory: HealthMetricHistory;
}

export const calculateEnergyDetail = (
	input: EnergyCalculatorInput,
): EnergyDetailData => {
	const {
		recoveryScore,
		sleepScore,
		activityMetrics,
		weather,
		targetWakeTime,
		energyScoreHistory,
		recoveryScoreHistory,
		sleepScoreHistory,
	} = input;

	// Calculate weather score
	let weatherFactor = 100;
	if (weather.pressureTrend === "falling" && weather.pressure < 1010) {
		weatherFactor -= 20;
	} else if (weather.pressureTrend === "rising") {
		weatherFactor += 5;
	}
	const weatherScore = Math.min(100, Math.max(0, weatherFactor));

	// Calculate energy score
	// Recovery (50%) + Sleep (40%) + Weather (10%)
	const score = Math.round(
		recoveryScore * 0.5 + sleepScore * 0.4 + weatherScore * 0.1,
	);

	// Calculate activity score (steps towards goal)
	const activityScore = Math.min(
		100,
		Math.round(
			(activityMetrics.stepsYesterday / ACTIVITY_GOALS.DAILY_STEPS) * 100,
		),
	);

	// Calculate trends for factors
	const recoveryTrend = calculateTrendFromHistory(recoveryScoreHistory.samples);
	const sleepTrend = calculateTrendFromHistory(sleepScoreHistory.samples);

	// Build factor info for Recovery
	const recoveryFactor: FactorInfo = {
		value: recoveryScore,
		label: "Recovery",
		trend: recoveryTrend.direction,
		trendText: formatTrendText(recoveryTrend.percent),
		detail: `${recoveryScore}% of optimal`,
	};

	// Build factor info for Sleep
	const sleepFactor: FactorInfo = {
		value: sleepScore,
		label: "Sleep",
		trend: sleepTrend.direction,
		trendText: formatTrendText(sleepTrend.percent),
		detail: `${sleepScore}% quality`,
	};

	// Build factor info for Activity
	const activityFactor: FactorInfo = {
		value: activityScore,
		label: "Activity",
		trend: "stable", // Activity doesn't have historical trend in current impl
		trendText: "Stable",
		detail: `${activityMetrics.stepsYesterday.toLocaleString()} steps`,
	};

	// Build factor info for Weather
	const weatherTrendDir: TrendDirection =
		weather.pressureTrend === "rising"
			? "improving"
			: weather.pressureTrend === "falling"
				? "declining"
				: "stable";

	const weatherForecast: FactorInfo = {
		value: weatherScore,
		label: "Weather",
		trend: weatherTrendDir,
		trendText:
			weather.pressureTrend === "stable"
				? "Stable"
				: weather.pressureTrend === "rising"
					? "Rising"
					: "Falling",
		detail: `${weather.pressure} hPa`,
	};

	// Calculate peak focus and afternoon dip times based on wake time
	const parseWakeTime = (timeStr: string): Date => {
		const [h, m] = timeStr.split(":").map(Number);
		const today = new Date();
		today.setHours(h, m, 0, 0);
		return today;
	};

	const wakeTime = parseWakeTime(targetWakeTime);

	// Peak Focus: 2-5 hours after waking
	const peakStart = new Date(wakeTime);
	peakStart.setHours(peakStart.getHours() + 2);
	const peakEnd = new Date(wakeTime);
	peakEnd.setHours(peakEnd.getHours() + 5);

	const peakFocus: TimeRange = {
		start: formatTime(peakStart),
		end: formatTime(peakEnd),
	};

	// Afternoon Dip: 7-9 hours after waking
	const dipStart = new Date(wakeTime);
	dipStart.setHours(dipStart.getHours() + 7);
	const dipEnd = new Date(wakeTime);
	dipEnd.setHours(dipEnd.getHours() + 9);

	const afternoonDip: TimeRange = {
		start: formatTime(dipStart),
		end: formatTime(dipEnd),
	};

	return {
		score,
		status: getScoreStatus(score),
		contributingFactors: {
			recovery: recoveryFactor,
			sleep: sleepFactor,
			activity: activityFactor,
			weather: weatherForecast,
		},
		peakFocus,
		afternoonDip,
		analysis: "", // Will be filled by analysisTemplates
	};
};
