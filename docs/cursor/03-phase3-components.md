# Phase 3: 共通コンポーネント

## 目的

- 新UI用の共通コンポーネントを作成
- WaveScore、MetricCard、MetricDetail、BottomSheet、RhythmGraph、BreathingCircle

---

## 開始前に読むべきドキュメント

**必ず以下のドキュメントを全て読んでから実装を開始すること:**

| ドキュメント | パス | 確認ポイント |
|-------------|------|-------------|
| CLAUDE.md | `/CLAUDE.md` | コンポーネント設計、コメントポリシー |
| React Native規約 | `/.claude/react-native-standards.md` | **コンポーネント設計パターン、Props型定義、スタイル定義** |
| UI/UX仕様 | `/docs/specs/ui_ux_design.md` | **デザイン詳細、アニメーション、Haptic Feedback、アクセシビリティ** |
| 新UIプロトタイプ | `/sozai/new/components/` | **実装リファレンス（WaveScore.tsx, MetricCard.tsx等）** |

**特に重要**:
- `/sozai/new/components/` 配下の全ファイルを読んでリファレンスとする
- `/docs/specs/ui_ux_design.md` のアクセシビリティ要件（コントラスト4.5:1、タップ領域44x44px）

---

## 依存パッケージ追加

```bash
cd app
pnpm add @gorhom/bottom-sheet expo-haptics react-native-reanimated
```

**注意**: `react-native-reanimated` が既にインストールされている場合はスキップ。

---

## Task 3.1: WaveScore コンポーネント

### `app/src/components/WaveScore.tsx` を新規作成

```typescript
/**
 * WaveScore - Tempo Score を波アニメーションで表示
 * @see docs/specs/ui_ux_design.md
 * @see sozai/new/components/WaveScore.tsx
 */

import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';
import Svg, { Path, Defs, LinearGradient, Stop, ClipPath, Rect } from 'react-native-svg';
import { Colors, Typography, Spacing } from '@/theme';

interface WaveScoreProps {
  score: number;
  size?: number;
  isCalibrating?: boolean;
}

export const WaveScore: React.FC<WaveScoreProps> = ({
  score,
  size = 200,
  isCalibrating = false,
}) => {
  const waveAnimation = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // 波アニメーション（4秒周期）
    const animation = Animated.loop(
      Animated.timing(waveAnimation, {
        toValue: 1,
        duration: 4000,
        useNativeDriver: true,
      })
    );
    animation.start();

    return () => animation.stop();
  }, [waveAnimation]);

  // スコアに基づく水位（0-100 → 0-1）
  const fillHeight = score / 100;
  const waveHeight = size * (1 - fillHeight);

  // 波のパス生成
  const generateWavePath = (phase: number): string => {
    const amplitude = 8;
    const frequency = 2;
    const points: string[] = [];

    for (let x = 0; x <= size; x += 2) {
      const y =
        waveHeight +
        amplitude * Math.sin((x / size) * Math.PI * frequency + phase * Math.PI * 2);
      points.push(x === 0 ? `M ${x} ${y}` : `L ${x} ${y}`);
    }

    // 下部を閉じる
    points.push(`L ${size} ${size}`);
    points.push(`L 0 ${size}`);
    points.push('Z');

    return points.join(' ');
  };

  return (
    <View
      style={[styles.container, { width: size, height: size }]}
      accessible
      accessibilityRole="text"
      accessibilityLabel={`Tempo Score ${score}点`}
    >
      {/* 外枠 */}
      <View style={[styles.outerRing, { width: size, height: size, borderRadius: size / 2 }]}>
        {/* 波アニメーション */}
        <Svg width={size} height={size} style={styles.svg}>
          <Defs>
            <ClipPath id="circleClip">
              <Rect x="4" y="4" width={size - 8} height={size - 8} rx={(size - 8) / 2} />
            </ClipPath>
            <LinearGradient id="waveGradient" x1="0" y1="0" x2="0" y2="1">
              <Stop offset="0%" stopColor={Colors.indigo[400]} stopOpacity="0.8" />
              <Stop offset="100%" stopColor={Colors.indigo[600]} stopOpacity="1" />
            </LinearGradient>
          </Defs>

          {/* 背景波（遅い） */}
          <Path
            d={generateWavePath(0.3)}
            fill={Colors.indigo[200]}
            opacity={0.5}
            clipPath="url(#circleClip)"
          />

          {/* 前景波 */}
          <Path
            d={generateWavePath(0)}
            fill="url(#waveGradient)"
            clipPath="url(#circleClip)"
          />
        </Svg>

        {/* スコア表示 */}
        <View style={styles.scoreContainer}>
          {isCalibrating ? (
            <Text style={styles.calibratingText}>Learning...</Text>
          ) : (
            <>
              <Text style={styles.scoreValue}>{score}</Text>
              <Text style={styles.scoreLabel}>TEMPO SCORE</Text>
            </>
          )}
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  outerRing: {
    backgroundColor: Colors.white,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
    borderWidth: 4,
    borderColor: Colors.stone[200],
  },
  svg: {
    position: 'absolute',
  },
  scoreContainer: {
    position: 'absolute',
    alignItems: 'center',
    justifyContent: 'center',
  },
  scoreValue: {
    ...Typography.scoreXL,
    color: Colors.stone[900],
  },
  scoreLabel: {
    ...Typography.label,
    color: Colors.stone[500],
    marginTop: Spacing.xs,
  },
  calibratingText: {
    ...Typography.heading3,
    color: Colors.stone[500],
  },
});
```

