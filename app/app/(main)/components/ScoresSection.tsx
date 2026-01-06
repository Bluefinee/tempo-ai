import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors, Spacing, Typography } from '../../../src/theme';
import { ScoreGauge } from '../../../src/components';
import type { JSX } from 'react';

interface ScoresSectionProps {
  scores: {
    autonomic: number;
    sleep: number;
    rhythm: number;
  };
  isCalibrating: boolean;
}

export const ScoresSection = ({ scores, isCalibrating }: ScoresSectionProps): JSX.Element => {
  return (
    <View style={styles.scoresSection}>
      <Text style={styles.sectionTitle}>今日のコンディション</Text>
      <View style={styles.scoresGrid}>
        <ScoreGauge
          label="自律神経"
          value={scores.autonomic}
          icon="💚"
          isCalibrating={isCalibrating}
        />
        <ScoreGauge
          label="睡眠"
          value={scores.sleep}
          icon="🌙"
          isCalibrating={isCalibrating}
        />
        <ScoreGauge
          label="リズム"
          value={scores.rhythm}
          icon="🎯"
          isCalibrating={isCalibrating}
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  scoresSection: {
    marginBottom: Spacing.lg,
  },
  sectionTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[700],
    marginBottom: Spacing.md,
  },
  scoresGrid: {
    flexDirection: 'row',
    gap: Spacing.sm,
  },
});

