import Anthropic from '@anthropic-ai/sdk';
import type { PromptCachingBetaMessage } from '@anthropic-ai/sdk/resources/beta/prompt-caching/messages';
import { describe, expect, it, vi } from 'vitest';
import { AnthropicClient } from './AnthropicClient';

// Anthropic SDKをモック
vi.mock('@anthropic-ai/sdk', () => {
  // MockAPIErrorをvi.mock内で定義（ホイスティング対応）
  class MockAPIError extends Error {
    status: number;
    constructor(status: number, message: string) {
      super(message);
      this.name = 'APIError';
      this.status = status;
    }
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const MockAnthropic: any = function (this: unknown) {
    return this;
  };
  MockAnthropic.prototype.beta = {
    promptCaching: {
      messages: {
        create: vi.fn(),
      },
    },
  };
  MockAnthropic.APIError = MockAPIError;
  return { default: MockAnthropic };
});

describe('AnthropicClient', () => {
  const systemPrompt = '<role>Test system prompt</role>';
  const userDataXml = '<user_data><profile><nickname>テスト</nickname></profile></user_data>';

  const createMockResponse = (text: string): PromptCachingBetaMessage => ({
    id: 'msg_test',
    type: 'message',
    role: 'assistant',
    content: [{ type: 'text', text }],
    model: 'claude-sonnet-4-20250514',
    stop_reason: 'end_turn',
    stop_sequence: null,
    usage: {
      input_tokens: 100,
      output_tokens: 200,
      cache_creation_input_tokens: null,
      cache_read_input_tokens: null,
    },
  });

  const validJsonResponse = JSON.stringify({
    todayInsight: {
      title: 'A Quiet Harmony',
      summary:
        '今日のあなたは穏やかな波のように整っています。昨夜の深い眠りが、心と身体をしっかりと回復させてくれました。',
      whyThisMatters: {
        hrv: {
          headline: 'HRVがベースラインより6%高い',
          explanation:
            '自律神経がしっかり回復しています。今日は集中力を要するタスクに向いています。',
        },
        sleep: {
          headline: '深い睡眠が1時間45分（23%）',
          explanation: '身体の修復に理想的な範囲でした。ホルモンバランスの回復も十分です。',
        },
        rhythm: {
          headline: '就寝時刻が目標の15分遅れ',
          explanation: '今日のコンディションへの影響はありません。この程度のズレは許容範囲です。',
        },
      },
      whatThisMeansForToday: '午前中のPeak Focus時間帯（9時〜12時）は特に集中力が高まります。',
    },
    todayOneThing: {
      icon: 'walking',
      action: '14時頃に5分の散歩',
      summary: '夕方のリズムが整い、夜の眠りの質が向上します',
      time: '14:00',
      whyThisAction:
        'あなたのAfternoon Dip（自然なエネルギー低下）は14時〜16時頃に訪れます。この時間帯に軽い動きを入れることで、カフェインに頼らずに午後の集中力を回復できます。',
      benefits: [
        'カフェインなしで覚醒度を回復',
        '夜のメラトニン分泌を改善',
        '体温リズムを安定させる',
      ],
      howToDoIt: ['可能であれば外に出る', '5分程度、軽いペースで歩く', '自然光を浴びると効果的'],
      expectedBenefit: {
        text: '午後の軽い運動は睡眠の質を10-20%改善する傾向があります',
        source: 'サーカディアンリズム研究に基づく',
      },
    },
    relatedInsight: {
      label: 'Research Finding',
      text: '23時前就寝で深い睡眠が20-25%増加',
      source: '睡眠科学研究に基づく',
    },
  });

  describe('generateAdvice', () => {
    it('should return parsed advice on successful response', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(createMockResponse(validJsonResponse));
      client['client'].beta.promptCaching.messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.data.todayInsight.title).toBe('A Quiet Harmony');
        expect(result.data.todayInsight.summary).toBeTruthy();
        expect(result.data.todayInsight.whyThisMatters.hrv.headline).toBeTruthy();
        expect(result.data.todayInsight.whyThisMatters.sleep.headline).toBeTruthy();
        expect(result.data.todayInsight.whyThisMatters.rhythm.headline).toBeTruthy();
        expect(result.data.todayOneThing.icon).toBe('walking');
        expect(result.data.todayOneThing.action).toBe('14時頃に5分の散歩');
        expect(result.data.todayOneThing.benefits).toHaveLength(3);
        expect(result.data.todayOneThing.howToDoIt).toHaveLength(3);
        expect(result.data.relatedInsight.label).toBe('Research Finding');
        expect(result.data.relatedInsight.text).toBeTruthy();
      }
    });

    it('should send request with cache_control for system prompt', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(createMockResponse(validJsonResponse));
      client['client'].beta.promptCaching.messages.create = mockCreate;

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
      client['client'].beta.promptCaching.messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.data.todayInsight.title).toBe('A Quiet Harmony');
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
        usage: {
          input_tokens: 100,
          output_tokens: 0,
          cache_creation_input_tokens: null,
          cache_read_input_tokens: null,
        },
      });
      client['client'].beta.promptCaching.messages.create = mockCreate;

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
      client['client'].beta.promptCaching.messages.create = mockCreate;

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
      client['client'].beta.promptCaching.messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toBe('Failed to parse JSON response');
      }
    });

    it('should return PARSE_ERROR when todayInsight is missing', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(
        createMockResponse(
          JSON.stringify({
            todayOneThing: {
              icon: 'walking',
              action: 'action',
              summary: 'summary',
              time: '14:00',
              whyThisAction: 'why',
              benefits: ['b1', 'b2', 'b3'],
              howToDoIt: ['h1', 'h2', 'h3'],
              expectedBenefit: { text: 'text', source: 'source' },
            },
            relatedInsight: { label: 'label', text: 'text', source: 'source' },
          }),
        ),
      );
      client['client'].beta.promptCaching.messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toContain('todayInsight');
      }
    });

    it('should return PARSE_ERROR when todayOneThing is missing', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(
        createMockResponse(
          JSON.stringify({
            todayInsight: {
              title: 'title',
              summary: 'summary',
              whyThisMatters: {
                hrv: { headline: 'h', explanation: 'e' },
                sleep: { headline: 'h', explanation: 'e' },
                rhythm: { headline: 'h', explanation: 'e' },
              },
              whatThisMeansForToday: 'what',
            },
            relatedInsight: { label: 'label', text: 'text', source: 'source' },
          }),
        ),
      );
      client['client'].beta.promptCaching.messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toContain('todayOneThing');
      }
    });

    it('should return PARSE_ERROR when icon is invalid', async () => {
      const client = new AnthropicClient('test-api-key');
      const mockCreate = vi.fn().mockResolvedValue(
        createMockResponse(
          JSON.stringify({
            todayInsight: {
              title: 'title',
              summary: 'summary',
              whyThisMatters: {
                hrv: { headline: 'h', explanation: 'e' },
                sleep: { headline: 'h', explanation: 'e' },
                rhythm: { headline: 'h', explanation: 'e' },
              },
              whatThisMeansForToday: 'what',
            },
            todayOneThing: {
              icon: 'invalid_icon',
              action: 'action',
              summary: 'summary',
              time: '14:00',
              whyThisAction: 'why',
              benefits: ['b1', 'b2', 'b3'],
              howToDoIt: ['h1', 'h2', 'h3'],
              expectedBenefit: { text: 'text', source: 'source' },
            },
            relatedInsight: { label: 'label', text: 'text', source: 'source' },
          }),
        ),
      );
      client['client'].beta.promptCaching.messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('PARSE_ERROR');
        expect(result.error.message).toContain('todayOneThing.icon');
      }
    });
  });

  describe('error handling', () => {
    it('should return RATE_LIMIT_ERROR on 429 status', async () => {
      const client = new AnthropicClient('test-api-key');
      // モックされたAnthropic.APIErrorを使用
      const ApiErrorClass = Anthropic.APIError as unknown as new (
        status: number,
        message: string,
      ) => Error & { status: number };
      const apiError = new ApiErrorClass(429, 'Rate limit exceeded');
      const mockCreate = vi.fn().mockRejectedValue(apiError);
      client['client'].beta.promptCaching.messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('RATE_LIMIT_ERROR');
        expect(result.error.message).toBe('Rate limit exceeded');
      }
    });

    it('should return AI_API_ERROR on other API errors', async () => {
      const client = new AnthropicClient('test-api-key');
      // モックされたAnthropic.APIErrorを使用
      const ApiErrorClass = Anthropic.APIError as unknown as new (
        status: number,
        message: string,
      ) => Error & { status: number };
      const apiError = new ApiErrorClass(500, 'Internal server error');
      const mockCreate = vi.fn().mockRejectedValue(apiError);
      client['client'].beta.promptCaching.messages.create = mockCreate;

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
      client['client'].beta.promptCaching.messages.create = mockCreate;

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
      client['client'].beta.promptCaching.messages.create = mockCreate;

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
      client['client'].beta.promptCaching.messages.create = mockCreate;

      const result = await client.generateAdvice(systemPrompt, userDataXml);

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('AI_API_ERROR');
        expect(result.error.details).toBe('string error');
      }
    });
  });
});
