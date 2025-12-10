import type { DailyAdvice } from '../types/domain.js';
import type { AdviceResponse, AdviceResponseData } from '../types/response.js';

// =============================================================================
// Mock Daily Advice Data
// =============================================================================

/**
 * Creates a fixed mock response for Phase 7 development and testing
 *
 * This function generates a complete AdviceResponse with realistic health advice content
 * that matches the specification from 07-phase-backend-foundation.md
 *
 * @returns Immutable AdviceResponse object with mock daily advice
 * @example
 * const mockResponse = createMockAdviceResponse();
 * console.log(mockResponse.data?.mainAdvice.greeting); // "〇〇さん、おはようございます"
 */
export const createMockAdviceResponse = (): AdviceResponse => {
  const mockAdvice: DailyAdvice = {
    greeting: '〇〇さん、おはようございます',
    condition: {
      summary:
        '昨夜は7時間の良質な睡眠が取れましたね。今朝のHRVは72msと高く、体の回復が十分に進んでいます。今日はトレーニングに最適なコンディションですよ！',
      detail:
        '昨夜は7時間の良質な睡眠が取れましたね。深い睡眠が1時間45分と、筋肉の回復に理想的な状態です。\n\n今朝のHRVは72msと、過去7日平均の68msを上回っています。日曜日のアクティブレストが功を奏して、体の回復が十分に進んでいます。\n\n今日は晴れて気温も14℃まで上がる予報です。トレーニングに最適なコンディションですよ！',
    },
    actionSuggestions: [
      {
        icon: 'fitness',
        title: '午前中に高強度トレーニング',
        detail: 'HRVが高く、睡眠の質も良いため、パフォーマンスを最大限発揮できる状態です。',
      },
      {
        icon: 'nutrition',
        title: 'トレーニング後の栄養補給',
        detail:
          '30分以内にプロテインと炭水化物を一緒に摂ることで、筋グリコーゲンの回復が早まります。',
      },
    ],
    closingMessage:
      '今日は心身ともに最高のコンディションです。ぜひ全力でチャレンジして、充実した一日をお過ごしください。',
    dailyTry: {
      title: 'ドロップセット法に挑戦',
      summary: 'トレーニングの最後に、普段と違う刺激を筋肉に与えてみませんか？',
      detail:
        '今日のトレーニングで、最後のセットにドロップセット法を取り入れてみませんか？通常の重量でできる限界まで行った後、重量を20-30%下げてさらに限界まで続けます。筋繊維により深い刺激を与えることができ、筋肥大効果が期待できます。ただし、フォームが崩れないよう注意し、週に1-2回程度に留めましょう。',
    },
    weeklyTry: undefined, // Phase 7では週次トライは含まない
    generatedAt: new Date().toISOString(),
    timeSlot: 'morning',
  };

  const responseData: AdviceResponseData = {
    mainAdvice: mockAdvice,
    // additionalAdvice は Phase 7 では含まない
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
 * In Phase 7, this provides basic personalization for testing.
 *
 * @param nickname - User's display name for greeting personalization
 * @returns Immutable AdviceResponse with personalized greeting
 * @example
 * const advice = createPersonalizedMockAdvice("田中");
 * console.log(advice.data?.mainAdvice.greeting); // "田中さん、おはようございます"
 */
export const createPersonalizedMockAdvice = (nickname: string): AdviceResponse => {
  const mockResponse = createMockAdviceResponse();

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
 * Phase 7 provides basic time slot adaptation for testing and UI development.
 * Future phases will enhance content based on circadian rhythm analysis.
 *
 * @param nickname - User's display name for personalized greeting
 * @param timeSlot - Current time slot for appropriate greeting and content tone
 * @returns Immutable AdviceResponse with time-appropriate personalization
 * @example
 * const morningAdvice = createMockAdviceForTimeSlot("田中", "morning");
 * const eveningAdvice = createMockAdviceForTimeSlot("田中", "evening");
 */
export const createMockAdviceForTimeSlot = (
  nickname: string,
  timeSlot: 'morning' | 'afternoon' | 'evening',
): AdviceResponse => {
  const mockResponse = createPersonalizedMockAdvice(nickname);

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
