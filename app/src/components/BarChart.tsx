/**
 * BarChart - 履歴バーチャート
 * スコア履歴を表示するバーチャート
 */

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { colors } from '../theme';

interface BarChartProps {
  data: {
    label: string;
    value: number;
  }[];
  color: string;
  maxValue?: number;
}

export const BarChart = ({
  data,
  color,
  maxValue = 100,
}: BarChartProps): React.ReactElement => {
  return (
    <View style={styles.container}>
      {data.map((item, index) => {
        const heightPercentage = (item.value / maxValue) * 100;
        return (
          <View key={index} style={styles.barContainer}>
            <Animated.View
              entering={FadeInUp.delay(index * 50).duration(400)}
              style={styles.barWrapper}
            >
              <View
                style={[
                  styles.bar,
                  {
                    height: `${heightPercentage}%`,
                    backgroundColor: color,
                  },
                ]}
              />
            </Animated.View>
            <Text style={styles.label}>{item.label}</Text>
          </View>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    height: 200,
    paddingBottom: 24,
  },
  barContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'flex-end',
    height: '100%',
  },
  barWrapper: {
    width: '70%',
    height: '85%',
    justifyContent: 'flex-end',
  },
  bar: {
    width: '100%',
    borderRadius: 4,
    minHeight: 4,
  },
  label: {
    fontSize: 10,
    fontWeight: '600',
    color: colors.stone[400],
    marginTop: 8,
    textAlign: 'center',
  },
});

