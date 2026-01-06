import React from 'react';
import { View, Text, StyleSheet, SafeAreaView } from 'react-native';
import { useRouter } from 'expo-router';
import { Sun } from 'lucide-react-native';
import { Colors, Spacing, Typography } from '../../src/theme';
import { PrimaryButton } from '../../src/components';

export default function WelcomeScreen() {
  const router = useRouter();

  const handleStart = () => {
    router.push('/(onboarding)/healthkit');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.iconContainer}>
          <Sun size={64} color={Colors.primary[500]} strokeWidth={1.5} />
        </View>

        <Text style={styles.title}>TempoAI</Text>
        <Text style={styles.subtitle}>あなたの毎日を科学的にサポート</Text>

        <View style={styles.features}>
          <FeatureItem
            emoji="🌙"
            title="睡眠分析"
            description="Apple Watchの睡眠データを分析"
          />
          <FeatureItem
            emoji="💚"
            title="自律神経"
            description="HRVから回復度を可視化"
          />
          <FeatureItem
            emoji="🎯"
            title="パーソナルAI"
            description="あなたに合ったアドバイス"
          />
        </View>
      </View>

      <View style={styles.footer}>
        <PrimaryButton onPress={handleStart}>はじめる</PrimaryButton>
      </View>
    </SafeAreaView>
  );
}

const FeatureItem: React.FC<{
  emoji: string;
  title: string;
  description: string;
}> = ({ emoji, title, description }) => (
  <View style={styles.featureItem}>
    <Text style={styles.featureEmoji}>{emoji}</Text>
    <View style={styles.featureText}>
      <Text style={styles.featureTitle}>{title}</Text>
      <Text style={styles.featureDescription}>{description}</Text>
    </View>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.slate[50],
  },
  content: {
    flex: 1,
    paddingHorizontal: Spacing.xxl,
    paddingTop: Spacing.giant,
    alignItems: 'center',
  },
  iconContainer: {
    width: 120,
    height: 120,
    borderRadius: 30,
    backgroundColor: Colors.primary[50],
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: Spacing.xxl,
  },
  title: {
    ...Typography.h1,
    color: Colors.slate[800],
    marginBottom: Spacing.sm,
  },
  subtitle: {
    ...Typography.body,
    color: Colors.slate[500],
    marginBottom: Spacing.huge,
  },
  features: {
    width: '100%',
    gap: Spacing.lg,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    borderRadius: 16,
    padding: Spacing.lg,
    shadowColor: Colors.slate[900],
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  featureEmoji: {
    fontSize: 32,
    marginRight: Spacing.lg,
  },
  featureText: {
    flex: 1,
  },
  featureTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[800],
    marginBottom: 2,
  },
  featureDescription: {
    ...Typography.bodySmall,
    color: Colors.slate[500],
  },
  footer: {
    paddingHorizontal: Spacing.xxl,
    paddingBottom: Spacing.xxxl,
  },
});
