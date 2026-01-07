/**
 * AI アドバイス関連の型定義
 */

// アクションタイプ
export type ActionType = "breathing" | "morning_light" | "rest" | "activity";

// 推奨アクション
export interface RecommendedAction {
  type: ActionType;
  message: string;
  icon: string;
  displayName: string;
}

// デイリーアドバイス（ストア用の完全版）
export interface DailyAdvice {
  id: string;
  date: Date;
  greeting: string;
  condition: string;
  sleep: string;
  rhythm: string;
  environment: string;
  advice: string;
  closing: string;
}

// AI インサイト詳細（フルバージョン）- APIレスポンス用
export interface AIInsightFull {
  greeting: string;
  condition: string;
  sleep: string;
  rhythm: string;
  environment: string;
  advice: string;
  closing: string;
}

// クイックアクション
export interface QuickAction {
  id: string;
  type: ActionType;
  text: string;
  icon: string;
}

// アクションタイプの表示名
export const getActionTypeLabel = (type: ActionType): string => {
  switch (type) {
    case "breathing":
      return "呼吸法";
    case "morning_light":
      return "朝の光";
    case "rest":
      return "休息";
    case "activity":
      return "活動";
  }
};

// アクションタイプのアイコン
export const getActionTypeIcon = (type: ActionType): string => {
  switch (type) {
    case "breathing":
      return "wind";
    case "morning_light":
      return "sun";
    case "rest":
      return "coffee";
    case "activity":
      return "footprints";
  }
};

// デフォルト推奨アクション
export const createRecommendedAction = (
  type: ActionType,
  message: string,
): RecommendedAction => ({
  type,
  message,
  icon: getActionTypeIcon(type),
  displayName: getActionTypeLabel(type),
});

// 気分
export type Mood = 1 | 2 | 3 | 4 | 5;

// 本日モード
export type TodayMode = "normal" | "challenge" | "holiday";

// 気分のラベル
export const getMoodLabel = (mood: Mood): string => {
  switch (mood) {
    case 1:
      return "とても悪い";
    case 2:
      return "悪い";
    case 3:
      return "普通";
    case 4:
      return "良い";
    case 5:
      return "とても良い";
  }
};

// 本日モードのラベル
export const getTodayModeLabel = (mode: TodayMode): string => {
  switch (mode) {
    case "normal":
      return "ふつう";
    case "challenge":
      return "がんばる";
    case "holiday":
      return "ゆっくり";
  }
};

// 気分ログ
export interface MoodLog {
  date: Date;
  mood: Mood;
}

// 本日モードログ
export interface TodayModeLog {
  date: Date;
  mode: TodayMode;
}

// フィードバックログ
export interface FeedbackLog {
  date: Date;
  isHelpful: boolean;
  adviceSummary?: string;
}
