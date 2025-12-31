import Anthropic from '@anthropic-ai/sdk';
import type { DailyAdvice } from '../types/domain.js';
import type { GenerateAdviceParams } from '../types/claude.js';
import { buildSystemPrompt } from '../prompts/system.js';
import { getExamplesForInterest, buildUserDataPrompt } from '../utils/prompt.js';
import { ValidationError, ClaudeApiError } from '../utils/errors.js';

type TimeSlot = 'morning' | 'afternoon' | 'evening';

/**
 * ISO時刻文字列から時間帯を導出します
 * 注: 時刻はUTCとして解釈され、そのまま時間帯を判定します
 *
 * @param isoTime - ISO 8601形式の時刻文字列
 * @returns 'morning' (0-11時), 'afternoon' (12-17時), 'evening' (18-23時)
 */
const getTimeSlotFromTime = (isoTime: string): TimeSlot => {
  const hour = new Date(isoTime).getUTCHours();
  if (hour < 12) return 'morning';
  if (hour < 18) return 'afternoon';
  return 'evening';
};

/**
 * Claude Sonnet を用いてメインの朝アドバイスを生成します
 *
 * 3層プロンプト構造（システム・例文・ユーザーデータ）でPrompt Cachingを活用し、
 * ユーザーの健康データと環境データを統合分析してパーソナライズされたアドバイスを生成します。
 *
 * @param params - 生成パラメータ
 * @param params.userProfile - ユーザープロフィール（年齢、性別、関心ごと等）
 * @param params.healthData - HealthKitデータ（睡眠、HRV、活動量等）
 * @param params.weatherData - 気象データ（温度、湿度、UV指数等、取得失敗時undefined）
 * @param params.airQualityData - 大気汚染データ（AQI、PM2.5等、取得失敗時undefined）
 * @param params.context - リクエストコンテキスト（時刻、曜日、履歴等）
 * @param params.apiKey - Claude API認証キー
 * @returns バリデーション済みの `DailyAdvice` オブジェクト
 * @throws {ClaudeApiError} Claude API呼び出し失敗、ネットワークエラー、認証エラー時
 * @throws {ValidationError} JSONパース・バリデーション失敗時（自動的にフォールバック処理）
 *
 * @example
 * ```typescript
 * const advice = await generateMainAdvice({
 *   userProfile: { nickname: '田中', age: 28, ... },
 *   healthData: { sleep: { durationHours: 7.5 }, ... },
 *   weatherData: { condition: '晴れ', tempCurrentC: 22, ... },
 *   context: { currentTime: '2025-12-11T07:00:00Z', ... },
 *   apiKey: 'claude-api-key'
 * });
 * console.log(advice.greeting); // "田中さん、おはようございます"
 * ```
 */
export const generateMainAdvice = async (params: GenerateAdviceParams): Promise<DailyAdvice> => {
  const client = new Anthropic({ apiKey: params.apiKey });

  try {
    const systemPrompt = buildSystemPrompt();
    const examples = getExamplesForInterest(params.userProfile.interests[0]);
    const userData = buildUserDataPrompt(params);

    const response = await client.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 4096,
      system: [systemPrompt, examples],
      messages: [
        {
          role: 'user',
          content: userData,
        },
      ],
    });

    return parseAdviceResponse(response, params);
  } catch (error) {
    console.error('[Claude] Main advice generation failed:', error);

    if (error instanceof ClaudeApiError || error instanceof ValidationError) {
      throw error;
    }

    // Anthropic SDK エラーの場合
    if (error instanceof Error) {
      throw new ClaudeApiError(`Claude API request failed: ${error.message}`, 500, error);
    }

    throw new ClaudeApiError('Unknown error occurred while generating advice');
  }
};

