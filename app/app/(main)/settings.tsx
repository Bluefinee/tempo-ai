/**
 * SettingsScreen - 設定画面
 * sozai/new/tempoai/screens/SettingsScreen.tsx を React Native で完全再現
 */

import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, Pressable } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import {
  Moon,
  Sun,
  Bell,
  Zap,
  Heart,
  ChevronRight,
  HelpCircle,
  Shield,
  LogOut,
  Smartphone,
  LucideIcon,
} from 'lucide-react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withDelay,
  withTiming,
} from 'react-native-reanimated';

import { TAB_BAR_HEIGHT } from './_layout';
import { t } from '../../src/i18n';
import { FontFamily } from '../../src/theme';

// 日本語化されたMOCKデータ
const MOCK_DATA = {
  nickname: '田中 太郎',
  plan: 'フリープラン',
  memberSince: '2024',
  targetBedtime: '22:30',
  targetWakeUp: '6:30',
};

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

// Toggle Switch Component
const ToggleSwitch: React.FC<{
  value: boolean;
  onValueChange: (value: boolean) => void;
}> = ({ value, onValueChange }) => {
  const translateX = useSharedValue(value ? 20 : 0);

  useEffect(() => {
    translateX.value = withSpring(value ? 20 : 0, { damping: 15, stiffness: 120 });
  }, [value, translateX]);

  const thumbStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
  }));

  return (
    <Pressable
      onPress={() => onValueChange(!value)}
      className="w-12 h-7 rounded-full p-1 justify-center"
      style={{ backgroundColor: value ? '#6366F1' : '#E7E5E4' }}
    >
      <Animated.View
        style={[
          thumbStyle,
          {
            width: 20,
            height: 20,
            borderRadius: 10,
            backgroundColor: '#FFFFFF',
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: 0.15,
            shadowRadius: 4,
            elevation: 3,
          },
        ]}
      />
    </Pressable>
  );
};

// Section Component
const Section: React.FC<{ title: string; children: React.ReactNode }> = ({ title, children }) => (
  <View className="mb-8">
    <Text className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-3 ml-2">
      {title}
    </Text>
    <View
      className="bg-white rounded-2xl border border-stone-100 p-2"
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.06,
        shadowRadius: 20,
        elevation: 4,
      }}
    >
      {children}
    </View>
  </View>
);

// Settings Row Component
interface SettingsRowProps {
  icon: LucideIcon;
  iconColor: string;
  iconBg: string;
  label: string;
  value?: string;
  valueColor?: string;
  showChevron?: boolean;
  onPress?: () => void;
}

const SettingsRow: React.FC<SettingsRowProps> = ({
  icon: Icon,
  iconColor,
  iconBg,
  label,
  value,
  valueColor = '#A8A29E',
  showChevron = true,
  onPress,
}) => (
  <Pressable
    onPress={onPress}
    className="flex-row items-center justify-between p-3 rounded-xl"
    style={({ pressed }) => ({ opacity: pressed && onPress ? 0.7 : 1 })}
  >
    <View className="flex-row items-center" style={{ gap: 12 }}>
      <View className="p-2 rounded-xl" style={{ backgroundColor: iconBg }}>
        <Icon size={18} color={iconColor} />
      </View>
      <Text className="text-sm font-medium text-stone-700">{label}</Text>
    </View>
    <View className="flex-row items-center" style={{ gap: 8 }}>
      {value && (
        <Text className="text-sm" style={{ color: valueColor }}>
          {value}
        </Text>
      )}
      {showChevron && <ChevronRight size={20} color="#D6D3D1" />}
    </View>
  </Pressable>
);

// Toggle Row Component
interface ToggleRowProps {
  icon: LucideIcon;
  iconColor: string;
  iconBg: string;
  label: string;
  value: boolean;
  onValueChange: (value: boolean) => void;
}

const ToggleRow: React.FC<ToggleRowProps> = ({
  icon: Icon,
  iconColor,
  iconBg,
  label,
  value,
  onValueChange,
}) => (
  <View className="flex-row items-center justify-between p-3">
    <View className="flex-row items-center" style={{ gap: 12 }}>
      <View className="p-2 rounded-xl" style={{ backgroundColor: iconBg }}>
        <Icon size={18} color={iconColor} />
      </View>
      <Text className="text-sm font-medium text-stone-700">{label}</Text>
    </View>
    <ToggleSwitch value={value} onValueChange={onValueChange} />
  </View>
);

