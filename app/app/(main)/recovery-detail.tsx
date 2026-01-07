/**
 * RecoveryDetailScreen - Recovery詳細画面
 */

import React, { useState } from 'react';
import { View, Text, ScrollView, Pressable } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { ChevronLeft, Activity } from 'lucide-react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';

import {
  CircularProgress,
  TimeframeSelector,
  MiniBarChart,
  type Timeframe,
} from '../../src/components';
import { colors, FontFamily } from '../../src/theme';
import { t } from '../../src/i18n';
import { MOCK_DETAIL } from "../../src/constants/mockData";
import { useHealthStore } from '../../src/stores/healthStore';

// スコアに応じたステータスを取得
const getRecoveryStatus = (score: number): string => {
  if (score >= 80) return t('score.recovery.status.excellent');
  if (score >= 60) return t('score.recovery.status.good');
  if (score >= 40) return t('score.recovery.status.fair');
  return t('score.recovery.status.needsRest');
};

const RecoveryDetailScreen = (): React.ReactElement => {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [timeframe, setTimeframe] = useState<Timeframe>('7D');
  const { dailySnapshot } = useHealthStore();
  
  // healthStoreから計算済みのスコアを取得
  const recoveryScore = dailySnapshot?.scores?.recovery ?? 0;
  
  const data = MOCK_DETAIL.recovery;

  const handleBack = () => {
    router.back();
  };

  const getChangeColor = (change: number) => {
    if (change > 0) return colors.emerald[600];
    if (change < 0) return colors.rose[500];
    return colors.stone[500];
  };

  const getChangeBgColor = (change: number) => {
    if (change > 0) return colors.emerald[50];
    if (change < 0) return colors.rose[50];
    return colors.stone[100];
  };

  const getChangeSymbol = (change: number) => {
    if (change > 0) return '↑';
    if (change < 0) return '↓';
    return '=';
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
          <Text className="text-lg font-bold text-stone-900 ml-4">{t('score.recovery.label')}</Text>
        </View>

        <ScrollView
          contentContainerStyle={{
            paddingBottom: insets.bottom + 32,
          }}
          showsVerticalScrollIndicator={false}
        >
          <View className="px-6 py-6" style={{ gap: 32 }}>
            {/* Main Circular Display */}
            <Animated.View
              entering={FadeInDown.duration(400)}
              className="items-center"
            >
              <View className="relative w-48 h-48 items-center justify-center">
                <CircularProgress
                  size={192}
                  strokeWidth={16}
                  progress={recoveryScore}
                  color={colors.emerald[500]}
                  backgroundColor={colors.stone[200]}
                />
                <View className="absolute items-center">
                  <Text className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-1">
                    {getRecoveryStatus(recoveryScore)}
                  </Text>
                  <Text
                    className="text-5xl font-bold text-stone-900"
                    style={{ fontFamily: FontFamily.serif }}
                  >
                    {Math.round(recoveryScore)}%
                  </Text>
                </View>
              </View>
            </Animated.View>

            {/* Key Metrics Row */}
            <Animated.View
              entering={FadeInDown.delay(100).duration(400)}
              className="flex-row"
              style={{ gap: 16 }}
            >
              <View
                className="flex-1 bg-white p-4 rounded-2xl border border-stone-100 items-center"
                style={{
                  shadowColor: '#000',
                  shadowOffset: { width: 0, height: 4 },
                  shadowOpacity: 0.06,
                  shadowRadius: 10,
                  elevation: 4,
                }}
              >
                <Text className="text-xs font-bold text-stone-400 uppercase">HRV</Text>
                <Text className="text-2xl font-bold text-stone-900 my-1">
                  {data.hrv.value}
                  {data.hrv.unit}
                </Text>
                <View
                  className="px-2 py-0.5 rounded-full"
                  style={{
                    backgroundColor: getChangeBgColor(data.hrv.change),
                  }}
                >
                  <Text
                    className="text-xs font-bold"
                    style={{ color: getChangeColor(data.hrv.change) }}
                  >
                    {getChangeSymbol(data.hrv.change)} {Math.abs(data.hrv.change)}% (
                    {data.hrv.baseline})
                  </Text>
                </View>
              </View>

              <View
                className="flex-1 bg-white p-4 rounded-2xl border border-stone-100 items-center"
                style={{
                  shadowColor: '#000',
                  shadowOffset: { width: 0, height: 4 },
                  shadowOpacity: 0.06,
                  shadowRadius: 10,
                  elevation: 4,
                }}
              >
                <Text className="text-xs font-bold text-stone-400 uppercase">RHR</Text>
                <Text className="text-2xl font-bold text-stone-900 my-1">
                  {data.rhr.value}
                  {data.rhr.unit}
                </Text>
                <View
                  className="px-2 py-0.5 rounded-full"
                  style={{
                    backgroundColor: getChangeBgColor(data.rhr.change),
                  }}
                >
                  <Text
                    className="text-xs font-bold"
                    style={{ color: getChangeColor(data.rhr.change) }}
                  >
                    {getChangeSymbol(data.rhr.change)} ({data.rhr.baseline})
                  </Text>
                </View>
              </View>
            </Animated.View>

            {/* AI Explanation Card */}
            <Animated.View
              entering={FadeInDown.delay(200).duration(400)}
              className="bg-emerald-50 p-5 rounded-3xl border border-emerald-100"
            >
              <View className="flex-row items-center mb-3" style={{ gap: 8 }}>
                <Activity size={18} color={colors.emerald[600]} />
                <Text className="text-sm font-bold text-stone-900">{t('detail.recovery.analysis')}</Text>
              </View>
              <Text className="text-sm text-stone-700 leading-relaxed">
                {data.analysis}
              </Text>
              <View className="mt-3 pt-3 border-t border-emerald-100">
                <Text className="text-[10px] font-mono text-emerald-700 uppercase opacity-60">
                  {t('detail.recovery.calculatedAt')}: {data.calculatedAt}
                </Text>
              </View>
            </Animated.View>

            {/* History Chart */}
            <Animated.View
              entering={FadeInDown.delay(300).duration(400)}
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
                  {t('detail.recovery.dailyRecovery')}
                </Text>
                <MiniBarChart
                  data={data.history[timeframe]}
                  color={colors.emerald[500]}
                  height={120}
                  showLabels={timeframe === '7D'}
                  animated
                />
                <View className="mt-4 pt-4 border-t border-stone-50 flex-row justify-between items-center">
                  <Text className="text-xs text-stone-400">{t('detail.recovery.weeklyAverage')}</Text>
                  <Text className="text-sm font-bold text-stone-900">
                    {data.weeklyAverage}%
                  </Text>
                </View>
              </View>
            </Animated.View>

            {/* Educational Cards */}
            <Animated.View
              entering={FadeInDown.delay(400).duration(400)}
              className="flex-row"
              style={{ gap: 16 }}
            >
              <Pressable
                className="flex-1 bg-stone-100 p-4 rounded-2xl justify-between"
                style={{ height: 96 }}
              >
                <Text className="text-xs font-bold text-stone-400">{t('detail.recovery.learn')}</Text>
                <Text className="text-sm font-bold text-stone-900 leading-tight">
                  {t('detail.recovery.learnWhat')}
                </Text>
              </Pressable>
              <Pressable
                className="flex-1 bg-stone-100 p-4 rounded-2xl justify-between"
                style={{ height: 96 }}
              >
                <Text className="text-xs font-bold text-stone-400">{t('detail.recovery.learn')}</Text>
                <Text className="text-sm font-bold text-stone-900 leading-tight">
                  {t('detail.recovery.learnBestPractices')}
                </Text>
              </Pressable>
            </Animated.View>
          </View>
        </ScrollView>
      </SafeAreaView>
    </View>
  );
}


export default RecoveryDetailScreen;
