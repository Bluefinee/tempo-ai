/**
 * Card - 共通カードコンポーネント
 * 浮遊感のあるカードデザインを提供
 */

import React from "react";
import {
  View,
  StyleSheet,
  TouchableOpacity,
  ViewStyle,
  StyleProp,
} from "react-native";
import { Colors, Shadows } from "../theme";

export interface CardProps {
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  onPress?: () => void;
  noPadding?: boolean;
}

export const Card = ({
  children,
  style,
  onPress,
  noPadding,
}: CardProps): React.ReactElement => {
  const cardStyle = [styles.card, noPadding && styles.noPadding, style];

  if (onPress) {
    return (
      <TouchableOpacity
        onPress={onPress}
        activeOpacity={0.95}
        style={cardStyle}
        accessibilityRole="button"
      >
        {children}
      </TouchableOpacity>
    );
  }

  return <View style={cardStyle}>{children}</View>;
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: Colors.white,
    borderRadius: 16,
    padding: 16,
    ...Shadows.card,
  },
  noPadding: {
    padding: 0,
  },
});
