/**
 * BreatheScreen - 呼吸エクササイズ画面
 * sozai/new/tempoai/screens/BreatheScreen.tsx を React Native で完全再現
 * フルスクリーンモーダル風デザイン
 */

import React, { useCallback, useEffect, useRef, useState } from 'react';
import { View, Text, Pressable, useWindowDimensions } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { X, Play, Pause, Wind } from 'lucide-react-native';
import Svg, { Circle } from 'react-native-svg';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  Easing,
} from 'react-native-reanimated';

import { TAB_BAR_HEIGHT } from './_layout';
import { t } from '../../src/i18n';

const DEEP_NAVY = '#0F172A';

// 4-4-4 Box breathing: 4s inhale, 4s hold, 4s exhale (12s cycle)
const PHASE_DURATIONS = {
  inhale: 4000,
  hold: 4000,
  exhale: 4000,
};

const formatTime = (seconds: number): string => {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins.toString().padStart(2, '0')}:${secs < 10 ? '0' : ''}${secs}`;
};

export default function BreatheScreen(): React.ReactElement {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = useWindowDimensions();
  const [isActive, setIsActive] = useState(false);
  const [phase, setPhase] = useState<'idle' | 'inhale' | 'hold' | 'exhale'>('idle');
  const [timeLeft, setTimeLeft] = useState(60);

  const previousPhaseRef = useRef(phase);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const phaseTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Responsive circle size
  const CIRCLE_SIZE = Math.min(SCREEN_WIDTH * 0.65, 280);
  const SVG_RADIUS = CIRCLE_SIZE * 0.47;
  const CIRCUMFERENCE = 2 * Math.PI * SVG_RADIUS;

  // Animation values
  const scale = useSharedValue(0.75);
  const glowOpacity = useSharedValue(0.2);
  const glowScale = useSharedValue(1);
  const breatheRingOpacity = useSharedValue(0.3);

  // Progress calculation
  const totalTime = 60;
  const progress = ((totalTime - timeLeft) / totalTime) * 100;
  const strokeDashoffset = CIRCUMFERENCE - (progress / 100) * CIRCUMFERENCE;

  // Timer effect
  useEffect(() => {
    if (isActive && timeLeft > 0) {
      timerRef.current = setInterval(() => {
        setTimeLeft((prev) => {
          if (prev <= 1) {
            setIsActive(false);
            setPhase('idle');
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    } else {
      if (timerRef.current) {
        clearInterval(timerRef.current);
        timerRef.current = null;
      }
    }

    return () => {
      if (timerRef.current) {
        clearInterval(timerRef.current);
      }
    };
  }, [isActive, timeLeft]);

  // Phase cycling effect
  useEffect(() => {
    if (!isActive) {
      setPhase('idle');
      return;
    }

    const runCycle = (): void => {
      setPhase('inhale');

      phaseTimeoutRef.current = setTimeout(() => {
        if (!isActive) return;
        setPhase('hold');

        phaseTimeoutRef.current = setTimeout(() => {
          if (!isActive) return;
          setPhase('exhale');

          phaseTimeoutRef.current = setTimeout(() => {
            if (!isActive) return;
            runCycle();
          }, PHASE_DURATIONS.exhale);
        }, PHASE_DURATIONS.hold);
      }, PHASE_DURATIONS.inhale);
    };

    runCycle();

    return () => {
      if (phaseTimeoutRef.current) {
        clearTimeout(phaseTimeoutRef.current);
      }
    };
  }, [isActive]);

  // Animation effect based on phase
  useEffect(() => {
    const targetScale = phase === 'exhale' ? 0.5 : phase === 'inhale' || phase === 'hold' ? 1 : 0.75;
    const targetGlow = phase === 'inhale' || phase === 'hold' ? 0.4 : 0.2;
    const targetGlowScale = phase === 'inhale' || phase === 'hold' ? 1.25 : 1;

    scale.value = withTiming(targetScale, {
      duration: 4000,
      easing: Easing.inOut(Easing.ease),
    });
    glowOpacity.value = withTiming(targetGlow, {
      duration: 4000,
      easing: Easing.inOut(Easing.ease),
    });
    glowScale.value = withTiming(targetGlowScale, {
      duration: 4000,
      easing: Easing.inOut(Easing.ease),
    });
  }, [phase, scale, glowOpacity, glowScale]);

  // Haptic feedback on phase change
  useEffect(() => {
    if (previousPhaseRef.current !== phase && isActive) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    }
    previousPhaseRef.current = phase;
  }, [phase, isActive]);

  const getInstruction = (): string => {
    switch (phase) {
      case 'inhale':
        return t('screen.breathe.instruction.inhale');
      case 'hold':
        return t('screen.breathe.instruction.hold');
      case 'exhale':
        return t('screen.breathe.instruction.exhale');
      default:
        return t('screen.breathe.instruction.ready');
    }
  };

  const handleToggle = useCallback((): void => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    if (!isActive && timeLeft === 0) {
      setTimeLeft(60);
    }
    setIsActive(!isActive);
  }, [isActive, timeLeft]);

  const handleClose = useCallback((): void => {
    setIsActive(false);
    router.back();
  }, [router]);

  // Animated styles
  const glowStyle = useAnimatedStyle(() => ({
    opacity: glowOpacity.value,
    transform: [{ scale: glowScale.value }],
  }));

  const pulseStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const getPhaseColor = (): string => {
    switch (phase) {
      case 'inhale': return '#818CF8';
      case 'hold': return '#A78BFA';
      case 'exhale': return '#6366F1';
      default: return '#6366F1';
    }
  };

  return (
    <View className="flex-1" style={{ backgroundColor: DEEP_NAVY }}>
      {/* Background gradient overlay */}
      <LinearGradient
        colors={['rgba(99, 102, 241, 0.15)', 'transparent', 'rgba(99, 102, 241, 0.1)']}
        locations={[0, 0.5, 1]}
        style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}
      />

      {/* Background ambient glow */}
      <Animated.View
        style={[
          glowStyle,
          {
            position: 'absolute',
            top: '35%',
            left: '50%',
            width: 400,
            height: 400,
            marginLeft: -200,
            marginTop: -200,
            backgroundColor: '#6366F1',
            borderRadius: 200,
          },
        ]}
      />

      {/* Header */}
      <View
        className="flex-row justify-between items-center px-6 z-10"
        style={{ paddingTop: insets.top + 12 }}
      >
        <View className="flex-row items-center" style={{ gap: 12 }}>
          <View
            className="p-2 rounded-xl"
            style={{ backgroundColor: 'rgba(99, 102, 241, 0.3)' }}
          >
            <Wind size={20} color="#A5B4FC" />
          </View>
          <View>
            <Text className="text-lg font-semibold tracking-wide text-white">{t('screen.breathe.title')}</Text>
            <Text className="text-xs text-indigo-300">{t('screen.breathe.subtitle')}</Text>
          </View>
        </View>
        <Pressable
          onPress={handleClose}
          className="p-2.5 rounded-full"
          style={{ backgroundColor: 'rgba(255, 255, 255, 0.1)' }}
        >
          <X size={20} color="#FFFFFF" />
        </Pressable>
      </View>

      {/* Main Content Area */}
      <View
        className="flex-1 items-center justify-center"
        style={{ marginTop: -20 }}
      >
        {/* Breathing Circle Container */}
        <View
          className="items-center justify-center relative"
          style={{ width: CIRCLE_SIZE, height: CIRCLE_SIZE }}
        >
          {/* Progress Ring SVG */}
          <Svg
            style={{ position: 'absolute', width: '100%', height: '100%' }}
            viewBox={`0 0 ${CIRCLE_SIZE} ${CIRCLE_SIZE}`}
          >
            {/* Background Ring */}
            <Circle
              cx={CIRCLE_SIZE / 2}
              cy={CIRCLE_SIZE / 2}
              r={SVG_RADIUS}
              fill="none"
              stroke="rgba(99, 102, 241, 0.15)"
              strokeWidth="3"
            />
            {/* Progress Ring */}
            <Circle
              cx={CIRCLE_SIZE / 2}
              cy={CIRCLE_SIZE / 2}
              r={SVG_RADIUS}
              fill="none"
              stroke={getPhaseColor()}
              strokeWidth="3"
              strokeDasharray={CIRCUMFERENCE}
              strokeDashoffset={strokeDashoffset}
              strokeLinecap="round"
              rotation="-90"
              origin={`${CIRCLE_SIZE / 2}, ${CIRCLE_SIZE / 2}`}
            />
          </Svg>

          {/* Outer Pulsing Ring */}
          <Animated.View
            style={[
              pulseStyle,
              {
                position: 'absolute',
                width: CIRCLE_SIZE * 0.85,
                height: CIRCLE_SIZE * 0.85,
                borderRadius: (CIRCLE_SIZE * 0.85) / 2,
                borderWidth: 1,
                borderColor: 'rgba(99, 102, 241, 0.25)',
              },
            ]}
          />

          {/* Middle Pulsing Ring */}
          <Animated.View
            style={[
              pulseStyle,
              {
                position: 'absolute',
                width: CIRCLE_SIZE * 0.7,
                height: CIRCLE_SIZE * 0.7,
                borderRadius: (CIRCLE_SIZE * 0.7) / 2,
                borderWidth: 1,
                borderColor: 'rgba(129, 140, 248, 0.2)',
              },
            ]}
          />

          {/* Core Circle with Gradient */}
          <Animated.View
            style={[
              pulseStyle,
              {
                width: CIRCLE_SIZE * 0.45,
                height: CIRCLE_SIZE * 0.45,
                borderRadius: (CIRCLE_SIZE * 0.45) / 2,
                overflow: 'hidden',
                shadowColor: '#6366F1',
                shadowOffset: { width: 0, height: 0 },
                shadowOpacity: 0.6,
                shadowRadius: 30,
                elevation: 20,
              },
            ]}
          >
            <LinearGradient
              colors={['#818CF8', '#6366F1', '#4F46E5']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}
            >
              {/* Inner glow effect */}
              <View
                style={{
                  width: '60%',
                  height: '60%',
                  borderRadius: 100,
                  backgroundColor: 'rgba(255, 255, 255, 0.15)',
                }}
              />
            </LinearGradient>
          </Animated.View>
        </View>

        {/* Text Instruction */}
        <View className="mt-8 items-center justify-center">
          <Text
            className="text-2xl font-light text-white tracking-wider text-center"
            style={{ opacity: isActive ? 1 : 0.6 }}
          >
            {getInstruction()}
          </Text>
          {isActive && (
            <View
              className="mt-3 px-4 py-1.5 rounded-full"
              style={{ backgroundColor: 'rgba(99, 102, 241, 0.3)' }}
            >
              <Text className="text-xs font-medium text-indigo-200 tracking-widest">
                {phase === 'inhale' ? t('screen.breathe.phase.inhale') : phase === 'hold' ? t('screen.breathe.phase.hold') : phase === 'exhale' ? t('screen.breathe.phase.exhale') : ''}
              </Text>
            </View>
          )}
        </View>
      </View>

      {/* Controls - Fixed at bottom above tab bar */}
      <View
        className="items-center z-10"
        style={{
          paddingBottom: TAB_BAR_HEIGHT + insets.bottom + 24,
          gap: 20,
        }}
      >
        {/* Timer Display */}
        <View className="items-center">
          <Text
            className="font-mono font-light text-white tracking-widest"
            style={{ fontSize: 48, opacity: 0.9 }}
          >
            {formatTime(timeLeft)}
          </Text>
          <Text className="text-xs text-indigo-300 mt-1">
            {isActive ? t('screen.breathe.sessionInProgress') : t('screen.breathe.tapToBegin')}
          </Text>
        </View>

        {/* Play/Pause Button */}
        <Pressable
          onPress={handleToggle}
          className="items-center justify-center"
          style={{
            width: 72,
            height: 72,
            borderRadius: 36,
            backgroundColor: '#FFFFFF',
            shadowColor: '#FFFFFF',
            shadowOffset: { width: 0, height: 0 },
            shadowOpacity: 0.3,
            shadowRadius: 16,
            elevation: 12,
          }}
        >
          {isActive ? (
            <Pause size={28} color="#4F46E5" fill="#4F46E5" />
          ) : (
            <Play size={28} color="#4F46E5" fill="#4F46E5" style={{ marginLeft: 3 }} />
          )}
        </Pressable>
      </View>
    </View>
  );
}
