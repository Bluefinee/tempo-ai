/**
 * HealthDetailScreen - Health詳細画面
 * sozai/tempoai-health-summary/ を React Native で完全再現
 */

import React, { useState, useRef, useCallback, useMemo } from 'react';
import { View, Text, ScrollView, Pressable, useWindowDimensions, StyleSheet } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import {
  ChevronLeft,
  Check,
  AlertCircle,
  ArrowUp,
  ArrowDown,
  CheckCircle2,
  Activity,
  Heart,
  Wind,
  Droplets,
  Thermometer,
} from 'lucide-react-native';
import { BlurView } from 'expo-blur';
import Animated, { FadeInDown } from 'react-native-reanimated';

import { HealthAreaChart, type ChartDataPoint } from '../../src/components';
import { colors } from '../../src/theme';
import { t } from '../../src/i18n';
import { seededRandom } from '../../src/constants/mockDataFactory';
import { type Timeframe } from '../../src/components/TimeframeSelector';

export type IconType = 'activity' | 'heart' | 'wind' | 'droplet' | 'thermometer';
export type MetricStatus = 'in-range' | 'out-of-range';
export type BaselineTrend = 'up' | 'down' | 'neutral';

// メトリクスデータ型
interface MetricData {
  id: string;
  name: string;
  shortName: string;
  cardLabel: string; // カード用の改行付きラベル
  value: number | string;
  unit: string;
  status: MetricStatus;
  statusLabel: string;
  colorHex: string;
  typicalRange: { min: number; max: number };
  baseline: string;
  baselineTrend: BaselineTrend;
  iconType: IconType;
  chartData: ChartDataPoint[];
}

// アイコンマッピング
const ICON_MAP = {
  activity: Activity,
  heart: Heart,
  wind: Wind,
  droplet: Droplets,
  thermometer: Thermometer,
};

