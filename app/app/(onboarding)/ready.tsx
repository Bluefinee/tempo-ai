/**
 * Ready Screen - Onboarding Step 4
 * Calibration period explanation and celebration
 */

import * as Haptics from "expo-haptics";
import { useRouter } from "expo-router";
import { BarChart3, Sparkles, Sun, Watch } from "lucide-react-native";
import type { ReactElement } from "react";
import { useEffect, useState } from "react";
import { Dimensions, StyleSheet, Text, View } from "react-native";
import Animated, {
	Easing,
	useAnimatedStyle,
	useSharedValue,
	withDelay,
	withSequence,
	withSpring,
	withTiming,
} from "react-native-reanimated";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import {
	AnimatedButton,
	OnboardingContainer,
} from "../../src/components/onboarding";
import { CALIBRATION_DAYS } from "../../src/domain/models/onboarding";
import { t } from "../../src/i18n";
import { useOnboardingStore } from "../../src/stores/onboardingStore";
import { Colors, FontFamily, Typography } from "../../src/theme";

const { width: SCREEN_WIDTH } = Dimensions.get("window");

interface TipItemProps {
	icon: ReactElement;
	text: string;
	delay: number;
}

const TipItem = ({ icon, text, delay }: TipItemProps): ReactElement => {
	const opacity = useSharedValue(0);
	const translateY = useSharedValue(10);
	const scale = useSharedValue(0.9);

	useEffect(() => {
		opacity.value = withDelay(delay, withTiming(1, { duration: 400 }));
		translateY.value = withDelay(
			delay,
			withSpring(0, { damping: 20, stiffness: 100 }),
		);
		scale.value = withDelay(
			delay,
			withSequence(
				withSpring(1.05, { damping: 10 }),
				withSpring(1, { damping: 15 }),
			),
		);
	}, [delay, opacity, scale, translateY]);

	const animatedStyle = useAnimatedStyle(() => ({
		opacity: opacity.value,
		transform: [{ translateY: translateY.value }, { scale: scale.value }],
	}));

	return (
		<Animated.View style={[styles.tipItem, animatedStyle]}>
			<View style={styles.tipIconContainer}>{icon}</View>
			<Text style={styles.tipText}>{text}</Text>
		</Animated.View>
	);
};

