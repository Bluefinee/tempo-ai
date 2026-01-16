/**
 * Score History Storage Service
 * AsyncStorage を使用したスコア履歴の永続化サービス
 */

import AsyncStorage from "@react-native-async-storage/async-storage";
import type {
	DailyHealthSample,
	HealthMetricHistory,
	HealthMetricType,
} from "../domain/models/healthHistory";
import { DEFAULT_TYPICAL_RANGES } from "../domain/models/healthHistory";
import type {
	DailyScoreEntry,
	DailyScoresInput,
	ScoreType,
	StoredScoreHistory,
} from "../domain/models/scoreHistory";

// =============================================================================
// Constants
// =============================================================================

const STORAGE_KEY = "tempo-score-history";
const MAX_DAYS = 60;

// =============================================================================
// Helper Functions
// =============================================================================

/**
 * 今日の日付を YYYY-MM-DD 形式で取得
 */
const getTodayDateString = (): string => {
	const now = new Date();
	const year = now.getFullYear();
	const month = String(now.getMonth() + 1).padStart(2, "0");
	const day = String(now.getDate()).padStart(2, "0");
	return `${year}-${month}-${day}`;
};

/**
 * 日付文字列を Date オブジェクトに変換
 */
const parseDate = (dateString: string): Date => {
	const [year, month, day] = dateString.split("-").map(Number);
	return new Date(year, month - 1, day);
};

/**
 * ベースライン（平均値）を計算
 */
const calculateBaseline = (values: number[]): number => {
	if (values.length === 0) return 0;
	const sum = values.reduce((acc, v) => acc + v, 0);
	return Math.round((sum / values.length) * 10) / 10;
};

/**
 * 典型範囲（P5-P95）を計算
 */
const calculateTypicalRange = (
	values: number[],
	defaultRange: { min: number; max: number },
): { min: number; max: number; source: "personal" | "default" } => {
	if (values.length < 14) {
		return { ...defaultRange, source: "default" };
	}

	const sorted = [...values].sort((a, b) => a - b);
	const p5Index = Math.floor(sorted.length * 0.05);
	const p95Index = Math.floor(sorted.length * 0.95);

	return {
		min: Math.round(sorted[p5Index] * 10) / 10,
		max: Math.round(sorted[p95Index] * 10) / 10,
		source: "personal",
	};
};

/**
 * ScoreType を HealthMetricType に変換
 */
const scoreTypeToMetricType = (scoreType: ScoreType): HealthMetricType => {
	const mapping: Record<ScoreType, HealthMetricType> = {
		recovery: "recoveryScore",
		sleep: "sleepScore",
		rhythm: "rhythmScore",
		energy: "energyScore",
	};
	return mapping[scoreType];
};

// =============================================================================
// Score History Storage Service
// =============================================================================

export const scoreHistoryStorage = {
	/**
	 * 今日のスコアを保存
	 * 既存の履歴に追記し、60日を超えた古いデータは削除
	 */
	saveTodayScore: async (scores: DailyScoresInput): Promise<void> => {
		try {
			const today = getTodayDateString();
			const existingData = await scoreHistoryStorage.getStoredHistory();

			// 同日のエントリがあれば更新、なければ追加
			const existingIndex = existingData.scores.findIndex(
				(entry) => entry.date === today,
			);

			const newEntry: DailyScoreEntry = {
				date: today,
				recovery: Math.round(scores.recovery),
				sleep: Math.round(scores.sleep),
				rhythm: Math.round(scores.rhythm),
				energy: Math.round(scores.energy),
			};

			if (existingIndex >= 0) {
				existingData.scores[existingIndex] = newEntry;
			} else {
				existingData.scores.push(newEntry);
			}

			// 日付でソート（古い順）
			existingData.scores.sort(
				(a, b) => parseDate(a.date).getTime() - parseDate(b.date).getTime(),
			);

			// 60日を超えた古いデータを削除
			if (existingData.scores.length > MAX_DAYS) {
				existingData.scores = existingData.scores.slice(-MAX_DAYS);
			}

			existingData.lastUpdated = new Date().toISOString();

			await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(existingData));
		} catch (error) {
			console.error("[scoreHistoryStorage] Failed to save score:", error);
			throw error;
		}
	},

	/**
	 * 保存された履歴データを取得（内部用）
	 */
	getStoredHistory: async (): Promise<StoredScoreHistory> => {
		try {
			const data = await AsyncStorage.getItem(STORAGE_KEY);
			if (!data) {
				return {
					scores: [],
					lastUpdated: new Date().toISOString(),
				};
			}
			return JSON.parse(data) as StoredScoreHistory;
		} catch (error) {
			console.error("[scoreHistoryStorage] Failed to get history:", error);
			return {
				scores: [],
				lastUpdated: new Date().toISOString(),
			};
		}
	},

	/**
	 * スコア履歴を取得（エントリ配列）
	 */
	getScoreHistory: async (): Promise<DailyScoreEntry[]> => {
		const data = await scoreHistoryStorage.getStoredHistory();
		return data.scores;
	},

	/**
	 * 特定スコアの履歴を HealthMetricHistory 形式で取得
	 * チャート表示用に使用
	 */
	getScoreHistoryByType: async (
		scoreType: ScoreType,
	): Promise<HealthMetricHistory> => {
		const data = await scoreHistoryStorage.getStoredHistory();
		const metricType = scoreTypeToMetricType(scoreType);

		const samples: DailyHealthSample[] = data.scores.map((entry) => ({
			date: parseDate(entry.date),
			value: entry[scoreType],
		}));

		const values = samples.map((s) => s.value);
		const defaultRange = DEFAULT_TYPICAL_RANGES[metricType];

		return {
			metricType,
			samples,
			baseline: calculateBaseline(values),
			typicalRange: calculateTypicalRange(values, defaultRange),
			lastUpdated: new Date(),
		};
	},

	/**
	 * 全スコアタイプの履歴を一括取得
	 */
	getAllScoreHistories: async (): Promise<{
		recovery: HealthMetricHistory;
		sleep: HealthMetricHistory;
		rhythm: HealthMetricHistory;
		energy: HealthMetricHistory;
	}> => {
		const [recovery, sleep, rhythm, energy] = await Promise.all([
			scoreHistoryStorage.getScoreHistoryByType("recovery"),
			scoreHistoryStorage.getScoreHistoryByType("sleep"),
			scoreHistoryStorage.getScoreHistoryByType("rhythm"),
			scoreHistoryStorage.getScoreHistoryByType("energy"),
		]);

		return { recovery, sleep, rhythm, energy };
	},

	/**
	 * 履歴データの日数を取得
	 */
	getHistoryDaysCount: async (): Promise<number> => {
		const data = await scoreHistoryStorage.getStoredHistory();
		return data.scores.length;
	},

	/**
	 * 履歴をクリア（リセット/デバッグ用）
	 */
	clearHistory: async (): Promise<void> => {
		try {
			await AsyncStorage.removeItem(STORAGE_KEY);
		} catch (error) {
			console.error("[scoreHistoryStorage] Failed to clear history:", error);
			throw error;
		}
	},
};
