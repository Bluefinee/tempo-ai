import Anthropic from '@anthropic-ai/sdk';
import type { PromptCachingBetaMessage } from '@anthropic-ai/sdk/resources/beta/prompt-caching/messages';
import { type Result, err, ok } from '../../utils/result';
import type { AdviceError, AdviceResponse, RecommendedActionType } from './types';

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
   * @returns Result<AdviceResponse, AdviceError>
   */
  generateAdvice = async (
    systemPrompt: string,
    userDataXml: string,
  ): Promise<Result<AdviceResponse, AdviceError>> => {
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
  ): Result<AdviceResponse, AdviceError> => {
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
        summary?: string;
        insight?: {
          greeting?: string;
          condition?: string;
          sleep?: string;
          rhythm?: string;
          environment?: string;
          advice?: string;
          closing?: string;
        };
        recommended_action?: {
          type?: string;
          message?: string;
        };
      };

      // summary validation
      if (!parsed.summary || typeof parsed.summary !== 'string') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid summary field',
        });
      }

      // insight validation
      if (!parsed.insight || typeof parsed.insight !== 'object') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid insight field',
        });
      }

      const insightFields = [
        'greeting',
        'condition',
        'sleep',
        'rhythm',
        'environment',
        'advice',
        'closing',
      ] as const;
      for (const field of insightFields) {
        if (!parsed.insight[field] || typeof parsed.insight[field] !== 'string') {
          return err({
            code: 'PARSE_ERROR',
            message: `Missing or invalid insight.${field} field`,
          });
        }
      }

      // recommended_action validation
      if (!parsed.recommended_action || typeof parsed.recommended_action !== 'object') {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid recommended_action field',
        });
      }

      const actionType = parsed.recommended_action.type;
      if (!this.isValidActionType(actionType)) {
        return err({
          code: 'PARSE_ERROR',
          message: `Invalid recommended_action.type: ${actionType}`,
        });
      }

      if (
        !parsed.recommended_action.message ||
        typeof parsed.recommended_action.message !== 'string'
      ) {
        return err({
          code: 'PARSE_ERROR',
          message: 'Missing or invalid recommended_action.message field',
        });
      }

      // バリデーション済みなので型アサーションを使用
      const insight = parsed.insight as {
        greeting: string;
        condition: string;
        sleep: string;
        rhythm: string;
        environment: string;
        advice: string;
        closing: string;
      };

      return ok({
        summary: parsed.summary,
        insight: {
          greeting: insight.greeting,
          condition: insight.condition,
          sleep: insight.sleep,
          rhythm: insight.rhythm,
          environment: insight.environment,
          advice: insight.advice,
          closing: insight.closing,
        },
        recommendedAction: {
          type: actionType,
          message: parsed.recommended_action.message,
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
   * アクションタイプのバリデーション
   */
  private isValidActionType = (type: unknown): type is RecommendedActionType => {
    return (
      typeof type === 'string' && ['breathing', 'morning_light', 'rest', 'activity'].includes(type)
    );
  };

  /**
   * エラーハンドリング
   */
  private handleError = (error: unknown): Result<AdviceResponse, AdviceError> => {
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

