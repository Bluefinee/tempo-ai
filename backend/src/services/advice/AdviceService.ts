import { type Result, err, ok } from '../../utils/result';
import { AnthropicClient } from './AnthropicClient';
import { PromptBuilder } from './PromptBuilder';
import {
  type AdviceError,
  type AdviceRequest,
  AdviceRequestSchema,
  type AdviceResponse,
} from './types';

/**
 * アドバイス生成サービス
 * PromptBuilderとAnthropicClientを組み合わせてアドバイスを生成
 */
export class AdviceService {
  private readonly client: AnthropicClient;

  /**
   * AdviceServiceを初期化
   * @param apiKey - Anthropic APIキー
   */
  constructor(apiKey: string) {
    this.client = new AnthropicClient(apiKey);
  }

  /**
   * アドバイスを生成
   * @param requestData - リクエストデータ（未検証）
   * @returns Result<AdviceResponse, AdviceError>
   */
  generateAdvice = async (requestData: unknown): Promise<Result<AdviceResponse, AdviceError>> => {
    // バリデーション
    const parseResult = AdviceRequestSchema.safeParse(requestData);
    if (!parseResult.success) {
      return err({
        code: 'INVALID_REQUEST',
        message: 'Invalid request data',
        details: parseResult.error.format(),
      });
    }

    const request: AdviceRequest = parseResult.data;

    // プロンプト構築
    const systemPrompt = PromptBuilder.buildSystemPrompt();
    const userDataXml = PromptBuilder.buildUserDataXml(request);

    // AI呼び出し
    return await this.client.generateAdvice(systemPrompt, userDataXml);
  };
}
