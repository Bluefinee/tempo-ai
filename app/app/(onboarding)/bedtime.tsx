import React, { useState } from 'react';
import { View, Text, StyleSheet, SafeAreaView, Platform } from 'react-native';
import { useRouter } from 'expo-router';
import { Bed } from 'lucide-react-native';
import { Colors, Spacing, Typography } from '../../src/theme';
import { PrimaryButton } from '../../src/components';
import { useUserStore } from '../../src/stores';

const HOURS = Array.from({ length: 6 }, (_, i) => 20 + i); // 20:00 - 01:00
const MINUTES = [0, 15, 30, 45];

const parseTime = (timeStr: string): { hour: number; minute: number } => {
  const [h, m] = timeStr.split(':').map(Number);
  // Convert hours < 20 (like 00, 01) to 24, 25 format
  const normalizedHour = h < 20 ? h + 24 : h;
  return { hour: normalizedHour, minute: m };
};

export default function BedtimeScreen() {
  const router = useRouter();
  const setDraftTargetBedtime = useUserStore((state) => state.setDraftTargetBedtime);
  const draftBedtime = useUserStore((state) => state.draftProfile.targetBedtime);

  const initialTime = draftBedtime ? parseTime(draftBedtime) : { hour: 23, minute: 0 };
  const [hour, setHour] = useState(initialTime.hour);
  const [minute, setMinute] = useState(initialTime.minute);

  const formatTime = (h: number, m: number): string => {
    const displayHour = h >= 24 ? h - 24 : h;
    return `${displayHour.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
  };

  const handleNext = () => {
    setDraftTargetBedtime(formatTime(hour, minute));
    router.push('/(onboarding)/lifestyle');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.iconContainer}>
          <Bed size={48} color={Colors.indigo[500]} strokeWidth={1.5} />
        </View>

        <Text style={styles.title}>目標就寝時刻</Text>
        <Text style={styles.description}>
          理想的な就寝時刻を設定してください{'\n'}
          AIがリズムを分析する基準になります
        </Text>

        <View style={styles.timeDisplay}>
          <Text style={styles.timeText}>{formatTime(hour, minute)}</Text>
        </View>

        <View style={styles.pickerContainer}>
          <View style={styles.pickerColumn}>
            <Text style={styles.pickerLabel}>時</Text>
            {HOURS.map((h) => (
              <Text
                key={h}
                style={[
                  styles.pickerItem,
                  hour === h && styles.pickerItemSelected,
                ]}
                onPress={() => setHour(h)}
              >
                {h >= 24 ? h - 24 : h}
              </Text>
            ))}
          </View>
          <View style={styles.pickerColumn}>
            <Text style={styles.pickerLabel}>分</Text>
            {MINUTES.map((m) => (
              <Text
                key={m}
                style={[
                  styles.pickerItem,
                  minute === m && styles.pickerItemSelected,
                ]}
                onPress={() => setMinute(m)}
              >
                {m.toString().padStart(2, '0')}
              </Text>
            ))}
          </View>
        </View>

        <Text style={styles.hint}>
          睡眠データから自動推定された時刻を参考に{'\n'}
          設定することもできます
        </Text>
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
  iconContainer: {
    width: 80,
    height: 80,
    borderRadius: 20,
    backgroundColor: Colors.indigo[50],
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
  timeDisplay: {
    backgroundColor: Colors.indigo[50],
    borderRadius: 20,
    paddingVertical: Spacing.lg,
    paddingHorizontal: Spacing.xxxl,
    marginBottom: Spacing.xxl,
  },
  timeText: {
    ...Typography.scoreNumber,
    color: Colors.indigo[600],
  },
  pickerContainer: {
    flexDirection: 'row',
    gap: Spacing.huge,
    marginBottom: Spacing.xxl,
  },
  pickerColumn: {
    alignItems: 'center',
  },
  pickerLabel: {
    ...Typography.caption,
    color: Colors.slate[400],
    marginBottom: Spacing.md,
  },
  pickerItem: {
    ...Typography.h4,
    color: Colors.slate[400],
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.lg,
  },
  pickerItemSelected: {
    color: Colors.indigo[600],
    fontWeight: '700',
  },
  hint: {
    ...Typography.caption,
    color: Colors.slate[400],
    textAlign: 'center',
    lineHeight: 18,
  },
  footer: {
    paddingHorizontal: Spacing.xxl,
    paddingBottom: Spacing.xxxl,
  },
});
