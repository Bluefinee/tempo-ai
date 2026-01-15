/**
 * スコア計算関連の定数
 * @see docs/specs/tempoai_metrics_spec.md
 */

/**
 * 睡眠ステージの理想的な割合閾値
 * 科学的根拠: 成人の健康的な睡眠構成
 */
export const SLEEP_STAGE_THRESHOLDS = {
	/** Deep Sleep (深い睡眠): 15-25%が理想 */
	deep: { min: 0.15, max: 0.25 },
	/** REM Sleep (レム睡眠): 20-25%が理想 */
	rem: { min: 0.2, max: 0.25 },
} as const;

/**
 * リズム一貫性の閾値（標準偏差 → スコア）
 * 就寝時刻・起床時刻のばらつきからスコアを算出
 */
export const RHYTHM_CONSISTENCY_THRESHOLDS = {
	/** 15分以下: 優秀 */
	EXCELLENT: { maxMinutes: 15, score: 100 },
	/** 30分以下: 良好 */
	GOOD: { maxMinutes: 30, score: 85 },
	/** 45分以下: 普通 */
	FAIR: { maxMinutes: 45, score: 70 },
	/** 60分以下: やや不安定 */
	POOR: { maxMinutes: 60, score: 55 },
	/** 90分以下: 不安定 */
	VERY_POOR: { maxMinutes: 90, score: 40 },
	/** 90分超: 非常に不安定 */
	MINIMUM_SCORE: 25,
} as const;

/**
 * 睡眠時間の理想的な範囲（分）
 */
export const SLEEP_DURATION_RANGES = {
	/** 理想的な睡眠時間の最小値（7時間 = 420分） */
	IDEAL_MIN: 420,
	/** 理想的な睡眠時間の最大値（9時間 = 540分） */
	IDEAL_MAX: 540,
	/** 短すぎる睡眠の閾値（6時間 = 360分） */
	SHORT: 360,
	/** 長すぎる睡眠の閾値（10時間 = 600分） */
	LONG: 600,
} as const;

/**
 * アクティビティ目標値
 */
export const ACTIVITY_GOALS = {
	/** デフォルトの1日の目標歩数 */
	DAILY_STEPS: 8000,
	/** 低活動の閾値（これ未満でアラート） */
	LOW_ACTIVITY_THRESHOLD: 3000,
} as const;

/**
 * スコアステータスの閾値
 */
export const SCORE_STATUS_THRESHOLDS = {
	EXCELLENT: 85,
	GOOD: 65,
	FAIR: 40,
} as const;

/**
 * 標準偏差からリズムスコアを計算するヘルパー
 */
export const getConsistencyScore = (stddevMinutes: number): number => {
	if (stddevMinutes <= RHYTHM_CONSISTENCY_THRESHOLDS.EXCELLENT.maxMinutes) {
		return RHYTHM_CONSISTENCY_THRESHOLDS.EXCELLENT.score;
	}
	if (stddevMinutes <= RHYTHM_CONSISTENCY_THRESHOLDS.GOOD.maxMinutes) {
		return RHYTHM_CONSISTENCY_THRESHOLDS.GOOD.score;
	}
	if (stddevMinutes <= RHYTHM_CONSISTENCY_THRESHOLDS.FAIR.maxMinutes) {
		return RHYTHM_CONSISTENCY_THRESHOLDS.FAIR.score;
	}
	if (stddevMinutes <= RHYTHM_CONSISTENCY_THRESHOLDS.POOR.maxMinutes) {
		return RHYTHM_CONSISTENCY_THRESHOLDS.POOR.score;
	}
	if (stddevMinutes <= RHYTHM_CONSISTENCY_THRESHOLDS.VERY_POOR.maxMinutes) {
		return RHYTHM_CONSISTENCY_THRESHOLDS.VERY_POOR.score;
	}
	return RHYTHM_CONSISTENCY_THRESHOLDS.MINIMUM_SCORE;
};
