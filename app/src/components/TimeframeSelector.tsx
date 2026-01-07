/**
 * TimeframeSelector - 7D/30D/60Dセレクタ
 * 期間選択用のセグメントコントロール
 */

import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import Animated, {
  useAnimatedStyle,
  withTiming,
  Easing,
} from 'react-native-reanimated';
import { colors } from '../theme';

export type Timeframe = '7D' | '30D' | '60D';

interface TimeframeSelectorProps {
  selected: Timeframe;
  onSelect: (timeframe: Timeframe) => void;
}

const timeframes: Timeframe[] = ['7D', '30D', '60D'];

export const TimeframeSelector = ({
  selected,
  onSelect,
}: TimeframeSelectorProps): React.ReactElement => {
  const selectedIndex = timeframes.indexOf(selected);

  const indicatorStyle = useAnimatedStyle(() => {
    return {
      transform: [
        {
          translateX: withTiming(selectedIndex * 60, {
            duration: 200,
            easing: Easing.bezier(0.25, 0.1, 0.25, 1),
          }),
        },
      ],
    };
  });

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.indicator, indicatorStyle]} />
      {timeframes.map((timeframe) => (
        <Pressable
          key={timeframe}
          onPress={() => onSelect(timeframe)}
          style={styles.button}
        >
          <Text
            style={[
              styles.text,
              selected === timeframe && styles.textSelected,
            ]}
          >
            {timeframe}
          </Text>
        </Pressable>
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    backgroundColor: colors.stone[100],
    borderRadius: 12,
    padding: 4,
    position: 'relative',
  },
  indicator: {
    position: 'absolute',
    left: 4,
    top: 4,
    bottom: 4,
    width: 52,
    backgroundColor: colors.white,
    borderRadius: 8,
    // Shadow
    shadowColor: colors.stone[900],
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  button: {
    width: 60,
    height: 32,
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 1,
  },
  text: {
    fontSize: 13,
    fontWeight: '600',
    color: colors.stone[400],
  },
  textSelected: {
    color: colors.stone[900],
    fontWeight: '700',
  },
});

