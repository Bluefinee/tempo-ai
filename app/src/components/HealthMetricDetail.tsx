/**
 * HealthMetricDetail - Health詳細セクション
 * sozai/tempoai-health-summary/components/DetailSection.tsx を再現
 */

import { ArrowDown, ArrowUp, CheckCircle2 } from "lucide-react-native";
import type React from "react";
import { useMemo, useState } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import Animated, { FadeInDown } from "react-native-reanimated";

import { t } from "../i18n";
import { colors } from "../theme";
import { type ChartDataPoint, HealthAreaChart } from "./HealthAreaChart";
import type { Timeframe } from "./TimeframeSelector";

// タイムフレーム別ラベル定義（i18n JSONは配列対応が複雑なため、関数で取得）
const getTimeframeLabels = (timeframe: "30D" | "60D"): string[] => {
	if (timeframe === "30D") {
		return [
			t("chart.timeframeLabels.30d.0", { defaultValue: "W1" }),
			t("chart.timeframeLabels.30d.1", { defaultValue: "W2" }),
			t("chart.timeframeLabels.30d.2", { defaultValue: "W3" }),
			t("chart.timeframeLabels.30d.3", { defaultValue: "W4" }),
			t("chart.timeframeLabels.30d.4", { defaultValue: "Now" }),
		];
	}
	return [
		t("chart.timeframeLabels.60d.0", { defaultValue: "6w" }),
		t("chart.timeframeLabels.60d.1", { defaultValue: "4w" }),
		t("chart.timeframeLabels.60d.2", { defaultValue: "2w" }),
		t("chart.timeframeLabels.60d.3", { defaultValue: "1w" }),
		t("chart.timeframeLabels.60d.4", { defaultValue: "Now" }),
	];
};

export type BaselineTrend = "up" | "down" | "neutral";

interface HealthMetricDetailProps {
	id: string;
	name: string;
	value: number | string;
	unit: string;
	colorHex: string;
	chartData: ChartDataPoint[];
	typicalRange: { min: number; max: number };
	baseline: string;
	baselineTrend: BaselineTrend;
	delay?: number;
}