const parseAdviceResponse = (
  response: Anthropic.Message,
  params: GenerateAdviceParams,
): DailyAdvice => {
  const textContent = response.content.find(
    (c): c is Extract<typeof c, { type: 'text' }> => c.type === 'text',
  );
  if (!textContent) {
    throw new ClaudeApiError('No text content in Claude response');
  }

  let jsonString = textContent.text.trim();

  // JSONブロック（```json ... ```）の抽出を試行
  const jsonMatch = jsonString.match(/```json\s*([\s\S]*?)\s*```/);
  if (jsonMatch?.[1]) {
    jsonString = jsonMatch[1].trim();
  }

  try {
    const parsed = JSON.parse(jsonString);
    validateDailyAdvice(parsed);

    // スネークケースからキャメルケースへ変換
    const advice: DailyAdvice = {
      greeting: parsed.greeting,
      energyComment: parsed.energy_comment,
      condition: parsed.condition,
      insight: parsed.insight,
      dailyTry: {
        title: parsed.daily_try.title,
        detail: parsed.daily_try.detail,
      },
      closingMessage: parsed.closing_message,
      scores: params.healthData.scores, // スコアはリクエストから取得
      generatedAt: new Date().toISOString(),
      timeSlot: getTimeSlotFromTime(params.context.currentTime),
    };

    return advice;
  } catch (parseError) {
    console.error('[Claude] JSON parse failed:', parseError);
    console.error('[Claude] Raw response:', jsonString);

    // パースに失敗した場合はフォールバック
    return createFallbackAdvice(
      params.userProfile.nickname,
      params.healthData.scores,
      params.context.currentTime,
    );
  }
};

const validateDailyAdvice = (data: unknown): void => {
  if (typeof data !== 'object' || data === null) {
    throw new ValidationError('Invalid response: not an object', 'root', data);
  }

  const advice = data as Record<string, unknown>;

  if (typeof advice['greeting'] !== 'string') {
    throw new ValidationError('Missing or invalid greeting', 'greeting', advice['greeting']);
  }

  if (typeof advice['energy_comment'] !== 'string') {
    throw new ValidationError(
      'Missing or invalid energy_comment',
      'energy_comment',
      advice['energy_comment'],
    );
  }

  if (typeof advice['condition'] !== 'object' || advice['condition'] === null) {
    throw new ValidationError('Missing or invalid condition', 'condition', advice['condition']);
  }

  const condition = advice['condition'] as Record<string, unknown>;
  if (typeof condition['summary'] !== 'string' || typeof condition['detail'] !== 'string') {
    throw new ValidationError('Invalid condition structure', 'condition', condition);
  }

  if (typeof advice['insight'] !== 'string') {
    throw new ValidationError('Missing or invalid insight', 'insight', advice['insight']);
  }

  if (typeof advice['daily_try'] !== 'object' || advice['daily_try'] === null) {
    throw new ValidationError('Missing or invalid daily_try', 'daily_try', advice['daily_try']);
  }

  const dailyTry = advice['daily_try'] as Record<string, unknown>;
  if (typeof dailyTry['title'] !== 'string' || typeof dailyTry['detail'] !== 'string') {
    throw new ValidationError('Invalid daily_try structure', 'daily_try', dailyTry);
  }

  if (typeof advice['closing_message'] !== 'string') {
    throw new ValidationError(
      'Missing or invalid closing_message',
      'closing_message',
      advice['closing_message'],
    );
  }
};

/**
 * AI生成が失敗した場合の汎用フォールバックアドバイスを作成します
 *
 * Claude API の障害、タイムアウト、JSONパースエラー時に基本的な健康アドバイスを提供し、
 * サービスの継続性とユーザー体験を確保します。固定コンテンツで安全性を保証します。
 *
 * @param nickname - ユーザーのニックネーム（挨拶のパーソナライズに使用）
 * @param scores - 健康スコア（HRV、睡眠、リズム、活動量）
 * @returns 汎用的な `DailyAdvice` オブジェクト
 *
 * @example
 * ```typescript
 * try {
 *   const advice = await generateMainAdvice(params);
 * } catch (error) {
 *   const fallback = createFallbackAdvice('田中', { hrv: 70, sleep: 75, rhythm: 80, activity: 60 });
 *   console.log(fallback.greeting); // "田中さん、おはようございます"
 * }
 * ```
 */
