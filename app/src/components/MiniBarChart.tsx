/**
 * MiniBarChart - 統一バーチャートコンポーネント
 *
 * ホーム画面と詳細画面で共通のバーチャートスタイルを提供
 * - シンプルなバー表示
 * - 最後のバーをハイライト
 * - オプションでラベル表示
 */

import React from 'react';
import { View, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { colors } from '../theme';

export interface MiniBarChartData {
  label?: string;
  value: number;
}

export interface MiniBarChartProps {
  /** チャートデータ */
  data: MiniBarChartData[];
  /** バーの色 */
  color: string;
  /** チャートの高さ（デフォルト: 48） */
  height?: number;
  /** ラベルを表示するか（デフォルト: false） */
  showLabels?: boolean;
  /** 最大値（デフォルト: 100） */
  maxValue?: number;
  /** 非アクティブバーの透明度（デフォルト: 0.3） */
  inactiveOpacity?: number;
  /** アニメーションを有効にするか（デフォルト: false） */
  animated?: boolean;
  /** バー間のギャップ（デフォルト: 4） */
  gap?: number;
  /** バーの角丸（デフォルト: 2） */
  borderRadius?: number;
  /** コンテナスタイル */
  style?: ViewStyle;
}

/**
 * MiniBarChart コンポーネント
 *
 * @example
 * // ホーム画面での使用（ラベルなし、コンパクト）
 * <MiniBarChart
 *   data={[{ value: 40 }, { value: 60 }, { value: 70 }]}
 *   color={colors.emerald[500]}
 *   height={48}
 * />
 *
 * @example
 * // 詳細画面での使用（ラベルあり、大きめ）
 * <MiniBarChart
 *   data={history['7D']}
 *   color={colors.emerald[500]}
 *   height={120}
 *   showLabels
 *   animated
 * />
 */
export const MiniBarChart = ({
  data,
  color,
  height = 48,
  showLabels = false,
  maxValue = 100,
  inactiveOpacity = 0.3,
  animated = false,
  gap = 4,
  borderRadius = 2,
  style,
}): MiniBarChartProps => {
  const chartHeight = showLabels ? height - 20 : height;
  const lastIndex = data.length - 1;

  const renderBar = (item: MiniBarChartData, index: number) => {
    const heightPercentage = Math.min((item.value / maxValue) * 100, 100);
    const isLast = index === lastIndex;
    const opacity = isLast ? 1 : inactiveOpacity;

    const barStyle: ViewStyle = {
      height: `${heightPercentage}%`,
      backgroundColor: color,
      opacity,
      borderRadius,
      minHeight: 2,
    };

    if (animated) {
      return (
        <Animated.View
          key={index}
          entering={FadeInUp.delay(index * 30).duration(300)}
          style={[styles.barWrapper, { height: chartHeight }]}
        >
          <View style={barStyle} />
          {showLabels && item.label && (
            <Text style={styles.label}>{item.label}</Text>
          )}
        </Animated.View>
      );
    }

    return (
      <View key={index} style={[styles.barWrapper, { height: chartHeight }]}>
        <View style={barStyle} />
        {showLabels && item.label && (
          <Text style={styles.label}>{item.label}</Text>
        )}
      </View>
    );
  };

  return (
    <View
      style={[
        styles.container,
        { height, gap },
        style,
      ]}
    >
      {data.map(renderBar)}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
  },
  barWrapper: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  label: {
    fontSize: 10,
    fontWeight: '600',
    color: colors.stone[400],
    marginTop: 6,
    textAlign: 'center',
  },
});
