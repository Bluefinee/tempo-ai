/**
 * SleepDetailScreen - Sleep詳細画面
 */

import React, { useState } from 'react';
import { View, Text, ScrollView, Pressable } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { ChevronLeft, Moon, Sun, Sparkles } from 'lucide-react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';

import {
  DualRingProgress,
  TimeframeSelector,
  MiniBarChart,
  SleepStagesBar,
  type Timeframe,
} from '../../src/components';
import { colors, FontFamily } from '../../src/theme';
import { t } from '../../src/i18n';
import { MOCK_DETAIL } from '../../src/constants/mockData';
import { useHealthStore } from '../../src/stores/healthStore';

// スコアに応じたステータスを取得
const getSleepStatus = (score: number): string => {
  if (score >= 85) return t('score.sleep.status.excellent');
  if (score >= 70) return t('score.sleep.status.good');
  if (score >= 50) return t('score.sleep.status.fair');
  return t('score.sleep.status.poor');
};

export default function SleepDetailScreen(): React.ReactElement {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [timeframe, setTimeframe] = useState<Timeframe>('7D');
  const { dailySnapshot } = useHealthStore();
  
  // healthStoreから計算済みのスコアを取得
  const sleepScore = dailySnapshot?.scores?.sleep ?? 0;
  
  const data = MOCK_DETAIL.sleep;

  const handleBack = () => {
    router.back();
  };

  return (
    <View className="flex-1 bg-stone-100">
      <SafeAreaView className="flex-1" edges={['top']}>
        {/* Header */}
        <View className="flex-row items-center px-6 py-4 border-b border-stone-100 bg-stone-100">
          <Pressable
            onPress={handleBack}
            className="w-10 h-10 items-center justify-center rounded-full"
            style={({ pressed }) => [
              { backgroundColor: pressed ? colors.stone[100] : 'transparent' },
            ]}
          >
            <ChevronLeft size={24} color={colors.stone[600]} />
          </Pressable>
          <Text className="text-lg font-bold text-stone-900 ml-4">{t('score.sleep.label')}</Text>
        </View>

        <ScrollView
          contentContainerStyle={{
            paddingBottom: insets.bottom + 32,
          }}
          showsVerticalScrollIndicator={false}
        >
          <View className="px-6 py-6" style={{ gap: 32 }}>
            {/* Main Dual Ring Display */}
            <Animated.View
              entering={FadeInDown.duration(400)}
              className="items-center"
              style={{ gap: 24 }}
            >
              <View className="relative w-64 h-64 items-center justify-center">
                <DualRingProgress
                  size={256}
                  strokeWidth={12}
                  innerProgress={data.quality.percentage}
                  outerProgress={data.duration.percentage}
                  innerColor={colors.indigo[400]}
                  outerColor={colors.indigo[600]}
                  backgroundColor={colors.indigo[100]}
                />
                <View className="absolute items-center">
                  <Moon size={24} color={colors.indigo[500]} style={{ marginBottom: 4 }} />
                  <Text
                    className="text-3xl font-bold text-stone-900"
                    style={{ fontFamily: FontFamily.serif }}
                  >
                    {Math.round(sleepScore)}%
                  </Text>
                  <Text className="text-[10px] font-bold text-indigo-500 uppercase tracking-widest">
                    {getSleepStatus(sleepScore)}
                  </Text>
                </View>
              </View>

              <View className="flex-row items-center w-full justify-center" style={{ gap: 32 }}>
                <View className="items-center">
                  <Text className="text-xs font-bold text-indigo-500 uppercase mb-1">
                    {t('detail.sleep.duration')}
                  </Text>
                  <Text className="text-xl font-bold text-stone-900">
                    {data.duration.hours}h {data.duration.minutes}m
                  </Text>
                </View>
                <View className="w-px h-8 bg-stone-200" />
                <View className="items-center">
                  <View className="flex-row items-center mb-1" style={{ gap: 4 }}>
                    <Text className="text-xs font-bold text-indigo-400 uppercase">{t('detail.sleep.quality')}</Text>
                    <Sparkles size={10} color={colors.indigo[400]} />
                  </View>
                  <Text className="text-xl font-bold text-stone-900">
                    {data.quality.percentage}%
                  </Text>
                </View>
              </View>
            </Animated.View>

            {/* AI Explanation */}
            <Animated.View
              entering={FadeInDown.delay(100).duration(400)}
              className="bg-indigo-50 p-5 rounded-3xl border border-indigo-100"
            >
              <Text className="text-sm text-stone-700 leading-relaxed">
                {data.analysis}
              </Text>
            </Animated.View>

            {/* Sleep Stages Breakdown */}
            <Animated.View
              entering={FadeInDown.delay(200).duration(400)}
              style={{ gap: 16 }}
            >
              <Text className="text-xs font-bold text-stone-400 uppercase tracking-widest">
                {t('detail.sleep.sleepStages')}
              </Text>
              <View
                className="bg-white p-5 rounded-3xl border border-stone-100"
                style={{
                  shadowColor: '#000',
                  shadowOffset: { width: 0, height: 4 },
                  shadowOpacity: 0.06,
                  shadowRadius: 10,
                  elevation: 4,
                }}
              >
                <SleepStagesBar stages={data.stages} />
              </View>
            </Animated.View>

            {/* Timing Details */}
            <Animated.View
              entering={FadeInDown.delay(300).duration(400)}
              className="flex-row"
              style={{ gap: 16 }}
            >
              <View
                className="flex-1 bg-white p-4 rounded-2xl border border-stone-100"
                style={{
                  shadowColor: '#000',
                  shadowOffset: { width: 0, height: 4 },
                  shadowOpacity: 0.06,
                  shadowRadius: 10,
                  elevation: 4,
                }}
              >
                <View className="flex-row items-center mb-2" style={{ gap: 8 }}>
                  <Moon size={16} color={colors.indigo[500]} />
                  <Text className="text-xs font-bold text-stone-400 uppercase">{t('detail.sleep.bedtime')}</Text>
                </View>
                <Text className="text-xl font-bold text-stone-900">
                  {data.timing.bedtime.actual}
                </Text>
                <Text className="text-[10px] text-amber-500 font-medium mt-1">
                  {t('detail.sleep.target')}: {data.timing.bedtime.target} ({data.timing.bedtime.diff})
                </Text>
              </View>

              <View
                className="flex-1 bg-white p-4 rounded-2xl border border-stone-100"
                style={{
                  shadowColor: '#000',
                  shadowOffset: { width: 0, height: 4 },
                  shadowOpacity: 0.06,
                  shadowRadius: 10,
                  elevation: 4,
                }}
              >
                <View className="flex-row items-center mb-2" style={{ gap: 8 }}>
                  <Sun size={16} color={colors.amber[500]} />
                  <Text className="text-xs font-bold text-stone-400 uppercase">{t('detail.sleep.wakeTime')}</Text>
                </View>
                <Text className="text-xl font-bold text-stone-900">
                  {data.timing.wakeTime.actual}
                </Text>
                <Text className="text-[10px] text-emerald-500 font-medium mt-1">
                  {t('detail.sleep.target')}: {data.timing.wakeTime.target} ({data.timing.wakeTime.diff})
                </Text>
              </View>
            </Animated.View>

            {/* History Chart */}
            <Animated.View
              entering={FadeInDown.delay(400).duration(400)}
              style={{ gap: 16 }}
            >
              <TimeframeSelector selected={timeframe} onSelect={setTimeframe} />

              <View
                className="bg-white p-5 rounded-3xl border border-stone-100"
                style={{
                  shadowColor: '#000',
                  shadowOffset: { width: 0, height: 4 },
                  shadowOpacity: 0.06,
                  shadowRadius: 10,
                  elevation: 4,
                }}
              >
                <Text className="text-xs font-bold text-stone-400 uppercase mb-4">
                  {t('detail.sleep.history')}
                </Text>
                <MiniBarChart
                  data={data.history[timeframe]}
                  color={colors.indigo[500]}
                  height={120}
                  showLabels={timeframe === '7D'}
                  animated
                />
              </View>
            </Animated.View>
          </View>
        </ScrollView>
      </SafeAreaView>
    </View>
  );
}

