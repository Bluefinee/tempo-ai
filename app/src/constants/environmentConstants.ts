/**
 * 環境データのデフォルト定数
 * Rhythm画面等で使用するフォールバック値
 */

import type { EnvironmentData } from "../domain/models/environment";

/**
 * デフォルトの環境データ
 * APIからのデータ取得失敗時のフォールバック値として使用
 */
export const DEFAULT_ENVIRONMENT_DATA: EnvironmentData = {
	sunrise: "6:50",
	sunset: "16:48",
	sunriseTime: new Date(2026, 0, 1, 6, 50),
	sunsetTime: new Date(2026, 0, 1, 16, 48),
	dayLengthMinutes: 598, // 約10時間
	location: "",
	weather: {
		condition: "Clear",
		temperature: 15,
		humidity: 50,
	},
	pressure: {
		value: 1013,
		trend: "stable",
		change24h: 0,
	},
	uv: {
		index: 3,
		level: "Moderate",
	},
	moonPhase: {
		phase: "First Quarter",
		illumination: 50,
	},
};

/**
 * 睡眠タイミングのデフォルト値
 * スコア計算や詳細画面で使用
 */
export const SLEEP_TIMING_DEFAULTS = {
	/** 基準就寝時刻（分: 23:00 = 1380分） */
	BASE_BEDTIME_MINUTES: 23 * 60,
	/** 基準起床時刻（分: 7:00 = 420分） */
	BASE_WAKE_MINUTES: 7 * 60,
	/** 標準偏差（分） */
	VARIANCE_MINUTES: 45,
	/** 最小睡眠時間（分） */
	MIN_DURATION_MINUTES: 300,
	/** 最大睡眠時間（分） */
	MAX_DURATION_MINUTES: 600,
} as const;

/**
 * デフォルトの位置情報
 */
export const DEFAULT_LOCATION = "Current Location";
