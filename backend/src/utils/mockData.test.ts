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
        expect(result.data.mainAdvice.actionSuggestions).toHaveLength(2);
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
        expect(result.data.mainAdvice.actionSuggestions).toHaveLength(2);
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
        expect(result.data.mainAdvice.actionSuggestions).toHaveLength(2);
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
      it('should have valid action suggestions structure', () => {
        const result = createMockAdviceForTimeSlot(testNickname, 'morning');
        
        if (result.data?.mainAdvice) {
          for (const action of result.data.mainAdvice.actionSuggestions) {
            expect(action.icon).toBeTruthy();
            expect(action.title).toBeTruthy();
            expect(action.detail).toBeTruthy();
            expect(typeof action.icon).toBe('string');
            expect(typeof action.title).toBe('string');
            expect(typeof action.detail).toBe('string');
          }
        }
      });

      it('should have valid daily try structure', () => {
        const result = createMockAdviceForTimeSlot(testNickname, 'morning');
        
        if (result.data?.mainAdvice) {
          const { dailyTry } = result.data.mainAdvice;
          expect(dailyTry.title).toBeTruthy();
          expect(dailyTry.summary).toBeTruthy();
          expect(dailyTry.detail).toBeTruthy();
          expect(typeof dailyTry.title).toBe('string');
          expect(typeof dailyTry.summary).toBe('string');
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

      it('should have appropriate weeklyTry for morning only', () => {
        const morningResult = createMockAdviceForTimeSlot(testNickname, 'morning');
        const afternoonResult = createMockAdviceForTimeSlot(testNickname, 'afternoon');
        const eveningResult = createMockAdviceForTimeSlot(testNickname, 'evening');

        if (morningResult.data?.mainAdvice) {
          expect(morningResult.data.mainAdvice.weeklyTry).toBeFalsy(); // Phase 7 では undefined
        }

        if (afternoonResult.data?.mainAdvice) {
          expect(afternoonResult.data.mainAdvice.weeklyTry).toBeFalsy();
        }

        if (eveningResult.data?.mainAdvice) {
          expect(eveningResult.data.mainAdvice.weeklyTry).toBeFalsy();
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

      it('should have appropriate action suggestions for each time slot', () => {
        const morning = createMockAdviceForTimeSlot(testNickname, 'morning');
        const afternoon = createMockAdviceForTimeSlot(testNickname, 'afternoon');
        const evening = createMockAdviceForTimeSlot(testNickname, 'evening');

        // All should have exactly 2 action suggestions
        expect(morning.data?.mainAdvice.actionSuggestions).toHaveLength(2);
        expect(afternoon.data?.mainAdvice.actionSuggestions).toHaveLength(2);
        expect(evening.data?.mainAdvice.actionSuggestions).toHaveLength(2);

        // In current implementation, action suggestions are the same (only greeting changes)
        const morningTitles = morning.data?.mainAdvice.actionSuggestions.map(a => a.title) || [];
        const afternoonTitles = afternoon.data?.mainAdvice.actionSuggestions.map(a => a.title) || [];
        const eveningTitles = evening.data?.mainAdvice.actionSuggestions.map(a => a.title) || [];

        // Current implementation uses same content, only greeting differs
        expect(morningTitles).toEqual(afternoonTitles);
        expect(afternoonTitles).toEqual(eveningTitles);
      });

      it('should have time-appropriate daily try suggestions', () => {
        const morning = createMockAdviceForTimeSlot(testNickname, 'morning');
        const afternoon = createMockAdviceForTimeSlot(testNickname, 'afternoon');
        const evening = createMockAdviceForTimeSlot(testNickname, 'evening');

        // All should have daily try
        expect(morning.data?.mainAdvice.dailyTry).toBeTruthy();
        expect(afternoon.data?.mainAdvice.dailyTry).toBeTruthy();
        expect(evening.data?.mainAdvice.dailyTry).toBeTruthy();

        // Current implementation uses same dailyTry content (only greeting differs)
        expect(morning.data?.mainAdvice.dailyTry.title).toBe(afternoon.data?.mainAdvice.dailyTry.title);
        expect(afternoon.data?.mainAdvice.dailyTry.title).toBe(evening.data?.mainAdvice.dailyTry.title);
      });
    });

    describe('Data Consistency', () => {
      it('should generate consistent data for same inputs', () => {
        const result1 = createMockAdviceForTimeSlot(testNickname, 'morning');
        const result2 = createMockAdviceForTimeSlot(testNickname, 'morning');

        expect(result1.data?.mainAdvice.greeting).toBe(result2.data?.mainAdvice.greeting);
        expect(result1.data?.mainAdvice.condition.summary).toBe(result2.data?.mainAdvice.condition.summary);
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