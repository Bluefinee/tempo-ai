/**
 * アニメーション定義
 * @see docs/specs/ui_ux_design.md
 */
export const Animations = {
  // デュレーション
  duration: {
    fast: 150,
    normal: 300,
    slow: 500,
    wave: 4000, // Tempo Score波
    breatheIn: 4000, // 4-7-8呼吸法: 吸う
    breatheHold: 7000, // 4-7-8呼吸法: 止める
    breatheOut: 8000, // 4-7-8呼吸法: 吐く
  },

  // イージング
  easing: {
    default: "ease-in-out",
    spring: "spring",
  },

  // 画面遷移
  transition: {
    duration: 300,
  },

  // ボトムシート
  bottomSheet: {
    duration: 350,
  },
} as const;
