import { TextStyle, Platform } from 'react-native';

/**
 * TempoAI タイポグラフィシステム
 */

// フォントファミリー
const fontFamily = Platform.select({
  ios: 'System',
  android: 'Roboto',
  default: 'System',
});

// フォントウェイト定義
export const FontWeight = {
  regular: '400' as const,
  medium: '500' as const,
  semibold: '600' as const,
  bold: '700' as const,
};

// タイポグラフィスタイル
export const Typography: Record<string, TextStyle> = {
  // 見出し
  h1: {
    fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    lineHeight: 40,
    letterSpacing: -0.5,
  },
  h2: {
    fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    lineHeight: 36,
    letterSpacing: -0.3,
  },
  h3: {
    fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.semibold,
    lineHeight: 32,
    letterSpacing: -0.2,
  },
  h4: {
    fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.semibold,
    lineHeight: 28,
  },
  h5: {
    fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.semibold,
    lineHeight: 26,
  },

  // 本文
  body: {
    fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.regular,
    lineHeight: 24,
  },
  bodyMedium: {
    fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.medium,
    lineHeight: 24,
  },
  bodySmall: {
    fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.regular,
    lineHeight: 20,
  },

  // キャプション
  caption: {
    fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.medium,
    lineHeight: 16,
  },
  captionSmall: {
    fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.medium,
    lineHeight: 14,
  },

  // ボタン
  button: {
    fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    lineHeight: 24,
  },
  buttonSmall: {
    fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.semibold,
    lineHeight: 20,
  },

  // 数字（スコア表示用）
  scoreNumber: {
    fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.bold,
    lineHeight: 56,
    letterSpacing: -1,
  },
  scoreMedium: {
    fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    lineHeight: 40,
    letterSpacing: -0.5,
  },
  scoreSmall: {
    fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    lineHeight: 32,
  },

  // ラベル
  label: {
    fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.medium,
    lineHeight: 18,
    letterSpacing: 0.3,
  },
} as const;

export type TypographyKey = keyof typeof Typography;
