/**
 * スペーシング定義（8pxグリッド）
 * @see docs/specs/ui_ux_design.md
 */
export const Spacing = {
	xs: 4,
	sm: 8,
	md: 16,
	lg: 24,
	xl: 32,
	xxl: 48,
} as const;

/**
 * 角丸定義
 * Tailwind CSS border-radius mapping
 */
export const BorderRadius = {
	sm: 8, // rounded-lg
	md: 12, // rounded-xl
	lg: 16, // rounded-2xl
	xl: 24, // rounded-3xl (sozai のメインカード)
	"2xl": 20, // rounded-2xl
	"3xl": 24, // rounded-3xl
	full: 9999, // rounded-full
} as const;

export type SpacingKey = keyof typeof Spacing;
export type BorderRadiusKey = keyof typeof BorderRadius;
