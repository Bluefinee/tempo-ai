/**
 * オンボーディング専用ストア
 * 4ステップのオンボーディングフローを管理
 */

import AsyncStorage from "@react-native-async-storage/async-storage";
import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";
import {
	DEFAULT_BED_TIME,
	DEFAULT_WAKE_UP_TIME,
	ONBOARDING_TOTAL_STEPS,
	type OnboardingGoal,
} from "../domain/models/onboarding";
import { t } from "../i18n";
import { useUserStore } from "./userStore";

type AppLanguage = "en" | "ja";

interface OnboardingStore {
	// State
	currentStep: number;
	language: AppLanguage;
	nickname: string;
	goals: OnboardingGoal[];
	wakeUpTime: string;
	bedTime: string;
	healthKitAuthorized: boolean;
	isComplete: boolean;

	// Actions
	setStep: (step: number) => void;
	nextStep: () => void;
	previousStep: () => void;
	setLanguage: (language: AppLanguage) => void;
	setNickname: (nickname: string) => void;
	setGoals: (goals: OnboardingGoal[]) => void;
	toggleGoal: (goal: OnboardingGoal) => void;
	setWakeUpTime: (time: string) => void;
	setBedTime: (time: string) => void;
	setHealthKitAuthorized: (authorized: boolean) => void;
	complete: () => void;
	reset: () => void;
}

const initialState = {
	currentStep: 1,
	language: "en" as AppLanguage,
	nickname: "",
	goals: [] as OnboardingGoal[],
	wakeUpTime: DEFAULT_WAKE_UP_TIME,
	bedTime: DEFAULT_BED_TIME,
	healthKitAuthorized: false,
	isComplete: false,
};

export const useOnboardingStore = create<OnboardingStore>()(
	persist(
		(set, get) => ({
			...initialState,

			setStep: (step) => {
				const validStep = Math.max(1, Math.min(step, ONBOARDING_TOTAL_STEPS));
				set({ currentStep: validStep });
			},

			nextStep: () => {
				const { currentStep } = get();
				if (currentStep < ONBOARDING_TOTAL_STEPS) {
					set({ currentStep: currentStep + 1 });
				}
			},

			previousStep: () => {
				const { currentStep } = get();
				if (currentStep > 1) {
					set({ currentStep: currentStep - 1 });
				}
			},

			setLanguage: (language) => {
				set({ language });
			},

			setNickname: (nickname) => {
				set({ nickname });
			},

			setGoals: (goals) => {
				set({ goals });
			},

			toggleGoal: (goal) => {
				const { goals } = get();
				const MAX_GOALS = 3;

				if (goals.includes(goal)) {
					// 選択解除
					set({ goals: goals.filter((g) => g !== goal) });
				} else if (goals.length < MAX_GOALS) {
					// 追加（最大3つまで）
					set({ goals: [...goals, goal] });
				}
				// MAX_GOALS に達している場合は何もしない
			},

			setWakeUpTime: (time) => {
				set({ wakeUpTime: time });
			},

			setBedTime: (time) => {
				set({ bedTime: time });
			},

			setHealthKitAuthorized: (authorized) => {
				set({ healthKitAuthorized: authorized });
			},

			complete: () => {
				const { bedTime, nickname } = get();
				const userStore = useUserStore.getState();

				// 先にオンボーディング完了でプロファイルを初期化
				userStore.completeOnboarding();

				// その後でニックネームと就寝時間を更新
				userStore.updateProfile({
					nickname: nickname || t("common.defaultNickname"),
					targetBedtime: bedTime,
				});

				set({ isComplete: true });
			},

			reset: () => {
				set(initialState);
			},
		}),
		{
			name: "tempo-onboarding-storage",
			storage: createJSONStorage(() => AsyncStorage),
			partialize: (state) => ({
				currentStep: state.currentStep,
				language: state.language,
				nickname: state.nickname,
				goals: state.goals,
				wakeUpTime: state.wakeUpTime,
				bedTime: state.bedTime,
				healthKitAuthorized: state.healthKitAuthorized,
				isComplete: state.isComplete,
			}),
		},
	),
);

// Selectors
export const selectCanProceedFromPersonalize = (
	state: OnboardingStore,
): boolean => {
	return state.goals.length >= 1;
};

export const selectProgress = (state: OnboardingStore): number => {
	return (state.currentStep / ONBOARDING_TOTAL_STEPS) * 100;
};

export const selectIsGoalSelected = (
	state: OnboardingStore,
	goal: OnboardingGoal,
): boolean => {
	return state.goals.includes(goal);
};
