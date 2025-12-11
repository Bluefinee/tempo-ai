import Anthropic from "@anthropic-ai/sdk";
import type { DailyAdvice } from "../types/domain.js";
import type { 
  GenerateAdviceParams, 
  AdditionalAdviceParams, 
  AdditionalAdvice
} from "../types/claude.js";
import { buildSystemPrompt, buildAdditionalAdviceSystemPrompt } from "../prompts/system.js";
import { getExamplesForInterest, buildUserDataPrompt, buildAdditionalAdviceUserPrompt } from "../utils/prompt.js";
import { ValidationError, ClaudeApiError } from "../utils/errors.js";

/**
 * Claude Sonnet を用いてメインの朝アドバイスを生成します
 * 
 * 3層プロンプト構造（システム・例文・ユーザーデータ）でPrompt Cachingを活用し、
 * ユーザーの健康データと環境データを統合分析してパーソナライズされたアドバイスを生成します。
 *
 * @param params ユーザー情報・ヘルスデータ・環境データ・APIキーなどのリクエストパラメータ
 * @returns バリデーション済みの `DailyAdvice`。JSONパース/バリデーション失敗時はフォールバックを返します
 * @throws {ClaudeApiError} Claude API呼び出しエラーや予期しない例外時
 */
export const generateMainAdvice = async (
  params: GenerateAdviceParams
): Promise<DailyAdvice> => {
  const client = new Anthropic({ apiKey: params.apiKey });

  try {
    const systemPrompt = buildSystemPrompt();
    const examples = getExamplesForInterest(params.userProfile.interests[0]);
    const userData = buildUserDataPrompt(params);

    const response = await client.messages.create({
      model: "claude-sonnet-4-20250514",
      max_tokens: 4096,
      system: [
        systemPrompt,
        examples,
      ],
      messages: [
        {
          role: "user",
          content: userData,
        },
      ],
    });

    return parseAdviceResponse(response, params);
  } catch (error) {
    console.error("[Claude] Main advice generation failed:", error);
    
    if (error instanceof ClaudeApiError || error instanceof ValidationError) {
      throw error;
    }
    
    // Anthropic SDK エラーの場合
    if (error instanceof Error) {
      throw new ClaudeApiError(
        `Claude API request failed: ${error.message}`,
        500,
        error
      );
    }
    
    throw new ClaudeApiError("Unknown error occurred while generating advice");
  }
};

/**
 * Claude Haiku を用いて追加アドバイス（昼間・夕方）を生成します
 * 
 * 朝のメインアドバイスを補完する短文のアドバイスを低コストで生成し、
 * 時間帯に応じた適切なメッセージを提供します。
 *
 * @param params メインアドバイス・時間帯・ユーザー情報・APIキーを含むパラメータ
 * @returns 時間帯に適した `AdditionalAdvice`
 * @throws {ClaudeApiError} Claude API呼び出しエラーや予期しない例外時
 */
export const generateAdditionalAdvice = async (
  params: AdditionalAdviceParams
): Promise<AdditionalAdvice> => {
  const client = new Anthropic({ apiKey: params.apiKey });

  try {
    const systemPrompt = buildAdditionalAdviceSystemPrompt();
    const userPrompt = buildAdditionalAdviceUserPrompt(params);

    const response = await client.messages.create({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 1024,
      system: systemPrompt,
      messages: [
        {
          role: "user",
          content: userPrompt,
        },
      ],
    });

    return parseAdditionalAdviceResponse(response, params);
  } catch (error) {
    console.error("[Claude] Additional advice generation failed:", error);
    
    if (error instanceof ClaudeApiError || error instanceof ValidationError) {
      throw error;
    }
    
    if (error instanceof Error) {
      throw new ClaudeApiError(
        `Claude API request failed: ${error.message}`,
        500,
        error
      );
    }
    
    throw new ClaudeApiError("Unknown error occurred while generating additional advice");
  }
};

const parseAdviceResponse = (response: Anthropic.Message, params: GenerateAdviceParams): DailyAdvice => {
  const textContent = response.content.find((c): c is Extract<typeof c, { type: "text" }> => c.type === "text");
  if (!textContent) {
    throw new ClaudeApiError("No text content in Claude response");
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
    
    // 自動的に現在時刻とタイムスロットを設定
    const advice = parsed as DailyAdvice;
    advice.generatedAt = new Date().toISOString();
    advice.timeSlot = "morning";
    
    return advice;
  } catch (parseError) {
    console.error("[Claude] JSON parse failed:", parseError);
    console.error("[Claude] Raw response:", jsonString);
    
    // パースに失敗した場合はフォールバック
    return createFallbackAdvice(params.userProfile.nickname);
  }
};

const parseAdditionalAdviceResponse = (
  response: Anthropic.Message, 
  params: AdditionalAdviceParams
): AdditionalAdvice => {
  const textContent = response.content.find((c): c is Extract<typeof c, { type: "text" }> => c.type === "text");
  if (!textContent) {
    throw new ClaudeApiError("No text content in Claude response");
  }

  let jsonString = textContent.text.trim();
  
  const jsonMatch = jsonString.match(/```json\s*([\s\S]*?)\s*```/);
  if (jsonMatch?.[1]) {
    jsonString = jsonMatch[1].trim();
  }

  try {
    const parsed = JSON.parse(jsonString);
    validateAdditionalAdvice(parsed);
    
    const advice = parsed as AdditionalAdvice;
    advice.generatedAt = new Date().toISOString();
    advice.timeSlot = params.timeSlot;
    
    return advice;
  } catch (parseError) {
    console.error("[Claude] Additional advice JSON parse failed:", parseError);
    
    return createFallbackAdditionalAdvice(
      params.userProfile.nickname, 
      params.timeSlot
    );
  }
};

