/**
 * RhythmScreen - サーカディアンリズム可視化
 * sozai/tempoai-circadian-sync/ を React Native で完全再現
 */

import React, { useMemo } from "react";
import { View, Text, ScrollView, Pressable, StyleSheet } from "react-native";
import {
  SafeAreaView,
  useSafeAreaInsets,
} from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import {
  Calendar,
  Sun,
  Moon,
  Sunrise,
  Sunset,
  Cloud,
  Gauge,
  Droplets,
  CircleDot,
} from "lucide-react-native";
import Animated, { FadeInDown } from "react-native-reanimated";

import { TAB_BAR_HEIGHT } from "./_layout";
import {
  RhythmInteractiveChart,
  type RhythmDataPoint,
} from "../../src/components";
import { colors, FontFamily } from "../../src/theme";
import { t } from "../../src/i18n";
import { getEnvironmentData } from "../../src/constants/mockData";
import { getPressureTrendIcon } from "../../src/domain/models/weather";

// モックデータ: 24時間分のエネルギーレベル (sozai版と同じデータ形式)
const RHYTHM_DATA: RhythmDataPoint[] = [
  { time: "6 AM", hour: 6, energy: 30 },
  { time: "7 AM", hour: 7, energy: 45 },
  { time: "8 AM", hour: 8, energy: 65 },
  { time: "9 AM", hour: 9, energy: 80 },
  { time: "10 AM", hour: 10, energy: 90, label: "Peak" },
  { time: "11 AM", hour: 11, energy: 92 },
  { time: "12 PM", hour: 12, energy: 85 },
  { time: "1 PM", hour: 13, energy: 70 },
  { time: "2 PM", hour: 14, energy: 55 },
  { time: "3 PM", hour: 15, energy: 50, label: "Dip" },
  { time: "4 PM", hour: 16, energy: 60 },
  { time: "5 PM", hour: 17, energy: 75 },
  { time: "6 PM", hour: 18, energy: 85 },
  { time: "7 PM", hour: 19, energy: 80 },
  { time: "8 PM", hour: 20, energy: 60 },
  { time: "9 PM", hour: 21, energy: 40 },
  { time: "10 PM", hour: 22, energy: 25 },
  { time: "11 PM", hour: 23, energy: 15 },
  { time: "12 AM", hour: 24, energy: 10 },
];

// 日付フォーマット（英語）
const formatDate = (date: Date): string => {
  const days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  const day = days[date.getDay()];
  const month = months[date.getMonth()];
  const dateNum = date.getDate();
  return `${day}, ${month} ${dateNum}`;
};

