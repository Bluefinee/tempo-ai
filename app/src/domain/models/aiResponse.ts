/**
 * AI レスポンス型定義
 * @see docs/specs/ai_prompt_spec.md Section 3 output_format
 *
 * このファイルは実APIからのレスポンス形式を定義します。
 * MockDataもこの形式に準拠させることで、API接続時の置き換えが容易になります。
 */

// Today's One Thing のアイコンタイプ
export type OneThingIcon = 'walking' | 'breathing' | 'rest' | 'coffee' | 'sun';

// Related Insight のラベルタイプ
export type RelatedInsightLabel =
  | 'Research Finding'
  | 'Recovery Tip'
  | 'Rhythm Fact'
  | 'Sleep Science'
  | 'Weather Impact';

/**
 * Why This Matters の各項目
 */
export interface WhyThisMattersItem {
  headline: string;     // 例: "HRVがベースラインより6%高い"
  explanation: string;  // 科学的根拠と実感を結びつける説明（2-3文）
}

/**
 * Today's Insight
 * AI Insight カードで表示するメインコンテンツ
 */
export interface TodayInsight {
  title: string;        // 詩的なタイトル（英語、2-4語）例: "A Quiet Harmony"
  summary: string;      // Today画面用のコンディション説明（4-5文、120-180文字）
  whyThisMatters: {
    hrv: WhyThisMattersItem;
    sleep: WhyThisMattersItem;
    rhythm: WhyThisMattersItem;
  };
  whatThisMeansForToday: string; // 今日への実践的なアドバイス（3-4文、100-150文字）
}

/**
 * Expected Benefit（期待される効果）
 */
export interface ExpectedBenefit {
  text: string;    // 科学的根拠に基づく期待効果（50文字程度、具体的な数値を含む）
  source: string;  // 根拠の出典（例: "サーカディアンリズム研究"）
}

/**
 * Today's One Thing
 * 今日のワンアクション
 */
export interface TodayOneThing {
  icon: OneThingIcon;           // アイコンタイプ
  action: string;               // アクション名（25文字以内、時間を含む）
  summary: string;              // 効果の要約（50文字以内）
  time: string | null;          // 推奨時間（HH:MM形式）またはnull
  whyThisAction: string;        // このアクションを推奨する理由（3-4文）
  benefits: [string, string, string]; // 期待される効果（各20文字以内）
  howToDoIt: [string, string, string]; // 実践ステップ（各25文字以内）
  expectedBenefit: ExpectedBenefit;
}

/**
 * Related Insight
 * 科学的知見に基づく関連インサイト
 */
export interface RelatedInsight {
  label: RelatedInsightLabel;
  text: string;    // 科学的知見に基づく発見（35文字以内）
  source: string;  // 根拠の出典
}

/**
 * AI Response（完全版）
 * APIから返却されるレスポンス全体の型
 */
export interface AIResponse {
  todayInsight: TodayInsight;
  todayOneThing: TodayOneThing;
  relatedInsight: RelatedInsight;
}

/**
 * フォールバック用のデフォルトレスポンス
 * ネットワークエラー時などに使用
 */
export const FALLBACK_AI_RESPONSE: AIResponse = {
  todayInsight: {
    title: 'New Day',
    summary: '今日も新しい1日が始まりました。身体の声に耳を傾けながら、自分のペースで過ごしましょう。データの分析は次回の起動時に改めて行います。',
    whyThisMatters: {
      hrv: {
        headline: 'データを分析中',
        explanation: 'しばらくお待ちください。次回起動時に詳細をお伝えします。',
      },
      sleep: {
        headline: 'データを分析中',
        explanation: 'しばらくお待ちください。次回起動時に詳細をお伝えします。',
      },
      rhythm: {
        headline: 'データを分析中',
        explanation: 'しばらくお待ちください。次回起動時に詳細をお伝えします。',
      },
    },
    whatThisMeansForToday: '無理のない範囲で、今日のタスクに取り組みましょう。身体が疲れを感じたら、休息を優先してくださいね。',
  },
  todayOneThing: {
    icon: 'breathing',
    action: '深呼吸で1日をスタート',
    summary: '心と身体を整えます',
    time: null,
    whyThisAction: '深呼吸は自律神経を整え、1日の良いスタートを切る助けになります。どんなコンディションの日でも、深呼吸は心身のバランスを整える効果があります。',
    benefits: ['心を落ち着ける', '集中力を高める', 'ストレスを軽減する'],
    howToDoIt: ['楽な姿勢で座る', '4秒かけて鼻から吸う', '7秒止めて8秒で口から吐く'],
    expectedBenefit: {
      text: '深呼吸は自律神経のバランスを整える効果があります',
      source: '一般的な知見',
    },
  },
  relatedInsight: {
    label: 'Recovery Tip',
    text: '規則正しい生活がリズムを整えます',
    source: '一般的な知見',
  },
};
