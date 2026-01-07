/**
 * TempoAI カラーパレット
 * Tailwind CSS colors を React Native にマッピング
 * @see docs/specs/ui_ux_design.md
 * @see sozai/new/screens/TodayScreen.tsx
 */
export const Colors = {
  // Primary - Soft Indigo
  indigo: {
    50: '#EEF2FF',
    100: '#E0E7FF',
    200: '#C7D2FE',
    300: '#A5B4FC',
    400: '#818CF8',
    500: '#6366F1',  // メインカラー
    600: '#4F46E5',
    700: '#4338CA',
    800: '#3730A3',
    900: '#312E81',  // Dark button bg (Breathe button)
  },

  // Accent - Warm Amber (Steps, Energy)
  amber: {
    50: '#FFFBEB',
    100: '#FEF3C7',
    200: '#FDE68A',
    300: '#FCD34D',
    400: '#FBBF24',  // Current time indicator
    500: '#F59E0B',  // メインアクセント
    600: '#D97706',
  },

  // Accent - Rose (HRV) - Tailwind rose colors
  rose: {
    50: '#FFF1F2',
    100: '#FFE4E6',
    400: '#FB7185',  // メインアクセント (HRV)
    500: '#F43F5E',
    600: '#E11D48',
  },

  // Coral (alias for rose for backwards compatibility)
  coral: {
    50: '#FFF1F2',
    100: '#FFE4E6',
    400: '#FB7185',
    500: '#F43F5E',
    600: '#E11D48',
  },

  // Purple (for gradients and Rhythm)
  purple: {
    50: '#FAF5FF',
    100: '#F3E8FF',
    500: '#A855F7',
    600: '#9333EA',
  },

  // Blue (for Respiratory)
  blue: {
    50: '#EFF6FF',
    400: '#60A5FA',
    500: '#3B82F6',
  },

  // Teal (for SpO2)
  teal: {
    50: '#F0FDFA',
    500: '#14B8A6',
  },

  // Positive - Emerald
  emerald: {
    50: '#ECFDF5',
    100: '#D1FAE5',
    400: '#34D399',
    500: '#10B981',  // 成功・ポジティブ
    600: '#059669',
  },

  // Slate (for dark backgrounds)
  slate: {
    500: '#64748B',
    900: '#0F172A',  // Breathe画面背景
  },

  // Background
  offWhite: '#FAFAF9',
  deepNavy: '#0F172A',  // Breathe画面背景

  // Neutral - Stone (Tailwind stone colors)
  stone: {
    50: '#FAFAF9',
    100: '#F5F5F4',
    200: '#E7E5E4',  // Fixed: Tailwind stone-200
    300: '#D6D3D1',
    400: '#A8A29E',
    500: '#78716C',
    600: '#57534E',
    700: '#44403C',
    800: '#292524',
    900: '#1C1917',
  },

  // Semantic
  white: '#FFFFFF',
  black: '#000000',
  transparent: 'transparent',
} as const;

// メトリクス別カラーマッピング
export const MetricColors = {
  sleep: Colors.indigo[500],
  hrv: Colors.coral[400],
  steps: Colors.amber[500],
} as const;

export type ColorKey = keyof typeof Colors;

/**
 * スコア値から色を取得
 * @param score スコア値（0-100）
 * @returns 色コード
 */
export const getScoreColor = (score: number): string => {
  if (score >= 80) return Colors.emerald[500];
  if (score >= 60) return Colors.indigo[500];
  if (score >= 40) return Colors.amber[500];
  return Colors.coral[500];
};

/**
 * スコア値から背景色を取得
 * @param score スコア値（0-100）
 * @returns 色コード
 */
export const getScoreBackgroundColor = (score: number): string => {
  if (score >= 80) return Colors.emerald[50];
  if (score >= 60) return Colors.indigo[50];
  if (score >= 40) return Colors.amber[50];
  return Colors.coral[50];
};
