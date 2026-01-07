/**
 * Rhythm（サーカディアンリズム）計算サービス
 * @see docs/specs/metrics_spec.md Section 3
 */

import {
  RhythmPhase,
  RhythmPhaseName,
  RhythmPhaseType,
  CircadianRhythm,
  EnergyCurve,
  EnergyCurvePoint,
} from '../models/rhythm';

// ========================================
// Utility Functions
// ========================================

const parseTime = (timeString: string): Date => {
  const [hours, minutes] = timeString.split(':').map(Number);
  const date = new Date();
  date.setHours(hours, minutes, 0, 0);
  return date;
};

const parseHour = (timeString: string): number => {
  return parseInt(timeString.split(':')[0], 10);
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
  windDownTime: string
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
      definition: { name: 'Wake Window', type: 'transition' },
      start: wake,
      end: addHours(wake, 2),
    },
    {
      definition: { name: 'Peak Focus', type: 'high' },
      start: addHours(wake, 2),
      end: addHours(wake, 5),
    },
    {
      definition: { name: 'Afternoon Dip', type: 'low' },
      start: addHours(wake, 7),
      end: addHours(wake, 9),
    },
    {
      definition: { name: 'Second Wind', type: 'high' },
      start: addHours(wake, 10),
      end: addHours(wake, 13),
    },
    {
      definition: { name: 'Wind Down', type: 'transition' },
      start: addMinutes(sleep, -120),
      end: sleep,
    },
    {
      definition: { name: 'Melatonin Window', type: 'sleep' },
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
  sunset: string
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
  sleepHour: number
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
  windDownTime: string
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





