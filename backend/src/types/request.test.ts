// Test files allow any type for testing utilities and mocks
/* eslint-disable @typescript-eslint/no-explicit-any */

import { describe, it, expect } from 'vitest';
import { validateAdviceRequest } from './request.js';

describe('Request Validation', () => {
  const validRequestData = {
    userProfile: {
      nickname: 'テストユーザー',
      age: 28,
      gender: 'female',
      weightKg: 55.0,
      heightCm: 165.0,
      interests: ['fitness', 'beauty'],
      occupation: 'it_engineer',
      lifestyleRhythm: 'morning',
      exerciseFrequency: 'three_to_four',
    },
    healthData: {
      date: '2025-12-11T07:00:00.000Z',
      sleep: {
        bedtime: '2025-12-10T23:00:00.000Z',
        wakeTime: '2025-12-11T07:00:00.000Z',
        durationHours: 8,
        deepSleepHours: 2,
        awakenings: 1,
      },
      morningVitals: {
        restingHeartRate: 62,
        hrvMs: 45,
      },
      yesterdayActivity: {
        steps: 8500,
        workoutType: 'ヨガ',
      },
    },
    location: {
      latitude: 35.6762,
      longitude: 139.6503,
      city: '東京',
    },
    context: {
      currentTime: '2025-12-11T07:00:00.000Z',
      dayOfWeek: 'wednesday',
      isMonday: false,
      recentDailyTries: [],
    },
  };

  describe('validateAdviceRequest', () => {
    it('should validate correct request data', () => {
      const result = validateAdviceRequest(validRequestData);

      expect(result.success).toBe(true);
      expect(result.data).toEqual(validRequestData);
      expect(result.errors).toBeUndefined();
    });

    it('should reject request with missing userProfile', () => {
      const invalidData = { ...validRequestData };
      delete (invalidData as any).userProfile;

      const result = validateAdviceRequest(invalidData);

      expect(result.success).toBe(false);
      expect(result.errors).toBeTruthy();
      expect(result.data).toBeUndefined();
    });

    it('should reject request with missing healthData', () => {
      const invalidData = { ...validRequestData };
      delete (invalidData as any).healthData;

      const result = validateAdviceRequest(invalidData);

      expect(result.success).toBe(false);
      expect(result.errors).toBeTruthy();
    });

    it('should reject request with missing location', () => {
      const invalidData = { ...validRequestData };
      delete (invalidData as any).location;

      const result = validateAdviceRequest(invalidData);

      expect(result.success).toBe(false);
      expect(result.errors).toBeTruthy();
    });

    it('should reject request with missing context', () => {
      const invalidData = { ...validRequestData };
      delete (invalidData as any).context;

      const result = validateAdviceRequest(invalidData);

      expect(result.success).toBe(false);
      expect(result.errors).toBeTruthy();
    });

    it('should reject request with invalid age', () => {
      const invalidData = {
        ...validRequestData,
        userProfile: {
          ...validRequestData.userProfile,
          age: -5, // Invalid age
        },
      };

      const result = validateAdviceRequest(invalidData);

      expect(result.success).toBe(false);
      expect(result.errors).toBeTruthy();
    });

    it('should reject request with invalid weight', () => {
      const invalidData = {
        ...validRequestData,
        userProfile: {
          ...validRequestData.userProfile,
          weightKg: 0, // Invalid weight
        },
      };

      const result = validateAdviceRequest(invalidData);

      expect(result.success).toBe(false);
    });

    it('should reject request with invalid location coordinates', () => {
      const invalidData = {
        ...validRequestData,
        location: {
          ...validRequestData.location,
          latitude: 100, // Invalid latitude
        },
      };

      const result = validateAdviceRequest(invalidData);

      expect(result.success).toBe(false);
    });

    it('should reject request with empty interests array', () => {
      const invalidData = {
        ...validRequestData,
        userProfile: {
          ...validRequestData.userProfile,
          interests: [],
        },
      };

      const result = validateAdviceRequest(invalidData);

      expect(result.success).toBe(false);
    });

    it('should reject request with invalid gender', () => {
      const invalidData = {
        ...validRequestData,
        userProfile: {
          ...validRequestData.userProfile,
          gender: 'invalid',
        },
      };

      const result = validateAdviceRequest(invalidData);

      expect(result.success).toBe(false);
    });

    it('should accept request with minimal health data', () => {
      const minimalHealthData = {
        ...validRequestData,
        healthData: {
          date: '2025-12-11T07:00:00.000Z',
          // Only required field
        },
      };

      const result = validateAdviceRequest(minimalHealthData);

      expect(result.success).toBe(true);
    });

    it('should accept request with optional fields', () => {
      const dataWithOptionals = {
        ...validRequestData,
        userProfile: {
          ...validRequestData.userProfile,
          alcoholFrequency: 'never' as const,
        },
        healthData: {
          ...validRequestData.healthData,
          sleep: {
            ...validRequestData.healthData.sleep,
            remSleepHours: 1.5,
            avgHeartRate: 65,
          },
          morningVitals: {
            ...validRequestData.healthData.morningVitals,
            bloodOxygen: 98,
          },
          yesterdayActivity: {
            ...validRequestData.healthData.yesterdayActivity,
            workoutMinutes: 30,
            caloriesBurned: 200,
          },
          weekTrends: {
            avgSleepHours: 7.5,
            avgHrv: 45,
            avgRestingHeartRate: 62,
            avgSteps: 8000,
            totalWorkoutHours: 2.5,
          },
        },
        location: {
          ...validRequestData.location,
          city: '東京都',
        },
        context: {
          ...validRequestData.context,
          recentDailyTries: ['水分補給', '深呼吸'],
        },
      };

      const result = validateAdviceRequest(dataWithOptionals);

      expect(result.success).toBe(true);
      expect(result.data?.healthData.weekTrends?.avgSleepHours).toBe(7.5);
    });
  });
});