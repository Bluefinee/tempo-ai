import { describe, it, expect } from 'vitest';
import { calculatePressureTrend } from './pressure.js';

describe('calculatePressureTrend', () => {
  describe('上昇トレンド (rising)', () => {
    it('diff > 2 の場合は "rising" を返す', () => {
      expect(calculatePressureTrend(1020, 1017)).toBe('rising');
    });

    it('diff = 2.01 の場合は "rising" を返す（境界値）', () => {
      expect(calculatePressureTrend(1020.01, 1018)).toBe('rising');
    });

    it('diff = 5 の場合は "rising" を返す', () => {
      expect(calculatePressureTrend(1025, 1020)).toBe('rising');
    });
  });

  describe('下降トレンド (falling)', () => {
    it('diff < -2 の場合は "falling" を返す', () => {
      expect(calculatePressureTrend(1015, 1018)).toBe('falling');
    });

    it('diff = -2.01 の場合は "falling" を返す（境界値）', () => {
      expect(calculatePressureTrend(1017.99, 1020)).toBe('falling');
    });

    it('diff = -5 の場合は "falling" を返す', () => {
      expect(calculatePressureTrend(1015, 1020)).toBe('falling');
    });
  });

  describe('安定トレンド (stable)', () => {
    it('diff = 0 の場合は "stable" を返す', () => {
      expect(calculatePressureTrend(1018, 1018)).toBe('stable');
    });

    it('diff = 1 の場合は "stable" を返す', () => {
      expect(calculatePressureTrend(1019, 1018)).toBe('stable');
    });

    it('diff = -1 の場合は "stable" を返す', () => {
      expect(calculatePressureTrend(1017, 1018)).toBe('stable');
    });

    it('diff = 2 の場合は "stable" を返す（境界値）', () => {
      expect(calculatePressureTrend(1020, 1018)).toBe('stable');
    });

    it('diff = -2 の場合は "stable" を返す（境界値）', () => {
      expect(calculatePressureTrend(1016, 1018)).toBe('stable');
    });
  });

  describe('データ不足', () => {
    it('pressure3hAgo が undefined の場合は "stable" を返す', () => {
      expect(calculatePressureTrend(1018, undefined)).toBe('stable');
    });

    it('pressure3hAgo が省略された場合は "stable" を返す', () => {
      expect(calculatePressureTrend(1018)).toBe('stable');
    });
  });
});
