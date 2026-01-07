import { describe, expect, it } from 'vitest';
import {
  AdviceRequestSchema,
  HealthMetricsSchema,
  RhythmPhasesSchema,
  ScoresDataSchema,
  UserProfileSchema,
  WeatherDataSchema,
  createFallbackResponse,
  isValidAdviceRequest,
} from './types';

describe('UserProfileSchema (新形式)', () => {
  const validProfile = {
    goals: ['better_sleep', 'more_energy'] as const,
    wakeUpTime: '07:00',
    windDownTime: '23:00',
  };

  it('should validate a valid profile', () => {
    const result = UserProfileSchema.safeParse(validProfile);
    expect(result.success).toBe(true);
  });

  it('should reject invalid goal', () => {
    const result = UserProfileSchema.safeParse({
      ...validProfile,
      goals: ['invalid_goal'],
    });
    expect(result.success).toBe(false);
  });

  it('should reject invalid time format', () => {
    const result = UserProfileSchema.safeParse({
      ...validProfile,
      wakeUpTime: '7:00', // 2桁の時間が必要
    });
    expect(result.success).toBe(false);
  });
});

describe('ScoresDataSchema', () => {
  const validScores = {
    recovery: 70,
    sleep: 85,
    rhythm: 92,
    energy: 78,
  };

  it('should validate valid scores', () => {
    const result = ScoresDataSchema.safeParse(validScores);
    expect(result.success).toBe(true);
  });

  it('should reject score over 100', () => {
    const result = ScoresDataSchema.safeParse({
      ...validScores,
      recovery: 101,
    });
    expect(result.success).toBe(false);
  });

  it('should reject negative score', () => {
    const result = ScoresDataSchema.safeParse({
      ...validScores,
      sleep: -1,
    });
    expect(result.success).toBe(false);
  });
});

describe('HealthMetricsSchema', () => {
  const validMetrics = {
    hrv: {
      current: 82,
      baseline: 77,
      deviation: 6,
    },
    rhr: {
      current: 59,
      baseline: 59,
    },
    sleep: {
      durationMinutes: 428,
      deepSleepMinutes: 105,
      deepSleepPercent: 23,
      remSleepMinutes: 95,
      remSleepPercent: 22,
      bedtime: '23:15',
      wakeTime: '06:45',
      vsTargetBedtime: '+15min',
    },
  };

  it('should validate valid health metrics', () => {
    const result = HealthMetricsSchema.safeParse(validMetrics);
    expect(result.success).toBe(true);
  });

  it('should reject negative duration', () => {
    const result = HealthMetricsSchema.safeParse({
      ...validMetrics,
      sleep: {
        ...validMetrics.sleep,
        durationMinutes: -1,
      },
    });
    expect(result.success).toBe(false);
  });

  it('should reject invalid sleep percent', () => {
    const result = HealthMetricsSchema.safeParse({
      ...validMetrics,
      sleep: {
        ...validMetrics.sleep,
        deepSleepPercent: 101,
      },
    });
    expect(result.success).toBe(false);
  });
});

describe('WeatherDataSchema (新形式)', () => {
  const validWeather = {
    temperature: 20.5,
    pressure: 1013.25,
    pressureTrend: 'stable' as const,
    sunrise: '06:50',
    sunset: '16:48',
  };

  it('should validate valid weather data', () => {
    const result = WeatherDataSchema.safeParse(validWeather);
    expect(result.success).toBe(true);
  });

  it('should reject invalid pressure trend', () => {
    const result = WeatherDataSchema.safeParse({
      ...validWeather,
      pressureTrend: 'invalid',
    });
    expect(result.success).toBe(false);
  });
});

describe('RhythmPhasesSchema', () => {
  const validPhases = {
    peakFocus: {
      start: '09:00',
      end: '12:00',
    },
    afternoonDip: {
      start: '14:00',
      end: '16:00',
    },
    secondWind: {
      start: '17:00',
      end: '19:00',
    },
    windDown: {
      start: '21:00',
      end: '23:00',
    },
  };

  it('should validate valid rhythm phases', () => {
    const result = RhythmPhasesSchema.safeParse(validPhases);
    expect(result.success).toBe(true);
  });

  it('should reject invalid time format', () => {
    const result = RhythmPhasesSchema.safeParse({
      ...validPhases,
      peakFocus: {
        start: '9:00', // 2桁必要
        end: '12:00',
      },
    });
    expect(result.success).toBe(false);
  });
});

