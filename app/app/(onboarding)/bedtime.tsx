/**
 * BedtimeScreen - 就寝時刻設定画面
 * sozai/new のスタイルを React Native で再現
 * Step 6 of 9
 */

import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
  ScrollView,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Colors, Spacing, BorderRadius, FontFamily } from "../../src/theme";
import { PrimaryButton } from "../../src/components";
import { useUserStore } from "../../src/stores";
import type { JSX } from "react";

const { width, height } = Dimensions.get("window");
const CURRENT_STEP = 6;
const TOTAL_STEPS = 9;

const HOURS = Array.from({ length: 6 }, (_, i) => 20 + i); // 20:00 - 01:00
const MINUTES = [0, 15, 30, 45];

const parseTime = (timeStr: string): { hour: number; minute: number } => {
  const [h, m] = timeStr.split(":").map(Number);
  const normalizedHour = h < 20 ? h + 24 : h;
  return { hour: normalizedHour, minute: m };
};

const BedtimeScreen = (): JSX.Element => {
  const router = useRouter();
  const setDraftTargetBedtime = useUserStore(
    (state) => state.setDraftTargetBedtime,
  );
  const draftBedtime = useUserStore(
    (state) => state.draftProfile.targetBedtime,
  );

  const initialTime = draftBedtime
    ? parseTime(draftBedtime)
    : { hour: 23, minute: 0 };
  const [hour, setHour] = useState(initialTime.hour);
  const [minute, setMinute] = useState(initialTime.minute);

  const formatTime = (h: number, m: number): string => {
    const displayHour = h >= 24 ? h - 24 : h;
    return `${displayHour.toString().padStart(2, "0")}:${m.toString().padStart(2, "0")}`;
  };

  const handleNext = (): void => {
    setDraftTargetBedtime(formatTime(hour, minute));
    router.push("/(onboarding)/lifestyle");
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
                idx < CURRENT_STEP
                  ? styles.progressActive
                  : styles.progressInactive,
              ]}
            />
          ))}
        </View>

        <ScrollView
          style={styles.scrollView}
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          {/* Content */}
          <View style={styles.content}>
            <Text style={styles.emoji}>🛏️</Text>
            <Text style={styles.title}>Restful Ritual</Text>
            <Text style={styles.description}>
              Set your ideal bedtime. This becomes the anchor for your circadian
              rhythm analysis.
            </Text>

            {/* Time Display */}
            <View style={styles.timeDisplay}>
              <Text style={styles.timeText}>{formatTime(hour, minute)}</Text>
            </View>

            {/* Time Picker */}
            <View style={styles.pickerContainer}>
              <View style={styles.pickerColumn}>
                <Text style={styles.pickerLabel}>HOUR</Text>
                <View style={styles.pickerOptions}>
                  {HOURS.map((h) => (
                    <TouchableOpacity
                      key={h}
                      style={[
                        styles.pickerItem,
                        hour === h && styles.pickerItemSelected,
                      ]}
                      onPress={() => setHour(h)}
                    >
                      <Text
                        style={[
                          styles.pickerItemText,
                          hour === h && styles.pickerItemTextSelected,
                        ]}
                      >
                        {h >= 24 ? h - 24 : h}
                      </Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </View>

              <View style={styles.pickerColumn}>
                <Text style={styles.pickerLabel}>MINUTE</Text>
                <View style={styles.pickerOptions}>
                  {MINUTES.map((m) => (
                    <TouchableOpacity
                      key={m}
                      style={[
                        styles.pickerItem,
                        minute === m && styles.pickerItemSelected,
                      ]}
                      onPress={() => setMinute(m)}
                    >
                      <Text
                        style={[
                          styles.pickerItemText,
                          minute === m && styles.pickerItemTextSelected,
                        ]}
                      >
                        {m.toString().padStart(2, "0")}
                      </Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </View>
            </View>

            <Text style={styles.hint}>
              We can also infer this from your sleep data over time.
            </Text>
          </View>
        </ScrollView>

        {/* Footer */}
        <View style={styles.footer}>
          <PrimaryButton onPress={handleNext}>Continue</PrimaryButton>
        </View>
      </SafeAreaView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.stone[50],
    overflow: "hidden",
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
    position: "absolute",
    top: -height * 0.15,
    right: -width * 0.2,
    width: 256,
    height: 256,
    backgroundColor: Colors.indigo[100],
    borderRadius: 128,
    opacity: 0.4,
  },
  blobBottomLeft: {
    position: "absolute",
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
    flexDirection: "row",
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
    alignItems: "center",
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
    fontWeight: "700",
    color: Colors.stone[900],
    textAlign: "center",
    letterSpacing: -0.5,
    marginBottom: 12,
  },
  description: {
    fontFamily: FontFamily.regular,
    fontSize: 16,
    color: Colors.stone[500],
    textAlign: "center",
    lineHeight: 26,
    marginBottom: 32,
  },
  // Time Display
  timeDisplay: {
    backgroundColor: Colors.indigo[50],
    borderRadius: BorderRadius.xl,
    paddingVertical: Spacing.lg,
    paddingHorizontal: Spacing.xxl,
    marginBottom: 32,
    borderWidth: 2,
    borderColor: Colors.indigo[500],
  },
  timeText: {
    fontFamily: FontFamily.bold,
    fontSize: 48,
    fontWeight: "700",
    color: Colors.indigo[600],
    letterSpacing: 2,
  },
  // Picker
  pickerContainer: {
    flexDirection: "row",
    gap: 48,
    marginBottom: 24,
  },
  pickerColumn: {
    alignItems: "center",
  },
  pickerLabel: {
    fontFamily: FontFamily.medium,
    fontSize: 10,
    fontWeight: "500",
    color: Colors.stone[400],
    letterSpacing: 1.5,
    marginBottom: 12,
  },
  pickerOptions: {
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "center",
    gap: 8,
    maxWidth: 140,
  },
  pickerItem: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: Colors.white,
    justifyContent: "center",
    alignItems: "center",
    borderWidth: 1,
    borderColor: Colors.stone[200],
  },
  pickerItemSelected: {
    backgroundColor: Colors.indigo[500],
    borderColor: Colors.indigo[500],
  },
  pickerItemText: {
    fontFamily: FontFamily.semibold,
    fontSize: 16,
    fontWeight: "600",
    color: Colors.stone[600],
  },
  pickerItemTextSelected: {
    color: Colors.white,
  },
  hint: {
    fontFamily: FontFamily.regular,
    fontSize: 12,
    color: Colors.stone[400],
    textAlign: "center",
  },
  // Footer
  footer: {
    paddingHorizontal: 32,
    paddingBottom: 48,
    alignItems: "center",
  },
});

export default BedtimeScreen;