const RhythmScreen = (): React.ReactElement => {
  const router = useRouter();
  const insets = useSafeAreaInsets();

  // 現在時刻を取得
  const now = useMemo(() => new Date(), []);
  const currentHour = now.getHours() + now.getMinutes() / 60;
  const dateString = formatDate(now);

  // 環境データを取得
  const envData = useMemo(() => getEnvironmentData(), []);

  const handleSeeDetails = () => {
    router.push("/rhythm-detail");
  };

  return (
    <View className="flex-1 bg-stone-50">
      <SafeAreaView className="flex-1" edges={["top"]}>
        <ScrollView
          contentContainerStyle={{
            paddingBottom: TAB_BAR_HEIGHT + insets.bottom + 24,
          }}
          showsVerticalScrollIndicator={false}
        >
          {/* ヘッダー */}
          <Animated.View
            entering={FadeInDown.duration(400)}
            className="px-6 pt-12 pb-2"
          >
            {/* 日付 */}
            <View
              className="flex-row items-center mb-1"
              style={styles.dateContainer}
            >
              <Calendar size={16} color={colors.stone[400]} />
              <Text
                className="text-xs font-medium text-stone-400 uppercase"
                style={styles.dateText}
              >
                {dateString}
              </Text>
            </View>
            {/* タイトル */}
            <Text
              className="text-3xl font-bold text-stone-900 tracking-tight"
              style={styles.titleText}
            >
              {t("screen.rhythm.title")}
            </Text>
            {/* サブタイトル */}
            <Text className="text-base text-stone-500 mt-1 leading-relaxed">
              {t("screen.rhythm.subtitle")}
            </Text>
          </Animated.View>

          {/* リズムチャート */}
          <Animated.View
            entering={FadeInDown.delay(100).duration(400)}
            className="mt-4"
          >
            <RhythmInteractiveChart
              data={RHYTHM_DATA}
              currentHour={currentHour}
              height={280}
            />
          </Animated.View>

          {/* Upcoming Windows セクション */}
          <View className="px-6 mt-8">
            {/* セクションヘッダー */}
            <Animated.View
              entering={FadeInDown.delay(200).duration(400)}
              className="flex-row items-center justify-between mb-4"
            >
              <Text
                className="text-xs font-bold text-stone-400 uppercase"
                style={styles.sectionTitle}
              >
                {t("screen.rhythm.upcomingWindows")}
              </Text>
              <Pressable onPress={handleSeeDetails}>
                <Text className="text-xs font-semibold text-indigo-600">
                  {t("screen.rhythm.seeDetails")}
                </Text>
              </Pressable>
            </Animated.View>

            {/* WindowCards - larger cards with colored borders */}
            <View style={styles.windowCardsContainer}>
              {/* Peak Energy Card - Active with amber border */}
              <View
                className="bg-white rounded-2xl"
                style={styles.peakEnergyCard}
              >
                <View
                  className="flex-row items-center"
                  style={styles.windowCardContent}
                >
                  <View className="p-4 rounded-xl" style={styles.peakIconBg}>
                    <Sun size={28} color={colors.amber[600]} />
                  </View>
                  <View style={styles.windowIconContainer}>
                    <View className="flex-row justify-between items-center mb-2">
                      <Text className="text-lg font-bold text-stone-900">
                        {t("screen.rhythm.phases.peakEnergy.title")}
                      </Text>
                      <Text
                        className="text-xs text-stone-500 font-medium"
                        style={styles.timeText}
                      >
                        {t("screen.rhythm.phases.peakEnergy.time")}
                      </Text>
                    </View>
                    <Text className="text-sm text-stone-600 leading-relaxed">
                      {t("screen.rhythm.phases.peakEnergy.description")}
                    </Text>
                  </View>
                </View>
              </View>

              {/* Melatonin Window Card - with indigo border */}
              <View
                className="bg-white rounded-2xl"
                style={styles.melatoninCard}
              >
                <View
                  className="flex-row items-center"
                  style={styles.windowCardContent}
                >
                  <View
                    className="p-4 rounded-xl"
                    style={styles.melatoninIconBg}
                  >
                    <Moon size={28} color={colors.indigo[600]} />
                  </View>
                  <View style={styles.windowIconContainer}>
                    <View className="flex-row justify-between items-center mb-2">
                      <Text className="text-lg font-bold text-stone-900">
                        {t("screen.rhythm.phases.melatoninWindow.title")}
                      </Text>
                      <Text
                        className="text-xs text-stone-500 font-medium"
                        style={styles.timeText}
                      >
                        {t("screen.rhythm.phases.melatoninWindow.time")}
                      </Text>
                    </View>
                    <Text className="text-sm text-stone-600 leading-relaxed">
                      {t("screen.rhythm.phases.melatoninWindow.description")}
                    </Text>
                  </View>
                </View>
              </View>
            </View>
          </View>

          {/* Environmental Data セクション */}
          <View className="px-6 mt-8">
            {/* セクションヘッダー */}
            <Animated.View
              entering={FadeInDown.delay(350).duration(400)}
              className="mb-4"
            >
              <Text
                className="text-xs font-bold text-stone-400 uppercase"
                style={styles.sectionTitle}
              >
                {t("screen.rhythm.environmentalData")}
              </Text>
            </Animated.View>

            {/* Row 1: Sunrise & Sunset */}
            <View className="flex-row" style={styles.envRow}>
              {/* Sunrise Card */}
              <View
                className="flex-1 bg-white rounded-2xl"
                style={styles.envCard}
              >
                <View className="flex-row items-center justify-between">
                  <View>
                    <Text className="text-xs font-semibold text-stone-500 mb-1">
                      {t("screen.rhythm.sunrise")}
                    </Text>
                    <Text className="text-xl font-bold text-stone-900">
                      {envData.sunrise}
                    </Text>
                  </View>
                  <View className="p-3 rounded-xl" style={styles.sunriseIconBg}>
                    <Sunrise size={24} color={colors.amber[500]} />
                  </View>
                </View>
              </View>

              {/* Sunset Card */}
              <View
                className="flex-1 bg-white rounded-2xl"
                style={styles.envCard}
              >
                <View className="flex-row items-center justify-between">
                  <View>
                    <Text className="text-xs font-semibold text-stone-500 mb-1">
                      {t("screen.rhythm.sunset")}
                    </Text>
                    <Text className="text-xl font-bold text-stone-900">
                      {envData.sunset}
                    </Text>
                  </View>
                  <View className="p-3 rounded-xl" style={styles.sunsetIconBg}>
                    <Sunset size={24} color={colors.rose[500]} />
                  </View>
                </View>
              </View>
            </View>

            {/* Row 2: Weather & Pressure */}
            <View className="flex-row mt-3" style={styles.envRow}>
              {/* Weather Card */}
              <View
                className="flex-1 bg-white rounded-2xl"
                style={styles.envCard}
              >
                <View className="flex-row items-center justify-between">
                  <View>
                    <Text className="text-xs font-semibold text-stone-500 mb-1">
                      {t("screen.rhythm.environment.weather")}
                    </Text>
                    <Text className="text-xl font-bold text-stone-900">
                      {envData.weather.condition}
                    </Text>
                    <Text className="text-xs text-stone-400">
                      {envData.weather.temperature}°C
                    </Text>
                  </View>
                  <View className="p-3 rounded-xl" style={styles.weatherIconBg}>
                    <Cloud size={24} color={colors.blue[500]} />
                  </View>
                </View>
              </View>

              {/* Pressure Card */}
              <View
                className="flex-1 bg-white rounded-2xl"
                style={styles.envCard}
              >
                <View className="flex-row items-center justify-between">
                  <View>
                    <Text className="text-xs font-semibold text-stone-500 mb-1">
                      {t("screen.rhythm.environment.pressure")}
                    </Text>
                    <Text className="text-xl font-bold text-stone-900">
                      {envData.pressure.value}
                      <Text className="text-sm font-normal text-stone-400">
                        {" "}
                        hPa
                      </Text>
                    </Text>
                    <Text className="text-xs text-stone-400">
                      {getPressureTrendIcon(envData.pressure.trend)}{" "}
                      {t(
                        `screen.rhythm.environment.pressureTrend.${envData.pressure.trend}`,
                      )}
                    </Text>
                  </View>
                  <View
                    className="p-3 rounded-xl"
                    style={styles.pressureIconBg}
                  >
                    <Gauge size={24} color={colors.emerald[500]} />
                  </View>
                </View>
              </View>
            </View>

            {/* Row 3: UV & Moon Phase */}
            <View className="flex-row mt-3" style={styles.envRow}>
              {/* UV Card */}
              <View
                className="flex-1 bg-white rounded-2xl"
                style={styles.envCard}
              >
                <View className="flex-row items-center justify-between">
                  <View>
                    <Text className="text-xs font-semibold text-stone-500 mb-1">
                      {t("screen.rhythm.environment.uv")}
                    </Text>
                    <Text className="text-xl font-bold text-stone-900">
                      {envData.uv.index}
                    </Text>
                    <Text className="text-xs text-stone-400">
                      {envData.uv.level}
                    </Text>
                  </View>
                  <View className="p-3 rounded-xl" style={styles.uvIconBg}>
                    <Droplets size={24} color={colors.amber[500]} />
                  </View>
                </View>
              </View>

              {/* Moon Phase Card */}
              <View
                className="flex-1 bg-white rounded-2xl"
                style={styles.envCard}
              >
                <View className="flex-row items-center justify-between">
                  <View>
                    <Text className="text-xs font-semibold text-stone-500 mb-1">
                      {t("screen.rhythm.environment.moonPhase")}
                    </Text>
                    <Text className="text-xl font-bold text-stone-900">
                      {envData.moonPhase.phase}
                    </Text>
                    <Text className="text-xs text-stone-400">
                      {envData.moonPhase.illumination}%
                    </Text>
                  </View>
                  <View className="p-3 rounded-xl" style={styles.moonIconBg}>
                    <CircleDot size={24} color={colors.purple[500]} />
                  </View>
                </View>
              </View>
            </View>
          </View>
        </ScrollView>
      </SafeAreaView>
    </View>
  );
};

