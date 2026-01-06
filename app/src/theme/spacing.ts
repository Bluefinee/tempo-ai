/**
 * TempoAI スペーシングシステム
 * 4px ベースのスケール
 */

export const Spacing = {
  /** 0px */
  none: 0,
  /** 2px */
  xxs: 2,
  /** 4px */
  xs: 4,
  /** 8px */
  sm: 8,
  /** 12px */
  md: 12,
  /** 16px */
  lg: 16,
  /** 20px */
  xl: 20,
  /** 24px */
  xxl: 24,
  /** 32px */
  xxxl: 32,
  /** 40px */
  huge: 40,
  /** 48px */
  massive: 48,
  /** 64px */
  giant: 64,
} as const;

// ボーダー半径
export const BorderRadius = {
  /** 4px */
  xs: 4,
  /** 8px */
  sm: 8,
  /** 12px */
  md: 12,
  /** 16px */
  lg: 16,
  /** 20px */
  xl: 20,
  /** 24px - カード用 */
  xxl: 24,
  /** 9999px - ピル/ボタン用 */
  full: 9999,
} as const;

// 画面パディング
export const ScreenPadding = {
  horizontal: Spacing.lg,
  vertical: Spacing.lg,
  bottom: Spacing.huge, // タブバー考慮
} as const;

export type SpacingKey = keyof typeof Spacing;
export type BorderRadiusKey = keyof typeof BorderRadius;
