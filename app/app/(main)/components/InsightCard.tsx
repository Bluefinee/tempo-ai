import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { ChevronRight, Activity } from 'lucide-react-native';
import { Colors, Spacing, Typography } from '../../../src/theme';
import { Card } from '../../../src/components';
import type { JSX } from 'react';

interface InsightCardProps {
  isLoading: boolean;
  loadingMessage: string;
  shortGreeting: string | null;
  onPress: () => void;
}

export const InsightCard = ({
  isLoading,
  loadingMessage,
  shortGreeting,
  onPress,
}: InsightCardProps): JSX.Element => {
  return (
    <TouchableOpacity onPress={onPress} activeOpacity={0.95}>
      <Card style={styles.insightCard}>
        {isLoading ? (
          <View style={styles.loadingContent}>
            <Activity size={24} color={Colors.primary[500]} style={styles.loadingIcon} />
            <Text style={styles.loadingText}>{loadingMessage}</Text>
          </View>
        ) : (
          <>
            <View style={styles.insightHeader}>
              <Text style={styles.insightLabel}>今日のインサイト</Text>
              <ChevronRight size={20} color={Colors.slate[400]} />
            </View>
            <Text style={styles.insightText} numberOfLines={3}>
              {shortGreeting}
            </Text>
          </>
        )}
      </Card>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  insightCard: {
    backgroundColor: Colors.primary[50],
    marginBottom: Spacing.lg,
  },
  loadingContent: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: Spacing.sm,
  },
  loadingIcon: {
    marginRight: Spacing.md,
  },
  loadingText: {
    ...Typography.body,
    color: Colors.primary[600],
  },
  insightHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  insightLabel: {
    ...Typography.caption,
    color: Colors.primary[600],
  },
  insightText: {
    ...Typography.body,
    color: Colors.slate[700],
    lineHeight: 24,
  },
});

