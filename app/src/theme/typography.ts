import { Platform, type TextStyle } from "react-native";

/**
 * タイポグラフィ定義
 * Plus Jakarta Sans をメインフォントとして使用
 * @see docs/specs/ui_ux_design.md
 * @see sozai/new/components/WaveScore.tsx
 */

// Plus Jakarta Sans font family
export const FontFamily = {
	regular: "PlusJakartaSans_400Regular",
	medium: "PlusJakartaSans_500Medium",
	semibold: "PlusJakartaSans_600SemiBold",
	bold: "PlusJakartaSans_700Bold",
	// Serif for headings (system serif)
	serif: Platform.select({
		ios: "Georgia",
		android: "serif",
	}),
	// Monospace for timestamps and timers
	mono: Platform.select({
		ios: "Menlo",
		android: "monospace",
	}),
} as const;

export const Typography = {
	// 大見出し - 32px Bold (serif for main headings like greeting)
	heading1: {
		fontFamily: FontFamily.serif,
		fontSize: 30,
		fontWeight: "400",
		lineHeight: 38,
		letterSpacing: -0.5,
	} as TextStyle,

	// 見出し - 24px Semibold
	heading2: {
		fontFamily: FontFamily.semibold,
		fontSize: 24,
		fontWeight: "600",
		lineHeight: 32,
	} as TextStyle,

	// 小見出し - 20px Semibold (like "A Quiet Harmony")
	heading3: {
		fontFamily: FontFamily.bold,
		fontSize: 18,
		fontWeight: "700",
		lineHeight: 24,
	} as TextStyle,

	// 本文 - 15px Regular (like AI message body)
	body: {
		fontFamily: FontFamily.regular,
		fontSize: 15,
		fontWeight: "400",
		lineHeight: 24,
	} as TextStyle,

	// 本文（強調） - 16px Medium
	bodyMedium: {
		fontFamily: FontFamily.medium,
		fontSize: 16,
		fontWeight: "500",
		lineHeight: 24,
	} as TextStyle,

	// キャプション - 14px Regular
	caption: {
		fontFamily: FontFamily.regular,
		fontSize: 14,
		fontWeight: "400",
		lineHeight: 20,
	} as TextStyle,

	// ラベル - 12px Medium (uppercase tracking-wide for sections)
	label: {
		fontFamily: FontFamily.medium,
		fontSize: 12,
		fontWeight: "500",
		lineHeight: 16,
		letterSpacing: 1,
		textTransform: "uppercase",
	} as TextStyle,

	// 小ラベル - 10px Medium (for tab bar labels)
	labelSmall: {
		fontFamily: FontFamily.medium,
		fontSize: 10,
		fontWeight: "500",
		lineHeight: 14,
	} as TextStyle,

	// 日付ラベル - 14px Semibold (uppercase, wide tracking)
	dateLabel: {
		fontFamily: FontFamily.semibold,
		fontSize: 14,
		fontWeight: "600",
		lineHeight: 18,
		letterSpacing: 2,
		textTransform: "uppercase",
	} as TextStyle,

	// 数値（大） - 52px Bold (for WaveScore)
	scoreXL: {
		fontFamily: FontFamily.bold,
		fontSize: 52,
		fontWeight: "700",
		lineHeight: 56,
		letterSpacing: -1,
	} as TextStyle,

	// 数値（中） - 48px Bold
	scoreLG: {
		fontFamily: FontFamily.bold,
		fontSize: 48,
		fontWeight: "700",
		lineHeight: 56,
	} as TextStyle,

	// 数値（小） - 32px Bold
	scoreMD: {
		fontFamily: FontFamily.bold,
		fontSize: 32,
		fontWeight: "700",
		lineHeight: 40,
	} as TextStyle,

	// モノスペース（タイマー用）
	mono: {
		fontFamily: FontFamily.mono,
		fontSize: 48,
		fontWeight: "300",
		lineHeight: 56,
		letterSpacing: -1,
	} as TextStyle,

	// セクションタイトル（Settings用）
	sectionTitle: {
		fontFamily: FontFamily.medium,
		fontSize: 11,
		fontWeight: "500",
		lineHeight: 14,
		letterSpacing: 1.5,
		textTransform: "uppercase",
	} as TextStyle,
} as const;

export type TypographyKey = keyof typeof Typography;
