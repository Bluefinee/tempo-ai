/**
 * SettingsScreen - Settings Screen
 * Full React Native reproduction of sozai/new/tempoai/screens/SettingsScreen.tsx
 */

import { LinearGradient } from "expo-linear-gradient";
import { useRouter } from "expo-router";
import {
	Bell,
	ChevronRight,
	Heart,
	HelpCircle,
	LogOut,
	type LucideIcon,
	Moon,
	Shield,
	Smartphone,
	Sun,
	Zap,
} from "lucide-react-native";
import type React from "react";
import { useCallback, useEffect, useState } from "react";
import { Alert, Pressable, ScrollView, Text, View } from "react-native";
import Animated, {
	useAnimatedStyle,
	useSharedValue,
	withSpring,
} from "react-native-reanimated";
import {
	SafeAreaView,
	useSafeAreaInsets,
} from "react-native-safe-area-context";
import { useFadeIn } from "../../src/hooks/useFadeIn";
import { t } from "../../src/i18n";
import { useOnboardingStore } from "../../src/stores/onboardingStore";
import { useUserStore } from "../../src/stores/userStore";
import { colors, FontFamily } from "../../src/theme";
import { TAB_BAR_HEIGHT } from "./_layout";

// デフォルト値（userStoreからデータがない場合のフォールバック）
const DEFAULT_TARGET_BEDTIME = "23:00";
const DEFAULT_TARGET_WAKE_UP = "07:00";
const DEFAULT_PLAN = "Free Plan";

// Toggle Switch Component
const ToggleSwitch: React.FC<{
	value: boolean;
	onValueChange: (value: boolean) => void;
}> = ({ value, onValueChange }) => {
	const translateX = useSharedValue(value ? 20 : 0);

	useEffect(() => {
		translateX.value = withSpring(value ? 20 : 0, {
			damping: 15,
			stiffness: 120,
		});
	}, [value, translateX]);

	const thumbStyle = useAnimatedStyle(() => ({
		transform: [{ translateX: translateX.value }],
	}));

	return (
		<Pressable
			onPress={() => onValueChange(!value)}
			className="w-12 h-7 rounded-full p-1 justify-center"
			style={{
				backgroundColor: value ? colors.indigo[500] : colors.stone[200],
			}}
		>
			<Animated.View
				style={[
					thumbStyle,
					{
						width: 20,
						height: 20,
						borderRadius: 10,
						backgroundColor: colors.white,
						shadowColor: colors.black,
						shadowOffset: { width: 0, height: 2 },
						shadowOpacity: 0.15,
						shadowRadius: 4,
						elevation: 3,
					},
				]}
			/>
		</Pressable>
	);
};

// Section Component
const Section: React.FC<{ title: string; children: React.ReactNode }> = ({
	title,
	children,
}) => (
	<View className="mb-8">
		<Text className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-3 ml-2">
			{title}
		</Text>
		<View
			className="bg-white rounded-2xl border border-stone-100 p-2"
			style={{
				shadowColor: colors.black,
				shadowOffset: { width: 0, height: 4 },
				shadowOpacity: 0.06,
				shadowRadius: 20,
				elevation: 4,
			}}
		>
			{children}
		</View>
	</View>
);

// Settings Row Component
interface SettingsRowProps {
	icon: LucideIcon;
	iconColor: string;
	iconBg: string;
	label: string;
	value?: string;
	valueColor?: string;
	showChevron?: boolean;
	onPress?: () => void;
}

const SettingsRow: React.FC<SettingsRowProps> = ({
	icon: Icon,
	iconColor,
	iconBg,
	label,
	value,
	valueColor = colors.stone[400],
	showChevron = true,
	onPress,
}) => (
	<Pressable
		onPress={onPress}
		className="flex-row items-center justify-between p-3 rounded-xl"
		style={({ pressed }) => ({ opacity: pressed && onPress ? 0.7 : 1 })}
	>
		<View className="flex-row items-center" style={{ gap: 12 }}>
			<View className="p-2 rounded-xl" style={{ backgroundColor: iconBg }}>
				<Icon size={18} color={iconColor} />
			</View>
			<Text className="text-sm font-medium text-stone-700">{label}</Text>
		</View>
		<View className="flex-row items-center" style={{ gap: 8 }}>
			{value && (
				<Text className="text-sm" style={{ color: valueColor }}>
					{value}
				</Text>
			)}
			{showChevron && <ChevronRight size={20} color={colors.stone[300]} />}
		</View>
	</Pressable>
);

