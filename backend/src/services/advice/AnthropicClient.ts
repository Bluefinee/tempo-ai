import Anthropic from '@anthropic-ai/sdk';
import type { PromptCachingBetaMessage } from '@anthropic-ai/sdk/resources/beta/prompt-caching/messages';
import { type Result, err, ok } from '../../utils/result';
import type { AdviceError, ClaudeAdviceOutput, OneThingIcon } from './types';

/**
 * Anthropic API クライアント（Prompt Caching対応）
 * @see docs/specs/tempoai_ai_prompt_spec.md
 */
export class AnthropicClient {
  private readonly client: Anthropic;
  private readonly model: string = 'claude-sonnet-4-20250514';
  private readonly maxTokens: number = 2000;

  /**
   * AnthropicClientを初期化
   * @param apiKey - Anthropic APIキー
   */
  constructor(apiKey: string) {
    this.client = new Anthropic({ apiKey });
  }

  /**
   * アドバイスを生成
   * @param systemPrompt - System Prompt（キャッシュ対象）
   * @param userDataXml - User Data XML
   * @returns Result<ClaudeAdviceOutput, AdviceError>
   */
  generateAdvice = async (
    systemPrompt: string,
    userDataXml: string,
  ): Promise<Result<ClaudeAdviceOutput, AdviceError>> => {
    try {
      const response = await this.client.beta.promptCaching.messages.create({
        model: this.model,
        max_tokens: this.maxTokens,
        system: [
          {
            type: 'text',
            text: systemPrompt,
            cache_control: { type: 'ephemeral' },
          },
        ],
        messages: [{ role: 'user', content: userDataXml }],
      });

      return this.parseResponse(response);
    } catch (error) {
      return this.handleError(error);
    }
  };

