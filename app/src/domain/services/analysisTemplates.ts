/**
 * Analysis Templates
 *
 * Template-based analysis text generation for detail screens.
 * Selects appropriate text based on score level and trend direction.
 */

import type {
	EnergyDetailData,
	RecoveryDetailData,
	RhythmDetailData,
	SleepDetailData,
	TrendDirection,
} from "../models";

// =============================================================================
// Helper Types and Functions
// =============================================================================

type ScoreLevel = "excellent" | "good" | "fair" | "low";

const getScoreLevel = (score: number): ScoreLevel => {
	if (score >= 85) return "excellent";
	if (score >= 70) return "good";
	if (score >= 50) return "fair";
	return "low";
};

type TemplateKey = `${ScoreLevel}_${TrendDirection}`;

const getTemplateKey = (score: number, trend: TrendDirection): TemplateKey => {
	return `${getScoreLevel(score)}_${trend}`;
};

// =============================================================================
// Recovery Analysis Templates
// =============================================================================

const RECOVERY_TEMPLATES: Record<TemplateKey, string> = {
	// Excellent
	excellent_improving:
		"Your recovery is excellent and trending upward. HRV is {hrvChange}% above baseline, indicating strong autonomic balance. Great time for high-intensity activities.",
	excellent_stable:
		"Your recovery remains excellent with stable HRV patterns. Your body is well-adapted to your current lifestyle. Consider maintaining this balance.",
	excellent_declining:
		"Despite excellent recovery, your HRV shows a slight decline. Monitor rest quality and stress levels to maintain optimal performance.",

	// Good
	good_improving:
		"Your recovery is good and improving. HRV is trending {hrvChange}% higher than recent average. Continue your current routine.",
	good_stable:
		"Recovery looks solid with consistent HRV readings. Your autonomic nervous system is balanced. A moderate workout would be well-tolerated today.",
	good_declining:
		"Recovery is still good but showing a downward trend. Consider lighter activities today and focus on quality sleep tonight.",

	// Fair
	fair_improving:
		"Your recovery is fair but trending upward. Signs of improvement in HRV suggest your body is adapting. Stick with moderate activities.",
	fair_stable:
		"Recovery is at a moderate level. Consider balancing activity with rest. Light exercise and stress management recommended.",
	fair_declining:
		"Recovery is fair and declining. Your body may need additional rest. Prioritize sleep quality and consider reducing training intensity.",

	// Low
	low_improving:
		"While recovery is low, your HRV is showing improvement. This is a positive sign. Focus on gentle activities and rest.",
	low_stable:
		"Recovery remains low. Your autonomic system needs support. Prioritize rest, hydration, and stress reduction today.",
	low_declining:
		"Recovery is low and declining. This may indicate accumulated fatigue or stress. Rest is strongly recommended. Consider consulting a health professional if this persists.",
};

export const getRecoveryAnalysis = (data: RecoveryDetailData): string => {
	const key = getTemplateKey(data.score, data.hrv.trend);
	let template = RECOVERY_TEMPLATES[key];

	// Replace placeholders
	template = template.replace(
		"{hrvChange}",
		data.hrv.changePercent > 0
			? `+${data.hrv.changePercent}`
			: `${data.hrv.changePercent}`,
	);

	return template;
};

// =============================================================================
// Sleep Analysis Templates
// =============================================================================

const SLEEP_TEMPLATES: Record<TemplateKey, string> = {
	// Excellent
	excellent_improving:
		"Outstanding sleep quality! You got {hours}h {minutes}m of sleep with excellent deep and REM ratios. Your sleep is trending better than average.",
	excellent_stable:
		"Your sleep quality remains excellent. Deep sleep at {deepRatio}% and REM at {remRatio}% are within optimal ranges. Keep up your sleep routine.",
	excellent_declining:
		"Sleep quality is excellent but showing slight decline. Consider maintaining consistent sleep times to preserve this quality.",

	// Good
	good_improving:
		"Good sleep with improvement trend. {hours}h {minutes}m total sleep. Deep sleep ratio is healthy. Room for optimization in timing consistency.",
	good_stable:
		"Sleep is consistently good. You achieved {hours}h {minutes}m with balanced sleep stages. Small adjustments could push this to excellent.",
	good_declining:
		"Sleep quality is good but declining. Your {timingIssue} may be affecting quality. Focus on consistent bedtimes.",

	// Fair
	fair_improving:
		"Sleep is fair but improving. You slept {hours}h {minutes}m. Consider extending sleep duration toward your {targetHours}h {targetMinutes}m goal.",
	fair_stable:
		"Sleep quality is moderate. {durationIssue} Deep sleep at {deepRatio}% could be improved with earlier bedtimes.",
	fair_declining:
		"Sleep is fair and declining. Both duration and quality need attention. Try winding down {windDownMinutes} minutes earlier.",

	// Low
	low_improving:
		"While sleep quality is low, improvements are showing. Keep building on this trend with consistent sleep-wake times.",
	low_stable:
		"Sleep quality needs attention. Only {hours}h {minutes}m of total sleep with {deepRatio}% deep sleep. Prioritize sleep hygiene.",
	low_declining:
		"Sleep quality is low and declining. This affects all aspects of health. Consider addressing sleep environment and pre-sleep routine urgently.",
};

