/**
 * MetricGridCard - Today画面のスコアカード（2x2グリッド用）
 */

import React from "react";
import { View, Text, Pressable } from "react-native";
import { useRouter } from "expo-router";
import { ChevronRight } from "lucide-react-native";
import { colors, FontFamily } from "../../theme";

export type MetricCard = {
  id: string;
  title: string;
  value: string;
  colorText: string;
  colorAccent: string;
  chartData: number[];
  route: "/recovery-detail" | "/sleep-detail" | "/rhythm-detail" | "/energy-detail";
};

interface MetricGridCardProps {
  metric: MetricCard;
}

export const MetricGridCard = ({ metric }: MetricGridCardProps): React.ReactElement => {
  const router = useRouter();

  return (
    <Pressable
      key={metric.id}
      onPress={() => router.push(metric.route)}
      className="bg-white p-5 rounded-3xl border border-stone-100"
      style={({ pressed }) => [
        {
          aspectRatio: 1,
          justifyContent: "space-between",
          shadowColor: "#000",
          shadowOffset: { width: 0, height: 8 },
          shadowOpacity: 0.08,
          shadowRadius: 16,
          elevation: 8,
        },
        pressed && { transform: [{ scale: 0.98 }] },
      ]}
    >
      {/* Header */}
      <View className="flex-row justify-between items-start">
        <Text className="text-sm font-bold text-stone-400">{metric.title}</Text>
        <ChevronRight size={16} color={colors.stone[300]} />
      </View>

      {/* Value */}
      <Text
        className="text-3xl font-bold tracking-tight"
        style={{ color: metric.colorText, fontFamily: FontFamily.serif }}
      >
        {metric.value}
      </Text>

      {/* Mini Bar Chart */}
      <View
        className="flex-row items-end justify-between"
        style={{ gap: 4, height: 48 }}
      >
        {metric.chartData.map((val, i) => (
          <View
            key={i}
            className="flex-1 rounded-sm"
            style={{
              height: `${val}%`,
              backgroundColor: metric.colorAccent,
              opacity: i === metric.chartData.length - 1 ? 1 : 0.3,
            }}
          />
        ))}
      </View>
    </Pressable>
  );
};

