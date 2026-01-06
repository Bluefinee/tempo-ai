import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  UserProfile,
  Chronotype,
  Gender,
  Occupation,
  ExerciseFrequency,
  AlcoholFrequency,
  CALIBRATION_PERIOD_DAYS,
} from '../domain/models';

interface UserState {
  // User profile
  profile: UserProfile | null;

  // Onboarding state
  isOnboardingComplete: boolean;
  onboardingStep: number;

  // Draft profile during onboarding
  draftProfile: Partial<UserProfile>;

  // Actions
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

  // Onboarding navigation
  nextOnboardingStep: () => void;
  previousOnboardingStep: () => void;
  setOnboardingStep: (step: number) => void;

  // Complete onboarding
  completeOnboarding: () => void;

  // Update profile after onboarding
  updateProfile: (updates: Partial<UserProfile>) => void;

  // Calibration
  incrementCalibrationDay: () => void;

  // Reset
  resetUser: () => void;
}

const TOTAL_ONBOARDING_STEPS = 9;

const createDefaultProfile = (draft: Partial<UserProfile>): UserProfile => ({
  id: `user_${Date.now()}`,
  nickname: draft.nickname || 'ユーザー',
  age: draft.age || 30,
  gender: draft.gender || 'other',
  heightCm: draft.heightCm,
  weightKg: draft.weightKg,
  chronotype: draft.chronotype || 'intermediate',
  targetBedtime: draft.targetBedtime || '23:00',
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
          onboardingStep: Math.min(state.onboardingStep + 1, TOTAL_ONBOARDING_STEPS - 1),
        })),

      previousOnboardingStep: () =>
        set((state) => ({
          onboardingStep: Math.max(state.onboardingStep - 1, 0),
        })),

      setOnboardingStep: (step) =>
        set({ onboardingStep: Math.max(0, Math.min(step, TOTAL_ONBOARDING_STEPS - 1)) }),

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
                  CALIBRATION_PERIOD_DAYS
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
    }),
    {
      name: 'tempo-user-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        profile: state.profile,
        isOnboardingComplete: state.isOnboardingComplete,
      }),
    }
  )
);

// Selectors
export const selectIsCalibrating = (state: UserState): boolean =>
  state.profile !== null &&
  state.profile.calibrationDaysCompleted < CALIBRATION_PERIOD_DAYS;

export const selectCalibrationProgress = (state: UserState): number =>
  state.profile
    ? (state.profile.calibrationDaysCompleted / CALIBRATION_PERIOD_DAYS) * 100
    : 0;
