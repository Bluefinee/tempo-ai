/**
 * useFadeIn - フェードインアニメーション用カスタムフック
 * react-native-reanimated版
 */

import { useEffect } from "react";
import {
  useSharedValue,
  useAnimatedStyle,
  withDelay,
  withTiming,
} from "react-native-reanimated";

/**
 * フェードインアニメーションフック
 * @param delay アニメーション開始までの遅延時間（ミリ秒）
 * @returns アニメーションスタイル
 */
export const useFadeIn = (delay: number = 0) => {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(10);

  useEffect(() => {
    opacity.value = withDelay(delay, withTiming(1, { duration: 600 }));
    translateY.value = withDelay(delay, withTiming(0, { duration: 600 }));
  }, [opacity, translateY, delay]);

  return useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }));
};