const ReadyScreen = (): ReactElement => {
	const router = useRouter();
	const insets = useSafeAreaInsets();
	const complete = useOnboardingStore((state) => state.complete);
	const [isCompleting, setIsCompleting] = useState(false);
	const [showConfetti, setShowConfetti] = useState(false);

	// Animation values
	const celebrationScale = useSharedValue(0);
	const celebrationRotation = useSharedValue(0);
	const titleOpacity = useSharedValue(0);
	const subtitleOpacity = useSharedValue(0);
	const tipsContainerOpacity = useSharedValue(0);
	const buttonOpacity = useSharedValue(0);
	const confettiOpacity = useSharedValue(0);

	useEffect(() => {
		// Celebration animation
		celebrationScale.value = withDelay(
			200,
			withSpring(1, { damping: 8, stiffness: 100 }),
		);
		celebrationRotation.value = withDelay(
			200,
			withSequence(
				withTiming(-5, { duration: 100 }),
				withTiming(5, { duration: 200 }),
				withTiming(0, { duration: 100 }),
			),
		);

		// Title
		titleOpacity.value = withDelay(400, withTiming(1, { duration: 500 }));

		// Subtitle
		subtitleOpacity.value = withDelay(600, withTiming(1, { duration: 500 }));

		// Tips container
		tipsContainerOpacity.value = withDelay(
			700,
			withTiming(1, { duration: 500 }),
		);

		// Button
		buttonOpacity.value = withDelay(1200, withTiming(1, { duration: 500 }));
	}, [
		buttonOpacity,
		celebrationRotation,
		celebrationScale,
		subtitleOpacity,
		tipsContainerOpacity,
		titleOpacity,
	]);

	const celebrationStyle = useAnimatedStyle(() => ({
		transform: [
			{ scale: celebrationScale.value },
			{ rotate: `${celebrationRotation.value}deg` },
		],
	}));

	const titleStyle = useAnimatedStyle(() => ({
		opacity: titleOpacity.value,
	}));

	const subtitleStyle = useAnimatedStyle(() => ({
		opacity: subtitleOpacity.value,
	}));

	const tipsContainerStyle = useAnimatedStyle(() => ({
		opacity: tipsContainerOpacity.value,
	}));

	const buttonStyle = useAnimatedStyle(() => ({
		opacity: buttonOpacity.value,
	}));

	const handleComplete = async () => {
		if (isCompleting) return;
		setIsCompleting(true);

		// Celebration haptic
		Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);

		// Show confetti
		setShowConfetti(true);
		confettiOpacity.value = withSequence(
			withTiming(1, { duration: 200 }),
			withDelay(1500, withTiming(0, { duration: 500 })),
		);

		// Save onboarding completion to store
		complete();

		// Wait a bit then navigate to main screen
		const timeoutId = setTimeout(() => {
			router.replace("/(main)");
		}, 1800);

		// Cleanup function stored for potential future use
		return () => clearTimeout(timeoutId);
	};

	const confettiStyle = useAnimatedStyle(() => ({
		opacity: confettiOpacity.value,
	}));

	return (
		<OnboardingContainer step={4} blobVariant="warm">
			<View style={styles.content}>
				{/* Confetti overlay */}
				{showConfetti && (
					<Animated.View style={[styles.confettiContainer, confettiStyle]}>
						{/* Simple confetti representation - 20 fixed pieces */}
						{[
							0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
							19,
						].map((n) => (
							<ConfettiPiece key={`confetti-piece-${n}`} index={n} />
						))}
					</Animated.View>
				)}

				{/* Visual area */}
				<View style={styles.visualArea}>
					<Animated.View style={[styles.celebrationCircle, celebrationStyle]}>
						<View style={styles.celebrationInner}>
							<Sparkles size={48} color={Colors.amber[500]} />
						</View>
					</Animated.View>
				</View>

				{/* Title */}
				<Animated.View style={titleStyle}>
					<Text style={styles.title}>{t("onboarding.ready.title")}</Text>
				</Animated.View>

				{/* Subtitle */}
				<Animated.View style={subtitleStyle}>
					<Text style={styles.subtitle}>
						{t("onboarding.ready.subtitle", { days: CALIBRATION_DAYS })}
					</Text>
				</Animated.View>

				{/* Tips container */}
				<Animated.View style={[styles.tipsContainer, tipsContainerStyle]}>
					<View style={styles.tipsHeader}>
						<Text style={styles.tipsTitle}>
							{t("onboarding.ready.tipsTitle")}
						</Text>
					</View>
					<View style={styles.tipsList}>
						<TipItem
							icon={<Watch size={20} color={Colors.indigo[500]} />}
							text={t("onboarding.ready.tips.watch")}
							delay={900}
						/>
						<TipItem
							icon={<BarChart3 size={20} color={Colors.emerald[500]} />}
							text={t("onboarding.ready.tips.score")}
							delay={1000}
						/>
						<TipItem
							icon={<Sun size={20} color={Colors.amber[500]} />}
							text={t("onboarding.ready.tips.checkIn")}
							delay={1100}
						/>
					</View>
				</Animated.View>

				{/* Button area */}
				<Animated.View
					style={[
						styles.buttonArea,
						buttonStyle,
						{ paddingBottom: Math.max(insets.bottom, 24) },
					]}
				>
					<AnimatedButton
						onPress={handleComplete}
						variant="celebration"
						loading={isCompleting}
						isLast
					>
						{t("onboarding.ready.cta")}
					</AnimatedButton>
				</Animated.View>
			</View>
		</OnboardingContainer>
	);
};

// Simple confetti piece
interface ConfettiPieceProps {
	index: number;
}

