import { apiClient } from "../api/client";
import type { AdviceRequest, AdviceResponse } from "../api/types";
import { DATA_SOURCE_CONFIG } from "../config/dataSource";
import { SLEEP_TIMING_DEFAULTS } from "../constants/environmentConstants";
import {
	createMockRealtimeMetrics,
	MOCK_ACTIVITY_METRICS,
	MOCK_AI_RESPONSE,
	MOCK_ENVIRONMENT_DATA,
	MOCK_HRV_METRICS,
	MOCK_RHYTHM_ANALYSIS,
	MOCK_SLEEP_METRICS,
	MOCK_WEATHER,
} from "../constants/mockData";
import {
	generateDailySamples,
	generateDateRange,
	getMockMetricHistory,
} from "../constants/mockDataFactory";
import type {
	ActivityMetrics,
	EnvironmentData,
	HealthMetricHistory,
	HealthTimeRange,
	HRVMetrics,
	RealtimeMetrics,
	RHRMetrics,
	RhythmAnalysis,
	SimpleWeatherData,
	SleepMetrics,
	SleepTimingHistory,
	SleepTimingSample,
} from "../domain/models";
import {
	calculateMoonPhase,
	formatTimeFromISO,
	getUVLevelString,
} from "../domain/models/environment";
import { t } from "../i18n";

/**
 * Score type for historical data queries
 */
type ScoreType = "recovery" | "sleep" | "rhythm" | "energy";

/**
 * データソースアダプター
 * Mock と実データを統一インターフェースで提供
 */
