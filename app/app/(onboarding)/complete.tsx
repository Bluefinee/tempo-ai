/**
 * CompleteScreen - オンボーディング完了画面
 * sozai/new のスタイルを React Native で再現
 * Step 9 of 9 (Final)
 */

import React from 'react';
import { View, Text, StyleSheet, useWindowDimensions } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Colors, Spacing, BorderRadius, FontFamily } from '../../src/theme';
import { PrimaryButton, ProgressBar } from '../../src/components';
import { CALIBRATION_PERIOD_DAYS } from '../../src/domain/models';
import { useUserStore } from '../../src/stores';
import type { JSX } from 'react';

const CURRENT_STEP = 9;
const TOTAL_STEPS = 9;

export default function CompleteScreen(): JSX.Element {
  const router = useRouter();
  const { width, height } = useWindowDimensions();
  const completeOnboarding = useUserStore((state) => state.completeOnboarding);

  const handleComplete = () => {
    completeOnboarding();
    router.replace('/(main)');
  };

  return (
    <View style={styles.container}>
      {/* Decorative background blobs */}
      <View style={styles.blobTopRight} />
      <View style={styles.blobBottomLeft} />

      <SafeAreaView style={styles.safeArea}>
        {/* Progress Bar - All complete */}
        <View style={styles.progressContainer}>
          {[...Array(TOTAL_STEPS)].map((_, idx) => (
            <View
              key={idx}
              style={[
                styles.progressSegment,
                idx < CURRENT_STEP ? styles.progressActive : styles.progressInactive,
              ]}
            />
          ))}
        </View>

        {/* Content */}
        <View style={styles.content}>
          <Text style={styles.emoji}>✨</Text>
          <Text style={styles.title}>Ready?</Text>
          <Text style={styles.description}>
            Let&apos;s find your rhythm.
          </Text>

          {/* Calibration info */}
          <View style={styles.calibrationBox}>
            <Text style={styles.calibrationTitle}>Calibration Period</Text>
            <Text style={styles.calibrationDescription}>
              For the first {CALIBRATION_PERIOD_DAYS} days, Tempo will learn your unique patterns.
              Your score may show &quot;---&quot; during this time, but your data is being collected.
            </Text>

            <View style={styles.progressSection}>
              <View style={styles.progressHeader}>
                <Text style={styles.progressLabel}>Learning Progress</Text>
                <Text style={styles.progressValue}>0/{CALIBRATION_PERIOD_DAYS} days</Text>
              </View>
              <ProgressBar value={0} showAnimation={false} />
            </View>
          </View>

          {/* Tips */}
          <View style={styles.tipsBox}>
            <Text style={styles.tipsTitle}>For Better Analysis</Text>
            <TipItem emoji="⌚" text="Wear your Apple Watch while sleeping" />
            <TipItem emoji="🕐" text="Try to maintain a regular schedule" />
            <TipItem emoji="📱" text="Check the app each morning" />
          </View>
        </View>

        {/* Footer */}
        <View style={styles.footer}>
          <PrimaryButton onPress={handleComplete} isLast>
            Get Started
          </PrimaryButton>
        </View>
      </SafeAreaView>
    </View>
  );
}

const TipItem: React.FC<{ emoji: string; text: string }> = ({ emoji, text }): JSX.Element => (
  <View style={styles.tipItem}>
    <Text style={styles.tipEmoji}>{emoji}</Text>
    <Text style={styles.tipText}>{text}</Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.stone[50],
    overflow: 'hidden',
  },
  safeArea: {
    flex: 1,
  },
  // Decorative blobs
  blobTopRight: {
    position: 'absolute',
    top: -100,
    right: -80,
    width: 256,
    height: 256,
    backgroundColor: Colors.indigo[100],
    borderRadius: 128,
    opacity: 0.4,
  },
  blobBottomLeft: {
    position: 'absolute',
    bottom: -80,
    left: -60,
    width: 320,
    height: 320,
    backgroundColor: Colors.amber[100],
    borderRadius: 160,
    opacity: 0.4,
  },
  // Progress bar
  progressContainer: {
    flexDirection: 'row',
    paddingHorizontal: 32,
    paddingTop: 48,
    gap: 8,
  },
  progressSegment: {
    flex: 1,
    height: 4,
    borderRadius: 2,
  },
  progressActive: {
    backgroundColor: Colors.indigo[500],
  },
  progressInactive: {
    backgroundColor: Colors.stone[200],
  },
  // Content
  content: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 32,
  },
  emoji: {
    fontSize: 60,
    marginBottom: 32,
  },
  title: {
    fontFamily: FontFamily.serif,
    fontSize: 24,
    fontWeight: '700',
    color: Colors.stone[900],
    textAlign: 'center',
    letterSpacing: -0.5,
    marginBottom: 16,
  },
  description: {
    fontFamily: FontFamily.regular,
    fontSize: 16,
    color: Colors.stone[500],
    textAlign: 'center',
    lineHeight: 26,
    marginBottom: 32,
  },
  // Calibration box
  calibrationBox: {
    width: '100%',
    backgroundColor: Colors.amber[50],
    borderRadius: BorderRadius.lg,
    padding: Spacing.lg,
    marginBottom: Spacing.lg,
    borderWidth: 1,
    borderColor: Colors.amber[100],
  },
  calibrationTitle: {
    fontFamily: FontFamily.bold,
    fontSize: 14,
    fontWeight: '700',
    color: Colors.amber[600],
    marginBottom: 8,
  },
  calibrationDescription: {
    fontFamily: FontFamily.regular,
    fontSize: 12,
    color: Colors.amber[600],
    lineHeight: 20,
    marginBottom: 16,
  },
  progressSection: {
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.md,
    padding: Spacing.md,
  },
  progressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  progressLabel: {
    fontFamily: FontFamily.regular,
    fontSize: 12,
    color: Colors.stone[500],
  },
  progressValue: {
    fontFamily: FontFamily.semibold,
    fontSize: 12,
    fontWeight: '600',
    color: Colors.amber[600],
  },
  // Tips box
  tipsBox: {
    width: '100%',
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.lg,
    padding: Spacing.lg,
    borderWidth: 1,
    borderColor: Colors.stone[100],
  },
  tipsTitle: {
    fontFamily: FontFamily.bold,
    fontSize: 14,
    fontWeight: '700',
    color: Colors.stone[700],
    marginBottom: 12,
  },
  tipItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  tipEmoji: {
    fontSize: 18,
    marginRight: 12,
  },
  tipText: {
    fontFamily: FontFamily.regular,
    fontSize: 14,
    color: Colors.stone[600],
  },
  // Footer
  footer: {
    paddingHorizontal: 32,
    paddingBottom: 48,
    alignItems: 'center',
  },
});
