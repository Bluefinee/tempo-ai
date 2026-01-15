/**
 * HealthStore - メインストア
 */

import AsyncStorage from "@react-native-async-storage/async-storage";
import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";
import { DATA_SOURCE_CONFIG } from "../../config/dataSource";
import {
	createMockDailySnapshot,
	MOCK_ACTIVITY_METRICS,
	MOCK_HRV_METRICS,
	MOCK_RHYTHM_ANALYSIS,
	MOCK_SLEEP_METRICS,
	MOCK_WEATHER,
} from "../../constants/mockData";
import { formatDateString } from "../../constants/mockDataFactory";
import type { DailySnapshot, HealthTimeRange } from "../../domain/models";
import {
	DEFAULT_BED_TIME,
	DEFAULT_TARGET_SLEEP_MINUTES,
	DEFAULT_WAKE_UP_TIME,
} from "../../domain/models/onboarding";
import type { DailyScores } from "../../domain/models/score";
import {
	fillEnergyAnalysis,
	fillRecoveryAnalysis,
	fillRhythmAnalysis,
	fillSleepAnalysis,
} from "../../domain/services/analysisTemplates";
import {
	calculateEnergyDetail,
	calculateRecoveryDetail,
	calculateRhythmDetail,
	calculateSleepDetail,
} from "../../domain/services/detailCalculator";
import {
	calculateCircadianRhythm,
	calculateEnergyCurve,
} from "../../domain/services/rhythmCalculator";
import {
	calculateEnergyScore,
	calculateRecoveryScore,
	calculateRhythmScore,
	calculateSleepScore,
} from "../../domain/services/scoreCalculator";
import { calculateTempoScore } from "../../domain/services/tempoScoreCalculator";
import { dataSourceAdapter } from "../../services/dataSourceAdapter";
import { scoreHistoryStorage } from "../../services/scoreHistoryStorage";
import type { HealthMetricsV2, HealthState } from "./types";
import { initialHealthState } from "./types";

export * from "./selectors";
export type { HealthMetricsV2, HealthState } from "./types";

