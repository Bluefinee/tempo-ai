/**
 * HealthDetailScreen - Health詳細画面
 * sozai/tempoai-health-summary/ を React Native で完全再現
 */

import { BlurView } from "expo-blur";
import { useRouter } from "expo-router";
import {
	Activity,
	AlertCircle,
	ArrowDown,
	ArrowUp,
	Check,
	CheckCircle2,
	ChevronLeft,
	Droplets,
	Heart,
	Thermometer,
	Wind,
} from "lucide-react-native";
import type React from "react";
import { useCallback, useMemo, useRef, useState } from "react";
import {
	Pressable,
	ScrollView,
	StyleSheet,
	Text,
	useWindowDimensions,
	View,
} from "react-native";
import Animated, { FadeInDown } from "react-native-reanimated";
import {
	SafeAreaView,
	useSafeAreaInsets,
} from "react-native-safe-area-context";

import { type ChartDataPoint, HealthAreaChart } from "../../src/components";
import type { Timeframe } from "../../src/components/TimeframeSelector";
import { seededRandom } from "../../src/constants/mockDataFactory";
import type { RealtimeMetrics } from "../../src/domain/models";
import { t } from "../../src/i18n";
import { useHealthStore } from "../../src/stores/healthStore";
import type { HealthSummaryHistory } from "../../src/stores/healthStore/types";
import { colors } from "../../src/theme";

export type IconType =
	| "activity"
	| "heart"
	| "wind"
	| "droplet"
	| "thermometer";
export type MetricStatus = "in-range" | "out-of-range";
export type BaselineTrend = "up" | "down" | "neutral";

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

// Typical ranges for each metric
const METRIC_RANGES = {
	hrv: { min: 58, max: 97 },
	rhr: { min: 54, max: 63 },
	resp: { min: 10.5, max: 16 },
	spo2: { min: 96, max: 99 },
	temp: { min: 36.1, max: 36.9 },
};

/**
 * Convert HealthSummaryHistory samples to ChartDataPoint[]
 */
const historyToChartData = (
	samples: { date: Date; value: number }[] | undefined,
): ChartDataPoint[] => {
	// 曜日ラベルをi18nから取得
	const weekdayLabels = [
		t("screen.healthDetail.weekdays.su"),
		t("screen.healthDetail.weekdays.m"),
		t("screen.healthDetail.weekdays.t"),
		t("screen.healthDetail.weekdays.w"),
		t("screen.healthDetail.weekdays.th"),
		t("screen.healthDetail.weekdays.f"),
		t("screen.healthDetail.weekdays.s"),
	];

	if (!samples?.length) {
		return [
			{ day: weekdayLabels[2], value: 0 },
			{ day: weekdayLabels[5], value: 0 },
			{ day: weekdayLabels[6], value: 0 },
			{ day: weekdayLabels[0], value: 0 },
			{ day: weekdayLabels[1], value: 0 },
			{ day: weekdayLabels[2], value: 0 },
			{ day: weekdayLabels[3], value: 0 },
		];
	}
	const last7 = samples.slice(-7);
	return last7.map((s) => ({
		day: weekdayLabels[s.date.getDay()],
		value: Math.round(s.value * 10) / 10,
	}));
};

/**
 * Determine status based on value and typical range
 */
const getMetricStatus = (
	value: number,
	range: { min: number; max: number },
): { status: MetricStatus; statusLabel: string } => {
	if (value >= range.min && value <= range.max) {
		return {
			status: "in-range",
			statusLabel: `${t("metric.health.status.within")} ${range.min}-${range.max}`,
		};
	}
	if (value < range.min) {
		return {
			status: "out-of-range",
			statusLabel: `${t("screen.healthDetail.status.low")} < ${range.min}`,
		};
	}
	return {
		status: "out-of-range",
		statusLabel: `${t("screen.healthDetail.status.high")} > ${range.max}`,
	};
};

/**
 * Determine baseline trend by comparing current value to baseline
 */
const getBaselineTrend = (current: number, baseline: number): BaselineTrend => {
	const diff = current - baseline;
	if (Math.abs(diff) < baseline * 0.05) return "neutral";
	return diff > 0 ? "up" : "down";
};

