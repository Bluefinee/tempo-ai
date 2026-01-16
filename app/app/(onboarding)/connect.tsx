/**
 * Connect Screen - Onboarding Step 3
 * HealthKit permission request with value proposition
 */

import * as Haptics from "expo-haptics";
import { useRouter } from "expo-router";
import { Footprints, Heart, Lock, Moon } from "lucide-react-native";
import type { ReactElement } from "react";
import { useEffect } from "react";
import { Dimensions, ScrollView, StyleSheet, Text, View } from "react-native";
import Animated, {
	Easing,
	useAnimatedStyle,
	useSharedValue,
	withDelay,
	withRepeat,
	withSequence,
	withSpring,
	withTiming,
} from "react-native-reanimated";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import {
	AnimatedButton,
	OnboardingContainer,
} from "../../src/components/onboarding";
import { t } from "../../src/i18n";
import { useOnboardingStore } from "../../src/stores/onboardingStore";
import { Colors, FontFamily, Typography } from "../../src/theme";

const { width: SCREEN_WIDTH } = Dimensions.get("window");

interface DataItemProps {
	icon: ReactElement;
	title: string;
	description: string;
	delay: number;
}

const DataItem = ({
	icon,
	title,
	description,
	delay,
}: DataItemProps): ReactElement => {
	const opacity = useSharedValue(0);
	const translateX = useSharedValue(30);

	useEffect(() => {
		opacity.value = withDelay(delay, withTiming(1, { duration: 400 }));
		translateX.value = withDelay(
			delay,
			withSpring(0, { damping: 20, stiffness: 100 }),
		);
	}, [delay, opacity, translateX]);

	const animatedStyle = useAnimatedStyle(() => ({
		opacity: opacity.value,
		transform: [{ translateX: translateX.value }],
	}));

	return (
		<Animated.View style={[styles.dataItem, animatedStyle]}>
			<View style={styles.dataIconContainer}>{icon}</View>
			<View style={styles.dataTextContainer}>
				<Text style={styles.dataTitle}>{title}</Text>
				<Text style={styles.dataDescription}>{description}</Text>
			</View>
		</Animated.View>
	);
};

const ConnectScreen = (): ReactElement => {
	const router = useRouter();
	const insets = useSafeAreaInsets();
	const setHealthKitAuthorized = useOnboardingStore(
		(state) => state.setHealthKitAuthorized,
	);

	// Animation values
	const titleOpacity = useSharedValue(0);
	const titleTranslateY = useSharedValue(20);
	const heartScale = useSharedValue(0.8);
	const heartPulse = useSharedValue(1);
	const privacyOpacity = useSharedValue(0);
	const buttonsOpacity = useSharedValue(0);

	useEffect(() => {
		// Heart animation
		heartScale.value = withDelay(
			200,
			withSpring(1, { damping: 12, stiffness: 100 }),
		);
		heartPulse.value = withDelay(
			600,
			withRepeat(
				withSequence(
					withTiming(1.05, {
						duration: 800,
						easing: Easing.inOut(Easing.ease),
					}),
					withTiming(1, { duration: 800, easing: Easing.inOut(Easing.ease) }),
				),
				-1,
				false,
			),
		);

		// Title
		titleOpacity.value = withDelay(300, withTiming(1, { duration: 500 }));
		titleTranslateY.value = withDelay(
			300,
			withSpring(0, { damping: 20, stiffness: 100 }),
		);

		// Privacy message
		privacyOpacity.value = withDelay(1200, withTiming(1, { duration: 500 }));

		// Buttons
		buttonsOpacity.value = withDelay(1400, withTiming(1, { duration: 500 }));
	}, [
		buttonsOpacity,
		heartPulse,
		heartScale,
		privacyOpacity,
		titleOpacity,
		titleTranslateY,
	]);

	const titleStyle = useAnimatedStyle(() => ({
		opacity: titleOpacity.value,
		transform: [{ translateY: titleTranslateY.value }],
	}));

	const heartStyle = useAnimatedStyle(() => ({
		transform: [{ scale: heartScale.value * heartPulse.value }],
	}));

	const privacyStyle = useAnimatedStyle(() => ({
		opacity: privacyOpacity.value,
	}));

	const buttonsStyle = useAnimatedStyle(() => ({
		opacity: buttonsOpacity.value,
	}));

	const handleConnect = async () => {
		// TODO: Implement actual HealthKit permission request
		Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
		setHealthKitAuthorized(true);
		router.push("./ready");
	};

	const handleSkip = () => {
		Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
		setHealthKitAuthorized(false);
		router.push("./ready");
	};

	return (
		<OnboardingContainer step={3} blobVariant="warm">
			<ScrollView
				style={styles.scrollView}
				contentContainerStyle={[
					styles.scrollContent,
					{ paddingBottom: 140 + insets.bottom },
				]}
				showsVerticalScrollIndicator={false}
			>
				{/* Visual area */}
				<View style={styles.visualArea}>
					<Animated.View style={[styles.heartContainer, heartStyle]}>
						<View style={styles.heartOuter}>
							<View style={styles.heartInner}>
								<Heart
									size={48}
									color={Colors.rose[400]}
									fill={Colors.rose[400]}
								/>
							</View>
						</View>
						{/* Data stream visual representation */}
						<View style={styles.dataStreamLeft} />
						<View style={styles.dataStreamRight} />
					</Animated.View>
				</View>

				{/* Title */}
				<Animated.View style={[styles.titleContainer, titleStyle]}>
					<Text style={styles.title}>{t("onboarding.connect.title")}</Text>
				</Animated.View>

				{/* Data items list */}
				<View style={styles.dataList}>
					<DataItem
						icon={<Moon size={24} color={Colors.indigo[500]} />}
						title={t("onboarding.connect.dataItems.sleep.title")}
						description={t("onboarding.connect.dataItems.sleep.description")}
						delay={600}
					/>
					<DataItem
						icon={<Heart size={24} color={Colors.rose[400]} />}
						title={t("onboarding.connect.dataItems.hrv.title")}
						description={t("onboarding.connect.dataItems.hrv.description")}
						delay={750}
					/>
					<DataItem
						icon={<Footprints size={24} color={Colors.amber[500]} />}
						title={t("onboarding.connect.dataItems.activity.title")}
						description={t("onboarding.connect.dataItems.activity.description")}
						delay={900}
					/>
				</View>

				{/* Privacy message */}
				<Animated.View style={[styles.privacyContainer, privacyStyle]}>
					<Lock size={16} color={Colors.stone[500]} />
					<Text style={styles.privacyText}>
						{t("onboarding.connect.privacy")}
					</Text>
				</Animated.View>
			</ScrollView>

			{/* Fixed button area */}
			<Animated.View
				style={[
					styles.buttonArea,
					buttonsStyle,
					{ paddingBottom: Math.max(insets.bottom, 24) },
				]}
			>
				<AnimatedButton onPress={handleConnect} variant="primary">
					{t("onboarding.connect.connectCta")}
				</AnimatedButton>
				<View style={styles.buttonSpacer} />
				<AnimatedButton
					onPress={handleSkip}
					variant="secondary"
					showIcon={false}
				>
					{t("onboarding.connect.skipCta")}
				</AnimatedButton>
			</Animated.View>
		</OnboardingContainer>
	);
};

