/**
 * TodayScreen - メインホーム画面
 * sozai/tempoai/screens/TodayScreen.tsx を React Native で完全再現
 */

import { useRouter } from "expo-router";
import {
	Activity,
	ArrowRight,
	ChevronRight,
	Droplets,
	Footprints,
	Heart,
	Sparkles,
	Target,
	Thermometer,
	Wind,
} from "lucide-react-native";
import type React from "react";
import { useEffect } from "react";
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
import { BreatheFAB } from "../../src/components/BreatheFAB";
import {
	type HealthCard,
	HealthSummaryCard,
} from "../../src/components/today/HealthSummaryCard";
import {
	type MetricCard,
	MetricGridCard,
} from "../../src/components/today/MetricGridCard";
import type {
	HealthMetricHistory,
	RealtimeMetrics,
} from "../../src/domain/models";
import { t } from "../../src/i18n";
import {
	useHealthStore,
	useScoreChartDataForToday,
} from "../../src/stores/healthStore";
import type { HealthSummaryHistory } from "../../src/stores/healthStore/types";
import {
	selectTodayInsight,
	selectTodayOneThing,
	useInsightStore,
} from "../../src/stores/insightStore";
import { useOnboardingStore } from "../../src/stores/onboardingStore";
import { selectNickname, useUserStore } from "../../src/stores/userStore";
import { colors, FontFamily } from "../../src/theme";
import { formatDate, getGreeting } from "../../src/utils/dateFormatters";
import { TAB_BAR_HEIGHT } from "./_layout";

const getMetricCards = (
	scores?: {
		recovery: number;
		sleep: number;
		rhythm: number;
		energy: number;
	},
	chartData?: {
		recovery: number[];
		sleep: number[];
		rhythm: number[];
		energy: number[];
	},
): MetricCard[] => [
	{
		id: "recovery",
		title: t("score.recovery.label"),
		value: scores ? `${Math.round(scores.recovery)}%` : "--",
		colorText: colors.emerald[600],
		colorAccent: colors.emerald[500],
		chartData: chartData?.recovery ?? [0, 0, 0, 0, 0, 0, scores?.recovery ?? 0],
		route: "/recovery-detail",
	},
	{
		id: "sleep",
		title: t("score.sleep.label"),
		value: scores ? `${Math.round(scores.sleep)}%` : "--",
		colorText: colors.indigo[600],
		colorAccent: colors.indigo[500],
		chartData: chartData?.sleep ?? [0, 0, 0, 0, 0, 0, scores?.sleep ?? 0],
		route: "/sleep-detail",
	},
	{
		id: "rhythm",
		title: t("score.rhythm.label"),
		value: scores ? `${Math.round(scores.rhythm)}%` : "--",
		colorText: colors.purple[600],
		colorAccent: colors.purple[500],
		chartData: chartData?.rhythm ?? [0, 0, 0, 0, 0, 0, scores?.rhythm ?? 0],
		route: "/rhythm-detail",
	},
	{
		id: "energy",
		title: t("score.energy.label"),
		value: scores ? `${Math.round(scores.energy)}%` : "--",
		colorText: colors.amber[600],
		colorAccent: colors.amber[500],
		chartData: chartData?.energy ?? [0, 0, 0, 0, 0, 0, scores?.energy ?? 0],
		route: "/energy-detail",
	},
];

/**
 * 履歴データから直近7日分のchartDataを生成
 */
const extractChartData = (
	history: HealthMetricHistory | null | undefined,
): number[] => {
	if (!history?.samples?.length) {
		return [0, 0, 0, 0, 0, 0, 0];
	}
	const samples = [...history.samples];
	const last7 = samples.slice(-7);
	// 7件未満の場合は先頭を埋める
	while (last7.length < 7) {
		last7.unshift(last7[0] ?? { value: 0, date: new Date() });
	}
	return last7.map((s) => s.value);
};

/**
 * Health Summary カードのデータを生成（ストアから動的取得）
 * @param realtimeMetrics - リアルタイムメトリクス
 * @param histories - 履歴データ
 * @returns HealthCard配列（HRV, RHR, 呼吸数, SpO2, 体温）
 */