export default function SettingsScreen(): React.ReactElement {
  const insets = useSafeAreaInsets();
  const [notifications, setNotifications] = useState(true);
  const [haptic, setHaptic] = useState(true);

  // Fade-in animations
  const headerFadeIn = useFadeIn(0);
  const contentFadeIn = useFadeIn(100);

  return (
    <View className="flex-1 bg-stone-100">
      <SafeAreaView className="flex-1" edges={['top']}>
        <ScrollView
          contentContainerStyle={{
            paddingHorizontal: 24,
            paddingBottom: TAB_BAR_HEIGHT + insets.bottom + 24,
          }}
          showsVerticalScrollIndicator={false}
        >
          {/* Header */}
          <Animated.View style={headerFadeIn} className="pt-14 mb-6">
            <Text
              className="text-3xl text-stone-900 tracking-tight mb-1"
              style={{ fontFamily: FontFamily.serif }}
            >
              {t('screen.settings.title')}
            </Text>
            <Text className="text-sm text-stone-500">{t('screen.settings.subtitle')}</Text>
          </Animated.View>

          <Animated.View style={contentFadeIn}>
            {/* Profile Card */}
            <View
              className="bg-white p-4 rounded-3xl border border-stone-100 flex-row items-center mb-8"
              style={{
                gap: 16,
                shadowColor: '#000',
                shadowOffset: { width: 0, height: 4 },
                shadowOpacity: 0.06,
                shadowRadius: 20,
                elevation: 4,
              }}
            >
              <LinearGradient
                colors={['#E0E7FF', '#FFE4E6']}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                className="items-center justify-center"
                style={{ width: 64, height: 64, borderRadius: 32 }}
              >
                <Text style={{ fontSize: 28 }}>🧘</Text>
              </LinearGradient>
              <View className="flex-1">
                <Text className="text-lg font-bold text-stone-900">{MOCK_DATA.nickname}</Text>
                <Text className="text-xs text-stone-500">
                  {MOCK_DATA.plan} • {MOCK_DATA.memberSince}年から利用
                </Text>
              </View>
              <Pressable className="p-2 rounded-full">
                <ChevronRight size={20} color="#A8A29E" />
              </Pressable>
            </View>

            {/* My Rhythm Section */}
            <Section title={t('screen.settings.myRhythm')}>
              <SettingsRow
                icon={Moon}
                iconColor="#6366F1"
                iconBg="#EEF2FF"
                label={t('screen.settings.targetBedtime')}
                value={MOCK_DATA.targetBedtime}
              />
              <SettingsRow
                icon={Sun}
                iconColor="#F59E0B"
                iconBg="#FFFBEB"
                label={t('screen.settings.targetWakeUp')}
                value={MOCK_DATA.targetWakeUp}
              />
            </Section>

            {/* Preferences Section */}
            <Section title={t('screen.settings.preferences')}>
              <ToggleRow
                icon={Bell}
                iconColor="#F43F5E"
                iconBg="#FFF1F2"
                label={t('screen.settings.gentleNudges')}
                value={notifications}
                onValueChange={setNotifications}
              />
              <ToggleRow
                icon={Zap}
                iconColor="#57534E"
                iconBg="#F5F5F4"
                label={t('screen.settings.hapticFeedback')}
                value={haptic}
                onValueChange={setHaptic}
              />
            </Section>

            {/* Data Source Section */}
            <Section title={t('screen.settings.dataSource')}>
              {/* Apple Health - Connected */}
              <View className="flex-row items-center justify-between p-3">
                <View className="flex-row items-center" style={{ gap: 12 }}>
                  <View className="p-2 rounded-xl bg-stone-900">
                    <Heart size={18} color="#FFFFFF" fill="#FFFFFF" />
                  </View>
                  <Text className="text-sm font-medium text-stone-700">{t('screen.settings.appleHealth')}</Text>
                </View>
                <View className="bg-emerald-50 px-2 py-1 rounded-md">
                  <Text className="text-xs font-bold text-emerald-600">{t('screen.settings.connected')}</Text>
                </View>
              </View>

              {/* Divider */}
              <View className="h-px bg-stone-100 my-2 mx-12" />

              {/* Oura Ring - Connect */}
              <SettingsRow
                icon={Smartphone}
                iconColor="#78716C"
                iconBg="#F5F5F4"
                label={t('screen.settings.ouraRing')}
                value={t('screen.settings.connect')}
                valueColor="#4F46E5"
              />
            </Section>

            {/* Support Section */}
            <Section title={t('screen.settings.support')}>
              <SettingsRow
                icon={HelpCircle}
                iconColor="#6366F1"
                iconBg="#EEF2FF"
                label={t('screen.settings.helpCenter')}
              />
              <SettingsRow
                icon={Shield}
                iconColor="#6366F1"
                iconBg="#EEF2FF"
                label={t('screen.settings.privacyPolicy')}
              />
            </Section>

            {/* Sign Out Button */}
            <Pressable
              className="flex-row items-center justify-center py-4 rounded-2xl border border-rose-100 mb-8"
              style={{
                gap: 8,
                backgroundColor: 'rgba(255, 241, 242, 0.5)',
              }}
            >
              <LogOut size={16} color="#E11D48" />
              <Text className="text-sm font-medium text-rose-600">{t('screen.settings.resetSignOut')}</Text>
            </Pressable>

            {/* Version */}
            <View className="items-center pb-8">
              <Text className="text-xs font-medium text-stone-400 font-mono">
                {t('screen.settings.version')}
              </Text>
            </View>
          </Animated.View>
        </ScrollView>
      </SafeAreaView>
    </View>
  );
}
