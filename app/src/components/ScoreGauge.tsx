import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors, Spacing, Typography } from '../theme';
import { getScoreColor, getScoreBackgroundColor } from '../theme/colors';
import { ProgressBar } from './ProgressBar';

interface ScoreGaugeProps {
  label: string;
  value: number; // 0-100
  icon?: string;
  isCalibrating?: boolean;
}

export const ScoreGauge: React.FC<ScoreGaugeProps> = ({
  label,
  value,
  icon,
  isCalibrating = false,
}) => {
  const displayValue = isCalibrating ? '---' : String(value);
  const scoreColor = getScoreColor(value);
  const bgColor = getScoreBackgroundColor(value);

  return (
    <View style={[styles.container, { backgroundColor: bgColor }]}>
      <View style={styles.header}>
        {icon && <Text style={styles.icon}>{icon}</Text>}
        <Text style={styles.label}>{label}</Text>
      </View>
      <Text style={[styles.value, { color: scoreColor }]}>{displayValue}</Text>
      <ProgressBar value={isCalibrating ? 0 : value} showAnimation={!isCalibrating} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: 16,
    padding: Spacing.lg,
    minWidth: 100,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.xs,
  },
  icon: {
    fontSize: 14,
    marginRight: Spacing.xs,
  },
  label: {
    ...Typography.caption,
    color: Colors.slate[500],
  },
  value: {
    ...Typography.scoreMedium,
    marginBottom: Spacing.sm,
  },
});
