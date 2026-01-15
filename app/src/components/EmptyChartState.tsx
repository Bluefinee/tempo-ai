/**
 * EmptyChartState - データ不足時のチャートプレースホルダー
 * チャートにデータがない、または十分なデータがない場合に表示
 */

import { Ionicons } from "@expo/vector-icons";
import type React from "react";
import { Text, View } from "react-native";
import { t } from "../i18n";
import { colors } from "../theme";

interface EmptyChartStateProps {
	/** 現在の蓄積日数 */
	currentDays: number;
	/** 表示に必要な日数 */
	requiredDays: number;
	/** コンポーネントの高さ */
	height?: number;
	/** アイコンの色 */
	colorHex?: string;
}

export const EmptyChartState = ({
	currentDays,
	requiredDays,
	height = 200,
	colorHex = colors.stone[400],
}: EmptyChartStateProps): React.ReactElement => {
	const hasNoData = currentDays === 0;

	return (
		<View
			className="items-center justify-center bg-stone-50 rounded-2xl"
			style={{ height }}
		>
			<View className="items-center">
				<View
					className="w-12 h-12 rounded-full items-center justify-center mb-3"
					style={{ backgroundColor: `${colorHex}15` }}
				>
					<Ionicons
						name={hasNoData ? "bar-chart-outline" : "hourglass-outline"}
						size={24}
						color={colorHex}
					/>
				</View>

				<Text className="text-stone-700 text-base font-semibold mb-1">
					{hasNoData ? t("chart.noData") : t("chart.insufficientData")}
				</Text>

				<Text className="text-stone-500 text-sm text-center px-4">
					{hasNoData
						? t("chart.noDataDescription", { days: requiredDays })
						: t("chart.insufficientDataDescription", {
								current: currentDays,
								required: requiredDays,
							})}
				</Text>
			</View>
		</View>
	);
};