describe('AdviceRequestSchema', () => {
  const validRequest = {
    user: {
      goals: ['better_sleep'] as const,
      wakeUpTime: '07:00',
      windDownTime: '23:00',
    },
    scores: {
      recovery: 70,
      sleep: 85,
      rhythm: 92,
      energy: 78,
    },
    healthMetrics: {
      hrv: {
        current: 82,
        baseline: 77,
        deviation: 6,
      },
      rhr: {
        current: 59,
        baseline: 59,
      },
      sleep: {
        durationMinutes: 428,
        deepSleepMinutes: 105,
        deepSleepPercent: 23,
        remSleepMinutes: 95,
        remSleepPercent: 22,
        bedtime: '23:15',
        wakeTime: '06:45',
        vsTargetBedtime: '+15min',
      },
    },
    weather: {
      temperature: 8,
      pressure: 1018,
      pressureTrend: 'stable' as const,
      sunrise: '06:50',
      sunset: '16:48',
      description: '晴れ',
      location: 'Tokyo',
    },
    rhythmPhases: {
      peakFocus: {
        start: '09:00',
        end: '12:00',
      },
      afternoonDip: {
        start: '14:00',
        end: '16:00',
      },
      secondWind: {
        start: '17:00',
        end: '19:00',
      },
      windDown: {
        start: '21:00',
        end: '23:00',
      },
    },
    locale: 'ja',
  };

  it('should validate a valid request', () => {
    const result = AdviceRequestSchema.safeParse(validRequest);
    expect(result.success).toBe(true);
  });

  it('should use default locale when not provided', () => {
    const { locale: _, ...requestWithoutLocale } = validRequest;
    const result = AdviceRequestSchema.safeParse(requestWithoutLocale);
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.locale).toBe('ja');
    }
  });

  it('should reject request missing required fields', () => {
    const { user: _, ...requestWithoutUser } = validRequest;
    const result = AdviceRequestSchema.safeParse(requestWithoutUser);
    expect(result.success).toBe(false);
  });

  it('should reject request missing scores', () => {
    const { scores: _, ...requestWithoutScores } = validRequest;
    const result = AdviceRequestSchema.safeParse(requestWithoutScores);
    expect(result.success).toBe(false);
  });
});

describe('isValidAdviceRequest', () => {
  it('should return true for valid request', () => {
    const validRequest = {
      user: {
        goals: ['better_sleep'],
        wakeUpTime: '07:00',
        windDownTime: '23:00',
      },
      scores: {
        recovery: 70,
        sleep: 85,
        rhythm: 92,
        energy: 78,
      },
      healthMetrics: {
        hrv: { current: 82, baseline: 77 },
        rhr: { current: 59, baseline: 59 },
        sleep: {
          durationMinutes: 428,
          deepSleepMinutes: 105,
          deepSleepPercent: 23,
          remSleepMinutes: 95,
          remSleepPercent: 22,
        },
      },
      weather: {
        temperature: 8,
        pressure: 1018,
        pressureTrend: 'stable' as const,
        sunrise: '06:50',
        sunset: '16:48',
      },
      rhythmPhases: {
        peakFocus: { start: '09:00', end: '12:00' },
        afternoonDip: { start: '14:00', end: '16:00' },
        secondWind: { start: '17:00', end: '19:00' },
        windDown: { start: '21:00', end: '23:00' },
      },
    };
    expect(isValidAdviceRequest(validRequest)).toBe(true);
  });

  it('should return false for invalid request', () => {
    expect(isValidAdviceRequest(null)).toBe(false);
    expect(isValidAdviceRequest({})).toBe(false);
  });
});

describe('createFallbackResponse', () => {
  it('should create fallback response with new format', () => {
    const response = createFallbackResponse();
    expect(response.todayInsight.title).toBe('New Day');
    expect(response.todayInsight.summary).toBeTruthy();
    expect(response.todayOneThing.icon).toBe('breathing');
    expect(response.todayOneThing.action).toBeTruthy();
    expect(response.todayOneThing.benefits).toHaveLength(3);
    expect(response.todayOneThing.howToDoIt).toHaveLength(3);
    expect(response.relatedInsight.label).toBe('Tip');
  });
});
