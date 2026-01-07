/**
 * LifestyleScreen - ライフスタイル選択画面
 * sozai/new のスタイルを React Native で再現
 * Step 7 of 9
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Briefcase, Dumbbell, Wine } from 'lucide-react-native';
import { Colors, FontFamily } from '../../src/theme';
import { PrimaryButton, SecondaryButton } from '../../src/components';
import {
  Occupation,
  ExerciseFrequency,
  AlcoholFrequency,
} from '../../src/domain/models';
import { useUserStore } from '../../src/stores';
import type { JSX } from 'react';

const { width, height } = Dimensions.get('window');
const CURRENT_STEP = 7;
const TOTAL_STEPS = 9;

const OCCUPATIONS: { value: Occupation; label: string }[] = [
  { value: 'deskWork', label: 'Desk Work' },
  { value: 'standingWork', label: 'Standing Work' },
  { value: 'physicalWork', label: 'Physical Labor' },
  { value: 'hybrid', label: 'Hybrid' },
  { value: 'other', label: 'Other' },
];

const EXERCISE_OPTIONS: { value: ExerciseFrequency; label: string }[] = [
  { value: 'rarely', label: 'Rarely' },
  { value: 'onceWeek', label: '1x/week' },
  { value: 'twiceWeek', label: '2x/week' },
  { value: 'threeOrMore', label: '3+/week' },
  { value: 'daily', label: 'Daily' },
];

const ALCOHOL_OPTIONS: { value: AlcoholFrequency; label: string }[] = [
  { value: 'never', label: 'Never' },
  { value: 'rarely', label: 'Rarely' },
  { value: 'onceWeek', label: '1x/week' },
  { value: 'twiceWeek', label: '2-3x/week' },
  { value: 'threeOrMore', label: '4+/week' },
  { value: 'daily', label: 'Daily' },
];

const LifestyleScreen = (): JSX.Element => {
  const router = useRouter();
  const setDraftLifestyle = useUserStore((state) => state.setDraftLifestyle);
  const draftProfile = useUserStore((state) => state.draftProfile);

  const [occupation, setOccupation] = useState<Occupation | null>(
    draftProfile.occupation || null
  );
  const [exercise, setExercise] = useState<ExerciseFrequency | null>(
    draftProfile.exerciseFrequency || null
  );
  const [alcohol, setAlcohol] = useState<AlcoholFrequency | null>(
    draftProfile.alcoholFrequency || null
  );

  const handleNext = (): void => {
    setDraftLifestyle({
      occupation: occupation || undefined,
      exerciseFrequency: exercise || undefined,
      alcoholFrequency: alcohol || undefined,
    });
    router.push('/(onboarding)/location');
  };

  const handleSkip = (): void => {
    router.push('/(onboarding)/location');
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

        <ScrollView
          style={styles.scrollView}
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          {/* Content */}
          <View style={styles.content}>
            <Text style={styles.emoji}>🏃</Text>
            <Text style={styles.title}>Daily Rhythms</Text>
            <Text style={styles.description}>
              Help us understand your lifestyle for more personalized insights. (Optional)
            </Text>

            {/* Occupation Section */}
            <View style={styles.section}>
              <View style={styles.sectionHeader}>
                <View style={styles.sectionIconContainer}>
                  <Briefcase size={18} color={Colors.indigo[500]} />
                </View>
                <Text style={styles.sectionTitle}>Work Type</Text>
              </View>
              <View style={styles.options}>
                {OCCUPATIONS.map((opt) => (
                  <TouchableOpacity
                    key={opt.value}
                    style={[
                      styles.chip,
                      occupation === opt.value && styles.chipSelected,
                    ]}
                    onPress={() => setOccupation(opt.value)}
                  >
                    <Text
                      style={[
                        styles.chipText,
                        occupation === opt.value && styles.chipTextSelected,
                      ]}
                    >
                      {opt.label}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>
            </View>

            {/* Exercise Section */}
            <View style={styles.section}>
              <View style={styles.sectionHeader}>
                <View style={styles.sectionIconContainer}>
                  <Dumbbell size={18} color={Colors.indigo[500]} />
                </View>
                <Text style={styles.sectionTitle}>Exercise Frequency</Text>
              </View>
              <View style={styles.options}>
                {EXERCISE_OPTIONS.map((opt) => (
                  <TouchableOpacity
                    key={opt.value}
                    style={[
                      styles.chip,
                      exercise === opt.value && styles.chipSelected,
                    ]}
                    onPress={() => setExercise(opt.value)}
                  >
                    <Text
                      style={[
                        styles.chipText,
                        exercise === opt.value && styles.chipTextSelected,
                      ]}
                    >
                      {opt.label}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>
            </View>

            {/* Alcohol Section */}
            <View style={styles.section}>
              <View style={styles.sectionHeader}>
                <View style={styles.sectionIconContainer}>
                  <Wine size={18} color={Colors.indigo[500]} />
                </View>
                <Text style={styles.sectionTitle}>Alcohol Consumption</Text>
              </View>
              <View style={styles.options}>
                {ALCOHOL_OPTIONS.map((opt) => (
                  <TouchableOpacity
                    key={opt.value}
                    style={[
                      styles.chip,
                      alcohol === opt.value && styles.chipSelected,
                    ]}
                    onPress={() => setAlcohol(opt.value)}
                  >
                    <Text
                      style={[
                        styles.chipText,
                        alcohol === opt.value && styles.chipTextSelected,
                      ]}
                    >
                      {opt.label}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>
            </View>
          </View>
        </ScrollView>

        {/* Footer */}
        <View style={styles.footer}>
          <PrimaryButton onPress={handleNext}>
            Continue
          </PrimaryButton>
          <SecondaryButton onPress={handleSkip} style={styles.skipButton}>
            Skip for Now
          </SecondaryButton>
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
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: 24,
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
  // Sections
  section: {
    width: '100%',
    marginBottom: 24,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  sectionIconContainer: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: Colors.indigo[50],
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
  },
  sectionTitle: {
    fontFamily: FontFamily.semibold,
    fontSize: 14,
    fontWeight: '600',
    color: Colors.stone[700],
  },
  options: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  chip: {
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 999,
    backgroundColor: Colors.white,
    borderWidth: 1,
    borderColor: Colors.stone[200],
  },
  chipSelected: {
    backgroundColor: Colors.indigo[50],
    borderColor: Colors.indigo[500],
  },
  chipText: {
    fontFamily: FontFamily.medium,
    fontSize: 13,
    fontWeight: '500',
    color: Colors.stone[600],
  },
  chipTextSelected: {
    color: Colors.indigo[600],
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

export default LifestyleScreen;
