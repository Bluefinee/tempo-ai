/**
 * Chart Constants
 * チャート表示に関する共通定数
 */

/**
 * スコアチャートの標準範囲
 * Recovery, Sleep, Rhythm, Energy の全スコアで使用
 */
export const SCORE_TYPICAL_RANGE = {
	min: 40,
	max: 100,
} as const;

/**
 * データ鮮度の閾値（時間）
 * この時間を超えるとデータは古いとみなされる
 */
export const DATA_STALE_THRESHOLD_HOURS = 6;

/**
 * 履歴データの日数
 */
export const HISTORY_DAYS = {
	WEEK: 7,
	MONTH: 30,
	TWO_MONTHS: 60,
} as const;
