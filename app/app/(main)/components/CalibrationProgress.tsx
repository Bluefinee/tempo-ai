import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors, Spacing, Typography } from '../../../src/theme';
import { Card, ProgressBar } from '../../../src/components';
import { CALIBRATION_PERIOD_DAYS } from '../../../src/domain/models';
import type { UserProfile } from '../../../src/domain/models';
import type { JSX } from 'react';

interface CalibrationProgressProps {
  profile: UserProfile;
}

export const CalibrationProgress = ({ profile }: CalibrationProgressProps): JSX.Element => {
  return (
    <Card style={styles.calibrationCard}>
      <View style={styles.calibrationHeader}>
        <Text style={styles.calibrationTitle}>キャリブレーション中</Text>
        <Text style={styles.calibrationDays}>
          {profile.calibrationDaysCompleted}/{CALIBRATION_PERIOD_DAYS}日
        </Text>
      </View>
      <ProgressBar
        value={(profile.calibrationDaysCompleted / CALIBRATION_PERIOD_DAYS) * 100}
        showAnimation={false}
      />
      <Text style={styles.calibrationNote}>
        あと{CALIBRATION_PERIOD_DAYS - profile.calibrationDaysCompleted}日で
        パーソナライズされたスコアが表示されます
      </Text>
    </Card>
  );
};

const styles = StyleSheet.create({
  calibrationCard: {
    backgroundColor: Colors.amber[50],
    marginBottom: Spacing.lg,
  },
  calibrationHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  calibrationTitle: {
    ...Typography.bodyMedium,
    color: Colors.amber[700],
  },
  calibrationDays: {
    ...Typography.caption,
    color: Colors.amber[600],
  },
  calibrationNote: {
    ...Typography.caption,
    color: Colors.amber[600],
    marginTop: Spacing.sm,
  },
});

