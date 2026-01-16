/**
 * MetricGridCard - 2x2グリッド用のメトリクスカード
 * Recovery, Sleep, Rhythm, Energyスコアを表示
 * StyleSheet.createのみ使用（NativeWind排除）
 */

import { ChevronRight } from "lucide-react-native";
import type React from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import Animated, { FadeInDown } from "react-native-reanimated";
import { colors } from "../theme";

interface MetricGridCardProps {
	title: string;
	value: string;
	color: string;
	accentColor: string;
	chartData: number[];
	onPress: () => void;
	delay?: number;
}

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export const MetricGridCard = ({
	title,
	value,
	color,
	accentColor,
	chartData,
	onPress,
	delay = 0,
}: MetricGridCardProps): React.ReactElement => {
	return (
		<AnimatedPressable
			entering={FadeInDown.delay(delay).duration(400)}
			onPress={onPress}
			style={({ pressed }) => [styles.card, pressed && styles.cardPressed]}
		>
			{/* Header */}
			<View style={styles.header}>
				<Text style={styles.title}>{title}</Text>
				<View style={styles.chevronWrapper}>
					<ChevronRight size={18} color={colors.stone[300]} />
				</View>
			</View>

			{/* Value */}
			<Text style={[styles.value, { color }]}>{value}</Text>

			{/* Mini Bar Chart */}
			<View style={styles.barChart}>
				{chartData.map((val, i) => {
					const isLast = i === chartData.length - 1;
					return (
						<View
							key={i}
							style={[
								styles.bar,
								{
									height: `${Math.max(val, 5)}%`,
									backgroundColor: accentColor,
									opacity: isLast ? 1 : 0.25,
								},
							]}
						/>
					);
				})}
			</View>
		</AnimatedPressable>
	);
};

const styles = StyleSheet.create({
	card: {
		backgroundColor: colors.white,
		borderRadius: 20,
		padding: 16,
		height: 160,
		justifyContent: "space-between",
		overflow: "hidden",
		// シャドウ（iOS）
		shadowColor: colors.black,
		shadowOffset: { width: 0, height: 8 },
		shadowOpacity: 0.12,
		shadowRadius: 16,
		// シャドウ（Android）
		elevation: 8,
	},
	cardPressed: {
		opacity: 0.95,
		transform: [{ scale: 0.97 }],
	},
	header: {
		flexDirection: "row",
		justifyContent: "space-between",
		alignItems: "center",
	},
	title: {
		fontSize: 14,
		fontWeight: "500",
		color: colors.stone[400],
	},
	chevronWrapper: {
		opacity: 0.6,
	},
	value: {
		fontSize: 36,
		fontWeight: "700",
		letterSpacing: -1,
	},
	barChart: {
		flexDirection: "row",
		alignItems: "flex-end",
		justifyContent: "space-between",
		height: 36,
		gap: 3,
	},
	bar: {
		flex: 1,
		borderRadius: 3,
	},
});
