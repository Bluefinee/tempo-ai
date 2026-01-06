/**
 * TempoAI カラーパレット
 * sozai/components の Tailwind クラスから抽出
 */

export const Colors = {
  // Primary - Emerald (メインアクション、ポジティブな状態)
  primary: {
    50: '#ECFDF5',
    100: '#D1FAE5',
    200: '#A7F3D0',
    300: '#6EE7B7',
    400: '#34D399',
    500: '#10B981', // メインカラー
    600: '#059669',
    700: '#047857',
    800: '#065F46',
    900: '#064E3B',
  },

  // Slate (テキスト、背景)
  slate: {
    50: '#F8FAFC',
    100: '#F1F5F9',
    200: '#E2E8F0',
    300: '#CBD5E1',
    400: '#94A3B8',
    500: '#64748B',
    600: '#475569',
    700: '#334155',
    800: '#1E293B',
    900: '#0F172A',
  },

  // Amber (警告、注意)
  amber: {
    50: '#FFFBEB',
    100: '#FEF3C7',
    200: '#FDE68A',
    300: '#FCD34D',
    400: '#FBBF24',
    500: '#F59E0B',
    600: '#D97706',
    700: '#B45309',
  },

  // Rose (エラー、低スコア)
  rose: {
    50: '#FFF1F2',
    100: '#FFE4E6',
    200: '#FECDD3',
    300: '#FDA4AF',
    400: '#FB7185',
    500: '#F43F5E',
    600: '#E11D48',
  },

  // Indigo (アクセント、リンク)
  indigo: {
    50: '#EEF2FF',
    100: '#E0E7FF',
    400: '#818CF8',
    500: '#6366F1',
    600: '#4F46E5',
  },

  // Blue (情報)
  blue: {
    50: '#EFF6FF',
    100: '#DBEAFE',
    400: '#60A5FA',
    500: '#3B82F6',
    600: '#2563EB',
  },

  // 共通
  white: '#FFFFFF',
  black: '#000000',
  transparent: 'transparent',
} as const;

// スコア状態に応じた色
export const getScoreColor = (score: number): string => {
  if (score >= 80) return Colors.primary[500];
  if (score >= 60) return Colors.primary[400];
  if (score >= 40) return Colors.amber[500];
  return Colors.rose[500];
};

// スコア状態に応じた背景色
export const getScoreBackgroundColor = (score: number): string => {
  if (score >= 80) return Colors.primary[50];
  if (score >= 60) return Colors.primary[100];
  if (score >= 40) return Colors.amber[50];
  return Colors.rose[50];
};

export type ColorKey = keyof typeof Colors;
