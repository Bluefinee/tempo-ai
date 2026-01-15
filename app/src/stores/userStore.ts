import AsyncStorage from "@react-native-async-storage/async-storage";
import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";
import {
	type AlcoholFrequency,
	CALIBRATION_PERIOD_DAYS,
	type Chronotype,
	type ExerciseFrequency,
	type Gender,
	type Occupation,
	type UserProfile,
} from "../domain/models";
import { ONBOARDING_TOTAL_STEPS } from "../domain/models/onboarding";

// 新規: Types
type Goal = "better_sleep" | "more_energy" | "less_stress" | "peak_performance";

interface UserPreferences {
	gentleNudges: boolean;
	hapticFeedback: boolean;
}

interface UserState {
	// User profile (既存)
	profile: UserProfile | null;

	// Onboarding state (既存)
	isOnboardingComplete: boolean;
	onboardingStep: number;

	// Draft profile during onboarding (既存)
	draftProfile: Partial<UserProfile>;

	// 新規: Preferences
	preferences: UserPreferences;

	// 新規: Onboarding
	onboardingCompleted: boolean;

	// Actions (既存)
	setDraftNickname: (nickname: string) => void;
	setDraftBasicInfo: (info: {
		age?: number;
		gender?: Gender;
		heightCm?: number;
		weightKg?: number;
	}) => void;
	setDraftChronotype: (chronotype: Chronotype) => void;
	setDraftTargetBedtime: (bedtime: string) => void;
	setDraftLifestyle: (lifestyle: {
		occupation?: Occupation;
		exerciseFrequency?: ExerciseFrequency;
		alcoholFrequency?: AlcoholFrequency;
	}) => void;
	nextOnboardingStep: () => void;
	previousOnboardingStep: () => void;
	setOnboardingStep: (step: number) => void;
	completeOnboarding: () => void;
	updateProfile: (updates: Partial<UserProfile>) => void;
	incrementCalibrationDay: () => void;
	resetUser: () => void;

	// 新規: Actions
	setProfile: (
		profile: Partial<
			UserProfile & {
				goals?: Goal[];
				wakeUpTime?: string;
				windDownTime?: string;
			}
		>,
	) => void;
	setGoals: (goals: Goal[]) => void;
	setWakeUpTime: (time: string) => void;
	setWindDownTime: (time: string) => void;
	setPreferences: (prefs: Partial<UserPreferences>) => void;
	resetOnboarding: () => void;
	reset: () => void;
}

// ONBOARDING_TOTAL_STEPS は onboarding.ts からインポート

const initialPreferences: UserPreferences = {
	gentleNudges: true,
	hapticFeedback: true,
};

const createDefaultProfile = (draft: Partial<UserProfile>): UserProfile => ({
	id: `user_${Date.now()}`,
	nickname: draft.nickname || "ユーザー",
	age: draft.age || 30,
	gender: draft.gender || "other",
	heightCm: draft.heightCm,
	weightKg: draft.weightKg,
	chronotype: draft.chronotype || "intermediate",
	targetBedtime: draft.targetBedtime || "23:00",
	occupation: draft.occupation,
	exerciseFrequency: draft.exerciseFrequency,
	alcoholFrequency: draft.alcoholFrequency,
	calibrationDaysCompleted: 0,
	createdAt: new Date(),
	updatedAt: new Date(),
});

