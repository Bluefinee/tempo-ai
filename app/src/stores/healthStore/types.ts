/**
 * HealthStore型定義
 */

import type {
  RhythmAnalysis,
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
  SimpleWeatherData,
  DailySnapshot,
  RealtimeMetrics,
} from '../../domain/models';
import type {
  TempoScoreResult,
  HrvMetrics as NewHrvMetrics,
  SleepMetrics as NewSleepMetrics,
  RhythmMetrics,
  ActivityMetrics as NewActivityMetrics,
} from '../../domain/services/tempoScoreCalculator';
import type {
  CircadianRhythm,
  EnergyCurve,
} from '../../domain/models/rhythm';

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
    sunset: string
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
  /** 4つの独立スコアを計算 */
  calculateDailyScores: () => void;
  /** アプリ起動時に呼び出す初期化関数 */
  initialize: () => Promise<void>;
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
};

