import React, { useState } from 'react';
import { View, Text, StyleSheet, SafeAreaView, KeyboardAvoidingView, Platform } from 'react-native';
import { useRouter } from 'expo-router';
import { User } from 'lucide-react-native';
import { Colors, Spacing, Typography } from '../../src/theme';
import { PrimaryButton, InputField } from '../../src/components';
import { useUserStore } from '../../src/stores';
import type { JSX } from 'react';

export default function NicknameScreen(): JSX.Element {
  const router = useRouter();
  const setDraftNickname = useUserStore((state) => state.setDraftNickname);
  const draftNickname = useUserStore((state) => state.draftProfile.nickname);
  const [nickname, setNickname] = useState(draftNickname || '');
  const [error, setError] = useState('');

  const handleNext = (): void => {
    if (!nickname.trim()) {
      setError('ニックネームを入力してください');
      return;
    }
    if (nickname.length > 20) {
      setError('20文字以内で入力してください');
      return;
    }
    setDraftNickname(nickname.trim());
    router.push('/(onboarding)/basic-info');
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <View style={styles.content}>
          <View style={styles.iconContainer}>
            <User size={48} color={Colors.primary[500]} strokeWidth={1.5} />
          </View>

          <Text style={styles.title}>ニックネーム</Text>
          <Text style={styles.description}>
            AI があなたに呼びかける名前を{'\n'}教えてください
          </Text>

          <View style={styles.inputWrapper}>
            <InputField
              label="ニックネーム"
              value={nickname}
              onChangeText={(text) => {
                setNickname(text);
                setError('');
              }}
              placeholder="例: たろう"
              autoFocus
              maxLength={20}
              error={error}
            />
          </View>
        </View>

        <View style={styles.footer}>
          <PrimaryButton
            onPress={handleNext}
            disabled={!nickname.trim()}
          >
            次へ
          </PrimaryButton>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.slate[50],
  },
  keyboardView: {
    flex: 1,
  },
  content: {
    flex: 1,
    paddingHorizontal: Spacing.xxl,
    paddingTop: Spacing.huge,
    alignItems: 'center',
  },
  iconContainer: {
    width: 80,
    height: 80,
    borderRadius: 20,
    backgroundColor: Colors.primary[50],
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: Spacing.xxl,
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
  inputWrapper: {
    width: '100%',
  },
  footer: {
    paddingHorizontal: Spacing.xxl,
    paddingBottom: Spacing.xxxl,
  },
});
