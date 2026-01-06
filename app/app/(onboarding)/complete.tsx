import React from 'react';
import { View, Text, StyleSheet, SafeAreaView } from 'react-native';
import { useRouter } from 'expo-router';
import { CheckCircle } from 'lucide-react-native';
import { Colors, Spacing, Typography } from '../../src/theme';
import { PrimaryButton, ProgressBar } from '../../src/components';
import { CALIBRATION_PERIOD_DAYS } from '../../src/domain/models';
import { useUserStore } from '../../src/stores';

export default function CompleteScreen() {
  const router = useRouter();
  const completeOnboarding = useUserStore((state) => state.completeOnboarding);

  const handleComplete = () => {
    // Complete onboarding and save profile to store (persisted via Zustand middleware)
    completeOnboarding();
    // Navigate to main app
    router.replace('/(main)');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.iconContainer}>
          <CheckCircle size={64} color={Colors.primary[500]} strokeWidth={1.5} />
        </View>

        <Text style={styles.title}>準備完了！</Text>
        <Text style={styles.description}>
          TempoAI があなたの健康をサポートします
        </Text>

        <View style={styles.calibrationBox}>
          <Text style={styles.calibrationTitle}>キャリブレーション期間</Text>
          <Text style={styles.calibrationDescription}>
            最初の{CALIBRATION_PERIOD_DAYS}日間は、AIがあなたの睡眠パターンを
            学習します。この期間中はスコアが「---」と表示されますが、
            データは着実に蓄積されています。
          </Text>

          <View style={styles.progressSection}>
            <View style={styles.progressHeader}>
              <Text style={styles.progressLabel}>学習進捗</Text>
              <Text style={styles.progressValue}>0/{CALIBRATION_PERIOD_DAYS}日</Text>
            </View>
            <ProgressBar value={0} showAnimation={false} />
          </View>
        </View>

        <View style={styles.tips}>
          <Text style={styles.tipsTitle}>より良い分析のために</Text>
          <TipItem emoji="⌚" text="毎晩Apple Watchを着用して睡眠" />
          <TipItem emoji="🕐" text="できるだけ規則正しい生活を" />
          <TipItem emoji="📱" text="毎朝アプリをチェック" />
        </View>
      </View>

      <View style={styles.footer}>
        <PrimaryButton onPress={handleComplete}>はじめる</PrimaryButton>
      </View>
    </SafeAreaView>
  );
}

const TipItem: React.FC<{ emoji: string; text: string }> = ({ emoji, text }) => (
  <View style={styles.tipItem}>
    <Text style={styles.tipEmoji}>{emoji}</Text>
    <Text style={styles.tipText}>{text}</Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.slate[50],
  },
  content: {
    flex: 1,
    paddingHorizontal: Spacing.xxl,
    paddingTop: Spacing.huge,
    alignItems: 'center',
  },
  iconContainer: {
    width: 100,
    height: 100,
    borderRadius: 25,
    backgroundColor: Colors.primary[50],
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: Spacing.xxl,
  },
  title: {
    ...Typography.h2,
    color: Colors.slate[800],
    marginBottom: Spacing.md,
  },
  description: {
    ...Typography.body,
    color: Colors.slate[500],
    textAlign: 'center',
    marginBottom: Spacing.xxl,
  },
  calibrationBox: {
    width: '100%',
    backgroundColor: Colors.amber[50],
    borderRadius: 16,
    padding: Spacing.xl,
    marginBottom: Spacing.xl,
  },
  calibrationTitle: {
    ...Typography.bodyMedium,
    color: Colors.amber[700],
    marginBottom: Spacing.sm,
  },
  calibrationDescription: {
    ...Typography.bodySmall,
    color: Colors.amber[600],
    lineHeight: 20,
    marginBottom: Spacing.lg,
  },
  progressSection: {
    backgroundColor: Colors.white,
    borderRadius: 12,
    padding: Spacing.md,
  },
  progressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: Spacing.sm,
  },
  progressLabel: {
    ...Typography.caption,
    color: Colors.slate[500],
  },
  progressValue: {
    ...Typography.caption,
    color: Colors.amber[600],
    fontWeight: '600',
  },
  tips: {
    width: '100%',
    backgroundColor: Colors.white,
    borderRadius: 16,
    padding: Spacing.xl,
  },
  tipsTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[700],
    marginBottom: Spacing.md,
  },
  tipItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  tipEmoji: {
    fontSize: 18,
    marginRight: Spacing.md,
  },
  tipText: {
    ...Typography.bodySmall,
    color: Colors.slate[600],
  },
  footer: {
    paddingHorizontal: Spacing.xxl,
    paddingBottom: Spacing.xxxl,
  },
});