// モックデータ - sozai/tempoai-health-summary と同じ（i18n対応）
const getMetrics = (): MetricData[] => [
  {
    id: 'hrv',
    name: t('metric.health.hrv.name'),
    shortName: t('metric.health.hrv.shortName'),
    cardLabel: t('metric.health.hrv.cardLabel'),
    value: 82,
    unit: 'ms',
    status: 'in-range',
    statusLabel: `${t('metric.health.status.within')} 58-97`,
    colorHex: '#22C55E',
    typicalRange: { min: 58, max: 97 },
    baseline: '77 ms',
    baselineTrend: 'up',
    iconType: 'activity',
    chartData: [
      { day: 'T', value: 65 },
      { day: 'F', value: 78 },
      { day: 'S', value: 72 },
      { day: 'S', value: 85 },
      { day: 'M', value: 71 },
      { day: 'T', value: 88 },
      { day: 'W', value: 82 },
    ],
  },
  {
    id: 'rhr',
    name: t('metric.health.rhr.name'),
    shortName: t('metric.health.rhr.shortName'),
    cardLabel: t('metric.health.rhr.cardLabel'),
    value: 59,
    unit: 'bpm',
    status: 'out-of-range',
    statusLabel: 'Low < 53',
    colorHex: '#F87171',
    typicalRange: { min: 54, max: 63 },
    baseline: '59 bpm',
    baselineTrend: 'down',
    iconType: 'heart',
    chartData: [
      { day: 'T', value: 56 },
      { day: 'F', value: 52 },
      { day: 'S', value: 52 },
      { day: 'S', value: 59 },
      { day: 'M', value: 62 },
      { day: 'T', value: 59 },
      { day: 'W', value: 51 },
    ],
  },
  {
    id: 'resp',
    name: t('metric.health.resp.name'),
    shortName: t('metric.health.resp.shortName'),
    cardLabel: t('metric.health.resp.cardLabel'),
    value: 11.0,
    unit: 'BrPM',
    status: 'in-range',
    statusLabel: `${t('metric.health.status.within')} 10.5-16`,
    colorHex: '#3B82F6',
    typicalRange: { min: 10.5, max: 16 },
    baseline: '11.2 BrPM',
    baselineTrend: 'neutral',
    iconType: 'wind',
    chartData: [
      { day: 'T', value: 11.2 },
      { day: 'F', value: 10.8 },
      { day: 'S', value: 11.5 },
      { day: 'S', value: 11.0 },
      { day: 'M', value: 11.1 },
      { day: 'T', value: 10.9 },
      { day: 'W', value: 11.0 },
    ],
  },
  {
    id: 'spo2',
    name: t('metric.health.spo2.name'),
    shortName: t('metric.health.spo2.shortName'),
    cardLabel: t('metric.health.spo2.cardLabel'),
    value: 98,
    unit: '%',
    status: 'in-range',
    statusLabel: `${t('metric.health.status.within')} 96-99`,
    colorHex: '#14B8A6',
    typicalRange: { min: 96, max: 99 },
    baseline: '98%',
    baselineTrend: 'neutral',
    iconType: 'droplet',
    chartData: [
      { day: 'T', value: 97 },
      { day: 'F', value: 98 },
      { day: 'S', value: 99 },
      { day: 'S', value: 98 },
      { day: 'M', value: 97 },
      { day: 'T', value: 98 },
      { day: 'W', value: 98 },
    ],
  },
  {
    id: 'temp',
    name: t('metric.health.temp.name'),
    shortName: t('metric.health.temp.shortName'),
    cardLabel: t('metric.health.temp.cardLabel'),
    value: 36.4,
    unit: '°C',
    status: 'in-range',
    statusLabel: `${t('metric.health.status.within')} 36.1-36.9`,
    colorHex: '#F59E0B',
    typicalRange: { min: 36.1, max: 36.9 },
    baseline: '36.4°C',
    baselineTrend: 'neutral',
    iconType: 'thermometer',
    chartData: [
      { day: 'T', value: 36.3 },
      { day: 'F', value: 36.5 },
      { day: 'S', value: 36.4 },
      { day: 'S', value: 36.2 },
      { day: 'M', value: 36.6 },
      { day: 'T', value: 36.3 },
      { day: 'W', value: 36.4 },
    ],
  },
];

