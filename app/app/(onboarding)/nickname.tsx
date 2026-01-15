/**
 * Nickname Screen - Onboarding Step 2
 * User enters their name for personalization
 */

import * as Haptics from "expo-haptics";
import { useRouter } from "expo-router";
import { User } from "lucide-react-native";
import type { ReactElement } from "react";
import { useEffect, useState } from "react";
import {
	Dimensions,
	KeyboardAvoidingView,
	Platform,
	StyleSheet,
	Text,
	TextInput,
	View,
} from "react-native";
import Animated, {
	useAnimatedStyle,
	useSharedValue,
	withDelay,
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

const NicknameScreen = (): ReactElement => {
	const router = useRouter();
	const insets = useSafeAreaInsets();
	const { nickname, setNickname } = useOnboardingStore();
	const [inputValue, setInputValue] = useState(nickname);

	// Animation values
	const iconOpacity = useSharedValue(0);
	const iconScale = useSharedValue(0.8);
	const titleOpacity = useSharedValue(0);
	const inputOpacity = useSharedValue(0);
	const buttonOpacity = useSharedValue(0);

	useEffect(() => {
		iconOpacity.value = withDelay(200, withTiming(1, { duration: 500 }));
		iconScale.value = withDelay(
			200,
			withSpring(1, { damping: 12, stiffness: 100 }),
		);
		titleOpacity.value = withDelay(400, withTiming(1, { duration: 500 }));
		inputOpacity.value = withDelay(600, withTiming(1, { duration: 500 }));
		buttonOpacity.value = withDelay(800, withTiming(1, { duration: 500 }));
	}, [buttonOpacity, iconOpacity, iconScale, inputOpacity, titleOpacity]);

	const iconStyle = useAnimatedStyle(() => ({
		opacity: iconOpacity.value,
		transform: [{ scale: iconScale.value }],
	}));

	const titleStyle = useAnimatedStyle(() => ({
		opacity: titleOpacity.value,
	}));

	const inputStyle = useAnimatedStyle(() => ({
		opacity: inputOpacity.value,
	}));

	const buttonStyle = useAnimatedStyle(() => ({
		opacity: buttonOpacity.value,
	}));

	const handleChangeText = (text: string) => {
		setInputValue(text);
	};

	const handleNext = () => {
		Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
		setNickname(inputValue.trim());
		router.push("./personalize");
	};

	// Allow proceeding even without a name (will use default)
	const canProceed = true;

	return (
		<OnboardingContainer step={2} blobVariant="default">
			<KeyboardAvoidingView
				style={styles.keyboardView}
				behavior={Platform.OS === "ios" ? "padding" : "height"}
			>
				<View style={styles.content}>
					{/* Icon */}
					<Animated.View style={[styles.iconContainer, iconStyle]}>
						<View style={styles.iconOuter}>
							<View style={styles.iconInner}>
								<User size={40} color={Colors.indigo[500]} />
							</View>
						</View>
					</Animated.View>

					{/* Title */}
					<Animated.View style={[styles.titleContainer, titleStyle]}>
						<Text style={styles.title}>{t("onboarding.nickname.title")}</Text>
						<Text style={styles.hint}>{t("onboarding.nickname.hint")}</Text>
					</Animated.View>

					{/* Input */}
					<Animated.View style={[styles.inputContainer, inputStyle]}>
						<TextInput
							style={styles.input}
							value={inputValue}
							onChangeText={handleChangeText}
							placeholder={t("onboarding.nickname.placeholder")}
							placeholderTextColor={Colors.stone[400]}
							autoCapitalize="words"
							autoCorrect={false}
							returnKeyType="done"
							onSubmitEditing={handleNext}
						/>
					</Animated.View>

					{/* Spacer */}
					<View style={styles.spacer} />

					{/* Button */}
					<Animated.View
						style={[
							styles.buttonArea,
							buttonStyle,
							{ paddingBottom: Math.max(insets.bottom, 24) },
						]}
					>
						<AnimatedButton
							onPress={handleNext}
							variant="primary"
							disabled={!canProceed}
						>
							{t("onboarding.nickname.next")}
						</AnimatedButton>
					</Animated.View>
				</View>
			</KeyboardAvoidingView>
		</OnboardingContainer>
	);
};

const styles = StyleSheet.create({
	keyboardView: {
		flex: 1,
	},
	content: {
		flex: 1,
		paddingTop: 20,
	},
	iconContainer: {
		alignItems: "center",
		marginBottom: 32,
	},
	iconOuter: {
		width: SCREEN_WIDTH * 0.28,
		aspectRatio: 1,
		borderRadius: 1000,
		backgroundColor: Colors.indigo[100],
		alignItems: "center",
		justifyContent: "center",
	},
	iconInner: {
		width: "70%",
		height: "70%",
		borderRadius: 1000,
		backgroundColor: Colors.indigo[50],
		alignItems: "center",
		justifyContent: "center",
	},
	titleContainer: {
		alignItems: "center",
		marginBottom: 32,
		paddingHorizontal: 16,
	},
	title: {
		...Typography.heading2,
		color: Colors.stone[900],
		textAlign: "center",
		lineHeight: 32,
		marginBottom: 12,
	},
	hint: {
		fontFamily: FontFamily.regular,
		fontSize: 15,
		color: Colors.stone[500],
		textAlign: "center",
	},
	inputContainer: {
		paddingHorizontal: 16,
	},
	input: {
		backgroundColor: Colors.white,
		borderRadius: 16,
		paddingVertical: 18,
		paddingHorizontal: 20,
		fontSize: 18,
		fontFamily: FontFamily.medium,
		color: Colors.stone[900],
		borderWidth: 2,
		borderColor: Colors.stone[200],
		textAlign: "center",
	},
	spacer: {
		flex: 1,
	},
	buttonArea: {
		paddingHorizontal: 16,
		paddingTop: 20,
	},
});

export default NicknameScreen;
