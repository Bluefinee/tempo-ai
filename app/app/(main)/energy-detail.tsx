/**
 * EnergyDetailScreen - Energy詳細画面
 * Contributing Factors（4要素グリッド）とDaily Curve（エネルギー曲線）を含む
 */

import { useRouter } from "expo-router";
import {
	Activity,
	ChevronLeft,
	Moon,
	ThermometerSun,
	Zap,
} from "lucide-react-native";
import type React from "react";
import { useEffect, useState } from "react";
import {
	ActivityIndicator,
	Pressable,
	ScrollView,
	StyleSheet,
	Text,
	View,
} from "react-native";
import Animated, { FadeInDown } from "react-native-reanimated";
import {
	SafeAreaView,
	useSafeAreaInsets,
} from "react-native-safe-area-context";
import Svg, { Defs, LinearGradient, Path, Stop } from "react-native-svg";
import {
	CircularProgress,
	HealthAreaChart,
	type Timeframe,
	TimeframeSelector,
} from "../../src/components";
import { SCORE_TYPICAL_RANGE } from "../../src/constants";
import type { TrendDirection } from "../../src/domain/models";
import type { EnergyCurve } from "../../src/domain/models/rhythm";
import { t } from "../../src/i18n";
import { useEnergyDetail, useHealthStore } from "../../src/stores/healthStore";
import { colors, FontFamily } from "../../src/theme";

/**
 * EnergyCurveからSVGパスを生成
 * chartHeight: 100 (SVG viewBox高さ)
 * x軸: 6時〜22時を0〜100にマッピング
 * y軸: level 0-100を chartHeight-10 〜 10 にマッピング（上が低い）
 */
const generateEnergyCurveSvgPath = (
	energyCurve: EnergyCurve | null,
	chartHeight: number = 100,
): string => {
	// フォールバック用のデフォルトパス
	const defaultPath = `
		M0,80
		C20,80 20,20 40,20
		C55,20 55,60 65,60
		C75,60 75,30 85,30
		C95,30 100,80 100,80
	`;

	if (!energyCurve || energyCurve.length < 2) {
		return defaultPath;
	}

	// 6時〜22時のデータをフィルタリング
	const filteredPoints = energyCurve.filter((p) => p.hour >= 6 && p.hour <= 22);
	if (filteredPoints.length < 2) {
		return defaultPath;
	}

	// x座標: hour を 0-100 にマッピング (6時=0, 22時=100)
	const hourToX = (hour: number): number => ((hour - 6) / 16) * 100;

	// y座標: level を反転 (100=上部=10, 0=下部=chartHeight-10)
	const levelToY = (level: number): number =>
		chartHeight - 10 - (level / 100) * (chartHeight - 20);

	// パスを構築（スムーズなベジェ曲線）
	const points = filteredPoints.map((p) => ({
		x: hourToX(p.hour),
		y: levelToY(p.level),
	}));

	// パスの開始
	let path = `M${points[0].x.toFixed(1)},${points[0].y.toFixed(1)}`;

	// ベジェ曲線で滑らかに接続
	for (let i = 1; i < points.length; i++) {
		const prev = points[i - 1];
		const curr = points[i];

		// 制御点を計算（水平方向に滑らかに）
		const cp1x = prev.x + (curr.x - prev.x) * 0.4;
		const cp2x = prev.x + (curr.x - prev.x) * 0.6;

		path += ` C${cp1x.toFixed(1)},${prev.y.toFixed(1)} ${cp2x.toFixed(1)},${curr.y.toFixed(1)} ${curr.x.toFixed(1)},${curr.y.toFixed(1)}`;
	}

	return path;
};

/**
 * スコアに応じたステータスを取得
 * @param score - エネルギースコア (0-100)
 * @returns ステータス文字列（excellent/good/fair/low）
 */
const getEnergyStatus = (score: number): string => {
	if (score >= 85) return t("score.energy.status.excellent");
	if (score >= 65) return t("score.energy.status.good");
	if (score >= 45) return t("score.energy.status.fair");
	return t("score.energy.status.low");
};

// Contributing Factor カードコンポーネント（詳細版）
interface FactorCardProps {
	icon: React.ElementType;
	iconColor: string;
	iconBg: string;
	label: string;
	value: number;
	trend: string;
	trendDirection: TrendDirection;
	detail: string;
}