const styles = StyleSheet.create({
  dateContainer: {
    gap: 8,
  },
  dateText: {
    letterSpacing: 1.5,
  },
  titleText: {
    fontFamily: FontFamily.serif,
  },
  timeText: {
    fontFamily: "monospace",
  },
  sectionTitle: {
    letterSpacing: 1.5,
  },
  windowCardsContainer: {
    gap: 16,
  },
  peakEnergyCard: {
    padding: 20,
    borderWidth: 2,
    borderColor: colors.amber[400],
    shadowColor: colors.amber[500],
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    elevation: 6,
  },
  melatoninCard: {
    padding: 20,
    borderWidth: 2,
    borderColor: colors.indigo[400],
    shadowColor: colors.indigo[500],
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    elevation: 6,
  },
  windowCardContent: {
    gap: 16,
  },
  windowIconContainer: {
    flex: 1,
  },
  peakIconBg: {
    backgroundColor: colors.amber[100],
  },
  melatoninIconBg: {
    backgroundColor: colors.indigo[100],
  },
  envRow: {
    gap: 12,
  },
  envCard: {
    padding: 16,
    borderWidth: 1,
    borderColor: colors.stone[100],
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 10,
    elevation: 4,
  },
  sunriseIconBg: {
    backgroundColor: colors.amber[100],
  },
  sunsetIconBg: {
    backgroundColor: colors.rose[100],
  },
  weatherIconBg: {
    backgroundColor: colors.blue[50],
  },
  pressureIconBg: {
    backgroundColor: colors.emerald[100],
  },
  uvIconBg: {
    backgroundColor: colors.amber[50],
  },
  moonIconBg: {
    backgroundColor: colors.purple[50],
  },
});

export default RhythmScreen;
