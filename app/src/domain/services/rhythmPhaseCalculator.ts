import type { RhythmPhases } from "../../api/types";
import { CIRCADIAN_PHASE_OFFSETS } from "../../constants/rhythmConstants";

/**
 * サーカディアンリズムのフェーズを計算
 */
export interface RhythmPhaseInput {
	wakeUpTime: Date; // 起床時刻
	bedtime: Date; // 就寝時刻
}

export const calculateRhythmPhases = (
	input: RhythmPhaseInput,
): RhythmPhases => {
	const { wakeUpTime, bedtime } = input;

	// 起床時刻を基準にフェーズを計算（定数参照）
	const peakFocusStart = addHours(
		wakeUpTime,
		CIRCADIAN_PHASE_OFFSETS.peakFocus.startOffset,
	);
	const peakFocusEnd = addHours(
		wakeUpTime,
		CIRCADIAN_PHASE_OFFSETS.peakFocus.endOffset,
	);

	const afternoonDipStart = addHours(
		wakeUpTime,
		CIRCADIAN_PHASE_OFFSETS.afternoonDip.startOffset,
	);
	const afternoonDipEnd = addHours(
		wakeUpTime,
		CIRCADIAN_PHASE_OFFSETS.afternoonDip.endOffset,
	);

	const secondWindStart = addHours(
		wakeUpTime,
		CIRCADIAN_PHASE_OFFSETS.secondWind.startOffset,
	);
	const secondWindEnd = addHours(
		wakeUpTime,
		CIRCADIAN_PHASE_OFFSETS.secondWind.endOffset,
	);

	const windDownStart = addHours(
		bedtime,
		-CIRCADIAN_PHASE_OFFSETS.windDown.beforeBedtime,
	);
	const windDownEnd = bedtime;

	return {
		peakFocus: {
			start: formatTime(peakFocusStart),
			end: formatTime(peakFocusEnd),
		},
		afternoonDip: {
			start: formatTime(afternoonDipStart),
			end: formatTime(afternoonDipEnd),
		},
		secondWind: {
			start: formatTime(secondWindStart),
			end: formatTime(secondWindEnd),
		},
		windDown: {
			start: formatTime(windDownStart),
			end: formatTime(windDownEnd),
		},
	};
};

// Helper functions
const addHours = (date: Date, hours: number): Date => {
	return new Date(date.getTime() + hours * 60 * 60 * 1000);
};

const formatTime = (date: Date): string => {
	const hours = date.getHours().toString().padStart(2, "0");
	const minutes = date.getMinutes().toString().padStart(2, "0");
	return `${hours}:${minutes}`;
};
