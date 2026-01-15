/**
 * Mock Health Data
 * HealthKit related mock data
 */

import type {
	ActivityMetrics,
	DailyScoreSnapshot,
	EnvironmentData,
	HealthMetrics,
	HRVMetrics,
	QuickAction,
	RecommendedAction,
	RhythmAnalysis,
	SimpleWeatherData,
	SleepMetrics,
} from "../../../domain/models";

/**
 * MOCK WEATHER DATA
 */
export const MOCK_WEATHER: SimpleWeatherData = {
	temp: 8,
	condition: "Clear",
	pressure: 1018,
	pressureTrend: "stable",
	uv: 3,
	location: "Tokyo",
};

/**
 * MOCK ENVIRONMENT DATA
 * Rhythm画面用の環境データ（日の出/日の入り、天気、気圧、UV、月相）
 */
const createMockEnvironmentData = (): EnvironmentData => {
	const today = new Date();
	const sunriseTime = new Date(today);
	sunriseTime.setHours(6, 50, 0, 0);
	const sunsetTime = new Date(today);
	sunsetTime.setHours(16, 48, 0, 0);

	return {
		sunrise: "6:50",
		sunset: "16:48",
		sunriseTime,
		sunsetTime,
		dayLengthMinutes: Math.round(
			(sunsetTime.getTime() - sunriseTime.getTime()) / 60000,
		),
		location: "Tokyo",
		weather: {
			condition: "Clear",
			temperature: 8,
			humidity: 45,
		},
		pressure: {
			value: 1018,
			trend: "stable",
			change24h: 2,
		},
		uv: {
			index: 3,
			level: "Moderate",
		},
		moonPhase: {
			phase: "First Quarter",
			illumination: 48,
		},
	};
};

export const MOCK_ENVIRONMENT_DATA: EnvironmentData =
	createMockEnvironmentData();

/**
 * MOCK QUICK ACTIONS
 */
export const MOCK_QUICK_ACTIONS: QuickAction[] = [
	{
		id: "1",
		type: "activity",
		text: "10-min walk after lunch",
		icon: "footprints",
	},
	{ id: "2", type: "breathing", text: "1-min deep breathing", icon: "wind" },
];

/**
 * MOCK RECOMMENDED ACTION
 */
export const MOCK_RECOMMENDED_ACTION: RecommendedAction = {
	type: "activity",
	message: "10-min walk after lunch",
	icon: "footprints",
	displayName: "Activity",
};

/**
 * MOCK SLEEP METRICS
 */
export const MOCK_SLEEP_METRICS: SleepMetrics = {
	bedtime: new Date("2025-01-05T23:15:00"),
	wakeTime: new Date("2025-01-06T06:45:00"),
	durationMinutes: 450,
	deepSleepMinutes: 105,
	remSleepMinutes: 90,
};

/**
 * MOCK HRV METRICS
 */
export const MOCK_HRV_METRICS: HRVMetrics = {
	value: 68,
	baseline30d: 55,
};

/**
 * MOCK ACTIVITY METRICS
 */
export const MOCK_ACTIVITY_METRICS: ActivityMetrics = {
	stepsYesterday: 8500,
	activeMinutesYesterday: 35,
};

/**
 * MOCK HEALTH METRICS
 */
export const MOCK_HEALTH_METRICS: HealthMetrics = {
	date: new Date(),
	sleep: MOCK_SLEEP_METRICS,
	hrv: MOCK_HRV_METRICS,
	activity: MOCK_ACTIVITY_METRICS,
	auxiliary: {
		daylightMinutesYesterday: 25,
		wristTemperatureDeviation: 0.3,
	},
};

/**
 * MOCK RHYTHM ANALYSIS
 */
export const MOCK_RHYTHM_ANALYSIS: RhythmAnalysis = {
	bedtimeStddevMinutes: 22,
	wakeTimeStddevMinutes: 18,
	consecutiveStableDays: 5,
	status: "stable",
	isStable: true,
	bedtimeConsistencyScore: 85,
	wakeTimeConsistencyScore: 88,
};

/**
 * MOCK WEEKLY SCORES
 */
export const MOCK_WEEKLY_SCORES: DailyScoreSnapshot[] = [
	{
		id: "1",
		date: new Date("2025-01-01"),
		recoveryScore: 78,
		sleepScore: 65,
		rhythmScore: 82,
		energyScore: 70,
	},
	{
		id: "2",
		date: new Date("2025-01-02"),
		recoveryScore: 80,
		sleepScore: 70,
		rhythmScore: 85,
		energyScore: 75,
	},
	{
		id: "3",
		date: new Date("2025-01-03"),
		recoveryScore: 75,
		sleepScore: 68,
		rhythmScore: 88,
		energyScore: 65,
	},
	{
		id: "4",
		date: new Date("2025-01-04"),
		recoveryScore: 82,
		sleepScore: 74,
		rhythmScore: 90,
		energyScore: 78,
	},
	{
		id: "5",
		date: new Date("2025-01-05"),
		recoveryScore: 85,
		sleepScore: 72,
		rhythmScore: 94,
		energyScore: 80,
	},
	{
		id: "6",
		date: new Date("2025-01-06"),
		recoveryScore: 85,
		sleepScore: 72,
		rhythmScore: 94,
		energyScore: 82,
	},
	{
		id: "7",
		date: new Date("2025-01-07"),
		recoveryScore: 88,
		sleepScore: 76,
		rhythmScore: 95,
		energyScore: 85,
	},
];

/**
 * HealthKit 対応版の詳細データ構造
 *
 * 特徴:
 * - rawHistory: Date 型を含む HealthKit 形式のデータ
 * - history: BarChart 互換形式への変換ゲッター
 * - ベースライン・典型範囲を含む
 */
