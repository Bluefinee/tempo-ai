/**
 * BreatheFAB - Floating Action Button for Breathe feature
 * Provides quick access to the breathing exercise from any screen
 */

import * as Haptics from "expo-haptics";
import { useRouter } from "expo-router";
import { Wind } from "lucide-react-native";
import type React from "react";
import { useCallback } from "react";
import { Platform, Pressable, StyleSheet } from "react-native";
import Animated, {
	useAnimatedStyle,
	useSharedValue,
	withRepeat,
	withSequence,
	withTiming,
} from "react-native-reanimated";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { TAB_BAR_HEIGHT } from "../../app/(main)/_layout";
import { Colors } from "../theme";

interface BreatheFABProps {
	/** Whether to show a subtle pulse animation */
	showPulse?: boolean;
}

const FAB_SIZE = 56;

export const BreatheFAB = ({
	showPulse = false,
}: BreatheFABProps): React.ReactElement => {
	const router = useRouter();
	const insets = useSafeAreaInsets();

	// Pulse animation
	const pulseScale = useSharedValue(1);

	// Start pulse animation if enabled
	if (showPulse) {
		pulseScale.value = withRepeat(
			withSequence(
				withTiming(1.05, { duration: 1000 }),
				withTiming(1, { duration: 1000 }),
			),
			-1,
			true,
		);
	}

	const pulseStyle = useAnimatedStyle(() => ({
		transform: [{ scale: pulseScale.value }],
	}));

	const handlePress = useCallback((): void => {
		if (Platform.OS === "ios") {
			Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
		}
		router.push("/breathe");
	}, [router]);

	return (
		<Animated.View
			style={[
				styles.container,
				pulseStyle,
				{
					bottom: TAB_BAR_HEIGHT + insets.bottom + 16,
				},
			]}
		>
			<Pressable
				onPress={handlePress}
				style={({ pressed }) => [
					styles.button,
					pressed && styles.buttonPressed,
				]}
				accessibilityLabel="Open breathing exercise"
				accessibilityRole="button"
			>
				<Wind size={24} color={Colors.white} strokeWidth={2.5} />
			</Pressable>
		</Animated.View>
	);
};

const styles = StyleSheet.create({
	container: {
		position: "absolute",
		right: 20,
		zIndex: 100,
	},
	button: {
		width: FAB_SIZE,
		height: FAB_SIZE,
		borderRadius: FAB_SIZE / 2,
		backgroundColor: Colors.indigo[600],
		alignItems: "center",
		justifyContent: "center",
		shadowColor: Colors.indigo[900],
		shadowOffset: { width: 0, height: 4 },
		shadowOpacity: 0.25,
		shadowRadius: 12,
		elevation: 8,
	},
	buttonPressed: {
		backgroundColor: Colors.indigo[700],
		transform: [{ scale: 0.95 }],
	},
});

export default BreatheFAB;
