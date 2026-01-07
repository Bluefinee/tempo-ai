/**
 * TodayScreen - メインホーム画面
 * sozai/tempoai/screens/TodayScreen.tsx を React Native で完全再現
 */

import React, { useEffect } from "react";
import {
  View,
  Text,
  ScrollView,
  Pressable,
  ActivityIndicator,
} from "react-native";
import {
  SafeAreaView,
  useSafeAreaInsets,
} from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import {
  ChevronRight,
  Sparkles,
  ArrowRight,
  Heart,
  Activity,
  Wind,
  Droplets,
  Thermometer,
  Target,
  Footprints,
} from "lucide-react-native";
import Animated, { FadeInDown } from "react-native-reanimated";

import { TAB_BAR_HEIGHT } from "./_layout";
import { colors, FontFamily } from "../../src/theme";
import { t } from "../../src/i18n";
import { MOCK_TODAY, MOCK_SETTINGS } from "../../src/constants/mockData";
import { getGreeting, formatDate } from "../../src/utils/dateFormatters";
import { useHealthStore } from "../../src/stores/healthStore";
import { MetricGridCard, type MetricCard } from "../../src/components/today/MetricGridCard";
import { HealthSummaryCard, type HealthCard } from "../../src/components/today/HealthSummaryCard";

const getMetricCards = (scores?: { recovery: number; sleep: number; rhythm: number; energy: number }): MetricCard[] => [
  {
    id: "recovery",
    title: t("score.recovery.label"),
    value: scores ? `${Math.round(scores.recovery)}%` : "--",
    colorText: colors.emerald[600],
    colorAccent: colors.emerald[500],
    chartData: [40, 60, 55, 80, 70, 65, scores?.recovery ?? 0],
    route: "/recovery-detail",
  },
  {
    id: "sleep",
    title: t("score.sleep.label"),
    value: scores ? `${Math.round(scores.sleep)}%` : "--",
    colorText: colors.indigo[600],
    colorAccent: colors.indigo[500],
    chartData: [70, 80, 60, 90, 85, 80, scores?.sleep ?? 0],
    route: "/sleep-detail",
  },
  {
    id: "rhythm",
    title: t("score.rhythm.label"),
    value: scores ? `${Math.round(scores.rhythm)}%` : "--",
    colorText: colors.purple[600],
    colorAccent: colors.purple[500],
    chartData: [88, 90, 92, 91, 89, 94, scores?.rhythm ?? 0],
    route: "/rhythm-detail",
  },
  {
    id: "energy",
    title: t("score.energy.label"),
    value: scores ? `${Math.round(scores.energy)}%` : "--",
    colorText: colors.amber[600],
    colorAccent: colors.amber[500],
    chartData: [50, 60, 55, 70, 80, 75, scores?.energy ?? 0],
    route: "/energy-detail",
  },
];

// Health Summary カードのデータを取得（i18n対応）
const getHealthCards = () => [
  {
    id: "hrv",
    label: t("metric.health.hrv.shortName"),
    value: "82",
    unit: "ms",
    Icon: Activity,
    colorIcon: colors.emerald[500],
    lineColor: "#10B981",
    chartData: [65, 70, 68, 75, 72, 80, 82],
  },
  {
    id: "rhr",
    label: t("metric.health.rhr.shortName"),
    value: "59",
    unit: "bpm",
    Icon: Heart,
    colorIcon: colors.rose[500],
    lineColor: "#F43F5E",
    chartData: [60, 59, 61, 58, 59, 60, 59],
  },
  {
    id: "resp",
    label: t("metric.health.resp.shortName"),
    value: "11.0",
    unit: "brpm",
    Icon: Wind,
    colorIcon: colors.blue[500],
    lineColor: "#3B82F6",
    chartData: [12, 11.5, 11.2, 11.8, 11.0, 11.2, 11.0],
  },
  {
    id: "spo2",
    label: t("metric.health.spo2.shortName"),
    value: "98",
    unit: "%",
    Icon: Droplets,
    colorIcon: colors.teal[500],
    lineColor: "#14B8A6",
    chartData: [97, 98, 98, 99, 97, 98, 98],
  },
  {
    id: "temp",
    label: t("metric.health.temp.shortName"),
    value: "36.4",
    unit: "°C",
    Icon: Thermometer,
    colorIcon: colors.amber[500],
    lineColor: "#F59E0B",
    chartData: [36.5, 36.6, 36.4, 36.7, 36.5, 36.5, 36.4],
  },
];