export const useUserStore = create<UserState>()(
	persist(
		(set, get) => ({
			profile: null,
			isOnboardingComplete: false,
			onboardingStep: 0,
			draftProfile: {},
			preferences: initialPreferences,
			onboardingCompleted: false,

			setDraftNickname: (nickname) =>
				set((state) => ({
					draftProfile: { ...state.draftProfile, nickname },
				})),

			setDraftBasicInfo: (info) =>
				set((state) => ({
					draftProfile: { ...state.draftProfile, ...info },
				})),

			setDraftChronotype: (chronotype) =>
				set((state) => ({
					draftProfile: { ...state.draftProfile, chronotype },
				})),

			setDraftTargetBedtime: (targetBedtime) =>
				set((state) => ({
					draftProfile: { ...state.draftProfile, targetBedtime },
				})),

			setDraftLifestyle: (lifestyle) =>
				set((state) => ({
					draftProfile: { ...state.draftProfile, ...lifestyle },
				})),

			nextOnboardingStep: () =>
				set((state) => ({
					onboardingStep: Math.min(
						state.onboardingStep + 1,
						ONBOARDING_TOTAL_STEPS - 1,
					),
				})),

			previousOnboardingStep: () =>
				set((state) => ({
					onboardingStep: Math.max(state.onboardingStep - 1, 0),
				})),

			setOnboardingStep: (step) =>
				set({
					onboardingStep: Math.max(
						0,
						Math.min(step, ONBOARDING_TOTAL_STEPS - 1),
					),
				}),

			completeOnboarding: () => {
				const { draftProfile } = get();
				const profile = createDefaultProfile(draftProfile);
				set({
					profile,
					isOnboardingComplete: true,
					draftProfile: {},
				});
			},

			updateProfile: (updates) =>
				set((state) => ({
					profile: state.profile
						? { ...state.profile, ...updates, updatedAt: new Date() }
						: null,
				})),

			incrementCalibrationDay: () =>
				set((state) => ({
					profile: state.profile
						? {
								...state.profile,
								calibrationDaysCompleted: Math.min(
									state.profile.calibrationDaysCompleted + 1,
									CALIBRATION_PERIOD_DAYS,
								),
								updatedAt: new Date(),
							}
						: null,
				})),

			resetUser: () =>
				set({
					profile: null,
					isOnboardingComplete: false,
					onboardingStep: 0,
					draftProfile: {},
				}),

			// 新規: Actions
			setProfile: (partialProfile) => {
				set((state) => ({
					profile: state.profile
						? { ...state.profile, ...partialProfile }
						: null,
				}));
			},

			setGoals: (goals) => {
				set((state) => ({
					profile: state.profile
						? { ...state.profile, goals: goals as unknown as string[] }
						: null,
				}));
			},

			setWakeUpTime: (time) => {
				set((state) => ({
					profile: state.profile
						? { ...state.profile, wakeUpTime: time as unknown as string }
						: null,
				}));
			},

			setWindDownTime: (time) => {
				set((state) => ({
					profile: state.profile
						? { ...state.profile, windDownTime: time as unknown as string }
						: null,
				}));
			},

			setPreferences: (prefs) => {
				set((state) => ({
					preferences: { ...state.preferences, ...prefs },
				}));
			},

			resetOnboarding: () => {
				set({
					onboardingCompleted: false,
					profile: null,
				});
			},

			reset: () => {
				set({
					profile: null,
					preferences: initialPreferences,
					onboardingCompleted: false,
				});
			},
		}),
		{
			name: "tempo-user-storage",
			storage: createJSONStorage(() => AsyncStorage),
			partialize: (state) => ({
				profile: state.profile,
				isOnboardingComplete: state.isOnboardingComplete,
				preferences: state.preferences,
				onboardingCompleted: state.onboardingCompleted,
			}),
		},
	),
);

// Selectors (既存)
export const selectIsCalibrating = (state: UserState): boolean =>
	state.profile !== null &&
	state.profile.calibrationDaysCompleted < CALIBRATION_PERIOD_DAYS;

export const selectCalibrationProgress = (state: UserState): number =>
	state.profile
		? (state.profile.calibrationDaysCompleted / CALIBRATION_PERIOD_DAYS) * 100
		: 0;

// 新規: Selectors
export const selectNickname = (state: UserState): string =>
	state.profile?.nickname ?? "";

export const selectGoals = (state: UserState): Goal[] =>
	(state.profile as unknown as { goals?: Goal[] })?.goals ?? [];

export const selectWakeUpTime = (state: UserState): string =>
	(state.profile as unknown as { wakeUpTime?: string })?.wakeUpTime ?? "07:00";

export const selectWindDownTime = (state: UserState): string =>
	(state.profile as unknown as { windDownTime?: string })?.windDownTime ??
	"23:00";

export const selectHapticEnabled = (state: UserState): boolean =>
	state.preferences.hapticFeedback;
