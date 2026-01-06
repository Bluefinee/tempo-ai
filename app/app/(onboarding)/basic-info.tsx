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
import { User2 } from 'lucide-react-native';
import { Colors, Spacing, Typography, BorderRadius } from '../../src/theme';
import { PrimaryButton, InputField } from '../../src/components';
import { Gender, getGenderLabel } from '../../src/domain/models';
import { useUserStore } from '../../src/stores';

const GENDERS: Gender[] = ['male', 'female', 'other', 'preferNotToSay'];

export default function BasicInfoScreen() {
  const router = useRouter();
  const setDraftBasicInfo = useUserStore((state) => state.setDraftBasicInfo);
  const draftProfile = useUserStore((state) => state.draftProfile);

  const [age, setAge] = useState(draftProfile.age?.toString() || '');
  const [gender, setGender] = useState<Gender>(draftProfile.gender || 'preferNotToSay');
  const [height, setHeight] = useState(draftProfile.heightCm?.toString() || '');
  const [weight, setWeight] = useState(draftProfile.weightKg?.toString() || '');

  const isValid = age && height && weight;

  const handleNext = () => {
    setDraftBasicInfo({
      age: parseInt(age, 10),
      gender,
      heightCm: parseInt(height, 10),
      weightKg: parseInt(weight, 10),
    });
    router.push('/(onboarding)/chronotype');
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
      >
        <View style={styles.header}>
          <View style={styles.iconContainer}>
            <User2 size={40} color={Colors.indigo[500]} strokeWidth={1.5} />
          </View>
          <Text style={styles.title}>基本情報</Text>
          <Text style={styles.description}>
            より正確なアドバイスのために{'\n'}教えてください
          </Text>
        </View>

        <View style={styles.form}>
          <InputField
            label="年齢"
            value={age}
            onChangeText={setAge}
            placeholder="30"
            suffix="歳"
            keyboardType="number-pad"
          />

          <View style={styles.genderSection}>
            <Text style={styles.label}>性別</Text>
            <View style={styles.genderOptions}>
              {GENDERS.map((g) => (
                <TouchableOpacity
                  key={g}
                  style={[
                    styles.genderOption,
                    gender === g && styles.genderOptionSelected,
                  ]}
                  onPress={() => setGender(g)}
                >
                  <Text
                    style={[
                      styles.genderText,
                      gender === g && styles.genderTextSelected,
                    ]}
                  >
                    {getGenderLabel(g)}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          <View style={styles.row}>
            <View style={styles.halfInput}>
              <InputField
                label="身長"
                value={height}
                onChangeText={setHeight}
                placeholder="170"
                suffix="cm"
                keyboardType="number-pad"
              />
            </View>
            <View style={styles.halfInput}>
              <InputField
                label="体重"
                value={weight}
                onChangeText={setWeight}
                placeholder="65"
                suffix="kg"
                keyboardType="number-pad"
              />
            </View>
          </View>
        </View>
      </ScrollView>

      <View style={styles.footer}>
        <PrimaryButton onPress={handleNext} disabled={!isValid}>
          次へ
        </PrimaryButton>
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
  header: {
    alignItems: 'center',
    marginBottom: Spacing.xxl,
  },
  iconContainer: {
    width: 72,
    height: 72,
    borderRadius: 18,
    backgroundColor: Colors.indigo[50],
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: Spacing.lg,
  },
  title: {
    ...Typography.h2,
    color: Colors.slate[800],
    marginBottom: Spacing.sm,
  },
  description: {
    ...Typography.body,
    color: Colors.slate[500],
    textAlign: 'center',
    lineHeight: 24,
  },
  form: {
    width: '100%',
  },
  genderSection: {
    marginBottom: Spacing.xl,
  },
  label: {
    ...Typography.label,
    color: Colors.slate[500],
    marginBottom: Spacing.sm,
    marginLeft: Spacing.xs,
  },
  genderOptions: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing.sm,
  },
  genderOption: {
    paddingVertical: Spacing.md,
    paddingHorizontal: Spacing.lg,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.white,
    borderWidth: 1,
    borderColor: Colors.slate[100],
  },
  genderOptionSelected: {
    backgroundColor: Colors.primary[50],
    borderColor: Colors.primary[500],
  },
  genderText: {
    ...Typography.bodySmall,
    color: Colors.slate[600],
  },
  genderTextSelected: {
    color: Colors.primary[600],
    fontWeight: '600',
  },
  row: {
    flexDirection: 'row',
    gap: Spacing.md,
  },
  halfInput: {
    flex: 1,
  },
  footer: {
    paddingHorizontal: Spacing.xxl,
    paddingBottom: Spacing.xxxl,
  },
});