---

## Task 3.2: MetricCard コンポーネント

### `app/src/components/MetricCard.tsx` を新規作成

```typescript
/**
 * MetricCard - メトリクス表示カード
 * @see docs/specs/ui_ux_design.md
 * @see sozai/new/components/MetricCard.tsx
 */

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ViewStyle,
} from 'react-native';
import * as Haptics from 'expo-haptics';
import { ChevronRight } from 'lucide-react-native';
import { Colors, Typography, Spacing, BorderRadius, Shadows } from '@/theme';

type MetricType = 'sleep' | 'hrv' | 'steps';

interface MetricCardProps {
  type: MetricType;
  label: string;
  value: string;
  unit?: string;
  icon: React.ReactNode;
  onPress?: () => void;
  style?: ViewStyle;
}

const getMetricColor = (type: MetricType): string => {
  switch (type) {
    case 'sleep':
      return Colors.indigo[500];
    case 'hrv':
      return Colors.coral[400];
    case 'steps':
      return Colors.amber[500];
  }
};

const getMetricBgColor = (type: MetricType): string => {
  switch (type) {
    case 'sleep':
      return Colors.indigo[50];
    case 'hrv':
      return Colors.coral[50];
    case 'steps':
      return Colors.amber[50];
  }
};

export const MetricCard: React.FC<MetricCardProps> = ({
  type,
  label,
  value,
  unit,
  icon,
  onPress,
  style,
}) => {
  const handlePress = (): void => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    onPress?.();
  };

  const metricColor = getMetricColor(type);
  const metricBgColor = getMetricBgColor(type);

  return (
    <TouchableOpacity
      style={[styles.container, style]}
      onPress={handlePress}
      activeOpacity={0.7}
      accessible
      accessibilityRole="button"
      accessibilityLabel={`${label} ${value}${unit ?? ''}`}
      accessibilityHint="タップして詳細を表示"
    >
      {/* アイコン */}
      <View style={[styles.iconContainer, { backgroundColor: metricBgColor }]}>
        {React.cloneElement(icon as React.ReactElement, {
          color: metricColor,
          size: 20,
        })}
      </View>

      {/* ラベルと値 */}
      <View style={styles.content}>
        <Text style={styles.label}>{label}</Text>
        <View style={styles.valueRow}>
          <Text style={styles.value}>{value}</Text>
          {unit && <Text style={styles.unit}>{unit}</Text>}
        </View>
      </View>

      {/* 矢印 */}
      <ChevronRight color={Colors.stone[400]} size={20} />
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.lg,
    padding: Spacing.md,
    minHeight: 72, // アクセシビリティ: 最小タップ領域
    ...Shadows.card,
  },
  iconContainer: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.md,
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    flex: 1,
    marginLeft: Spacing.md,
  },
  label: {
    ...Typography.caption,
    color: Colors.stone[500],
  },
  valueRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
  },
  value: {
    ...Typography.heading3,
    color: Colors.stone[900],
  },
  unit: {
    ...Typography.caption,
    color: Colors.stone[500],
    marginLeft: Spacing.xs,
  },
});
```

