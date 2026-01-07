/**
 * useFadeIn - フェードインアニメーション用カスタムフック
 * sozai/new/new2/tempoaiの.fade-inクラスを再現
 */

import { useEffect, useRef } from 'react';
import { Animated, Easing } from 'react-native';

interface UseFadeInOptions {
  delay?: number;
  duration?: number;
}

export const useFadeIn = (options: UseFadeInOptions = {}) => {
  const { delay = 0, duration = 600 } = options;
  const opacity = useRef(new Animated.Value(0)).current;
  const translateY = useRef(new Animated.Value(10)).current;

  useEffect(() => {
    const timeout = setTimeout(() => {
      Animated.parallel([
        Animated.timing(opacity, {
          toValue: 1,
          duration,
          easing: Easing.out(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(translateY, {
          toValue: 0,
          duration,
          easing: Easing.out(Easing.ease),
          useNativeDriver: true,
        }),
      ]).start();
    }, delay);

    return () => clearTimeout(timeout);
  }, [delay, duration, opacity, translateY]);

  return {
    opacity,
    transform: [{ translateY }],
  };
};

/**
 * FadeInView - フェードインアニメーション付きのViewラッパー
 */
export const createFadeInStyle = (opacity: Animated.Value, translateY: Animated.Value) => ({
  opacity,
  transform: [{ translateY }],
});
