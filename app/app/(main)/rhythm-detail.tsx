/**
 * RhythmDetailScreen - Rhythm詳細画面
 * Bedtime/Wake Consistency、Weekly Patternを含む
 */

import React from 'react';
import { View, Text, ScrollView, Pressable } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { ChevronLeft, Clock, Moon, Sun, Calendar, Plane } from 'lucide-react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';
import Svg, { Rect, Line } from 'react-native-svg';

import { CircularProgress } from '../../src/components';
import { colors, FontFamily } from '../../src/theme';
import { t } from '../../src/i18n';
import { MOCK_DETAIL } from '../../src/constants/mockData';
import { useHealthStore } from '../../src/stores/healthStore';

// スコアに応じたステータスを取得
const getRhythmStatus = (score: number): string => {
  if (score >= 90) return t('score.rhythm.status.excellent');
  if (score >= 75) return t('score.rhythm.status.good');
  if (score >= 50) return t('score.rhythm.status.fair');
  return t('score.rhythm.status.poor');
};

// Contributing Factor カードコンポーネント（詳細版）
interface FactorCardProps {
  icon: React.ElementType;
  iconColor: string;
  iconBg: string;
  label: string;
  value: number;
  trend: string;
  trendDirection: 'up' | 'down' | 'stable';
  detail: string;
}

const FactorCard = ({
  icon: Icon,
  iconColor,
  iconBg,
  label,
  value,
  trend,
  trendDirection,
  detail,
}: FactorCardProps): React.ReactElement => {
  const getTrendColor = () => {
    if (trendDirection === 'up') return colors.emerald[500];
    if (trendDirection === 'down') return colors.rose[500];
    return colors.stone[400];
  };

  return (
    <View
      className="bg-white p-4 rounded-2xl border border-stone-100"
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.04,
        shadowRadius: 6,
        elevation: 2,
      }}
    >
      <View className="flex-row items-center justify-between mb-2">
        <View className="flex-row items-center" style={{ gap: 10 }}>
          <View className="p-2 rounded-xl" style={{ backgroundColor: iconBg }}>
            <Icon size={16} color={iconColor} />
          </View>
          <Text className="text-xs font-bold text-stone-500 uppercase">{label}</Text>
        </View>
        <Text className="text-xs font-bold" style={{ color: getTrendColor() }}>
          {trend}
        </Text>
      </View>
      <Text className="text-2xl font-bold text-stone-900 mb-1">{value}%</Text>
      <Text className="text-[10px] text-stone-400">{detail}</Text>
    </View>
  );
};

