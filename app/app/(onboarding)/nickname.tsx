/**
 * NicknameScreen - ニックネーム入力画面
 * sozai/new のスタイルを React Native で再現
 * Step 3 of 9
 */

import React, { useState } from 'react';
import { View, Text, StyleSheet, useWindowDimensions, KeyboardAvoidingView, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Colors, FontFamily } from '../../src/theme';
import { PrimaryButton, InputField } from '../../src/components';
import { useUserStore } from '../../src/stores';
import type { JSX } from 'react';

const { width, height } = useWindowDimensions();
const CURRENT_STEP = 3;
const TOTAL_STEPS = 9;

export default function NicknameScreen(): JSX.Element {
  const router = useRouter();
  const setDraftNickname = useUserStore((state) => state.setDraftNickname);
  const draftNickname = useUserStore((state) => state.draftProfile.nickname);
  const [nickname, setNickname] = useState(draftNickname || '');
  const [error, setError] = useState('');

  const handleNext = (): void => {
    if (!nickname.trim()) {
      setError('Please enter a nickname');
      return;
    }
    if (nickname.length > 20) {
      setError('Nickname must be 20 characters or less');
      return;
    }
    setDraftNickname(nickname.trim());
    router.push('/(onboarding)/basic-info');
  };

  return (
    <View style={styles.container}>
      {/* Decorative background blobs */}
      <View style={styles.blobTopRight} />
      <View style={styles.blobBottomLeft} />

      <SafeAreaView style={styles.safeArea}>
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={styles.keyboardView}
        >
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
            <Text style={styles.emoji}>🤖</Text>
            <Text style={styles.title}>Warm AI Guidance</Text>
            <Text style={styles.description}>
              No robotic charts. Just gentle, poetic advice to help you feel your best.
            </Text>

            <View style={styles.inputWrapper}>
              <InputField
                label="What should we call you?"
                value={nickname}
                onChangeText={(text) => {
                  setNickname(text);
                  setError('');
                }}
                placeholder="Enter your name"
                autoFocus
                maxLength={20}
                error={error}
              />
            </View>
          </View>

          {/* Footer */}
          <View style={styles.footer}>
            <PrimaryButton
              onPress={handleNext}
              disabled={!nickname.trim()}
            >
              Continue
            </PrimaryButton>
          </View>
        </KeyboardAvoidingView>
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
  keyboardView: {
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
  inputWrapper: {
    width: '100%',
  },
  // Footer
  footer: {
    paddingHorizontal: 32,
    paddingBottom: 48,
    alignItems: 'center',
  },
});
