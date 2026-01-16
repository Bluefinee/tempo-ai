/**
 * Onboarding Store
 * Manages onboarding flow state with persistence
 */

import AsyncStorage from "@react-native-async-storage/async-storage";
import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";
import { t } from "../i18n";

type Goal = "better_sleep" | "more_energy" | "less_stress" | "peak_performance";
type Language = "en" | "ja";

export interface OnboardingState {
	// Flow state
	currentStep: number;
	isCompleted: boolean;

	// User data collected during onboarding
	nickname: string;
	goals: Goal[];
	wakeUpTime: string;
	windDownTime: string;
	bedTime: string; // Alias for windDownTime for backward compatibility
	healthKitAuthorized: boolean;
	language: Language | null;

	// Actions
	setNickname: (nickname: string) => void;
	setGoals: (goals: Goal[]) => void;
	toggleGoal: (goal: Goal) => void;
	setWakeUpTime: (time: string) => void;
	setWindDownTime: (time: string) => void;
	setBedTime: (time: string) => void; // Alias for setWindDownTime
	setHealthKitAuthorized: (authorized: boolean) => void;
	setLanguage: (language: Language) => void;
	nextStep: () => void;
	previousStep: () => void;
	setStep: (step: number) => void;
	completeOnboarding: () => void;
	complete: () => void; // Alias for completeOnboarding
	reset: () => void;
}

const TOTAL_STEPS = 4;

const initialState = {
	currentStep: 0,
	isCompleted: false,
	nickname: "",
	goals: [] as Goal[],
	wakeUpTime: "07:00",
	windDownTime: "23:00",
	bedTime: "23:00", // Alias for windDownTime
	healthKitAuthorized: false,
	language: null as Language | null,
};

export const useOnboardingStore = create<OnboardingState>()(
	persist(
		(set, get) => ({
			...initialState,

			setNickname: (nickname) => {
				const finalNickname = nickname || t("common.defaultNickname");
				set({ nickname: finalNickname });
			},

			setGoals: (goals) => set({ goals }),

			toggleGoal: (goal) => {
				const currentGoals = get().goals;
				const newGoals = currentGoals.includes(goal)
					? currentGoals.filter((g) => g !== goal)
					: [...currentGoals, goal];
				set({ goals: newGoals });
			},

			setWakeUpTime: (time) => set({ wakeUpTime: time }),

			setWindDownTime: (time) => set({ windDownTime: time, bedTime: time }),

			setBedTime: (time) => set({ windDownTime: time, bedTime: time }),

			setHealthKitAuthorized: (authorized) =>
				set({ healthKitAuthorized: authorized }),

			setLanguage: (language) => set({ language }),

			nextStep: () =>
				set((state) => ({
					currentStep: Math.min(state.currentStep + 1, TOTAL_STEPS - 1),
				})),

			previousStep: () =>
				set((state) => ({
					currentStep: Math.max(state.currentStep - 1, 0),
				})),

			setStep: (step) =>
				set({
					currentStep: Math.max(0, Math.min(step, TOTAL_STEPS - 1)),
				}),

			completeOnboarding: () =>
				set({
					isCompleted: true,
					currentStep: TOTAL_STEPS - 1,
				}),

			complete: () =>
				set({
					isCompleted: true,
					currentStep: TOTAL_STEPS - 1,
				}),

			reset: () => set(initialState),
		}),
		{
			name: "tempo-onboarding-storage",
			storage: createJSONStorage(() => AsyncStorage),
			partialize: (state) => ({
				isCompleted: state.isCompleted,
				nickname: state.nickname,
				goals: state.goals,
				wakeUpTime: state.wakeUpTime,
				windDownTime: state.windDownTime,
				healthKitAuthorized: state.healthKitAuthorized,
				language: state.language,
			}),
		},
	),
);

// Selectors
export const selectIsOnboardingComplete = (state: OnboardingState): boolean =>
	state.isCompleted;

export const selectCurrentStep = (state: OnboardingState): number =>
	state.currentStep;

export const selectNickname = (state: OnboardingState): string =>
	state.nickname;

export const selectGoals = (state: OnboardingState): Goal[] => state.goals;

export const selectWakeUpTime = (state: OnboardingState): string =>
	state.wakeUpTime;

export const selectWindDownTime = (state: OnboardingState): string =>
	state.windDownTime;
