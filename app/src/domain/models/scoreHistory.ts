/**
 * Score History Types
 * AsyncStorage に保存するスコア履歴の型定義
 */

/**
 * 日次スコアエントリ
 * 1日分の4つのスコアを保存
 */
export interface DailyScoreEntry {
	/** 日付 (YYYY-MM-DD) */
	date: string;
	/** Recovery スコア (0-100) */
	recovery: number;
	/** Sleep スコア (0-100) */
	sleep: number;
	/** Rhythm スコア (0-100) */
	rhythm: number;
	/** Energy スコア (0-100) */
	energy: number;
}

/**
 * AsyncStorage に保存するスコア履歴のルート構造
 */
export interface StoredScoreHistory {
	/** スコアエントリの配列（最大60日分） */
	scores: DailyScoreEntry[];
	/** 最終更新日時 (ISO8601) */
	lastUpdated: string;
}

/**
 * スコアの種類
 */
export type ScoreType = "recovery" | "sleep" | "rhythm" | "energy";

/**
 * 保存時に使用する日次スコアの入力型
 */
export interface DailyScoresInput {
	recovery: number;
	sleep: number;
	rhythm: number;
	energy: number;
}