// タイムフレームに基づいてデータを生成
const generateTimeframeData = (
	baseData: ChartDataPoint[],
	timeframe: Timeframe,
	typicalRange: { min: number; max: number },
): ChartDataPoint[] => {
	const baseValue =
		typeof baseData[0]?.value === "number"
			? baseData[0].value
			: typicalRange.min;
	const range = typicalRange.max - typicalRange.min;

	// シード値を基にした擬似ランダム生成
	const seededRandom = (seed: number): number => {
		const x = Math.sin(seed * 12.9898 + seed * 78.233) * 43758.5453;
		return x - Math.floor(x);
	};

	const generateValue = (index: number, seed: number): number => {
		const variance = range * 0.4;
		const random = seededRandom(index + seed);
		const value = baseValue + (random - 0.5) * variance * 2;
		return (
			Math.round(
				Math.max(
					typicalRange.min * 0.85,
					Math.min(typicalRange.max * 1.15, value),
				) * 10,
			) / 10
		);
	};

	switch (timeframe) {
		case "7D":
			// 7日間: 元のデータをそのまま使用
			return baseData;

		case "30D": {
			// 30日間: 週単位のラベルで5データポイント (i18n対応)
			const labels = getTimeframeLabels("30D");
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
			// 60日間: 2週間単位のラベルで5データポイント (i18n対応)
			const labels = getTimeframeLabels("60D");
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
};

export const HealthMetricDetail = ({
	id,
	name,
	value,
	unit,
	colorHex,
	chartData,
	typicalRange,
	baseline,
	baselineTrend,
	delay = 0,
}: HealthMetricDetailProps): React.ReactElement => {
	const [timeframe, setTimeframe] = useState<Timeframe>("7D");

	const timeframes: Timeframe[] = ["7D", "30D", "60D"];

	// タイムフレームに応じたチャートデータを生成
	const displayChartData = useMemo(
		() => generateTimeframeData(chartData, timeframe, typicalRange),
		[chartData, timeframe, typicalRange],
	);

	return (
		<Animated.View
			entering={FadeInDown.delay(delay).duration(400)}
			style={styles.container}
		>
			{/* Section Header with Left Border */}
			<View style={[styles.sectionHeader, { borderLeftColor: colorHex }]}>
				<Text style={styles.sectionTitle}>{name}</Text>
			</View>

			{/* Main Card */}
			<View style={styles.card}>
				{/* Top Stats Row */}
				<View style={styles.statsRow}>
					{/* Most Recent */}
					<View>
						<Text style={styles.statLabel}>{t("detail.health.mostRecent")}</Text>
						<View style={styles.valueRow}>
							<Text style={[styles.value, { color: colorHex }]}>{value}</Text>
							<Text style={styles.unit}>{unit}</Text>
						</View>
					</View>

					{/* Baseline */}
					<View style={styles.baselineSection}>
						<Text style={styles.statLabel}>{t("detail.health.baseline")}</Text>
						<View style={styles.baselineRow}>
							<Text style={styles.baselineValue}>{baseline}</Text>
							{baselineTrend === "up" && <ArrowUp size={16} color={colorHex} />}
							{baselineTrend === "down" && (
								<ArrowDown size={16} color={colorHex} />
							)}
						</View>
					</View>
				</View>

				{/* Timeframe Selector */}
				<View style={styles.timeframeContainer}>
					<View style={styles.timeframePills}>
						{timeframes.map((tf) => (
							<Pressable
								key={tf}
								onPress={() => setTimeframe(tf)}
								style={[
									styles.timeframePill,
									timeframe === tf && styles.timeframePillActive,
								]}
							>
								<Text
									style={[
										styles.timeframePillText,
										timeframe === tf && styles.timeframePillTextActive,
									]}
								>
									{tf}
								</Text>
							</Pressable>
						))}
					</View>
				</View>

				{/* Chart */}
				<View style={styles.chartContainer}>
					<HealthAreaChart
						data={displayChartData}
						colorHex={colorHex}
						typicalRange={typicalRange}
						unit={unit}
						height={180}
					/>
				</View>

				{/* Legend / Range Indicator */}
				<View style={styles.legend}>
					<CheckCircle2 size={16} color={colorHex} />
					<Text style={styles.legendText}>
						Typical Range: {typicalRange.min}-{typicalRange.max}{" "}
						{unit.replace(" ", "")}
					</Text>
				</View>
			</View>
		</Animated.View>
	);
};

const styles = StyleSheet.create({
	container: {
		marginBottom: 32,
	},
	sectionHeader: {
		flexDirection: "row",
		alignItems: "center",
		marginBottom: 16,
		paddingLeft: 16,
		borderLeftWidth: 4,
	},
	sectionTitle: {
		fontSize: 18,
		fontWeight: "600",
		color: colors.stone[900],
	},
	card: {
		backgroundColor: colors.white,
		borderRadius: 16,
		padding: 20,
		shadowColor: colors.stone[900],
		shadowOffset: { width: 0, height: 2 },
		shadowOpacity: 0.06,
		shadowRadius: 8,
		elevation: 2,
	},
	statsRow: {
		flexDirection: "row",
		justifyContent: "space-between",
		alignItems: "flex-end",
		marginBottom: 24,
	},
	statLabel: {
		fontSize: 12,
		fontWeight: "600",
		color: colors.stone[400],
		textTransform: "uppercase",
		letterSpacing: 0.5,
		marginBottom: 4,
	},
	valueRow: {
		flexDirection: "row",
		alignItems: "baseline",
		gap: 4,
	},
	value: {
		fontSize: 36,
		fontWeight: "700",
	},
	unit: {
		fontSize: 14,
		fontWeight: "500",
		color: colors.stone[500],
	},
	baselineSection: {
		alignItems: "flex-end",
	},
	baselineRow: {
		flexDirection: "row",
		alignItems: "center",
		gap: 4,
	},
	baselineValue: {
		fontSize: 14,
		fontWeight: "500",
		color: colors.stone[600],
	},
	timeframeContainer: {
		alignItems: "center",
		marginBottom: 24,
	},
	timeframePills: {
		flexDirection: "row",
		backgroundColor: colors.stone[100],
		padding: 4,
		borderRadius: 999,
		gap: 4,
	},
	timeframePill: {
		paddingHorizontal: 16,
		paddingVertical: 6,
		borderRadius: 999,
	},
	timeframePillActive: {
		backgroundColor: colors.stone[800],
		shadowColor: colors.stone[900],
		shadowOffset: { width: 0, height: 2 },
		shadowOpacity: 0.1,
		shadowRadius: 4,
		elevation: 2,
	},
	timeframePillText: {
		fontSize: 12,
		fontWeight: "500",
		color: colors.stone[500],
	},
	timeframePillTextActive: {
		color: colors.white,
	},
	chartContainer: {
		marginBottom: 16,
	},
	legend: {
		flexDirection: "row",
		alignItems: "center",
		gap: 8,
		paddingTop: 8,
		borderTopWidth: 1,
		borderTopColor: colors.stone[100],
	},
	legendText: {
		fontSize: 12,
		fontWeight: "500",
		color: colors.stone[500],
	},
});