const styles = StyleSheet.create({
	scrollView: {
		flex: 1,
	},
	scrollContent: {
		paddingBottom: 140,
	},
	visualArea: {
		alignItems: "center",
		justifyContent: "center",
		height: SCREEN_WIDTH * 0.5,
		marginTop: 16,
	},
	heartContainer: {
		width: SCREEN_WIDTH * 0.4,
		aspectRatio: 1,
		alignItems: "center",
		justifyContent: "center",
		position: "relative",
	},
	heartOuter: {
		width: "100%",
		height: "100%",
		borderRadius: 1000,
		backgroundColor: Colors.rose[50],
		alignItems: "center",
		justifyContent: "center",
	},
	heartInner: {
		width: "70%",
		height: "70%",
		borderRadius: 1000,
		backgroundColor: Colors.rose[100],
		alignItems: "center",
		justifyContent: "center",
	},
	dataStreamLeft: {
		position: "absolute",
		left: -20,
		top: "50%",
		width: 40,
		height: 4,
		borderRadius: 2,
		backgroundColor: Colors.indigo[300],
		opacity: 0.6,
	},
	dataStreamRight: {
		position: "absolute",
		right: -20,
		top: "50%",
		width: 40,
		height: 4,
		borderRadius: 2,
		backgroundColor: Colors.emerald[400],
		opacity: 0.6,
	},
	titleContainer: {
		alignItems: "center",
		marginBottom: 24,
	},
	title: {
		...Typography.heading2,
		color: Colors.stone[900],
		textAlign: "center",
		lineHeight: 32,
	},
	dataList: {
		paddingHorizontal: 8,
		marginBottom: 16,
	},
	dataItem: {
		flexDirection: "row",
		alignItems: "center",
		backgroundColor: Colors.white,
		borderRadius: 12,
		padding: 16,
		marginBottom: 12,
		shadowColor: Colors.stone[900],
		shadowOffset: { width: 0, height: 2 },
		shadowOpacity: 0.05,
		shadowRadius: 8,
		elevation: 2,
	},
	dataIconContainer: {
		width: 44,
		height: 44,
		borderRadius: 22,
		backgroundColor: Colors.stone[50],
		alignItems: "center",
		justifyContent: "center",
		marginRight: 16,
	},
	dataTextContainer: {
		flex: 1,
	},
	dataTitle: {
		fontFamily: FontFamily.semibold,
		fontSize: 16,
		fontWeight: "600",
		color: Colors.stone[900],
		marginBottom: 2,
	},
	dataDescription: {
		fontFamily: FontFamily.regular,
		fontSize: 14,
		color: Colors.stone[500],
	},
	privacyContainer: {
		flexDirection: "row",
		alignItems: "flex-start",
		paddingHorizontal: 16,
		marginBottom: 24,
	},
	privacyText: {
		fontFamily: FontFamily.regular,
		fontSize: 13,
		color: Colors.stone[500],
		marginLeft: 8,
		lineHeight: 18,
		flex: 1,
	},
	buttonArea: {
		position: "absolute",
		bottom: 0,
		left: 0,
		right: 0,
		paddingTop: 20,
		paddingHorizontal: 16,
		backgroundColor: Colors.stone[50],
	},
	buttonSpacer: {
		height: 12,
	},
});

export default ConnectScreen;
