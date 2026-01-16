/**
 * Rhythm（サーカディアンリズム）計算サービス
 * @see docs/specs/metrics_spec.md Section 3
 */

import type {
	CircadianRhythm,
	EnergyCurve,
	EnergyCurvePoint,
	RhythmPhase,
	RhythmPhaseName,
	RhythmPhaseType,
} from "../models/rhythm";

// ========================================
// Utility Functions
// ========================================

const parseTime = (timeString: string): Date => {
	const [hours, minutes] = timeString.split(":").map(Number);
	const date = new Date();
	date.setHours(hours, minutes, 0, 0);
	return date;
};

const parseHour = (timeString: string): number => {
	return parseInt(timeString.split(":")[0], 10);
};

const addHours = (date: Date, hours: number): Date => {
	return new Date(date.getTime() + hours * 60 * 60 * 1000);
};

const addMinutes = (date: Date, minutes: number): Date => {
	return new Date(date.getTime() + minutes * 60 * 1000);
};

const isTimeInRange = (time: Date, start: Date, end: Date): boolean => {
	const timeMs = time.getTime();
	const startMs = start.getTime();
	const endMs = end.getTime();

	if (startMs <= endMs) {
		return timeMs >= startMs && timeMs < endMs;
	}
	// 日付をまたぐ場合
	return timeMs >= startMs || timeMs < endMs;
};

const getMinutesBetween = (from: Date, to: Date): number => {
	return Math.round((to.getTime() - from.getTime()) / (1000 * 60));
};

// ========================================
// Phase Calculation
// ========================================

interface PhaseDefinition {
	name: RhythmPhaseName;
	type: RhythmPhaseType;
}

export const calculatePhases = (
	wakeUpTime: string,
	windDownTime: string,
): readonly RhythmPhase[] => {
	const wake = parseTime(wakeUpTime);
	const sleep = parseTime(windDownTime);
	const now = new Date();

	const phaseDefinitions: {
		definition: PhaseDefinition;
		start: Date;
		end: Date;
	}[] = [
		{
			definition: { name: "Wake Window", type: "transition" },
			start: wake,
			end: addHours(wake, 2),
		},
		{
			definition: { name: "Peak Focus", type: "high" },
			start: addHours(wake, 2),
			end: addHours(wake, 5),
		},
		{
			definition: { name: "Afternoon Dip", type: "low" },
			start: addHours(wake, 7),
			end: addHours(wake, 9),
		},
		{
			definition: { name: "Second Wind", type: "high" },
			start: addHours(wake, 10),
			end: addHours(wake, 13),
		},
		{
			definition: { name: "Wind Down", type: "transition" },
			start: addMinutes(sleep, -120),
			end: sleep,
		},
		{
			definition: { name: "Melatonin Window", type: "sleep" },
			start: addMinutes(sleep, -30),
			end: wake,
		},
	];

	return phaseDefinitions.map(({ definition, start, end }) => ({
		name: definition.name,
		type: definition.type,
		start,
		end,
		isCurrent: isTimeInRange(now, start, end),
	}));
};

// ========================================
// Circadian Rhythm
// ========================================

export const calculateCircadianRhythm = (
	wakeUpTime: string,
	windDownTime: string,
	sunrise: string,
	sunset: string,
): CircadianRhythm => {
	const phases = calculatePhases(wakeUpTime, windDownTime);
	const now = new Date();

	const currentPhase = phases.find((p) => p.isCurrent) ?? null;

	// 次のフェーズを見つける
	let nextPhase: RhythmPhase | null = null;
	let minutesToNextPhase: number | null = null;

	if (currentPhase) {
		const currentIndex = phases.findIndex((p) => p.name === currentPhase.name);
		const nextIndex = (currentIndex + 1) % phases.length;
		nextPhase = phases[nextIndex];
		minutesToNextPhase = getMinutesBetween(now, currentPhase.end);
	}

	return {
		phases,
		currentPhase,
		nextPhase,
		minutesToNextPhase,
		sunrise,
		sunset,
	};
};

// ========================================
// Energy Curve (for Graph)
// ========================================

const getEnergyLevel = (
	hoursSinceWake: number,
	wakeHour: number,
	sleepHour: number,
): number => {
	const awakeHours = (sleepHour - wakeHour + 24) % 24;

	// 睡眠中
	if (hoursSinceWake < 0 || hoursSinceWake > awakeHours) {
		return 10;
	}

	// Wake Window (0-2h): 30→60に上昇
	if (hoursSinceWake < 2) {
		return 30 + (hoursSinceWake / 2) * 30;
	}

	// Peak Focus (2-5h): 60→90に上昇
	if (hoursSinceWake < 5) {
		return 60 + ((hoursSinceWake - 2) / 3) * 30;
	}

	// Post-Peak (5-7h): 90→70に下降
	if (hoursSinceWake < 7) {
		return 90 - ((hoursSinceWake - 5) / 2) * 20;
	}

	// Afternoon Dip (7-9h): 70→50に下降
	if (hoursSinceWake < 9) {
		return 70 - ((hoursSinceWake - 7) / 2) * 20;
	}

	// Recovery (9-10h): 50→70に上昇
	if (hoursSinceWake < 10) {
		return 50 + (hoursSinceWake - 9) * 20;
	}

	// Second Wind (10-13h): 70→80
	if (hoursSinceWake < 13) {
		return 70 + ((hoursSinceWake - 10) / 3) * 10;
	}

	// Wind Down (13h+): 80→30に下降
	const hoursUntilSleep = awakeHours - hoursSinceWake;
	if (hoursUntilSleep > 0) {
		return 30 + (hoursUntilSleep / 3) * 20;
	}

	return 30;
};

