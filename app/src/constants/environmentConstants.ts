/**
 * Environment Data Constants
 * 環境データに関する定数・フォールバック値
 */

import type { EnvironmentData } from "../domain/models/environment";

/**
 * デフォルトの環境データ（フォールバック用）
 * 注: これらの値は実データがない場合のプレースホルダーであり、
 * APIやデバイスから取得した実データで上書きされることを前提としています。
 */
export const DEFAULT_ENVIRONMENT_DATA: EnvironmentData = {
	sunrise: "--:--",
	sunset: "--:--",
	sunriseTime: new Date(0),
	sunsetTime: new Date(0),
	dayLengthMinutes: 0,
	location: "--",
	weather: {
		condition: "--",
		temperature: 0,
		humidity: 0,
	},
	pressure: {
		value: 0,
		trend: "stable",
		change24h: 0,
	},
	uv: {
		index: 0,
		level: "Low",
	},
	moonPhase: {
		phase: "New Moon",
		illumination: 0,
	},
};

/**
 * 東京のデフォルト座標（位置情報未取得時のフォールバック）
 */
export const DEFAULT_LOCATION = {
	latitude: 35.6762,
	longitude: 139.6503,
	name: "Tokyo",
} as const;

/**
 * 天気コンディションのデフォルト値
 */
export const DEFAULT_WEATHER_CONDITION = "Clear";

/**
 * 気圧の閾値
 */
export const PRESSURE_THRESHOLDS = {
	LOW: 1005,
	NORMAL: 1013,
	HIGH: 1020,
} as const;

/**
 * UV指数のレベル閾値
 */
export const UV_LEVEL_THRESHOLDS = {
	LOW: 2,
	MODERATE: 5,
	HIGH: 7,
	VERY_HIGH: 10,
} as const;

/**
 * 睡眠タイミングのデフォルト値（分単位）
 */
export const SLEEP_TIMING_DEFAULTS = {
	/** 基準就寝時刻（23:00 = 1380分） */
	BASE_BEDTIME_MINUTES: 23 * 60,
	/** 基準起床時刻（07:00 = 420分） */
	BASE_WAKE_MINUTES: 7 * 60,
	/** 時刻変動の標準偏差（±45分） */
	VARIANCE_MINUTES: 45,
	/** 最小睡眠時間（5時間） */
	MIN_DURATION_MINUTES: 300,
	/** 最大睡眠時間（10時間） */
	MAX_DURATION_MINUTES: 600,
} as const;
