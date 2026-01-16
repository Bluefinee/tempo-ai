/**
 * Detail Calculator
 * Calculates detailed data for detail screens based on raw metrics
 */

import type {
	ChartDataPoint,
	EnergyDetailData,
	RecoveryDetailData,
	RhythmDetailData,
	SleepDetailData,
	SleepTimingHistory,
	TimeframeChartData,
} from "../models/detailData";
import type { HealthMetricHistory, TrendDirection } from "../models/healthHistory";
import type {
	ActivityMetrics,
	HRVMetrics,
	RHRMetrics,
	SimpleWeatherData,
	SleepMetrics,
} from "../models";

// =============================================================================
// Helper Functions
// =============================================================================

const getTrendDirection = (changePercent: number): TrendDirection => {
	if (changePercent > 5) return "improving";
	if (changePercent < -5) return "declining";
	return "stable";
};

const formatChangePercent = (change: number): string => {
	if (Math.abs(change) < 1) return "Stable";
	const sign = change > 0 ? "+" : "";
	return `${sign}${Math.round(change)}%`;
};

const getScoreStatus = (
	score: number,
	_type: "recovery" | "sleep" | "rhythm" | "energy",
): string => {
	if (score >= 85) return "excellent";
	if (score >= 70) return "good";
	if (score >= 50) return "fair";
	return "poor";
};

const generateChartData = (
	history: HealthMetricHistory | null,
): TimeframeChartData => {
	const defaultData: ChartDataPoint[] = [
		{ day: "Mon", value: 70 },
		{ day: "Tue", value: 72 },
		{ day: "Wed", value: 68 },
		{ day: "Thu", value: 75 },
		{ day: "Fri", value: 73 },
		{ day: "Sat", value: 78 },
		{ day: "Sun", value: 76 },
	];

	if (!history || history.samples.length === 0) {
		return {
			"7D": defaultData,
			"30D": defaultData,
			"60D": defaultData,
		};
	}

	const samples = history.samples.slice().reverse();
	const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

	const mapToChartData = (
		slice: typeof samples,
	): ChartDataPoint[] =>
		slice.map((sample) => ({
			day: dayNames[new Date(sample.date).getDay()],
			value: sample.value,
		}));

	return {
		"7D": mapToChartData(samples.slice(0, 7)),
		"30D": mapToChartData(samples.slice(0, 30)),
		"60D": mapToChartData(samples.slice(0, 60)),
	};
};

// =============================================================================
// Recovery Detail Calculator
// =============================================================================

interface RecoveryDetailInput {
	hrvMetrics: HRVMetrics | null;
	rhrMetrics: RHRMetrics | null;
	sleepScore: number;
	hrvHistory: HealthMetricHistory | null;
	rhrHistory: HealthMetricHistory | null;
	recoveryScoreHistory: HealthMetricHistory | null;
}

export const calculateRecoveryDetail = (
	input: RecoveryDetailInput,
): RecoveryDetailData & { chartData: TimeframeChartData } => {
	const {
		hrvMetrics,
		rhrMetrics,
		sleepScore,
		// hrvHistory and rhrHistory reserved for future trend analysis
		recoveryScoreHistory,
	} = input;

	// Calculate HRV metrics
	const hrvValue = hrvMetrics?.value ?? 55;
	const hrvBaseline = hrvMetrics?.baseline30d ?? 50;
	const hrvChange =
		hrvBaseline > 0 ? ((hrvValue - hrvBaseline) / hrvBaseline) * 100 : 0;

	// Calculate RHR metrics
	const rhrValue = rhrMetrics?.value ?? 62;
	const rhrBaseline = rhrMetrics?.baseline30d ?? 65;
	const rhrChange =
		rhrBaseline > 0 ? ((rhrValue - rhrBaseline) / rhrBaseline) * 100 : 0;

	// Calculate score based on HRV, RHR, and sleep
	const hrvScore = Math.min(100, (hrvValue / hrvBaseline) * 70);
	const rhrScore = Math.min(100, (rhrBaseline / rhrValue) * 70);
	const score = Math.round(hrvScore * 0.5 + rhrScore * 0.3 + sleepScore * 0.2);

	// Calculate weekly average
	const weeklyAvg =
		recoveryScoreHistory?.samples.slice(0, 7).reduce((sum, s) => sum + s.value, 0) ??
		score * 7;
	const weeklyAverage = Math.round(weeklyAvg / 7);

	return {
		score,
		status: getScoreStatus(score, "recovery"),
		hrv: {
			value: hrvValue,
			unit: "ms",
			baseline: hrvBaseline,
			changePercent: hrvChange,
			trend: getTrendDirection(hrvChange),
		},
		rhr: {
			value: rhrValue,
			unit: "bpm",
			baseline: rhrBaseline,
			changePercent: rhrChange,
			trend: getTrendDirection(-rhrChange), // Lower RHR is better
		},
		analysis: "",
		calculatedAt: new Date().toLocaleTimeString("en-US", {
			hour: "numeric",
			minute: "2-digit",
		}),
		weeklyAverage,
		chartData: generateChartData(recoveryScoreHistory),
	};
};

