import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import { Colors, Spacing, Typography, BorderRadius } from '../../src/theme';
import { Card, ProgressBar } from '../../src/components';
import {
  MOCK_WEEKLY_SCORES,
  MOCK_RHYTHM_ANALYSIS,
  TimePeriod,
} from '../../src/constants/mockData';
import { format } from 'date-fns';
import { ja } from 'date-fns/locale';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

export default function AnalyticsScreen() {
  const [period, setPeriod] = useState<TimePeriod>('weekly');
  const scores = MOCK_WEEKLY_SCORES;
  const rhythmAnalysis = MOCK_RHYTHM_ANALYSIS;

  // Calculate averages
  const avgAutonomic = Math.round(
    scores.reduce((sum, s) => sum + s.autonomicScore, 0) / scores.length
  );
  const avgSleep = Math.round(
    scores.reduce((sum, s) => sum + s.sleepScore, 0) / scores.length
  );
  const avgRhythm = Math.round(
    scores.reduce((sum, s) => sum + s.rhythmScore, 0) / scores.length
  );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>分析</Text>
        </View>

        {/* Period Selector */}
        <View style={styles.periodSelector}>
          <TouchableOpacity
            style={[
              styles.periodButton,
              period === 'weekly' && styles.periodButtonActive,
            ]}
            onPress={() => setPeriod('weekly')}
          >
            <Text
              style={[
                styles.periodText,
                period === 'weekly' && styles.periodTextActive,
              ]}
            >
              週間
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[
              styles.periodButton,
              period === 'monthly' && styles.periodButtonActive,
            ]}
            onPress={() => setPeriod('monthly')}
          >
            <Text
              style={[
                styles.periodText,
                period === 'monthly' && styles.periodTextActive,
              ]}
            >
              月間
            </Text>
          </TouchableOpacity>
        </View>

        {/* Score Summary */}
        <Card style={styles.summaryCard}>
          <Text style={styles.cardTitle}>平均スコア</Text>
          <View style={styles.summaryGrid}>
            <SummaryItem label="自律神経" value={avgAutonomic} icon="💚" />
            <SummaryItem label="睡眠" value={avgSleep} icon="🌙" />
            <SummaryItem label="リズム" value={avgRhythm} icon="🎯" />
          </View>
        </Card>

        {/* Simple Chart */}
        <Card style={styles.chartCard}>
          <Text style={styles.cardTitle}>スコア推移</Text>
          <View style={styles.chartContainer}>
            {scores.map((score, index) => (
              <View key={score.id} style={styles.chartBar}>
                <View
                  style={[
                    styles.chartBarFill,
                    { height: `${score.autonomicScore}%` },
                  ]}
                />
                <Text style={styles.chartLabel}>
                  {format(score.date, 'E', { locale: ja })}
                </Text>
              </View>
            ))}
          </View>
          <View style={styles.chartLegend}>
            <View style={styles.legendItem}>
              <View
                style={[styles.legendDot, { backgroundColor: Colors.primary[500] }]}
              />
              <Text style={styles.legendText}>自律神経</Text>
            </View>
          </View>
        </Card>

        {/* Rhythm Consistency */}
        <Card style={styles.rhythmCard}>
          <Text style={styles.cardTitle}>リズム一貫性</Text>
          <View style={styles.rhythmMetrics}>
            <RhythmMetric
              label="就寝時刻のばらつき"
              value={`${rhythmAnalysis.bedtimeStddevMinutes}分`}
              score={rhythmAnalysis.bedtimeConsistencyScore}
            />
            <RhythmMetric
              label="起床時刻のばらつき"
              value={`${rhythmAnalysis.wakeTimeStddevMinutes}分`}
              score={rhythmAnalysis.wakeTimeConsistencyScore}
            />
          </View>
          <View style={styles.rhythmStatus}>
            <Text style={styles.rhythmStatusLabel}>連続安定日数</Text>
            <Text style={styles.rhythmStatusValue}>
              {rhythmAnalysis.consecutiveStableDays}日
            </Text>
          </View>
        </Card>

        {/* Insights */}
        <Card style={styles.insightsCard}>
          <Text style={styles.cardTitle}>インサイト</Text>
          <View style={styles.insightsList}>
            <InsightItem
              emoji="📈"
              text="自律神経スコアが先週より8%向上しています"
              type="positive"
            />
            <InsightItem
              emoji="🌙"
              text="睡眠の質が安定してきています"
              type="positive"
            />
            <InsightItem
              emoji="⏰"
              text="週末の起床時刻が平日より遅れる傾向があります"
              type="warning"
            />
          </View>
        </Card>
      </ScrollView>
    </SafeAreaView>
  );
}

const SummaryItem: React.FC<{ label: string; value: number; icon: string }> = ({
  label,
  value,
  icon,
}) => (
  <View style={styles.summaryItem}>
    <Text style={styles.summaryIcon}>{icon}</Text>
    <Text style={styles.summaryValue}>{value}</Text>
    <Text style={styles.summaryLabel}>{label}</Text>
  </View>
);