// Toggle Row Component
interface ToggleRowProps {
	icon: LucideIcon;
	iconColor: string;
	iconBg: string;
	label: string;
	value: boolean;
	onValueChange: (value: boolean) => void;
}

const ToggleRow: React.FC<ToggleRowProps> = ({
	icon: Icon,
	iconColor,
	iconBg,
	label,
	value,
	onValueChange,
}) => (
	<View className="flex-row items-center justify-between p-3">
		<View className="flex-row items-center" style={{ gap: 12 }}>
			<View className="p-2 rounded-xl" style={{ backgroundColor: iconBg }}>
				<Icon size={18} color={iconColor} />
			</View>
			<Text className="text-sm font-medium text-stone-700">{label}</Text>
		</View>
		<ToggleSwitch value={value} onValueChange={onValueChange} />
	</View>
);

const SettingsScreen = (): React.ReactElement => {
	const insets = useSafeAreaInsets();
	const router = useRouter();
	const [notifications, setNotifications] = useState(true);
	const [haptic, setHaptic] = useState(true);

	// userStoreからプロフィール情報を取得
	const profile = useUserStore((state) => state.profile);
	const nickname =
		profile?.nickname ?? t("screen.settings.profile.defaultNickname");
	const targetBedtime = profile?.targetBedtime ?? DEFAULT_TARGET_BEDTIME;
	// targetWakeTimeはprofileにないためchronotypeから推測するか、デフォルト使用
	const targetWakeUp = DEFAULT_TARGET_WAKE_UP;
	const memberSince = profile?.createdAt
		? new Date(profile.createdAt).getFullYear().toString()
		: new Date().getFullYear().toString();

	// Store actions
	const resetUserStore = useUserStore((state) => state.resetUser);
	const resetOnboardingStore = useOnboardingStore((state) => state.reset);

	// Handle reset and sign out
	const handleResetOnboarding = useCallback(() => {
		Alert.alert(
			t("screen.settings.resetAlert.title"),
			t("screen.settings.resetAlert.message"),
			[
				{
					text: t("screen.settings.resetAlert.cancel"),
					style: "cancel",
				},
				{
					text: t("screen.settings.resetAlert.reset"),
					style: "destructive",
					onPress: () => {
						// Reset both stores
						resetUserStore();
						resetOnboardingStore();
						// Navigate to onboarding
						router.replace("/(onboarding)");
					},
				},
			],
		);
	}, [resetUserStore, resetOnboardingStore, router]);

	// Fade-in animations
	const headerFadeIn = useFadeIn(0);
	const contentFadeIn = useFadeIn(100);

	return (
		<View className="flex-1 bg-stone-100">
			<SafeAreaView className="flex-1" edges={["top"]}>
				<ScrollView
					contentContainerStyle={{
						paddingHorizontal: 24,
						paddingBottom: TAB_BAR_HEIGHT + insets.bottom + 24,
					}}
					showsVerticalScrollIndicator={false}
				>
					{/* Header */}
					<Animated.View style={headerFadeIn} className="pt-14 mb-6">
						<Text
							className="text-3xl text-stone-900 tracking-tight mb-1"
							style={{ fontFamily: FontFamily.serif }}
						>
							{t("screen.settings.title")}
						</Text>
						<Text className="text-sm text-stone-500">
							{t("screen.settings.subtitle")}
						</Text>
					</Animated.View>

					<Animated.View style={contentFadeIn}>
						{/* Profile Card */}
						<View
							className="bg-white p-4 rounded-3xl border border-stone-100 flex-row items-center mb-8"
							style={{
								gap: 16,
								shadowColor: colors.black,
								shadowOffset: { width: 0, height: 4 },
								shadowOpacity: 0.06,
								shadowRadius: 20,
								elevation: 4,
							}}
						>
							<LinearGradient
								colors={[colors.indigo[100], colors.rose[100]]}
								start={{ x: 0, y: 0 }}
								end={{ x: 1, y: 1 }}
								className="items-center justify-center"
								style={{ width: 64, height: 64, borderRadius: 32 }}
							>
								<Text style={{ fontSize: 28 }}>🧘</Text>
							</LinearGradient>
							<View className="flex-1">
								<Text className="text-lg font-bold text-stone-900">
									{nickname}
								</Text>
								<Text className="text-xs text-stone-500">
									{DEFAULT_PLAN} •{" "}
									{t("screen.settings.profile.memberSince", {
										year: memberSince,
									})}
								</Text>
							</View>
							<Pressable className="p-2 rounded-full">
								<ChevronRight size={20} color="#A8A29E" />
							</Pressable>
						</View>

						{/* My Rhythm Section */}
						<Section title={t("screen.settings.myRhythm")}>
							<SettingsRow
								icon={Moon}
								iconColor="#6366F1"
								iconBg="#EEF2FF"
								label={t("screen.settings.targetBedtime")}
								value={targetBedtime}
							/>
							<SettingsRow
								icon={Sun}
								iconColor="#F59E0B"
								iconBg="#FFFBEB"
								label={t("screen.settings.targetWakeUp")}
								value={targetWakeUp}
							/>
						</Section>

						{/* Preferences Section */}
						<Section title={t("screen.settings.preferences")}>
							<ToggleRow
								icon={Bell}
								iconColor="#F43F5E"
								iconBg="#FFF1F2"
								label={t("screen.settings.gentleNudges")}
								value={notifications}
								onValueChange={setNotifications}
							/>
							<ToggleRow
								icon={Zap}
								iconColor="#57534E"
								iconBg="#F5F5F4"
								label={t("screen.settings.hapticFeedback")}
								value={haptic}
								onValueChange={setHaptic}
							/>
						</Section>

						{/* Data Source Section */}
						<Section title={t("screen.settings.dataSource")}>
							{/* Apple Health - Connected */}
							<View className="flex-row items-center justify-between p-3">
								<View className="flex-row items-center" style={{ gap: 12 }}>
									<View className="p-2 rounded-xl bg-stone-900">
										<Heart size={18} color="#FFFFFF" fill="#FFFFFF" />
									</View>
									<Text className="text-sm font-medium text-stone-700">
										{t("screen.settings.appleHealth")}
									</Text>
								</View>
								<View className="bg-emerald-50 px-2 py-1 rounded-md">
									<Text className="text-xs font-bold text-emerald-600">
										{t("screen.settings.connected")}
									</Text>
								</View>
							</View>

							{/* Divider */}
							<View className="h-px bg-stone-100 my-2 mx-12" />

							{/* Oura Ring - Connect */}
							<SettingsRow
								icon={Smartphone}
								iconColor="#78716C"
								iconBg="#F5F5F4"
								label={t("screen.settings.ouraRing")}
								value={t("screen.settings.connect")}
								valueColor="#4F46E5"
							/>
						</Section>

						{/* Support Section */}
						<Section title={t("screen.settings.support")}>
							<SettingsRow
								icon={HelpCircle}
								iconColor="#6366F1"
								iconBg="#EEF2FF"
								label={t("screen.settings.helpCenter")}
							/>
							<SettingsRow
								icon={Shield}
								iconColor="#6366F1"
								iconBg="#EEF2FF"
								label={t("screen.settings.privacyPolicy")}
							/>
						</Section>

						{/* Sign Out Button */}
						<Pressable
							onPress={handleResetOnboarding}
							className="flex-row items-center justify-center py-4 rounded-2xl border border-rose-100 mb-8"
							style={({ pressed }) => ({
								gap: 8,
								backgroundColor: "rgba(255, 241, 242, 0.5)",
								opacity: pressed ? 0.7 : 1,
							})}
						>
							<LogOut size={16} color="#E11D48" />
							<Text className="text-sm font-medium text-rose-600">
								{t("screen.settings.resetSignOut")}
							</Text>
						</Pressable>

						{/* Version */}
						<View className="items-center pb-8">
							<Text className="text-xs font-medium text-stone-400 font-mono">
								{t("screen.settings.version")}
							</Text>
						</View>
					</Animated.View>
				</ScrollView>
			</SafeAreaView>
		</View>
	);
};

export default SettingsScreen;
