/**
 * ActionDetailScreen - アクション詳細画面
 * MOCK_AI_RESPONSE からデータを取得し、Today画面と共有
 */

import React from 'react';
import { View, Text, ScrollView, Pressable } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { ChevronLeft, Footprints, Sun, Battery, Moon, Bell } from 'lucide-react-native';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';

import { t } from '../../src/i18n';
import { colors, FontFamily } from '../../src/theme';
import { MOCK_AI_RESPONSE } from "../../src/constants/mockData";
import { useFadeIn } from '../../src/hooks/useFadeIn';

// アイコン設定（UI表示用）
const BENEFIT_ICONS = [
  { icon: Sun, iconColor: colors.amber[500], iconBg: colors.amber[50] },
  { icon: Moon, iconColor: colors.indigo[500], iconBg: colors.indigo[50] },
  { icon: Battery, iconColor: colors.emerald[500], iconBg: colors.emerald[50] },
];

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

const ActionDetailScreen = (): React.ReactElement => {
  const router = useRouter();
  const insets = useSafeAreaInsets();

  // MOCK_AI_RESPONSE からデータを取得（Today画面と共有）
  const { todayOneThing } = MOCK_AI_RESPONSE;

  // Fade-in animations
  const titleFadeIn = useFadeIn(0);
  const whyFadeIn = useFadeIn(100);
  const howFadeIn = useFadeIn(200);
  const benefitFadeIn = useFadeIn(300);
  const buttonFadeIn = useFadeIn(400);

  // Button press animation
  const buttonScale = useSharedValue(1);

  const buttonPressStyle = useAnimatedStyle(() => ({
    transform: [{ scale: buttonScale.value }],
  }));

  const handleReminder = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    // TODO: Implement reminder functionality
  };

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
          {t('screen.actionDetail.header')}
        </Text>
      </View>

      {/* Scrollable Content */}
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: 24,
          paddingTop: 24,
          paddingBottom: 160,
        }}
        showsVerticalScrollIndicator={false}
      >
        {/* Title Section */}
        <Animated.View style={titleFadeIn} className="items-center">
          <View
            className="w-20 h-20 rounded-full items-center justify-center mb-4"
            style={{
              backgroundColor: colors.amber[100],
              shadowColor: colors.amber[500],
              shadowOffset: { width: 0, height: 4 },
              shadowOpacity: 0.15,
              shadowRadius: 12,
              elevation: 4,
            }}
          >
            <Footprints size={40} color={colors.amber[600]} strokeWidth={1.5} />
          </View>
          <Text
            className="text-2xl font-bold text-stone-900 tracking-tight mb-2 text-center leading-tight"
            style={{ fontFamily: FontFamily.serif }}
          >
            {todayOneThing.action}
          </Text>
          <Text className="text-stone-500 font-medium text-center">{todayOneThing.summary}</Text>
        </Animated.View>

        {/* Section 1: Why This Action - 説明文のみ、タイトルなし */}
        <Animated.View style={[whyFadeIn, { marginTop: 32 }]}>
          <View
            className="bg-amber-50 rounded-2xl p-5 border border-amber-100"
          >
            <Text className="text-stone-700 text-sm leading-relaxed">
              {todayOneThing.whyThisAction}
            </Text>
          </View>
        </Animated.View>

        {/* Section 2: Benefits - ピルスタイル */}
        <Animated.View
          style={[whyFadeIn, { marginTop: 24 }]}
          className="flex-row flex-wrap justify-center"
        >
          {todayOneThing.benefits.map((benefit, index) => {
            const iconConfig = BENEFIT_ICONS[index % BENEFIT_ICONS.length];
            const IconComponent = iconConfig.icon;
            return (
              <View
                key={index}
                className="flex-row items-center bg-white rounded-full px-4 py-2 m-1"
                style={{
                  borderWidth: 1,
                  borderColor: colors.stone[100],
                  shadowColor: colors.black,
                  shadowOffset: { width: 0, height: 2 },
                  shadowOpacity: 0.04,
                  shadowRadius: 4,
                  elevation: 2,
                }}
              >
                <IconComponent size={14} color={iconConfig.iconColor} />
                <Text className="text-xs font-medium text-stone-700 ml-2">{benefit}</Text>
              </View>
            );
          })}
        </Animated.View>

        {/* Section 3: How To Do It - シンプルなリスト */}
        <Animated.View style={[howFadeIn, { marginTop: 32 }]}>
          <Text className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-4">
            {t('screen.actionDetail.howToDoIt')}
          </Text>
          <View style={{ gap: 12 }}>
            {todayOneThing.howToDoIt.map((step, index) => (
              <View
                key={index}
                className="flex-row items-start"
                style={{ gap: 12 }}
              >
                <View
                  className="w-6 h-6 rounded-full items-center justify-center"
                  style={{ backgroundColor: colors.amber[100] }}
                >
                  <Text className="text-xs font-bold" style={{ color: colors.amber[600] }}>{index + 1}</Text>
                </View>
                <Text className="text-sm text-stone-700 flex-1 leading-relaxed">{step}</Text>
              </View>
            ))}
          </View>
        </Animated.View>

        {/* Section 4: Expected Benefit */}
        <Animated.View style={[benefitFadeIn, { marginTop: 32 }]}>
          <Text className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-3">
            {t('screen.actionDetail.expectedBenefit')}
          </Text>
          <View
            className="bg-white p-5 rounded-2xl border border-stone-100"
            style={{
              shadowColor: colors.black,
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: 0.04,
              shadowRadius: 8,
              elevation: 2,
            }}
          >
            <Text className="text-sm text-stone-800 leading-relaxed mb-2">
              {todayOneThing.expectedBenefit.text}
            </Text>
            <Text className="text-xs text-stone-400">
              — {todayOneThing.expectedBenefit.source}
            </Text>
          </View>
        </Animated.View>
      </ScrollView>

      {/* Sticky Bottom Button - グラデーション背景付きアンバーボタン */}
      <Animated.View
        style={[
          buttonFadeIn,
          {
            position: 'absolute',
            bottom: 0,
            left: 0,
            right: 0,
            paddingHorizontal: 24,
            paddingBottom: Math.max(insets.bottom, 24) + 16,
            paddingTop: 16,
          },
        ]}
      >
        <LinearGradient
          colors={['rgba(250, 250, 249, 0)', 'rgba(250, 250, 249, 0.95)', 'rgba(250, 250, 249, 1)']}
          locations={[0, 0.4, 1]}
          style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}
        />
        <AnimatedPressable
          onPress={handleReminder}
          onPressIn={() => { buttonScale.value = withSpring(0.98); }}
          onPressOut={() => { buttonScale.value = withSpring(1); }}
          style={[
            buttonPressStyle,
            {
              backgroundColor: colors.amber[500],
              paddingVertical: 16,
              borderRadius: 16,
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              shadowColor: colors.amber[600],
              shadowOffset: { width: 0, height: 6 },
              shadowOpacity: 0.3,
              shadowRadius: 12,
              elevation: 8,
            },
          ]}
        >
          <Bell size={20} color="#FFFFFF" />
          <Text className="text-white font-bold">{todayOneThing.time}にリマインド</Text>
        </AnimatedPressable>
      </Animated.View>
    </View>
  );
}

export default ActionDetailScreen;
