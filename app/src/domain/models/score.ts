/**
 * スコア関連の型定義
 */

// スコアステータス
export type ScoreStatus = "excellent" | "good" | "fair" | "poor" | "rest";

// スコア
export interface Score {
  value: number; // 0-100
  status: ScoreStatus;
  icon: string;
  statusLabel: string;
}

// 日次スコア（メイン4項目）
export interface DailyScores {
  recovery: number; // 0-100 (旧: autonomic)
  sleep: number; // 0-100
  rhythm: number; // 0-100
  energy: number; // 0-100 (旧: activity)
}

// コンディション評価（全4項目）
export interface ConditionAssessment {
  sleepScore: Score;
  recoveryScore: Score; // 旧: autonomicScore
  rhythmScore: Score;
  energyScore: Score; // 旧: activityScore
  averageScore: number;
  overallStatus: ScoreStatus;
  weakestArea: "sleep" | "recovery" | "rhythm" | "energy" | null;
}

// リズム分析
export interface RhythmAnalysis {
  bedtimeStddevMinutes: number;
  wakeTimeStddevMinutes: number;
  consecutiveStableDays: number;
  status: RhythmStatus;
  isStable: boolean;
  bedtimeConsistencyScore: number; // 0-100
  wakeTimeConsistencyScore: number; // 0-100
}

export type RhythmStatus = "stable" | "recovering" | "unstable";

/**
 * スコア値からステータスを取得
 * @param value スコア値（0-100）
 * @returns スコアステータス
 */
export const getScoreStatus = (value: number): ScoreStatus => {
  if (value >= 80) return "excellent";
  if (value >= 60) return "good";
  if (value >= 40) return "fair";
  return "poor";
};

/**
 * ステータスからアイコンを取得
 * @param status スコアステータス
 * @returns アイコン文字列
 */
export const getScoreIcon = (status: ScoreStatus): string => {
  switch (status) {
    case "excellent":
      return "🌟";
    case "good":
      return "😊";
    case "fair":
      return "😐";
    case "poor":
      return "😔";
    case "rest":
      return "💤";
  }
};

/**
 * ステータスからラベルを取得
 * @param status スコアステータス
 * @returns ラベル文字列
 */
export const getScoreStatusLabel = (status: ScoreStatus): string => {
  switch (status) {
    case "excellent":
      return "絶好調";
    case "good":
      return "良好";
    case "fair":
      return "まあまあ";
    case "poor":
      return "要注意";
    case "rest":
      return "休息推奨";
  }
};

/**
 * リズムステータスのラベルを取得
 * @param status リズムステータス
 * @returns ラベル文字列
 */
export const getRhythmStatusLabel = (status: RhythmStatus): string => {
  switch (status) {
    case "stable":
      return "安定";
    case "recovering":
      return "回復中";
    case "unstable":
      return "不安定";
  }
};

/**
 * スコアオブジェクトを作成
 * @param value スコア値（0-100）
 * @returns スコアオブジェクト
 */
export const createScore = (value: number): Score => {
  const clampedValue = Math.max(0, Math.min(100, Math.round(value)));
  const status = getScoreStatus(clampedValue);
  return {
    value: clampedValue,
    status,
    icon: getScoreIcon(status),
    statusLabel: getScoreStatusLabel(status),
  };
};

/**
 * キャリブレーション中の表示値を取得
 * @param score スコアオブジェクト
 * @param isCalibrating キャリブレーション中かどうか
 * @returns 表示値文字列
 */
export const getDisplayValue = (
  score: Score,
  isCalibrating: boolean,
): string => {
  if (isCalibrating) return "---";
  return String(score.value);
};

// デフォルトスコア
export const DEFAULT_SCORE: Score = createScore(50);

// デフォルトリズム分析
export const DEFAULT_RHYTHM_ANALYSIS: RhythmAnalysis = {
  bedtimeStddevMinutes: 0,
  wakeTimeStddevMinutes: 0,
  consecutiveStableDays: 0,
  status: "unstable",
  isStable: false,
  bedtimeConsistencyScore: 0,
  wakeTimeConsistencyScore: 0,
};