const ConfettiPiece = ({ index }: ConfettiPieceProps): ReactElement => {
	const translateY = useSharedValue(-50);
	const translateX = useSharedValue(0);
	const rotation = useSharedValue(0);
	const opacity = useSharedValue(1);

	const colors = [
		Colors.indigo[400],
		Colors.amber[400],
		Colors.emerald[400],
		Colors.rose[400],
		Colors.purple[500],
	];

	const color = colors[index % colors.length];
	const startX = (Math.random() - 0.5) * SCREEN_WIDTH;
	const endX = startX + (Math.random() - 0.5) * 100;
	const duration = 1500 + Math.random() * 500;
	const delay = Math.random() * 200;

	useEffect(() => {
		translateX.value = startX;
		translateY.value = withDelay(
			delay,
			withTiming(SCREEN_WIDTH * 1.5, {
				duration,
				easing: Easing.out(Easing.quad),
			}),
		);
		translateX.value = withDelay(
			delay,
			withTiming(endX, { duration, easing: Easing.out(Easing.quad) }),
		);
		rotation.value = withDelay(
			delay,
			withTiming(360 * (Math.random() > 0.5 ? 1 : -1) * 3, { duration }),
		);
		opacity.value = withDelay(
			delay + duration * 0.7,
			withTiming(0, { duration: duration * 0.3 }),
		);
	}, [
		delay,
		duration,
		endX,
		opacity,
		rotation,
		startX,
		translateX,
		translateY,
	]);

	const style = useAnimatedStyle(() => ({
		transform: [
			{ translateX: translateX.value },
			{ translateY: translateY.value },
			{ rotate: `${rotation.value}deg` },
		],
		opacity: opacity.value,
	}));

	return (
		<Animated.View
			style={[styles.confettiPiece, { backgroundColor: color }, style]}
		/>
	);
};

const styles = StyleSheet.create({
	content: {
		flex: 1,
	},
	confettiContainer: {
		...StyleSheet.absoluteFillObject,
		zIndex: 100,
		pointerEvents: "none",
	},
	confettiPiece: {
		position: "absolute",
		width: 10,
		height: 10,
		borderRadius: 2,
		left: "50%",
		top: 0,
	},
	visualArea: {
		alignItems: "center",
		justifyContent: "center",
		height: SCREEN_WIDTH * 0.45,
		marginTop: 8,
	},
	celebrationCircle: {
		width: SCREEN_WIDTH * 0.35,
		aspectRatio: 1,
		borderRadius: 1000,
		backgroundColor: Colors.amber[100],
		alignItems: "center",
		justifyContent: "center",
	},
	celebrationInner: {
		width: "70%",
		height: "70%",
		borderRadius: 1000,
		backgroundColor: Colors.amber[50],
		alignItems: "center",
		justifyContent: "center",
	},
	title: {
		...Typography.heading1,
		color: Colors.stone[900],
		textAlign: "center",
		marginBottom: 12,
	},
	subtitle: {
		fontFamily: FontFamily.regular,
		fontSize: 17,
		lineHeight: 26,
		color: Colors.stone[600],
		textAlign: "center",
		marginBottom: 24,
	},
	tipsContainer: {
		backgroundColor: Colors.white,
		borderRadius: 16,
		marginHorizontal: 4,
		overflow: "hidden",
		shadowColor: Colors.stone[900],
		shadowOffset: { width: 0, height: 2 },
		shadowOpacity: 0.05,
		shadowRadius: 8,
		elevation: 2,
	},
	tipsHeader: {
		backgroundColor: Colors.stone[50],
		paddingVertical: 12,
		paddingHorizontal: 16,
		borderBottomWidth: 1,
		borderBottomColor: Colors.stone[100],
	},
	tipsTitle: {
		fontFamily: FontFamily.semibold,
		fontSize: 14,
		fontWeight: "600",
		color: Colors.stone[700],
	},
	tipsList: {
		padding: 16,
	},
	tipItem: {
		flexDirection: "row",
		alignItems: "center",
		marginBottom: 14,
	},
	tipIconContainer: {
		width: 36,
		height: 36,
		borderRadius: 18,
		backgroundColor: Colors.stone[50],
		alignItems: "center",
		justifyContent: "center",
		marginRight: 12,
	},
	tipText: {
		fontFamily: FontFamily.regular,
		fontSize: 15,
		color: Colors.stone[700],
		flex: 1,
	},
	buttonArea: {
		marginTop: "auto",
		paddingTop: 24,
		paddingHorizontal: 16,
	},
});

export default ReadyScreen;