---

## Task 3.3: BottomSheet コンポーネント

### `app/src/components/BottomSheet.tsx` を新規作成

```typescript
/**
 * BottomSheet - ボトムシートコンポーネント
 * @see docs/specs/ui_ux_design.md
 * @see sozai/new/components/BottomSheet.tsx
 */

import React, { useCallback, useMemo, forwardRef } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import BottomSheetLib, {
  BottomSheetBackdrop,
  BottomSheetView,
} from '@gorhom/bottom-sheet';
import { X } from 'lucide-react-native';
import { Colors, Typography, Spacing, BorderRadius, Shadows } from '@/theme';

interface BottomSheetProps {
  title: string;
  children: React.ReactNode;
  onClose: () => void;
}

export const BottomSheet = forwardRef<BottomSheetLib, BottomSheetProps>(
  ({ title, children, onClose }, ref) => {
    const snapPoints = useMemo(() => ['50%', '90%'], []);

    const renderBackdrop = useCallback(
      (props: Parameters<typeof BottomSheetBackdrop>[0]) => (
        <BottomSheetBackdrop
          {...props}
          disappearsOnIndex={-1}
          appearsOnIndex={0}
          opacity={0.5}
        />
      ),
      []
    );

    return (
      <BottomSheetLib
        ref={ref}
        index={-1}
        snapPoints={snapPoints}
        enablePanDownToClose
        backdropComponent={renderBackdrop}
        handleIndicatorStyle={styles.handle}
        backgroundStyle={styles.background}
        style={styles.sheet}
      >
        <BottomSheetView style={styles.content}>
          {/* ヘッダー */}
          <View style={styles.header}>
            <Text style={styles.title}>{title}</Text>
            <TouchableOpacity
              onPress={onClose}
              style={styles.closeButton}
              accessible
              accessibilityRole="button"
              accessibilityLabel="閉じる"
            >
              <X color={Colors.stone[500]} size={24} />
            </TouchableOpacity>
          </View>

          {/* コンテンツ */}
          <View style={styles.body}>{children}</View>
        </BottomSheetView>
      </BottomSheetLib>
    );
  }
);

BottomSheet.displayName = 'BottomSheet';

const styles = StyleSheet.create({
  sheet: {
    ...Shadows.bottomSheet,
  },
  background: {
    backgroundColor: Colors.white,
    borderTopLeftRadius: BorderRadius.xl,
    borderTopRightRadius: BorderRadius.xl,
  },
  handle: {
    backgroundColor: Colors.stone[300],
    width: 40,
  },
  content: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: Colors.stone[200],
  },
  title: {
    ...Typography.heading3,
    color: Colors.stone[900],
  },
  closeButton: {
    width: 44,
    height: 44,
    alignItems: 'center',
    justifyContent: 'center',
  },
  body: {
    flex: 1,
    paddingHorizontal: Spacing.lg,
    paddingTop: Spacing.lg,
  },
});
```

---

## Task 3.4: MetricDetail コンポーネント

### `app/src/components/MetricDetail.tsx` を新規作成