  /**
   * APIレスポンスをパース
   */
  private parseResponse = (
    response: PromptCachingBetaMessage,
  ): Result<ClaudeAdviceOutput, AdviceError> => {
    const textBlock = response.content.find(
      (block): block is Anthropic.TextBlock => block.type === 'text',
    );

    if (!textBlock) {
      return err({
        code: 'PARSE_ERROR',
        message: 'No text content in response',
      });
    }

    try {
      const jsonMatch = textBlock.text.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        return err({
          code: 'PARSE_ERROR',
          message: 'No JSON found in response',
        });
      }

      const parsed = JSON.parse(jsonMatch[0]) as {
        todayInsight?: {
          title?: string;
          summary?: string;
          whyThisMatters?: {
            hrv?: { headline?: string; explanation?: string };
            sleep?: { headline?: string; explanation?: string };
            rhythm?: { headline?: string; explanation?: string };
          };
          whatThisMeansForToday?: string;
        };
        todayOneThing?: {
          icon?: string;
          action?: string;
          summary?: string;
          time?: string;
          whyThisAction?: string;
          benefits?: string[];
          howToDoIt?: string[];
          expectedBenefit?: {
            text?: string;
            source?: string;
          };
        };
        relatedInsight?: {
          label?: string;
          text?: string;
          source?: string;
        };
      };

      // todayInsight validation
      if (!parsed.todayInsight || typeof parsed.todayInsight !== 'object') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayInsight field',
        });
      }
      if (!parsed.todayInsight.title || typeof parsed.todayInsight.title !== 'string') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayInsight.title field',
        });
      }
      if (!parsed.todayInsight.summary || typeof parsed.todayInsight.summary !== 'string') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayInsight.summary field',
        });
      }
      if (
        !parsed.todayInsight.whyThisMatters ||
        typeof parsed.todayInsight.whyThisMatters !== 'object'
      ) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayInsight.whyThisMatters field',
        });
      }

      // Validate whyThisMatters sub-fields
      const whyMattersFields = ['hrv', 'sleep', 'rhythm'] as const;
      for (const field of whyMattersFields) {
        const item = parsed.todayInsight.whyThisMatters[field];
        if (!item || typeof item !== 'object' || !item.headline || !item.explanation) {
          return err({
            code: 'PARSE_ERROR',
            message: `Missing or invalid todayInsight.whyThisMatters.${field} field`,
          });
        }
      }

      if (
        !parsed.todayInsight.whatThisMeansForToday ||
        typeof parsed.todayInsight.whatThisMeansForToday !== 'string'
      ) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayInsight.whatThisMeansForToday field',
        });
      }

      // todayOneThing validation
      if (!parsed.todayOneThing || typeof parsed.todayOneThing !== 'object') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayOneThing field',
        });
      }
      if (!this.isValidOneThingIcon(parsed.todayOneThing.icon)) {
        return err({
          code: 'PARSE_ERROR',
          message: `Invalid todayOneThing.icon: ${parsed.todayOneThing.icon}`,
        });
      }
      if (!parsed.todayOneThing.action || typeof parsed.todayOneThing.action !== 'string') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayOneThing.action field',
        });
      }
      if (!parsed.todayOneThing.summary || typeof parsed.todayOneThing.summary !== 'string') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayOneThing.summary field',
        });
      }
      if (!parsed.todayOneThing.time || typeof parsed.todayOneThing.time !== 'string') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayOneThing.time field',
        });
      }
      if (
        !parsed.todayOneThing.whyThisAction ||
        typeof parsed.todayOneThing.whyThisAction !== 'string'
      ) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayOneThing.whyThisAction field',
        });
      }
      if (
        !Array.isArray(parsed.todayOneThing.benefits) ||
        parsed.todayOneThing.benefits.length === 0
      ) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayOneThing.benefits field',
        });
      }
      if (
        !Array.isArray(parsed.todayOneThing.howToDoIt) ||
        parsed.todayOneThing.howToDoIt.length === 0
      ) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayOneThing.howToDoIt field',
        });
      }
      if (
        !parsed.todayOneThing.expectedBenefit ||
        typeof parsed.todayOneThing.expectedBenefit !== 'object'
      ) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayOneThing.expectedBenefit field',
        });
      }
      if (
        !parsed.todayOneThing.expectedBenefit.text ||
        !parsed.todayOneThing.expectedBenefit.source
      ) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid todayOneThing.expectedBenefit.text or source field',
        });
      }

      // relatedInsight validation
      if (!parsed.relatedInsight || typeof parsed.relatedInsight !== 'object') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid relatedInsight field',
        });
      }
      if (!parsed.relatedInsight.label || typeof parsed.relatedInsight.label !== 'string') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid relatedInsight.label field',
        });
      }
      if (!parsed.relatedInsight.text || typeof parsed.relatedInsight.text !== 'string') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid relatedInsight.text field',
        });
      }
      if (!parsed.relatedInsight.source || typeof parsed.relatedInsight.source !== 'string') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid relatedInsight.source field',
        });
      }

      return ok({
        todayInsight: {
          title: parsed.todayInsight.title,
          summary: parsed.todayInsight.summary,
          whyThisMatters: {
            hrv: {
              headline: parsed.todayInsight.whyThisMatters.hrv?.headline ?? '',
              explanation: parsed.todayInsight.whyThisMatters.hrv?.explanation ?? '',
            },
            sleep: {
              headline: parsed.todayInsight.whyThisMatters.sleep?.headline ?? '',
              explanation: parsed.todayInsight.whyThisMatters.sleep?.explanation ?? '',
            },
            rhythm: {
              headline: parsed.todayInsight.whyThisMatters.rhythm?.headline ?? '',
              explanation: parsed.todayInsight.whyThisMatters.rhythm?.explanation ?? '',
            },
          },
          whatThisMeansForToday: parsed.todayInsight.whatThisMeansForToday,
        },
        todayOneThing: {
          icon: parsed.todayOneThing.icon as OneThingIcon,
          action: parsed.todayOneThing.action,
          summary: parsed.todayOneThing.summary,
          time: parsed.todayOneThing.time,
          whyThisAction: parsed.todayOneThing.whyThisAction,
          benefits: parsed.todayOneThing.benefits,
          howToDoIt: parsed.todayOneThing.howToDoIt,
          expectedBenefit: {
            text: parsed.todayOneThing.expectedBenefit.text ?? '',
            source: parsed.todayOneThing.expectedBenefit.source ?? '',
          },
        },
        relatedInsight: {
          label: parsed.relatedInsight.label,
          text: parsed.relatedInsight.text,
          source: parsed.relatedInsight.source,
        },
      });
    } catch (parseError) {
      return err({
        code: 'PARSE_ERROR',
        message: 'Failed to parse JSON response',
        details: parseError instanceof Error ? parseError.message : String(parseError),
      });
    }
  };

  /**
   * OneThingIconのバリデーション
   */
  private isValidOneThingIcon = (icon: unknown): icon is OneThingIcon => {
    return (
      typeof icon === 'string' && ['walking', 'breathing', 'rest', 'coffee', 'sun'].includes(icon)
    );
  };

  /**
   * エラーハンドリング
   */
  private handleError = (error: unknown): Result<ClaudeAdviceOutput, AdviceError> => {
    if (error instanceof Anthropic.APIError) {
      if (error.status === 429) {
        return err({
          code: 'RATE_LIMIT_ERROR',
          message: 'Rate limit exceeded',
          details: error.message,
        });
      }

      return err({
        code: 'AI_API_ERROR',
        message: `Anthropic API error: ${error.status}`,
        details: error.message,
      });
    }

    if (error instanceof Error) {
      if (
        error.message.includes('fetch') ||
        error.message.includes('network') ||
        error.message.includes('ECONNREFUSED')
      ) {
        return err({
          code: 'NETWORK_ERROR',
          message: 'Network error occurred',
          details: error.message,
        });
      }

      return err({
        code: 'AI_API_ERROR',
        message: 'Unknown API error',
        details: error.message,
      });
    }

    return err({
      code: 'AI_API_ERROR',
      message: 'Unknown error occurred',
      details: String(error),
    });
  };
}
