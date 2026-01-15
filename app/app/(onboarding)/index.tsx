/**
 * Language Selection Screen - Onboarding Step 0
 * User selects their preferred language before starting
 */

import * as Haptics from "expo-haptics";
import { useRouter } from "expo-router";
import { Check, Globe } from "lucide-react-native";
import type { ReactElement } from "react";
import { useEffect, useState } from "react";
import {
	Dimensions,
	StyleSheet,
	Text,
	TouchableOpacity,
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
import { AnimatedButton } from "../../src/components/onboarding";
import { setLocale } from "../../src/i18n";
import { useOnboardingStore } from "../../src/stores/onboardingStore";
import { Colors, FontFamily, Typography } from "../../src/theme";

const { width: SCREEN_WIDTH } = Dimensions.get("window");

type Language = "en" | "ja";

interface LanguageOption {
	code: Language;
	name: string;
	nativeName: string;
}

const LANGUAGES: LanguageOption[] = [
	{ code: "en", name: "English", nativeName: "English" },
	{ code: "ja", name: "Japanese", nativeName: "日本語" },
];

interface LanguageCardProps {
	option: LanguageOption;
	isSelected: boolean;
	onSelect: () => void;
	delay: number;
}

const LanguageCard = ({
	option,
	isSelected,
	onSelect,
	delay,
}: LanguageCardProps): ReactElement => {
	const opacity = useSharedValue(0);
	const translateY = useSharedValue(20);
	const scale = useSharedValue(1);

	useEffect(() => {
		opacity.value = withDelay(delay, withTiming(1, { duration: 400 }));
		translateY.value = withDelay(
			delay,
			withSpring(0, { damping: 20, stiffness: 100 }),
		);
	}, [delay, opacity, translateY]);

	const animatedStyle = useAnimatedStyle(() => ({
		opacity: opacity.value,
		transform: [{ translateY: translateY.value }, { scale: scale.value }],
	}));

	const handlePress = () => {
		Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
		scale.value = withSpring(0.98, { damping: 15 });
		setTimeout(() => {
			scale.value = withSpring(1, { damping: 15 });
		}, 100);
		onSelect();
	};

	return (
		<Animated.View style={animatedStyle}>
			<TouchableOpacity
				style={[styles.languageCard, isSelected && styles.languageCardSelected]}
				onPress={handlePress}
				activeOpacity={0.8}
			>
				<View style={styles.languageInfo}>
					<Text
						style={[
							styles.languageName,
							isSelected && styles.languageNameSelected,
						]}
					>
						{option.nativeName}
					</Text>
					{option.code !== "en" && (
						<Text style={styles.languageSubname}>{option.name}</Text>
					)}
				</View>
				{isSelected && (
					<View style={styles.checkContainer}>
						<Check size={20} color={Colors.white} />
					</View>
				)}
			</TouchableOpacity>
		</Animated.View>
	);
};

const LanguageScreen = (): ReactElement => {
	const router = useRouter();
	const insets = useSafeAreaInsets();
	const { language, setLanguage } = useOnboardingStore();
	const [selectedLanguage, setSelectedLanguage] = useState<Language>(language);

	// Animation values
	const iconOpacity = useSharedValue(0);
	const iconScale = useSharedValue(0.8);
	const titleOpacity = useSharedValue(0);
	const buttonOpacity = useSharedValue(0);

	useEffect(() => {
		iconOpacity.value = withDelay(200, withTiming(1, { duration: 500 }));
		iconScale.value = withDelay(
			200,
			withSpring(1, { damping: 12, stiffness: 100 }),
		);
		titleOpacity.value = withDelay(400, withTiming(1, { duration: 500 }));
		buttonOpacity.value = withDelay(800, withTiming(1, { duration: 500 }));
	}, [buttonOpacity, iconOpacity, iconScale, titleOpacity]);

	const iconStyle = useAnimatedStyle(() => ({
		opacity: iconOpacity.value,
		transform: [{ scale: iconScale.value }],
	}));

	const titleStyle = useAnimatedStyle(() => ({
		opacity: titleOpacity.value,
	}));

	const buttonStyle = useAnimatedStyle(() => ({
		opacity: buttonOpacity.value,
	}));

	const handleSelectLanguage = (code: Language) => {
		setSelectedLanguage(code);
		setLocale(code);
		setLanguage(code);
	};

	const handleContinue = () => {
		Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
		router.push("./welcome");
	};

	return (
		<View style={[styles.container, { paddingTop: insets.top + 40 }]}>
			{/* Icon */}
			<Animated.View style={[styles.iconContainer, iconStyle]}>
				<View style={styles.iconOuter}>
					<View style={styles.iconInner}>
						<Globe size={40} color={Colors.indigo[500]} />
					</View>
				</View>
			</Animated.View>

			{/* Title - bilingual */}
			<Animated.View style={[styles.titleContainer, titleStyle]}>
				<Text style={styles.title}>Choose your language</Text>
				<Text style={styles.titleJa}>言語を選択</Text>
			</Animated.View>

			{/* Language options */}
			<View style={styles.languageList}>
				{LANGUAGES.map((lang, index) => (
					<LanguageCard
						key={lang.code}
						option={lang}
						isSelected={selectedLanguage === lang.code}
						onSelect={() => handleSelectLanguage(lang.code)}
						delay={500 + index * 100}
					/>
				))}
			</View>

			{/* Continue button */}
			<Animated.View
				style={[
					styles.buttonArea,
					buttonStyle,
					{ paddingBottom: Math.max(insets.bottom, 24) },
				]}
			>
				<AnimatedButton onPress={handleContinue} variant="primary">
					Continue
				</AnimatedButton>
			</Animated.View>
		</View>
	);
};

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: Colors.stone[50],
		paddingHorizontal: 24,
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
		marginBottom: 40,
	},
	title: {
		...Typography.heading2,
		color: Colors.stone[900],
		textAlign: "center",
		marginBottom: 8,
	},
	titleJa: {
		fontFamily: FontFamily.regular,
		fontSize: 18,
		color: Colors.stone[500],
		textAlign: "center",
	},
	languageList: {
		gap: 12,
	},
	languageCard: {
		flexDirection: "row",
		alignItems: "center",
		justifyContent: "space-between",
		backgroundColor: Colors.white,
		borderRadius: 16,
		padding: 20,
		borderWidth: 2,
		borderColor: Colors.stone[200],
	},
	languageCardSelected: {
		borderColor: Colors.indigo[500],
		backgroundColor: Colors.indigo[50],
	},
	languageInfo: {
		flex: 1,
	},
	languageName: {
		fontFamily: FontFamily.semibold,
		fontSize: 18,
		fontWeight: "600",
		color: Colors.stone[900],
	},
	languageNameSelected: {
		color: Colors.indigo[700],
	},
	languageSubname: {
		fontFamily: FontFamily.regular,
		fontSize: 14,
		color: Colors.stone[500],
		marginTop: 2,
	},
	checkContainer: {
		width: 32,
		height: 32,
		borderRadius: 16,
		backgroundColor: Colors.indigo[500],
		alignItems: "center",
		justifyContent: "center",
	},
	buttonArea: {
		position: "absolute",
		bottom: 0,
		left: 0,
		right: 0,
		paddingTop: 20,
		paddingHorizontal: 24,
		backgroundColor: Colors.stone[50],
	},
});

export default LanguageScreen;
