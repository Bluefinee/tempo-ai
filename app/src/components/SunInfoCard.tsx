/**
 * SunInfoCard - 日の出/日の入りカード
 * StyleSheet.createのみ使用（NativeWind排除）
 */

import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { Sunrise, Sunset } from 'lucide-react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';

import { Colors } from '../theme';

type SunType = 'sunrise' | 'sunset';

interface SunInfoCardProps {
  type: SunType;
  time: string;
  label?: string;
  delay?: number;
  onPress?: () => void;
}

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

const getTypeConfig = (type: SunType) => {
  if (type === 'sunrise') {
    return {
      Icon: Sunrise,
      iconColor: Colors.amber[500],
      iconBgColor: 'rgba(251, 191, 36, 0.12)',
      labelColor: Colors.stone[400],
      defaultLabel: 'Sunrise',
    };
  }
  return {
    Icon: Sunset,
    iconColor: Colors.indigo[500],
    iconBgColor: 'rgba(99, 102, 241, 0.12)',
    labelColor: Colors.stone[400],
    defaultLabel: 'Sunset',
  };
};

export const SunInfoCard = ({
  type,
  time,
  label,
  delay = 0,
  onPress,
}): SunInfoCardProps => {
  const config = getTypeConfig(type);
  const displayLabel = label ?? config.defaultLabel;

  return (
    <View style={styles.wrapper}>
      <AnimatedPressable
        entering={FadeInDown.delay(delay).duration(400)}
        onPress={onPress}
        style={({ pressed }) => [
          styles.card,
          pressed && styles.cardPressed,
        ]}
      >
        {/* Content - horizontal layout */}
        <View style={styles.content}>
          <View style={styles.textContent}>
            {/* Label */}
            <Text style={[styles.label, { color: config.labelColor }]}>
              {displayLabel.toUpperCase()}
            </Text>

            {/* Time */}
            <Text style={styles.time}>{time}</Text>
          </View>

          {/* Icon with background */}
          <View style={[styles.iconWrapper, { backgroundColor: config.iconBgColor }]}>
            <config.Icon size={22} color={config.iconColor} strokeWidth={2} />
          </View>
        </View>
      </AnimatedPressable>
    </View>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    flex: 1,
  },
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    padding: 16,
    // シャドウ（iOS）
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.12,
    shadowRadius: 16,
    // シャドウ（Android）
    elevation: 8,
  },
  cardPressed: {
    opacity: 0.95,
    transform: [{ scale: 0.98 }],
  },
  content: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  textContent: {
    flex: 1,
  },
  label: {
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 1,
    marginBottom: 6,
  },
  time: {
    fontSize: 24,
    fontWeight: '700',
    color: '#1C1917',
    letterSpacing: -0.5,
  },
  iconWrapper: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