const RhythmMetric: React.FC<{
  label: string;
  value: string;
  score: number;
}> = ({ label, value, score }) => (
  <View style={styles.rhythmMetric}>
    <View style={styles.rhythmMetricHeader}>
      <Text style={styles.rhythmMetricLabel}>{label}</Text>
      <Text style={styles.rhythmMetricValue}>{value}</Text>
    </View>
    <ProgressBar value={score} height={6} />
  </View>
);

const InsightItem: React.FC<{
  emoji: string;
  text: string;
  type: 'positive' | 'warning';
}> = ({ emoji, text, type }) => (
  <View
    style={[
      styles.insightItem,
      type === 'positive' ? styles.insightPositive : styles.insightWarning,
    ]}
  >
    <Text style={styles.insightEmoji}>{emoji}</Text>
    <Text style={styles.insightText}>{text}</Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.slate[50],
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: Spacing.lg,
    paddingTop: Spacing.lg,
    paddingBottom: Spacing.huge,
  },
  header: {
    marginBottom: Spacing.lg,
  },
  title: {
    ...Typography.h3,
    color: Colors.slate[800],
  },
  periodSelector: {
    flexDirection: 'row',
    backgroundColor: Colors.slate[100],
    borderRadius: BorderRadius.full,
    padding: 4,
    marginBottom: Spacing.lg,
  },
  periodButton: {
    flex: 1,
    paddingVertical: Spacing.sm,
    alignItems: 'center',
    borderRadius: BorderRadius.full,
  },
  periodButtonActive: {
    backgroundColor: Colors.white,
    shadowColor: Colors.slate[900],
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  periodText: {
    ...Typography.bodySmall,
    color: Colors.slate[500],
  },
  periodTextActive: {
    color: Colors.slate[800],
    fontWeight: '600',
  },
  summaryCard: {
    marginBottom: Spacing.lg,
  },
  cardTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[700],
    marginBottom: Spacing.lg,
  },
  summaryGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  summaryItem: {
    alignItems: 'center',
  },
  summaryIcon: {
    fontSize: 24,
    marginBottom: Spacing.xs,
  },
  summaryValue: {
    ...Typography.scoreMedium,
    color: Colors.slate[800],
  },
  summaryLabel: {
    ...Typography.caption,
    color: Colors.slate[500],
  },
  chartCard: {
    marginBottom: Spacing.lg,
  },
  chartContainer: {
    flexDirection: 'row',
    height: 150,
    alignItems: 'flex-end',
    justifyContent: 'space-around',
    paddingTop: Spacing.md,
  },
  chartBar: {
    alignItems: 'center',
    width: (SCREEN_WIDTH - Spacing.lg * 2 - Spacing.xl * 2) / 7 - 4,
  },
  chartBarFill: {
    width: '60%',
    backgroundColor: Colors.primary[400],
    borderRadius: 4,
    minHeight: 4,
  },
  chartLabel: {
    ...Typography.captionSmall,
    color: Colors.slate[400],
    marginTop: Spacing.xs,
  },
  chartLegend: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: Spacing.lg,
    paddingTop: Spacing.md,
    borderTopWidth: 1,
    borderTopColor: Colors.slate[100],
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  legendDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: Spacing.xs,
  },
  legendText: {
    ...Typography.caption,
    color: Colors.slate[500],
  },
  rhythmCard: {
    marginBottom: Spacing.lg,
  },
  rhythmMetrics: {
    gap: Spacing.lg,
    marginBottom: Spacing.lg,
  },
  rhythmMetric: {},
  rhythmMetricHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: Spacing.sm,
  },
  rhythmMetricLabel: {
    ...Typography.bodySmall,
    color: Colors.slate[600],
  },
  rhythmMetricValue: {
    ...Typography.bodySmall,
    color: Colors.slate[800],
    fontWeight: '600',
  },
  rhythmStatus: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingTop: Spacing.md,
    borderTopWidth: 1,
    borderTopColor: Colors.slate[100],
  },
  rhythmStatusLabel: {
    ...Typography.bodySmall,
    color: Colors.slate[500],
  },
  rhythmStatusValue: {
    ...Typography.bodyMedium,
    color: Colors.primary[600],
  },
  insightsCard: {
    marginBottom: Spacing.lg,
  },
  insightsList: {
    gap: Spacing.sm,
  },
  insightItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: Spacing.md,
    borderRadius: BorderRadius.md,
  },
  insightPositive: {
    backgroundColor: Colors.primary[50],
  },
  insightWarning: {
    backgroundColor: Colors.amber[50],
  },
  insightEmoji: {
    fontSize: 18,
    marginRight: Spacing.md,
  },
  insightText: {
    ...Typography.bodySmall,
    color: Colors.slate[700],
    flex: 1,
  },
});
