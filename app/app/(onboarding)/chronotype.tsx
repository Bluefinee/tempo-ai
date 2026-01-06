import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  TouchableOpacity,
} from 'react-native';
import { useRouter } from 'expo-router';
import { Sun, Moon, Clock } from 'lucide-react-native';
import { Colors, Spacing, Typography, BorderRadius } from '../../src/theme';
import { PrimaryButton } from '../../src/components';
import { Chronotype, getChronotypeLabel } from '../../src/domain/models';
import { useUserStore } from '../../src/stores';

interface ChronotypeOption {
  value: Chronotype;
  icon: React.ReactNode;
  description: string;
}

const CHRONOTYPE_OPTIONS: ChronotypeOption[] = [
  {
    value: 'morning',
    icon: <Sun size={32} color={Colors.amber[500]} />,
    description: '早起きが得意で\n午前中に集中力が高い',
  },
  {
    value: 'intermediate',
    icon: <Clock size={32} color={Colors.primary[500]} />,
    description: '特に朝型・夜型の\n傾向がない',
  },
  {
    value: 'evening',
    icon: <Moon size={32} color={Colors.indigo[500]} />,
    description: '夜の方が活動的で\n朝は苦手',
  },
];

export default function ChronotypeScreen() {
  const router = useRouter();
  const setDraftChronotype = useUserStore((state) => state.setDraftChronotype);
  const draftChronotype = useUserStore((state) => state.draftProfile.chronotype);
  const [chronotype, setChronotype] = useState<Chronotype>(draftChronotype || 'intermediate');

  const handleNext = () => {
    setDraftChronotype(chronotype);
    router.push('/(onboarding)/bedtime');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>あなたのタイプは？</Text>
        <Text style={styles.description}>
          朝型・夜型の傾向を教えてください{'\n'}
          アドバイスの最適化に使用します
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

      <View style={styles.footer}>
        <PrimaryButton onPress={handleNext}>次へ</PrimaryButton>
      </View>
    </SafeAreaView>
  );
}

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
  options: {
    width: '100%',
    gap: Spacing.md,
  },
  optionCard: {
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.xl,
    padding: Spacing.xl,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'transparent',
    shadowColor: Colors.slate[900],
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  optionCardSelected: {
    borderColor: Colors.primary[500],
    backgroundColor: Colors.primary[50],
  },
  optionIcon: {
    marginBottom: Spacing.md,
  },
  optionLabel: {
    ...Typography.h5,
    color: Colors.slate[700],
    marginBottom: Spacing.xs,
  },
  optionLabelSelected: {
    color: Colors.primary[600],
  },
  optionDescription: {
    ...Typography.bodySmall,
    color: Colors.slate[500],
    textAlign: 'center',
    lineHeight: 20,
  },
  footer: {
    paddingHorizontal: Spacing.xxl,
    paddingBottom: Spacing.xxxl,
  },
});
