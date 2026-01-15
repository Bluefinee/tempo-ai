/**
 * Alert 生成サービス
 * @see docs/specs/metrics_spec.md Section 4
 */

import { ALERT_THRESHOLDS } from "../../constants/alertConstants";
import type { Alert, AlertPriority } from "../models/insight";
import type { ActivityMetrics, HrvMetrics } from "./tempoScoreCalculator";

// ========================================
// Types
// ========================================

interface AlertInput {
	hrv: HrvMetrics | null;
	sleep: {
		durationMinutes: number;
		bedtime: Date;
		targetBedtime: Date;
	} | null;
	activity: ActivityMetrics | null;
	rhythmData: {
		weekendWakeShiftMinutes: number;
	} | null;
}

// ========================================
// Alert Generation
// ========================================

const generateId = (): string => {
	return `alert_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
};

export const generateAlerts = (input: AlertInput): readonly Alert[] => {
	const alerts: Alert[] = [];
	const now = new Date();

	// HRV低下
	if (input.hrv && input.hrv.baseline30d > 0) {
		if (
			input.hrv.current <
			input.hrv.baseline30d * ALERT_THRESHOLDS.hrv.lowRatio
		) {
			alerts.push({
				id: generateId(),
				type: "recovery_needed",
				icon: "⚠️",
				title: "Recovery Needed",
				message: "Your HRV is lower than usual. Consider taking it easy today.",
				timestamp: now,
				priority: "high",
			});
		}

		// HRV回復
		if (
			input.hrv.current >
			input.hrv.baseline30d * ALERT_THRESHOLDS.hrv.recoveredRatio
		) {
			alerts.push({
				id: generateId(),
				type: "recovery_complete",
				icon: "✓",
				title: "Recovery Complete",
				message: "Your recovery looks great. You're ready for challenges.",
				timestamp: now,
				priority: "low",
			});
		}
	}

	// 睡眠不足
	if (
		input.sleep &&
		input.sleep.durationMinutes < ALERT_THRESHOLDS.sleep.deficitMinutes
	) {
		const hours = Math.floor(input.sleep.durationMinutes / 60);
		const mins = input.sleep.durationMinutes % 60;
		alerts.push({
			id: generateId(),
			type: "sleep_deficit",
			icon: "🌙",
			title: "Sleep Deficit",
			message: `Only ${hours}h ${mins}m of sleep. Try to rest earlier tonight.`,
			timestamp: now,
			priority: "high",
		});
	}

	// 遅い就寝
	if (input.sleep) {
		const bedtimeDelay =
			(input.sleep.bedtime.getTime() - input.sleep.targetBedtime.getTime()) /
			(1000 * 60);
		if (bedtimeDelay > ALERT_THRESHOLDS.sleep.lateBedtimeDelayMinutes) {
			alerts.push({
				id: generateId(),
				type: "late_bedtime",
				icon: "⏰",
				title: "Late Bedtime",
				message:
					"You went to bed later than your target. Try to wind down earlier.",
				timestamp: now,
				priority: "medium",
			});
		}
	}

	// 週末時差ボケ
	if (
		input.rhythmData &&
		input.rhythmData.weekendWakeShiftMinutes >
			ALERT_THRESHOLDS.rhythm.weekendJetlagMinutes
	) {
		alerts.push({
			id: generateId(),
			type: "weekend_jetlag",
			icon: "📅",
			title: "Weekend Jetlag",
			message:
				"Weekend sleep schedule shift detected. This may affect Monday energy.",
			timestamp: now,
			priority: "medium",
		});
	}

	// 活動量不足
	if (
		input.activity &&
		input.activity.steps < ALERT_THRESHOLDS.activity.lowSteps
	) {
		alerts.push({
			id: generateId(),
			type: "low_activity",
			icon: "🚶",
			title: "Low Activity",
			message:
				"Low activity yesterday. A short walk today can help your rhythm.",
			timestamp: now,
			priority: "low",
		});
	}

	// 優先度でソート
	const priorityOrder: Record<AlertPriority, number> = {
		high: 0,
		medium: 1,
		low: 2,
	};

	return alerts.sort(
		(a, b) => priorityOrder[a.priority] - priorityOrder[b.priority],
	);
};
