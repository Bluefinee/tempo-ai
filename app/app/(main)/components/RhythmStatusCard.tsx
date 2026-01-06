import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors, Spacing, Typography, BorderRadius } from '../../../src/theme';
import { Card } from '../../../src/components';
import type { RhythmAnalysis } from '../../../src/domain/models';
import type { JSX } from 'react';

interface RhythmStatusCardProps {
  rhythmAnalysis: RhythmAnalysis;
}

export const RhythmStatusCard = ({ rhythmAnalysis }: RhythmStatusCardProps): JSX.Element => {
  return (
    <Card style={styles.rhythmCard}>
      <View style={styles.rhythmHeader}>
        <Text style={styles.rhythmTitle}>リズム状態</Text>
        <View
          style={[
            styles.rhythmBadge,
            rhythmAnalysis.isStable ? styles.rhythmBadgeStable : styles.rhythmBadgeUnstable,
          ]}
        >
          <Text
            style={[
              styles.rhythmBadgeText,
              rhythmAnalysis.isStable
                ? styles.rhythmBadgeTextStable
                : styles.rhythmBadgeTextUnstable,
            ]}
          >
            {rhythmAnalysis.status === 'stable'
              ? '安定'
              : rhythmAnalysis.status === 'recovering'
              ? '回復中'
              : '不安定'}
          </Text>
        </View>
      </View>
      <Text style={styles.rhythmDescription}>
        {rhythmAnalysis.consecutiveStableDays}日連続で睡眠リズムが安定しています
      </Text>
    </Card>
  );
};

const styles = StyleSheet.create({
  rhythmCard: {
    marginBottom: Spacing.lg,
  },
  rhythmHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  rhythmTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[700],
  },
  rhythmBadge: {
    paddingVertical: Spacing.xxs,
    paddingHorizontal: Spacing.sm,
    borderRadius: BorderRadius.full,
  },
  rhythmBadgeStable: {
    backgroundColor: Colors.primary[100],
  },
  rhythmBadgeUnstable: {
    backgroundColor: Colors.amber[100],
  },
  rhythmBadgeText: {
    ...Typography.captionSmall,
  },
  rhythmBadgeTextStable: {
    color: Colors.primary[600],
  },
  rhythmBadgeTextUnstable: {
    color: Colors.amber[600],
  },
  rhythmDescription: {
    ...Typography.bodySmall,
    color: Colors.slate[500],
  },
});