const createHealthCards = (
	realtimeMetrics: RealtimeMetrics | null,
	histories: HealthSummaryHistory | null,
): HealthCard[] => [
	{
		id: "hrv",
		label: t("metric.health.hrv.shortName"),
		value: realtimeMetrics?.hrv?.value?.toString() ?? "--",
		unit: "ms",
		Icon: Activity,
		colorIcon: colors.emerald[500],
		lineColor: colors.emerald[500],
		chartData: extractChartData(histories?.hrv),
	},
	{
		id: "rhr",
		label: t("metric.health.rhr.shortName"),
		value: realtimeMetrics?.rhr?.value?.toString() ?? "--",
		unit: "bpm",
		Icon: Heart,
		colorIcon: colors.rose[500],
		lineColor: colors.rose[500],
		chartData: extractChartData(histories?.rhr),
	},
	{
		id: "resp",
		label: t("metric.health.resp.shortName"),
		value: realtimeMetrics?.respiratory?.value?.toFixed(1) ?? "--",
		unit: "brpm",
		Icon: Wind,
		colorIcon: colors.blue[500],
		lineColor: colors.blue[500],
		chartData: extractChartData(histories?.respiratory),
	},
	{
		id: "spo2",
		label: t("metric.health.spo2.shortName"),
		value: realtimeMetrics?.spo2?.value?.toString() ?? "--",
		unit: "%",
		Icon: Droplets,
		colorIcon: colors.teal[500],
		lineColor: colors.teal[500],
		chartData: extractChartData(histories?.spo2),
	},
	{
		id: "temp",
		label: t("metric.health.temp.shortName"),
		value: realtimeMetrics?.wristTemp?.value?.toFixed(1) ?? "--",
		unit: "°C",
		Icon: Thermometer,
		colorIcon: colors.amber[500],
		lineColor: colors.amber[500],
		chartData: extractChartData(histories?.wristTemp),
	},
];

