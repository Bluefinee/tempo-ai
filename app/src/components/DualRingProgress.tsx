/**
 * DualRingProgress - 二重サークル
 * 2つの指標を同時に表示するサーキュラープログレス
 */

import React from "react";
import { View, StyleSheet } from "react-native";
import Svg, { Circle } from "react-native-svg";
import Animated, {
  useAnimatedProps,
  useSharedValue,
  withTiming,
  Easing,
} from "react-native-reanimated";

interface DualRingProgressProps {
  size: number;
  strokeWidth: number;
  innerProgress: number; // 0-100
  outerProgress: number; // 0-100
  innerColor: string;
  outerColor: string;
  backgroundColor?: string;
  duration?: number;
}

const AnimatedCircle = Animated.createAnimatedComponent(Circle);

export const DualRingProgress = ({
  size,
  strokeWidth,
  innerProgress,
  outerProgress,
  innerColor,
  outerColor,
  backgroundColor = "#E7E5E4",
  duration = 1000,
}: DualRingProgressProps): React.ReactElement => {
  const innerRadius = (size - strokeWidth * 3) / 2;
  const outerRadius = (size - strokeWidth) / 2;
  const innerCircumference = 2 * Math.PI * innerRadius;
  const outerCircumference = 2 * Math.PI * outerRadius;

  const innerProgressValue = useSharedValue(0);
  const outerProgressValue = useSharedValue(0);

  React.useEffect(() => {
    innerProgressValue.value = withTiming(innerProgress, {
      duration,
      easing: Easing.bezier(0.25, 0.1, 0.25, 1),
    });
    outerProgressValue.value = withTiming(outerProgress, {
      duration,
      easing: Easing.bezier(0.25, 0.1, 0.25, 1),
    });
  }, [
    innerProgress,
    outerProgress,
    duration,
    innerProgressValue,
    outerProgressValue,
  ]);

  const innerAnimatedProps = useAnimatedProps(() => {
    const strokeDashoffset =
      innerCircumference -
      (innerProgressValue.value / 100) * innerCircumference;
    return {
      strokeDashoffset,
    };
  });

  const outerAnimatedProps = useAnimatedProps(() => {
    const strokeDashoffset =
      outerCircumference -
      (outerProgressValue.value / 100) * outerCircumference;
    return {
      strokeDashoffset,
    };
  });

  return (
    <View style={[styles.container, { width: size, height: size }]}>
      <Svg width={size} height={size}>
        {/* Outer Background Circle */}
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={outerRadius}
          stroke={backgroundColor}
          strokeWidth={strokeWidth}
          fill="none"
        />
        {/* Outer Progress Circle */}
        <AnimatedCircle
          cx={size / 2}
          cy={size / 2}
          r={outerRadius}
          stroke={outerColor}
          strokeWidth={strokeWidth}
          fill="none"
          strokeDasharray={outerCircumference}
          strokeLinecap="round"
          animatedProps={outerAnimatedProps}
          rotation="-90"
          origin={`${size / 2}, ${size / 2}`}
        />

        {/* Inner Background Circle */}
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={innerRadius}
          stroke={backgroundColor}
          strokeWidth={strokeWidth}
          fill="none"
        />
        {/* Inner Progress Circle */}
        <AnimatedCircle
          cx={size / 2}
          cy={size / 2}
          r={innerRadius}
          stroke={innerColor}
          strokeWidth={strokeWidth}
          fill="none"
          strokeDasharray={innerCircumference}
          strokeLinecap="round"
          animatedProps={innerAnimatedProps}
          rotation="-90"
          origin={`${size / 2}, ${size / 2}`}
        />
      </Svg>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    justifyContent: "center",
    alignItems: "center",
  },
});