// デフォルトBaseline値（realtimeMetricsがない場合のフォールバック）
const DEFAULT_BASELINES = {
	hrv: 55, // 一般的なHRV平均値
	rhr: 65, // 一般的なRHR平均値
	resp: 14, // 一般的な呼吸数
	spo2: 97, // 一般的なSpO2
	temp: 36.5, // 一般的な体温
} as const;

/**
 * Create dynamic metrics from healthStore data
 */
const createMetrics = (
	realtimeMetrics: RealtimeMetrics | null,
	history: HealthSummaryHistory | null,
): MetricData[] => {
	// HRV: valueとbaselineの両方をrealtimeMetricsから取得
	const hrvValue = realtimeMetrics?.hrv?.value ?? DEFAULT_BASELINES.hrv;
	const hrvBaseline = realtimeMetrics?.hrv?.baseline ?? DEFAULT_BASELINES.hrv;
	const hrvStatus = getMetricStatus(hrvValue, METRIC_RANGES.hrv);

	// RHR: valueとbaselineの両方をrealtimeMetricsから取得
	const rhrValue = realtimeMetrics?.rhr?.value ?? DEFAULT_BASELINES.rhr;
	const rhrBaseline = realtimeMetrics?.rhr?.baseline ?? DEFAULT_BASELINES.rhr;
	const rhrStatus = getMetricStatus(rhrValue, METRIC_RANGES.rhr);

	// Respiratory: valueとbaselineの両方をrealtimeMetricsから取得
	const respValue =
		realtimeMetrics?.respiratory?.value ?? DEFAULT_BASELINES.resp;
	const respBaseline =
		realtimeMetrics?.respiratory?.baseline ?? DEFAULT_BASELINES.resp;
	const respStatus = getMetricStatus(respValue, METRIC_RANGES.resp);

	// SpO2: valueとbaselineの両方をrealtimeMetricsから取得
	const spo2Value = realtimeMetrics?.spo2?.value ?? DEFAULT_BASELINES.spo2;
	const spo2Baseline =
		realtimeMetrics?.spo2?.baseline ?? DEFAULT_BASELINES.spo2;
	const spo2Status = getMetricStatus(spo2Value, METRIC_RANGES.spo2);

	// Wrist Temp: valueとbaselineの両方をrealtimeMetricsから取得
	const tempValue = realtimeMetrics?.wristTemp?.value ?? DEFAULT_BASELINES.temp;
	const tempBaseline =
		realtimeMetrics?.wristTemp?.baseline ?? DEFAULT_BASELINES.temp;
	const tempStatus = getMetricStatus(tempValue, METRIC_RANGES.temp);

	return [
		{
			id: "hrv",
			name: t("metric.health.hrv.name"),
			shortName: t("metric.health.hrv.shortName"),
			cardLabel: t("metric.health.hrv.cardLabel"),
			value: hrvValue,
			unit: "ms",
			status: hrvStatus.status,
			statusLabel: hrvStatus.statusLabel,
			colorHex: "#22C55E",
			typicalRange: METRIC_RANGES.hrv,
			baseline: `${hrvBaseline} ms`,
			baselineTrend: getBaselineTrend(hrvValue, hrvBaseline),
			iconType: "activity",
			chartData: historyToChartData(history?.hrv?.samples),
		},
		{
			id: "rhr",
			name: t("metric.health.rhr.name"),
			shortName: t("metric.health.rhr.shortName"),
			cardLabel: t("metric.health.rhr.cardLabel"),
			value: rhrValue,
			unit: "bpm",
			status: rhrStatus.status,
			statusLabel: rhrStatus.statusLabel,
			colorHex: "#F87171",
			typicalRange: METRIC_RANGES.rhr,
			baseline: `${rhrBaseline} bpm`,
			baselineTrend: getBaselineTrend(rhrValue, rhrBaseline),
			iconType: "heart",
			chartData: historyToChartData(history?.rhr?.samples),
		},
		{
			id: "resp",
			name: t("metric.health.resp.name"),
			shortName: t("metric.health.resp.shortName"),
			cardLabel: t("metric.health.resp.cardLabel"),
			value: respValue.toFixed(1),
			unit: "BrPM",
			status: respStatus.status,
			statusLabel: respStatus.statusLabel,
			colorHex: "#3B82F6",
			typicalRange: METRIC_RANGES.resp,
			baseline: `${respBaseline} BrPM`,
			baselineTrend: getBaselineTrend(respValue, respBaseline),
			iconType: "wind",
			chartData: historyToChartData(history?.respiratory?.samples),
		},
		{
			id: "spo2",
			name: t("metric.health.spo2.name"),
			shortName: t("metric.health.spo2.shortName"),
			cardLabel: t("metric.health.spo2.cardLabel"),
			value: spo2Value,
			unit: "%",
			status: spo2Status.status,
			statusLabel: spo2Status.statusLabel,
			colorHex: "#14B8A6",
			typicalRange: METRIC_RANGES.spo2,
			baseline: `${spo2Baseline}%`,
			baselineTrend: getBaselineTrend(spo2Value, spo2Baseline),
			iconType: "droplet",
			chartData: historyToChartData(history?.spo2?.samples),
		},
		{
			id: "temp",
			name: t("metric.health.temp.name"),
			shortName: t("metric.health.temp.shortName"),
			cardLabel: t("metric.health.temp.cardLabel"),
			value: tempValue.toFixed(1),
			unit: "°C",
			status: tempStatus.status,
			statusLabel: tempStatus.statusLabel,
			colorHex: "#F59E0B",
			typicalRange: METRIC_RANGES.temp,
			baseline: `${tempBaseline}°C`,
			baselineTrend: getBaselineTrend(tempValue, tempBaseline),
			iconType: "thermometer",
			chartData: historyToChartData(history?.wristTemp?.samples),
		},
	];
};

