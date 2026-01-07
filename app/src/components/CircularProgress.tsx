/**
 * CircularProgress - サーキュラープログレスリング
 * スコア表示用のサークルプログレス
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import Svg, { Circle } from 'react-native-svg';
import Animated, {
  useAnimatedProps,
  useSharedValue,
  withTiming,
  Easing,
} from 'react-native-reanimated';

interface CircularProgressProps {
  size: number;
  strokeWidth: number;
  progress: number; // 0-100
  color: string;
  backgroundColor?: string;
  duration?: number;
}

const AnimatedCircle = Animated.createAnimatedComponent(Circle);

export const CircularProgress = ({
  size,
  strokeWidth,
  progress,
  color,
  backgroundColor = '#E7E5E4',
  duration = 1000,
}: CircularProgressProps): React.ReactElement => {
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const progressValue = useSharedValue(0);

  React.useEffect(() => {
    progressValue.value = withTiming(progress, {
      duration,
      easing: Easing.bezier(0.25, 0.1, 0.25, 1),
    });
  }, [progress, duration, progressValue]);

  const animatedProps = useAnimatedProps(() => {
    const strokeDashoffset = circumference - (progressValue.value / 100) * circumference;
    return {
      strokeDashoffset,
    };
  });

  return (
    <View style={[styles.container, { width: size, height: size }]}>
      <Svg width={size} height={size}>
        {/* Background Circle */}
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={backgroundColor}
          strokeWidth={strokeWidth}
          fill="none"
        />
        {/* Progress Circle */}
        <AnimatedCircle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={color}
          strokeWidth={strokeWidth}
          fill="none"
          strokeDasharray={circumference}
          strokeLinecap="round"
          animatedProps={animatedProps}
          rotation="-90"
          origin={`${size / 2}, ${size / 2}`}
        />
      </Svg>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    justifyContent: 'center',
    alignItems: 'center',
  },
});