const HealthDetailScreen = (): React.ReactElement => {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const scrollViewRef = useRef<ScrollView>(null);

  // i18n対応のメトリクスデータを取得
  const metrics = useMemo(() => getMetrics(), []);
  const [activeSection, setActiveSection] = useState<string>('hrv');

  // セクションの位置を保持
  const sectionPositions = useRef<Record<string, number>>({});

  const handleBack = () => {
    router.back();
  };

  // セクションへスクロール
  const scrollToSection = useCallback((id: string) => {
    setActiveSection(id);
    const sectionY = sectionPositions.current[id];
    const containerY = sectionPositions.current['_container'] || 0;
    if (sectionY !== undefined && scrollViewRef.current) {
      // コンテナの開始位置 + セクションの相対位置 - ヘッダー分のオフセット
      const scrollY = containerY + sectionY - 70;
      scrollViewRef.current.scrollTo({ y: scrollY, animated: true });
    }
  }, []);

  // セクションの位置を記録
  const handleSectionLayout = useCallback((id: string, y: number) => {
    sectionPositions.current[id] = y;
  }, []);

  // タイムフレームに基づいてデータを生成
  const generateTimeframeData = useCallback(
    (
      baseData: ChartDataPoint[],
      tf: Timeframe,
      typicalRange: { min: number; max: number }
    ): ChartDataPoint[] => {
      const baseValue =
        typeof baseData[0]?.value === 'number' ? baseData[0].value : typicalRange.min;
      const range = typicalRange.max - typicalRange.min;

      const generateValue = (index: number, seed: number): number => {
        const variance = range * 0.4;
        const random = seededRandom(index + seed);
        const val =
          baseValue + (random - 0.5) * variance * 2;
        return (
          Math.round(
            Math.max(typicalRange.min * 0.85, Math.min(typicalRange.max * 1.15, val)) * 10
          ) / 10
        );
      };

      switch (tf) {
        case '7D':
          return baseData;
        case '30D': {
          const labels = ['W1', 'W2', 'W3', 'W4', 'Now'];
          return labels.map((label, i) => ({
            day: label,
            value:
              i === labels.length - 1
                ? typeof baseData[baseData.length - 1]?.value === 'number'
                  ? baseData[baseData.length - 1].value
                  : baseValue
                : generateValue(i, 30),
          }));
        }
        case '60D': {
          const labels = ['6w', '4w', '2w', '1w', 'Now'];
          return labels.map((label, i) => ({
            day: label,
            value:
              i === labels.length - 1
                ? typeof baseData[baseData.length - 1]?.value === 'number'
                  ? baseData[baseData.length - 1].value
                  : baseValue
                : generateValue(i, 60),
          }));
        }
        default:
          return baseData;
      }
    },
    []
  );

  // タイムフレーム状態を各メトリックごとに管理
  const [timeframes, setTimeframes] = useState<Record<string, Timeframe>>({});
  const getTimeframe = (id: string): Timeframe => timeframes[id] || '7D';
  const setTimeframe = (id: string, tf: Timeframe) =>
    setTimeframes((prev) => ({ ...prev, [id]: tf }));

  // 画面幅を取得
  const screenWidth = useWindowDimensions().width;

  // Temperatureカード用（横長レイアウト）- アイコン付き
  const renderTemperatureCard = (metric: MetricData, onPress: () => void) => {
    const isOutOfRange = metric.status === 'out-of-range';
    const IconComponent = ICON_MAP[metric.iconType];
    return (
      <View style={styles.tempCard}>
        <Pressable onPress={onPress} style={styles.tempCardPressable}>
          {/* 左側: アイコン + ラベル（縦中央） */}
          <View style={styles.tempLeftSection}>
            <IconComponent size={18} color={colors.stone[400]} />
            <Text style={styles.tempCardLabel}>
              {metric.cardLabel}
            </Text>
          </View>
          {/* 右側: 数値とステータス */}
          <View style={styles.tempRightSection}>
            <View style={styles.tempValueRow}>
              <Text style={styles.tempValue}>
                {metric.value}
              </Text>
              <Text style={styles.tempUnit}>
                {metric.unit}
              </Text>
            </View>
            <View style={styles.tempStatusRow}>
              {isOutOfRange ? (
                <AlertCircle size={14} strokeWidth={2.5} color={colors.amber[500]} />
              ) : (
                <Check size={14} strokeWidth={3} color={colors.emerald[500]} />
              )}
              <Text
                style={[
                  styles.tempStatusText,
                  { color: isOutOfRange ? colors.amber[500] : colors.emerald[500] }
                ]}
              >
                {metric.statusLabel}
              </Text>
            </View>
          </View>
        </Pressable>
      </View>
    );
  };

  // インラインMetricDetail
  const renderMetricDetail = (metric: MetricData, index: number) => {
    const tf = getTimeframe(metric.id);
    const displayChartData = generateTimeframeData(metric.chartData, tf, metric.typicalRange);
    const tfOptions: Timeframe[] = ['7D', '30D', '60D'];

    return (
      <Animated.View
        key={metric.id}
        entering={FadeInDown.delay(100 + index * 50).duration(400)}
        style={{ marginBottom: 32 }}
        onLayout={(event) => {
          const { y } = event.nativeEvent.layout;
          handleSectionLayout(metric.id, y);
        }}
      >
        {/* Section Header with Left Border */}
        <View
          className="flex-row items-center mb-4 pl-4"
          style={[styles.sectionHeader, { borderLeftColor: metric.colorHex }]}
        >
          <Text className="text-lg font-semibold text-stone-900">{metric.name}</Text>
        </View>

        {/* Main Card */}
        <View
          className="bg-white p-5 rounded-2xl border border-stone-100"
          style={styles.detailCard}
        >
          {/* Top Stats Row */}
          <View className="flex-row justify-between items-end mb-6">
            <View>
              <Text
                className="text-xs font-semibold text-stone-400 uppercase mb-1"
                style={styles.statLabel}
              >
                {t('detail.health.mostRecent')}
              </Text>
              <View className="flex-row items-baseline" style={styles.valueRow}>
                <Text className="text-4xl font-bold" style={{ color: metric.colorHex }}>
                  {metric.value}
                </Text>
                <Text className="text-sm font-medium text-stone-500">{metric.unit}</Text>
              </View>
            </View>
            <View style={styles.baselineContainer}>
              <Text
                className="text-xs font-semibold text-stone-400 uppercase mb-1"
                style={styles.statLabel}
              >
                {t('detail.health.baseline')}
              </Text>
              <View className="flex-row items-center" style={styles.valueRow}>
                <Text className="text-sm font-medium text-stone-600">{metric.baseline}</Text>
                {metric.baselineTrend === 'up' && (
                  <ArrowUp size={16} color={metric.colorHex} />
                )}
                {metric.baselineTrend === 'down' && (
                  <ArrowDown size={16} color={metric.colorHex} />
                )}
              </View>
            </View>
          </View>

          {/* Timeframe Selector */}
          <View className="items-center mb-6">
            <View
              className="flex-row bg-stone-100 p-1 rounded-full"
              style={styles.timeframeSelector}
            >
              {tfOptions.map((option) => (
                <Pressable
                  key={option}
                  onPress={() => setTimeframe(metric.id, option)}
                  className="px-4 py-1.5 rounded-full"
                  style={[
                    tf === option && {
                      backgroundColor: colors.stone[800],
                      shadowColor: colors.stone[900],
                      shadowOffset: { width: 0, height: 2 },
                      shadowOpacity: 0.1,
                      shadowRadius: 4,
                      elevation: 2,
                    },
                  ]}
                >
                  <Text
                    className="text-xs font-medium"
                    style={{ color: tf === option ? colors.white : colors.stone[500] }}
                  >
                    {option}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          {/* Chart */}
          <View className="mb-4">
            <HealthAreaChart
              data={displayChartData}
              colorHex={metric.colorHex}
              typicalRange={metric.typicalRange}
              unit={metric.unit}
              height={180}
            />
          </View>

          {/* Legend */}
          <View
            className="flex-row items-center pt-2 border-t border-stone-100"
            style={styles.legend}
          >
            <CheckCircle2 size={16} color={metric.colorHex} />
            <Text className="text-xs font-medium text-stone-500">
              {t('detail.health.typicalRange')}: {metric.typicalRange.min}-{metric.typicalRange.max}{' '}
              {metric.unit.replace(' ', '')}
            </Text>
          </View>
        </View>
      </Animated.View>
    );
  };

  return (
    <View className="flex-1 bg-stone-50">
      <SafeAreaView className="flex-1" edges={['top']}>
        {/* Header */}
        <View
          className="flex-row items-center justify-between px-5 border-b border-stone-100 bg-stone-50"
          style={{
            height: 56,
            shadowColor: colors.stone[900],
            shadowOffset: { width: 0, height: 1 },
            shadowOpacity: 0.05,
            shadowRadius: 2,
          }}
        >
          <Pressable
            onPress={handleBack}
            className="p-2 -ml-2 rounded-full"
            style={({ pressed }) => [
              { backgroundColor: pressed ? colors.stone[100] : 'transparent' },
            ]}
          >
            <ChevronLeft size={24} strokeWidth={2.5} color={colors.stone[800]} />
          </Pressable>
          <Text className="text-lg font-bold text-stone-900">Health</Text>
          <View style={{ width: 40 }} />
        </View>

        <ScrollView
          ref={scrollViewRef}
          contentContainerStyle={{
            paddingBottom: insets.bottom + 100,
          }}
          showsVerticalScrollIndicator={false}
        >
          <View className="px-4 pt-6">
            {/* Summary Grid - 2x2 + full width */}
            <Animated.View entering={FadeInDown.duration(400)} className="mb-8">
              {(() => {
                const CARD_GAP = 12;
                const HORIZONTAL_PADDING = 16;
                const containerWidth = screenWidth - HORIZONTAL_PADDING * 2;
                const cardWidth = (containerWidth - CARD_GAP) / 2;
                const cardHeight = cardWidth * 0.85; // 縦幅を少し狭める

                const renderMetricCard = (metric: MetricData, onPress: () => void) => {
                  const isOutOfRange = metric.status === 'out-of-range';
                  const IconComponent = ICON_MAP[metric.iconType];
                  return (
                    <View
                      style={[
                        styles.metricCard,
                        { width: cardWidth, height: cardHeight }
                      ]}
                    >
                      <Pressable
                        onPress={onPress}
                        style={styles.metricCardPressable}
                      >
                        {/* Icon + Label */}
                        <View style={styles.metricCardHeader}>
                          <IconComponent size={18} color={colors.stone[400]} />
                          <Text style={styles.metricCardLabel}>
                            {metric.cardLabel}
                          </Text>
                        </View>

                        {/* Value */}
                        <View style={styles.metricValueContainer}>
                          <Text style={styles.metricValue}>
                            {metric.value}
                          </Text>
                          <Text style={styles.metricUnit}>
                            {metric.unit}
                          </Text>
                        </View>

                        {/* Status */}
                        <View style={styles.metricStatusContainer}>
                          {isOutOfRange ? (
                            <AlertCircle size={14} strokeWidth={2.5} color={colors.amber[500]} />
                          ) : (
                            <Check size={14} strokeWidth={3} color={colors.emerald[500]} />
                          )}
                          <Text
                            style={[
                              styles.metricStatusText,
                              { color: isOutOfRange ? colors.amber[500] : colors.emerald[500] }
                            ]}
                          >
                            {metric.statusLabel}
                          </Text>
                        </View>
                      </Pressable>
                    </View>
                  );
                };

                return (
                  <View style={[styles.gridContainer, { gap: CARD_GAP }]}>
                    {/* Row 1: HRV & RHR */}
                    <View style={[styles.gridRow, { gap: CARD_GAP }]}>
                      {renderMetricCard(metrics[0], () => scrollToSection(metrics[0].id))}
                      {renderMetricCard(metrics[1], () => scrollToSection(metrics[1].id))}
                    </View>
                    {/* Row 2: RESP & SpO2 */}
                    <View style={[styles.gridRow, { gap: CARD_GAP }]}>
                      {renderMetricCard(metrics[2], () => scrollToSection(metrics[2].id))}
                      {renderMetricCard(metrics[3], () => scrollToSection(metrics[3].id))}
                    </View>
                    {/* Row 3: Temperature (full width) */}
                    {renderTemperatureCard(metrics[4], () => scrollToSection(metrics[4].id))}
                  </View>
                );
              })()}
            </Animated.View>

            {/* Detail Sections - インライン実装 */}
            <View
              style={styles.detailSections}
              onLayout={(event) => {
                // Detail Sectionsコンテナの開始位置を保存
                sectionPositions.current['_container'] = event.nativeEvent.layout.y;
              }}
            >
              {metrics.map((metric, index) => renderMetricDetail(metric, index))}
            </View>
          </View>
        </ScrollView>

        {/* Bottom Metric Switcher */}
        <View
          className="absolute bottom-0 left-0 right-0 border-t border-stone-200"
          style={{
            paddingBottom: insets.bottom + 8,
            backgroundColor: 'rgba(255, 255, 255, 0.85)',
          }}
        >
          <BlurView intensity={80} tint="light" className="absolute inset-0" />
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{
              paddingHorizontal: 8,
              paddingVertical: 12,
              gap: 8,
            }}
          >
            {metrics.map((metric) => {
              const isActive = activeSection === metric.id;
              return (
                <Pressable
                  key={metric.id}
                  onPress={() => scrollToSection(metric.id)}
                  className="flex-row items-center px-4 py-2.5 rounded-xl"
                  style={[
                    {
                      backgroundColor: isActive ? colors.stone[900] : colors.stone[100],
                      transform: [{ scale: isActive ? 1 : 0.95 }],
                    },
                    isActive && {
                      shadowColor: colors.stone[900],
                      shadowOffset: { width: 0, height: 4 },
                      shadowOpacity: 0.15,
                      shadowRadius: 8,
                      elevation: 4,
                    },
                  ]}
                >
                  <Text
                    className="text-xs font-bold uppercase mr-2"
                    style={{
                      color: isActive ? colors.stone[400] : colors.stone[500],
                      letterSpacing: 0.5,
                    }}
                  >
                    {metric.shortName}
                  </Text>
                  <Text
                    className="text-sm font-bold"
                    style={{
                      color: isActive ? colors.white : colors.stone[900],
                    }}
                  >
                    {metric.value}
                    {metric.unit}
                  </Text>
                </Pressable>
              );
            })}
          </ScrollView>
        </View>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  sectionHeader: {
    borderLeftWidth: 4,
  },
  detailCard: {
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 10,
    elevation: 4,
  },
  statLabel: {
    letterSpacing: 0.5,
  },
  valueRow: {
    gap: 4,
  },
  baselineContainer: {
    alignItems: 'flex-end',
  },
  timeframeSelector: {
    gap: 4,
  },
  legend: {
    gap: 8,
  },
  tempCard: {
    backgroundColor: colors.white,
    borderRadius: 24,
    borderWidth: 1,
    borderColor: colors.stone[100],
    overflow: 'hidden',
  },
  tempCardPressable: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
  },
  tempLeftSection: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  tempCardLabel: {
    fontSize: 14,
    fontWeight: '700',
    color: colors.stone[400],
  },
  tempRightSection: {
    alignItems: 'flex-end',
  },
  tempValueRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: 4,
  },
  tempValue: {
    fontSize: 36,
    fontWeight: '700',
    color: colors.stone[900],
    letterSpacing: -1,
  },
  tempUnit: {
    fontSize: 16,
    fontWeight: '500',
    color: colors.stone[400],
  },
  tempStatusRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    marginTop: 4,
  },
  tempStatusText: {
    fontSize: 14,
    fontWeight: '500',
  },
  metricCard: {
    backgroundColor: colors.white,
    borderRadius: 24,
    borderWidth: 1,
    borderColor: colors.stone[100],
    overflow: 'hidden',
  },
  metricCardPressable: {
    padding: 16,
  },
  metricCardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  metricCardLabel: {
    fontSize: 14,
    fontWeight: '700',
    color: colors.stone[400],
  },
  metricValueContainer: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: 4,
    marginTop: 8,
  },
  metricValue: {
    fontSize: 36,
    fontWeight: '700',
    color: colors.stone[900],
    letterSpacing: -1,
  },
  metricUnit: {
    fontSize: 16,
    fontWeight: '500',
    color: colors.stone[400],
  },
  metricStatusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    marginTop: 8,
  },
  metricStatusText: {
    fontSize: 14,
    fontWeight: '500',
  },
  gridContainer: {
    // gap is dynamic
  },
  gridRow: {
    flexDirection: 'row',
    // gap is dynamic
  },
  detailSections: {
    gap: 8,
  },
});

export default HealthDetailScreen;