export const getSleepAnalysis = (data: SleepDetailData): string => {
	// Determine trend from duration and quality
	const trend: TrendDirection =
		data.duration.percentage >= 100 && data.quality.percentage >= 80
			? "improving"
			: data.duration.percentage < 90 || data.quality.percentage < 70
				? "declining"
				: "stable";

	const key = getTemplateKey(data.score, trend);
	let template = SLEEP_TEMPLATES[key];

	// Replace placeholders
	template = template
		.replace("{hours}", data.duration.hours.toString())
		.replace("{minutes}", (data.duration.minutes % 60).toString())
		.replace("{deepRatio}", data.quality.deepRatio.toString())
		.replace("{remRatio}", data.quality.remRatio.toString())
		.replace("{targetHours}", data.duration.target.hours.toString())
		.replace("{targetMinutes}", data.duration.target.minutes.toString())
		.replace(
			"{durationIssue}",
			data.duration.percentage < 100
				? `Sleep duration is ${100 - data.duration.percentage}% below target.`
				: "",
		)
		.replace(
			"{timingIssue}",
			Math.abs(data.timing.bedtime.diffMinutes) > 30
				? "bedtime inconsistency"
				: "wake time variance",
		)
		.replace("{windDownMinutes}", "30");

	return template;
};

// =============================================================================
// Rhythm Analysis Templates
// =============================================================================

const RHYTHM_TEMPLATES: Record<TemplateKey, string> = {
	// Excellent
	excellent_improving:
		"Your sleep-wake rhythm is excellent. Bedtime consistency ({bedtimeDeviation}) and wake consistency ({wakeDeviation}) are both outstanding. Your circadian rhythm is well-aligned.",
	excellent_stable:
		"Consistent and excellent rhythm. Your body clock is well-trained with {bedtimeDeviation} bedtime variance and {wakeDeviation} wake variance. This supports optimal recovery.",
	excellent_declining:
		"Rhythm is excellent but showing minor fluctuations. Weekend patterns may be affecting consistency. Try to maintain similar times on weekends.",

	// Good
	good_improving:
		"Good rhythm with improving consistency. Your bedtime variance of {bedtimeDeviation} is healthy. Small improvements in wake time consistency could boost this further.",
	good_stable:
		"Your rhythm is consistently good. {bedtimeDeviation} bedtime variance works well. Consider tightening wake time consistency for better energy levels.",
	good_declining:
		"Rhythm is good but showing more variance. {primaryIssue} has increased. Re-establishing consistent times will help.",

	// Fair
	fair_improving:
		"Rhythm is fair but improving. Your {betterMetric} is getting more consistent. Continue working on the other to see full benefits.",
	fair_stable:
		"Sleep rhythm shows moderate consistency. {bedtimeDeviation} bedtime variance and {wakeDeviation} wake variance suggest room for improvement.",
	fair_declining:
		"Rhythm consistency is declining. Variable sleep times affect recovery quality. Try setting alarm reminders for bedtime.",

	// Low
	low_improving:
		"While rhythm consistency is low, improvements are visible. Keep building on this momentum with consistent routines.",
	low_stable:
		"Sleep rhythm needs attention. High variance in both bedtime ({bedtimeDeviation}) and wake time ({wakeDeviation}) disrupts circadian alignment.",
	low_declining:
		"Rhythm is low and becoming more irregular. Inconsistent sleep-wake times significantly impact health. Consider strict scheduling.",
};

export const getRhythmAnalysis = (data: RhythmDetailData): string => {
	// Determine trend based on consistency values
	const avgDeviation =
		(data.consistency.bedtime.deviationMinutes +
			data.consistency.wakeTime.deviationMinutes) /
		2;
	const trend: TrendDirection =
		avgDeviation <= 15
			? "improving"
			: avgDeviation >= 45
				? "declining"
				: "stable";

	const key = getTemplateKey(data.score, trend);
	let template = RHYTHM_TEMPLATES[key];

	// Replace placeholders
	template = template
		.replace(/{bedtimeDeviation}/g, data.consistency.bedtime.deviationText)
		.replace(/{wakeDeviation}/g, data.consistency.wakeTime.deviationText)
		.replace(
			"{primaryIssue}",
			data.consistency.bedtime.deviationMinutes >
				data.consistency.wakeTime.deviationMinutes
				? "Bedtime variance"
				: "Wake time variance",
		)
		.replace(
			"{betterMetric}",
			data.consistency.bedtime.deviationMinutes <
				data.consistency.wakeTime.deviationMinutes
				? "bedtime"
				: "wake time",
		);

	return template;
};

