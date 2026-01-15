/**
 * Welcome Screen - Onboarding Step 1
 * Brand experience and value proposition
 */

import { useRouter } from "expo-router";
import type { ReactElement } from "react";
import { useEffect } from "react";
import { Dimensions, StyleSheet, View } from "react-native";
import Animated, {
	Easing,
	useAnimatedStyle,
	useSharedValue,
	withDelay,
	withRepeat,
	withSpring,
	withTiming,
} from "react-native-reanimated";
import {
	AnimatedButton,
	OnboardingContainer,
} from "../../src/components/onboarding";
import { t } from "../../src/i18n";
import { Colors, FontFamily, Typography } from "../../src/theme";

const { width: SCREEN_WIDTH } = Dimensions.get("window");

const WelcomeScreen = (): ReactElement => {
	const router = useRouter();

	// アニメーション値
	const titleOpacity = useSharedValue(0);
	const titleTranslateY = useSharedValue(30);
	const subtitleOpacity = useSharedValue(0);
	const subtitleTranslateY = useSharedValue(20);
	const buttonOpacity = useSharedValue(0);
	const buttonTranslateY = useSharedValue(20);
	const waveScale = useSharedValue(0.8);
	const waveRotation = useSharedValue(0);

	useEffect(() => {
		// 段階的にアニメーション開始
		// 波アニメーション
		waveScale.value = withDelay(
			200,
			withSpring(1, { damping: 12, stiffness: 100 }),
		);
		waveRotation.value = withRepeat(
			withTiming(360, { duration: 60000, easing: Easing.linear }),
			-1,
			false,
		);

		// タイトル
		titleOpacity.value = withDelay(400, withTiming(1, { duration: 600 }));
		titleTranslateY.value = withDelay(
			400,
			withSpring(0, { damping: 20, stiffness: 100 }),
		);

		// サブタイトル
		subtitleOpacity.value = withDelay(600, withTiming(1, { duration: 600 }));
		subtitleTranslateY.value = withDelay(
			600,
			withSpring(0, { damping: 20, stiffness: 100 }),
		);

		// ボタン
		buttonOpacity.value = withDelay(800, withTiming(1, { duration: 600 }));
		buttonTranslateY.value = withDelay(
			800,
			withSpring(0, { damping: 20, stiffness: 100 }),
		);
	}, [
		buttonOpacity,
		buttonTranslateY,
		subtitleOpacity,
		subtitleTranslateY,
		titleOpacity,
		titleTranslateY,
		waveRotation,
		waveScale,
	]);

	const titleStyle = useAnimatedStyle(() => ({
		opacity: titleOpacity.value,
		transform: [{ translateY: titleTranslateY.value }],
	}));

	const subtitleStyle = useAnimatedStyle(() => ({
		opacity: subtitleOpacity.value,
		transform: [{ translateY: subtitleTranslateY.value }],
	}));

	const buttonStyle = useAnimatedStyle(() => ({
		opacity: buttonOpacity.value,
		transform: [{ translateY: buttonTranslateY.value }],
	}));

	const waveStyle = useAnimatedStyle(() => ({
		transform: [
			{ scale: waveScale.value },
			{ rotate: `${waveRotation.value}deg` },
		],
	}));

	const handleNext = () => {
		router.push("./nickname");
	};

	return (
		<OnboardingContainer step={1} blobVariant="calm">
			<View style={styles.content}>
				{/* Visual area */}
				<View style={styles.visualArea}>
					<View style={styles.waveContainer}>
						<Animated.View style={[styles.waveOuter, waveStyle]}>
							<View style={styles.waveInner}>
								<View style={styles.waveCore} />
							</View>
						</Animated.View>
					</View>
				</View>

				{/* Text area */}
				<View style={styles.textArea}>
					<Animated.Text style={[styles.title, titleStyle]}>
						{t("onboarding.welcome.title")}
					</Animated.Text>

					<Animated.Text style={[styles.subtitle, subtitleStyle]}>
						{t("onboarding.welcome.subtitle")}
					</Animated.Text>
				</View>

				{/* Button area */}
				<Animated.View style={[styles.buttonArea, buttonStyle]}>
					<AnimatedButton onPress={handleNext} variant="primary">
						{t("onboarding.welcome.cta")}
					</AnimatedButton>
				</Animated.View>
			</View>
		</OnboardingContainer>
	);
};

const styles = StyleSheet.create({
	content: {
		flex: 1,
		justifyContent: "space-between",
		paddingBottom: 24,
	},
	visualArea: {
		flex: 1,
		alignItems: "center",
		justifyContent: "center",
		maxHeight: "50%",
	},
	waveContainer: {
		width: SCREEN_WIDTH * 0.7,
		aspectRatio: 1,
		alignItems: "center",
		justifyContent: "center",
	},
	waveOuter: {
		width: "100%",
		height: "100%",
		borderRadius: 1000,
		backgroundColor: Colors.indigo[100],
		alignItems: "center",
		justifyContent: "center",
		opacity: 0.6,
	},
	waveInner: {
		width: "70%",
		height: "70%",
		borderRadius: 1000,
		backgroundColor: Colors.indigo[200],
		alignItems: "center",
		justifyContent: "center",
	},
	waveCore: {
		width: "60%",
		height: "60%",
		borderRadius: 1000,
		backgroundColor: Colors.indigo[400],
		opacity: 0.8,
	},
	textArea: {
		alignItems: "center",
		paddingHorizontal: 16,
		marginBottom: 40,
	},
	title: {
		...Typography.heading1,
		color: Colors.stone[900],
		textAlign: "center",
		marginBottom: 16,
	},
	subtitle: {
		fontFamily: FontFamily.regular,
		fontSize: 18,
		lineHeight: 28,
		color: Colors.stone[600],
		textAlign: "center",
	},
	buttonArea: {
		paddingHorizontal: 16,
	},
});

export default WelcomeScreen;