```typescript
/**
 * MetricDetail - メトリクス詳細（BottomSheet内コンテンツ）
 * @see docs/specs/ui_ux_design.md
 * @see sozai/new/components/MetricDetail.tsx
 */

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors, Typography, Spacing, BorderRadius } from '@/theme';
import { t } from '@/i18n';

type MetricType = 'sleep' | 'hrv' | 'steps';

interface SubMetric {
  label: string;
  value: string;
  status: string;
}

interface MetricDetailProps {
  type: MetricType;
  currentValue: string;
  currentUnit?: string;
  comparison: string;
  insight: string;
  hourlyData: readonly number[];
  subMetrics: readonly SubMetric[];
}

const getMetricColor = (type: MetricType): string => {
  switch (type) {
    case 'sleep':
      return Colors.indigo[500];
    case 'hrv':
      return Colors.coral[400];
    case 'steps':
      return Colors.amber[500];
  }
};

export const MetricDetail: React.FC<MetricDetailProps> = ({
  type,
  currentValue,
  currentUnit,
  comparison,
  insight,
  hourlyData,
  subMetrics,
}) => {
  const metricColor = getMetricColor(type);
  const maxValue = Math.max(...hourlyData, 1);

  return (
    <View style={styles.container}>
      {/* Current Status */}
      <View style={styles.section}>
        <Text style={styles.sectionLabel}>CURRENT STATUS</Text>
        <View style={styles.currentValueRow}>
          <Text style={styles.currentValue}>{currentValue}</Text>
          {currentUnit && <Text style={styles.currentUnit}>{currentUnit}</Text>}
        </View>
        <Text style={styles.comparison}>{comparison}</Text>
      </View>

      {/* Bar Graph */}
      <View style={styles.section}>
        <View style={styles.barGraph}>
          {hourlyData.map((value, index) => (
            <View
              key={index}
              style={[
                styles.bar,
                {
                  height: `${(value / maxValue) * 100}%`,
                  backgroundColor: metricColor,
                },
              ]}
            />
          ))}
        </View>
        <View style={styles.timeLabels}>
          <Text style={styles.timeLabel}>12h ago</Text>
          <Text style={styles.timeLabel}>Now</Text>
        </View>
      </View>

      {/* Tempo Insight */}
      <View style={[styles.section, styles.insightBox]}>
        <Text style={styles.insightLabel}>Tempo Insight</Text>
        <Text style={styles.insightText}>{insight}</Text>
      </View>

      {/* Sub Metrics */}
      <View style={styles.subMetricsGrid}>
        {subMetrics.map((metric, index) => (
          <View key={index} style={styles.subMetricItem}>
            <Text style={styles.subMetricLabel}>{metric.label}</Text>
            <Text style={styles.subMetricValue}>{metric.value}</Text>
            <Text style={styles.subMetricStatus}>{metric.status}</Text>
          </View>
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  section: {
    marginBottom: Spacing.lg,
  },
  sectionLabel: {
    ...Typography.label,
    color: Colors.stone[500],
    marginBottom: Spacing.sm,
  },
  currentValueRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
  },
  currentValue: {
    ...Typography.scoreLG,
    color: Colors.stone[900],
  },
  currentUnit: {
    ...Typography.heading3,
    color: Colors.stone[500],
    marginLeft: Spacing.xs,
  },
  comparison: {
    ...Typography.caption,
    color: Colors.stone[500],
    marginTop: Spacing.xs,
  },
  barGraph: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    height: 100,
    gap: 4,
  },
  bar: {
    flex: 1,
    borderRadius: 2,
    minHeight: 4,
  },
  timeLabels: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: Spacing.xs,
  },
  timeLabel: {
    ...Typography.caption,
    color: Colors.stone[400],
  },
  insightBox: {
    backgroundColor: Colors.stone[50],
    borderRadius: BorderRadius.md,
    padding: Spacing.md,
  },
  insightLabel: {
    ...Typography.label,
    color: Colors.stone[500],
    marginBottom: Spacing.xs,
  },
  insightText: {
    ...Typography.body,
    color: Colors.stone[700],
  },
  subMetricsGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  subMetricItem: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: Spacing.md,
  },
  subMetricLabel: {
    ...Typography.caption,
    color: Colors.stone[500],
  },
  subMetricValue: {
    ...Typography.heading3,
    color: Colors.stone[900],
    marginTop: Spacing.xs,
  },
  subMetricStatus: {
    ...Typography.caption,
    color: Colors.emerald[500],
    marginTop: Spacing.xs,
  },
});
```

