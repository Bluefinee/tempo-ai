/**
 * HealthKitScreen - ヘルスケア連携画面
 * sozai/new のスタイルを React Native で再現
 * Step 2 of 9
 */

import React from 'react';
import { View, Text, StyleSheet, useWindowDimensions } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Colors, Spacing, BorderRadius, FontFamily } from '../../src/theme';
import { PrimaryButton, SecondaryButton } from '../../src/components';
import type { JSX } from 'react';

const CURRENT_STEP = 2;
const TOTAL_STEPS = 9;

const HealthKitScreen = (): JSX.Element => {
  const router = useRouter();
  const { width, height } = useWindowDimensions();

  const handleAllow = () => {
    // TODO: HealthKit permission request
    router.push('/(onboarding)/nickname');
  };

  const handleSkip = () => {
    router.push('/(onboarding)/nickname');
  };

  return (
    <View style={styles.container}>
      {/* Decorative background blobs */}
      <View style={styles.blobTopRight} />
      <View style={styles.blobBottomLeft} />

      <SafeAreaView style={styles.safeArea}>
        {/* Progress Bar */}
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
          <Text style={styles.emoji}>❤️</Text>
          <Text style={styles.title}>Heart Rate Variability</Text>
          <Text style={styles.description}>
            We measure the tiny variations in your heartbeat to understand how recovered and ready you are.
          </Text>

          {/* Data info box */}
          <View style={styles.infoBox}>
            <Text style={styles.infoTitle}>Data We&apos;ll Access</Text>
            <View style={styles.dataList}>
              <DataItem emoji="🌙" text="Sleep (duration, stages)" />
              <DataItem emoji="💓" text="Heart Rate Variability (HRV)" />
              <DataItem emoji="👟" text="Steps & Activity" />
            </View>
          </View>

          <Text style={styles.privacyNote}>
            Your data stays on your device. We never share it.
          </Text>
        </View>

        {/* Footer */}
        <View style={styles.footer}>
          <PrimaryButton onPress={handleAllow}>
            Allow Access
          </PrimaryButton>
          <SecondaryButton onPress={handleSkip} style={styles.skipButton}>
            Set Up Later
          </SecondaryButton>
        </View>
      </SafeAreaView>
    </View>
  );
}

const DataItem: React.FC<{ emoji: string; text: string }> = ({ emoji, text }): JSX.Element => (
  <View style={styles.dataItem}>
    <Text style={styles.dataEmoji}>{emoji}</Text>
    <Text style={styles.dataText}>{text}</Text>
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
    backgroundColor: Colors.rose[100],
    borderRadius: 128,
    opacity: 0.4,
  },
  blobBottomLeft: {
    position: 'absolute',
    bottom: -80,
    left: -60,
    width: 320,
    height: 320,
    backgroundColor: Colors.indigo[100],
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
  // Info box
  infoBox: {
    width: '100%',
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.lg,
    padding: Spacing.lg,
    marginBottom: Spacing.lg,
    borderWidth: 1,
    borderColor: Colors.stone[100],
  },
  infoTitle: {
    fontFamily: FontFamily.bold,
    fontSize: 14,
    fontWeight: '700',
    color: Colors.stone[700],
    marginBottom: 12,
  },
  dataList: {
    gap: 12,
  },
  dataItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  dataEmoji: {
    fontSize: 18,
    marginRight: 12,
  },
  dataText: {
    fontFamily: FontFamily.regular,
    fontSize: 14,
    color: Colors.stone[600],
    flex: 1,
  },
  privacyNote: {
    fontFamily: FontFamily.regular,
    fontSize: 12,
    color: Colors.stone[400],
    textAlign: 'center',
  },
  // Footer
  footer: {
    paddingHorizontal: 32,
    paddingBottom: 48,
    alignItems: 'center',
    gap: 12,
  },
  skipButton: {
    marginTop: 4,
  },
});

export default HealthKitScreen;
