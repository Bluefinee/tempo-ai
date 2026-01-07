/**
 * RhythmInteractiveChart - タッチ対応リズムチャート
 * スムーズなドラッグ操作でツールチップ表示
 */

import React, { useState, useCallback, useMemo, useRef } from "react";
import {
  View,
  Text,
  useWindowDimensions,
  StyleSheet,
  PanResponder,
} from "react-native";
import Svg, {
  Path,
  Defs,
  LinearGradient,
  Stop,
  Line,
  Circle,
  Text as SvgText,
} from "react-native-svg";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  runOnJS,
} from "react-native-reanimated";

import { Colors } from "../theme";

export interface RhythmDataPoint {
  time: string;
  hour: number;
  energy: number;
  label?: string;
}

interface RhythmInteractiveChartProps {
  data: RhythmDataPoint[];
  currentHour: number;
  width?: number;
  height?: number;
}

const PADDING_LEFT = 16;
const PADDING_RIGHT = 16;
const PADDING_TOP = 50;
const PADDING_BOTTOM = 35;

export const RhythmInteractiveChart = ({
  data,
  currentHour,
  width: propWidth,
  height = 280,
}: RhythmInteractiveChartProps): React.ReactElement => {
  const screenWidth = useWindowDimensions().width;
  const width = propWidth ?? screenWidth;
  const chartWidth = width - PADDING_LEFT - PADDING_RIGHT;
  const chartHeight = height - PADDING_TOP - PADDING_BOTTOM;

  const [touchedIndex, setTouchedIndex] = useState<number | null>(null);
  const [isDragging, setIsDragging] = useState(false);
  const hideTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // アニメーション用
  const tooltipOpacity = useSharedValue(0);
  const tooltipScale = useSharedValue(0.8);
  const cursorOpacity = useSharedValue(0);

  // データポイントの座標を計算
  const points = useMemo(() => {
    if (data.length === 0) return [];
    const minHour = Math.min(...data.map((d) => d.hour));
    const maxHour = Math.max(...data.map((d) => d.hour));
    const hourRange = maxHour - minHour || 1;

    return data.map((d, index) => {
      const x = PADDING_LEFT + ((d.hour - minHour) / hourRange) * chartWidth;
      const y = PADDING_TOP + chartHeight - (d.energy / 100) * chartHeight;
      return { x, y, data: d, index };
    });
  }, [data, chartWidth, chartHeight]);

  // Catmull-Rom スプラインを三次ベジェ曲線に変換して滑らかな曲線を生成
  const generateSmoothPath = useCallback(
    (pts: typeof points, closePath: boolean) => {
      if (pts.length < 2) return "";

      // Catmull-Rom to Bezier conversion
      const tension = 0.3; // 曲線の張り具合（0-1、小さいほど滑らか）

      let path = `M ${pts[0].x} ${pts[0].y}`;

      for (let i = 0; i < pts.length - 1; i++) {
        const p0 = pts[Math.max(0, i - 1)];
        const p1 = pts[i];
        const p2 = pts[i + 1];
        const p3 = pts[Math.min(pts.length - 1, i + 2)];

        // コントロールポイントを計算
        const cp1x = p1.x + ((p2.x - p0.x) * tension) / 2;
        const cp1y = p1.y + ((p2.y - p0.y) * tension) / 2;
        const cp2x = p2.x - ((p3.x - p1.x) * tension) / 2;
        const cp2y = p2.y - ((p3.y - p1.y) * tension) / 2;

        path += ` C ${cp1x} ${cp1y}, ${cp2x} ${cp2y}, ${p2.x} ${p2.y}`;
      }

      if (closePath) {
        // エリアを閉じる
        path += ` L ${pts[pts.length - 1].x} ${PADDING_TOP + chartHeight}`;
        path += ` L ${pts[0].x} ${PADDING_TOP + chartHeight}`;
        path += " Z";
      }

      return path;
    },
    [chartHeight],
  );

  // SVGパスを生成（スムーズな曲線）
  const areaPath = useMemo(() => {
    return generateSmoothPath(points, true);
  }, [points, generateSmoothPath]);

  // ラインパスを生成
  const linePath = useMemo(() => {
    return generateSmoothPath(points, false);
  }, [points, generateSmoothPath]);

  // 現在時刻の位置を計算
  const currentTimePosition = useMemo(() => {
    if (data.length === 0) return { x: 0, y: 0, energy: 0 };
    const minHour = Math.min(...data.map((d) => d.hour));
    const maxHour = Math.max(...data.map((d) => d.hour));
    const hourRange = maxHour - minHour || 1;

    const x = PADDING_LEFT + ((currentHour - minHour) / hourRange) * chartWidth;

    // 現在時刻に最も近いデータポイントのエネルギーを取得
    const closestPoint = data.reduce((prev, curr) => {
      return Math.abs(curr.hour - currentHour) <
        Math.abs(prev.hour - currentHour)
        ? curr
        : prev;
    });
    const y =
      PADDING_TOP + chartHeight - (closestPoint.energy / 100) * chartHeight;

    return { x, y, energy: closestPoint.energy };
  }, [data, currentHour, chartWidth, chartHeight]);

  // ピークとディップの位置を取得
  const annotations = useMemo(() => {
    const peak = points.find(
      (p) => p.data.label === "Peak" || p.data.label === "ピーク",
    );
    const dip = points.find(
      (p) => p.data.label === "Dip" || p.data.label === "低迷期",
    );
    return { peak, dip };
  }, [points]);

  // タッチ位置から最も近いポイントを見つける
  const findClosestPoint = useCallback(
    (touchX: number) => {
      if (points.length === 0) return null;

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
    },
    [points],
  );

  // ツールチップを表示
  const showTooltip = useCallback(
    (index: number) => {
      if (hideTimeoutRef.current) {
        clearTimeout(hideTimeoutRef.current);
        hideTimeoutRef.current = null;
      }
      setTouchedIndex(index);
      tooltipOpacity.value = withSpring(1, { damping: 20, stiffness: 300 });
      tooltipScale.value = withSpring(1, { damping: 15, stiffness: 400 });
      cursorOpacity.value = withTiming(1, { duration: 100 });
    },
    [tooltipOpacity, tooltipScale, cursorOpacity],
  );

  // ツールチップを非表示
  const hideTooltip = useCallback(() => {
    hideTimeoutRef.current = setTimeout(() => {
      tooltipOpacity.value = withTiming(0, { duration: 200 });
      tooltipScale.value = withTiming(0.8, { duration: 200 });
      cursorOpacity.value = withTiming(0, { duration: 150 });
      setTouchedIndex(null);
      setIsDragging(false);
    }, 1500);
  }, [tooltipOpacity, tooltipScale, cursorOpacity]);

  // PanResponder でドラッグ操作を処理
  const panResponder = useMemo(
    () =>
      PanResponder.create({
        onStartShouldSetPanResponder: () => true,
        onMoveShouldSetPanResponder: () => true,
        onPanResponderGrant: (evt) => {
          const touchX = evt.nativeEvent.locationX;
          const closest = findClosestPoint(touchX);
          if (closest) {
            runOnJS(setIsDragging)(true);
            runOnJS(showTooltip)(closest.index);
          }
        },
        onPanResponderMove: (evt) => {
          const touchX = evt.nativeEvent.locationX;
          const closest = findClosestPoint(touchX);
          if (closest && closest.index !== touchedIndex) {
            runOnJS(showTooltip)(closest.index);
          }
        },
        onPanResponderRelease: () => {
          runOnJS(hideTooltip)();
        },
        onPanResponderTerminate: () => {
          runOnJS(hideTooltip)();
        },
      }),
    [findClosestPoint, showTooltip, hideTooltip, touchedIndex],
  );

  // X軸ラベル
  const xAxisLabels = useMemo(() => {
    if (data.length === 0) return [];
    const labels = ["6 AM", "12 PM", "6 PM", "12 AM"];
    const minHour = Math.min(...data.map((d) => d.hour));
    const maxHour = Math.max(...data.map((d) => d.hour));
    const hourRange = maxHour - minHour || 1;

    return labels.map((label, index) => {
      const hour = 6 + index * 6;
      const x = PADDING_LEFT + ((hour - minHour) / hourRange) * chartWidth;
      return { label, x };
    });
  }, [data, chartWidth]);

  // 現在時刻をフォーマット
  const formatCurrentTime = () => {
    const hours = Math.floor(currentHour);
    const minutes = Math.round((currentHour - hours) * 60);
    const period = hours >= 12 ? "PM" : "AM";
    const displayHours = hours > 12 ? hours - 12 : hours === 0 ? 12 : hours;
    return `${displayHours}:${minutes.toString().padStart(2, "0")} ${period}`;
  };

  // アニメーションスタイル
  const tooltipAnimatedStyle = useAnimatedStyle(() => ({
    opacity: tooltipOpacity.value,
    transform: [{ scale: tooltipScale.value }],
  }));

  // タッチ中のポイントのY座標を計算
  const touchedPoint = touchedIndex !== null ? points[touchedIndex] : null;

  return (
    <View style={styles.container}>
      <View style={styles.chartContainer} {...panResponder.panHandlers}>
        <Svg width={width} height={height}>
          <Defs>
            <LinearGradient id="areaGradient" x1="0" y1="0" x2="0" y2="1">
              <Stop
                offset="0%"
                stopColor={Colors.indigo[400]}
                stopOpacity={0.3}
              />
              <Stop
                offset="100%"
                stopColor={Colors.indigo[400]}
                stopOpacity={0.02}
              />
            </LinearGradient>
            <LinearGradient id="lineGradient" x1="0" y1="0" x2="1" y2="0">
              <Stop offset="0%" stopColor={Colors.indigo[400]} />
              <Stop offset="100%" stopColor={Colors.indigo[500]} />
            </LinearGradient>
            <LinearGradient id="cursorGradient" x1="0" y1="0" x2="0" y2="1">
              <Stop
                offset="0%"
                stopColor={Colors.indigo[400]}
                stopOpacity={0.8}
              />
              <Stop
                offset="100%"
                stopColor={Colors.indigo[400]}
                stopOpacity={0.1}
              />
            </LinearGradient>
          </Defs>

          {/* エリア塗りつぶし */}
          <Path d={areaPath} fill="url(#areaGradient)" />

          {/* ライン */}
          <Path
            d={linePath}
            stroke="url(#lineGradient)"
            strokeWidth={3.5}
            fill="none"
          />

          {/* 現在時刻のインジケーター */}
          {!isDragging && (
            <>
              <Line
                x1={currentTimePosition.x}
                y1={PADDING_TOP}
                x2={currentTimePosition.x}
                y2={PADDING_TOP + chartHeight}
                stroke={Colors.amber[400]}
                strokeWidth={2}
                strokeDasharray="6 4"
              />
              <Circle
                cx={currentTimePosition.x}
                cy={currentTimePosition.y}
                r={8}
                fill={Colors.amber[400]}
                stroke="white"
                strokeWidth={3}
              />
            </>
          )}

          {/* ピークポイント */}
          {annotations.peak && !isDragging && (
            <Circle
              cx={annotations.peak.x}
              cy={annotations.peak.y}
              r={5}
              fill={Colors.indigo[500]}
              stroke="white"
              strokeWidth={2}
            />
          )}

          {/* ディップポイント */}
          {annotations.dip && !isDragging && (
            <Circle
              cx={annotations.dip.x}
              cy={annotations.dip.y}
              r={5}
              fill={Colors.stone[400]}
              stroke="white"
              strokeWidth={2}
            />
          )}

          {/* タッチ時のカーソル線 */}
          {touchedPoint && (
            <Line
              x1={touchedPoint.x}
              y1={PADDING_TOP}
              x2={touchedPoint.x}
              y2={PADDING_TOP + chartHeight}
              stroke="url(#cursorGradient)"
              strokeWidth={2}
            />
          )}

          {/* タッチ時のドット（曲線上） */}
          {touchedPoint && (
            <>
              {/* 外側のグロー */}
              <Circle
                cx={touchedPoint.x}
                cy={touchedPoint.y}
                r={16}
                fill={Colors.indigo[400]}
                opacity={0.2}
              />
              {/* 中間のリング */}
              <Circle
                cx={touchedPoint.x}
                cy={touchedPoint.y}
                r={10}
                fill={Colors.indigo[400]}
                opacity={0.4}
              />
              {/* 内側のドット */}
              <Circle
                cx={touchedPoint.x}
                cy={touchedPoint.y}
                r={6}
                fill={Colors.indigo[500]}
                stroke="white"
                strokeWidth={2}
              />
            </>
          )}

          {/* X軸ラベル */}
          {xAxisLabels.map((item, index) => (
            <SvgText
              key={index}
              x={item.x}
              y={height - 10}
              fontSize={11}
              fontWeight="500"
              fill={Colors.stone[400]}
              textAnchor="middle"
            >
              {item.label}
            </SvgText>
          ))}
        </Svg>

        {/* 「Now」ラベル - チャート上部に表示 */}
        {!isDragging && (
          <View
            style={[
              styles.nowLabel,
              {
                left: Math.max(
                  8,
                  Math.min(currentTimePosition.x - 55, width - 120),
                ),
                top: 8,
              },
            ]}
          >
            <View style={styles.nowLabelInner}>
              <Text style={styles.nowLabelText}>Now {formatCurrentTime()}</Text>
            </View>
          </View>
        )}

        {/* ピークフォーカスバッジ - ポイントの下に表示 */}
        {annotations.peak && !isDragging && (
          <View
            style={[
              styles.badge,
              {
                left: Math.max(
                  8,
                  Math.min(annotations.peak.x - 40, width - 90),
                ),
                top: annotations.peak.y + 15,
              },
            ]}
          >
            <View style={[styles.badgeInner, styles.peakBadge]}>
              <Text style={styles.peakBadgeText}>Peak Focus</Text>
            </View>
          </View>
        )}

        {/* アフタヌーンディップバッジ - ポイントの下に表示 */}
        {annotations.dip && !isDragging && (
          <View
            style={[
              styles.badge,
              {
                left: Math.max(
                  8,
                  Math.min(annotations.dip.x - 48, width - 110),
                ),
                top: annotations.dip.y + 15,
              },
            ]}
          >
            <View style={[styles.badgeInner, styles.dipBadge]}>
              <Text style={styles.dipBadgeText}>Afternoon Dip</Text>
            </View>
          </View>
        )}

        {/* タッチ時のツールチップ */}
        {touchedPoint && touchedIndex !== null && (
          <Animated.View
            style={[
              styles.tooltip,
              {
                left: Math.max(8, Math.min(touchedPoint.x - 50, width - 110)),
                top: Math.max(8, touchedPoint.y - 75),
              },
              tooltipAnimatedStyle,
            ]}
          >
            <View style={styles.tooltipInner}>
              <Text style={styles.tooltipTime}>{data[touchedIndex].time}</Text>
              <View style={styles.tooltipEnergyContainer}>
                <View style={styles.tooltipEnergyBar}>
                  <View
                    style={[
                      styles.tooltipEnergyFill,
                      { width: `${data[touchedIndex].energy}%` },
                    ]}
                  />
                </View>
                <Text style={styles.tooltipEnergy}>
                  {data[touchedIndex].energy}%
                </Text>
              </View>
            </View>
          </Animated.View>
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  chartContainer: {
    position: "relative",
  },
  nowLabel: {
    position: "absolute",
  },
  nowLabelInner: {
    backgroundColor: Colors.amber[400],
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    shadowColor: Colors.amber[500],
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.35,
    shadowRadius: 6,
    elevation: 4,
  },
  nowLabelText: {
    color: Colors.white,
    fontSize: 12,
    fontWeight: "700",
  },
  badge: {
    position: "absolute",
  },
  badgeInner: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 14,
    borderWidth: 1,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.08,
    shadowRadius: 3,
    elevation: 2,
  },
  peakBadge: {
    backgroundColor: Colors.indigo[50],
    borderColor: Colors.indigo[100],
  },
  peakBadgeText: {
    color: Colors.indigo[600],
    fontSize: 11,
    fontWeight: "600",
  },
  dipBadge: {
    backgroundColor: Colors.stone[50],
    borderColor: Colors.stone[200],
  },
  dipBadgeText: {
    color: Colors.stone[500],
    fontSize: 11,
    fontWeight: "500",
  },
  tooltip: {
    position: "absolute",
  },
  tooltipInner: {
    backgroundColor: "rgba(255, 255, 255, 0.98)",
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: Colors.stone[100],
    alignItems: "center",
    shadowColor: Colors.indigo[500],
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.2,
    shadowRadius: 20,
    elevation: 8,
    minWidth: 100,
  },
  tooltipTime: {
    color: Colors.stone[800],
    fontSize: 15,
    fontWeight: "700",
    marginBottom: 8,
  },
  tooltipEnergyContainer: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
  },
  tooltipEnergyBar: {
    width: 50,
    height: 6,
    backgroundColor: Colors.stone[100],
    borderRadius: 3,
    overflow: "hidden",
  },
  tooltipEnergyFill: {
    height: "100%",
    backgroundColor: Colors.indigo[500],
    borderRadius: 3,
  },
  tooltipEnergy: {
    color: Colors.indigo[500],
    fontSize: 13,
    fontWeight: "700",
  },
});
