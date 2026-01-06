import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors, Spacing, Typography } from '../../../src/theme';
import { Card } from '../../../src/components';
import type { QuickAction } from '../../../src/domain/models';
import type { JSX } from 'react';

interface QuickActionsSectionProps {
  actions: QuickAction[];
}

export const QuickActionsSection = ({ actions }: QuickActionsSectionProps): JSX.Element => {
  return (
    <View style={styles.actionsSection}>
      <Text style={styles.sectionTitle}>おすすめのアクション</Text>
      <View style={styles.actionsGrid}>
        {actions.map((action) => (
          <Card key={action.id} style={styles.actionCard}>
            <Text style={styles.actionIcon}>
              {action.type === 'activity' ? '👟' : '🌬️'}
            </Text>
            <Text style={styles.actionText}>{action.text}</Text>
          </Card>
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  actionsSection: {
    marginBottom: Spacing.lg,
  },
  sectionTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[700],
    marginBottom: Spacing.md,
  },
  actionsGrid: {
    gap: Spacing.sm,
  },
  actionCard: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  actionIcon: {
    fontSize: 24,
    marginRight: Spacing.md,
  },
  actionText: {
    ...Typography.body,
    color: Colors.slate[700],
    flex: 1,
  },
});

