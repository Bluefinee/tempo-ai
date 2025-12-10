import type { DailyAdvice } from '../types/domain.js';
import type { AdviceResponse, AdviceResponseData } from '../types/response.js';

// =============================================================================
// Mock Daily Advice Data
// =============================================================================

/**
 * Fixed mock response for Phase 7 development
 * This matches the specification from 07-phase-backend-foundation.md
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
 * In Phase 7, this just returns the base mock with nickname replacement
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
 * Mock response for different time slots
 * Phase 7 focuses on morning advice, but provides structure for future phases
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
