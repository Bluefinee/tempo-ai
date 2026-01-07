/**
 * WelcomeScreen - オンボーディング開始画面
 * sozai/new/screens/OnboardingScreen.tsx のスタイルを React Native で再現
 * 9ステップのオンボーディングフローを維持
 */

import React from "react";
import { View, Text, StyleSheet, useWindowDimensions } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Colors, FontFamily } from "../../src/theme";
import { PrimaryButton } from "../../src/components";
import type { JSX } from "react";

const WelcomeScreen = (): JSX.Element => {
  const router = useRouter();
  const { width, height } = useWindowDimensions();

  const handleStart = () => {
    router.push("/(onboarding)/healthkit");
  };

  return (
    <View style={styles.container}>
      {/* Decorative background blobs matching sozai */}
      <View style={styles.blobTopRight} />
      <View style={styles.blobBottomLeft} />

      <SafeAreaView style={styles.safeArea}>
        {/* Progress Bar - Step 1 of 9 */}
        <View style={styles.progressContainer}>
          {[...Array(9)].map((_, idx) => (
            <View
              key={idx}
              style={[
                styles.progressSegment,
                idx === 0 ? styles.progressActive : styles.progressInactive,
              ]}
            />
          ))}
        </View>

        {/* Content */}
        <View style={styles.content}>
          <Text style={styles.emoji}>👋</Text>
          <Text style={styles.title}>Welcome to Tempo</Text>
          <Text style={styles.description}>
            A new way to understand your body&apos;s hidden rhythms without the
            overwhelm of numbers.
          </Text>
        </View>

        {/* Button */}
        <View style={styles.footer}>
          <PrimaryButton onPress={handleStart}>Continue</PrimaryButton>
        </View>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.stone[50],
    overflow: "hidden",
  },
  safeArea: {
    flex: 1,
  },
  // Decorative blobs
  blobTopRight: {
    position: "absolute",
    top: -100,
    right: -80,
    width: 256, // w-64
    height: 256, // h-64
    backgroundColor: Colors.amber[100],
    borderRadius: 128,
    // blur effect approximation
    opacity: 0.4,
  },
  blobBottomLeft: {
    position: "absolute",
    bottom: -80,
    left: -60,
    width: 320, // w-80
    height: 320, // h-80
    backgroundColor: Colors.indigo[100],
    borderRadius: 160,
    opacity: 0.4,
  },
  // Progress bar
  progressContainer: {
    flexDirection: "row",
    paddingHorizontal: 32, // px-8
    paddingTop: 48, // top-12
    gap: 8, // space-x-2
  },
  progressSegment: {
    flex: 1,
    height: 4, // h-1
    borderRadius: 2, // rounded-full
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
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 32,
    maxWidth: 320, // max-w-xs
    alignSelf: "center",
  },
  emoji: {
    fontSize: 60, // text-6xl
    marginBottom: 32, // mb-8
  },
  title: {
    fontFamily: FontFamily.serif,
    fontSize: 24, // text-2xl
    fontWeight: "700", // font-bold
    color: Colors.stone[900],
    textAlign: "center",
    letterSpacing: -0.5, // tracking-tight
    marginBottom: 16, // mb-4
  },
  description: {
    fontFamily: FontFamily.regular,
    fontSize: 16,
    color: Colors.stone[500],
    textAlign: "center",
    lineHeight: 26, // leading-relaxed
  },
  // Footer
  footer: {
    paddingHorizontal: 32,
    paddingBottom: 48, // bottom-12
    alignItems: "center",
  },
});

export default WelcomeScreen;