const TodayScreen = (): React.ReactElement => {
	const router = useRouter();
	const insets = useSafeAreaInsets();
	const {
		dailySnapshot,
		isLoading,
		initialize,
		realtimeMetrics,
		healthSummaryHistory,
		fetchHistoricalData,
	} = useHealthStore();
	const nickname = useUserStore(selectNickname);
	const language = useOnboardingStore((state) => state.language);
	const todayInsight = useInsightStore(selectTodayInsight);
	const todayOneThing = useInsightStore(selectTodayOneThing);
	const { initializeWithMockData } = useInsightStore();

	// スコア履歴からchartDataを取得
	const scoreChartData = useScoreChartDataForToday();

	// 初回レンダリング時に初期化（データ取得 + 計算）
	useEffect(() => {
		initialize();
		initializeWithMockData();
		// スコア履歴データも取得（chartData用）
		fetchHistoricalData("7D");
	}, [initialize, initializeWithMockData, fetchHistoricalData]);

	// healthStoreから計算済みのスコアを取得
	const scores = dailySnapshot?.scores;

	const healthCards = createHealthCards(realtimeMetrics, healthSummaryHistory);
	const metricCards = getMetricCards(scores, scoreChartData);

	const greeting = getGreeting(nickname || undefined, language);
	const today = formatDate(new Date(), language);

	// ローディング表示
	if (isLoading) {
		return (
			<View style={styles.loadingContainer}>
				<SafeAreaView style={styles.loadingSafeArea}>
					<View style={styles.loadingContent}>
						<ActivityIndicator size="large" color={colors.stone[900]} />
						<Text style={styles.loadingText}>{t("common.loading")}</Text>
					</View>
				</SafeAreaView>
			</View>
		);
	}

	return (
		<View className="flex-1 bg-stone-50">
			{/* Breathe Floating Action Button - outside SafeAreaView for proper positioning */}
			<BreatheFAB />
			<SafeAreaView className="flex-1" edges={["top"]}>
				<ScrollView
					contentContainerStyle={{
						paddingBottom: TAB_BAR_HEIGHT + insets.bottom + 24,
					}}
					showsVerticalScrollIndicator={false}
				>
					{/* Header */}
					<Animated.View
						entering={FadeInDown.duration(400)}
						className="pt-14 px-6 mb-6"
					>
						<Text
							className="text-2xl font-bold text-stone-900 tracking-tight"
							style={styles.headerTitle}
						>
							{greeting}
						</Text>
						<Text
							className="text-sm font-medium text-stone-500 uppercase mt-1"
							style={styles.headerDate}
						>
							{today}
						</Text>
					</Animated.View>

					<View className="px-6" style={styles.contentContainer}>
						{/* 2x2 Metric Grid */}
						<Animated.View
							entering={FadeInDown.delay(100).duration(400)}
							style={styles.metricGridContainer}
						>
							<View className="flex-row" style={styles.metricRow}>
								<View style={styles.metricCardWrapper}>
									<MetricGridCard metric={metricCards[0]} />
								</View>
								<View style={styles.metricCardWrapper}>
									<MetricGridCard metric={metricCards[1]} />
								</View>
							</View>
							<View className="flex-row" style={styles.metricRow}>
								<View style={styles.metricCardWrapper}>
									<MetricGridCard metric={metricCards[2]} />
								</View>
								<View style={styles.metricCardWrapper}>
									<MetricGridCard metric={metricCards[3]} />
								</View>
							</View>
						</Animated.View>

						{/* AI Insight Section */}
						<Animated.View
							entering={FadeInDown.delay(200).duration(400)}
							style={styles.sectionContainer}
						>
							<View
								className="flex-row items-center px-1"
								style={styles.sectionHeader}
							>
								<Sparkles size={18} color={colors.indigo[500]} />
								<Text
									className="text-sm font-bold text-stone-400 uppercase"
									style={styles.sectionTitle}
								>
									{t("screen.today.aiInsight")}
								</Text>
							</View>
							<Pressable
								onPress={() => router.push("/insight-detail")}
								className="bg-white p-5 rounded-3xl border border-stone-100 overflow-hidden"
								style={({ pressed }) => [
									styles.insightCardShadow,
									pressed && { transform: [{ scale: 0.98 }], opacity: 0.9 },
								]}
							>
								{/* Left accent bar - 紫の縦線 (absolute positioning) */}
								<View style={[styles.accentBar, styles.insightAccentBar]} />
								<Text className="text-lg font-bold text-stone-900 mb-2">
									{todayInsight?.title ?? t("common.loading")}
								</Text>
								<Text className="text-sm text-stone-600 leading-relaxed mb-4">
									{todayInsight?.summary ?? ""}
								</Text>
								<View
									className="flex-row items-center"
									style={styles.viewAnalysisContainer}
								>
									<Text className="text-xs font-bold text-indigo-600">
										{t("screen.today.viewAnalysis")}
									</Text>
									<ArrowRight size={14} color={colors.indigo[600]} />
								</View>
							</Pressable>
						</Animated.View>

						{/* Today's One Thing Section */}
						<Animated.View
							entering={FadeInDown.delay(300).duration(400)}
							style={styles.sectionContainer}
						>
							<View
								className="flex-row items-center px-1"
								style={styles.sectionHeader}
							>
								<Target size={18} color={colors.amber[500]} />
								<Text
									className="text-sm font-bold text-stone-400 uppercase"
									style={styles.sectionTitle}
								>
									{t("screen.today.todayOneThing.title")}
								</Text>
							</View>
							<Pressable
								onPress={() => router.push("/action-detail")}
								className="bg-white p-6 rounded-3xl border border-stone-100 overflow-hidden flex-row items-center justify-between"
								style={({ pressed }) => [
									{
										minHeight: 100,
									},
									styles.insightCardShadow,
									pressed && { transform: [{ scale: 0.98 }], opacity: 0.9 },
								]}
							>
								{/* Left accent bar - オレンジの縦線 (absolute positioning) */}
								<View style={[styles.accentBar, styles.actionAccentBar]} />
								<View
									className="flex-row items-center"
									style={styles.actionCardContent}
								>
									<View
										className="p-4 rounded-2xl"
										style={styles.actionIconContainer}
									>
										<Footprints size={28} color={colors.amber[600]} />
									</View>
									<View style={styles.actionTextContainer}>
										<Text className="text-lg font-bold text-stone-900 mb-1">
											{todayOneThing?.action ?? t("common.loading")}
										</Text>
										<Text className="text-sm text-stone-500 font-medium">
											{todayOneThing?.summary ?? ""}
										</Text>
									</View>
								</View>
								<View
									className="p-2.5 rounded-full"
									style={styles.chevronButton}
								>
									<ChevronRight size={22} color={colors.stone[300]} />
								</View>
							</Pressable>
						</Animated.View>

						{/* Health Summary Section */}
						<Animated.View
							entering={FadeInDown.delay(400).duration(400)}
							style={styles.sectionContainer}
						>
							<View className="flex-row items-center justify-between px-1">
								<View
									className="flex-row items-center"
									style={styles.sectionHeader}
								>
									<Activity size={18} color={colors.rose[500]} />
									<Text
										className="text-sm font-bold text-stone-400 uppercase"
										style={styles.sectionTitle}
									>
										{t("screen.today.healthSummary")}
									</Text>
								</View>
								<Pressable onPress={() => router.push("/health-detail")}>
									<ChevronRight size={20} color={colors.stone[300]} />
								</Pressable>
							</View>
						</Animated.View>
					</View>

					{/* Health Summary Horizontal Scroll */}
					<Animated.View entering={FadeInDown.delay(450).duration(400)}>
						<ScrollView
							horizontal
							showsHorizontalScrollIndicator={false}
							contentContainerStyle={styles.healthScrollContent}
						>
							{healthCards.map((card) => (
								<HealthSummaryCard key={card.id} card={card} />
							))}
						</ScrollView>
					</Animated.View>
				</ScrollView>
			</SafeAreaView>
		</View>
	);
};

