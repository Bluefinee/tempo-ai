/**
 * SleepStagesBar - 睡眠ステージバー
 * 睡眠詳細画面で睡眠ステージを表示
 */

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Animated, { FadeIn } from 'react-native-reanimated';
import { colors } from '../theme';

interface SleepStage {
  stage: 'deep' | 'rem' | 'light' | 'awake';
  percentage: number;
}

interface SleepStagesBarProps {
  stages: SleepStage[];
}

const stageColors = {
  deep: colors.indigo[600],
  rem: colors.purple[500],
  light: colors.blue[400],
  awake: colors.amber[400],
};

const stageLabels = {
  deep: 'Deep',
  rem: 'REM',
  light: 'Light',
  awake: 'Awake',
};

export const SleepStagesBar = ({ stages }: SleepStagesBarProps): React.ReactElement => {
  return (
    <View style={styles.container}>
      {/* Bar */}
      <View style={styles.bar}>
        {stages.map((stage, index) => (
          <Animated.View
            key={index}
            entering={FadeIn.delay(index * 100).duration(400)}
            style={[
              styles.segment,
              {
                flex: stage.percentage,
                backgroundColor: stageColors[stage.stage],
              },
            ]}
          />
        ))}
      </View>

      {/* Legend */}
      <View style={styles.legend}>
        {stages.map((stage, index) => (
          <View key={index} style={styles.legendItem}>
            <View
              style={[
                styles.legendDot,
                { backgroundColor: stageColors[stage.stage] },
              ]}
            />
            <Text style={styles.legendLabel}>{stageLabels[stage.stage]}</Text>
            <Text style={styles.legendValue}>{stage.percentage}%</Text>
          </View>
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    gap: 16,
  },
  bar: {
    flexDirection: 'row',
    height: 12,
    borderRadius: 6,
    overflow: 'hidden',
    backgroundColor: colors.stone[100],
  },
  segment: {
    height: '100%',
  },
  legend: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 16,
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  legendDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  legendLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: colors.stone[600],
  },
  legendValue: {
    fontSize: 12,
    fontWeight: '700',
    color: colors.stone[900],
  },
});

