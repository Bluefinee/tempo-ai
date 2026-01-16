/**
 * Personalize Screen - Onboarding Step 2
 * Goal selection and wake/sleep time settings
 */

import * as Haptics from "expo-haptics";
import { useRouter } from "expo-router";
import { ChevronDown } from "lucide-react-native";
import type { ReactElement } from "react";
import { useEffect, useState } from "react";
import {
	KeyboardAvoidingView,
	Platform,
	ScrollView,
	StyleSheet,
	Text,
	TouchableOpacity,
	View,
} from "react-native";
import Animated, {
	FadeIn,
	useAnimatedStyle,
	useSharedValue,
	withDelay,
	withTiming,
} from "react-native-reanimated";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import {
	AnimatedButton,
	GoalCard,
	OnboardingContainer,
} from "../../src/components/onboarding";
import { ONBOARDING_GOALS } from "../../src/domain/models/onboarding";
import { t } from "../../src/i18n";
import { useOnboardingStore } from "../../src/stores/onboardingStore";
import { Colors, FontFamily, Typography } from "../../src/theme";

// Generate time options
const generateTimeOptions = (startHour: number, endHour: number): string[] => {
	const options: string[] = [];
	for (let h = startHour; h <= endHour; h++) {
		for (const m of ["00", "15", "30", "45"]) {
			const hour = h < 24 ? h : h - 24;
			options.push(`${hour.toString().padStart(2, "0")}:${m}`);
		}
	}
	return options;
};

const WAKE_UP_OPTIONS = generateTimeOptions(5, 10); // 5:00 - 10:45
const BED_TIME_OPTIONS = generateTimeOptions(20, 25); // 20:00 - 1:45

// Goal ID to i18n key mapping
const goalI18nKeys: Record<string, string> = {
	better_sleep: "betterSleep",
	more_energy: "moreEnergy",
	less_stress: "lessStress",
	peak_performance: "peakPerformance",
};

interface TimePickerProps {
	label: string;
	value: string;
	options: string[];
	onChange: (value: string) => void;
}

const TimePicker = ({
	label,
	value,
	options,
	onChange,
}: TimePickerProps): ReactElement => {
	const [isOpen, setIsOpen] = useState(false);

	const handleSelect = (time: string) => {
		Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
		onChange(time);
		setIsOpen(false);
	};

	const formatDisplayTime = (time: string): string => {
		const [hourStr, minute] = time.split(":");
		const hour = Number.parseInt(hourStr, 10);
		if (hour >= 24) {
			return `${(hour - 24).toString().padStart(2, "0")}:${minute}`;
		}
		return time;
	};

	return (
		<View style={styles.timePickerContainer}>
			<Text style={styles.timePickerLabel}>{label}</Text>
			<TouchableOpacity
				style={styles.timePickerButton}
				onPress={() => {
					Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
					setIsOpen(!isOpen);
				}}
				activeOpacity={0.8}
			>
				<Text style={styles.timePickerValue}>{formatDisplayTime(value)}</Text>
				<ChevronDown
					size={20}
					color={Colors.stone[500]}
					style={{
						transform: [{ rotate: isOpen ? "180deg" : "0deg" }],
					}}
				/>
			</TouchableOpacity>

			{isOpen && (
				<Animated.View
					entering={FadeIn.duration(200)}
					style={styles.timePickerDropdown}
				>
					<ScrollView
						style={styles.timePickerScroll}
						showsVerticalScrollIndicator={false}
						nestedScrollEnabled
					>
						{options.map((time) => (
							<TouchableOpacity
								key={time}
								style={[
									styles.timePickerOption,
									time === value && styles.timePickerOptionSelected,
								]}
								onPress={() => handleSelect(time)}
							>
								<Text
									style={[
										styles.timePickerOptionText,
										time === value && styles.timePickerOptionTextSelected,
									]}
								>
									{formatDisplayTime(time)}
								</Text>
							</TouchableOpacity>
						))}
					</ScrollView>
				</Animated.View>
			)}
		</View>
	);
};

