/**
 * BasicInfoScreen - 基本情報入力画面
 * sozai/new のスタイルを React Native で再現
 * Step 4 of 9
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
import { Colors, Spacing, BorderRadius, FontFamily } from '../../src/theme';
import { PrimaryButton, InputField } from '../../src/components';
import { Gender, getGenderLabel } from '../../src/domain/models';
import { useUserStore } from '../../src/stores';
import type { JSX } from 'react';

const { width, height } = Dimensions.get('window');
const CURRENT_STEP = 4;
const TOTAL_STEPS = 9;
const GENDERS: Gender[] = ['male', 'female', 'other', 'preferNotToSay'];

export default function BasicInfoScreen(): JSX.Element {
  const router = useRouter();
  const setDraftBasicInfo = useUserStore((state) => state.setDraftBasicInfo);
  const draftProfile = useUserStore((state) => state.draftProfile);

  const [age, setAge] = useState(draftProfile.age?.toString() || '');
  const [gender, setGender] = useState<Gender>(draftProfile.gender || 'preferNotToSay');
  const [heightVal, setHeightVal] = useState(draftProfile.heightCm?.toString() || '');
  const [weight, setWeight] = useState(draftProfile.weightKg?.toString() || '');

  const parsedAge = parseInt(age, 10);
  const parsedHeight = parseInt(heightVal, 10);
  const parsedWeight = parseInt(weight, 10);
  const isValid =
    age && !isNaN(parsedAge) && parsedAge > 0 && parsedAge < 150 &&
    heightVal && !isNaN(parsedHeight) && parsedHeight > 0 &&
    weight && !isNaN(parsedWeight) && parsedWeight > 0;

  const handleNext = (): void => {
    if (isValid) {
      setDraftBasicInfo({
        age: parsedAge,
        gender,
        heightCm: parsedHeight,
        weightKg: parsedWeight,
      });
      router.push('/(onboarding)/chronotype');
    }
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
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {/* Content */}
          <View style={styles.content}>
            <Text style={styles.emoji}>🌊</Text>
            <Text style={styles.title}>Your Body is an Ocean</Text>
            <Text style={styles.description}>
              Your energy isn&apos;t a straight line. It flows like a tide. Tell us a bit about yourself.
            </Text>

            {/* Form */}
            <View style={styles.form}>
              <InputField
                label="Age"
                value={age}
                onChangeText={setAge}
                placeholder="30"
                suffix="years"
                keyboardType="number-pad"
              />

              <View style={styles.genderSection}>
                <Text style={styles.label}>Gender</Text>
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
                    label="Height"
                    value={heightVal}
                    onChangeText={setHeightVal}
                    placeholder="170"
                    suffix="cm"
                    keyboardType="number-pad"
                  />
                </View>
                <View style={styles.halfInput}>
                  <InputField
                    label="Weight"
                    value={weight}
                    onChangeText={setWeight}
                    placeholder="65"
                    suffix="kg"
                    keyboardType="number-pad"
                  />
                </View>
              </View>
            </View>
          </View>
        </ScrollView>

        {/* Footer */}
        <View style={styles.footer}>
          <PrimaryButton onPress={handleNext} disabled={!isValid}>
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
  // Form
  form: {
    width: '100%',
  },
  genderSection: {
    marginBottom: Spacing.lg,
  },
  label: {
    fontFamily: FontFamily.medium,
    fontSize: 12,
    fontWeight: '500',
    color: Colors.stone[500],
    textTransform: 'uppercase',
    letterSpacing: 1,
    marginBottom: 8,
    marginLeft: 4,
  },
  genderOptions: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  genderOption: {
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 999,
    backgroundColor: Colors.white,
    borderWidth: 1,
    borderColor: Colors.stone[200],
  },
  genderOptionSelected: {
    backgroundColor: Colors.indigo[50],
    borderColor: Colors.indigo[500],
  },
  genderText: {
    fontFamily: FontFamily.medium,
    fontSize: 14,
    fontWeight: '500',
    color: Colors.stone[600],
  },
  genderTextSelected: {
    color: Colors.indigo[600],
  },
  row: {
    flexDirection: 'row',
    gap: 16,
  },
  halfInput: {
    flex: 1,
  },
  // Footer
  footer: {
    paddingHorizontal: 32,
    paddingBottom: 48,
    alignItems: 'center',
  },
});
