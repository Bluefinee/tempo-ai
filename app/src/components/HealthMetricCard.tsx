/**
 * HealthMetricCard - Health Summary グリッド用カード
 * 白背景で浮遊感のある美しいカードデザイン（Apple Design Award品質）
 */

import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { Check, AlertCircle } from 'lucide-react-native';
import { colors } from '../theme';

export type IconType = 'activity' | 'heart' | 'wind' | 'droplet' | 'thermometer';
export type MetricStatus = 'in-range' | 'out-of-range';

interface HealthMetricCardProps {
  id: string;
  name: string;
  value: number | string;
  unit: string;
  status: MetricStatus;
  statusLabel: string;
  iconType: IconType;
  isLastOdd?: boolean;
  onPress?: () => void;
}

export const HealthMetricCard = ({
  name,
  value,
  unit,
  status,
  statusLabel,
  isLastOdd = false,
  onPress,
}: HealthMetricCardProps): React.ReactElement => {
  const isOutOfRange = status === 'out-of-range';

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.container,
        isLastOdd && styles.containerLastOdd,
        pressed && styles.pressed,
      ]}
    >
      {/* Label - テキストのみ、アイコンなし */}
      <Text style={styles.label}>{name.toUpperCase()}</Text>

      {/* Value */}
      <View style={styles.valueRow}>
        <Text style={styles.value}>{value}</Text>
        <Text style={styles.unit}>{unit}</Text>
      </View>

      {/* Status Pill */}
      <View style={styles.statusRow}>
        {isOutOfRange ? (
          <AlertCircle size={14} strokeWidth={2.5} color={colors.amber[500]} />
        ) : (
          <Check size={14} strokeWidth={3} color={colors.emerald[500]} />
        )}
        <Text style={[styles.statusText, isOutOfRange ? styles.statusOutOfRange : styles.statusInRange]}>
          {statusLabel}
        </Text>
      </View>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    padding: 16,
    minHeight: 130,
    justifyContent: 'space-between',
    // 浮遊感のある強いシャドウ
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.12,
    shadowRadius: 16,
    elevation: 8,
  },
  containerLastOdd: {
    // Full width variant uses same styling
  },
  pressed: {
    transform: [{ scale: 0.97 }],
    opacity: 0.95,
  },
  label: {
    fontSize: 11,
    fontWeight: '600',
    color: colors.stone[400],
    letterSpacing: 1,
    marginBottom: 8,
  },
  valueRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: 4,
    marginBottom: 8,
  },
  value: {
    fontSize: 32,
    fontWeight: '700',
    color: colors.stone[900],
    letterSpacing: -0.5,
  },
  unit: {
    fontSize: 14,
    fontWeight: '500',
    color: colors.stone[400],
  },
  statusRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  statusText: {
    fontSize: 13,
    fontWeight: '500',
  },
  statusInRange: {
    color: colors.emerald[500],
  },
  statusOutOfRange: {
    color: colors.amber[500],
  },
});
