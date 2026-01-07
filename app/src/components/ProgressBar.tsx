import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated } from 'react-native';
import { Colors, BorderRadius } from '../theme';
import { getScoreColor } from '../theme/colors';
import type { ReactElement } from 'react';

interface ProgressBarProps {
  value: number; // 0-100
  showAnimation?: boolean;
  height?: number;
  backgroundColor?: string;
}

export const ProgressBar: React.FC<ProgressBarProps> = ({
  value,
  showAnimation = true,
  height = 8,
  backgroundColor = Colors.stone[100],
}): ReactElement => {
  const animatedWidth = useRef(new Animated.Value(0)).current;
  const clampedValue = Math.max(0, Math.min(100, value));
  const fillColor = getScoreColor(clampedValue);

  useEffect(() => {
    if (showAnimation) {
      Animated.timing(animatedWidth, {
        toValue: clampedValue,
        duration: 1000,
        useNativeDriver: false,
      }).start();
    } else {
      animatedWidth.setValue(clampedValue);
    }
  }, [clampedValue, showAnimation, animatedWidth]);

  const widthInterpolated = animatedWidth.interpolate({
    inputRange: [0, 100],
    outputRange: ['0%', '100%'],
  });

  return (
    <View style={[styles.container, { height, backgroundColor }]}>
      <Animated.View
        style={[
          styles.fill,
          {
            backgroundColor: fillColor,
            width: widthInterpolated,
            height,
          },
        ]}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: BorderRadius.full,
    overflow: 'hidden',
    width: '100%',
  },
  fill: {
    borderRadius: BorderRadius.full,
  },
});