const FactorCard = ({
	icon: Icon,
	iconColor,
	iconBg,
	label,
	value,
	trend,
	trendDirection,
	detail,
}: FactorCardProps): React.ReactElement => {
	const getTrendColor = () => {
		if (trendDirection === "improving") return colors.emerald[500];
		if (trendDirection === "declining") return colors.rose[500];
		return colors.stone[400];
	};

	return (
		<View
			className="bg-white p-4 rounded-2xl border border-stone-100"
			style={styles.factorCardShadow}
		>
			<View className="flex-row items-center justify-between mb-2">
				<View className="flex-row items-center" style={styles.factorCardHeader}>
					<View className="p-2 rounded-xl" style={{ backgroundColor: iconBg }}>
						<Icon size={16} color={iconColor} />
					</View>
					<Text className="text-xs font-bold text-stone-500 uppercase">
						{label}
					</Text>
				</View>
				<Text className="text-xs font-bold" style={{ color: getTrendColor() }}>
					{trend}
				</Text>
			</View>
			<Text className="text-2xl font-bold text-stone-900 mb-1">{value}%</Text>
			<Text className="text-[10px] text-stone-400">{detail}</Text>
		</View>
	);
};

const EnergyDetailScreen = (): React.ReactElement => {
	const router = useRouter();
	const insets = useSafeAreaInsets();
	const [timeframe, setTimeframe] = useState<Timeframe>("7D");
	const { isLoading, fetchHistoricalData, energyCurve } = useHealthStore();

	// Get computed energy detail data with chart data
	const energyDetail = useEnergyDetail();

	// Fetch historical data on mount if not available
	useEffect(() => {
		if (!energyDetail) {
			fetchHistoricalData("60D");
		}
	}, [energyDetail, fetchHistoricalData]);

	const handleBack = () => {
		router.back();
	};

	// Show loading state
	if (isLoading || !energyDetail) {
		return (
			<View className="flex-1 bg-stone-100 items-center justify-center">
				<ActivityIndicator size="large" color={colors.amber[500]} />
				<Text className="mt-4 text-stone-500">{t("screen.loading.energy")}</Text>
			</View>
		);
	}

	// Extract data from energyDetail
	const {
		score,
		contributingFactors,
		peakFocus,
		afternoonDip,
		analysis,
		chartData,
	} = energyDetail;

	// Daily Curve SVGをレンダリング
	const renderDailyCurve = () => {
		const chartHeight = 100;

		// healthStoreのenergyCurveから動的にSVGパスを生成
		const curvePath = generateEnergyCurveSvgPath(energyCurve, chartHeight);

		// 現在時刻の位置（例: 10:42 = 約40%の位置）
		const now = new Date();
		const currentHour = now.getHours() + now.getMinutes() / 60;
		// 6時〜22時を0〜100%にマッピング
		const currentPosition = Math.max(
			0,
			Math.min(100, ((currentHour - 6) / 16) * 100),
		);

		return (
			<View
				className="bg-white p-5 rounded-3xl border border-stone-100"
				style={styles.chartCard}
			>
				<Text className="text-xs font-bold text-stone-400 uppercase mb-2">
					{t("detail.energy.dailyCurve")}
				</Text>

				{/* Peak Focus と Afternoon Dip のラベル */}
				<View className="flex-row justify-between mb-2">
					<View className="flex-row items-center" style={styles.labelRow}>
						<View className="w-2 h-2 rounded-full bg-amber-500" />
						<Text className="text-[10px] text-stone-500">
							{t("detail.energy.peakFocus")} {peakFocus.start}-{peakFocus.end}
						</Text>
					</View>
					<View className="flex-row items-center" style={styles.labelRow}>
						<View className="w-2 h-2 rounded-full bg-stone-300" />
						<Text className="text-[10px] text-stone-500">
							{t("detail.energy.afternoonDip")} {afternoonDip.start}-
							{afternoonDip.end}
						</Text>
					</View>
				</View>

				<View style={styles.dailyCurveContainer}>
					<Svg
						width="100%"
						height={chartHeight}
						viewBox={`0 0 100 ${chartHeight}`}
						preserveAspectRatio="none"
					>
						<Defs>
							<LinearGradient id="curveGradient" x1="0" y1="0" x2="0" y2="1">
								<Stop
									offset="0"
									stopColor={colors.amber[500]}
									stopOpacity="0.3"
								/>
								<Stop
									offset="1"
									stopColor={colors.amber[500]}
									stopOpacity="0"
								/>
							</LinearGradient>
						</Defs>

						{/* 塗りつぶしエリア */}
						<Path
							d={`${curvePath} V${chartHeight} H0 Z`}
							fill="url(#curveGradient)"
						/>

						{/* 曲線 */}
						<Path
							d={curvePath}
							fill="none"
							stroke={colors.amber[500]}
							strokeWidth={2}
						/>
					</Svg>

					{/* 現在時刻マーカー */}
					<View
						style={[styles.currentTimeMarker, { left: `${currentPosition}%` }]}
					/>
					<View
						style={[styles.currentTimeDot, { left: `${currentPosition}%` }]}
					/>

					{/* 時間軸ラベル (i18n対応) */}
					<View
						className="flex-row justify-between absolute bottom-0 left-0 right-0"
						style={styles.timeLabels}
					>
						<Text className="text-[10px] text-stone-400">
							{t("chart.timeAxis.6")}
						</Text>
						<Text className="text-[10px] text-stone-400">
							{t("chart.timeAxis.12")}
						</Text>
						<Text className="text-[10px] text-stone-400">
							{t("chart.timeAxis.18")}
						</Text>
						<Text className="text-[10px] text-stone-400">
							{t("chart.timeAxis.22")}
						</Text>
					</View>
				</View>
			</View>
		);
	};

	return (
		<View className="flex-1 bg-stone-100">
			<SafeAreaView className="flex-1" edges={["top"]}>
				{/* Header */}
				<View className="flex-row items-center px-6 py-4 border-b border-stone-100 bg-stone-100">
					<Pressable
						onPress={handleBack}
						className="w-10 h-10 items-center justify-center rounded-full"
						style={({ pressed }) => [
							{ backgroundColor: pressed ? colors.stone[100] : "transparent" },
						]}
					>
						<ChevronLeft size={24} color={colors.stone[600]} />
					</Pressable>
					<Text className="text-lg font-bold text-stone-900 ml-4">
						{t("score.energy.label")}
					</Text>
				</View>

				<ScrollView
					contentContainerStyle={{
						paddingBottom: insets.bottom + 32,
					}}
					showsVerticalScrollIndicator={false}
				>
					<View className="px-6 py-6" style={styles.contentContainer}>
						{/* Main Circular Display */}
						<Animated.View
							entering={FadeInDown.duration(400)}
							className="items-center"
						>
							<View className="relative w-48 h-48 items-center justify-center mb-4">
								<CircularProgress
									size={192}
									strokeWidth={16}
									progress={score}
									color={colors.amber[500]}
									backgroundColor={colors.stone[200]}
								/>
								<View className="absolute items-center">
									<Text
										className="text-5xl font-bold text-stone-900"
										style={styles.scoreText}
									>
										{Math.round(score)}%
									</Text>
								</View>
							</View>
							<View
								className="px-4 py-1.5 rounded-full"
								style={styles.statusBadge}
							>
								<Text className="text-xs font-bold text-amber-600 uppercase tracking-widest">
									{getEnergyStatus(score)}
								</Text>
							</View>
						</Animated.View>

						{/* Contributing Factors */}
						<Animated.View
							entering={FadeInDown.delay(100).duration(400)}
							style={styles.contributingFactorsContainer}
						>
							<Text className="text-xs font-bold text-stone-400 uppercase tracking-widest">
								{t("detail.energy.contributingFactors")}
							</Text>
							<View className="flex-row flex-wrap" style={styles.factorGrid}>
								<View style={styles.factorCardWrapper}>
									<FactorCard
										icon={Activity}
										iconColor={colors.emerald[500]}
										iconBg={colors.emerald[50]}
										label={contributingFactors.recovery.label}
										value={contributingFactors.recovery.value}
										trend={contributingFactors.recovery.trendText}
										trendDirection={contributingFactors.recovery.trend}
										detail={contributingFactors.recovery.detail}
									/>
								</View>
								<View style={styles.factorCardWrapper}>
									<FactorCard
										icon={Moon}
										iconColor={colors.indigo[500]}
										iconBg={colors.indigo[50]}
										label={contributingFactors.sleep.label}
										value={contributingFactors.sleep.value}
										trend={contributingFactors.sleep.trendText}
										trendDirection={contributingFactors.sleep.trend}
										detail={contributingFactors.sleep.detail}
									/>
								</View>
								<View style={styles.factorCardWrapper}>
									<FactorCard
										icon={Zap}
										iconColor={colors.amber[500]}
										iconBg={colors.amber[50]}
										label={contributingFactors.activity.label}
										value={contributingFactors.activity.value}
										trend={contributingFactors.activity.trendText}
										trendDirection={contributingFactors.activity.trend}
										detail={contributingFactors.activity.detail}
									/>
								</View>
								<View style={styles.factorCardWrapper}>
									<FactorCard
										icon={ThermometerSun}
										iconColor={colors.blue[500]}
										iconBg={colors.blue[50]}
										label={contributingFactors.weather.label}
										value={contributingFactors.weather.value}
										trend={contributingFactors.weather.trendText}
										trendDirection={contributingFactors.weather.trend}
										detail={contributingFactors.weather.detail}
									/>
								</View>
							</View>
						</Animated.View>

						{/* AI Explanation */}
						<Animated.View
							entering={FadeInDown.delay(200).duration(400)}
							className="bg-amber-50 p-5 rounded-3xl border border-amber-100"
						>
							<Text className="text-sm text-stone-700 leading-relaxed">
								{analysis}
							</Text>
						</Animated.View>

						{/* Daily Curve */}
						<Animated.View entering={FadeInDown.delay(300).duration(400)}>
							{renderDailyCurve()}
						</Animated.View>

						{/* History Chart */}
						<Animated.View
							entering={FadeInDown.delay(400).duration(400)}
							style={styles.chartContainer}
						>
							<TimeframeSelector selected={timeframe} onSelect={setTimeframe} />

							<View
								className="bg-white p-5 rounded-3xl border border-stone-100"
								style={styles.chartCard}
							>
								<Text className="text-xs font-bold text-stone-400 uppercase mb-4">
									{t("detail.energy.history")}
								</Text>
								<HealthAreaChart
									data={chartData[timeframe]}
									colorHex={colors.amber[500]}
									typicalRange={SCORE_TYPICAL_RANGE}
									unit="%"
									height={160}
								/>
							</View>
						</Animated.View>
					</View>
				</ScrollView>
			</SafeAreaView>
		</View>
	);
};