---

## Task 3.5: RhythmGraph コンポーネント

### `app/src/components/RhythmGraph.tsx` を新規作成

```typescript
/**
 * RhythmGraph - サーカディアンリズムグラフ
 * @see docs/specs/ui_ux_design.md
 * @see sozai/new/screens/RhythmScreen.tsx
 */

import React from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import Svg, { Path, Line, Circle } from 'react-native-svg';
import { Colors, Typography, Spacing } from '@/theme';
import { EnergyCurve } from '@/domain/models/rhythm';

interface RhythmGraphProps {
  energyCurve: EnergyCurve;
  currentHour: number;
  labels?: readonly { hour: number; text: string }[];
}

const { width: screenWidth } = Dimensions.get('window');
const GRAPH_HEIGHT = 200;
const GRAPH_PADDING = 20;

export const RhythmGraph: React.FC<RhythmGraphProps> = ({
  energyCurve,
  currentHour,
  labels = [],
}) => {
  const graphWidth = screenWidth - Spacing.lg * 2;

  // エネルギー曲線のパス生成
  const generatePath = (): string => {
    const points = energyCurve.map((point, index) => {
      const x = (index / 23) * (graphWidth - GRAPH_PADDING * 2) + GRAPH_PADDING;
      const y = GRAPH_HEIGHT - (point.level / 100) * (GRAPH_HEIGHT - 40) - 20;
      return { x, y };
    });

    // スムーズな曲線を生成（Catmull-Rom spline approximation）
    let path = `M ${points[0].x} ${points[0].y}`;

    for (let i = 0; i < points.length - 1; i++) {
      const p0 = points[Math.max(i - 1, 0)];
      const p1 = points[i];
      const p2 = points[i + 1];
      const p3 = points[Math.min(i + 2, points.length - 1)];

      const cp1x = p1.x + (p2.x - p0.x) / 6;
      const cp1y = p1.y + (p2.y - p0.y) / 6;
      const cp2x = p2.x - (p3.x - p1.x) / 6;
      const cp2y = p2.y - (p3.y - p1.y) / 6;

      path += ` C ${cp1x} ${cp1y}, ${cp2x} ${cp2y}, ${p2.x} ${p2.y}`;
    }

    return path;
  };

  // 現在時刻の位置
  const currentX = (currentHour / 23) * (graphWidth - GRAPH_PADDING * 2) + GRAPH_PADDING;
  const currentPoint = energyCurve.find((p) => p.hour === currentHour);
  const currentY = currentPoint
    ? GRAPH_HEIGHT - (currentPoint.level / 100) * (GRAPH_HEIGHT - 40) - 20
    : GRAPH_HEIGHT / 2;

  return (
    <View style={styles.container}>
      <Svg width={graphWidth} height={GRAPH_HEIGHT}>
        {/* 背景グリッド線 */}
        {[0, 6, 12, 18].map((hour) => {
          const x = (hour / 23) * (graphWidth - GRAPH_PADDING * 2) + GRAPH_PADDING;
          return (
            <Line
              key={hour}
              x1={x}
              y1={20}
              x2={x}
              y2={GRAPH_HEIGHT - 20}
              stroke={Colors.stone[200]}
              strokeWidth={1}
              strokeDasharray="4,4"
            />
          );
        })}

        {/* エネルギー曲線 */}
        <Path
          d={generatePath()}
          fill="none"
          stroke={Colors.indigo[500]}
          strokeWidth={3}
          strokeLinecap="round"
        />

        {/* 現在時刻インジケーター */}
        <Line
          x1={currentX}
          y1={20}
          x2={currentX}
          y2={GRAPH_HEIGHT - 20}
          stroke={Colors.amber[500]}
          strokeWidth={2}
        />
        <Circle cx={currentX} cy={currentY} r={6} fill={Colors.amber[500]} />
      </Svg>

      {/* 時間軸ラベル */}
      <View style={styles.timeAxis}>
        <Text style={styles.timeLabel}>6 AM</Text>
        <Text style={styles.timeLabel}>12 PM</Text>
        <Text style={styles.timeLabel}>6 PM</Text>
        <Text style={styles.timeLabel}>12 AM</Text>
      </View>

      {/* フェーズラベル */}
      {labels.map((label, index) => {
        const x = (label.hour / 23) * (graphWidth - GRAPH_PADDING * 2) + GRAPH_PADDING;
        return (
          <View
            key={index}
            style={[styles.phaseLabel, { left: x - 40 }]}
          >
            <Text style={styles.phaseLabelText}>{label.text}</Text>
          </View>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'relative',
  },
  timeAxis: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: GRAPH_PADDING,
    marginTop: Spacing.sm,
  },
  timeLabel: {
    ...Typography.caption,
    color: Colors.stone[500],
  },
  phaseLabel: {
    position: 'absolute',
    top: 30,
    width: 80,
    alignItems: 'center',
  },
  phaseLabelText: {
    ...Typography.label,
    color: Colors.indigo[600],
    backgroundColor: Colors.indigo[50],
    paddingHorizontal: Spacing.sm,
    paddingVertical: Spacing.xs,
    borderRadius: 4,
    overflow: 'hidden',
  },
});
```