export default function TodayScreen(): React.ReactElement {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { dailySnapshot, isLoading, initialize } = useHealthStore();
  
  // 初回レンダリング時に初期化（データ取得 + 計算）
  useEffect(() => {
    initialize();
  }, [initialize]);
  
  // healthStoreから計算済みのスコアを取得
  const scores = dailySnapshot?.scores;
  
  const healthCards = getHealthCards();
  const metricCards = getMetricCards(scores);

  const greeting = getGreeting(MOCK_SETTINGS.profile.name);
  const today = formatDate();
  
  // ローディング表示
  if (isLoading) {
    return (
      <View style={{ flex: 1, backgroundColor: colors.stone[50] }}>
        <SafeAreaView style={{ flex: 1 }}>
          <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
            <ActivityIndicator size="large" color={colors.stone[900]} />
            <Text style={{ color: colors.stone[600], marginTop: 16, fontSize: 14 }}>
              {t("common.loading")}
            </Text>
          </View>
        </SafeAreaView>
      </View>
    );
  }



  return (
    <View className="flex-1 bg-stone-50">
      <SafeAreaView className="flex-1" edges={["top"]}>
        <ScrollView
          contentContainerStyle={{
            paddingBottom: TAB_BAR_HEIGHT + insets.bottom + 24,
          }}
          showsVerticalScrollIndicator={false}
        >
          {/* Header */}
          <Animated.View
            entering={FadeInDown.duration(400)}
            className="pt-14 px-6 mb-6"
          >
            <Text
              className="text-2xl font-bold text-stone-900 tracking-tight"
              style={{ fontFamily: FontFamily.serif }}
            >
              {greeting}
            </Text>
            <Text
              className="text-sm font-medium text-stone-500 uppercase mt-1"
              style={{ letterSpacing: 1 }}
            >
              {today}
            </Text>
          </Animated.View>

          <View className="px-6" style={{ gap: 32 }}>
            {/* 2x2 Metric Grid */}
            <Animated.View
              entering={FadeInDown.delay(100).duration(400)}
              style={{ gap: 16 }}
            >
              <View className="flex-row" style={{ gap: 16 }}>
                <View style={{ flex: 1 }}>
                  <MetricGridCard metric={metricCards[0]} />
                </View>
                <View style={{ flex: 1 }}>
                  <MetricGridCard metric={metricCards[1]} />
                </View>
              </View>
              <View className="flex-row" style={{ gap: 16 }}>
                <View style={{ flex: 1 }}>
                  <MetricGridCard metric={metricCards[2]} />
                </View>
                <View style={{ flex: 1 }}>
                  <MetricGridCard metric={metricCards[3]} />
                </View>
              </View>
            </Animated.View>

            {/* AI Insight Section */}
            <Animated.View
              entering={FadeInDown.delay(200).duration(400)}
              style={{ gap: 12 }}
            >
              <View className="flex-row items-center px-1" style={{ gap: 8 }}>
                <Sparkles size={18} color={colors.indigo[500]} />
                <Text
                  className="text-sm font-bold text-stone-400 uppercase"
                  style={{ letterSpacing: 1.5 }}
                >
                  {t("screen.today.aiInsight")}
                </Text>
              </View>
              <Pressable
                onPress={() => router.push("/insight-detail")}
                className="bg-white p-5 rounded-3xl border border-stone-100 overflow-hidden"
                style={({ pressed }) => [
                  {
                    shadowColor: "#000",
                    shadowOffset: { width: 0, height: 4 },
                    shadowOpacity: 0.06,
                    shadowRadius: 8,
                    elevation: 3,
                  },
                  pressed && { transform: [{ scale: 0.98 }], opacity: 0.9 },
                ]}
              >
                {/* Left accent bar - 紫の縦線 (absolute positioning) */}
                <View
                  style={{
                    position: "absolute",
                    top: 0,
                    left: 0,
                    bottom: 0,
                    width: 4,
                    backgroundColor: colors.indigo[500],
                  }}
                />
                <Text className="text-lg font-bold text-stone-900 mb-2">
                  {MOCK_TODAY.aiMessage.title}
                </Text>
                <Text className="text-sm text-stone-600 leading-relaxed mb-4">
                  {MOCK_TODAY.aiMessage.body}
                </Text>
                <View className="flex-row items-center" style={{ gap: 4 }}>
                  <Text className="text-xs font-bold text-indigo-600">
                    {t("screen.today.viewAnalysis")}
                  </Text>
                  <ArrowRight size={14} color={colors.indigo[600]} />
                </View>
              </Pressable>
            </Animated.View>

            {/* Today's One Thing Section */}
            <Animated.View
              entering={FadeInDown.delay(300).duration(400)}
              style={{ gap: 12 }}
            >
              <View className="flex-row items-center px-1" style={{ gap: 8 }}>
                <Target size={18} color={colors.amber[500]} />
                <Text
                  className="text-sm font-bold text-stone-400 uppercase"
                  style={{ letterSpacing: 1.5 }}
                >
                  {t("screen.today.todayOneThing.title")}
                </Text>
              </View>
              <Pressable
                onPress={() => router.push("/action-detail")}
                className="bg-white p-6 rounded-3xl border border-stone-100 overflow-hidden flex-row items-center justify-between"
                style={({ pressed }) => [
                  {
                    minHeight: 100,
                    shadowColor: "#000",
                    shadowOffset: { width: 0, height: 4 },
                    shadowOpacity: 0.06,
                    shadowRadius: 8,
                    elevation: 3,
                  },
                  pressed && { transform: [{ scale: 0.98 }], opacity: 0.9 },
                ]}
              >
                {/* Left accent bar - オレンジの縦線 (absolute positioning) */}
                <View
                  style={{
                    position: "absolute",
                    top: 0,
                    left: 0,
                    bottom: 0,
                    width: 4,
                    backgroundColor: colors.amber[500],
                  }}
                />
                <View
                  className="flex-row items-center"
                  style={{ gap: 20, flex: 1 }}
                >
                  <View
                    className="p-4 rounded-2xl"
                    style={{ backgroundColor: colors.amber[50] }}
                  >
                    <Footprints size={28} color={colors.amber[600]} />
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text className="text-lg font-bold text-stone-900 mb-1">
                      {MOCK_TODAY.oneThing.action}
                    </Text>
                    <Text className="text-sm text-stone-500 font-medium">
                      {MOCK_TODAY.oneThing.summary}
                    </Text>
                  </View>
                </View>
                <View
                  className="p-2.5 rounded-full"
                  style={{ backgroundColor: colors.stone[50] }}
                >
                  <ChevronRight size={22} color={colors.stone[300]} />
                </View>
              </Pressable>
            </Animated.View>

            {/* Health Summary Section */}
            <Animated.View
              entering={FadeInDown.delay(400).duration(400)}
              style={{ gap: 12 }}
            >
              <View className="flex-row items-center justify-between px-1">
                <View className="flex-row items-center" style={{ gap: 8 }}>
                  <Activity size={18} color={colors.rose[500]} />
                  <Text
                    className="text-sm font-bold text-stone-400 uppercase"
                    style={{ letterSpacing: 1.5 }}
                  >
                    {t("screen.today.healthSummary")}
                  </Text>
                </View>
                <Pressable onPress={() => router.push("/health-detail")}>
                  <ChevronRight size={20} color={colors.stone[300]} />
                </Pressable>
              </View>
            </Animated.View>
          </View>

          {/* Health Summary Horizontal Scroll */}
          <Animated.View entering={FadeInDown.delay(450).duration(400)}>
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={{
                paddingHorizontal: 24,
                paddingTop: 8,
                paddingBottom: 32,
                gap: 16,
              }}
            >
              {healthCards.map((card) => (
                <HealthSummaryCard key={card.id} card={card} />
              ))}
            </ScrollView>
          </Animated.View>
        </ScrollView>
      </SafeAreaView>
    </View>
  );
}
