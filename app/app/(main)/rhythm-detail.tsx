/**
 * RhythmDetailScreen - Rhythm詳細画面
 * Simplified to match Recovery screen layout
 */

import { useRouter } from "expo-router";
import { Activity, ChevronLeft } from "lucide-react-native";
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

import {
	CircularProgress,
	HealthAreaChart,
	type Timeframe,
	TimeframeSelector,
} from "../../src/components";
import { SCORE_TYPICAL_RANGE } from "../../src/constants";
import { t } from "../../src/i18n";
import { useHealthStore, useRhythmDetail } from "../../src/stores/healthStore";
import { colors, FontFamily } from "../../src/theme";

// スコアに応じたステータスを取得
const getRhythmStatus = (score: number): string => {
	if (score >= 90) return t("score.rhythm.status.excellent");
	if (score >= 75) return t("score.rhythm.status.good");
	if (score >= 50) return t("score.rhythm.status.fair");
	return t("score.rhythm.status.poor");
};

const RhythmDetailScreen = (): React.ReactElement => {
	const router = useRouter();
	const insets = useSafeAreaInsets();
	const [timeframe, setTimeframe] = useState<Timeframe>("7D");
	const { isLoading, fetchHistoricalData } = useHealthStore();

	// Get computed rhythm detail data with chart data
	const rhythmDetail = useRhythmDetail();

	// Fetch historical data on mount if not available
	useEffect(() => {
		if (!rhythmDetail) {
			fetchHistoricalData("60D");
		}
	}, [rhythmDetail, fetchHistoricalData]);

	const handleBack = () => {
		router.back();
	};

	const getConsistencyColor = (deviationMinutes: number): string => {
		if (deviationMinutes <= 15) return colors.emerald[600];
		if (deviationMinutes <= 30) return colors.amber[500];
		return colors.rose[500];
	};

	const getConsistencyBgColor = (deviationMinutes: number): string => {
		if (deviationMinutes <= 15) return colors.emerald[50];
		if (deviationMinutes <= 30) return colors.amber[50];
		return colors.rose[50];
	};

	// Show loading state
	if (isLoading || !rhythmDetail) {
		return (
			<View className="flex-1 bg-stone-100 items-center justify-center">
				<ActivityIndicator size="large" color={colors.purple[500]} />
				<Text className="mt-4 text-stone-500">{t("screen.loading.rhythm")}</Text>
			</View>
		);
	}

	// Extract data from rhythmDetail
	const { score, consistency, analysis, chartData } = rhythmDetail;

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
						{t("score.rhythm.label")}
					</Text>
				</View>

				<ScrollView
					contentContainerStyle={{
						paddingBottom: insets.bottom + 32,
					}}
					showsVerticalScrollIndicator={false}
				>
					<View className="px-6 py-6" style={styles.container}>
						{/* Main Circular Display */}
						<Animated.View
							entering={FadeInDown.duration(400)}
							className="items-center"
						>
							<View className="relative w-48 h-48 items-center justify-center">
								<CircularProgress
									size={192}
									strokeWidth={16}
									progress={score}
									color={colors.purple[500]}
									backgroundColor={colors.stone[200]}
								/>
								<View className="absolute items-center">
									<Text className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-1">
										{getRhythmStatus(score)}
									</Text>
									<Text
										className="text-5xl font-bold text-stone-900"
										style={styles.scoreText}
									>
										{Math.round(score)}%
									</Text>
								</View>
							</View>
						</Animated.View>

						{/* Consistency Metrics Row */}
						<Animated.View
							entering={FadeInDown.delay(100).duration(400)}
							className="flex-row"
							style={styles.metricsRow}
						>
							<View
								className="flex-1 bg-white p-4 rounded-2xl border border-stone-100 items-center"
								style={styles.metricCard}
							>
								<Text
									className="text-xs font-bold text-stone-400 uppercase text-center"
									numberOfLines={1}
								>
									{t("detail.rhythm.bedtimeConsistency")}
								</Text>
								<Text className="text-2xl font-bold text-stone-900 my-1">
									{consistency.bedtime.deviationText}
								</Text>
								<View
									className="px-2 py-0.5 rounded-full"
									style={{
										backgroundColor: getConsistencyBgColor(
											consistency.bedtime.deviationMinutes,
										),
									}}
								>
									<Text
										className="text-xs font-bold"
										style={{
											color: getConsistencyColor(
												consistency.bedtime.deviationMinutes,
											),
										}}
									>
										{t("detail.rhythm.target")}: {consistency.bedtime.target}
									</Text>
								</View>
							</View>

							<View
								className="flex-1 bg-white p-4 rounded-2xl border border-stone-100 items-center"
								style={styles.metricCard}
							>
								<Text
									className="text-xs font-bold text-stone-400 uppercase text-center"
									numberOfLines={1}
								>
									{t("detail.rhythm.wakeConsistency")}
								</Text>
								<Text className="text-2xl font-bold text-stone-900 my-1">
									{consistency.wakeTime.deviationText}
								</Text>
								<View
									className="px-2 py-0.5 rounded-full"
									style={{
										backgroundColor: getConsistencyBgColor(
											consistency.wakeTime.deviationMinutes,
										),
									}}
								>
									<Text
										className="text-xs font-bold"
										style={{
											color: getConsistencyColor(
												consistency.wakeTime.deviationMinutes,
											),
										}}
									>
										{t("detail.rhythm.target")}: {consistency.wakeTime.target}
									</Text>
								</View>
							</View>
						</Animated.View>

						{/* AI Explanation Card */}
						<Animated.View
							entering={FadeInDown.delay(200).duration(400)}
							className="bg-purple-50 p-5 rounded-3xl border border-purple-100"
						>
							<View className="flex-row items-center mb-3" style={{ gap: 8 }}>
								<Activity size={18} color={colors.purple[600]} />
								<Text className="text-sm font-bold text-stone-900">
									{t("detail.rhythm.analysis")}
								</Text>
							</View>
							<Text className="text-sm text-stone-700 leading-relaxed">
								{analysis}
							</Text>
						</Animated.View>

						{/* History Chart */}
						<Animated.View
							entering={FadeInDown.delay(300).duration(400)}
							style={styles.chartSection}
						>
							<TimeframeSelector selected={timeframe} onSelect={setTimeframe} />

							<View
								className="bg-white p-5 rounded-3xl border border-stone-100"
								style={styles.chartCard}
							>
								<Text className="text-xs font-bold text-stone-400 uppercase mb-4">
									{t("detail.rhythm.dailyRhythm")}
								</Text>
								<HealthAreaChart
									data={chartData?.[timeframe] ?? []}
									colorHex={colors.purple[500]}
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
	container: {
		gap: 32,
	},
	scoreText: {
		fontFamily: FontFamily.serif,
	},
	metricsRow: {
		gap: 16,
	},
	metricCard: {
		shadowColor: colors.black,
		shadowOffset: { width: 0, height: 2 },
		shadowOpacity: 0.04,
		shadowRadius: 6,
		elevation: 2,
	},
	chartSection: {
		gap: 16,
	},
	chartCard: {
		shadowColor: colors.black,
		shadowOffset: { width: 0, height: 4 },
		shadowOpacity: 0.06,
		shadowRadius: 10,
		elevation: 4,
	},
});

export default RhythmDetailScreen;