const HealthDetailScreen = (): React.ReactElement => {
	const router = useRouter();
	const insets = useSafeAreaInsets();
	const scrollViewRef = useRef<ScrollView>(null);

	// healthStoreからリアルタイムメトリクスと履歴を取得
	const realtimeMetrics = useHealthStore((s) => s.realtimeMetrics);
	const healthSummaryHistory = useHealthStore((s) => s.healthSummaryHistory);

	// 動的なメトリクスデータを生成
	const metrics = useMemo(
		() => createMetrics(realtimeMetrics, healthSummaryHistory),
		[realtimeMetrics, healthSummaryHistory],
	);
	const [activeSection, setActiveSection] = useState<string>("hrv");

	// セクションの位置を保持
	const sectionPositions = useRef<Record<string, number>>({});

	const handleBack = () => {
		router.back();
	};

	// セクションへスクロール
	const scrollToSection = useCallback((id: string) => {
		setActiveSection(id);
		const sectionY = sectionPositions.current[id];
		const containerY = sectionPositions.current._container || 0;
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
			typicalRange: { min: number; max: number },
		): ChartDataPoint[] => {
			const baseValue =
				typeof baseData[0]?.value === "number"
					? baseData[0].value
					: typicalRange.min;
			const range = typicalRange.max - typicalRange.min;

			const generateValue = (index: number, seed: number): number => {
				const variance = range * 0.4;
				const random = seededRandom(index + seed);
				const val = baseValue + (random - 0.5) * variance * 2;
				return (
					Math.round(
						Math.max(
							typicalRange.min * 0.85,
							Math.min(typicalRange.max * 1.15, val),
						) * 10,
					) / 10
				);
			};

			switch (tf) {
				case "7D":
					return baseData;
				case "30D": {
					const labels = ["W1", "W2", "W3", "W4", "Now"];
					return labels.map((label, i) => ({
						day: label,
						value:
							i === labels.length - 1
								? typeof baseData[baseData.length - 1]?.value === "number"
									? baseData[baseData.length - 1].value
									: baseValue
								: generateValue(i, 30),
					}));
				}
				case "60D": {
					const labels = ["6w", "4w", "2w", "1w", "Now"];
					return labels.map((label, i) => ({
						day: label,
						value:
							i === labels.length - 1
								? typeof baseData[baseData.length - 1]?.value === "number"
									? baseData[baseData.length - 1].value
									: baseValue
								: generateValue(i, 60),
					}));
				}
				default:
					return baseData;
			}
		},
		[],
	);

	// タイムフレーム状態を各メトリックごとに管理
	const [timeframes, setTimeframes] = useState<Record<string, Timeframe>>({});
	const getTimeframe = (id: string): Timeframe => timeframes[id] || "7D";
	const setTimeframe = (id: string, tf: Timeframe) =>
		setTimeframes((prev) => ({ ...prev, [id]: tf }));

	// 画面幅を取得
	const screenWidth = useWindowDimensions().width;

	// Temperatureカード用（横長レイアウト）- アイコン付き
	const renderTemperatureCard = (metric: MetricData, onPress: () => void) => {
		const isOutOfRange = metric.status === "out-of-range";
		const IconComponent = ICON_MAP[metric.iconType];
		return (
			<View style={styles.tempCard}>
				<Pressable onPress={onPress} style={styles.tempCardPressable}>
					{/* 左側: アイコン + ラベル（縦中央） */}
					<View style={styles.tempLeftSection}>
						<IconComponent size={18} color={colors.stone[400]} />
						<Text style={styles.tempCardLabel}>{metric.cardLabel}</Text>
					</View>
					{/* 右側: 数値とステータス */}
					<View style={styles.tempRightSection}>
						<View style={styles.tempValueRow}>
							<Text style={styles.tempValue}>{metric.value}</Text>
							<Text style={styles.tempUnit}>{metric.unit}</Text>
						</View>
						<View style={styles.tempStatusRow}>
							{isOutOfRange ? (
								<AlertCircle
									size={14}
									strokeWidth={2.5}
									color={colors.amber[500]}
								/>
							) : (
								<Check size={14} strokeWidth={3} color={colors.emerald[500]} />
							)}
							<Text
								style={[
									styles.tempStatusText,
									{
										color: isOutOfRange
											? colors.amber[500]
											: colors.emerald[500],
									},
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
		const displayChartData = generateTimeframeData(
			metric.chartData,
			tf,
			metric.typicalRange,
		);
		const tfOptions: Timeframe[] = ["7D", "30D", "60D"];

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
					<Text className="text-lg font-semibold text-stone-900">
						{metric.name}
					</Text>
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
								{t("detail.health.mostRecent")}
							</Text>
							<View className="flex-row items-baseline" style={styles.valueRow}>
								<Text
									className="text-4xl font-bold"
									style={{ color: metric.colorHex }}
								>
									{metric.value}
								</Text>
								<Text className="text-sm font-medium text-stone-500">
									{metric.unit}
								</Text>
							</View>
						</View>
						<View style={styles.baselineContainer}>
							<Text
								className="text-xs font-semibold text-stone-400 uppercase mb-1"
								style={styles.statLabel}
							>
								{t("detail.health.baseline")}
							</Text>
							<View className="flex-row items-center" style={styles.valueRow}>
								<Text className="text-sm font-medium text-stone-600">
									{metric.baseline}
								</Text>
								{metric.baselineTrend === "up" && (
									<ArrowUp size={16} color={metric.colorHex} />
								)}
								{metric.baselineTrend === "down" && (
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
										style={{
											color: tf === option ? colors.white : colors.stone[500],
										}}
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
							{t("detail.health.typicalRange")}: {metric.typicalRange.min}-
							{metric.typicalRange.max} {metric.unit.replace(" ", "")}
						</Text>
					</View>
				</View>
			</Animated.View>
		);
	};

	return (
		<View className="flex-1 bg-stone-50">
			<SafeAreaView className="flex-1" edges={["top"]}>
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
							{ backgroundColor: pressed ? colors.stone[100] : "transparent" },
						]}
					>
						<ChevronLeft
							size={24}
							strokeWidth={2.5}
							color={colors.stone[800]}
						/>
					</Pressable>
					<Text className="text-lg font-bold text-stone-900">{t("screen.healthDetail.title")}</Text>
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

								const renderMetricCard = (
									metric: MetricData,
									onPress: () => void,
								) => {
									const isOutOfRange = metric.status === "out-of-range";
									const IconComponent = ICON_MAP[metric.iconType];
									return (
										<View
											style={[
												styles.metricCard,
												{ width: cardWidth, height: cardHeight },
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
													<Text style={styles.metricValue}>{metric.value}</Text>
													<Text style={styles.metricUnit}>{metric.unit}</Text>
												</View>

												{/* Status */}
												<View style={styles.metricStatusContainer}>
													{isOutOfRange ? (
														<AlertCircle
															size={14}
															strokeWidth={2.5}
															color={colors.amber[500]}
														/>
													) : (
														<Check
															size={14}
															strokeWidth={3}
															color={colors.emerald[500]}
														/>
													)}
													<Text
														style={[
															styles.metricStatusText,
															{
																color: isOutOfRange
																	? colors.amber[500]
																	: colors.emerald[500],
															},
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
											{renderMetricCard(metrics[0], () =>
												scrollToSection(metrics[0].id),
											)}
											{renderMetricCard(metrics[1], () =>
												scrollToSection(metrics[1].id),
											)}
										</View>
										{/* Row 2: RESP & SpO2 */}
										<View style={[styles.gridRow, { gap: CARD_GAP }]}>
											{renderMetricCard(metrics[2], () =>
												scrollToSection(metrics[2].id),
											)}
											{renderMetricCard(metrics[3], () =>
												scrollToSection(metrics[3].id),
											)}
										</View>
										{/* Row 3: Temperature (full width) */}
										{renderTemperatureCard(metrics[4], () =>
											scrollToSection(metrics[4].id),
										)}
									</View>
								);
							})()}
						</Animated.View>

						{/* Detail Sections - インライン実装 */}
						<View
							style={styles.detailSections}
							onLayout={(event) => {
								// Detail Sectionsコンテナの開始位置を保存
								sectionPositions.current._container =
									event.nativeEvent.layout.y;
							}}
						>
							{metrics.map((metric, index) =>
								renderMetricDetail(metric, index),
							)}
						</View>
					</View>
				</ScrollView>

				{/* Bottom Metric Switcher */}
				<View
					className="absolute bottom-0 left-0 right-0 border-t border-stone-200"
					style={{
						paddingBottom: insets.bottom + 8,
						backgroundColor: "rgba(255, 255, 255, 0.85)",
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
											backgroundColor: isActive
												? colors.stone[900]
												: colors.stone[100],
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
};

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
		alignItems: "flex-end",
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
		overflow: "hidden",
	},
	tempCardPressable: {
		flexDirection: "row",
		alignItems: "center",
		justifyContent: "space-between",
		padding: 16,
	},
	tempLeftSection: {
		flexDirection: "row",
		alignItems: "center",
		gap: 6,
	},
	tempCardLabel: {
		fontSize: 14,
		fontWeight: "700",
		color: colors.stone[400],
	},
	tempRightSection: {
		alignItems: "flex-end",
	},
	tempValueRow: {
		flexDirection: "row",
		alignItems: "baseline",
		gap: 4,
	},
	tempValue: {
		fontSize: 36,
		fontWeight: "700",
		color: colors.stone[900],
		letterSpacing: -1,
	},
	tempUnit: {
		fontSize: 16,
		fontWeight: "500",
		color: colors.stone[400],
	},
	tempStatusRow: {
		flexDirection: "row",
		alignItems: "center",
		gap: 6,
		marginTop: 4,
	},
	tempStatusText: {
		fontSize: 14,
		fontWeight: "500",
	},
	metricCard: {
		backgroundColor: colors.white,
		borderRadius: 24,
		borderWidth: 1,
		borderColor: colors.stone[100],
		overflow: "hidden",
	},
	metricCardPressable: {
		padding: 16,
	},
	metricCardHeader: {
		flexDirection: "row",
		alignItems: "center",
		gap: 6,
	},
	metricCardLabel: {
		fontSize: 14,
		fontWeight: "700",
		color: colors.stone[400],
	},
	metricValueContainer: {
		flexDirection: "row",
		alignItems: "baseline",
		gap: 4,
		marginTop: 8,
	},
	metricValue: {
		fontSize: 36,
		fontWeight: "700",
		color: colors.stone[900],
		letterSpacing: -1,
	},
	metricUnit: {
		fontSize: 16,
		fontWeight: "500",
		color: colors.stone[400],
	},
	metricStatusContainer: {
		flexDirection: "row",
		alignItems: "center",
		gap: 6,
		marginTop: 8,
	},
	metricStatusText: {
		fontSize: 14,
		fontWeight: "500",
	},
	gridContainer: {
		// gap is dynamic
	},
	gridRow: {
		flexDirection: "row",
		// gap is dynamic
	},
	detailSections: {
		gap: 8,
	},
});

export default HealthDetailScreen;
