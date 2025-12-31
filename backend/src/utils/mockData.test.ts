import { describe, it, expect } from 'vitest';
import { createMockAdviceForTimeSlot } from './mockData.js';

describe('Mock Data Utilities', () => {
  describe('createMockAdviceForTimeSlot', () => {
    const testNickname = 'テストユーザー';

    it('should create mock advice for morning time slot', () => {
      const result = createMockAdviceForTimeSlot(testNickname, 'morning');

      expect(result.success).toBe(true);
      expect(result.data).toBeTruthy();
      expect(result.data?.mainAdvice).toBeDefined();

      if (result.data?.mainAdvice) {
        expect(result.data.mainAdvice.greeting).toContain(testNickname);
        expect(result.data.mainAdvice.greeting).toContain('おはよう');
        expect(result.data.mainAdvice.timeSlot).toBe('morning');
        expect(result.data.mainAdvice.condition).toBeTruthy();
        expect(result.data.mainAdvice.condition.summary).toBeTruthy();
        expect(result.data.mainAdvice.condition.detail).toBeTruthy();
        expect(result.data.mainAdvice.energyComment).toBeTruthy();
        expect(result.data.mainAdvice.insight).toBeTruthy();
        expect(result.data.mainAdvice.scores).toBeTruthy();
        expect(result.data.mainAdvice.closingMessage).toBeTruthy();
        expect(result.data.mainAdvice.dailyTry).toBeTruthy();
        expect(result.data.mainAdvice.generatedAt).toBeTruthy();
      }
    });

    it('should create mock advice for afternoon time slot', () => {
      const result = createMockAdviceForTimeSlot(testNickname, 'afternoon');

      expect(result.success).toBe(true);
      expect(result.data).toBeTruthy();
      expect(result.data?.mainAdvice).toBeDefined();

      if (result.data?.mainAdvice) {
        expect(result.data.mainAdvice.greeting).toContain(testNickname);
        expect(result.data.mainAdvice.greeting).toContain('お疲れさま');
        expect(result.data.mainAdvice.timeSlot).toBe('afternoon');
        expect(result.data.mainAdvice.condition).toBeTruthy();
        expect(result.data.mainAdvice.energyComment).toBeTruthy();
        expect(result.data.mainAdvice.dailyTry).toBeTruthy();
      }
    });

    it('should create mock advice for evening time slot', () => {
      const result = createMockAdviceForTimeSlot(testNickname, 'evening');

      expect(result.success).toBe(true);
      expect(result.data).toBeTruthy();
      expect(result.data?.mainAdvice).toBeDefined();

      if (result.data?.mainAdvice) {
        expect(result.data.mainAdvice.greeting).toContain(testNickname);
        expect(result.data.mainAdvice.greeting).toContain('お疲れさま');
        expect(result.data.mainAdvice.timeSlot).toBe('evening');
        expect(result.data.mainAdvice.condition).toBeTruthy();
        expect(result.data.mainAdvice.energyComment).toBeTruthy();
        expect(result.data.mainAdvice.dailyTry).toBeTruthy();
      }
    });

    it('should handle empty nickname gracefully', () => {
      const result = createMockAdviceForTimeSlot('', 'morning');

      expect(result.success).toBe(true);
      expect(result.data).toBeTruthy();
      expect(result.data?.mainAdvice).toBeDefined();

      if (result.data?.mainAdvice) {
        expect(result.data.mainAdvice.greeting).toContain('さん、おはよう');
      }
    });

    it('should handle special characters in nickname', () => {
      const specialNickname = 'ユーザー123@#$';
      const result = createMockAdviceForTimeSlot(specialNickname, 'morning');

      expect(result.success).toBe(true);
      expect(result.data).toBeTruthy();
      expect(result.data?.mainAdvice).toBeDefined();

      if (result.data?.mainAdvice) {
        expect(result.data.mainAdvice.greeting).toContain(specialNickname);
      }
    });

    it('should handle very long nickname', () => {
      const longNickname = 'とても長いニックネームのテストユーザーです';
      const result = createMockAdviceForTimeSlot(longNickname, 'morning');

      expect(result.success).toBe(true);
      expect(result.data).toBeTruthy();
      expect(result.data?.mainAdvice).toBeDefined();

      if (result.data?.mainAdvice) {
        expect(result.data.mainAdvice.greeting).toContain(longNickname);
      }
    });

    describe('Response Structure Validation', () => {
      it('should have valid scores structure', () => {
        const result = createMockAdviceForTimeSlot(testNickname, 'morning');

        if (result.data?.mainAdvice) {
          const { scores } = result.data.mainAdvice;
          expect(typeof scores.hrv).toBe('number');
          expect(typeof scores.sleep).toBe('number');
          expect(typeof scores.rhythm).toBe('number');
          expect(typeof scores.activity).toBe('number');
          expect(scores.hrv).toBeGreaterThanOrEqual(0);
          expect(scores.hrv).toBeLessThanOrEqual(100);
        }
      });

      it('should have valid daily try structure', () => {
        const result = createMockAdviceForTimeSlot(testNickname, 'morning');

        if (result.data?.mainAdvice) {
          const { dailyTry } = result.data.mainAdvice;
          expect(dailyTry.title).toBeTruthy();
          expect(dailyTry.detail).toBeTruthy();
          expect(typeof dailyTry.title).toBe('string');
          expect(typeof dailyTry.detail).toBe('string');
        }
      });

      it('should have valid timestamp format', () => {
        const result = createMockAdviceForTimeSlot(testNickname, 'morning');

        if (result.data?.mainAdvice) {
          const timestamp = new Date(result.data.mainAdvice.generatedAt);
          expect(timestamp.toISOString()).toBe(result.data.mainAdvice.generatedAt);
        }
      });

      it('should have energyComment and insight fields', () => {
        const result = createMockAdviceForTimeSlot(testNickname, 'morning');

        if (result.data?.mainAdvice) {
          expect(result.data.mainAdvice.energyComment).toBeTruthy();
          expect(typeof result.data.mainAdvice.energyComment).toBe('string');
          expect(result.data.mainAdvice.insight).toBeTruthy();
          expect(typeof result.data.mainAdvice.insight).toBe('string');
        }
      });
    });

    describe('Time Slot Specific Content', () => {
      it('should have different greetings for different time slots', () => {
        const morning = createMockAdviceForTimeSlot(testNickname, 'morning');
        const afternoon = createMockAdviceForTimeSlot(testNickname, 'afternoon');
        const evening = createMockAdviceForTimeSlot(testNickname, 'evening');

        expect(morning.data?.mainAdvice.greeting).toContain('おはよう');
        expect(afternoon.data?.mainAdvice.greeting).toContain('お疲れさま');
        expect(evening.data?.mainAdvice.greeting).toContain('お疲れさま');

        // Afternoon and evening should be different
        expect(afternoon.data?.mainAdvice.greeting).not.toBe(evening.data?.mainAdvice.greeting);
      });

      it('should have consistent scores across time slots', () => {
        const morning = createMockAdviceForTimeSlot(testNickname, 'morning');
        const afternoon = createMockAdviceForTimeSlot(testNickname, 'afternoon');
        const evening = createMockAdviceForTimeSlot(testNickname, 'evening');

        // All should have scores
        expect(morning.data?.mainAdvice.scores).toBeTruthy();
        expect(afternoon.data?.mainAdvice.scores).toBeTruthy();
        expect(evening.data?.mainAdvice.scores).toBeTruthy();
      });
    });

    describe('Data Consistency', () => {
      it('should generate consistent data for same inputs', () => {
        const result1 = createMockAdviceForTimeSlot(testNickname, 'morning');
        const result2 = createMockAdviceForTimeSlot(testNickname, 'morning');

        expect(result1.data?.mainAdvice.greeting).toBe(result2.data?.mainAdvice.greeting);
        expect(result1.data?.mainAdvice.condition.summary).toBe(
          result2.data?.mainAdvice.condition.summary,
        );
        expect(result1.data?.mainAdvice.timeSlot).toBe(result2.data?.mainAdvice.timeSlot);
      });

      it('should include nickname in greeting for all time slots', () => {
        const timeSlots = ['morning', 'afternoon', 'evening'] as const;

        for (const timeSlot of timeSlots) {
          const result = createMockAdviceForTimeSlot(testNickname, timeSlot);
          expect(result.data?.mainAdvice.greeting).toContain(testNickname);
        }
      });

      it('should have valid generatedAt timestamp', () => {
        const beforeTest = new Date();
        const result = createMockAdviceForTimeSlot(testNickname, 'morning');
        const afterTest = new Date();

        if (result.data?.mainAdvice) {
          const generated = new Date(result.data.mainAdvice.generatedAt);
          expect(generated.getTime()).toBeGreaterThanOrEqual(beforeTest.getTime());
          expect(generated.getTime()).toBeLessThanOrEqual(afterTest.getTime());
        }
      });
    });
  });
});