class DataSourceAdapter {
	/**
	 * 睡眠メトリクスを取得
	 */
	async getSleepMetrics(): Promise<SleepMetrics> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return MOCK_SLEEP_METRICS;
		}
		// TODO: 実装 - HealthKitService.fetchSleepMetrics()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * HRVメトリクスを取得
	 */
	async getHRVMetrics(): Promise<HRVMetrics> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return MOCK_HRV_METRICS;
		}
		// TODO: 実装 - HealthKitService.fetchHRVMetrics()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * アクティビティメトリクスを取得
	 */
	async getActivityMetrics(): Promise<ActivityMetrics> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return MOCK_ACTIVITY_METRICS;
		}
		// TODO: 実装 - HealthKitService.fetchActivityMetrics()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * リズム分析を取得
	 */
	async getRhythmAnalysis(): Promise<RhythmAnalysis> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return MOCK_RHYTHM_ANALYSIS;
		}
		// TODO: 実装 - HealthKitService.fetchRhythmAnalysis()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * リアルタイムメトリクスを取得（HRV, RHR, 呼吸数, SpO2, 体温）
	 */
	async getRealtimeMetrics(): Promise<RealtimeMetrics> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return createMockRealtimeMetrics();
		}
		// TODO: 実装 - HealthKitService.fetchRealtimeMetrics()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * 天気データを取得
	 */
	async getWeather(lat: number, lon: number): Promise<SimpleWeatherData> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_WEATHER) {
			return MOCK_WEATHER;
		}

		const result = await apiClient.getWeather(lat, lon);
		if (!result.success) {
			throw new Error("Failed to fetch weather data");
		}

		return {
			temp: result.data.temperature,
			condition: result.data.description || "sunny",
			pressure: result.data.pressure,
			pressureTrend: result.data.pressureTrend,
			uv: 0, // TODO: UV index is not available yet
			location: result.data.location || t("common.currentLocation"),
		};
	}

	/**
	 * 環境データを取得（日の出/日の入り、天気、気圧、UV、月相）
	 * Rhythm画面で使用
	 */
	async getEnvironmentData(lat: number, lon: number): Promise<EnvironmentData> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_WEATHER) {
			return MOCK_ENVIRONMENT_DATA;
		}

		// 実API: 天気APIから取得したデータをEnvironmentData形式に変換
		const result = await apiClient.getWeather(lat, lon);
		if (!result.success) {
			throw new Error("Failed to fetch environment data");
		}

		const {
			temperature,
			pressure,
			pressureTrend,
			sunrise,
			sunset,
			description,
			location,
		} = result.data;

		// ISO8601形式の時刻をパース
		const sunriseFormatted = formatTimeFromISO(sunrise);
		const sunsetFormatted = formatTimeFromISO(sunset);

		// Date形式に変換
		const sunriseTime = new Date(sunrise);
		const sunsetTime = new Date(sunset);

		// 日照時間を計算
		const dayLengthMinutes = Math.round(
			(sunsetTime.getTime() - sunriseTime.getTime()) / 60000,
		);

		// 月相を計算
		const { phase, illumination } = calculateMoonPhase(new Date());

		return {
			sunrise: sunriseFormatted,
			sunset: sunsetFormatted,
			sunriseTime,
			sunsetTime,
			dayLengthMinutes,
			location: location || t("common.currentLocation"),
			weather: {
				condition: description || "Clear",
				temperature,
				humidity: 50, // TODO: APIから取得できるようになったら更新
			},
			pressure: {
				value: pressure,
				trend: pressureTrend,
				change24h: 0, // TODO: 24時間変化の計算は後続の実装で対応
			},
			uv: {
				index: 3, // TODO: APIから取得できるようになったら更新
				level: getUVLevelString(3),
			},
			moonPhase: {
				phase,
				illumination,
			},
		};
	}

	/**
	 * AIアドバイスを取得
	 */
	async getAIAdvice(request: AdviceRequest): Promise<AdviceResponse> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_AI) {
			return MOCK_AI_RESPONSE;
		}

		const result = await apiClient.generateAdvice(request);
		if (!result.success) {
			throw new Error("Failed to generate AI advice");
		}

		return result.data;
	}

	// ===========================================================================
	// Historical Data Methods (for Detail Screens)
	// ===========================================================================

	/**
	 * HRV履歴データを取得
	 * @param timeRange - 時間範囲（7D/30D/60D）
	 */
	async getHRVHistory(
		timeRange: HealthTimeRange,
	): Promise<HealthMetricHistory> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return getMockMetricHistory("hrv", timeRange);
		}
		// TODO: 実装 - HealthKitService.fetchHRVHistory()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * RHR（安静時心拍数）履歴データを取得
	 * @param timeRange - 時間範囲（7D/30D/60D）
	 */
	async getRHRHistory(
		timeRange: HealthTimeRange,
	): Promise<HealthMetricHistory> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return getMockMetricHistory("rhr", timeRange);
		}
		// TODO: 実装 - HealthKitService.fetchRHRHistory()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * 呼吸数履歴データを取得
	 * @param timeRange - 時間範囲（7D/30D/60D）
	 */
	async getRespiratoryHistory(
		timeRange: HealthTimeRange,
	): Promise<HealthMetricHistory> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return getMockMetricHistory("respiratory", timeRange);
		}
		// TODO: 実装 - HealthKitService.fetchRespiratoryHistory()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * SpO2履歴データを取得
	 * @param timeRange - 時間範囲（7D/30D/60D）
	 */
	async getSpO2History(
		timeRange: HealthTimeRange,
	): Promise<HealthMetricHistory> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return getMockMetricHistory("spo2", timeRange);
		}
		// TODO: 実装 - HealthKitService.fetchSpO2History()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * 手首温度履歴データを取得
	 * @param timeRange - 時間範囲（7D/30D/60D）
	 */
	async getWristTempHistory(
		timeRange: HealthTimeRange,
	): Promise<HealthMetricHistory> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return getMockMetricHistory("wristTemp", timeRange);
		}
		// TODO: 実装 - HealthKitService.fetchWristTempHistory()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * RHRメトリクスを取得（今日の値とベースライン）
	 */
	async getRHRMetrics(): Promise<RHRMetrics> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			// モック: 今日の値と60日平均を生成
			const history = getMockMetricHistory("rhr", "60D");
			const todayValue =
				history.samples.length > 0
					? history.samples[history.samples.length - 1].value
					: 60;
			return {
				value: todayValue,
				baseline30d: history.baseline,
			};
		}
		// TODO: 実装 - HealthKitService.fetchRHRMetrics()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * スコア履歴データを取得
	 * @param scoreType - スコアの種類（recovery/sleep/rhythm/energy）
	 * @param timeRange - 時間範囲（7D/30D/60D）
	 */
	async getScoreHistory(
		scoreType: ScoreType,
		timeRange: HealthTimeRange,
	): Promise<HealthMetricHistory> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			const metricType = `${scoreType}Score` as const;
			return getMockMetricHistory(metricType, timeRange);
		}
		// TODO: 実装 - 保存されたスコア履歴から取得
		throw new Error("Real score history not yet implemented");
	}

	/**
	 * 睡眠タイミング履歴データを取得（Rhythm計算用）
	 * @param timeRange - 時間範囲（7D/30D/60D）
	 */
	async getSleepTimingHistory(
		timeRange: HealthTimeRange,
	): Promise<SleepTimingHistory> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return this.generateMockSleepTimingHistory(timeRange);
		}
		// TODO: 実装 - HealthKitService.fetchSleepTimingHistory()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * 睡眠履歴データを取得（Sleep詳細用）
	 * @param timeRange - 時間範囲（7D/30D/60D）
	 */
	async getSleepHistory(
		timeRange: HealthTimeRange,
	): Promise<HealthMetricHistory> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			return getMockMetricHistory("sleepScore", timeRange);
		}
		// TODO: 実装 - HealthKitService.fetchSleepHistory()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	/**
	 * アクティビティ履歴データを取得（Energy詳細用）
	 * @param timeRange - 時間範囲（7D/30D/60D）
	 */
	async getActivityHistory(
		timeRange: HealthTimeRange,
	): Promise<HealthMetricHistory> {
		if (DATA_SOURCE_CONFIG.USE_MOCK_HEALTHKIT) {
			// アクティビティはスコア形式で返す（0-100）
			return getMockMetricHistory("energyScore", timeRange);
		}
		// TODO: 実装 - HealthKitService.fetchActivityHistory()
		throw new Error("Real HealthKit integration not yet implemented");
	}

	// ===========================================================================
	// Private Helper Methods
	// ===========================================================================

	/**
	 * モック用の睡眠タイミング履歴を生成
	 * @param timeRange - 時間範囲
	 */
	private generateMockSleepTimingHistory(
		timeRange: HealthTimeRange,
	): SleepTimingHistory {
		const days = timeRange === "7D" ? 7 : timeRange === "30D" ? 30 : 60;
		const dates = generateDateRange(days);

		// 基準時刻と変動幅を定数から取得
		const { BASE_BEDTIME_MINUTES, BASE_WAKE_MINUTES, VARIANCE_MINUTES } =
			SLEEP_TIMING_DEFAULTS;

		// シード値を使用して一貫性のあるデータを生成
		const bedtimeVariations = generateDailySamples(
			0,
			VARIANCE_MINUTES,
			days,
			301,
		);
		const wakeVariations = generateDailySamples(0, VARIANCE_MINUTES, days, 302);

		const samples: SleepTimingSample[] = dates.map((date, index) => {
			// 就寝時刻を計算（前日の夜）
			const bedtimeOffsetMinutes = bedtimeVariations[index].value;
			const actualBedtimeMinutes = BASE_BEDTIME_MINUTES + bedtimeOffsetMinutes;

			const bedtime = new Date(date);
			bedtime.setDate(bedtime.getDate() - 1); // 前日
			bedtime.setHours(
				Math.floor(actualBedtimeMinutes / 60),
				actualBedtimeMinutes % 60,
				0,
				0,
			);

			// 起床時刻を計算
			const wakeOffsetMinutes = wakeVariations[index].value;
			const actualWakeMinutes = BASE_WAKE_MINUTES + wakeOffsetMinutes;

			const wakeTime = new Date(date);
			wakeTime.setHours(
				Math.floor(actualWakeMinutes / 60),
				actualWakeMinutes % 60,
				0,
				0,
			);

			// 睡眠時間を計算（分）
			const durationMinutes = Math.round(
				(wakeTime.getTime() - bedtime.getTime()) / (1000 * 60),
			);

			return {
				date,
				bedtime,
				wakeTime,
				durationMinutes: Math.max(
					SLEEP_TIMING_DEFAULTS.MIN_DURATION_MINUTES,
					Math.min(SLEEP_TIMING_DEFAULTS.MAX_DURATION_MINUTES, durationMinutes),
				),
			};
		});

		return { samples };
	}
}

// シングルトンインスタンス
export const dataSourceAdapter = new DataSourceAdapter();
