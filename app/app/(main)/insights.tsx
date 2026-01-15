/**
 * InsightsScreen - インサイト画面
 * sozai/tempoai/screens/InsightsScreen.tsx を React Native で完全再現
 */

import { LinearGradient } from "expo-linear-gradient";
import {
	AlertCircle,
	ArrowRight,
	Calendar,
	CheckCircle2,
	type LucideIcon,
	TrendingUp,
} from "lucide-react-native";
import type React from "react";
import { Pressable, ScrollView, StyleSheet, Text, View } from "react-native";
import Animated, { FadeInDown } from "react-native-reanimated";
import {
	SafeAreaView,
	useSafeAreaInsets,
} from "react-native-safe-area-context";
import { t } from "../../src/i18n";
import { colors, FontFamily } from "../../src/theme";
import { TAB_BAR_HEIGHT } from "./_layout";

// モックデータ
const MOCK_DATA = {
	avgScore: 74,
	todayIndex: 1, // Tuesday
	weeklyScores: [40, 60, 75, 45, 80, 90, 70],
};

const WEEKDAYS = ["M", "T", "W", "T", "F", "S", "S"];

// Alert configurations
interface AlertConfig {
	Icon: LucideIcon;
	color: string;
	bg: string;
	title: string;
	desc: string;
	time: string;
}

// Note: Alert translations are in ja.json under alert.*
const getAlerts = (): AlertConfig[] => [
	{
		Icon: CheckCircle2,
		color: colors.emerald[500],
		bg: colors.emerald[50],
		title: t("alert.recoveryComplete.title"),
		desc: t("alert.recoveryComplete.description"),
		time: t("alert.recoveryComplete.time"),
	},
	{
		Icon: AlertCircle,
		color: colors.amber[500],
		bg: colors.amber[50],
		title: t("alert.lateCaffeine.title"),
		desc: t("alert.lateCaffeine.description"),
		time: t("alert.lateCaffeine.time"),
	},
	{
		Icon: Calendar,
		color: colors.indigo[500],
		bg: colors.indigo[50],
		title: t("alert.weekendJetlag.title"),
		desc: t("alert.weekendJetlag.description"),
		time: t("alert.weekendJetlag.time"),
	},
];

// Alert Item Component
const AlertItem: React.FC<{ alert: AlertConfig; delay: number }> = ({
	alert,
	delay,
}) => {
	const { Icon, color, bg, title, desc, time } = alert;

	return (
		<Animated.View
			entering={FadeInDown.delay(delay).duration(400)}
			className="bg-white p-4 rounded-2xl border border-stone-100 flex-row items-start"
			style={styles.alertItem}
		>
			<View className="p-2 rounded-xl mt-0.5" style={{ backgroundColor: bg }}>
				<Icon size={20} color={color} />
			</View>
			<View className="flex-1">
				<View className="flex-row justify-between items-center mb-1">
					<Text className="font-bold text-stone-900 text-sm">{title}</Text>
					<Text className="text-[10px] text-stone-400 font-medium">{time}</Text>
				</View>
				<Text className="text-xs text-stone-500 leading-relaxed">{desc}</Text>
			</View>
		</Animated.View>
	);
};

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