export const calculateEnergyCurve = (
	wakeUpTime: string,
	windDownTime: string,
): EnergyCurve => {
	const wakeHour = parseHour(wakeUpTime);
	const sleepHour = parseHour(windDownTime);

	const curve: EnergyCurvePoint[] = [];

	for (let h = 0; h < 24; h++) {
		const hoursSinceWake = (h - wakeHour + 24) % 24;
		curve.push({
			hour: h,
			level: Math.round(getEnergyLevel(hoursSinceWake, wakeHour, sleepHour)),
		});
	}

	return curve;
};

// ========================================
// RhythmDataPoint Conversion
// ========================================

/**
 * RhythmDataPoint型（チャート表示用）
 */
export interface RhythmDataPoint {
	/** 表示用時刻文字列（"6 AM"形式） */
	readonly time: string;
	/** 時（0-24） */
	readonly hour: number;
	/** エネルギーレベル（0-100） */
	readonly energy: number;
	/** ラベル（"Peak", "Dip"など） */
	readonly label?: string;
}

/**
 * 時刻を12時間形式の文字列に変換
 * @param hour 24時間形式の時（0-24）
 * @returns "6 AM"形式の文字列
 */
const formatHourTo12HString = (hour: number): string => {
	const normalizedHour = hour === 24 ? 0 : hour;
	const isAM = normalizedHour < 12;
	const displayHour =
		normalizedHour === 0
			? 12
			: normalizedHour === 12
				? 12
				: normalizedHour > 12
					? normalizedHour - 12
					: normalizedHour;
	const period = isAM ? "AM" : "PM";
	return `${displayHour} ${period}`;
};

/**
 * EnergyCurveをRhythmDataPoint配列に変換
 * チャート表示用のデータ形式に変換する
 *
 * @param energyCurve - calculateEnergyCurve()で生成されたエネルギーカーブ
 * @param startHour - 表示開始時刻（デフォルト: 6）
 * @param endHour - 表示終了時刻（デフォルト: 24）
 * @returns RhythmDataPoint配列
 */
export const convertEnergyCurveToRhythmData = (
	energyCurve: EnergyCurve,
	startHour: number = 6,
	endHour: number = 24,
): readonly RhythmDataPoint[] => {
	// ピークとディップを検出
	let peakHour = startHour;
	let peakLevel = 0;
	let dipHour = startHour;
	let dipLevel = 100;

	// startHour～endHourの範囲でピーク/ディップを検出
	for (const point of energyCurve) {
		if (point.hour >= startHour && point.hour <= endHour) {
			if (point.level > peakLevel) {
				peakLevel = point.level;
				peakHour = point.hour;
			}
			// ディップは午後（13-16時）に限定
			if (point.hour >= 13 && point.hour <= 16 && point.level < dipLevel) {
				dipLevel = point.level;
				dipHour = point.hour;
			}
		}
	}

	// EnergyCurveをRhythmDataPointに変換
	return energyCurve
		.filter((point) => point.hour >= startHour && point.hour <= endHour)
		.map((point) => {
			let label: string | undefined;

			// ピークにラベル付与
			if (point.hour === peakHour && point.level >= 80) {
				label = "Peak";
			}
			// ディップにラベル付与
			else if (point.hour === dipHour && point.level <= 60) {
				label = "Dip";
			}

			return {
				time: formatHourTo12HString(point.hour),
				hour: point.hour,
				energy: point.level,
				label,
			};
		});
};

/**
 * デフォルトのRhythmDataPoint（フォールバック用）
 * healthStoreのenergyCurveがnullの場合に使用
 */
export const DEFAULT_RHYTHM_DATA: readonly RhythmDataPoint[] = [
	{ time: "6 AM", hour: 6, energy: 30 },
	{ time: "7 AM", hour: 7, energy: 45 },
	{ time: "8 AM", hour: 8, energy: 65 },
	{ time: "9 AM", hour: 9, energy: 80 },
	{ time: "10 AM", hour: 10, energy: 90, label: "Peak" },
	{ time: "11 AM", hour: 11, energy: 92 },
	{ time: "12 PM", hour: 12, energy: 85 },
	{ time: "1 PM", hour: 13, energy: 70 },
	{ time: "2 PM", hour: 14, energy: 55 },
	{ time: "3 PM", hour: 15, energy: 50, label: "Dip" },
	{ time: "4 PM", hour: 16, energy: 60 },
	{ time: "5 PM", hour: 17, energy: 75 },
	{ time: "6 PM", hour: 18, energy: 85 },
	{ time: "7 PM", hour: 19, energy: 80 },
	{ time: "8 PM", hour: 20, energy: 60 },
	{ time: "9 PM", hour: 21, energy: 40 },
	{ time: "10 PM", hour: 22, energy: 25 },
	{ time: "11 PM", hour: 23, energy: 15 },
	{ time: "12 AM", hour: 24, energy: 10 },
];
