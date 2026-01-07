/**
 * Breathe Store - 呼吸エクササイズ状態管理
 * @see docs/specs/product_spec.md
 */

import { create } from 'zustand';

// ========================================
// Types
// ========================================

type BreathePhase = 'idle' | 'inhale' | 'hold' | 'exhale';

interface BreatheState {
  // Session State
  isActive: boolean;
  isPaused: boolean;
  phase: BreathePhase;

  // Timing
  sessionDuration: number;      // 総セッション時間（秒）
  elapsedTime: number;          // 経過時間（秒）
  phaseTimeRemaining: number;   // 現在フェーズ残り時間（ミリ秒）

  // Settings
  hapticEnabled: boolean;

  // Stats
  completedSessions: number;

  // Actions
  start: () => void;
  pause: () => void;
  resume: () => void;
  stop: () => void;
  startSession: () => void;
  pauseSession: () => void;
  resumeSession: () => void;
  stopSession: () => void;
  setPhase: (phase: BreathePhase) => void;
  updateElapsedTime: (seconds: number) => void;
  setPhaseTimeRemaining: (ms: number) => void;
  setHapticEnabled: (enabled: boolean) => void;
  incrementCompletedSessions: () => void;
  reset: () => void;
}

// ========================================
// Constants
// ========================================

const DEFAULT_SESSION_DURATION = 60; // 1分

// ========================================
// Store
// ========================================

export const useBreatheStore = create<BreatheState>((set, get) => ({
  // Initial State
  isActive: false,
  isPaused: false,
  phase: 'idle',
  sessionDuration: DEFAULT_SESSION_DURATION,
  elapsedTime: 0,
  phaseTimeRemaining: 0,
  hapticEnabled: true,
  completedSessions: 0,

  // Actions (alias for compatibility)
  start: () => {
    set({
      isActive: true,
      isPaused: false,
      phase: 'inhale',
      elapsedTime: 0,
    });
  },

  pause: () => {
    set({ isPaused: true });
  },

  resume: () => {
    set({ isPaused: false });
  },

  stop: () => {
    set({
      isActive: false,
      isPaused: false,
      phase: 'idle',
      elapsedTime: 0,
      phaseTimeRemaining: 0,
    });
  },

  startSession: () => {
    set({
      isActive: true,
      isPaused: false,
      phase: 'inhale',
      elapsedTime: 0,
    });
  },

  pauseSession: () => {
    set({ isPaused: true });
  },

  resumeSession: () => {
    set({ isPaused: false });
  },

  stopSession: () => {
    set({
      isActive: false,
      isPaused: false,
      phase: 'idle',
      elapsedTime: 0,
      phaseTimeRemaining: 0,
    });
  },

  setPhase: (phase) => {
    set({ phase });
  },

  updateElapsedTime: (seconds) => {
    const { sessionDuration } = get();
    set({ elapsedTime: Math.min(seconds, sessionDuration) });
  },

  setPhaseTimeRemaining: (ms) => {
    set({ phaseTimeRemaining: ms });
  },

  setHapticEnabled: (enabled) => {
    set({ hapticEnabled: enabled });
  },

  incrementCompletedSessions: () => {
    set((state) => ({
      completedSessions: state.completedSessions + 1,
    }));
  },

  reset: () => {
    set({
      isActive: false,
      isPaused: false,
      phase: 'idle',
      elapsedTime: 0,
      phaseTimeRemaining: 0,
    });
  },
}));

// ========================================
// Selectors
// ========================================

export const selectIsSessionComplete = (state: BreatheState): boolean =>
  state.elapsedTime >= state.sessionDuration;

export const selectSessionProgress = (state: BreatheState): number =>
  state.sessionDuration > 0 ? state.elapsedTime / state.sessionDuration : 0;

export const selectFormattedElapsedTime = (state: BreatheState): string => {
  const minutes = Math.floor(state.elapsedTime / 60);
  const seconds = state.elapsedTime % 60;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
};