// =============================================================================
// Sleep Detail Calculator
// =============================================================================

interface SleepDetailInput {
	sleepMetrics: SleepMetrics | null;
	targetBedtime: string;
	targetWakeTime: string;
	targetDurationMinutes: number;
	sleepScoreHistory: HealthMetricHistory | null;
}

export const calculateSleepDetail = (
	input: SleepDetailInput,
): SleepDetailData & { chartData: TimeframeChartData } => {
	const {
		sleepMetrics,
		targetBedtime,
		targetWakeTime,
		targetDurationMinutes,
		sleepScoreHistory,
	} = input;

	const duration = sleepMetrics?.durationMinutes ?? 420;
	const deepSleep = sleepMetrics?.deepSleepMinutes ?? 90;
	const remSleep = sleepMetrics?.remSleepMinutes ?? 90;
	// Light sleep and awake are calculated from remaining time
	const lightSleep = Math.max(0, duration - deepSleep - remSleep - 30);
	const awake = 30; // Default awake time

	// Handle bedtime/wakeTime which might be Date or string
	const getBedtimeStr = (): string => {
		const bt = sleepMetrics?.bedtime;
		if (!bt) return "23:00";
		if (typeof bt === "string") return bt;
		return `${bt.getHours().toString().padStart(2, "0")}:${bt.getMinutes().toString().padStart(2, "0")}`;
	};
	const getWakeTimeStr = (): string => {
		const wt = sleepMetrics?.wakeTime;
		if (!wt) return "07:00";
		if (typeof wt === "string") return wt;
		return `${wt.getHours().toString().padStart(2, "0")}:${wt.getMinutes().toString().padStart(2, "0")}`;
	};

	const bedtime = getBedtimeStr();
	const wakeTime = getWakeTimeStr();

	// Calculate score
	const durationRatio = duration / targetDurationMinutes;
	const durationScore = Math.min(100, durationRatio * 100);
	const deepRatio = deepSleep / duration;
	const remRatio = remSleep / duration;
	const qualityScore = (deepRatio * 0.5 + remRatio * 0.5) * 400; // Scale to ~80-100
	const score = Math.round(durationScore * 0.5 + qualityScore * 0.5);

	// Calculate timing differences
	const parseTime = (t: string): number => {
		const [h, m] = t.split(":").map(Number);
		return h * 60 + m;
	};
	const bedtimeDiff = parseTime(bedtime) - parseTime(targetBedtime);
	const wakeDiff = parseTime(wakeTime) - parseTime(targetWakeTime);

	const formatDiff = (diff: number): string => {
		if (Math.abs(diff) < 5) return "on time";
		const absMin = Math.abs(diff);
		return diff > 0 ? `${absMin} min late` : `${absMin} min early`;
	};

	return {
		score,
		status: getScoreStatus(score, "sleep"),
		duration: {
			hours: Math.floor(duration / 60),
			minutes: duration % 60,
			totalMinutes: duration,
			percentage: Math.round((duration / targetDurationMinutes) * 100),
			target: {
				hours: Math.floor(targetDurationMinutes / 60),
				minutes: targetDurationMinutes % 60,
			},
		},
		quality: {
			percentage: Math.round(((deepSleep + remSleep) / duration) * 100),
			deepRatio: Math.round(deepRatio * 100),
			remRatio: Math.round(remRatio * 100),
		},
		stages: [
			{
				stage: "deep",
				minutes: deepSleep,
				percentage: Math.round((deepSleep / duration) * 100),
			},
			{
				stage: "rem",
				minutes: remSleep,
				percentage: Math.round((remSleep / duration) * 100),
			},
			{
				stage: "light",
				minutes: lightSleep,
				percentage: Math.round((lightSleep / duration) * 100),
			},
			{
				stage: "awake",
				minutes: awake,
				percentage: Math.round((awake / duration) * 100),
			},
		],
		timing: {
			bedtime: {
				actual: bedtime,
				target: targetBedtime,
				diffMinutes: bedtimeDiff,
				diffText: formatDiff(bedtimeDiff),
			},
			wakeTime: {
				actual: wakeTime,
				target: targetWakeTime,
				diffMinutes: wakeDiff,
				diffText: formatDiff(wakeDiff),
			},
		},
		analysis: "",
		chartData: generateChartData(sleepScoreHistory),
	};
};

// =============================================================================
// Rhythm Detail Calculator
// =============================================================================

interface RhythmDetailInput {
	sleepTimingHistory: SleepTimingHistory | null;
	targetBedtime: string;
	targetWakeTime: string;
	rhythmScoreHistory: HealthMetricHistory | null;
}

