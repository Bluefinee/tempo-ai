/**
 * ChronotypeScreen - クロノタイプ選択画面
 * sozai/new のスタイルを React Native で再現
 * Step 5 of 9
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Sun, Moon, Clock } from 'lucide-react-native';
import { Colors, Spacing, BorderRadius, FontFamily } from '../../src/theme';
import { PrimaryButton } from '../../src/components';
import { Chronotype, getChronotypeLabel } from '../../src/domain/models';
import { useUserStore } from '../../src/stores';
import type { JSX } from 'react';

const { width, height } = Dimensions.get('window');
const CURRENT_STEP = 5;
const TOTAL_STEPS = 9;

interface ChronotypeOption {
  value: Chronotype;
  icon: React.ReactNode;
  description: string;
}

const CHRONOTYPE_OPTIONS: ChronotypeOption[] = [
  {
    value: 'morning',
    icon: <Sun size={32} color={Colors.amber[500]} />,
    description: 'I wake up early naturally and feel most energized in the morning.',
  },
  {
    value: 'intermediate',
    icon: <Clock size={32} color={Colors.indigo[500]} />,
    description: 'No strong preference. I adapt to most schedules.',
  },
  {
    value: 'evening',
    icon: <Moon size={32} color={Colors.indigo[500]} />,
    description: 'I come alive at night and find mornings difficult.',
  },
];

export default function ChronotypeScreen(): JSX.Element {
  const router = useRouter();
  const setDraftChronotype = useUserStore((state) => state.setDraftChronotype);
  const draftChronotype = useUserStore((state) => state.draftProfile.chronotype);
  const [chronotype, setChronotype] = useState<Chronotype>(draftChronotype || 'intermediate');

  const handleNext = (): void => {
    setDraftChronotype(chronotype);
    router.push('/(onboarding)/bedtime');
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
          <Text style={styles.emoji}>🌙</Text>
          <Text style={styles.title}>Circadian Sync</Text>
          <Text style={styles.description}>
            Light, food, and movement timed right can fix your sleep and boost your focus.
          </Text>

          <View style={styles.options}>
            {CHRONOTYPE_OPTIONS.map((option) => (
              <TouchableOpacity
                key={option.value}
                style={[
                  styles.optionCard,
                  chronotype === option.value && styles.optionCardSelected,
                ]}
                onPress={() => setChronotype(option.value)}
              >
                <View style={styles.optionIcon}>{option.icon}</View>
                <Text
                  style={[
                    styles.optionLabel,
                    chronotype === option.value && styles.optionLabelSelected,
                  ]}
                >
                  {getChronotypeLabel(option.value)}
                </Text>
                <Text style={styles.optionDescription}>{option.description}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Footer */}
        <View style={styles.footer}>
          <PrimaryButton onPress={handleNext}>
            Continue
          </PrimaryButton>
        </View>
      </SafeAreaView>
    </View>
  );
}

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
    top: -height * 0.15,
    right: -width * 0.2,
    width: 256,
    height: 256,
    backgroundColor: Colors.indigo[100],
    borderRadius: 128,
    opacity: 0.4,
  },
  blobBottomLeft: {
    position: 'absolute',
    bottom: -height * 0.1,
    left: -width * 0.15,
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
    paddingHorizontal: 32,
    paddingTop: 32,
  },
  emoji: {
    fontSize: 60,
    marginBottom: 24,
  },
  title: {
    fontFamily: FontFamily.serif,
    fontSize: 24,
    fontWeight: '700',
    color: Colors.stone[900],
    textAlign: 'center',
    letterSpacing: -0.5,
    marginBottom: 12,
  },
  description: {
    fontFamily: FontFamily.regular,
    fontSize: 16,
    color: Colors.stone[500],
    textAlign: 'center',
    lineHeight: 26,
    marginBottom: 32,
  },
  // Options
  options: {
    width: '100%',
    gap: 12,
  },
  optionCard: {
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.lg,
    padding: Spacing.lg,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'transparent',
    // shadow-soft
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 20,
    elevation: 4,
  },
  optionCardSelected: {
    borderColor: Colors.indigo[500],
    backgroundColor: Colors.indigo[50],
  },
  optionIcon: {
    marginBottom: 12,
  },
  optionLabel: {
    fontFamily: FontFamily.bold,
    fontSize: 16,
    fontWeight: '700',
    color: Colors.stone[700],
    marginBottom: 4,
  },
  optionLabelSelected: {
    color: Colors.indigo[600],
  },
  optionDescription: {
    fontFamily: FontFamily.regular,
    fontSize: 12,
    color: Colors.stone[500],
    textAlign: 'center',
    lineHeight: 18,
  },
  // Footer
  footer: {
    paddingHorizontal: 32,
    paddingBottom: 48,
    alignItems: 'center',
  },
});
