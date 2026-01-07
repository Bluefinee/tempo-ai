import { Platform, ViewStyle } from "react-native";

/**
 * シャドウ定義
 * @see docs/specs/ui_ux_design.md
 */
export const Shadows = {
  // カード用シャドウ（浮遊感を強調）
  card:
    Platform.select<ViewStyle>({
      ios: {
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.06,
        shadowRadius: 10,
      },
      android: {
        elevation: 4,
      },
    }) ?? {},

  // カードホバー用シャドウ（押下時）
  cardHover:
    Platform.select<ViewStyle>({
      ios: {
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 6 },
        shadowOpacity: 0.1,
        shadowRadius: 14,
      },
      android: {
        elevation: 6,
      },
    }) ?? {},

  // 小さなシャドウ
  small:
    Platform.select<ViewStyle>({
      ios: {
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.04,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }) ?? {},

  // ボトムシート用シャドウ
  bottomSheet:
    Platform.select<ViewStyle>({
      ios: {
        shadowColor: "#000",
        shadowOffset: { width: 0, height: -4 },
        shadowOpacity: 0.1,
        shadowRadius: 24,
      },
      android: {
        elevation: 16,
      },
    }) ?? {},

  // ボタン用シャドウ
  button:
    Platform.select<ViewStyle>({
      ios: {
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.08,
        shadowRadius: 8,
      },
      android: {
        elevation: 2,
      },
    }) ?? {},

  // なし
  none: {} as ViewStyle,
} as const;

export type ShadowKey = keyof typeof Shadows;