const InsightsScreen = (): React.ReactElement => {
	const insets = useSafeAreaInsets();

	return (
		<View className="flex-1 bg-stone-100">
			<SafeAreaView className="flex-1" edges={["top"]}>
				<ScrollView
					contentContainerStyle={[
						styles.scrollContent,
						{ paddingBottom: TAB_BAR_HEIGHT + insets.bottom + 24 },
					]}
					showsVerticalScrollIndicator={false}
				>
					{/* Header */}
					<Animated.View
						entering={FadeInDown.duration(400)}
						className="pt-14 px-6 mb-6"
					>
						<Text
							className="text-3xl text-stone-900 tracking-tight mb-1"
							style={styles.headerTitle}
						>
							Insights
						</Text>
						<Text className="text-sm text-stone-500">
							{t("screen.insights.subtitle")}
						</Text>
					</Animated.View>

					<View className="px-6" style={styles.mainContainer}>
						{/* Weekly Strip */}
						<Animated.View
							entering={FadeInDown.delay(100).duration(400)}
							className="bg-white p-4 rounded-2xl border border-stone-100"
							style={styles.weeklyCard}
						>
							<View className="flex-row justify-between items-center mb-4">
								<Text className="text-sm font-bold text-stone-800">
									{t("screen.insights.thisWeek")}
								</Text>
								<View className="bg-indigo-50 px-2 py-1 rounded-md">
									<Text className="text-xs font-medium text-indigo-500">
										{t("screen.insights.avgScore")}: {MOCK_DATA.avgScore}
									</Text>
								</View>
							</View>

							<View
								className="flex-row justify-between items-end pb-2"
								style={styles.barContainerHeight}
							>
								{MOCK_DATA.weeklyScores.map((score, i) => {
									const isToday = i === MOCK_DATA.todayIndex;
									return (
										<View
											key={i}
											className="flex-1 items-center h-full"
											style={styles.barItem}
										>
											{/* Bar Track */}
											<View className="flex-1 w-2 bg-stone-100 rounded-full overflow-hidden justify-end">
												<View
													className="w-full rounded-full"
													style={{
														height: `${score}%`,
														backgroundColor: isToday
															? colors.indigo[500]
															: colors.indigo[300],
														opacity: isToday ? 1 : 0.6,
													}}
												/>
											</View>
											{/* Day Label */}
											<View className="items-center h-4 justify-start">
												<Text
													className="text-[10px] font-bold leading-none"
													style={{
														color: isToday
															? colors.indigo[600]
															: colors.stone[400],
													}}
												>
													{WEEKDAYS[i]}
												</Text>
												{isToday && (
													<View className="w-1 h-1 bg-indigo-500 rounded-full mt-1" />
												)}
											</View>
										</View>
									);
								})}
							</View>
						</Animated.View>

						{/* Discovery Card */}
						<AnimatedPressable
							entering={FadeInDown.delay(200).duration(400)}
							style={({ pressed }) => [
								styles.discoveryCardPressable,
								pressed && styles.discoveryCardPressed,
							]}
						>
							<LinearGradient
								colors={[colors.indigo[400], colors.indigo[600]]}
								start={{ x: 0, y: 0 }}
								end={{ x: 1, y: 1 }}
								style={styles.discoveryGradient}
							>
								<View
									className="flex-row items-center mb-4"
									style={styles.discoveryHeader}
								>
									<View style={styles.discoveryIconBg}>
										<TrendingUp size={16} color="#FFFFFF" />
									</View>
									<Text className="text-xs font-bold text-white/90 uppercase tracking-wider">
										{t("screen.insights.topDiscovery")}
									</Text>
								</View>
								<Text
									className="text-[22px] font-bold text-white mb-3"
									style={styles.discoveryTitle}
								>
									{t("screen.insights.topDiscoveryTitle")}
								</Text>
								<Text
									className="text-sm text-white/80 mb-5"
									style={styles.discoveryDescription}
								>
									{t("screen.insights.topDiscoveryDescription")}
								</Text>
								<View
									className="flex-row items-center self-start"
									style={styles.discoveryButton}
								>
									<Text className="text-sm font-semibold text-white mr-2">
										{t("screen.insights.viewDetails")}
									</Text>
									<ArrowRight size={14} color="#FFFFFF" />
								</View>
							</LinearGradient>
						</AnimatedPressable>

						{/* Recent Alerts */}
						<View className="pt-2">
							<Animated.View entering={FadeInDown.delay(300).duration(400)}>
								<Text className="text-sm font-bold text-stone-900 uppercase tracking-wide mb-4">
									{t("screen.insights.recentAlerts")}
								</Text>
							</Animated.View>
							<View style={styles.alertsContainer}>
								{getAlerts().map((alert, index) => (
									<AlertItem
										key={index}
										alert={alert}
										delay={350 + index * 50}
									/>
								))}
							</View>
						</View>
					</View>
				</ScrollView>
			</SafeAreaView>
		</View>
	);
};

const styles = StyleSheet.create({
	scrollContent: {
		// Dynamic paddingBottom will be merged
	},
	headerTitle: {
		fontFamily: FontFamily.serif,
	},
	mainContainer: {
		gap: 32,
	},
	weeklyCard: {
		shadowColor: colors.stone[900],
		shadowOffset: { width: 0, height: 4 },
		shadowOpacity: 0.06,
		shadowRadius: 20,
		elevation: 4,
	},
	barContainerHeight: {
		height: 96,
	},
	barItem: {
		gap: 8,
	},
	discoveryCardPressable: {
		borderRadius: 24,
		overflow: "hidden",
	},
	discoveryCardPressed: {
		transform: [{ scale: 0.98 }],
	},
	discoveryGradient: {
		borderRadius: 24,
		padding: 24,
		shadowColor: colors.indigo[500],
		shadowOffset: { width: 0, height: 12 },
		shadowOpacity: 0.4,
		shadowRadius: 24,
		elevation: 12,
	},
	discoveryHeader: {
		gap: 8,
	},
	discoveryIconBg: {
		backgroundColor: "rgba(255, 255, 255, 0.2)",
		padding: 8,
		borderRadius: 10,
	},
	discoveryTitle: {
		lineHeight: 30,
	},
	discoveryDescription: {
		lineHeight: 22,
	},
	discoveryButton: {
		backgroundColor: "rgba(255, 255, 255, 0.15)",
		paddingHorizontal: 16,
		paddingVertical: 10,
		borderRadius: 12,
	},
	alertsContainer: {
		gap: 16,
	},
	alertItem: {
		gap: 16,
	},
});

export default InsightsScreen;
