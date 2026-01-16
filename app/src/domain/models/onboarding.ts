/**
 * オンボーディング関連の型定義
 * @see docs/specs/onboarding-design.md
 */

/**
 * ユーザーの目標
 * - better_sleep: より良い睡眠
 * - more_energy: もっと活力を
 * - less_stress: ストレス軽減
 * - peak_performance: 最高のパフォーマンス
 */
export type OnboardingGoal =
	| "better_sleep"
	| "more_energy"
	| "less_stress"
	| "peak_performance";

/**
 * 目標の表示情報
 */
export interface GoalInfo {
	id: OnboardingGoal;
	title: string;
	icon: string;
}

/**
 * 利用可能な目標一覧
 */
export const ONBOARDING_GOALS: GoalInfo[] = [
	{ id: "better_sleep", title: "より良い睡眠", icon: "moon" },
	{ id: "more_energy", title: "もっと活力を", icon: "zap" },
	{ id: "less_stress", title: "ストレス軽減", icon: "heart" },
	{ id: "peak_performance", title: "最高のパフォーマンス", icon: "target" },
];

/**
 * オンボーディングで収集するデータ
 */
export interface OnboardingData {
	/** 選択した目標（1-3つ） */
	goals: OnboardingGoal[];
	/** 起床目標時刻（HH:mm形式） */
	wakeUpTime: string;
	/** 就寝目標時刻（HH:mm形式） */
	bedTime: string;
	/** HealthKit権限が許可されたか */
	healthKitAuthorized: boolean;
	/** 完了日時 */
	completedAt: Date | null;
	/** 完了したステップ */
	completedSteps: number[];
}

/**
 * オンボーディングの状態
 */
export interface OnboardingState {
	/** 現在のステップ（1-4） */
	currentStep: number;
	/** 収集中のデータ */
	data: Partial<OnboardingData>;
	/** 完了フラグ */
	isComplete: boolean;
}

/**
 * オンボーディングのステップ数
 */
export const ONBOARDING_TOTAL_STEPS = 4;

/**
 * デフォルトの起床時刻
 */
export const DEFAULT_WAKE_UP_TIME = "07:00";

/**
 * デフォルトの就寝時刻
 */
export const DEFAULT_BED_TIME = "23:00";

/**
 * デフォルトの目標睡眠時間（分）
 * 7.5時間 = 450分（一般的な推奨睡眠時間）
 */
export const DEFAULT_TARGET_SLEEP_MINUTES = 450;

/**
 * キャリブレーション期間（日数）
 */
export const CALIBRATION_DAYS = 7;
