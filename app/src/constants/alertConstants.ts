/**
 * アラート関連の閾値定数
 * @see docs/specs/tempoai_metrics_spec.md Section 4
 */

/**
 * アラート生成のための閾値
 */
export const ALERT_THRESHOLDS = {
	/** HRV関連 */
	hrv: {
		/** ベースライン比でこの値未満なら「回復が必要」アラート */
		lowRatio: 0.8,
		/** ベースライン比でこの値以上なら「回復完了」アラート */
		recoveredRatio: 1.15,
	},
	/** 睡眠関連 */
	sleep: {
		/** この分数未満で「睡眠不足」アラート（6時間 = 360分） */
		deficitMinutes: 360,
		/** 目標就寝時刻からこの分数以上遅れると「遅い就寝」アラート */
		lateBedtimeDelayMinutes: 60,
	},
	/** リズム関連 */
	rhythm: {
		/** 週末の起床時刻のずれがこの分数以上で「週末時差ボケ」アラート */
		weekendJetlagMinutes: 120,
	},
	/** 活動量関連 */
	activity: {
		/** この歩数未満で「活動量不足」アラート */
		lowSteps: 3000,
	},
} as const;