export const createFallbackAdvice = (
  nickname: string,
  scores: { hrv: number; sleep: number; rhythm: number; activity: number },
  currentTime: string = new Date().toISOString(),
): DailyAdvice => {
  const timeSlot = getTimeSlotFromTime(currentTime);

  // 時間帯に応じた挨拶
  const getGreeting = (slot: TimeSlot): string => {
    switch (slot) {
      case 'morning':
        return 'おはようございます';
      case 'afternoon':
        return 'お疲れさまです';
      case 'evening':
        return 'お疲れさまでした';
    }
  };
  // HRVスコアに応じたエネルギーコメントを生成（優しいお姉さんのトーン）
  const energyComments = {
    excellent: [
      '今日は絶好調ですね',
      'エネルギー満タン、何でもできそう',
      '体が軽く感じる日ですね',
      'いい感じに整ってますよ',
      'やりたいことに挑戦できる日',
      '調子いいですね、素敵です',
      'パワフルな1日になりそう',
    ],
    good: [
      'いい感じですね',
      '安定したコンディションです',
      '順調な滑り出しですよ',
      'いつも通りのあなたで大丈夫',
      'バランス取れてますね',
      '落ち着いた調子ですね',
    ],
    moderate: [
      '今日はマイペースでいきましょ',
      '大事なことに絞っていこうね',
      'ちょっと省エネモードかな',
      '焦らず、ゆっくりでいいですよ',
      '優先順位をつけて進めましょ',
      'できる範囲で大丈夫ですよ',
    ],
    low: [
      '今日はゆるめに過ごしましょ',
      '体が休みたがってるみたい',
      '自分を甘やかしていい日ですよ',
      '無理しないでね',
      'のんびりいきましょ',
      '頑張りすぎなくて大丈夫',
    ],
    veryLow: [
      'ゆっくり休んでくださいね',
      '今日はお休みモードで',
      '体を休めることも大切ですよ',
      '充電の日にしましょ',
      '何もしなくていい日ですよ',
      'あなたの体を労わってあげて',
    ],
  };

  const getEnergyComment = (hrvScore: number): string => {
    let comments: readonly string[];
    if (hrvScore >= 80) {
      comments = energyComments.excellent;
    } else if (hrvScore >= 60) {
      comments = energyComments.good;
    } else if (hrvScore >= 40) {
      comments = energyComments.moderate;
    } else if (hrvScore >= 20) {
      comments = energyComments.low;
    } else {
      comments = energyComments.veryLow;
    }
    const index = Math.floor(Math.random() * comments.length);
    return comments[index] ?? 'いい感じですね';
  };

  return {
    greeting: `${nickname}さん、${getGreeting(timeSlot)}`,
    energyComment: getEnergyComment(scores.hrv),
    condition: {
      summary:
        '今日も一日、あなたのペースで過ごしていきましょう。体調に合わせて無理なく過ごしてくださいね。',
      detail:
        '本日のアドバイスを生成できませんでした。ヘルスケアデータと環境情報を確認して、また後でお試しください。基本的な水分補給とこまめな休憩を心がけて、リラックスした1日をお過ごしください。',
    },
    insight:
      'アドバイスの生成中に問題が発生しました。ヘルスケアデータは正常に取得できていますので、しばらくしてから再度お試しください。',
    dailyTry: {
      title: '深呼吸を3回',
      detail:
        '鼻から4秒で吸って、7秒間息を止め、口から8秒でゆっくり吐き出してみてください。気持ちを落ち着けるのに効果的です。',
    },
    closingMessage: '今日も良い一日をお過ごしください。',
    scores,
    generatedAt: new Date().toISOString(),
    timeSlot,
  };
};
