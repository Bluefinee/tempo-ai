/**
 * Insight（インサイト・アラート）ドメインモデル
 * @see docs/specs/metrics_spec.md Section 4
 */

export type AlertType =
  | 'recovery_needed'
  | 'recovery_complete'
  | 'sleep_deficit'
  | 'late_bedtime'
  | 'weekend_jetlag'
  | 'low_activity';

export type AlertPriority = 'high' | 'medium' | 'low';

export type AlertIcon = '⚠️' | '✓' | '🌙' | '⏰' | '📅' | '🚶';

export interface Alert {
  readonly id: string;
  readonly type: AlertType;
  readonly icon: AlertIcon;
  readonly title: string;
  readonly message: string;
  readonly timestamp: Date;
  readonly priority: AlertPriority;
}

export interface TopDiscovery {
  readonly title: string;
  readonly description: string;
  readonly impact?: string; // e.g., "+18% deep sleep"
}

export interface WeeklyInsight {
  readonly weeklyScores: readonly number[]; // 7日分
  readonly avgScore: number;
  readonly topDiscovery: TopDiscovery | null;
  readonly recentAlerts: readonly Alert[];
}





