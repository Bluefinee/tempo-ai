/**
 * WindowCard - Upcoming Windows カード
 * StyleSheet.createのみ使用（NativeWind排除）
 */

import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { Sun, Moon, LucideIcon } from 'lucide-react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';

import { Colors } from '../theme';

type Theme = 'day' | 'night';

interface WindowCardProps {
  title: string;
  timeRange: string;
  description: string;
  icon?: LucideIcon;
  iconType?: 'sun' | 'moon';
  theme: Theme;
  isActive?: boolean;
  delay?: number;
  onPress?: () => void;
}

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

const getThemeConfig = (theme: Theme): { iconBgColor: string; iconColor: string; timeColor: string; accentColor: string } => {
  if (theme === 'day') {
    return {
      iconBgColor: 'rgba(251, 191, 36, 0.15)',
      iconColor: Colors.amber[500],
      timeColor: Colors.stone[500],
      accentColor: Colors.amber[400],
    };
  }
  return {
    iconBgColor: 'rgba(99, 102, 241, 0.12)',
    iconColor: Colors.indigo[500],
    timeColor: Colors.stone[500],
    accentColor: Colors.indigo[400],
  };
};

export const WindowCard = ({
  title,
  timeRange,
  description,
  icon,
  iconType,
  theme,
  isActive = false,
  delay = 0,
  onPress,
}: WindowCardProps): React.ReactElement => {
  const config = getThemeConfig(theme);
  const IconComponent = icon ?? (iconType === 'moon' ? Moon : Sun);

  return (
    <AnimatedPressable
      entering={FadeInDown.delay(delay).duration(400)}
      onPress={onPress}
      style={({ pressed }) => [
        styles.card,
        isActive && [styles.cardActive, { borderColor: config.accentColor }],
        pressed && styles.cardPressed,
      ]}
    >
      {/* Main content */}
      <View style={styles.content}>
        {/* Icon */}
        <View style={[styles.iconContainer, { backgroundColor: config.iconBgColor }]}>
          <IconComponent size={22} color={config.iconColor} strokeWidth={2} />
        </View>

        {/* Text content */}
        <View style={styles.textContent}>
          <View style={styles.header}>
            <Text style={styles.title}>{title}</Text>
            <Text style={[styles.timeRange, { color: config.timeColor }]}>{timeRange}</Text>
          </View>
          <Text style={styles.description}>{description}</Text>
        </View>
      </View>
    </AnimatedPressable>
  );
};

const styles = StyleSheet.create({
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
  cardActive: {
    borderWidth: 2,
  },
  cardPressed: {
    opacity: 0.95,
    transform: [{ scale: 0.98 }],
  },
  content: {
    flexDirection: 'row',
    gap: 14,
  },
  iconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
  },
  textContent: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 6,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1C1917',
    letterSpacing: -0.3,
    flex: 1,
    marginRight: 8,
  },
  timeRange: {
    fontSize: 12,
    fontWeight: '500',
  },
  description: {
    fontSize: 14,
    color: '#78716C',
    lineHeight: 20,
  },
});