const validateDailyAdvice = (data: unknown): void => {
  if (typeof data !== "object" || data === null) {
    throw new ValidationError("Invalid response: not an object", "root", data);
  }

  const advice = data as Record<string, unknown>;

  if (typeof advice["greeting"] !== "string") {
    throw new ValidationError("Missing or invalid greeting", "greeting", advice["greeting"]);
  }
  
  if (typeof advice["condition"] !== "object" || advice["condition"] === null) {
    throw new ValidationError("Missing or invalid condition", "condition", advice["condition"]);
  }
  
  const condition = advice["condition"] as Record<string, unknown>;
  if (typeof condition["summary"] !== "string" || typeof condition["detail"] !== "string") {
    throw new ValidationError("Invalid condition structure", "condition", condition);
  }

  if (!Array.isArray(advice["actionSuggestions"])) {
    throw new ValidationError("Missing or invalid actionSuggestions", "actionSuggestions", advice["actionSuggestions"]);
  }

  if (typeof advice["closingMessage"] !== "string") {
    throw new ValidationError("Missing or invalid closingMessage", "closingMessage", advice["closingMessage"]);
  }

  if (typeof advice["dailyTry"] !== "object" || advice["dailyTry"] === null) {
    throw new ValidationError("Missing or invalid dailyTry", "dailyTry", advice["dailyTry"]);
  }
  
  const dailyTry = advice["dailyTry"] as Record<string, unknown>;
  if (typeof dailyTry["title"] !== "string" || 
      typeof dailyTry["summary"] !== "string" || 
      typeof dailyTry["detail"] !== "string") {
    throw new ValidationError("Invalid dailyTry structure", "dailyTry", dailyTry);
  }
};

const validateAdditionalAdvice = (data: unknown): void => {
  if (typeof data !== "object" || data === null) {
    throw new ValidationError("Invalid additional advice: not an object", "root", data);
  }

  const advice = data as Record<string, unknown>;

  if (typeof advice["greeting"] !== "string") {
    throw new ValidationError("Missing or invalid greeting", "greeting", advice["greeting"]);
  }

  if (typeof advice["message"] !== "string") {
    throw new ValidationError("Missing or invalid message", "message", advice["message"]);
  }
};

/**
 * AI生成が失敗した場合の汎用フォールバックアドバイスを作成します
 * 
 * Claude API の障害やタイムアウト時に、基本的な健康アドバイスを提供し、
 * サービスの継続性を確保します。
 *
 * @param nickname ユーザーのニックネーム（挨拶に使用）
 * @returns 汎用的な `DailyAdvice` オブジェクト
 */
export const createFallbackAdvice = (nickname: string): DailyAdvice => ({
  greeting: `${nickname}さん、おはようございます`,
  condition: {
    summary: "今日も一日、あなたのペースで過ごしていきましょう。",
    detail: "本日のアドバイスを生成できませんでした。ヘルスケアデータと環境情報を確認して、また後でお試しください。",
  },
  actionSuggestions: [
    {
      icon: "hydration",
      title: "こまめな水分補給を",
      detail: "1日を通して、こまめに水分を補給しましょう。",
    },
    {
      icon: "mental",
      title: "深呼吸でリラックス",
      detail: "ゆっくりと深呼吸をして、心を落ち着けてみませんか？",
    },
  ],
  closingMessage: "今日も良い一日をお過ごしください。",
  dailyTry: {
    title: "深呼吸を3回",
    summary: "ゆっくりと深呼吸をして、心を落ち着けてみませんか？",
    detail: "鼻から4秒で吸って、7秒間息を止め、口から8秒でゆっくり吐き出してみてください。",
  },
  weeklyTry: undefined,
  generatedAt: new Date().toISOString(),
  timeSlot: "morning",
});

/**
 * 追加アドバイス生成失敗時に使用するフォールバックを生成します
 * 
 * Claude Haiku API の障害や応答エラー時に、基本的なメッセージを提供し、
 * 時間帯に適したフォールバック体験を確保します。
 *
 * @param nickname ユーザーのニックネーム（挨拶に使用）
 * @param timeSlot "midday" または "evening"
 * @returns 基本的なメッセージを含む AdditionalAdvice オブジェクト
 */
export const createFallbackAdditionalAdvice = (
  nickname: string, 
  timeSlot: "midday" | "evening"
): AdditionalAdvice => {
  const timeText = timeSlot === "midday" ? "お疲れ様です" : "お疲れ様でした";
  const message = timeSlot === "midday" 
    ? "午後も無理をせず、ご自分のペースで進めてくださいね。"
    : "今日も一日お疲れ様でした。ゆっくりと休息をお取りください。";
  
  return {
    greeting: `${nickname}さん、${timeText}`,
    message,
    actionSuggestion: {
      icon: "hydration",
      title: "水分補給を忘れずに",
      detail: "こまめな水分補給で体調を維持しましょう。",
    },
    generatedAt: new Date().toISOString(),
    timeSlot,
  };
};