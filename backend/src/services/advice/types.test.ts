import { describe, expect, it } from 'vitest';
import {
  AdviceRequestSchema,
  ContextSchema,
  HealthDataSchema,
  LocationSchema,
  ScoresSchema,
  UserProfileSchema,
  WeatherSchema,
} from './types';

describe('UserProfileSchema', () => {
  const validProfile = {
    nickname: 'マサ',
    age: 28,
    gender: 'male' as const,
    chronotype: 'morning' as const,
    targetBedtime: '23:00',
  };

  it('should validate a valid profile', () => {
    const result = UserProfileSchema.safeParse(validProfile);
    expect(result.success).toBe(true);
  });

  it('should validate a profile with optional fields', () => {
    const result = UserProfileSchema.safeParse({
      ...validProfile,
      occupation: 'deskWork',
      exerciseFrequency: 'twiceWeek',
    });
    expect(result.success).toBe(true);
  });

  it('should reject empty nickname', () => {
    const result = UserProfileSchema.safeParse({
      ...validProfile,
      nickname: '',
    });
    expect(result.success).toBe(false);
  });

  it('should reject age 0', () => {
    const result = UserProfileSchema.safeParse({
      ...validProfile,
      age: 0,
    });
    expect(result.success).toBe(false);
  });

  it('should reject age 121', () => {
    const result = UserProfileSchema.safeParse({
      ...validProfile,
      age: 121,
    });
    expect(result.success).toBe(false);
  });

  it('should reject invalid gender', () => {
    const result = UserProfileSchema.safeParse({
      ...validProfile,
      gender: 'invalid',
    });
    expect(result.success).toBe(false);
  });

  it('should reject invalid chronotype', () => {
    const result = UserProfileSchema.safeParse({
      ...validProfile,
      chronotype: 'invalid',
    });
    expect(result.success).toBe(false);
  });

  it('should reject invalid occupation', () => {
    const result = UserProfileSchema.safeParse({
      ...validProfile,
      occupation: 'invalid',
    });
    expect(result.success).toBe(false);
  });
});

describe('ScoresSchema', () => {
  it('should validate valid scores', () => {
    const result = ScoresSchema.safeParse({
      autonomic: 85,
      sleep: 78,
      rhythm: 88,
      activity: 68,
    });
    expect(result.success).toBe(true);
  });

  it('should reject score below 0', () => {
    const result = ScoresSchema.safeParse({
      autonomic: -1,
      sleep: 78,
      rhythm: 88,
      activity: 68,
    });
    expect(result.success).toBe(false);
  });

  it('should reject score above 100', () => {
    const result = ScoresSchema.safeParse({
      autonomic: 101,
      sleep: 78,
      rhythm: 88,
      activity: 68,
    });
    expect(result.success).toBe(false);
  });
});

describe('LocationSchema', () => {
  it('should validate valid location', () => {
    const result = LocationSchema.safeParse({
      latitude: 35.6762,
      longitude: 139.6503,
      city: 'Tokyo',
    });
    expect(result.success).toBe(true);
  });

  it('should reject latitude below -90', () => {
    const result = LocationSchema.safeParse({
      latitude: -91,
      longitude: 139.6503,
      city: 'Tokyo',
    });
    expect(result.success).toBe(false);
  });

  it('should reject latitude above 90', () => {
    const result = LocationSchema.safeParse({
      latitude: 91,
      longitude: 139.6503,
      city: 'Tokyo',
    });
    expect(result.success).toBe(false);
  });

  it('should reject longitude below -180', () => {
    const result = LocationSchema.safeParse({
      latitude: 35.6762,
      longitude: -181,
      city: 'Tokyo',
    });
    expect(result.success).toBe(false);
  });

  it('should reject longitude above 180', () => {
    const result = LocationSchema.safeParse({
      latitude: 35.6762,
      longitude: 181,
      city: 'Tokyo',
    });
    expect(result.success).toBe(false);
  });
});

describe('ContextSchema', () => {
  it('should validate valid context', () => {
    const result = ContextSchema.safeParse({
      currentTime: '07:15',
      dayOfWeek: '水曜日',
      todayMode: 'normal',
    });
    expect(result.success).toBe(true);
  });

  it('should use default todayMode when not provided', () => {
    const result = ContextSchema.safeParse({
      currentTime: '07:15',
      dayOfWeek: '水曜日',
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.todayMode).toBe('normal');
    }
  });

  it('should validate mood in range 1-5', () => {
    const result = ContextSchema.safeParse({
      currentTime: '07:15',
      dayOfWeek: '水曜日',
      mood: 4,
    });
    expect(result.success).toBe(true);
  });

  it('should reject mood below 1', () => {
    const result = ContextSchema.safeParse({
      currentTime: '07:15',
      dayOfWeek: '水曜日',
      mood: 0,
    });
    expect(result.success).toBe(false);
  });

  it('should reject mood above 5', () => {
    const result = ContextSchema.safeParse({
      currentTime: '07:15',
      dayOfWeek: '水曜日',
      mood: 6,
    });
    expect(result.success).toBe(false);
  });

  it('should reject invalid todayMode', () => {
    const result = ContextSchema.safeParse({
      currentTime: '07:15',
      dayOfWeek: '水曜日',
      todayMode: 'invalid',
    });
    expect(result.success).toBe(false);
  });
});

