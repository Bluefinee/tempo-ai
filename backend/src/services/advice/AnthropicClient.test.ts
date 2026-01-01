import Anthropic from '@anthropic-ai/sdk';
import { describe, expect, it, vi } from 'vitest';
import { AnthropicClient } from './AnthropicClient';

// Anthropic SDKをモック
vi.mock('@anthropic-ai/sdk', () => {
  const MockAnthropic = vi.fn();
  MockAnthropic.prototype.messages = {
    create: vi.fn(),
  };
  MockAnthropic.APIError = class APIError extends Error {
    status: number;
    constructor(status: number, message: string) {
      super(message);
      this.name = 'APIError';
      this.status = status;
    }
  };
  return { default: MockAnthropic };
});

describe('AnthropicClient', () => {
  const systemPrompt = '<role>Test system prompt</role>';
  const userDataXml = '<user_data><profile><nickname>テスト</nickname></profile></user_data>';

  const createMockResponse = (text: string): Anthropic.Message => ({
    id: 'msg_test',
    type: 'message',
    role: 'assistant',
    content: [{ type: 'text', text }],
    model: 'claude-sonnet-4-20250514',
    stop_reason: 'end_turn',
    stop_sequence: null,
    usage: { input_tokens: 100, output_tokens: 200 },
  });

  const validJsonResponse = JSON.stringify({
    summary: 'テストサマリーです。今日のコンディションは良好です。',
    full_insight:
      'マサさん、おはようございます。今日のコンディションは全体的に良好です。昨夜の睡眠は目標通りで、深い睡眠も十分に取れています。',
    recommended_action: {
      type: 'breathing',
      message: '深呼吸を3回してみましょう',
    },
  });

  describe('generateAdvice', () => {
    it('should return parsed advice on successful response', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(createMockResponse(validJsonResponse));
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.data.summary).toBe('テストサマリーです。今日のコンディションは良好です。');
        expect(result.data.fullInsight).toContain('マサさん、おはようございます');
        expect(result.data.recommendedAction.type).toBe('breathing');
        expect(result.data.recommendedAction.message).toBe('深呼吸を3回してみましょう');
      }
    });

    it('should send request with cache_control for system prompt', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(createMockResponse(validJsonResponse));
      client['client'].messages.create = mockCreate;

      await client.generateAdvice(systemPrompt, userDataXml);

      expect(mockCreate).toHaveBeenCalledWith({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 2000,
        system: [
          {
            type: 'text',
            text: systemPrompt,
            cache_control: { type: 'ephemeral' },
          },
        ],
        messages: [{ role: 'user', content: userDataXml }],
      });
    });

    it('should handle response with surrounding text', async () => {
      const client = new AnthropicClient('test-api-key');
      const responseWithText = `Here is the advice:\n\n${validJsonResponse}\n\nI hope this helps!`;
      const mockCreate = vi.fn().mockResolvedValue(createMockResponse(responseWithText));
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.data.summary).toBe('テストサマリーです。今日のコンディションは良好です。');
      }
    });

    it('should return PARSE_ERROR when response has no text content', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue({
        id: 'msg_test',
        type: 'message',
        role: 'assistant',
        content: [],
        model: 'claude-sonnet-4-20250514',
        stop_reason: 'end_turn',
        stop_sequence: null,
        usage: { input_tokens: 100, output_tokens: 0 },
      });
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toBe('No text content in response');
      }
    });

    it('should return PARSE_ERROR when response has no JSON', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi
        .fn()
        .mockResolvedValue(createMockResponse('This is just plain text without JSON'));
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toBe('No JSON found in response');
      }
    });

    it('should return PARSE_ERROR when JSON is invalid', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(createMockResponse('{ invalid json }'));
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toBe('Failed to parse JSON response');
      }
    });

    it('should return PARSE_ERROR when summary is missing', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(
        createMockResponse(
          JSON.stringify({
            full_insight: 'insight',
            recommended_action: { type: 'breathing', message: 'msg' },
          }),
        ),
      );
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toBe('Missing or invalid summary field');
      }
    });

    it('should return PARSE_ERROR when full_insight is missing', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(
        createMockResponse(
          JSON.stringify({
            summary: 'summary',
            recommended_action: { type: 'breathing', message: 'msg' },
          }),
        ),
      );
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toBe('Missing or invalid full_insight field');
      }
    });

    it('should return PARSE_ERROR when recommended_action is missing', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(
        createMockResponse(
          JSON.stringify({
            summary: 'summary',
            full_insight: 'insight',
          }),
        ),
      );
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toBe('Missing or invalid recommended_action field');
      }
    });

    it('should return PARSE_ERROR when action type is invalid', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(
        createMockResponse(
          JSON.stringify({
            summary: 'summary',
            full_insight: 'insight',
            recommended_action: { type: 'invalid_type', message: 'msg' },
          }),
        ),
      );
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toContain('Invalid recommended_action.type');
      }
    });

    it('should return PARSE_ERROR when action message is missing', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(
        createMockResponse(
          JSON.stringify({
            summary: 'summary',
            full_insight: 'insight',
            recommended_action: { type: 'breathing' },
          }),
        ),
      );
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toBe('Missing or invalid recommended_action.message field');
      }
    });

    it('should handle all valid action types', async () => {
      const client = new AnthropicClient('test-api-key');
      const actionTypes = ['breathing', 'morning_light', 'rest', 'activity'] as const;

      for (const actionType of actionTypes) {
        const mockCreate = vi.fn().mockResolvedValue(
          createMockResponse(
            JSON.stringify({
              summary: 'summary',
              full_insight: 'insight',
              recommended_action: { type: actionType, message: 'msg' },
            }),
          ),
        );
        client['client'].messages.create = mockCreate;

        const result = await client.generateAdvice(systemPrompt, userDataXml);

        expect(result.ok).toBe(true);
        if (result.ok) {
          expect(result.data.recommendedAction.type).toBe(actionType);
        }
      }
    });
  });

  describe('error handling', () => {
    it('should return RATE_LIMIT_ERROR on 429 status', async () => {
      const client = new AnthropicClient('test-api-key');
      const apiError = new (
        Anthropic.APIError as unknown as new (
          status: number,
          message: string,
        ) => Anthropic.APIError
      )(429, 'Rate limit exceeded');
      const mockCreate = vi.fn().mockRejectedValue(apiError);
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('RATE_LIMIT_ERROR');
        expect(result.error.message).toBe('Rate limit exceeded');
      }
    });

    it('should return AI_API_ERROR on other API errors', async () => {
      const client = new AnthropicClient('test-api-key');
      const apiError = new (
        Anthropic.APIError as unknown as new (
          status: number,
          message: string,
        ) => Anthropic.APIError
      )(500, 'Internal server error');
      const mockCreate = vi.fn().mockRejectedValue(apiError);
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('AI_API_ERROR');
        expect(result.error.message).toContain('500');
      }
    });

    it('should return NETWORK_ERROR on network failures', async () => {
      const client = new AnthropicClient('test-api-key');
      const networkError = new Error('fetch failed: ECONNREFUSED');
      const mockCreate = vi.fn().mockRejectedValue(networkError);
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('NETWORK_ERROR');
        expect(result.error.message).toBe('Network error occurred');
      }
    });

    it('should return AI_API_ERROR on unknown errors', async () => {
      const client = new AnthropicClient('test-api-key');
      const unknownError = new Error('Something went wrong');
      const mockCreate = vi.fn().mockRejectedValue(unknownError);
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('AI_API_ERROR');
        expect(result.error.message).toBe('Unknown API error');
      }
    });

    it('should handle non-Error objects', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockRejectedValue('string error');
      client['client'].messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('AI_API_ERROR');
        expect(result.error.details).toBe('string error');
      }
    });
  });
});
