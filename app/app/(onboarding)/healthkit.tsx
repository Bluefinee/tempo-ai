import React from 'react';
import { View, Text, StyleSheet, SafeAreaView } from 'react-native';
import { useRouter } from 'expo-router';
import { Heart } from 'lucide-react-native';
import { Colors, Spacing, Typography } from '../../src/theme';
import { PrimaryButton, SecondaryButton } from '../../src/components';

export default function HealthKitScreen() {
  const router = useRouter();

  const handleAllow = () => {
    // TODO: HealthKit permission request
    router.push('/(onboarding)/nickname');
  };

  const handleSkip = () => {
    router.push('/(onboarding)/nickname');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.iconContainer}>
          <Heart size={56} color={Colors.rose[500]} strokeWidth={1.5} />
        </View>

        <Text style={styles.title}>ヘルスケア連携</Text>
        <Text style={styles.description}>
          TempoAI はあなたの睡眠データと心拍変動（HRV）を分析して、
          コンディションを評価します。
        </Text>

        <View style={styles.infoBox}>
          <Text style={styles.infoTitle}>取得するデータ</Text>
          <View style={styles.dataList}>
            <DataItem icon="🌙" text="睡眠（就寝・起床時刻、睡眠ステージ）" />
            <DataItem icon="💓" text="心拍変動（HRV）" />
            <DataItem icon="👟" text="歩数・運動時間" />
          </View>
        </View>

        <Text style={styles.privacyNote}>
          データはデバイス内で処理され、外部に送信されません。
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

const DataItem: React.FC<{ icon: string; text: string }> = ({ icon, text }) => (
  <View style={styles.dataItem}>
    <Text style={styles.dataIcon}>{icon}</Text>
    <Text style={styles.dataText}>{text}</Text>
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
    backgroundColor: Colors.rose[50],
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
  dataList: {
    gap: Spacing.md,
  },
  dataItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  dataIcon: {
    fontSize: 18,
    marginRight: Spacing.md,
  },
  dataText: {
    ...Typography.bodySmall,
    color: Colors.slate[600],
    flex: 1,
  },
  privacyNote: {
    ...Typography.caption,
    color: Colors.slate[400],
    textAlign: 'center',
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