describe('WeatherSchema', () => {
  it('should validate valid weather', () => {
    const result = WeatherSchema.safeParse({
      temperature: 20.5,
      humidity: 65,
      pressure: 1013.25,
      weatherCode: 0,
      uvIndexMax: 5.2,
    });
    expect(result.success).toBe(true);
  });

  it('should reject humidity above 100', () => {
    const result = WeatherSchema.safeParse({
      temperature: 20.5,
      humidity: 101,
      pressure: 1013.25,
      weatherCode: 0,
      uvIndexMax: 5.2,
    });
    expect(result.success).toBe(false);
  });

  it('should reject negative pressure', () => {
    const result = WeatherSchema.safeParse({
      temperature: 20.5,
      humidity: 65,
      pressure: -1,
      weatherCode: 0,
      uvIndexMax: 5.2,
    });
    expect(result.success).toBe(false);
  });
});

describe('HealthDataSchema', () => {
  const validHealthData = {
    scores: {
      autonomic: 85,
      sleep: 78,
      rhythm: 88,
      activity: 68,
    },
    rhythmAnalysis: {
      bedtimeStddevMinutes: 22,
      wakeTimeStddevMinutes: 18,
      consecutiveStableDays: 5,
      status: 'stable' as const,
    },
  };

  it('should validate minimal health data (scores and rhythmAnalysis only)', () => {
    const result = HealthDataSchema.safeParse(validHealthData);
    expect(result.success).toBe(true);
  });

  it('should validate health data with sleep', () => {
    const result = HealthDataSchema.safeParse({
      ...validHealthData,
      sleep: {
        bedtime: '23:15',
        wakeTime: '06:45',
        durationHours: 7.5,
        deepSleepMinutes: 105,
        remSleepMinutes: 95,
        deepSleepRatio: 0.23,
      },
    });
    expect(result.success).toBe(true);
  });

  it('should validate health data with HRV', () => {
    const result = HealthDataSchema.safeParse({
      ...validHealthData,
      hrv: {
        value: 68,
        baseline30d: 62,
        deviationPercent: 9.7,
      },
    });
    expect(result.success).toBe(true);
  });

  it('should reject invalid rhythm status', () => {
    const result = HealthDataSchema.safeParse({
      ...validHealthData,
      rhythmAnalysis: {
        ...validHealthData.rhythmAnalysis,
        status: 'invalid',
      },
    });
    expect(result.success).toBe(false);
  });
});

describe('AdviceRequestSchema', () => {
  const validRequest = {
    profile: {
      nickname: 'マサ',
      age: 28,
      gender: 'male' as const,
      chronotype: 'morning' as const,
      targetBedtime: '23:00',
    },
    healthData: {
      scores: {
        autonomic: 85,
        sleep: 78,
        rhythm: 88,
        activity: 68,
      },
      rhythmAnalysis: {
        bedtimeStddevMinutes: 22,
        wakeTimeStddevMinutes: 18,
        consecutiveStableDays: 5,
        status: 'stable' as const,
      },
    },
    location: {
      latitude: 35.6762,
      longitude: 139.6503,
      city: 'Tokyo',
    },
    context: {
      currentTime: '07:15',
      dayOfWeek: '水曜日',
    },
  };

  it('should validate a valid request', () => {
    const result = AdviceRequestSchema.safeParse(validRequest);
    expect(result.success).toBe(true);
  });

  it('should validate a request with weather', () => {
    const result = AdviceRequestSchema.safeParse({
      ...validRequest,
      weather: {
        temperature: 20.5,
        humidity: 65,
        pressure: 1013.25,
        weatherCode: 0,
        uvIndexMax: 5.2,
      },
    });
    expect(result.success).toBe(true);
  });

  it('should validate a request with all optional fields', () => {
    const result = AdviceRequestSchema.safeParse({
      ...validRequest,
      profile: {
        ...validRequest.profile,
        occupation: 'deskWork',
        exerciseFrequency: 'twiceWeek',
      },
      healthData: {
        ...validRequest.healthData,
        sleep: {
          bedtime: '23:15',
          wakeTime: '06:45',
          durationHours: 7.5,
          deepSleepMinutes: 105,
          remSleepMinutes: 95,
          deepSleepRatio: 0.23,
        },
        hrv: {
          value: 68,
          baseline30d: 62,
          deviationPercent: 9.7,
        },
        activity: {
          stepsYesterday: 8200,
          activeMinutesYesterday: 35,
        },
        auxiliary: {
          daylightMinutesYesterday: 45,
          wristTemperatureDeviation: 0.1,
        },
      },
      context: {
        ...validRequest.context,
        mood: 4,
        todayMode: 'challenge',
      },
      weather: {
        temperature: 20.5,
        humidity: 65,
        pressure: 1013.25,
        weatherCode: 0,
        uvIndexMax: 5.2,
      },
    });
    expect(result.success).toBe(true);
  });

  it('should reject request missing required profile field', () => {
    const { profile: _, ...requestWithoutProfile } = validRequest;
    const result = AdviceRequestSchema.safeParse(requestWithoutProfile);
    expect(result.success).toBe(false);
  });

  it('should reject request missing required healthData field', () => {
    const { healthData: _, ...requestWithoutHealthData } = validRequest;
    const result = AdviceRequestSchema.safeParse(requestWithoutHealthData);
    expect(result.success).toBe(false);
  });

  it('should reject request missing required location field', () => {
    const { location: _, ...requestWithoutLocation } = validRequest;
    const result = AdviceRequestSchema.safeParse(requestWithoutLocation);
    expect(result.success).toBe(false);
  });

  it('should reject request missing required context field', () => {
    const { context: _, ...requestWithoutContext } = validRequest;
    const result = AdviceRequestSchema.safeParse(requestWithoutContext);
    expect(result.success).toBe(false);
  });
});
