/**
 * HealthSummaryCard - Health Summaryセクションの個別カード
 */

import React from "react";
import { View, Text, Pressable, StyleSheet } from "react-native";
import { useRouter } from "expo-router";
import { LucideIcon } from "lucide-react-native";
import Svg, { Polyline, Circle } from "react-native-svg";
import { colors, FontFamily } from "../../theme";

export type HealthCard = {
  id: string;
  label: string;
  value: string;
  unit: string;
  Icon: LucideIcon;
  chartData: number[];
  lineColor: string;
  colorIcon: string;
};

interface HealthSummaryCardProps {
  card: HealthCard;
}

export const HealthSummaryCard = ({
  card,
}: HealthSummaryCardProps): React.ReactElement => {
  const router = useRouter();
  const { Icon, chartData, lineColor } = card;

  const min = Math.min(...chartData);
  const max = Math.max(...chartData);
  const range = max - min || 1;
  const points = chartData
    .map((val, i) => {
      const x = (i / (chartData.length - 1)) * 100;
      const y = 100 - ((val - min) / range) * 80 - 10;
      return `${x},${y}`;
    })
    .join(" ");
  const lastY =
    100 - ((chartData[chartData.length - 1] - min) / range) * 80 - 10;

  return (
    <View style={styles.cardContainer}>
      <Pressable
        onPress={() => router.push("/health-detail")}
        style={({ pressed }) => [styles.pressable, pressed && styles.pressed]}
      >
        {/* Header: Icon + Label */}
        <View style={styles.header}>
          <View
            style={[
              styles.iconWrapper,
              { backgroundColor: `${card.colorIcon}15` },
            ]}
          >
            <Icon size={12} color={card.colorIcon} strokeWidth={2.5} />
          </View>
          <Text style={styles.labelText}>{card.label}</Text>
        </View>

        {/* Value + Unit */}
        <View style={styles.valueContainer}>
          <Text style={styles.valueText}>{card.value}</Text>
          <Text style={styles.unitText}>{card.unit}</Text>
        </View>

        {/* Mini Line Chart */}
        <View style={styles.chartContainer}>
          <Svg width="100%" height="100%" viewBox="0 0 100 100">
            <Polyline
              points={points}
              fill="none"
              stroke={lineColor}
              strokeWidth={3}
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <Circle cx={100} cy={lastY} r={4} fill={lineColor} />
          </Svg>
        </View>
      </Pressable>
    </View>
  );
};

const styles = StyleSheet.create({
  cardContainer: {
    width: 140,
    aspectRatio: 1,
    backgroundColor: colors.white,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: colors.stone[100],
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 3,
    overflow: "hidden",
    padding: 16,
  },
  pressable: {},
  pressed: {
    opacity: 0.7,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
  },
  iconWrapper: {
    width: 24,
    height: 24,
    borderRadius: 12,
    justifyContent: "center",
    alignItems: "center",
  },
  labelText: {
    fontSize: 11,
    fontWeight: "700",
    color: colors.stone[400],
    letterSpacing: 0.5,
  },
  valueContainer: {
    marginTop: 12,
  },
  valueText: {
    fontSize: 24,
    fontWeight: "700",
    color: colors.stone[900],
    fontFamily: FontFamily.serif,
  },
  unitText: {
    fontSize: 11,
    fontWeight: "500",
    color: colors.stone[400],
    marginTop: 2,
  },
  chartContainer: {
    marginTop: 8,
    height: 32,
  },
});
