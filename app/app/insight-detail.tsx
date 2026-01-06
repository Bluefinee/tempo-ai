import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { useRouter } from 'expo-router';
import { X, ThumbsUp, ThumbsDown } from 'lucide-react-native';
import { Colors, Spacing, Typography, BorderRadius } from '../src/theme';
import { Card } from '../src/components';
import { useUserStore, useInsightStore } from '../src/stores';

export default function InsightDetailScreen() {
  const router = useRouter();

  // User store - profile loaded for future use
  useUserStore((state) => state.profile);

  // Insight store
  const dailyAdvice = useInsightStore((state) => state.dailyAdvice);
  const recommendedAction = useInsightStore((state) => state.recommendedAction);
  const feedback = useInsightStore((state) => state.insightFeedback);
  const setInsightFeedback = useInsightStore((state) => state.setInsightFeedback);

  const handleFeedback = (isHelpful: boolean) => {
    setInsightFeedback(isHelpful ? 'helpful' : 'not-helpful');
  };

  // Fallback if no insight is loaded
  if (!dailyAdvice) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>今日のインサイト</Text>
          <TouchableOpacity
            onPress={() => router.back()}
            style={styles.closeButton}
          >
            <X size={24} color={Colors.slate[500]} />
          </TouchableOpacity>
        </View>
        <View style={[styles.container, { justifyContent: 'center', alignItems: 'center' }]}>
          <Text style={styles.sectionText}>インサイトを読み込み中...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>今日のインサイト</Text>
        <TouchableOpacity
          onPress={() => router.back()}
          style={styles.closeButton}
        >
          <X size={24} color={Colors.slate[500]} />
        </TouchableOpacity>
      </View>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Greeting */}
        <Text style={styles.greeting}>{dailyAdvice.greeting}</Text>

        {/* Condition */}
        <Section title="コンディション" emoji="💚">
          <Text style={styles.sectionText}>{dailyAdvice.condition}</Text>
        </Section>

        {/* Sleep */}
        <Section title="睡眠分析" emoji="🌙">
          <Text style={styles.sectionText}>{dailyAdvice.sleep}</Text>
        </Section>

        {/* Rhythm */}
        <Section title="リズム" emoji="🎯">
          <Text style={styles.sectionText}>{dailyAdvice.rhythm}</Text>
        </Section>

        {/* Environment */}
        <Section title="環境" emoji="☁️">
          <Text style={styles.sectionText}>{dailyAdvice.environment}</Text>
        </Section>

        {/* Advice Card */}
        <Card style={styles.adviceCard}>
          <Text style={styles.adviceTitle}>今日のアドバイス</Text>
          <Text style={styles.adviceText}>{dailyAdvice.advice}</Text>
          {recommendedAction && (
            <View style={styles.actionBadge}>
              <Text style={styles.actionIcon}>
                {recommendedAction.type === 'activity' ? '👟' : '🌬️'}
              </Text>
              <Text style={styles.actionText}>{recommendedAction.message}</Text>
            </View>
          )}
        </Card>

        {/* Closing */}
        <Text style={styles.closing}>{dailyAdvice.closing}</Text>

        {/* Feedback */}
        <View style={styles.feedbackSection}>
          <Text style={styles.feedbackTitle}>このアドバイスは役立ちましたか？</Text>
          <View style={styles.feedbackButtons}>
            <TouchableOpacity
              style={[
                styles.feedbackButton,
                feedback === 'helpful' && styles.feedbackButtonActive,
              ]}
              onPress={() => handleFeedback(true)}
            >
              <ThumbsUp
                size={20}
                color={
                  feedback === 'helpful'
                    ? Colors.primary[600]
                    : Colors.slate[400]
                }
              />
              <Text
                style={[
                  styles.feedbackButtonText,
                  feedback === 'helpful' && styles.feedbackButtonTextActive,
                ]}
              >
                役立った
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[
                styles.feedbackButton,
                feedback === 'not-helpful' && styles.feedbackButtonActiveNegative,
              ]}
              onPress={() => handleFeedback(false)}
            >
              <ThumbsDown
                size={20}
                color={
                  feedback === 'not-helpful'
                    ? Colors.rose[500]
                    : Colors.slate[400]
                }
              />
              <Text
                style={[
                  styles.feedbackButtonText,
                  feedback === 'not-helpful' && styles.feedbackButtonTextActiveNegative,
                ]}
              >
                改善希望
              </Text>
            </TouchableOpacity>
          </View>
          {feedback && (
            <Text style={styles.feedbackThanks}>
              フィードバックありがとうございます！
            </Text>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const Section: React.FC<{
  title: string;
  emoji: string;
  children: React.ReactNode;
}> = ({ title, emoji, children }) => (
  <View style={styles.section}>
    <View style={styles.sectionHeader}>
      <Text style={styles.sectionEmoji}>{emoji}</Text>
      <Text style={styles.sectionTitle}>{title}</Text>
    </View>
    {children}
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.white,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: Colors.slate[100],
  },
  title: {
    ...Typography.h4,
    color: Colors.slate[800],
  },
  closeButton: {
    padding: Spacing.xs,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: Spacing.lg,
    paddingTop: Spacing.xl,
    paddingBottom: Spacing.huge,
  },
  greeting: {
    ...Typography.h4,
    color: Colors.slate[800],
    marginBottom: Spacing.xl,
  },
  section: {
    marginBottom: Spacing.xl,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  sectionEmoji: {
    fontSize: 18,
    marginRight: Spacing.sm,
  },
  sectionTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[700],
  },
  sectionText: {
    ...Typography.body,
    color: Colors.slate[600],
    lineHeight: 26,
  },
  adviceCard: {
    backgroundColor: Colors.primary[50],
    marginBottom: Spacing.xl,
  },
  adviceTitle: {
    ...Typography.bodyMedium,
    color: Colors.primary[700],
    marginBottom: Spacing.md,
  },
  adviceText: {
    ...Typography.body,
    color: Colors.slate[700],
    lineHeight: 26,
    marginBottom: Spacing.lg,
  },
  actionBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.md,
    borderRadius: BorderRadius.full,
    alignSelf: 'flex-start',
  },
  actionIcon: {
    fontSize: 18,
    marginRight: Spacing.sm,
  },
  actionText: {
    ...Typography.bodySmall,
    color: Colors.slate[700],
    fontWeight: '500',
  },
  closing: {
    ...Typography.body,
    color: Colors.slate[500],
    textAlign: 'center',
    fontStyle: 'italic',
    marginBottom: Spacing.xxl,
  },
  feedbackSection: {
    alignItems: 'center',
    paddingTop: Spacing.xl,
    borderTopWidth: 1,
    borderTopColor: Colors.slate[100],
  },
  feedbackTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[600],
    marginBottom: Spacing.lg,
  },
  feedbackButtons: {
    flexDirection: 'row',
    gap: Spacing.md,
  },
  feedbackButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: Spacing.md,
    paddingHorizontal: Spacing.xl,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.slate[50],
    gap: Spacing.sm,
  },
  feedbackButtonActive: {
    backgroundColor: Colors.primary[50],
    borderWidth: 1,
    borderColor: Colors.primary[200],
  },
  feedbackButtonActiveNegative: {
    backgroundColor: Colors.rose[50],
    borderWidth: 1,
    borderColor: Colors.rose[200],
  },
  feedbackButtonText: {
    ...Typography.bodySmall,
    color: Colors.slate[500],
  },
  feedbackButtonTextActive: {
    color: Colors.primary[600],
    fontWeight: '600',
  },
  feedbackButtonTextActiveNegative: {
    color: Colors.rose[600],
    fontWeight: '600',
  },
  feedbackThanks: {
    ...Typography.caption,
    color: Colors.slate[500],
    marginTop: Spacing.lg,
  },
});
