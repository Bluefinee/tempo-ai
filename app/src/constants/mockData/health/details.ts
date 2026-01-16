/**
 * Mock Health Data
 * HealthKit related mock data
 */

import type {
	BarChartDataPoint,
	HealthMetricHistory,
} from "../../../domain/models/healthHistory";
import { toBarChartData } from "../../../utils/healthDataTransformer";
import { getAllScoreHistories } from "../../mockDataFactory";
export interface MockDetailRecovery {
	score: number;
	status: string;
	hrv: { value: number; unit: string; change: number; baseline: number };
	rhr: { value: number; unit: string; change: number; baseline: number };
	analysis: string;
	calculatedAt: string;
	rawHistory: HealthMetricHistory;
	history: {
		"7D": BarChartDataPoint[];
		"30D": BarChartDataPoint[];
		"60D": BarChartDataPoint[];
	};
	weeklyAverage: number;
}

export interface MockDetailSleep {
	score: number;
	duration: { hours: number; minutes: number; percentage: number };
	quality: { percentage: number };
	analysis: string;
	stages: {
		stage: "deep" | "rem" | "light" | "awake";
		percentage: number;
	}[];
	timing: {
		bedtime: { actual: string; target: string; diff: string };
		wakeTime: { actual: string; target: string; diff: string };
	};
	rawHistory: HealthMetricHistory;
	history: {
		"7D": BarChartDataPoint[];
		"30D": BarChartDataPoint[];
		"60D": BarChartDataPoint[];
	};
}

export interface MockDetailRhythm {
	score: number;
	status: string;
	analysis: string;
	consistency: {
		bedtime: { target: string; deviation: string };
		wakeTime: { target: string; deviation: string };
	};
	contributingFactors: {
		bedtimeVariance: {
			value: number;
			label: string;
			trend: string;
			trendDirection: "up" | "down" | "stable";
			detail: string;
		};
		wakeVariance: {
			value: number;
			label: string;
			trend: string;
			trendDirection: "up" | "down" | "stable";
			detail: string;
		};
		weekendShift: {
			value: number;
			label: string;
			trend: string;
			trendDirection: "up" | "down" | "stable";
			detail: string;
		};
		socialJetlag: {
			value: number;
			label: string;
			trend: string;
			trendDirection: "up" | "down" | "stable";
			detail: string;
		};
	};
	weeklyPattern: { day: string; offset: number }[];
	rawHistory: HealthMetricHistory;
	history: {
		"7D": BarChartDataPoint[];
		"30D": BarChartDataPoint[];
		"60D": BarChartDataPoint[];
	};
}

export interface MockDetailEnergy {
	score: number;
	status: string;
	analysis: string;
	contributingFactors: {
		recovery: {
			value: number;
			label: string;
			trend: string;
			trendDirection: "up" | "down" | "stable";
			detail: string;
		};
		sleep: {
			value: number;
			label: string;
			trend: string;
			trendDirection: "up" | "down" | "stable";
			detail: string;
		};
		activity: {
			value: number;
			label: string;
			trend: string;
			trendDirection: "up" | "down" | "stable";
			detail: string;
		};
		weather: {
			value: number;
			label: string;
			trend: string;
			trendDirection: "up" | "down" | "stable";
			detail: string;
		};
	};
	peakFocus: { start: string; end: string };
	afternoonDip: { start: string; end: string };
	rawHistory: HealthMetricHistory;
	history: {
		"7D": BarChartDataPoint[];
		"30D": BarChartDataPoint[];
		"60D": BarChartDataPoint[];
	};
}

export interface MockDetail {
	recovery: MockDetailRecovery;
	sleep: MockDetailSleep;
	rhythm: MockDetailRhythm;
	energy: MockDetailEnergy;
}

/**
 * Generate HealthKit compatible mock data
 * rawHistory contains Date in HealthKit format, history is BarChart compatible format
 */