export const useHealthStore = create<HealthState>()(
	persist(
		(set, get) => ({
			...initialHealthState,
			sleepMetrics: null,
			hrvMetrics: null,
			rhrMetrics: null,
			activityMetrics: null,
			rhythmAnalysis: null,
			weather: null,
			weatherCode: null,
			weatherHumidity: null,
			isLoadingMetrics: false,
			isLoadingWeather: false,
			metricsError: null,
			weatherError: null,
			lastMetricsUpdate: null,
			lastWeatherUpdate: null,
			// Historical data
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

			fetchTodayMetrics: async (): Promise<void> => {
				set({ isLoadingMetrics: true, metricsError: null });

				try {
					const [sleep, hrv, activity, rhythm] = await Promise.all([
						dataSourceAdapter.getSleepMetrics(),
						dataSourceAdapter.getHRVMetrics(),
						dataSourceAdapter.getActivityMetrics(),
						dataSourceAdapter.getRhythmAnalysis(),
					]);

					set({
						sleepMetrics: sleep,
						hrvMetrics: hrv,
						activityMetrics: activity,
						rhythmAnalysis: rhythm,
						isLoadingMetrics: false,
						lastMetricsUpdate: new Date(),
					});
				} catch (error) {
					set({
						isLoadingMetrics: false,
						metricsError:
							error instanceof Error
								? error.message
								: "Failed to fetch metrics",
					});
				}
			},

			fetchWeather: async (
				latitude: number,
				longitude: number,
			): Promise<void> => {
				set({ isLoadingWeather: true, weatherError: null });

				try {
					const weather = await dataSourceAdapter.getWeather(
						latitude,
						longitude,
					);

					set({
						weather,
						weatherCode: null,
						weatherHumidity: null,
						isLoadingWeather: false,
						lastWeatherUpdate: new Date(),
					});
				} catch (error) {
					const message =
						error instanceof Error ? error.message : "Failed to fetch weather";
					set({
						isLoadingWeather: false,
						weatherError: message,
					});
				}
			},

			setMockData: () => {
				set({
					sleepMetrics: MOCK_SLEEP_METRICS,
					hrvMetrics: MOCK_HRV_METRICS,
					activityMetrics: MOCK_ACTIVITY_METRICS,
					rhythmAnalysis: MOCK_RHYTHM_ANALYSIS,
					weather: MOCK_WEATHER,
					lastMetricsUpdate: new Date(),
					lastWeatherUpdate: new Date(),
				});
			},

			resetHealth: () =>
				set({
					sleepMetrics: null,
					hrvMetrics: null,
					activityMetrics: null,
					rhythmAnalysis: null,
					weather: null,
					weatherCode: null,
					weatherHumidity: null,
					isLoadingMetrics: false,
					isLoadingWeather: false,
					metricsError: null,
					weatherError: null,
					lastMetricsUpdate: null,
					lastWeatherUpdate: null,
				}),

			setMetrics: (newMetrics: Partial<HealthMetricsV2>) => {
				set((state) => ({
					metrics: {
						...state.metrics,
						...newMetrics,
					},
				}));
			},

			calculateAndSetTempoScore: () => {
				const { metrics, calibrationDaysCompleted } = get();
				const isCalibrating = calibrationDaysCompleted < 7;

				const tempoScore = calculateTempoScore(
					metrics.hrv,
					metrics.sleep,
					metrics.rhythm,
					metrics.activity,
					isCalibrating,
				);

				set({ tempoScore });
			},

			calculateAndSetCircadianRhythm: (
				wakeUpTime: string,
				windDownTime: string,
				sunrise: string,
				sunset: string,
			) => {
				const circadianRhythm = calculateCircadianRhythm(
					wakeUpTime,
					windDownTime,
					sunrise,
					sunset,
				);
				const energyCurve = calculateEnergyCurve(wakeUpTime, windDownTime);

				set({ circadianRhythm, energyCurve });
			},

			startCalibration: () => {
				const now = new Date().toISOString();
				set({
					calibrationStartDate: now,
					calibrationDaysCompleted: 0,
				});
			},

			incrementCalibrationDay: () => {
				set((state) => ({
					calibrationDaysCompleted: Math.min(
						state.calibrationDaysCompleted + 1,
						7,
					),
				}));
			},

			setLoading: (isLoading: boolean) => set({ isLoading }),

			setError: (error: string | null) => set({ error }),

			reset: () => set(initialHealthState),

			shouldCalculateSnapshot: (): boolean => {
				const { lastSnapshotDate } = get();
				const today = formatDateString(new Date());
				return lastSnapshotDate !== today;
			},

			calculateDailySnapshot: async (): Promise<void> => {
				const state = get();

				if (!state.shouldCalculateSnapshot()) {
					return;
				}

				set({ isLoading: true, error: null });

				try {
					await new Promise((resolve) => setTimeout(resolve, 300));

					const snapshot = createMockDailySnapshot();

					set({
						dailySnapshot: snapshot,
						lastSnapshotDate: snapshot.date,
						isLoading: false,
					});
				} catch (error) {
					set({
						isLoading: false,
						error:
							error instanceof Error
								? error.message
								: "Failed to calculate daily snapshot",
					});
				}
			},

			calculateDailyScores: async () => {
				const {
					sleepMetrics,
					hrvMetrics,
					activityMetrics,
					rhythmAnalysis,
					weather,
				} = get();

				if (
					!sleepMetrics ||
					!hrvMetrics ||
					!activityMetrics ||
					!rhythmAnalysis
				) {
					console.warn("Missing metrics for score calculation");
					return;
				}

				const sleepScore = calculateSleepScore({
					duration: {
						minutes: sleepMetrics.durationMinutes,
						targetMinutes: DEFAULT_TARGET_SLEEP_MINUTES,
					},
					stages: {
						deepMinutes: sleepMetrics.deepSleepMinutes,
						remMinutes: sleepMetrics.remSleepMinutes,
						lightMinutes:
							sleepMetrics.durationMinutes -
							sleepMetrics.deepSleepMinutes -
							sleepMetrics.remSleepMinutes,
						awakeMinutes: 0,
					},
				});

				const recoveryScore = calculateRecoveryScore({
					hrv: {
						current: hrvMetrics.value,
						baseline: hrvMetrics.baseline30d,
					},
					rhr: {
						current: 60,
						baseline: 60,
					},
					sleepQuality: sleepScore,
				});

				const rhythmScore = calculateRhythmScore({
					bedtimeStddevMinutes: rhythmAnalysis.bedtimeStddevMinutes,
					wakeTimeStddevMinutes: rhythmAnalysis.wakeTimeStddevMinutes,
				});

				const energyScore = calculateEnergyScore({
					recovery: recoveryScore,
					sleep: sleepScore,
					weather: {
						pressure: weather?.pressure ?? 1013,
						pressureTrend: weather?.pressureTrend ?? "stable",
					},
				});

				const dailyScores: DailyScores = {
					recovery: recoveryScore,
					sleep: sleepScore,
					rhythm: rhythmScore,
					energy: energyScore,
				};

				// Save scores to AsyncStorage history (本番モードのみ)
				if (!DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
					try {
						await scoreHistoryStorage.saveTodayScore(dailyScores);
					} catch (error) {
						console.error("Failed to save score history:", error);
					}
				}

				const currentSnapshot = get().dailySnapshot;
				set({
					dailySnapshot: currentSnapshot
						? {
								...currentSnapshot,
								date: formatDateString(new Date()),
								scores: dailyScores,
							}
						: ({
								date: formatDateString(new Date()),
								scores: dailyScores,
								calculatedAt: new Date(),
							} as DailySnapshot),
				});
			},

			initialize: async () => {
				// 東京のデフォルト座標
				const defaultLat = 35.6762;
				const defaultLon = 139.6503;

				// 並行でデータを取得
				await Promise.all([
					get().fetchTodayMetrics(),
					get().fetchRealtimeMetrics(),
					get().fetchHealthSummaryHistory(),
					get().fetchWeather(defaultLat, defaultLon),
					get().fetchEnvironmentData(defaultLat, defaultLon),
				]);

				await get().calculateDailyScores();

				// 環境データと時刻設定を使ってサーカディアンリズムを計算
				const state = get();
				const envData = state.environmentData;

				// userStoreからwakeUpTime/windDownTimeを取得
				// 注: 循環参照を避けるため、useUserStore.getState()は使用しない
				// Rhythm画面で直接userStoreから取得するか、
				// 初期化時にパラメータとして渡す方式に変更する
				// ここではonboarding.tsの定数を使用
				const defaultWakeUpTime = DEFAULT_WAKE_UP_TIME;
				const defaultWindDownTime = DEFAULT_BED_TIME;

				if (envData) {
					get().calculateAndSetCircadianRhythm(
						defaultWakeUpTime,
						defaultWindDownTime,
						envData.sunrise,
						envData.sunset,
					);
				}
			},

			fetchRealtimeMetrics: async (): Promise<void> => {
				set({ isLoadingMetrics: true, metricsError: null });

				try {
					const metrics = await dataSourceAdapter.getRealtimeMetrics();

					set({
						realtimeMetrics: metrics,
						isLoadingMetrics: false,
						lastMetricsUpdate: new Date(),
					});
				} catch (error) {
					set({
						isLoadingMetrics: false,
						metricsError:
							error instanceof Error
								? error.message
								: "Failed to fetch realtime metrics",
					});
				}
			},

			fetchHealthSummaryHistory: async (): Promise<void> => {
				try {
					const [hrv, rhr, respiratory, spo2, wristTemp] = await Promise.all([
						dataSourceAdapter.getHRVHistory("7D"),
						dataSourceAdapter.getRHRHistory("7D"),
						dataSourceAdapter.getRespiratoryHistory("7D"),
						dataSourceAdapter.getSpO2History("7D"),
						dataSourceAdapter.getWristTempHistory("7D"),
					]);
					set({
						healthSummaryHistory: { hrv, rhr, respiratory, spo2, wristTemp },
					});
				} catch (error) {
					console.error("Failed to fetch health summary history:", error);
				}
			},

			fetchEnvironmentData: async (
				latitude: number,
				longitude: number,
			): Promise<void> => {
				set({ isLoadingEnvironment: true, environmentError: null });

				try {
					const environmentData = await dataSourceAdapter.getEnvironmentData(
						latitude,
						longitude,
					);

					set({
						environmentData,
						isLoadingEnvironment: false,
						lastEnvironmentUpdate: new Date(),
					});
				} catch (error) {
					const message =
						error instanceof Error
							? error.message
							: "Failed to fetch environment data";
					set({
						isLoadingEnvironment: false,
						environmentError: message,
					});
				}
			},

			fetchHistoricalData: async (
				timeRange: HealthTimeRange = "60D",
			): Promise<void> => {
				set({ isLoading: true, error: null });

				try {
					// Fetch HRV, RHR, sleep timing history (always from dataSourceAdapter)
					const [hrvHistory, rhrHistory, sleepTimingHistory, rhrMetrics] =
						await Promise.all([
							dataSourceAdapter.getHRVHistory(timeRange),
							dataSourceAdapter.getRHRHistory(timeRange),
							dataSourceAdapter.getSleepTimingHistory(timeRange),
							dataSourceAdapter.getRHRMetrics(),
						]);

					// Fetch score histories based on mode
					let scoreHistoriesData;

					if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
						// Development mode: Use mock data (existing behavior)
						const [
							recoveryHistory,
							sleepHistory,
							rhythmHistory,
							energyHistory,
						] = await Promise.all([
							dataSourceAdapter.getScoreHistory("recovery", timeRange),
							dataSourceAdapter.getScoreHistory("sleep", timeRange),
							dataSourceAdapter.getScoreHistory("rhythm", timeRange),
							dataSourceAdapter.getScoreHistory("energy", timeRange),
						]);

						scoreHistoriesData = {
							recovery: recoveryHistory,
							sleep: sleepHistory,
							rhythm: rhythmHistory,
							energy: energyHistory,
						};
					} else {
						// Production mode: Load from AsyncStorage
						scoreHistoriesData =
							await scoreHistoryStorage.getAllScoreHistories();
					}

					set({
						hrvHistory,
						rhrHistory,
						sleepTimingHistory,
						rhrMetrics,
						scoreHistories: scoreHistoriesData,
						isLoading: false,
					});

					// Calculate detail data after fetching historical data
					get().calculateAllDetailData();
				} catch (error) {
					set({
						isLoading: false,
						error:
							error instanceof Error
								? error.message
								: "Failed to fetch historical data",
					});
				}
			},

			calculateAllDetailData: () => {
				const state = get();

				// Check if we have required data
				if (
					!state.hrvMetrics ||
					!state.rhrMetrics ||
					!state.sleepMetrics ||
					!state.activityMetrics ||
					!state.hrvHistory ||
					!state.rhrHistory ||
					!state.sleepTimingHistory ||
					!state.scoreHistories.recovery
				) {
					console.warn("Missing data for detail calculations");
					return;
				}

				// Calculate Recovery Detail
				const recoveryDetail = fillRecoveryAnalysis(
					calculateRecoveryDetail({
						hrvMetrics: state.hrvMetrics,
						rhrMetrics: state.rhrMetrics,
						sleepScore: state.dailySnapshot?.scores.sleep ?? 70,
						hrvHistory: state.hrvHistory,
						rhrHistory: state.rhrHistory,
						recoveryScoreHistory: state.scoreHistories.recovery,
					}),
				);

				// Calculate Sleep Detail
				// Note: targetBedtime/targetWakeTime are from DEFAULT constants
				// In future, integrate with userStore.profile for personalized values
				const sleepDetail = fillSleepAnalysis(
					calculateSleepDetail({
						sleepMetrics: state.sleepMetrics,
						targetBedtime: DEFAULT_BED_TIME,
						targetWakeTime: DEFAULT_WAKE_UP_TIME,
						targetDurationMinutes: DEFAULT_TARGET_SLEEP_MINUTES,
						sleepScoreHistory: state.scoreHistories.sleep!,
					}),
				);

				// Calculate Rhythm Detail
				const rhythmDetail = fillRhythmAnalysis(
					calculateRhythmDetail({
						sleepTimingHistory: state.sleepTimingHistory,
						targetBedtime: DEFAULT_BED_TIME,
						targetWakeTime: DEFAULT_WAKE_UP_TIME,
						rhythmScoreHistory: state.scoreHistories.rhythm!,
					}),
				);

				// Calculate Energy Detail
				const energyDetail = fillEnergyAnalysis(
					calculateEnergyDetail({
						recoveryScore: state.dailySnapshot?.scores.recovery ?? 70,
						sleepScore: state.dailySnapshot?.scores.sleep ?? 70,
						activityMetrics: state.activityMetrics,
						weather: state.weather ?? {
							temp: 20,
							condition: "sunny",
							pressure: 1013,
							pressureTrend: "stable",
							uv: 5,
							location: "Unknown",
						},
						targetWakeTime: DEFAULT_WAKE_UP_TIME,
						energyScoreHistory: state.scoreHistories.energy!,
						recoveryScoreHistory: state.scoreHistories.recovery!,
						sleepScoreHistory: state.scoreHistories.sleep!,
					}),
				);

				set({
					detailData: {
						recovery: recoveryDetail,
						sleep: sleepDetail,
						rhythm: rhythmDetail,
						energy: energyDetail,
					},
				});
			},
		}),
		{
			name: "tempo-health-storage",
			storage: createJSONStorage(() => AsyncStorage),
			partialize: (state) => ({
				calibrationStartDate: state.calibrationStartDate,
				calibrationDaysCompleted: state.calibrationDaysCompleted,
				dailySnapshot: state.dailySnapshot,
				lastSnapshotDate: state.lastSnapshotDate,
			}),
		},
	),
);