const PersonalizeScreen = (): ReactElement => {
	const router = useRouter();
	const insets = useSafeAreaInsets();
	const { goals, wakeUpTime, bedTime, toggleGoal, setWakeUpTime, setBedTime } =
		useOnboardingStore();

	// Animation values
	const titleOpacity = useSharedValue(0);
	const cardsOpacity = useSharedValue(0);
	const scheduleOpacity = useSharedValue(0);
	const buttonOpacity = useSharedValue(0);

	useEffect(() => {
		titleOpacity.value = withDelay(200, withTiming(1, { duration: 500 }));
		cardsOpacity.value = withDelay(400, withTiming(1, { duration: 500 }));
		scheduleOpacity.value = withDelay(600, withTiming(1, { duration: 500 }));
		buttonOpacity.value = withDelay(800, withTiming(1, { duration: 500 }));
	}, [buttonOpacity, cardsOpacity, scheduleOpacity, titleOpacity]);

	const titleStyle = useAnimatedStyle(() => ({
		opacity: titleOpacity.value,
	}));

	const cardsStyle = useAnimatedStyle(() => ({
		opacity: cardsOpacity.value,
	}));

	const scheduleStyle = useAnimatedStyle(() => ({
		opacity: scheduleOpacity.value,
	}));

	const buttonStyle = useAnimatedStyle(() => ({
		opacity: buttonOpacity.value,
	}));

	const handleNext = () => {
		router.push("./connect");
	};

	const canProceed = goals.length >= 1;

	return (
		<OnboardingContainer step={2} blobVariant="default">
			<KeyboardAvoidingView
				style={styles.keyboardView}
				behavior={Platform.OS === "ios" ? "padding" : "height"}
			>
				<ScrollView
					style={styles.scrollView}
					contentContainerStyle={[
						styles.scrollContent,
						{ paddingBottom: 160 + insets.bottom },
					]}
					showsVerticalScrollIndicator={false}
					keyboardShouldPersistTaps="handled"
				>
					{/* Title */}
					<Animated.View style={[styles.titleContainer, titleStyle]}>
						<Text style={styles.title}>
							{t("onboarding.personalize.title")}
						</Text>
						<Text style={styles.subtitle}>
							{t("onboarding.personalize.subtitle")}
						</Text>
					</Animated.View>

					{/* Goal cards grid */}
					<Animated.View style={[styles.cardsGrid, cardsStyle]}>
						{ONBOARDING_GOALS.map((goal) => (
							<GoalCard
								key={goal.id}
								goal={goal.id}
								title={t(
									`onboarding.personalize.goals.${goalI18nKeys[goal.id]}`,
								)}
								isSelected={goals.includes(goal.id)}
								onSelect={() => toggleGoal(goal.id)}
								disabled={goals.length >= 3 && !goals.includes(goal.id)}
							/>
						))}
					</Animated.View>

					{/* Schedule settings - directly after cards */}
					<Animated.View style={[styles.scheduleSection, scheduleStyle]}>
						<Text style={styles.scheduleSectionTitle}>
							{t("onboarding.personalize.scheduleTitle")}
						</Text>
						<View style={styles.timePickersRow}>
							<View style={styles.timePickerWrapper}>
								<TimePicker
									label={t("onboarding.personalize.wakeUp")}
									value={wakeUpTime}
									options={WAKE_UP_OPTIONS}
									onChange={setWakeUpTime}
								/>
							</View>
							<View style={styles.timePickerWrapper}>
								<TimePicker
									label={t("onboarding.personalize.bedTime")}
									value={bedTime}
									options={BED_TIME_OPTIONS}
									onChange={setBedTime}
								/>
							</View>
						</View>
					</Animated.View>
				</ScrollView>

				{/* Fixed button area */}
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
						{t("onboarding.personalize.next")}
					</AnimatedButton>
					{!canProceed && (
						<Text style={styles.hintText}>
							{t("onboarding.personalize.hint")}
						</Text>
					)}
				</Animated.View>
			</KeyboardAvoidingView>
		</OnboardingContainer>
	);
};

const styles = StyleSheet.create({
	keyboardView: {
		flex: 1,
	},
	scrollView: {
		flex: 1,
	},
	scrollContent: {
		paddingBottom: 160,
	},
	titleContainer: {
		alignItems: "center",
		marginTop: 0,
		marginBottom: 12,
	},
	title: {
		...Typography.heading2,
		color: Colors.stone[900],
		textAlign: "center",
		lineHeight: 32,
		marginBottom: 8,
	},
	subtitle: {
		fontFamily: FontFamily.regular,
		fontSize: 15,
		color: Colors.stone[500],
	},
	cardsGrid: {
		flexDirection: "row",
		flexWrap: "wrap",
		justifyContent: "space-between",
		paddingHorizontal: 4,
		gap: 10,
		marginBottom: 8,
	},
	scheduleSection: {
		paddingHorizontal: 4,
		zIndex: 10,
		marginBottom: 8,
	},
	scheduleSectionTitle: {
		fontFamily: FontFamily.semibold,
		fontSize: 15,
		fontWeight: "600",
		color: Colors.stone[900],
		marginBottom: 8,
	},
	timePickersRow: {
		flexDirection: "row",
		gap: 16,
	},
	timePickerWrapper: {
		flex: 1,
		zIndex: 10,
	},
	timePickerContainer: {
		position: "relative",
		zIndex: 10,
	},
	timePickerLabel: {
		fontFamily: FontFamily.medium,
		fontSize: 13,
		color: Colors.stone[500],
		marginBottom: 8,
	},
	timePickerButton: {
		flexDirection: "row",
		alignItems: "center",
		justifyContent: "space-between",
		backgroundColor: Colors.white,
		borderRadius: 12,
		paddingVertical: 14,
		paddingHorizontal: 16,
		borderWidth: 1,
		borderColor: Colors.stone[200],
	},
	timePickerValue: {
		fontFamily: FontFamily.semibold,
		fontSize: 20,
		fontWeight: "600",
		color: Colors.stone[900],
	},
	timePickerDropdown: {
		position: "absolute",
		top: "100%",
		left: 0,
		right: 0,
		marginTop: 4,
		backgroundColor: Colors.white,
		borderRadius: 12,
		borderWidth: 1,
		borderColor: Colors.stone[200],
		shadowColor: Colors.stone[900],
		shadowOffset: { width: 0, height: 4 },
		shadowOpacity: 0.1,
		shadowRadius: 12,
		elevation: 8,
		zIndex: 100,
	},
	timePickerScroll: {
		maxHeight: 200,
	},
	timePickerOption: {
		paddingVertical: 12,
		paddingHorizontal: 16,
	},
	timePickerOptionSelected: {
		backgroundColor: Colors.indigo[50],
	},
	timePickerOptionText: {
		fontFamily: FontFamily.regular,
		fontSize: 16,
		color: Colors.stone[700],
		textAlign: "center",
	},
	timePickerOptionTextSelected: {
		fontFamily: FontFamily.semibold,
		color: Colors.indigo[600],
		fontWeight: "600",
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
	hintText: {
		fontFamily: FontFamily.regular,
		fontSize: 13,
		color: Colors.stone[500],
		textAlign: "center",
		marginTop: 12,
	},
});

export default PersonalizeScreen;
