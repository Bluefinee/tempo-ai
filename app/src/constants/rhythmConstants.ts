/**
 * サーカディアンリズム関連の定数
 * 科学的根拠に基づく時間オフセット（起床時刻からの経過時間）
 */

/**
 * 各フェーズの時間オフセット（単位：時間）
 *
 * @see https://en.wikipedia.org/wiki/Circadian_rhythm
 * @see tempoai_metrics_spec.md - サーカディアンリズムスコア仕様
 */
export const CIRCADIAN_PHASE_OFFSETS = {
	/** Peak Focus - 最も集中力が高い時間帯 */
	peakFocus: {
		/** 起床から2時間後に開始 */
		startOffset: 2,
		/** 起床から5時間後に終了 */
		endOffset: 5,
	},
	/** Afternoon Dip - 午後の眠気ピーク */
	afternoonDip: {
		/** 起床から7時間後に開始 */
		startOffset: 7,
		/** 起床から9時間後に終了 */
		endOffset: 9,
	},
	/** Second Wind - 夕方の活力回復期 */
	secondWind: {
		/** 起床から10時間後に開始 */
		startOffset: 10,
		/** 起床から13時間後に終了 */
		endOffset: 13,
	},
	/** Wind Down - 就寝準備期（就寝時刻からの逆算） */
	windDown: {
		/** 就寝2時間前から開始 */
		beforeBedtime: 2,
	},
} as const;

/** ツールチップの自動非表示遅延（ミリ秒） */
export const TOOLTIP_AUTO_HIDE_DELAY = 1500;