---

## Task 3.6: BreathingCircle コンポーネント

### `app/src/components/BreathingCircle.tsx` を新規作成

```typescript
/**
 * BreathingCircle - 呼吸エクササイズ用アニメーション
 * @see docs/specs/ui_ux_design.md
 * @see sozai/new/screens/BreatheScreen.tsx
 */

import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';
import * as Haptics from 'expo-haptics';
import { Colors, Typography, Spacing } from '@/theme';
import { t } from '@/i18n';

type BreathePhase = 'idle' | 'inhale' | 'hold' | 'exhale';

interface BreathingCircleProps {
  phase: BreathePhase;
  size?: number;
  hapticEnabled?: boolean;
}

const PHASE_DURATIONS = {
  inhale: 4000,
  hold: 7000,
  exhale: 8000,
};

export const BreathingCircle: React.FC<BreathingCircleProps> = ({
  phase,
  size = 200,
  hapticEnabled = true,
}) => {
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const glowAnim = useRef(new Animated.Value(0.5)).current;

  useEffect(() => {
    // フェーズ変更時のHapticフィードバック
    if (hapticEnabled && phase !== 'idle') {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    }

    let scaleAnimation: Animated.CompositeAnimation | null = null;
    let glowAnimation: Animated.CompositeAnimation | null = null;

    switch (phase) {
      case 'inhale':
        scaleAnimation = Animated.timing(scaleAnim, {
          toValue: 1.3,
          duration: PHASE_DURATIONS.inhale,
          useNativeDriver: true,
        });
        glowAnimation = Animated.timing(glowAnim, {
          toValue: 1,
          duration: PHASE_DURATIONS.inhale,
          useNativeDriver: true,
        });
        break;

      case 'hold':
        // 維持
        break;

      case 'exhale':
        scaleAnimation = Animated.timing(scaleAnim, {
          toValue: 1,
          duration: PHASE_DURATIONS.exhale,
          useNativeDriver: true,
        });
        glowAnimation = Animated.timing(glowAnim, {
          toValue: 0.5,
          duration: PHASE_DURATIONS.exhale,
          useNativeDriver: true,
        });
        break;

      case 'idle':
      default:
        scaleAnim.setValue(1);
        glowAnim.setValue(0.5);
        break;
    }

    if (scaleAnimation) {
      scaleAnimation.start();
    }
    if (glowAnimation) {
      glowAnimation.start();
    }

    return () => {
      scaleAnimation?.stop();
      glowAnimation?.stop();
    };
  }, [phase, scaleAnim, glowAnim, hapticEnabled]);

  const getPhaseText = (): string => {
    switch (phase) {
      case 'inhale':
        return t('screen.breathe.inhale');
      case 'hold':
        return t('screen.breathe.hold');
      case 'exhale':
        return t('screen.breathe.exhale');
      default:
        return t('screen.breathe.tapToStart');
    }
  };

  return (
    <View style={[styles.container, { width: size * 1.5, height: size * 1.5 }]}>
      {/* グロー効果 */}
      <Animated.View
        style={[
          styles.glow,
          {
            width: size * 1.4,
            height: size * 1.4,
            borderRadius: size * 0.7,
            opacity: glowAnim,
            transform: [{ scale: scaleAnim }],
          },
        ]}
      />

      {/* メインサークル */}
      <Animated.View
        style={[
          styles.circle,
          {
            width: size,
            height: size,
            borderRadius: size / 2,
            transform: [{ scale: scaleAnim }],
          },
        ]}
      >
        <Text style={styles.phaseText}>{getPhaseText()}</Text>
      </Animated.View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  glow: {
    position: 'absolute',
    backgroundColor: Colors.indigo[400],
  },
  circle: {
    backgroundColor: Colors.indigo[500],
    alignItems: 'center',
    justifyContent: 'center',
  },
  phaseText: {
    ...Typography.heading2,
    color: Colors.white,
  },
});
```

