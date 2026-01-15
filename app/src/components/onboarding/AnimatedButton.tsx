/**
 * AnimatedButton - アニメーション付きボタン
 * プレス時のスケールアニメーションとHapticフィードバック
 */

import * as Haptics from "expo-haptics";
import { Check, ChevronRight, Sparkles } from "lucide-react-native";
import type { ReactElement, ReactNode } from "react";
import {
	ActivityIndicator,
	StyleSheet,
	Text,
	TouchableOpacity,
	View,
} from "react-native";
import Animated, {
	useAnimatedStyle,
	useSharedValue,
	withSequence,
	withSpring,
	withTiming,
} from "react-native-reanimated";
import { Colors, FontFamily } from "../../theme";

type ButtonVariant = "primary" | "secondary" | "celebration";

interface AnimatedButtonProps {
	onPress: () => void;
	children: ReactNode;
	variant?: ButtonVariant;
	disabled?: boolean;
	loading?: boolean;
	showIcon?: boolean;
	isLast?: boolean;
}

const AnimatedTouchable = Animated.createAnimatedComponent(TouchableOpacity);

export const AnimatedButton = ({
	onPress,
	children,
	variant = "primary",
	disabled = false,
	loading = false,
	showIcon = true,
	isLast = false,
}: AnimatedButtonProps): ReactElement => {
	const scale = useSharedValue(1);
	const sparkleOpacity = useSharedValue(0);

	const handlePressIn = () => {
		scale.value = withSpring(0.95, { damping: 15 });
	};

	const handlePressOut = () => {
		scale.value = withSpring(1, { damping: 15 });
	};

	const handlePress = () => {
		if (variant === "celebration") {
			// お祝いアニメーション
			Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
			sparkleOpacity.value = withSequence(
				withTiming(1, { duration: 200 }),
				withTiming(0, { duration: 400 }),
			);
		} else {
			Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
		}
		onPress();
	};

	const animatedStyle = useAnimatedStyle(() => ({
		transform: [{ scale: scale.value }],
	}));

	const sparkleStyle = useAnimatedStyle(() => ({
		opacity: sparkleOpacity.value,
	}));

	const getButtonStyle = () => {
		switch (variant) {
			case "secondary":
				return styles.buttonSecondary;
			case "celebration":
				return styles.buttonCelebration;
			default:
				return styles.buttonPrimary;
		}
	};

	const getTextStyle = () => {
		switch (variant) {
			case "secondary":
				return styles.textSecondary;
			default:
				return styles.textPrimary;
		}
	};

	const getIconColor = () => {
		switch (variant) {
			case "secondary":
				return Colors.stone[600];
			default:
				return Colors.white;
		}
	};

	const renderIcon = () => {
		if (!showIcon) return null;

		if (variant === "celebration") {
			return (
				<View style={styles.iconContainer}>
					<Sparkles size={20} color={Colors.white} />
					<Animated.View style={[styles.sparkleOverlay, sparkleStyle]}>
						<Sparkles size={20} color={Colors.amber[300]} />
					</Animated.View>
				</View>
			);
		}

		if (isLast) {
			return <Check size={20} color={getIconColor()} style={styles.icon} />;
		}

		return (
			<ChevronRight size={20} color={getIconColor()} style={styles.icon} />
		);
	};

	return (
		<AnimatedTouchable
			onPress={handlePress}
			onPressIn={handlePressIn}
			onPressOut={handlePressOut}
			disabled={disabled || loading}
			activeOpacity={1}
			style={[
				styles.button,
				getButtonStyle(),
				(disabled || loading) && styles.disabled,
				animatedStyle,
			]}
			accessibilityRole="button"
			accessibilityState={{ disabled: disabled || loading }}
		>
			{loading ? (
				<ActivityIndicator
					color={variant === "secondary" ? Colors.stone[600] : Colors.white}
				/>
			) : (
				<View style={styles.content}>
					<Text style={[styles.text, getTextStyle()]}>{children}</Text>
					{renderIcon()}
				</View>
			)}
		</AnimatedTouchable>
	);
};

const styles = StyleSheet.create({
	button: {
		borderRadius: 999,
		paddingVertical: 16,
		paddingLeft: 32,
		paddingRight: 24,
		alignItems: "center",
		justifyContent: "center",
	},
	buttonPrimary: {
		backgroundColor: Colors.indigo[900],
		shadowColor: Colors.indigo[900],
		shadowOffset: { width: 0, height: 8 },
		shadowOpacity: 0.2,
		shadowRadius: 16,
		elevation: 8,
	},
	buttonSecondary: {
		backgroundColor: Colors.white,
		borderWidth: 1,
		borderColor: Colors.stone[200],
	},
	buttonCelebration: {
		backgroundColor: Colors.emerald[500],
		shadowColor: Colors.emerald[500],
		shadowOffset: { width: 0, height: 8 },
		shadowOpacity: 0.3,
		shadowRadius: 16,
		elevation: 8,
	},
	disabled: {
		opacity: 0.5,
	},
	content: {
		flexDirection: "row",
		alignItems: "center",
	},
	text: {
		fontFamily: FontFamily.semibold,
		fontSize: 16,
		fontWeight: "600",
	},
	textPrimary: {
		color: Colors.white,
	},
	textSecondary: {
		color: Colors.stone[600],
	},
	icon: {
		marginLeft: 8,
	},
	iconContainer: {
		marginLeft: 8,
		position: "relative",
	},
	sparkleOverlay: {
		position: "absolute",
		top: 0,
		left: 0,
	},
});
