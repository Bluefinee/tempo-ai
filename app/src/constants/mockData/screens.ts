/**
 * Mock Screen Data
 * Mock data used by each screen
 */

import { Sun, Moon } from "lucide-react-native";
import { Colors } from "../../theme";
import { MOCK_AI_RESPONSE } from "./aiResponse";

/**
 * Pressure Trend Type
 */
export type PressureTrend = "rising" | "stable" | "falling";

/**
 * Environment Data Type (API ready)
 * Will be dynamically fetched from Weather API in the future
 */
export interface EnvironmentData {
  // Sunrise/Sunset
  sunrise: string; // "6:50" format
  sunset: string; // "16:48" format
  sunriseTime: Date; // Full Date (for calculations)
  sunsetTime: Date; // Full Date (for calculations)
  dayLengthMinutes: number; // Daylight duration (minutes)
  location: string;
  // Weather
  weather: {
    condition: string; // Weather condition (Clear, Cloudy, etc.)
    temperature: number; // Temperature °C
    humidity: number; // Humidity %
  };
  // Pressure
  pressure: {
    value: number; // Pressure hPa
    trend: PressureTrend; // Trend
    change24h: number; // 24h change hPa
  };
  // UV Index
  uv: {
    index: number; // UV Index (0-11+)
    level: string; // Level (Low, Moderate, etc.)
  };
  // Moon Phase
  moonPhase: {
    phase: string; // Moon phase (New Moon, Full Moon, etc.)
    illumination: number; // Illumination 0-100%
  };
}

/**
 * Get environment data (currently mock, will support API in the future)
 * @param _latitude Latitude (for future API)
 * @param _longitude Longitude (for future API)
 * @returns Environment data
 */
export const getEnvironmentData = (
  _latitude?: number,
  _longitude?: number,
): EnvironmentData => {
  // TODO: Replace with actual API fetch
  // const response = await fetch(`/api/environment?lat=${latitude}&lon=${longitude}`);
  const today = new Date();
  const sunriseTime = new Date(today);
  sunriseTime.setHours(6, 50, 0, 0);
  const sunsetTime = new Date(today);
  sunsetTime.setHours(16, 48, 0, 0);

  return {
    // Sunrise/Sunset
    sunrise: "6:50",
    sunset: "16:48",
    sunriseTime,
    sunsetTime,
    dayLengthMinutes: Math.round(
      (sunsetTime.getTime() - sunriseTime.getTime()) / 60000,
    ),
    location: "Tokyo",
    // Weather
    weather: {
      condition: "Clear",
      temperature: 8,
      humidity: 45,
    },
    // Pressure
    pressure: {
      value: 1018,
      trend: "stable",
      change24h: 2,
    },
    // UV Index
    uv: {
      index: 3,
      level: "Moderate",
    },
    // Moon Phase
    moonPhase: {
      phase: "First Quarter",
      illumination: 48,
    },
  };
};

/**
 * TODAY SCREEN MOCK DATA
 * Formatted data for screen display (derived from MOCK_AI_RESPONSE)
 */
export const MOCK_TODAY = {
  // AI Insight card
  aiMessage: {
    title: MOCK_AI_RESPONSE.todayInsight.title,
    body: MOCK_AI_RESPONSE.todayInsight.summary,
  },
  // Today's One Thing
  oneThing: {
    icon: MOCK_AI_RESPONSE.todayOneThing.icon,
    action: MOCK_AI_RESPONSE.todayOneThing.action,
    summary: MOCK_AI_RESPONSE.todayOneThing.summary,
    time: MOCK_AI_RESPONSE.todayOneThing.time,
  },
  // Related Insight
  insight: {
    label: MOCK_AI_RESPONSE.relatedInsight.label,
    text: MOCK_AI_RESPONSE.relatedInsight.text,
  },
  // Scores (frontend calculated)
  scores: {
    recovery: 70,
    sleep: 85,
    rhythm: 92,
    energy: 78,
  },
  // Health metrics (frontend calculated)
  health: {
    hrv: { value: 82, unit: "ms", baseline: 77, deviation: "+6%" },
    rhr: { value: 59, unit: "bpm", baseline: 59, deviation: "0%" },
    sleep: {
      duration: "7h 8m",
      deepSleep: "1h 45m",
      deepSleepPercent: 23,
      remSleep: "1h 35m",
      remSleepPercent: 22,
      bedtime: "23:15",
      wakeTime: "06:45",
    },
  },
};

/**
 * RHYTHM SCREEN MOCK DATA
 */
export const MOCK_RHYTHM = {
  // Current time indicator
  currentTime: "10:42",
  // Upcoming Windows
  upcomingWindows: [
    {
      type: "peak" as const,
      icon: Sun,
      iconBg: Colors.amber[100],
      iconColor: Colors.amber[600],
      title: "Peak Focus",
      time: "Now — 12:00",
      description:
        "Great time for complex problem-solving and tasks requiring deep concentration. Your cognitive performance is at its peak.",
      active: true,
    },
    {
      type: "windDown" as const,
      icon: Moon,
      iconBg: Colors.indigo[100],
      iconColor: Colors.indigo[600],
      title: "Wind Down",
      time: "21:30 — 7:00",
      description:
        "Dim the lights and reduce screen time to prepare for sleep. Your body is entering rest mode.",
      active: false,
    },
  ],
  // Environment data - recommend using getEnvironmentData() for dynamic fetch
  ...getEnvironmentData(),
};

/**
 * Alert Type
 */
export type AlertType =
  | "recovery_complete"
  | "late_caffeine"
  | "weekend_jetlag";

/**
 * INSIGHTS SCREEN MOCK DATA
 */
export const MOCK_INSIGHTS = {
  weeklyScores: [40, 60, 75, 45, 80, 90, 70],
  avgScore: 74,
  todayIndex: 1, // Tuesday (0 = Monday)
  // Top Discovery (AI generated)
  topDiscovery: {
    title: "Evening walks improve deep sleep",
    description:
      "On days when you walk more than 15 minutes after 6pm, your deep sleep score tends to be 18% higher.",
  },
  // Recent Alerts (system generated)
  recentAlerts: [
    {
      id: "1",
      type: "recovery_complete" as const,
      title: "Recovery Complete",
      desc: "Your HRV has returned to baseline after yesterday's workout.",
      time: "Today",
    },
    {
      id: "2",
      type: "late_caffeine" as const,
      title: "Late Caffeine",
      desc: "Coffee at 4pm may have delayed sleep onset by 45 minutes. Consider limiting afternoon caffeine.",
      time: "Yesterday",
    },
    {
      id: "3",
      type: "weekend_jetlag" as const,
      title: "Weekend Jetlag",
      desc: "Your wake time shifted 2 hours this weekend. Try to gradually align with weekday schedule.",
      time: "Sunday",
    },
  ],
};

/**
 * SETTINGS SCREEN MOCK DATA
 */
export const MOCK_SETTINGS = {
  profile: {
    name: "John",
    status: "Calibrating...",
    initials: "J",
  },
  rhythm: {
    targetBedtime: "23:00",
    targetWakeUp: "7:00",
  },
  preferences: {
    notifications: true,
    haptics: true,
  },
  dataSource: {
    healthKit: true,
  },
};

/**
 * BREATHE SCREEN MOCK DATA
 */
export const MOCK_BREATHE = {
  technique: {
    name: "Resonance",
    pattern: "4-7-8 Calm",
  },
  phaseDurations: {
    inhale: 4,
    hold: 7,
    exhale: 8,
  },
};

/**
 * Time Period Type
 */
export type TimePeriod = "weekly" | "monthly";