const styles = StyleSheet.create({
	factorCardShadow: {
		shadowColor: colors.black,
		shadowOffset: { width: 0, height: 2 },
		shadowOpacity: 0.04,
		shadowRadius: 6,
		elevation: 2,
	},
	factorCardHeader: {
		gap: 10,
	},
	statusBadge: {
		backgroundColor: colors.amber[50],
	},
	contributingFactorsContainer: {
		gap: 12,
	},
	factorGrid: {
		gap: 12,
	},
	factorCardWrapper: {
		width: "48%",
	},
	contentContainer: {
		gap: 24,
	},
	chartContainer: {
		gap: 16,
	},
	chartCard: {
		shadowColor: colors.black,
		shadowOffset: { width: 0, height: 4 },
		shadowOpacity: 0.06,
		shadowRadius: 10,
		elevation: 4,
	},
	dailyCurveContainer: {
		height: 120,
		position: "relative",
	},
	currentTimeMarker: {
		position: "absolute",
		top: 0,
		bottom: 20,
		width: 2,
		backgroundColor: colors.amber[400],
	},
	currentTimeDot: {
		position: "absolute",
		top: -4,
		width: 8,
		height: 8,
		borderRadius: 4,
		backgroundColor: colors.amber[500],
		marginLeft: -3,
	},
	timeLabels: {
		paddingHorizontal: 4,
	},
	labelRow: {
		gap: 4,
	},
	scoreText: {
		fontFamily: FontFamily.serif,
	},
});

export default EnergyDetailScreen;
