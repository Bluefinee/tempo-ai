/**
 * InsightDetailScreen - インサイト詳細画面
 * MOCK_AI_RESPONSE からデータを取得し、Today画面と共有
 */

import React, { useEffect } from 'react';
import { View, Text, ScrollView, Pressable } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { ChevronLeft, Sparkles, Activity, Moon, Clock } from 'lucide-react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withDelay,
  withTiming,
} from 'react-native-reanimated';

import { t } from '../../src/i18n';
import { FontFamily } from '../../src/theme';
import { MOCK_AI_RESPONSE } from "../../src/constants/mockData";
import { formatDate } from "../../src/utils/dateFormatters";

// アイコン設定（UI表示用）
const DATA_POINT_ICONS = [
  { key: 'hrv', icon: Activity, iconColor: '#FB7185', iconBg: '#FFF1F2' },
  { key: 'sleep', icon: Moon, iconColor: '#6366F1', iconBg: '#EEF2FF' },
  { key: 'rhythm', icon: Clock, iconColor: '#F59E0B', iconBg: '#FFFBEB' },
] as const;

// Fade-in animation hook
const useFadeIn = (delay: number = 0) => {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(10);

  useEffect(() => {
    opacity.value = withDelay(delay, withTiming(1, { duration: 600 }));
    translateY.value = withDelay(delay, withTiming(0, { duration: 600 }));
  }, [opacity, translateY, delay]);

  return useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }));
};

const InsightDetailScreen = (): React.ReactElement => {
  const router = useRouter();
  const insets = useSafeAreaInsets();

  // MOCK_AI_RESPONSE からデータを取得（Today画面と共有）
  const { todayInsight } = MOCK_AI_RESPONSE;
  const { whyThisMatters } = todayInsight;

  // Fade-in animations
  const titleFadeIn = useFadeIn(0);
  const conditionFadeIn = useFadeIn(100);
  const whyFadeIn = useFadeIn(200);
  const meaningFadeIn = useFadeIn(300);

  return (
    <View className="flex-1 bg-stone-100">
      {/* Sticky Header */}
      <View
        className="flex-row items-center px-6 pb-4 border-b border-stone-100 z-20"
        style={{
          paddingTop: insets.top + 16,
          backgroundColor: 'rgba(250, 250, 249, 0.9)',
          gap: 16,
        }}
      >
        <Pressable
          onPress={() => router.back()}
          className="w-10 h-10 items-center justify-center rounded-full"
        >
          <ChevronLeft size={24} color="#57534E" />
        </Pressable>
        <Text className="text-sm font-bold text-stone-400 uppercase tracking-widest">
          {t('screen.insightDetail.header')}
        </Text>
      </View>

      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: 24,
          paddingTop: 16,
          paddingBottom: 128,
        }}
        showsVerticalScrollIndicator={false}
      >
        {/* Title Section */}
        <Animated.View style={titleFadeIn}>
          <View className="flex-row items-center mb-2" style={{ gap: 8 }}>
            <Sparkles size={20} color="#6366F1" />
          </View>
          <Text
            className="text-3xl text-stone-900 tracking-tight mb-1"
            style={{ fontFamily: FontFamily.serif }}
          >
            {todayInsight.title}
          </Text>
          <Text className="text-stone-500 font-medium">{formatDate()}</Text>
        </Animated.View>

        {/* Section 1: Summary */}
        <Animated.View
          style={[conditionFadeIn, { marginTop: 32 }]}
          className="pl-4 border-l-4 border-indigo-500 py-1"
        >
          <Text
            className="text-lg text-stone-700 leading-relaxed italic"
            style={{ fontFamily: FontFamily.serif }}
          >
            {todayInsight.summary}
          </Text>
        </Animated.View>

        {/* Section 2: Why This Matters */}
        <Animated.View style={[whyFadeIn, { marginTop: 32 }]}>
          <Text className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-4">
            {t('screen.insightDetail.whyThisMatters')}
          </Text>

          <View
            className="bg-white rounded-2xl p-4 border border-stone-100"
            style={{
              shadowColor: '#000',
              shadowOffset: { width: 0, height: 4 },
              shadowOpacity: 0.06,
              shadowRadius: 20,
              elevation: 4,
              gap: 16,
            }}
          >
            {DATA_POINT_ICONS.map((iconConfig, index) => {
              const IconComponent = iconConfig.icon;
              const dataPoint = whyThisMatters[iconConfig.key];
              return (
                <React.Fragment key={iconConfig.key}>
                  {index > 0 && <View className="h-px bg-stone-100 w-full" />}
                  <View className="flex-row items-start" style={{ gap: 12 }}>
                    <View
                      className="p-2 rounded-lg mt-0.5"
                      style={{ backgroundColor: iconConfig.iconBg }}
                    >
                      <IconComponent size={18} color={iconConfig.iconColor} />
                    </View>
                    <View className="flex-1">
                      <Text className="text-sm font-bold text-stone-900">{dataPoint.headline}</Text>
                      <Text className="text-xs text-stone-500 mt-0.5">{dataPoint.explanation}</Text>
                    </View>
                  </View>
                </React.Fragment>
              );
            })}
          </View>
        </Animated.View>

        {/* Section 3: What This Means For Today */}
        <Animated.View style={[meaningFadeIn, { marginTop: 32 }]}>
          <Text className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-3">
            {t('screen.insightDetail.whatThisMeans')}
          </Text>
          <View
            className="p-5 rounded-2xl border border-indigo-100"
            style={{ backgroundColor: 'rgba(238, 242, 255, 0.5)' }}
          >
            <Text className="text-sm text-indigo-900 leading-relaxed">{todayInsight.whatThisMeansForToday}</Text>
          </View>
        </Animated.View>

      </ScrollView>
    </View>
  );
}

export default InsightDetailScreen;
