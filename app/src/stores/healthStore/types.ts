/**
 * HealthStore型定義
 */

import type {
	ActivityMetrics,
	AllDetailData,
	DailySnapshot,
	HealthMetricHistory,
	HealthTimeRange,
	HRVMetrics,
	RealtimeMetrics,
	RHRMetrics,
	RhythmAnalysis,
	SimpleWeatherData,
	SleepMetrics,
	SleepTimingHistory,
} from "../../domain/models";
import type { EnvironmentData } from "../../domain/models/environment";
import type { CircadianRhythm, EnergyCurve } from "../../domain/models/rhythm";
import type {
	ActivityMetrics as NewActivityMetrics,
	HrvMetrics as NewHrvMetrics,
	SleepMetrics as NewSleepMetrics,
	RhythmMetrics,
	TempoScoreResult,
} from "../../domain/services/tempoScoreCalculator";

/**
 * Score histories for chart displays
 */
export interface ScoreHistories {
	recovery: HealthMetricHistory | null;
	sleep: HealthMetricHistory | null;
	rhythm: HealthMetricHistory | null;
	energy: HealthMetricHistory | null;
}

/**
 * Health Summary用の履歴データ（7日分のスパークライン表示用）
 */
export interface HealthSummaryHistory {
	hrv: HealthMetricHistory | null;
	rhr: HealthMetricHistory | null;
	respiratory: HealthMetricHistory | null;
	spo2: HealthMetricHistory | null;
	wristTemp: HealthMetricHistory | null;
}

export interface HealthMetricsV2 {
	hrv: NewHrvMetrics | null;
	sleep: NewSleepMetrics | null;
	rhythm: RhythmMetrics | null;
	activity: NewActivityMetrics | null;
}

/**
 * HealthStore の状態インターフェース
 *
 * データ更新タイミング:
 * - dailySnapshot: 朝1回算出（起床時刻連動）、その日は固定
 * - realtimeMetrics: アプリ起動ごとにリアルタイム更新
 */
export interface HealthState {
	// Health metrics
	sleepMetrics: SleepMetrics | null;
	hrvMetrics: HRVMetrics | null;
	activityMetrics: ActivityMetrics | null;
	rhythmAnalysis: RhythmAnalysis | null;

	// Weather
	weather: SimpleWeatherData | null;
	weatherCode: number | null;
	weatherHumidity: number | null;

	// Loading states
	isLoadingMetrics: boolean;
	isLoadingWeather: boolean;

	// Error states
	metricsError: string | null;
	weatherError: string | null;

	// Last updated
	lastMetricsUpdate: Date | null;
	lastWeatherUpdate: Date | null;

	// Tempo Score
	metrics: HealthMetricsV2;
	tempoScore: TempoScoreResult | null;
	circadianRhythm: CircadianRhythm | null;
	energyCurve: EnergyCurve | null;
	calibrationStartDate: string | null;
	calibrationDaysCompleted: number;
	isLoading: boolean;
	error: string | null;

	// HealthKit 対応: 更新タイミング別データ
	/** 朝1回算出、その日は固定のスコア */
	dailySnapshot: DailySnapshot | null;
	/** 最後にスナップショットを算出した日付 (YYYY-MM-DD) */
	lastSnapshotDate: string | null;
	/** リアルタイム更新されるヘルスメトリクス */
	realtimeMetrics: RealtimeMetrics | null;

	// Detail screen data (Phase 2)
	/** RHR metrics for recovery detail */
	rhrMetrics: RHRMetrics | null;
	/** Historical data for detail screens */
	hrvHistory: HealthMetricHistory | null;
	rhrHistory: HealthMetricHistory | null;
	sleepTimingHistory: SleepTimingHistory | null;
	/** Score histories for charts */
	scoreHistories: ScoreHistories;
	/** Computed detail data */
	detailData: AllDetailData;

	// Health Summary用の履歴データ
	/** Health Summaryセクション用の7日分履歴（スパークライン表示） */
	healthSummaryHistory: HealthSummaryHistory | null;

	// Environment Data (Rhythm画面用)
	/** 環境データ（日の出/日の入り、天気、気圧、UV、月相） */
	environmentData: EnvironmentData | null;
	/** 環境データ読み込み中フラグ */
	isLoadingEnvironment: boolean;
	/** 環境データエラー */
	environmentError: string | null;
	/** 最終環境データ更新日時 */
	lastEnvironmentUpdate: Date | null;

	// Actions
	fetchTodayMetrics: () => Promise<void>;
	fetchWeather: (latitude: number, longitude: number) => Promise<void>;
	setMockData: () => void;
	resetHealth: () => void;
	setMetrics: (metrics: Partial<HealthMetricsV2>) => void;
	calculateAndSetTempoScore: () => void;
	calculateAndSetCircadianRhythm: (
		wakeUpTime: string,
		windDownTime: string,
		sunrise: string,
		sunset: string,
	) => void;
	startCalibration: () => void;
	incrementCalibrationDay: () => void;
	setLoading: (isLoading: boolean) => void;
	setError: (error: string | null) => void;
	reset: () => void;

	// HealthKit 対応: 新規アクション
	/** 今日のスナップショットが算出済みかを判定 */
	shouldCalculateSnapshot: () => boolean;
	/** 日次スナップショットを算出（朝1回のみ） */
	calculateDailySnapshot: () => Promise<void>;
	/** リアルタイムメトリクスを取得（アプリ起動ごと） */
	fetchRealtimeMetrics: () => Promise<void>;
	/** 4つの独立スコアを計算（AsyncStorageに保存） */
	calculateDailyScores: () => Promise<void>;
	/** アプリ起動時に呼び出す初期化関数 */
	initialize: () => Promise<void>;

	// Detail screen data actions
	/** Fetch historical data for detail screens */
	fetchHistoricalData: (timeRange?: HealthTimeRange) => Promise<void>;
	/** Calculate all detail data from current state */
	calculateAllDetailData: () => void;

	// Health Summary用の履歴取得
	/** Health Summary用の7日分履歴データを取得 */
	fetchHealthSummaryHistory: () => Promise<void>;

	// Environment Data actions
	/** 環境データを取得（日の出/日の入り、天気、気圧、UV、月相） */
	fetchEnvironmentData: (latitude: number, longitude: number) => Promise<void>;
}

export const initialHealthState = {
	metrics: {
		hrv: null,
		sleep: null,
		rhythm: null,
		activity: null,
	},
	tempoScore: null,
	circadianRhythm: null,
	energyCurve: null,
	calibrationStartDate: null,
	calibrationDaysCompleted: 0,
	isLoading: false,
	error: null,
	// HealthKit 対応
	dailySnapshot: null,
	lastSnapshotDate: null,
	realtimeMetrics: null,
	// Detail screen data
	rhrMetrics: null,
	hrvHistory: null,
	rhrHistory: null,
	sleepTimingHistory: null,
	scoreHistories: {
		recovery: null,
		sleep: null,
		rhythm: null,
		energy: null,
	},
	detailData: {
		recovery: null,
		sleep: null,
		rhythm: null,
		energy: null,
	},
	// Health Summary用の履歴データ
	healthSummaryHistory: null,
	// Environment Data
	environmentData: null,
	isLoadingEnvironment: false,
	environmentError: null,
	lastEnvironmentUpdate: null,
};