const styles = StyleSheet.create({
	loadingContainer: {
		flex: 1,
		backgroundColor: colors.stone[50],
	},
	loadingSafeArea: {
		flex: 1,
	},
	loadingContent: {
		flex: 1,
		justifyContent: "center",
		alignItems: "center",
	},
	loadingText: {
		color: colors.stone[600],
		marginTop: 16,
		fontSize: 14,
	},
	headerTitle: {
		fontFamily: FontFamily.serif,
	},
	headerDate: {
		letterSpacing: 1,
	},
	contentContainer: {
		gap: 32,
	},
	metricGridContainer: {
		gap: 16,
	},
	metricRow: {
		gap: 16,
	},
	metricCardWrapper: {
		flex: 1,
	},
	sectionContainer: {
		gap: 12,
	},
	sectionHeader: {
		gap: 8,
	},
	sectionTitle: {
		letterSpacing: 1.5,
	},
	insightCardShadow: {
		shadowColor: colors.black,
		shadowOffset: { width: 0, height: 4 },
		shadowOpacity: 0.06,
		shadowRadius: 8,
		elevation: 3,
	},
	accentBar: {
		position: "absolute",
		top: 0,
		left: 0,
		bottom: 0,
		width: 4,
	},
	insightAccentBar: {
		backgroundColor: colors.indigo[500],
	},
	actionAccentBar: {
		backgroundColor: colors.amber[500],
	},
	viewAnalysisContainer: {
		gap: 4,
	},
	actionCardContent: {
		gap: 20,
		flex: 1,
	},
	actionIconContainer: {
		backgroundColor: colors.amber[50],
	},
	actionTextContainer: {
		flex: 1,
	},
	chevronButton: {
		backgroundColor: colors.stone[50],
	},
	healthScrollContent: {
		paddingHorizontal: 24,
		paddingTop: 8,
		paddingBottom: 32,
		gap: 16,
	},
});

export default TodayScreen;
