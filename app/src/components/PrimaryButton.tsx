/**
 * PrimaryButton - メインアクションボタン
 * sozai/new のスタイルを React Native で再現
 */

import React from "react";
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ViewStyle,
  StyleProp,
  ActivityIndicator,
  View,
} from "react-native";
import { ChevronRight, Check } from "lucide-react-native";
import { Colors, FontFamily } from "../theme";
import type { ReactElement } from "react";

interface PrimaryButtonProps {
  onPress: () => void;
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  disabled?: boolean;
  loading?: boolean;
  showIcon?: boolean;
  isLast?: boolean;
}

export const PrimaryButton = ({
  onPress,
  children,
  style,
  disabled = false,
  loading = false,
  showIcon = true,
  isLast = false,
}: PrimaryButtonProps): ReactElement => {
  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.85}
      style={[styles.button, (disabled || loading) && styles.disabled, style]}
    >
      {loading ? (
        <ActivityIndicator color={Colors.white} />
      ) : (
        <View style={styles.content}>
          <Text style={styles.text}>{children}</Text>
          {showIcon &&
            (isLast ? (
              <Check size={20} color={Colors.white} style={styles.icon} />
            ) : (
              <ChevronRight
                size={20}
                color={Colors.white}
                style={styles.icon}
              />
            ))}
        </View>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    backgroundColor: Colors.indigo[900], // bg-indigo-900 (matching sozai)
    borderRadius: 999, // rounded-full
    paddingVertical: 16, // py-4
    paddingLeft: 32, // pl-8
    paddingRight: 24, // pr-6
    alignItems: "center",
    justifyContent: "center",
    // shadow-xl shadow-indigo-900/20
    shadowColor: Colors.indigo[900],
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.2,
    shadowRadius: 16,
    elevation: 8,
  },
  disabled: {
    opacity: 0.5,
  },
  content: {
    flexDirection: "row",
    alignItems: "center",
  },
  text: {
    fontFamily: FontFamily.semibold,
    fontSize: 16,
    fontWeight: "600",
    color: Colors.white,
  },
  icon: {
    marginLeft: 8, // ml-2
  },
});