const createMockDetail = (): MockDetail => {
	const scoreHistories = getAllScoreHistories("60D");

	return {
		recovery: {
			score: 70,
			status: "Ready to Train",
			hrv: { value: 82, unit: "ms", change: 5, baseline: 77 },
			rhr: { value: 59, unit: "bpm", change: 0, baseline: 59 },
			analysis:
				"Recovery score is based on daytime HRV average of 82ms (recorded at 5:39, 6% above 60-day average of 77ms) and resting heart rate of 59bpm (recorded at 22:06, equal to 60-day average of 59bpm).",
			calculatedAt: "5:39",
			rawHistory: scoreHistories.recoveryScore,
			get history() {
				const samples = this.rawHistory.samples;
				return {
					"7D": toBarChartData(samples.slice(-7), "7D", "en"),
					"30D": toBarChartData(samples.slice(-30), "30D", "en"),
					"60D": toBarChartData(samples, "60D", "en"),
				};
			},
			weeklyAverage: 64,
		},
		sleep: {
			score: 85,
			duration: { hours: 7, minutes: 8, percentage: 80 },
			quality: { percentage: 85 },
			analysis:
				"Sleep duration was below target, but REM and deep sleep were higher than usual. Your body seems to be prioritizing restorative stages to compensate for the shorter sleep.",
			stages: [
				{ stage: "deep" as const, percentage: 23 },
				{ stage: "rem" as const, percentage: 22 },
				{ stage: "light" as const, percentage: 53 },
				{ stage: "awake" as const, percentage: 2 },
			],
			timing: {
				bedtime: { actual: "23:15", target: "23:00", diff: "15 min late" },
				wakeTime: { actual: "06:45", target: "07:00", diff: "15 min early" },
			},
			rawHistory: scoreHistories.sleepScore,
			get history() {
				const samples = this.rawHistory.samples;
				return {
					"7D": toBarChartData(samples.slice(-7), "7D", "en"),
					"30D": toBarChartData(samples.slice(-30), "30D", "en"),
					"60D": toBarChartData(samples, "60D", "en"),
				};
			},
		},
		rhythm: {
			score: 92,
			status: "In Sync",
			analysis:
				"Your circadian rhythm is well aligned with your sleep-wake cycle. Your bedtime consistency has been excellent this week, contributing to a high rhythm score.",
			consistency: {
				bedtime: { target: "23:00", deviation: "±12 min" },
				wakeTime: { target: "07:00", deviation: "±8 min" },
			},
			contributingFactors: {
				bedtimeVariance: {
					value: 95,
					label: "Bedtime Variance",
					trend: "+3%",
					trendDirection: "up" as const,
					detail: "Avg ±12 min (target ±15 min)",
				},
				wakeVariance: {
					value: 98,
					label: "Wake Variance",
					trend: "+5%",
					trendDirection: "up" as const,
					detail: "Avg ±8 min (target ±15 min)",
				},
				weekendShift: {
					value: 85,
					label: "Weekend Shift",
					trend: "Stable",
					trendDirection: "stable" as const,
					detail: "Weekend delay 25 min",
				},
				socialJetlag: {
					value: 90,
					label: "Social Jetlag",
					trend: "-2%",
					trendDirection: "down" as const,
					detail: "Weekday-weekend gap 32 min",
				},
			},
			weeklyPattern: [
				{ day: "Thu", offset: 0 },
				{ day: "Fri", offset: -10 },
				{ day: "Sat", offset: 5 },
				{ day: "Sun", offset: 0 },
				{ day: "Mon", offset: 15 },
				{ day: "Tue", offset: 5 },
				{ day: "Wed", offset: 0 },
			],
			rawHistory: scoreHistories.rhythmScore,
			get history() {
				const samples = this.rawHistory.samples;
				return {
					"7D": toBarChartData(samples.slice(-7), "7D", "en"),
					"30D": toBarChartData(samples.slice(-30), "30D", "en"),
					"60D": toBarChartData(samples, "60D", "en"),
				};
			},
		},
		energy: {
			score: 78,
			status: "Moderate Energy",
			analysis:
				"Based on your recovery and sleep data, you should have good energy today. Peak Focus window is 9:00-12:00. Consider switching to lighter tasks during the Afternoon Dip (14:00-16:00).",
			contributingFactors: {
				recovery: {
					value: 70,
					label: "Recovery",
					trend: "+5%",
					trendDirection: "up" as const,
					detail: "HRV 82ms (baseline +6%)",
				},
				sleep: {
					value: 85,
					label: "Sleep",
					trend: "+3%",
					trendDirection: "up" as const,
					detail: "Deep sleep 1h 45m",
				},
				activity: {
					value: 75,
					label: "Activity",
					trend: "Stable",
					trendDirection: "stable" as const,
					detail: "Yesterday 8,500 steps",
				},
				weather: {
					value: 80,
					label: "Weather",
					trend: "Stable",
					trendDirection: "stable" as const,
					detail: "Clear, stable pressure",
				},
			},
			peakFocus: { start: "09:00", end: "12:00" },
			afternoonDip: { start: "14:00", end: "16:00" },
			rawHistory: scoreHistories.energyScore,
			get history() {
				const samples = this.rawHistory.samples;
				return {
					"7D": toBarChartData(samples.slice(-7), "7D", "en"),
					"30D": toBarChartData(samples.slice(-30), "30D", "en"),
					"60D": toBarChartData(samples, "60D", "en"),
				};
			},
		},
	};
};

/** HealthKit compatible mock detail data */
export const MOCK_DETAIL = createMockDetail();
