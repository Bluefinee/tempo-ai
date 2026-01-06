import { create } from 'zustand';
import { DailyAdvice, Mood, TodayMode, QuickAction, RecommendedAction } from '../domain/models';
import {
  MOCK_AI_INSIGHT_FULL,
  MOCK_AI_GREETING_SHORT,
  MOCK_QUICK_ACTIONS,
  MOCK_RECOMMENDED_ACTION,
} from '../constants/mockData';

type InsightFeedback = 'helpful' | 'not-helpful' | null;

interface InsightState {
  // Daily insight
  dailyAdvice: DailyAdvice | null;
  shortGreeting: string | null;
  quickActions: QuickAction[];
  recommendedAction: RecommendedAction | null;

  // User check-in
  todayMood: Mood | null;
  todayMode: TodayMode | null;

  // Feedback
  insightFeedback: InsightFeedback;

  // Loading state (for Labor Illusion)
  isGeneratingInsight: boolean;
  generationPhase: number;
  generationMessages: string[];

  // Error state
  insightError: string | null;

  // Last updated
  lastInsightUpdate: Date | null;

  // Actions
  generateDailyInsight: (nickname: string) => Promise<void>;
  setMood: (mood: Mood) => void;
  setTodayMode: (mode: TodayMode) => void;
  setInsightFeedback: (feedback: InsightFeedback) => void;

  // For testing/mock
  setMockInsight: (nickname: string) => void;

  // Reset
  resetInsight: () => void;
}

const GENERATION_MESSAGES = [
  '睡眠データを分析中...',
  'HRVを解析中...',
  'アドバイスを生成中...',
];

export const useInsightStore = create<InsightState>()((set, get) => ({
  dailyAdvice: null,
  shortGreeting: null,
  quickActions: [],
  recommendedAction: null,
  todayMood: null,
  todayMode: null,
  insightFeedback: null,
  isGeneratingInsight: false,
  generationPhase: 0,
  generationMessages: GENERATION_MESSAGES,
  insightError: null,
  lastInsightUpdate: null,

  generateDailyInsight: async (nickname: string) => {
    set({
      isGeneratingInsight: true,
      generationPhase: 0,
      insightError: null,
    });

    try {
      // Labor Illusion: Show progressive loading phases
      for (let phase = 0; phase < GENERATION_MESSAGES.length; phase++) {
        set({ generationPhase: phase });
        await new Promise((resolve) => setTimeout(resolve, 800));
      }

      // TODO: Replace with actual API call
      // For now, use mock data
      const insight = MOCK_AI_INSIGHT_FULL(nickname);
      const greeting = MOCK_AI_GREETING_SHORT(nickname);

      // Small delay before showing result
      await new Promise((resolve) => setTimeout(resolve, 500));

      set({
        dailyAdvice: {
          id: `advice_${Date.now()}`,
          date: new Date(),
          greeting: insight.greeting,
          condition: insight.condition,
          sleep: insight.sleep,
          rhythm: insight.rhythm,
          environment: insight.environment,
          advice: insight.advice,
          closing: insight.closing,
        },
        shortGreeting: greeting,
        quickActions: MOCK_QUICK_ACTIONS,
        recommendedAction: MOCK_RECOMMENDED_ACTION,
        isGeneratingInsight: false,
        lastInsightUpdate: new Date(),
      });
    } catch (error) {
      set({
        isGeneratingInsight: false,
        insightError: error instanceof Error ? error.message : 'Failed to generate insight',
      });
    }
  },

  setMood: (mood) => set({ todayMood: mood }),

  setTodayMode: (mode) => set({ todayMode: mode }),

  setInsightFeedback: (feedback) => {
    set({ insightFeedback: feedback });
    // TODO: Send feedback to backend
  },

  setMockInsight: (nickname: string) => {
    const insight = MOCK_AI_INSIGHT_FULL(nickname);
    const greeting = MOCK_AI_GREETING_SHORT(nickname);

    set({
      dailyAdvice: {
        id: `advice_${Date.now()}`,
        date: new Date(),
        greeting: insight.greeting,
        condition: insight.condition,
        sleep: insight.sleep,
        rhythm: insight.rhythm,
        environment: insight.environment,
        advice: insight.advice,
        closing: insight.closing,
      },
      shortGreeting: greeting,
      quickActions: MOCK_QUICK_ACTIONS,
      recommendedAction: MOCK_RECOMMENDED_ACTION,
      lastInsightUpdate: new Date(),
    });
  },

  resetInsight: () =>
    set({
      dailyAdvice: null,
      shortGreeting: null,
      quickActions: [],
      recommendedAction: null,
      todayMood: null,
      todayMode: null,
      insightFeedback: null,
      isGeneratingInsight: false,
      generationPhase: 0,
      insightError: null,
      lastInsightUpdate: null,
    }),
}));

// Selectors
export const selectCurrentGenerationMessage = (state: InsightState): string =>
  state.generationMessages[state.generationPhase] || '';

export const selectIsInsightStale = (state: InsightState): boolean => {
  if (!state.lastInsightUpdate) return true;
  const lastUpdate = state.lastInsightUpdate;
  const now = new Date();
  // Stale if not from today
  return (
    lastUpdate.getDate() !== now.getDate() ||
    lastUpdate.getMonth() !== now.getMonth() ||
    lastUpdate.getFullYear() !== now.getFullYear()
  );
};
