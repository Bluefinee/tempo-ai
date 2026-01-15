/**
 * Main Layout - タブナビゲーション
 * sozai/new/components/Navigation.tsx を React Native で完全再現
 */

import { BlurView } from "expo-blur";
import * as Haptics from "expo-haptics";
import { Tabs } from "expo-router";
import { Activity, Home, Settings } from "lucide-react-native";
import type React from "react";
import { Platform, StyleSheet } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
// import { BarChart3 } from "lucide-react-native"; // Insights タブ復活時に使用
import { Colors, FontFamily } from "../../src/theme";

// タブバーの基本高さ（SafeArea除く）
const TAB_BAR_BASE_HEIGHT = 60;

const handleTabPress = (): void => {
	if (Platform.OS === "ios") {
		Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
	}
};

const MainLayout = (): React.ReactElement => {
	const insets = useSafeAreaInsets();
	const tabBarHeight = TAB_BAR_BASE_HEIGHT + insets.bottom;

	return (
		<Tabs
			screenOptions={{
				headerShown: false,
				tabBarActiveTintColor: Colors.indigo[500],
				tabBarInactiveTintColor: Colors.stone[400],
				tabBarBackground: () => (
					<BlurView
						intensity={80}
						tint="light"
						style={StyleSheet.absoluteFill}
					/>
				),
				tabBarStyle: {
					position: "absolute",
					backgroundColor: "rgba(255, 255, 255, 0.8)",
					borderTopWidth: 1,
					borderTopColor: Colors.stone[200],
					height: tabBarHeight,
					paddingBottom: insets.bottom,
					paddingTop: 6,
				},
				tabBarLabelStyle: {
					fontFamily: FontFamily.medium,
					fontSize: 10,
					fontWeight: "500",
					marginTop: -2,
				},
				tabBarIconStyle: {
					marginBottom: -2,
				},
			}}
		>
			<Tabs.Screen
				name="index"
				options={{
					title: "Today",
					tabBarIcon: ({ color, focused }) => (
						<Home size={22} color={color} strokeWidth={focused ? 2.5 : 2} />
					),
				}}
				listeners={{
					tabPress: handleTabPress,
				}}
			/>
			<Tabs.Screen
				name="rhythm"
				options={{
					title: "Rhythm",
					tabBarIcon: ({ color, focused }) => (
						<Activity size={22} color={color} strokeWidth={focused ? 2.5 : 2} />
					),
				}}
				listeners={{
					tabPress: handleTabPress,
				}}
			/>
			{/* Breathe is now accessed via FAB on Today screen */}
			<Tabs.Screen
				name="breathe"
				options={{
					href: null,
				}}
			/>
			{/* Insights タブは一時的に非表示（将来復活予定） */}
			<Tabs.Screen
				name="insights"
				options={{
					href: null,
				}}
			/>
			<Tabs.Screen
				name="settings"
				options={{
					title: "Settings",
					tabBarIcon: ({ color, focused }) => (
						<Settings size={22} color={color} strokeWidth={focused ? 2.5 : 2} />
					),
				}}
				listeners={{
					tabPress: handleTabPress,
				}}
			/>
			{/* Hidden detail screens */}
			<Tabs.Screen
				name="insight-detail"
				options={{
					href: null,
				}}
			/>
			<Tabs.Screen
				name="action-detail"
				options={{
					href: null,
				}}
			/>
			<Tabs.Screen
				name="health-detail"
				options={{
					href: null,
				}}
			/>
			<Tabs.Screen
				name="recovery-detail"
				options={{
					href: null,
				}}
			/>
			<Tabs.Screen
				name="sleep-detail"
				options={{
					href: null,
				}}
			/>
			<Tabs.Screen
				name="rhythm-detail"
				options={{
					href: null,
				}}
			/>
			<Tabs.Screen
				name="energy-detail"
				options={{
					href: null,
				}}
			/>
		</Tabs>
	);
};

// Export tab bar height for use in other screens
export const TAB_BAR_HEIGHT = TAB_BAR_BASE_HEIGHT;

export default MainLayout;
