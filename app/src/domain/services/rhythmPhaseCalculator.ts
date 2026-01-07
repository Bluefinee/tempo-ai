import type { RhythmPhases } from '../../api/types';

/**
 * サーカディアンリズムのフェーズを計算
 */
export interface RhythmPhaseInput {
  wakeUpTime: Date; // 起床時刻
  bedtime: Date; // 就寝時刻
}

export const calculateRhythmPhases = (
  input: RhythmPhaseInput
): RhythmPhases => {
  const { wakeUpTime, bedtime } = input;

  // 起床時刻を基準にフェーズを計算
  const peakFocusStart = addHours(wakeUpTime, 2); // 起床 + 2h
  const peakFocusEnd = addHours(wakeUpTime, 5); // 起床 + 5h

  const afternoonDipStart = addHours(wakeUpTime, 7); // 起床 + 7h
  const afternoonDipEnd = addHours(wakeUpTime, 9); // 起床 + 9h

  const secondWindStart = addHours(wakeUpTime, 10); // 起床 + 10h
  const secondWindEnd = addHours(wakeUpTime, 13); // 起床 + 13h

  const windDownStart = addHours(bedtime, -2); // 就寝 - 2h
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
  const hours = date.getHours().toString().padStart(2, '0');
  const minutes = date.getMinutes().toString().padStart(2, '0');
  return `${hours}:${minutes}`;
};

