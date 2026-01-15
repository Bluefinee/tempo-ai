/**
 * Mock AI Response Data
 * AI プロンプト仕様書（docs/specs/ai_prompt_spec.md）の出力形式に準拠
 */

import type { AIResponse } from "../../domain/models";

/**
 * AI RESPONSE MOCK DATA
 * Fully compliant with API response format
 * @see docs/specs/ai_prompt_spec.md Section 5.1 (Good Day Scenario)
 */
export const MOCK_AI_RESPONSE: AIResponse = {
  todayInsight: {
    title: "A Quiet Harmony",
    summary:
      "You recovered well last night. With clear skies and stable pressure today, you should feel great. You got plenty of deep sleep and your nervous system is calm. You have the capacity to tackle some challenging work today. Your focus is especially high this morning, so consider tackling important tasks early.",
    whyThisMatters: {
      hrv: {
        headline: "HRV is 6% above baseline",
        explanation:
          "This indicates your parasympathetic nervous system is functioning well. You have high stress resilience and can make calm decisions.",
      },
      sleep: {
        headline: "Deep sleep: 1h 45m (23%)",
        explanation:
          "This signals sufficient growth hormone release. Your muscles and cells have been properly repaired.",
      },
      rhythm: {
        headline: "Bedtime was 15 min late",
        explanation:
          "This is within acceptable range and has minimal impact on today's condition.",
      },
    },
    whatThisMeansForToday:
      "Make the most of your Peak Focus window from 9am to 12pm. This is the ideal time for complex document work or important decisions. Switching to lighter tasks in the afternoon will help maintain your energy throughout the day.",
  },
  todayOneThing: {
    icon: "walking",
    action: "Take a 5-min walk around 2pm",
    summary: "Prevents afternoon drowsiness and improves sleep quality",
    time: "14:00",
    whyThisAction:
      "Between 2-4pm, your circadian rhythm naturally makes you feel drowsy. With stable pressure today, your body is primed for movement. A light walk during this 'Afternoon Dip' can restore alertness without needing coffee. Plus, moderate daytime activity supports melatonin production for better sleep onset.",
    benefits: [
      "Restores afternoon focus",
      "Improves sleep onset at night",
      "Provides a mental refresh",
    ],
    howToDoIt: [
      "Step away from your desk and go outside",
      "Walk at a light pace for about 5 minutes",
      "Try to get some sunlight if possible",
    ],
    expectedBenefit: {
      text: "Short daytime walks have been shown to improve sleep efficiency by 10-15%",
      source: "Circadian Rhythm Research",
    },
  },
  relatedInsight: {
    label: "Research Finding",
    text: "Morning focused work improves productivity by 23%",
    source: "Chronobiology Research",
  },
};
