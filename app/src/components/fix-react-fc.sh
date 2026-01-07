#!/bin/bash

# HealthMetricDetail.tsx
perl -i -pe 's/^export const HealthMetricDetail = \(\{$/export const HealthMetricDetail = ({/' HealthMetricDetail.tsx
perl -i -0777 -pe 's/(export const HealthMetricDetail = \(\{[^}]+}\))/\1: HealthMetricDetailProps/' HealthMetricDetail.tsx

# InputField.tsx  
perl -i -0777 -pe 's/(export const InputField = \(\{[^}]+}\))/\1: InputFieldProps/' InputField.tsx

# MetricGridCard.tsx
perl -i -0777 -pe 's/(export const MetricGridCard = \(\{[^}]+}\))/\1: MetricGridCardProps/' MetricGridCard.tsx

# MiniBarChart.tsx
perl -i -0777 -pe 's/(export const MiniBarChart = \(\{[^}]+}\))/\1: MiniBarChartProps/' MiniBarChart.tsx

# RhythmInteractiveChart.tsx
perl -i -0777 -pe 's/(export const RhythmInteractiveChart = \(\{[^}]+}\))/\1: RhythmInteractiveChartProps/' RhythmInteractiveChart.tsx

# ScoreGauge.tsx
perl -i -0777 -pe 's/(export const ScoreGauge = \(\{[^}]+}\))/\1: ScoreGaugeProps/' ScoreGauge.tsx

# SecondaryButton.tsx
perl -i -0777 -pe 's/(export const SecondaryButton = \(\{[^}]+}\))/\1: SecondaryButtonProps/' SecondaryButton.tsx

# SleepStagesBar.tsx
perl -i -0777 -pe 's/(export const SleepStagesBar = \(\{ stages }\))/\1: SleepStagesBarProps/' SleepStagesBar.tsx

# SunInfoCard.tsx
perl -i -0777 -pe 's/(export const SunInfoCard = \(\{[^}]+}\))/\1: SunInfoCardProps/' SunInfoCard.tsx

# TimeframeSelector.tsx
perl -i -0777 -pe 's/(export const TimeframeSelector = \(\{[^}]+}\))/\1: TimeframeSelectorProps/' TimeframeSelector.tsx

# WindowCard.tsx
perl -i -0777 -pe 's/(export const WindowCard = \(\{[^}]+}\))/\1: WindowCardProps/' WindowCard.tsx

echo "Fixed all components"
