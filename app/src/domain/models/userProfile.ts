/**
 * ユーザープロファイル関連の型定義
 */

// クロノタイプ（朝型・中間型・夜型）
export type Chronotype = 'morning' | 'intermediate' | 'evening';

// 性別
export type Gender = 'male' | 'female' | 'other' | 'preferNotToSay';

// 職業タイプ
export type Occupation = 'deskWork' | 'standingWork' | 'physicalWork' | 'hybrid' | 'other';

// 運動頻度
export type ExerciseFrequency = 'rarely' | 'onceWeek' | 'twiceWeek' | 'threeOrMore' | 'daily';

// 飲酒頻度
export type AlcoholFrequency = 'never' | 'rarely' | 'onceWeek' | 'twiceWeek' | 'threeOrMore' | 'daily';

// ユーザープロファイル
export interface UserProfile {
  id: string;
  nickname: string;
  age: number;
  gender: Gender;
  heightCm?: number; // cm (optional)
  weightKg?: number; // kg (optional)
  chronotype: Chronotype;
  targetBedtime: string; // HH:mm
  occupation?: Occupation;
  exerciseFrequency?: ExerciseFrequency;
  alcoholFrequency?: AlcoholFrequency;
  calibrationDaysCompleted: number; // 0-7
  createdAt: Date;
  updatedAt: Date;
}

// キャリブレーション状態
export interface CalibrationState {
  startDate: Date;
  daysCompleted: number;
  isComplete: boolean;
  progressRatio: number; // 0.0-1.0
  remainingDays: number;
}

// デフォルト値
export const DEFAULT_USER_PROFILE: Omit<UserProfile, 'id' | 'createdAt' | 'updatedAt'> = {
  nickname: '',
  age: 0,
  gender: 'preferNotToSay',
  chronotype: 'intermediate',
  targetBedtime: '23:00',
  calibrationDaysCompleted: 0,
};

// キャリブレーション期間（日数）
export const CALIBRATION_PERIOD_DAYS = 7;

// キャリブレーション状態を計算
export const calculateCalibrationState = (
  startDate: Date,
  currentDate: Date = new Date()
): CalibrationState => {
  const diffMs = currentDate.getTime() - startDate.getTime();
  const daysCompleted = Math.min(
    Math.floor(diffMs / (1000 * 60 * 60 * 24)),
    CALIBRATION_PERIOD_DAYS
  );
  const isComplete = daysCompleted >= CALIBRATION_PERIOD_DAYS;
  const progressRatio = daysCompleted / CALIBRATION_PERIOD_DAYS;
  const remainingDays = Math.max(0, CALIBRATION_PERIOD_DAYS - daysCompleted);

  return {
    startDate,
    daysCompleted,
    isComplete,
    progressRatio,
    remainingDays,
  };
};

// クロノタイプの表示名
export const getChronotypeLabel = (chronotype: Chronotype): string => {
  switch (chronotype) {
    case 'morning':
      return '朝型';
    case 'intermediate':
      return '中間型';
    case 'evening':
      return '夜型';
  }
};

// 性別の表示名
export const getGenderLabel = (gender: Gender): string => {
  switch (gender) {
    case 'male':
      return '男性';
    case 'female':
      return '女性';
    case 'other':
      return 'その他';
    case 'preferNotToSay':
      return '回答しない';
  }
};
