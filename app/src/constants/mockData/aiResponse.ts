/**
 * Mock AI Response Data
 * AI プロンプト仕様書（docs/specs/ai_prompt_spec.md）の出力形式に準拠
 */

import type { AIResponse } from "../../domain/models";

/**
 * AI RESPONSE MOCK DATA
 * APIから返却されるレスポンス形式に完全準拠
 * @see docs/specs/ai_prompt_spec.md Section 5.1 (良い日のシナリオ)
 */
export const MOCK_AI_RESPONSE: AIResponse = {
  todayInsight: {
    title: "A Quiet Harmony",
    summary:
      "昨夜はしっかり回復できましたね。今日は晴れで気圧も安定しているので、体調は良好なはず。深い睡眠が十分に取れていて、自律神経も落ち着いた状態です。今日は少し負荷のかかる仕事にも取り組める余裕があります。午前中の集中力が特に高まっているので、大事なタスクは早めに片付けてしまいましょう。",
    whyThisMatters: {
      hrv: {
        headline: "HRVがベースラインより6%高い",
        explanation:
          "副交感神経がしっかり働いている証拠です。ストレスへの耐性が高く、落ち着いて判断できる状態にあります。",
      },
      sleep: {
        headline: "深い睡眠が1時間45分（23%）",
        explanation:
          "成長ホルモンの分泌が十分だったサインです。筋肉や細胞の修復がしっかり行われました。",
      },
      rhythm: {
        headline: "就寝が目標より15分遅れ",
        explanation:
          "許容範囲内のズレです。今日のコンディションにはほとんど影響していません。",
      },
    },
    whatThisMeansForToday:
      "9時〜12時のPeak Focus時間帯をぜひご活用ください。複雑な資料作成や重要な意思決定は、この時間帯に集中して取り組むのがおすすめです。午後は軽めのタスクに切り替えると、1日を通してエネルギーを維持できます。",
  },
  todayOneThing: {
    icon: "walking",
    action: "14時頃に5分だけ外を歩く",
    summary: "午後の眠気を防ぎ、夜の睡眠の質も上がります",
    time: "14:00",
    whyThisAction:
      "14時〜16時は、体内時計の影響で自然と眠気が出やすい時間帯です。今日は気圧が安定しているので、体が動きやすい日です。この「Afternoon Dip」のタイミングで軽く体を動かすと、コーヒーに頼らなくても覚醒度が戻ります。さらに、日中の適度な活動は夜のメラトニン分泌を助け、寝つきが良くなる効果もあります。",
    benefits: [
      "午後の集中力が回復する",
      "夜の寝つきが良くなる",
      "気分転換になる",
    ],
    howToDoIt: [
      "デスクを離れて外に出る",
      "5分ほど軽いペースで歩く",
      "できれば日光を浴びる",
    ],
    expectedBenefit: {
      text: "日中の短い散歩は、睡眠効率を10〜15%改善するという報告があります",
      source: "サーカディアンリズム研究",
    },
  },
  relatedInsight: {
    label: "Research Finding",
    text: "午前中の集中作業で生産性が23%向上",
    source: "時間生物学研究",
  },
};
