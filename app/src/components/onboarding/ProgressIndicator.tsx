/**
 * ProgressIndicator - 4ドットプログレスインジケーター
 * オンボーディングの進行状況を表示
 */

import type { ReactElement } from "react";
import React from "react";
import { StyleSheet, View } from "react-native";
import Animated, {
	useAnimatedStyle,
	useSharedValue,
	withSpring,
	withTiming,
} from "react-native-reanimated";
import { ONBOARDING_TOTAL_STEPS } from "../../domain/models/onboarding";
import { Colors } from "../../theme";

interface ProgressIndicatorProps {
	currentStep: number;
}

const DOT_SIZE = 8;
const DOT_SPACING = 8;

export const ProgressIndicator = ({
	currentStep,
}: ProgressIndicatorProps): ReactElement => {
	return (
		<View
			style={styles.container}
			accessibilityRole="progressbar"
			accessibilityLabel={`ステップ ${currentStep} / ${ONBOARDING_TOTAL_STEPS}`}
			accessibilityValue={{
				min: 1,
				max: ONBOARDING_TOTAL_STEPS,
				now: currentStep,
			}}
		>
			{Array.from({ length: ONBOARDING_TOTAL_STEPS }, (_, i) => i).map((stepNum) => (
				<Dot
					key={`progress-dot-step-${stepNum}`}
					index={stepNum}
					isActive={stepNum < currentStep}
					isCurrent={stepNum === currentStep - 1}
				/>
			))}
		</View>
	);
};

interface DotProps {
	index: number;
	isActive: boolean;
	isCurrent: boolean;
}

const Dot = ({ index, isActive, isCurrent }: DotProps): ReactElement => {
	const scale = useSharedValue(1);

	React.useEffect(() => {
		if (isCurrent) {
			scale.value = withSpring(1.2, { damping: 15 });
		} else {
			scale.value = withSpring(1, { damping: 15 });
		}
	}, [isCurrent, scale]);

	const animatedStyle = useAnimatedStyle(() => ({
		transform: [{ scale: scale.value }],
		backgroundColor: withTiming(
			isActive ? Colors.indigo[500] : Colors.stone[200],
			{ duration: 200 },
		),
	}));

	return (
		<Animated.View
			style={[
				styles.dot,
				animatedStyle,
				{ marginLeft: index > 0 ? DOT_SPACING : 0 },
			]}
		/>
	);
};

const styles = StyleSheet.create({
	container: {
		flexDirection: "row",
		alignItems: "center",
		justifyContent: "center",
		paddingVertical: 16,
	},
	dot: {
		width: DOT_SIZE,
		height: DOT_SIZE,
		borderRadius: DOT_SIZE / 2,
	},
});