---

## Task 3.7: コンポーネント index 更新

### `app/src/components/index.ts` を更新

```typescript
// 既存のエクスポート
export * from './Card';
export * from './PrimaryButton';
export * from './SecondaryButton';
export * from './InputField';
export * from './ProgressBar';
export * from './ScoreGauge';
export * from './LoadingView';

// 新規コンポーネント
export * from './WaveScore';
export * from './MetricCard';
export * from './MetricDetail';
export * from './BottomSheet';
export * from './RhythmGraph';
export * from './BreathingCircle';
```

---

## Phase 3 完了時の検証

### 必須コマンド（全てパスすること）

```bash
cd app

# 1. 型チェック
pnpm typecheck

# 2. リント
pnpm lint

# 3. テスト実行
pnpm test

# 4. iOS ビルド
pnpm ios --no-dev

# 5. Android ビルド
pnpm android --no-dev
```

### 完了チェックリスト

- [ ] `@gorhom/bottom-sheet` と `expo-haptics` がインストールされている
- [ ] `app/src/components/WaveScore.tsx` が作成されている
- [ ] `app/src/components/MetricCard.tsx` が作成されている
- [ ] `app/src/components/MetricDetail.tsx` が作成されている
- [ ] `app/src/components/BottomSheet.tsx` が作成されている
- [ ] `app/src/components/RhythmGraph.tsx` が作成されている
- [ ] `app/src/components/BreathingCircle.tsx` が作成されている
- [ ] `app/src/components/index.ts` が更新されている
- [ ] 全コンポーネントに `accessibilityRole` と `accessibilityLabel` がある
- [ ] タップ可能な要素の最小サイズが 44x44px 以上
- [ ] **`pnpm typecheck` でエラーなし**
- [ ] **`pnpm lint` でエラーなし**
- [ ] **`pnpm test` で全テストパス**
- [ ] **iOS ビルドが成功する**
- [ ] **Android ビルドが成功する**

---

## 次のフェーズ

Phase 3 の全てのチェックが完了したら、`04-phase4-stores.md` に進む。