// =============================================================================
// Energy Analysis Templates
// =============================================================================

const ENERGY_TEMPLATES: Record<TemplateKey, string> = {
	// Excellent
	excellent_improving:
		"Energy levels are excellent and improving. All contributing factors are strong. Peak focus expected around {peakStart}-{peakEnd}. Great day for demanding tasks.",
	excellent_stable:
		"Energy is consistently excellent. Recovery ({recoveryValue}%), sleep ({sleepValue}%), and weather conditions all support high performance today.",
	excellent_declining:
		"Energy is excellent but factors show decline. Monitor recovery over the next few days. Still a great day for productive work.",

	// Good
	good_improving:
		"Good energy with positive trends. Your {strongestFactor} is particularly strong. Expect natural dip around {dipStart}-{dipEnd}.",
	good_stable:
		"Energy is steadily good. Recovery at {recoveryValue}% and sleep at {sleepValue}% provide solid foundation. Plan important tasks for morning hours.",
	good_declining:
		"Energy is good but trending down. Your {weakestFactor} may need attention. Schedule lighter afternoon activities.",

	// Fair
	fair_improving:
		"Energy is fair but improving. {improvingFactor} shows positive momentum. Build on this with good rest tonight.",
	fair_stable:
		"Moderate energy levels today. Recovery and sleep are balanced. Consider lighter workload and prioritize rest.",
	fair_declining:
		"Energy is fair and declining. Multiple factors are pulling down. Focus on recovery activities today.",

	// Low
	low_improving:
		"While energy is low, positive trends suggest improvement. Gentle activities and rest will support continued recovery.",
	low_stable:
		"Energy levels are low. Contributing factors need attention. Prioritize rest and avoid demanding activities.",
	low_declining:
		"Energy is low and declining. Rest is essential. Consider rescheduling demanding tasks and focus on recovery basics.",
};

export const getEnergyAnalysis = (data: EnergyDetailData): string => {
	// Determine overall trend from factors
	const factors = data.contributingFactors;
	const improvingCount = [
		factors.recovery.trend,
		factors.sleep.trend,
		factors.activity.trend,
		factors.weather.trend,
	].filter((t) => t === "improving").length;

	const decliningCount = [
		factors.recovery.trend,
		factors.sleep.trend,
		factors.activity.trend,
		factors.weather.trend,
	].filter((t) => t === "declining").length;

	const trend: TrendDirection =
		improvingCount > decliningCount
			? "improving"
			: decliningCount > improvingCount
				? "declining"
				: "stable";

	const key = getTemplateKey(data.score, trend);
	let template = ENERGY_TEMPLATES[key];

	// Find strongest and weakest factors
	const factorValues = [
		{ name: "Recovery", value: factors.recovery.value },
		{ name: "Sleep", value: factors.sleep.value },
		{ name: "Activity", value: factors.activity.value },
		{ name: "Weather", value: factors.weather.value },
	].sort((a, b) => b.value - a.value);

	const strongest = factorValues[0].name;
	const weakest = factorValues[factorValues.length - 1].name;

	// Find improving factor
	const improvingFactorObj = [
		{ name: "Recovery", trend: factors.recovery.trend },
		{ name: "Sleep", trend: factors.sleep.trend },
		{ name: "Activity", trend: factors.activity.trend },
		{ name: "Weather", trend: factors.weather.trend },
	].find((f) => f.trend === "improving");

	const improvingFactor = improvingFactorObj?.name ?? "Recovery";

	// Replace placeholders
	template = template
		.replace("{peakStart}", data.peakFocus.start)
		.replace("{peakEnd}", data.peakFocus.end)
		.replace("{dipStart}", data.afternoonDip.start)
		.replace("{dipEnd}", data.afternoonDip.end)
		.replace("{recoveryValue}", factors.recovery.value.toString())
		.replace("{sleepValue}", factors.sleep.value.toString())
		.replace("{strongestFactor}", strongest)
		.replace("{weakestFactor}", weakest)
		.replace("{improvingFactor}", improvingFactor);

	return template;
};

// =============================================================================
// Main API - Fill Analysis for All Detail Data
// =============================================================================

export const fillRecoveryAnalysis = (
	data: RecoveryDetailData,
): RecoveryDetailData => ({
	...data,
	analysis: getRecoveryAnalysis(data),
});

export const fillSleepAnalysis = (data: SleepDetailData): SleepDetailData => ({
	...data,
	analysis: getSleepAnalysis(data),
});

export const fillRhythmAnalysis = (
	data: RhythmDetailData,
): RhythmDetailData => ({
	...data,
	analysis: getRhythmAnalysis(data),
});

export const fillEnergyAnalysis = (
	data: EnergyDetailData,
): EnergyDetailData => ({
	...data,
	analysis: getEnergyAnalysis(data),
});
