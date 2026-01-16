/**
 * SleepDetailScreen - Sleep詳細画面
 */

import { useRouter } from "expo-router";
import { ChevronLeft, Moon, Sparkles, Sun } from "lucide-react-native";
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
	DualRingProgress,
	HealthAreaChart,
	SleepStagesBar,
	type Timeframe,
	TimeframeSelector,
} from "../../src/components";
import { SCORE_TYPICAL_RANGE } from "../../src/constants";
import { t } from "../../src/i18n";
import { useHealthStore, useSleepDetail } from "../../src/stores/healthStore";
import { colors, FontFamily } from "../../src/theme";

// スコアに応じたステータスを取得
const getSleepStatus = (score: number): string => {
	if (score >= 85) return t("score.sleep.status.excellent");
	if (score >= 70) return t("score.sleep.status.good");
	if (score >= 50) return t("score.sleep.status.fair");
	return t("score.sleep.status.poor");
};

const SleepDetailScreen = (): React.ReactElement => {
	const router = useRouter();
	const insets = useSafeAreaInsets();
	const [timeframe, setTimeframe] = useState<Timeframe>("7D");
	const { isLoading, fetchHistoricalData } = useHealthStore();

	// Get computed sleep detail data with chart data
	const sleepDetail = useSleepDetail();

	// Fetch historical data on mount if not available
	useEffect(() => {
		if (!sleepDetail) {
			fetchHistoricalData("60D");
		}
	}, [sleepDetail, fetchHistoricalData]);

	const handleBack = () => {
		router.back();
	};

	// Show loading state
	if (isLoading || !sleepDetail) {
		return (
			<View className="flex-1 bg-stone-100 items-center justify-center">
				<ActivityIndicator size="large" color={colors.indigo[500]} />
				<Text className="mt-4 text-stone-500">{t("screen.loading.sleep")}</Text>
			</View>
		);
	}

	// Extract data from sleepDetail
	const { score, duration, quality, stages, timing, analysis, chartData } =
		sleepDetail;

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
						{t("score.sleep.label")}
					</Text>
				</View>

				<ScrollView
					contentContainerStyle={{
						paddingBottom: insets.bottom + 32,
					}}
					showsVerticalScrollIndicator={false}
				>
					<View className="px-6 py-6" style={styles.container}>
						{/* Main Dual Ring Display */}
						<Animated.View
							entering={FadeInDown.duration(400)}
							className="items-center"
							style={styles.mainDisplay}
						>
							<View className="relative w-64 h-64 items-center justify-center">
								<DualRingProgress
									size={256}
									strokeWidth={12}
									innerProgress={quality.percentage}
									outerProgress={duration.percentage}
									innerColor={colors.indigo[400]}
									outerColor={colors.indigo[600]}
									backgroundColor={colors.indigo[100]}
								/>
								<View className="absolute items-center">
									<Moon
										size={24}
										color={colors.indigo[500]}
										style={styles.moonIcon}
									/>
									<Text
										className="text-3xl font-bold text-stone-900"
										style={styles.scoreText}
									>
										{Math.round(score)}%
									</Text>
									<Text className="text-[10px] font-bold text-indigo-500 uppercase tracking-widest">
										{getSleepStatus(score)}
									</Text>
								</View>
							</View>

							<View
								className="flex-row items-center w-full justify-center"
								style={styles.metricsRow}
							>
								<View className="items-center">
									<Text className="text-xs font-bold text-indigo-500 uppercase mb-1">
										{t("detail.sleep.duration")}
									</Text>
									<Text className="text-xl font-bold text-stone-900">
										{duration.hours}h {duration.minutes}m
									</Text>
								</View>
								<View className="w-px h-8 bg-stone-200" />
								<View className="items-center">
									<View
										className="flex-row items-center mb-1"
										style={styles.qualityRow}
									>
										<Text className="text-xs font-bold text-indigo-400 uppercase">
											{t("detail.sleep.quality")}
										</Text>
										<Sparkles size={10} color={colors.indigo[400]} />
									</View>
									<Text className="text-xl font-bold text-stone-900">
										{quality.percentage}%
									</Text>
								</View>
							</View>
						</Animated.View>

						{/* AI Explanation */}
						<Animated.View
							entering={FadeInDown.delay(100).duration(400)}
							className="bg-indigo-50 p-5 rounded-3xl border border-indigo-100"
						>
							<Text className="text-sm text-stone-700 leading-relaxed">
								{analysis}
							</Text>
						</Animated.View>

						{/* Sleep Stages Breakdown */}
						<Animated.View
							entering={FadeInDown.delay(200).duration(400)}
							style={styles.section}
						>
							<Text className="text-xs font-bold text-stone-400 uppercase tracking-widest">
								{t("detail.sleep.sleepStages")}
							</Text>
							<View
								className="bg-white p-5 rounded-3xl border border-stone-100"
								style={styles.cardShadow}
							>
								<SleepStagesBar stages={stages} />
							</View>
						</Animated.View>

						{/* Timing Details */}
						<Animated.View
							entering={FadeInDown.delay(300).duration(400)}
							className="flex-row"
							style={styles.section}
						>
							<View
								className="flex-1 bg-white p-4 rounded-2xl border border-stone-100"
								style={styles.cardShadow}
							>
								<View
									className="flex-row items-center mb-2"
									style={styles.timingRow}
								>
									<Moon size={16} color={colors.indigo[500]} />
									<Text className="text-xs font-bold text-stone-400 uppercase">
										{t("detail.sleep.bedtime")}
									</Text>
								</View>
								<Text className="text-xl font-bold text-stone-900">
									{timing.bedtime.actual}
								</Text>
								<Text className="text-[10px] text-amber-500 font-medium mt-1">
									{t("detail.sleep.target")}: {timing.bedtime.target} (
									{timing.bedtime.diffText})
								</Text>
							</View>

							<View
								className="flex-1 bg-white p-4 rounded-2xl border border-stone-100"
								style={styles.cardShadow}
							>
								<View
									className="flex-row items-center mb-2"
									style={styles.timingRow}
								>
									<Sun size={16} color={colors.amber[500]} />
									<Text className="text-xs font-bold text-stone-400 uppercase">
										{t("detail.sleep.wakeTime")}
									</Text>
								</View>
								<Text className="text-xl font-bold text-stone-900">
									{timing.wakeTime.actual}
								</Text>
								<Text className="text-[10px] text-emerald-500 font-medium mt-1">
									{t("detail.sleep.target")}: {timing.wakeTime.target} (
									{timing.wakeTime.diffText})
								</Text>
							</View>
						</Animated.View>

						{/* History Chart */}
						<Animated.View
							entering={FadeInDown.delay(400).duration(400)}
							style={styles.section}
						>
							<TimeframeSelector selected={timeframe} onSelect={setTimeframe} />

							<View
								className="bg-white p-5 rounded-3xl border border-stone-100"
								style={styles.cardShadow}
							>
								<Text className="text-xs font-bold text-stone-400 uppercase mb-4">
									{t("detail.sleep.history")}
								</Text>
								<HealthAreaChart
									data={chartData?.[timeframe] ?? []}
									colorHex={colors.indigo[500]}
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
	mainDisplay: {
		gap: 24,
	},
	moonIcon: {
		marginBottom: 4,
	},
	scoreText: {
		fontFamily: FontFamily.serif,
	},
	metricsRow: {
		gap: 32,
	},
	qualityRow: {
		gap: 4,
	},
	section: {
		gap: 16,
	},
	cardShadow: {
		shadowColor: colors.black,
		shadowOffset: { width: 0, height: 4 },
		shadowOpacity: 0.06,
		shadowRadius: 10,
		elevation: 4,
	},
	timingRow: {
		gap: 8,
	},
});

export default SleepDetailScreen;
