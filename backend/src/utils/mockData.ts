import type { DailyAdvice, HealthScores } from '../types/domain.js';
import type { AdviceResponse, AdviceResponseData } from '../types/response.js';

// =============================================================================
// Default Mock Scores
// =============================================================================

const defaultMockScores: HealthScores = {
  hrv: 85,
  sleep: 82,
  rhythm: 78,
  activity: 70,
};

// =============================================================================
// Mock Daily Advice Data
// =============================================================================

/**
 * Creates a fixed mock response for Phase 10 development and testing
 *
 * This function generates a complete AdviceResponse with realistic health advice content
 * that matches the new specification with energyComment, insight, and scores.
 *
 * @param scores - Optional health scores to use (defaults to good scores)
 * @returns Immutable AdviceResponse object with mock daily advice
 * @example
 * const mockResponse = createMockAdviceResponse();
 * console.log(mockResponse.data?.mainAdvice.greeting); // "〇〇さん、おはようございます"
 */
export const createMockAdviceResponse = (
  scores: HealthScores = defaultMockScores,
): AdviceResponse => {
  const mockAdvice: DailyAdvice = {
    greeting: '〇〇さん、おはようございます',
    energyComment: '今日は絶好調ですね！',
    condition: {
      summary:
        '昨夜は7時間の良質な睡眠が取れましたね。今朝のHRVは72msと高く、体の回復が十分に進んでいます。今日はトレーニングに最適なコンディションですよ。',
      detail:
        '昨夜は7時間の良質な睡眠が取れましたね。深い睡眠が1時間45分と、筋肉の回復に理想的な状態です。今朝のHRVは72msと、過去7日平均の68msを上回っています。日曜日のアクティブレストが功を奏して、体の回復が十分に進んでいます。今日は晴れて気温も14℃まで上がる予報です。トレーニングに最適なコンディションですよ。午前中の涼しい時間帯に運動を取り入れると、より効果的にパフォーマンスを発揮できるでしょう。',
    },
    insight:
      '昨夜は就寝が23時と30分早かったため、HRVが72msと7日平均より+9%改善しています。さらに3日連続でリズムが安定していることが、回復効率のアップに貢献しています。今日は午後から気圧が下がりますが、これだけコンディションが整っていれば影響は最小限でしょう。',
    dailyTry: {
      title: 'ドロップセット法に挑戦',
      detail:
        '今日のトレーニングで、最後のセットにドロップセット法を取り入れてみませんか？通常の重量でできる限界まで行った後、重量を20-30%下げてさらに限界まで続けます。HRVが高い今日なら、筋肉により深い刺激を与えられます。',
    },
    closingMessage:
      '今日は心身ともに最高のコンディションです。ぜひ全力でチャレンジして、充実した一日をお過ごしください。',
    scores,
    generatedAt: new Date().toISOString(),
    timeSlot: 'morning',
  };

  const responseData: AdviceResponseData = {
    mainAdvice: mockAdvice,
  };

  return {
    success: true,
    data: responseData,
  };
};

// =============================================================================
// Mock Data Variants
// =============================================================================

/**
 * Creates personalized mock response based on user profile
 *
 * Takes the base mock advice and personalizes it by replacing the placeholder
 * nickname with the actual user's nickname using immutable object creation.
 *
 * @param nickname - User's display name for greeting personalization
 * @param scores - Optional health scores to use
 * @returns Immutable AdviceResponse with personalized greeting
 * @example
 * const advice = createPersonalizedMockAdvice("田中");
 * console.log(advice.data?.mainAdvice.greeting); // "田中さん、おはようございます"
 */
export const createPersonalizedMockAdvice = (
  nickname: string,
  scores: HealthScores = defaultMockScores,
): AdviceResponse => {
  const mockResponse = createMockAdviceResponse(scores);

  if (mockResponse.data?.mainAdvice) {
    // Create new objects instead of mutating
    return {
      ...mockResponse,
      data: {
        ...mockResponse.data,
        mainAdvice: {
          ...mockResponse.data.mainAdvice,
          greeting: mockResponse.data.mainAdvice.greeting.replace('〇〇さん', `${nickname}さん`),
        },
      },
    };
  }

  return mockResponse;
};

/**
 * Creates mock response for different time slots with time-appropriate greetings
 *
 * Generates personalized advice that adapts to the time of day:
 * - Morning: "おはようございます" - energy and planning focus
 * - Afternoon: "お疲れさまです" - midday wellness check
 * - Evening: "お疲れさまでした" - recovery and rest focus
 *
 * @param nickname - User's display name for personalized greeting
 * @param timeSlot - Current time slot for appropriate greeting and content tone
 * @param scores - Optional health scores to use
 * @returns Immutable AdviceResponse with time-appropriate personalization
 * @example
 * const morningAdvice = createMockAdviceForTimeSlot("田中", "morning");
 * const eveningAdvice = createMockAdviceForTimeSlot("田中", "evening");
 */
export const createMockAdviceForTimeSlot = (
  nickname: string,
  timeSlot: 'morning' | 'afternoon' | 'evening',
  scores: HealthScores = defaultMockScores,
): AdviceResponse => {
  const mockResponse = createPersonalizedMockAdvice(nickname, scores);

  if (mockResponse.data?.mainAdvice) {
    // Determine greeting based on time slot
    let greeting: string;
    switch (timeSlot) {
      case 'morning':
        greeting = `${nickname}さん、おはようございます`;
        break;
      case 'afternoon':
        greeting = `${nickname}さん、お疲れさまです`;
        break;
      case 'evening':
        greeting = `${nickname}さん、お疲れさまでした`;
        break;
    }

    // Create new objects instead of mutating
    return {
      ...mockResponse,
      data: {
        ...mockResponse.data,
        mainAdvice: {
          ...mockResponse.data.mainAdvice,
          timeSlot,
          greeting,
        },
      },
    };
  }

  return mockResponse;
};
