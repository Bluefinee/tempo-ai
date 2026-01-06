import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { useRouter } from 'expo-router';
import { Briefcase, Dumbbell, Wine } from 'lucide-react-native';
import { Colors, Spacing, Typography, BorderRadius } from '../../src/theme';
import { PrimaryButton, SecondaryButton } from '../../src/components';
import {
  Occupation,
  ExerciseFrequency,
  AlcoholFrequency,
} from '../../src/domain/models';
import { useUserStore } from '../../src/stores';
import type { JSX } from 'react';

const OCCUPATIONS: { value: Occupation; label: string }[] = [
  { value: 'deskWork', label: 'デスクワーク' },
  { value: 'standingWork', label: '立ち仕事' },
  { value: 'physicalWork', label: '肉体労働' },
  { value: 'hybrid', label: 'ハイブリッド' },
  { value: 'other', label: 'その他' },
];

const EXERCISE_OPTIONS: { value: ExerciseFrequency; label: string }[] = [
  { value: 'rarely', label: 'ほとんどしない' },
  { value: 'onceWeek', label: '週1回' },
  { value: 'twiceWeek', label: '週2回' },
  { value: 'threeOrMore', label: '週3回以上' },
  { value: 'daily', label: '毎日' },
];

const ALCOHOL_OPTIONS: { value: AlcoholFrequency; label: string }[] = [
  { value: 'never', label: '飲まない' },
  { value: 'rarely', label: 'ほとんど飲まない' },
  { value: 'onceWeek', label: '週1回' },
  { value: 'twiceWeek', label: '週2-3回' },
  { value: 'threeOrMore', label: '週4回以上' },
  { value: 'daily', label: '毎日' },
];

export default function LifestyleScreen(): JSX.Element {
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
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
      >
        <Text style={styles.title}>ライフスタイル</Text>
        <Text style={styles.description}>
          より精度の高いアドバイスのために{'\n'}
          教えてください（任意）
        </Text>

        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Briefcase size={20} color={Colors.slate[500]} />
            <Text style={styles.sectionTitle}>職業タイプ</Text>
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

        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Dumbbell size={20} color={Colors.slate[500]} />
            <Text style={styles.sectionTitle}>運動頻度</Text>
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

        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Wine size={20} color={Colors.slate[500]} />
            <Text style={styles.sectionTitle}>飲酒頻度</Text>
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
      </ScrollView>

      <View style={styles.footer}>
        <PrimaryButton onPress={handleNext}>次へ</PrimaryButton>
        <SecondaryButton onPress={handleSkip} style={styles.skipButton}>
          スキップ
        </SecondaryButton>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.slate[50],
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: Spacing.xxl,
    paddingTop: Spacing.huge,
    paddingBottom: Spacing.lg,
  },
  title: {
    ...Typography.h2,
    color: Colors.slate[800],
    marginBottom: Spacing.md,
    textAlign: 'center',
  },
  description: {
    ...Typography.body,
    color: Colors.slate[500],
    textAlign: 'center',
    marginBottom: Spacing.xxl,
    lineHeight: 24,
  },
  section: {
    marginBottom: Spacing.xxl,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.md,
  },
  sectionTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[700],
    marginLeft: Spacing.sm,
  },
  options: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing.sm,
  },
  chip: {
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.lg,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.white,
    borderWidth: 1,
    borderColor: Colors.slate[100],
  },
  chipSelected: {
    backgroundColor: Colors.primary[50],
    borderColor: Colors.primary[500],
  },
  chipText: {
    ...Typography.bodySmall,
    color: Colors.slate[600],
  },
  chipTextSelected: {
    color: Colors.primary[600],
    fontWeight: '600',
  },
  footer: {
    paddingHorizontal: Spacing.xxl,
    paddingBottom: Spacing.xxxl,
    gap: Spacing.md,
  },
  skipButton: {
    marginTop: Spacing.xs,
  },
});
