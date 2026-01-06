import React from 'react';
import { View, Text, StyleSheet, SafeAreaView } from 'react-native';
import { useRouter } from 'expo-router';
import { MapPin } from 'lucide-react-native';
import { Colors, Spacing, Typography } from '../../src/theme';
import { PrimaryButton, SecondaryButton } from '../../src/components';

export default function LocationScreen() {
  const router = useRouter();

  const handleAllow = () => {
    // TODO: Request location permission
    router.push('/(onboarding)/complete');
  };

  const handleSkip = () => {
    router.push('/(onboarding)/complete');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.iconContainer}>
          <MapPin size={48} color={Colors.blue[500]} strokeWidth={1.5} />
        </View>

        <Text style={styles.title}>位置情報</Text>
        <Text style={styles.description}>
          天気や気圧情報を取得して{'\n'}
          環境に応じたアドバイスを提供します
        </Text>

        <View style={styles.infoBox}>
          <Text style={styles.infoTitle}>位置情報の利用目的</Text>
          <View style={styles.infoList}>
            <InfoItem icon="☀️" text="現在地の天気情報を取得" />
            <InfoItem icon="📊" text="気圧変化による体調影響を分析" />
            <InfoItem icon="🌡️" text="気温に応じた行動提案" />
          </View>
        </View>

        <Text style={styles.privacyNote}>
          位置情報は天気APIへの問い合わせにのみ使用され、{'\n'}
          サーバーには保存されません。
        </Text>
      </View>

      <View style={styles.footer}>
        <PrimaryButton onPress={handleAllow}>許可する</PrimaryButton>
        <SecondaryButton onPress={handleSkip} style={styles.skipButton}>
          あとで設定
        </SecondaryButton>
      </View>
    </SafeAreaView>
  );
}

const InfoItem: React.FC<{ icon: string; text: string }> = ({ icon, text }) => (
  <View style={styles.infoItem}>
    <Text style={styles.infoIcon}>{icon}</Text>
    <Text style={styles.infoText}>{text}</Text>
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
    paddingTop: Spacing.huge,
    alignItems: 'center',
  },
  iconContainer: {
    width: 100,
    height: 100,
    borderRadius: 25,
    backgroundColor: Colors.blue[50],
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
  infoBox: {
    width: '100%',
    backgroundColor: Colors.white,
    borderRadius: 16,
    padding: Spacing.xl,
    marginBottom: Spacing.lg,
  },
  infoTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[700],
    marginBottom: Spacing.md,
  },
  infoList: {
    gap: Spacing.md,
  },
  infoItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  infoIcon: {
    fontSize: 18,
    marginRight: Spacing.md,
  },
  infoText: {
    ...Typography.bodySmall,
    color: Colors.slate[600],
    flex: 1,
  },
  privacyNote: {
    ...Typography.caption,
    color: Colors.slate[400],
    textAlign: 'center',
    lineHeight: 18,
  },
  footer: {
    paddingHorizontal: Spacing.xxl,
    paddingBottom: Spacing.xxxl,
    gap: Spacing.md,
  },
  skipButton: {
    marginTop: Spacing.sm,
  },
});