export const calculateRhythmDetail = (
	input: RhythmDetailInput,
): RhythmDetailData & { chartData: TimeframeChartData } => {
	const { sleepTimingHistory, targetBedtime, targetWakeTime, rhythmScoreHistory } =
		input;

	// Calculate standard deviation for consistency
	const samples = sleepTimingHistory?.samples ?? [];
	let bedtimeStdDev = 30;
	let wakeStdDev = 25;

	if (samples.length > 1) {
		const bedtimes = samples.map(
			(s) => s.bedtime.getHours() * 60 + s.bedtime.getMinutes(),
		);
		const wakes = samples.map(
			(s) => s.wakeTime.getHours() * 60 + s.wakeTime.getMinutes(),
		);

		const mean = (arr: number[]) => arr.reduce((a, b) => a + b, 0) / arr.length;
		const stdDev = (arr: number[]) => {
			const m = mean(arr);
			return Math.sqrt(arr.reduce((sum, x) => sum + (x - m) ** 2, 0) / arr.length);
		};

		bedtimeStdDev = Math.round(stdDev(bedtimes));
		wakeStdDev = Math.round(stdDev(wakes));
	}

	// Score based on consistency (lower stddev = higher score)
	const bedtimeScore = Math.max(0, 100 - bedtimeStdDev * 2);
	const wakeScore = Math.max(0, 100 - wakeStdDev * 2);
	const score = Math.round((bedtimeScore + wakeScore) / 2);

	return {
		score,
		status: getScoreStatus(score, "rhythm"),
		consistency: {
			bedtime: {
				target: targetBedtime,
				deviationMinutes: bedtimeStdDev,
				deviationText: `±${bedtimeStdDev} min`,
			},
			wakeTime: {
				target: targetWakeTime,
				deviationMinutes: wakeStdDev,
				deviationText: `±${wakeStdDev} min`,
			},
		},
		analysis: "",
		chartData: generateChartData(rhythmScoreHistory),
	};
};

// =============================================================================
// Energy Detail Calculator
// =============================================================================

interface EnergyDetailInput {
	recoveryScore: number;
	sleepScore: number;
	activityMetrics: ActivityMetrics | null;
	weather: SimpleWeatherData;
	/** Target wake up time (e.g., "07:00") - used as wakeUpTime for calculations */
	targetWakeTime: string;
	energyScoreHistory: HealthMetricHistory | null;
	/** Recovery score history - reserved for future trend analysis */
	recoveryScoreHistory?: HealthMetricHistory | null;
	/** Sleep score history - reserved for future trend analysis */
	sleepScoreHistory?: HealthMetricHistory | null;
}

export const calculateEnergyDetail = (
	input: EnergyDetailInput,
): EnergyDetailData & { chartData: TimeframeChartData } => {
	const {
		recoveryScore,
		sleepScore,
		activityMetrics,
		weather,
		targetWakeTime,
		// recoveryScoreHistory and sleepScoreHistory reserved for future trend analysis
		energyScoreHistory,
	} = input;

	// Use targetWakeTime as the wake up time for calculations
	const wakeUpTime = targetWakeTime;

	// Calculate activity score - use activeMinutesYesterday
	const activityValue = activityMetrics?.activeMinutesYesterday ?? 30;
	const targetActivity = 60; // 60 minutes active
	const activityScore = Math.min(100, (activityValue / targetActivity) * 100);

	// Weather impact
	let weatherScore = 70;
	if (weather.pressureTrend === "falling" && weather.pressure < 1010) {
		weatherScore = 50;
	} else if (weather.pressureTrend === "rising") {
		weatherScore = 80;
	}

	// Total energy score
	const score = Math.round(
		recoveryScore * 0.35 +
			sleepScore * 0.35 +
			activityScore * 0.2 +
			weatherScore * 0.1,
	);

	// Calculate peak focus and afternoon dip times based on wake time
	const [wakeHour] = wakeUpTime.split(":").map(Number);
	const peakStart = wakeHour + 2;
	const peakEnd = wakeHour + 5;
	const dipStart = wakeHour + 7;
	const dipEnd = wakeHour + 9;

	const formatHour = (h: number) => {
		const hour = h % 24;
		const ampm = hour >= 12 ? "PM" : "AM";
		const h12 = hour > 12 ? hour - 12 : hour === 0 ? 12 : hour;
		return `${h12}:00 ${ampm}`;
	};

	return {
		score,
		status: getScoreStatus(score, "energy"),
		contributingFactors: {
			recovery: {
				value: recoveryScore,
				label: "Recovery",
				trend: getTrendDirection(recoveryScore - 70),
				trendText: formatChangePercent(recoveryScore - 70),
				detail: "HRV-based recovery",
			},
			sleep: {
				value: sleepScore,
				label: "Sleep",
				trend: getTrendDirection(sleepScore - 70),
				trendText: formatChangePercent(sleepScore - 70),
				detail: "Sleep quality",
			},
			activity: {
				value: Math.round(activityScore),
				label: "Activity",
				trend: getTrendDirection(activityScore - 70),
				trendText: `${activityValue} min active`,
				detail: "Daily movement",
			},
			weather: {
				value: weatherScore,
				label: "Weather",
				trend: getTrendDirection(weatherScore - 70),
				trendText: weather.pressureTrend,
				detail: `${weather.pressure} hPa`,
			},
		},
		peakFocus: {
			start: formatHour(peakStart),
			end: formatHour(peakEnd),
		},
		afternoonDip: {
			start: formatHour(dipStart),
			end: formatHour(dipEnd),
		},
		analysis: "",
		chartData: generateChartData(energyScoreHistory),
	};
};
