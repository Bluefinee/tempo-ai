import { describe, it, expect } from 'vitest';
import { buildSystemPrompt, buildAdditionalAdviceSystemPrompt } from './system.js';

describe('System Prompts', () => {
  describe('buildSystemPrompt', () => {
    it('should build system prompt with correct structure', () => {
      const result = buildSystemPrompt();

      expect(result.type).toBe('text');
      expect(result.cache_control).toEqual({ type: 'ephemeral' });
      expect(result.text).toBeTruthy();
    });

    it('should contain role definition', () => {
      const result = buildSystemPrompt();

      expect(result.text).toContain('Tempo AIの専属ヘルスケアアドバイザー');
      expect(result.text).toContain('年上の落ち着いた優しいお姉さん');
    });

    it('should contain prohibited actions', () => {
      const result = buildSystemPrompt();

      expect(result.text).toContain('禁止事項');
      expect(result.text).toContain('医学的診断や処方薬の提案');
      expect(result.text).toContain('絵文字の使用');
      expect(result.text).toContain('過度な心配や不安を煽る表現');
    });

    it('should contain tone guidelines', () => {
      const result = buildSystemPrompt();

      expect(result.text).toContain('トーンルール');
      expect(result.text).toContain('敬語ベースの丁寧語');
      expect(result.text).toContain('です・ます調');
      expect(result.text).toContain('温かい励ましと理解を示す表現');
    });

    it('should contain advice balance guidelines', () => {
      const result = buildSystemPrompt();

      expect(result.text).toContain('アドバイスバランス');
      expect(result.text).toContain('ベースライン提案: 60-70%');
      expect(result.text).toContain('関心ごと反映: 30-40%');
    });

    it('should contain data integration guidelines', () => {
      const result = buildSystemPrompt();

      expect(result.text).toContain('データ統合の指針');
      expect(result.text).toContain('複数のデータソースを掛け合わせた分析');
      expect(result.text).toContain('HRVと睡眠データの相関性');
      expect(result.text).toContain('気象データとユーザーの体調');
    });

    it('should contain complete JSON output format specification', () => {
      const result = buildSystemPrompt();

      // Check all required JSON fields are specified
      expect(result.text).toContain('出力JSON形式');
      expect(result.text).toContain('greeting');
      expect(result.text).toContain('condition');
      expect(result.text).toContain('summary');
      expect(result.text).toContain('detail');
      expect(result.text).toContain('actionSuggestions');
      expect(result.text).toContain('closingMessage');
      expect(result.text).toContain('dailyTry');
      expect(result.text).toContain('weeklyTry');
      expect(result.text).toContain('generatedAt');
      expect(result.text).toContain('timeSlot');

      // Check icon types are specified
      expect(result.text).toContain('hydration|movement|rest|nutrition|mindfulness');

      // Check field constraints
      expect(result.text).toContain('15文字以内');
      expect(result.text).toContain('50文字以内');
      expect(result.text).toContain('20文字以内');
      expect(result.text).toContain('30文字以内');
      expect(result.text).toContain('100文字以内');
    });

    it('should specify JSON-only output requirement', () => {
      const result = buildSystemPrompt();

      expect(result.text).toContain('JSONの前後に説明文は不要');
      expect(result.text).toContain('純粋なJSONのみを出力');
    });
  });

  describe('buildAdditionalAdviceSystemPrompt', () => {
    it('should build additional advice system prompt', () => {
      const result = buildAdditionalAdviceSystemPrompt();

      expect(typeof result).toBe('string');
      expect(result).toBeTruthy();
    });

    it('should contain role definition for additional advice', () => {
      const result = buildAdditionalAdviceSystemPrompt();

      expect(result).toContain('Tempo AIの専属ヘルスケアアドバイザー');
      expect(result).toContain('朝のメインアドバイスを補完する追加アドバイス');
      expect(result).toContain('時間帯に応じた適切なアドバイス');
    });

    it('should contain tone guidelines for additional advice', () => {
      const result = buildAdditionalAdviceSystemPrompt();

      expect(result).toContain('トーンルール');
      expect(result).toContain('敬語ベースの丁寧語');
      expect(result).toContain('親しみやすく励ましのある表現');
      expect(result).toContain('簡潔で分かりやすい');
    });

    it('should contain additional advice JSON format specification', () => {
      const result = buildAdditionalAdviceSystemPrompt();

      // Check required fields for additional advice
      expect(result).toContain('出力JSON形式');
      expect(result).toContain('greeting');
      expect(result).toContain('message');
      expect(result).toContain('actionSuggestion');
      expect(result).toContain('generatedAt');
      expect(result).toContain('timeSlot');

      // Check time slot values
      expect(result).toContain('midday|evening');

      // Check field constraints
      expect(result).toContain('100文字以内');
      expect(result).toContain('15文字以内');
      expect(result).toContain('50文字以内');
    });

    it('should specify JSON-only output requirement for additional advice', () => {
      const result = buildAdditionalAdviceSystemPrompt();

      expect(result).toContain('JSONの前後に説明文は不要');
      expect(result).toContain('純粋なJSONのみを出力');
    });
  });

  describe('System Prompt Content Quality', () => {
    it('should have appropriate length for system prompt', () => {
      const result = buildSystemPrompt();

      // Should be substantial but not excessive (roughly 1,500 tokens as specified in design)
      expect(result.text.length).toBeGreaterThan(1000);
      expect(result.text.length).toBeLessThan(4000);
    });

    it('should have appropriate length for additional advice prompt', () => {
      const result = buildAdditionalAdviceSystemPrompt();

      // Should be shorter than main system prompt
      expect(result.length).toBeGreaterThan(400);
      expect(result.length).toBeLessThan(2000);
    });

    it('should contain structured sections in system prompt', () => {
      const result = buildSystemPrompt();

      const sections = [
        '【役割】',
        '【禁止事項】',
        '【トーンルール】',
        '【アドバイスバランス】',
        '【データ統合の指針】',
        '【出力JSON形式】',
      ];

      for (const section of sections) {
        expect(result.text).toContain(section);
      }
    });

    it('should use consistent formatting in system prompt', () => {
      const result = buildSystemPrompt();

      // Check for consistent use of Japanese brackets
      expect(result.text).toContain('【');
      expect(result.text).toContain('】');

      // Check for proper JSON code block formatting
      expect(result.text).toContain('{');
      expect(result.text).toContain('}');
    });

    it('should include all required icon types', () => {
      const result = buildSystemPrompt();

      const iconTypes = ['hydration', 'movement', 'rest', 'nutrition', 'mindfulness'];

      for (const iconType of iconTypes) {
        expect(result.text).toContain(iconType);
      }
    });

    it('should include cache control configuration', () => {
      const result = buildSystemPrompt();

      expect(result.cache_control).toBeDefined();
      expect(result.cache_control?.type).toBe('ephemeral');
    });
  });
});