export default function RhythmDetailScreen(): React.ReactElement {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { dailySnapshot } = useHealthStore();
  
  // healthStoreから計算済みのスコアを取得
  const rhythmScore = dailySnapshot?.scores?.rhythm ?? 0;
  
  const data = MOCK_DETAIL.rhythm;

  const handleBack = () => {
    router.back();
  };

  // Weekly Pattern バーチャートをレンダリング
  const renderWeeklyPattern = () => {
    const pattern = data.weeklyPattern;
    const maxOffset = Math.max(...pattern.map((p) => Math.abs(p.offset)));
    const chartHeight = 120;
    const centerY = chartHeight / 2;
    const barWidth = 12;
    const gap = 8;
    const totalWidth = pattern.length * (barWidth + gap) - gap;
    const startX = (300 - totalWidth) / 2;

    return (
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
          {t('detail.rhythm.weeklyPattern')}
        </Text>
        <View style={{ height: chartHeight, position: 'relative' }}>
          <Svg width="100%" height={chartHeight} viewBox={`0 0 300 ${chartHeight}`}>
            {/* Center line (target bedtime) */}
            <Line
              x1="0"
              y1={centerY}
              x2="300"
              y2={centerY}
              stroke={colors.stone[200]}
              strokeWidth={1}
              strokeDasharray="4,4"
            />
            {/* Bars */}
            {pattern.map((item, index) => {
              const x = startX + index * (barWidth + gap);
              const barHeight = maxOffset > 0 ? (Math.abs(item.offset) / maxOffset) * 40 : 0;
              const y = item.offset >= 0 ? centerY - barHeight : centerY;

              return (
                <Rect
                  key={item.day}
                  x={x}
                  y={y}
                  width={barWidth}
                  height={Math.max(barHeight, 4)}
                  rx={4}
                  fill={colors.purple[500]}
                  opacity={index === pattern.length - 1 ? 1 : 0.5}
                />
              );
            })}
          </Svg>
          {/* Day labels */}
          <View
            style={{
              position: 'absolute',
              bottom: 0,
              left: 0,
              right: 0,
              flexDirection: 'row',
              justifyContent: 'space-around',
              paddingHorizontal: 20,
            }}
          >
            {pattern.map((item, index) => (
              <Text
                key={item.day}
                style={{
                  fontSize: 10,
                  fontWeight: '500',
                  color: index === pattern.length - 1 ? colors.purple[600] : colors.stone[400],
                  width: barWidth + gap,
                  textAlign: 'center',
                }}
              >
                {item.day}
              </Text>
            ))}
          </View>
        </View>
        <View className="mt-3 pt-3 border-t border-stone-50 flex-row justify-between items-center">
          <Text className="text-xs text-stone-400">目標からのズレ</Text>
          <Text className="text-xs text-stone-500">上: 早い / 下: 遅い</Text>
        </View>
      </View>
    );
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
          <Text className="text-lg font-bold text-stone-900 ml-4">{t('score.rhythm.label')}</Text>
        </View>

        <ScrollView
          contentContainerStyle={{
            paddingBottom: insets.bottom + 32,
          }}
          showsVerticalScrollIndicator={false}
        >
          <View className="px-6 py-6" style={{ gap: 24 }}>
            {/* Main Circular Display */}
            <Animated.View entering={FadeInDown.duration(400)} className="items-center">
              <View className="relative w-48 h-48 items-center justify-center mb-4">
                <CircularProgress
                  size={192}
                  strokeWidth={16}
                  progress={rhythmScore}
                  color={colors.purple[500]}
                  backgroundColor={colors.stone[200]}
                />
                <View className="absolute items-center">
                  <Text
                    className="text-5xl font-bold text-stone-900"
                    style={{ fontFamily: FontFamily.serif }}
                  >
                    {Math.round(rhythmScore)}%
                  </Text>
                </View>
              </View>
              <View
                className="px-4 py-1.5 rounded-full"
                style={{ backgroundColor: colors.purple[50] }}
              >
                <Text className="text-xs font-bold text-purple-600 uppercase tracking-widest">
                  {getRhythmStatus(data.score)}
                </Text>
              </View>
            </Animated.View>

            {/* Consistency Metrics */}
            <Animated.View entering={FadeInDown.delay(100).duration(400)} style={{ gap: 12 }}>
              {/* Bedtime Consistency */}
              <View
                className="bg-white p-4 rounded-2xl border border-stone-100 flex-row justify-between items-center"
                style={{
                  shadowColor: '#000',
                  shadowOffset: { width: 0, height: 2 },
                  shadowOpacity: 0.04,
                  shadowRadius: 6,
                  elevation: 2,
                }}
              >
                <View className="flex-row items-center" style={{ gap: 12 }}>
                  <View
                    className="p-2.5 rounded-xl"
                    style={{ backgroundColor: colors.purple[50] }}
                  >
                    <Clock size={20} color={colors.purple[600]} />
                  </View>
                  <View>
                    <Text className="text-sm font-bold text-stone-900">
                      {t('detail.rhythm.bedtimeConsistency')}
                    </Text>
                    <Text className="text-xs text-stone-500">
                      {t('detail.rhythm.target')}: {data.consistency.bedtime.target}
                    </Text>
                  </View>
                </View>
                <Text className="text-sm font-bold text-stone-900">
                  {data.consistency.bedtime.deviation}
                </Text>
              </View>

              {/* Wake Consistency */}
              <View
                className="bg-white p-4 rounded-2xl border border-stone-100 flex-row justify-between items-center"
                style={{
                  shadowColor: '#000',
                  shadowOffset: { width: 0, height: 2 },
                  shadowOpacity: 0.04,
                  shadowRadius: 6,
                  elevation: 2,
                }}
              >
                <View className="flex-row items-center" style={{ gap: 12 }}>
                  <View
                    className="p-2.5 rounded-xl"
                    style={{ backgroundColor: colors.purple[50] }}
                  >
                    <Clock size={20} color={colors.purple[600]} />
                  </View>
                  <View>
                    <Text className="text-sm font-bold text-stone-900">
                      {t('detail.rhythm.wakeConsistency')}
                    </Text>
                    <Text className="text-xs text-stone-500">
                      {t('detail.rhythm.target')}: {data.consistency.wakeTime.target}
                    </Text>
                  </View>
                </View>
                <Text className="text-sm font-bold text-stone-900">
                  {data.consistency.wakeTime.deviation}
                </Text>
              </View>
            </Animated.View>

            {/* Contributing Factors */}
            <Animated.View entering={FadeInDown.delay(150).duration(400)} style={{ gap: 12 }}>
              <Text className="text-xs font-bold text-stone-400 uppercase tracking-widest">
                {t('detail.rhythm.contributingFactors')}
              </Text>
              <View className="flex-row flex-wrap" style={{ gap: 12 }}>
                <View style={{ width: '48%' }}>
                  <FactorCard
                    icon={Moon}
                    iconColor={colors.purple[500]}
                    iconBg={colors.purple[50]}
                    label={data.contributingFactors.bedtimeVariance.label}
                    value={data.contributingFactors.bedtimeVariance.value}
                    trend={data.contributingFactors.bedtimeVariance.trend}
                    trendDirection={data.contributingFactors.bedtimeVariance.trendDirection}
                    detail={data.contributingFactors.bedtimeVariance.detail}
                  />
                </View>
                <View style={{ width: '48%' }}>
                  <FactorCard
                    icon={Sun}
                    iconColor={colors.amber[500]}
                    iconBg={colors.amber[50]}
                    label={data.contributingFactors.wakeVariance.label}
                    value={data.contributingFactors.wakeVariance.value}
                    trend={data.contributingFactors.wakeVariance.trend}
                    trendDirection={data.contributingFactors.wakeVariance.trendDirection}
                    detail={data.contributingFactors.wakeVariance.detail}
                  />
                </View>
                <View style={{ width: '48%' }}>
                  <FactorCard
                    icon={Calendar}
                    iconColor={colors.blue[500]}
                    iconBg={colors.blue[50]}
                    label={data.contributingFactors.weekendShift.label}
                    value={data.contributingFactors.weekendShift.value}
                    trend={data.contributingFactors.weekendShift.trend}
                    trendDirection={data.contributingFactors.weekendShift.trendDirection}
                    detail={data.contributingFactors.weekendShift.detail}
                  />
                </View>
                <View style={{ width: '48%' }}>
                  <FactorCard
                    icon={Plane}
                    iconColor={colors.rose[500]}
                    iconBg={colors.rose[50]}
                    label={data.contributingFactors.socialJetlag.label}
                    value={data.contributingFactors.socialJetlag.value}
                    trend={data.contributingFactors.socialJetlag.trend}
                    trendDirection={data.contributingFactors.socialJetlag.trendDirection}
                    detail={data.contributingFactors.socialJetlag.detail}
                  />
                </View>
              </View>
            </Animated.View>

            {/* AI Explanation */}
            <Animated.View
              entering={FadeInDown.delay(200).duration(400)}
              className="bg-purple-50 p-5 rounded-3xl border border-purple-100"
            >
              <Text className="text-sm text-stone-700 leading-relaxed">{data.analysis}</Text>
            </Animated.View>

            {/* Weekly Pattern Visual */}
            <Animated.View entering={FadeInDown.delay(300).duration(400)}>
              {renderWeeklyPattern()}
            </Animated.View>
          </View>
        </ScrollView>
      </SafeAreaView>
    </View>
  );
}
