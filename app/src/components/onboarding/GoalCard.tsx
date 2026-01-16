/**
 * GoalCard - 目標選択カード
 * アニメーション付きの選択可能なカード
 */

import * as Haptics from "expo-haptics";
import { Check, Heart, Moon, Target, Zap } from "lucide-react-native";
import type { ReactElement } from "react";
import React from "react";
import { StyleSheet, Text, TouchableOpacity, View } from "react-native";
import Animated, {
	interpolateColor,
	useAnimatedStyle,
	useSharedValue,
	withSpring,
	withTiming,
} from "react-native-reanimated";
import type { OnboardingGoal } from "../../domain/models/onboarding";
import { Colors, FontFamily } from "../../theme";

interface GoalCardProps {
	goal: OnboardingGoal;
	title: string;
	isSelected: boolean;
	onSelect: () => void;
	disabled?: boolean;
}

const AnimatedTouchable = Animated.createAnimatedComponent(TouchableOpacity);

export const GoalCard = ({
	goal,
	title,
	isSelected,
	onSelect,
	disabled = false,
}: GoalCardProps): ReactElement => {
	const scale = useSharedValue(1);
	const selected = useSharedValue(isSelected ? 1 : 0);

	React.useEffect(() => {
		selected.value = withTiming(isSelected ? 1 : 0, { duration: 200 });
	}, [isSelected, selected]);

	const handlePressIn = () => {
		scale.value = withSpring(0.95, { damping: 15 });
	};

	const handlePressOut = () => {
		scale.value = withSpring(1, { damping: 15 });
	};

	const handlePress = () => {
		Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
		onSelect();
	};

	const animatedContainerStyle = useAnimatedStyle(() => ({
		transform: [{ scale: scale.value }],
		backgroundColor: interpolateColor(
			selected.value,
			[0, 1],
			[Colors.stone[100], Colors.indigo[50]],
		),
		borderColor: interpolateColor(
			selected.value,
			[0, 1],
			[Colors.stone[200], Colors.indigo[500]],
		),
	}));

	const animatedCheckStyle = useAnimatedStyle(() => ({
		opacity: selected.value,
		transform: [{ scale: selected.value }],
	}));

	const getIcon = () => {
		const iconProps = {
			size: 28,
			color: isSelected ? Colors.indigo[600] : Colors.stone[500],
			strokeWidth: 1.5,
		};

		switch (goal) {
			case "better_sleep":
				return <Moon {...iconProps} />;
			case "more_energy":
				return <Zap {...iconProps} />;
			case "less_stress":
				return <Heart {...iconProps} />;
			case "peak_performance":
				return <Target {...iconProps} />;
			default:
				return null;
		}
	};

	return (
		<AnimatedTouchable
			onPress={handlePress}
			onPressIn={handlePressIn}
			onPressOut={handlePressOut}
			disabled={disabled}
			activeOpacity={1}
			style={[styles.container, animatedContainerStyle]}
			accessibilityRole="checkbox"
			accessibilityState={{ checked: isSelected, disabled }}
			accessibilityLabel={title}
		>
			{/* アイコン */}
			<View style={styles.iconContainer}>{getIcon()}</View>

			{/* タイトル */}
			<Text
				style={[styles.title, isSelected && styles.titleSelected]}
				numberOfLines={2}
			>
				{title}
			</Text>

			{/* チェックマーク */}
			<Animated.View style={[styles.checkContainer, animatedCheckStyle]}>
				<View style={styles.checkCircle}>
					<Check size={14} color={Colors.white} strokeWidth={3} />
				</View>
			</Animated.View>
		</AnimatedTouchable>
	);
};

const styles = StyleSheet.create({
	container: {
		width: "47%",
		aspectRatio: 1,
		borderRadius: 16,
		borderWidth: 2,
		padding: 16,
		alignItems: "center",
		justifyContent: "center",
		position: "relative",
	},
	iconContainer: {
		marginBottom: 12,
	},
	title: {
		fontFamily: FontFamily.semibold,
		fontSize: 14,
		fontWeight: "600",
		color: Colors.stone[700],
		textAlign: "center",
		lineHeight: 18,
	},
	titleSelected: {
		color: Colors.indigo[700],
	},
	checkContainer: {
		position: "absolute",
		top: 10,
		right: 10,
	},
	checkCircle: {
		width: 22,
		height: 22,
		borderRadius: 11,
		backgroundColor: Colors.indigo[500],
		alignItems: "center",
		justifyContent: "center",
	},
});
