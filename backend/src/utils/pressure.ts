import type { PressureTrend } from '../types/domain.js';

// =============================================================================
// Pressure Trend Calculation
// =============================================================================

/**
 * 気圧トレンドを算出
 *
 * 過去3時間の気圧変化を基に、気圧トレンドを判定する。
 * - 2hPa以上上昇: "rising"
 * - 2hPa以上下降: "falling"
 * - その他: "stable"
 *
 * @param currentPressure - 現在の気圧（hPa）
 * @param pressure3hAgo - 3時間前の気圧（hPa、オプション）
 * @returns 気圧トレンド
 *
 * @example
 * ```typescript
 * // 上昇トレンド
 * calculatePressureTrend(1020, 1017); // "rising"
 *
 * // 下降トレンド
 * calculatePressureTrend(1015, 1018); // "falling"
 *
 * // 安定
 * calculatePressureTrend(1018, 1017); // "stable"
 *
 * // データ不足
 * calculatePressureTrend(1018, undefined); // "stable"
 * ```
 */
export const calculatePressureTrend = (
  currentPressure: number,
  pressure3hAgo?: number
): PressureTrend => {
  // 過去データがない場合は "stable" を返す
  if (pressure3hAgo === undefined) {
    return 'stable';
  }

  const diff: number = currentPressure - pressure3hAgo;

  if (diff > 2) {
    return 'rising';
  }
  if (diff < -2) {
    return 'falling';
  }
  return 'stable';
};
