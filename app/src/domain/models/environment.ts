/**
 * 環境データの型定義
 * Rhythm画面で使用する日の出/日の入り、天気、気圧、UV、月相などの環境情報
 */

import type { PressureTrend } from "./weather";

/**
 * 月相タイプ
 */
export type MoonPhaseType =
	| "New Moon"
	| "Waxing Crescent"
	| "First Quarter"
	| "Waxing Gibbous"
	| "Full Moon"
	| "Waning Gibbous"
	| "Last Quarter"
	| "Waning Crescent";

/**
 * UVレベルタイプ
 */
export type UVLevelType = "Low" | "Moderate" | "High" | "Very High" | "Extreme";

/**
 * 環境データ
 * Rhythm画面で表示する包括的な環境情報
 */
export interface EnvironmentData {
	/** 日の出時刻（"6:50"形式） */
	readonly sunrise: string;
	/** 日の入り時刻（"16:48"形式） */
	readonly sunset: string;
	/** 日の出時刻（計算用Date） */
	readonly sunriseTime: Date;
	/** 日の入り時刻（計算用Date） */
	readonly sunsetTime: Date;
	/** 日照時間（分） */
	readonly dayLengthMinutes: number;
	/** 位置情報（都市名） */
	readonly location: string;
	/** 天気情報 */
	readonly weather: {
		/** 天気状態（Clear, Cloudy等） */
		readonly condition: string;
		/** 気温（°C） */
		readonly temperature: number;
		/** 湿度（%） */
		readonly humidity: number;
	};
	/** 気圧情報 */
	readonly pressure: {
		/** 気圧（hPa） */
		readonly value: number;
		/** 気圧トレンド */
		readonly trend: PressureTrend;
		/** 24時間変化（hPa） */
		readonly change24h: number;
	};
	/** UVインデックス */
	readonly uv: {
		/** UVインデックス値（0-11+） */
		readonly index: number;
		/** UVレベル */
		readonly level: UVLevelType;
	};
	/** 月相情報 */
	readonly moonPhase: {
		/** 月相名 */
		readonly phase: MoonPhaseType;
		/** 照度（0-100%） */
		readonly illumination: number;
	};
}

/**
 * UVインデックスからレベル文字列を取得
 */
export const getUVLevelString = (index: number): UVLevelType => {
	if (index <= 2) return "Low";
	if (index <= 5) return "Moderate";
	if (index <= 7) return "High";
	if (index <= 10) return "Very High";
	return "Extreme";
};

/**
 * 日付から月相を計算
 * @param date 日付
 * @returns 月相タイプと照度
 */
export const calculateMoonPhase = (
	date: Date,
): { phase: MoonPhaseType; illumination: number } => {
	// 月の周期（約29.53日）
	const LUNAR_CYCLE = 29.53;

	// 基準日（新月: 2000年1月6日）
	const referenceNewMoon = new Date(2000, 0, 6, 18, 14, 0);

	// 経過日数
	const daysSinceReference =
		(date.getTime() - referenceNewMoon.getTime()) / (1000 * 60 * 60 * 24);

	// 月齢（0-29.53）
	const lunarAge =
		((daysSinceReference % LUNAR_CYCLE) + LUNAR_CYCLE) % LUNAR_CYCLE;

	// 照度（0-100%）
	const illumination = Math.round(
		50 * (1 - Math.cos((2 * Math.PI * lunarAge) / LUNAR_CYCLE)),
	);

	// 月相判定
	let phase: MoonPhaseType;
	if (lunarAge < 1.85) {
		phase = "New Moon";
	} else if (lunarAge < 7.38) {
		phase = "Waxing Crescent";
	} else if (lunarAge < 9.23) {
		phase = "First Quarter";
	} else if (lunarAge < 14.77) {
		phase = "Waxing Gibbous";
	} else if (lunarAge < 16.61) {
		phase = "Full Moon";
	} else if (lunarAge < 22.15) {
		phase = "Waning Gibbous";
	} else if (lunarAge < 24.0) {
		phase = "Last Quarter";
	} else {
		phase = "Waning Crescent";
	}

	return { phase, illumination };
};

/**
 * ISO8601形式の時刻文字列を"H:MM"形式に変換
 * @param isoString ISO8601形式の文字列（例: "2025-01-01T06:50:00+09:00"）
 * @returns "H:MM"形式の文字列（例: "6:50"）
 */
export const formatTimeFromISO = (isoString: string): string => {
	try {
		const date = new Date(isoString);
		if (Number.isNaN(date.getTime())) {
			return isoString; // 既に"6:50"形式の場合はそのまま返す
		}
		const hours = date.getHours();
		const minutes = date.getMinutes().toString().padStart(2, "0");
		return `${hours}:${minutes}`;
	} catch {
		return isoString;
	}
};
