/**
 * HealthAreaChart - Health詳細用エリアチャート
 * sozai/tempoai-health-summary/components/DetailSection.tsx のチャートを再現
 */

import React, { useMemo, useState } from 'react';
import { View, Text, Dimensions, PanResponder, GestureResponderEvent } from 'react-native';
import Svg, {
  Path,
  Defs,
  LinearGradient,
  Stop,
  Rect,
  Circle,
  Line,
  Text as SvgText,
} from 'react-native-svg';
import Animated, { FadeIn, FadeOut } from 'react-native-reanimated';

import { colors } from '../theme';

export interface ChartDataPoint {
  day: string;
  value: number;
}

interface HealthAreaChartProps {
  data: ChartDataPoint[];
  colorHex: string;
  typicalRange: { min: number; max: number };
  unit: string;
  width?: number;
  height?: number;
}

const PADDING_LEFT = 0;
const PADDING_RIGHT = 0;
const PADDING_TOP = 20;
const PADDING_BOTTOM = 30;

export const HealthAreaChart: React.FC<HealthAreaChartProps> = ({
  data,
  colorHex,
  typicalRange,
  unit,
  width: propWidth,
  height = 200,
}) => {
  const screenWidth = Dimensions.get('window').width;
  const width = propWidth ?? screenWidth - 48;
  const chartWidth = width - PADDING_LEFT - PADDING_RIGHT;
  const chartHeight = height - PADDING_TOP - PADDING_BOTTOM;

  const [touchedIndex, setTouchedIndex] = useState<number | null>(null);
  const [tooltipPosition, setTooltipPosition] = useState({ x: 0, y: 0 });

  // Y軸のドメインを計算（データとtypicalRangeを含む）
  const { minY, maxY } = useMemo(() => {
    const allValues = data.map((d) => d.value);
    const minVal = Math.min(...allValues, typicalRange.min) * 0.95;
    const maxVal = Math.max(...allValues, typicalRange.max) * 1.05;
    return { minY: minVal, maxY: maxVal };
  }, [data, typicalRange]);

  const yRange = maxY - minY;

  // データポイントの座標を計算
  const points = useMemo(() => {
    return data.map((d, index) => {
      const x = PADDING_LEFT + (index / (data.length - 1)) * chartWidth;
      const y = PADDING_TOP + chartHeight - ((d.value - minY) / yRange) * chartHeight;
      return { x, y, data: d, index };
    });
  }, [data, chartWidth, chartHeight, minY, yRange]);

  // SVGパスを生成（スムーズな曲線）
  const areaPath = useMemo(() => {
    if (points.length < 2) return '';

    let path = `M ${points[0].x} ${points[0].y}`;

    for (let i = 1; i < points.length; i++) {
      const prev = points[i - 1];
      const curr = points[i];
      const cpX = (prev.x + curr.x) / 2;
      path += ` Q ${prev.x + (cpX - prev.x) * 0.5} ${prev.y}, ${cpX} ${(prev.y + curr.y) / 2}`;
      path += ` Q ${cpX + (curr.x - cpX) * 0.5} ${curr.y}, ${curr.x} ${curr.y}`;
    }

    // エリアを閉じる
    path += ` L ${points[points.length - 1].x} ${PADDING_TOP + chartHeight}`;
    path += ` L ${points[0].x} ${PADDING_TOP + chartHeight}`;
    path += ' Z';

    return path;
  }, [points, chartHeight]);

  // ラインパスを生成
  const linePath = useMemo(() => {
    if (points.length < 2) return '';

    let path = `M ${points[0].x} ${points[0].y}`;

    for (let i = 1; i < points.length; i++) {
      const prev = points[i - 1];
      const curr = points[i];
      const cpX = (prev.x + curr.x) / 2;
      path += ` Q ${prev.x + (cpX - prev.x) * 0.5} ${prev.y}, ${cpX} ${(prev.y + curr.y) / 2}`;
      path += ` Q ${cpX + (curr.x - cpX) * 0.5} ${curr.y}, ${curr.x} ${curr.y}`;
    }

    return path;
  }, [points]);

  // Typical Rangeのバンド位置
  const typicalRangeBand = useMemo(() => {
    const y1 = PADDING_TOP + chartHeight - ((typicalRange.max - minY) / yRange) * chartHeight;
    const y2 = PADDING_TOP + chartHeight - ((typicalRange.min - minY) / yRange) * chartHeight;
    return { y1, y2, height: y2 - y1 };
  }, [typicalRange, chartHeight, minY, yRange]);

  // タッチハンドリング
  const findClosestPoint = (touchX: number) => {
    let closest = points[0];
    let minDist = Math.abs(touchX - points[0].x);

    for (const point of points) {
      const dist = Math.abs(touchX - point.x);
      if (dist < minDist) {
        minDist = dist;
        closest = point;
      }
    }

    return closest;
  };

  const handleTouch = (evt: GestureResponderEvent) => {
    const touchX = evt.nativeEvent.locationX;
    const closest = findClosestPoint(touchX);
    setTouchedIndex(closest.index);
    setTooltipPosition({ x: closest.x, y: closest.y });
  };

  const panResponder = useMemo(
    () =>
      PanResponder.create({
        onStartShouldSetPanResponder: () => true,
        onMoveShouldSetPanResponder: () => true,
        onPanResponderGrant: handleTouch,
        onPanResponderMove: handleTouch,
        onPanResponderRelease: () => setTouchedIndex(null),
        onPanResponderTerminate: () => setTouchedIndex(null),
      }),
    [points]
  );

  const chartId = `healthChart_${Math.random().toString(36).substr(2, 9)}`;

  return (
    <View className="relative">
      <View {...panResponder.panHandlers}>
        <Svg width={width} height={height}>
          <Defs>
            <LinearGradient id={`areaGradient_${chartId}`} x1="0" y1="0" x2="0" y2="1">
              <Stop offset="5%" stopColor={colorHex} stopOpacity={0.1} />
              <Stop offset="95%" stopColor={colorHex} stopOpacity={0} />
            </LinearGradient>
          </Defs>

          {/* Typical Range Band */}
          <Rect
            x={PADDING_LEFT}
            y={typicalRangeBand.y1}
            width={chartWidth}
            height={typicalRangeBand.height}
            fill={colorHex}
            fillOpacity={0.08}
          />

          {/* エリア塗りつぶし */}
          <Path d={areaPath} fill={`url(#areaGradient_${chartId})`} />

          {/* ライン */}
          <Path d={linePath} stroke={colorHex} strokeWidth={3} fill="none" />

          {/* タッチ時のカーソル線 */}
          {touchedIndex !== null && (
            <Line
              x1={tooltipPosition.x}
              y1={PADDING_TOP}
              x2={tooltipPosition.x}
              y2={PADDING_TOP + chartHeight}
              stroke={colorHex}
              strokeWidth={1}
              strokeDasharray="4 4"
            />
          )}

          {/* データポイント */}
          {points.map((point, index) => {
            const isLast = index === points.length - 1;
            return (
              <Circle
                key={index}
                cx={point.x}
                cy={point.y}
                r={isLast ? 5 : 3}
                fill={colorHex}
                stroke="white"
                strokeWidth={2}
              />
            );
          })}

          {/* X軸ラベル */}
          {points.map((point, index) => (
            <SvgText
              key={index}
              x={point.x}
              y={height - 8}
              fontSize={11}
              fontWeight="500"
              fill={colors.stone[400]}
              textAnchor="middle"
            >
              {point.data.day}
            </SvgText>
          ))}
        </Svg>
      </View>

      {/* タッチ時のツールチップ */}
      {touchedIndex !== null && (
        <Animated.View
          entering={FadeIn.duration(150)}
          exiting={FadeOut.duration(150)}
          className="absolute"
          style={{
            left: tooltipPosition.x - 35,
            top: tooltipPosition.y - 45,
          }}
        >
          <View
            className="bg-white p-2 rounded-lg border border-stone-100 items-center"
            style={{
              shadowColor: '#000',
              shadowOffset: { width: 0, height: 4 },
              shadowOpacity: 0.1,
              shadowRadius: 12,
              elevation: 4,
            }}
          >
            <Text className="text-stone-800 text-sm font-semibold">
              {data[touchedIndex].value}
              {unit}
            </Text>
          </View>
        </Animated.View>
      )}
    </View>
  );
};
