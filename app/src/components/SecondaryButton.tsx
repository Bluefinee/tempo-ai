import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ViewStyle,
  StyleProp,
  ActivityIndicator,
} from 'react-native';
import { Colors, BorderRadius, Spacing, Typography } from '../theme';
import type { ReactElement } from 'react';

interface SecondaryButtonProps {
  onPress: () => void;
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  disabled?: boolean;
  loading?: boolean;
}

export const SecondaryButton = ({
  onPress,
  children,
  style,
  disabled = false,
  loading = false,
}: SecondaryButtonProps): ReactElement => {
  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.9}
      style={[
        styles.button,
        (disabled || loading) && styles.disabled,
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator color={Colors.stone[600]} />
      ) : (
        <Text style={styles.text}>{children}</Text>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.full,
    paddingVertical: Spacing.lg,
    paddingHorizontal: Spacing.xxl,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: Colors.stone[100],
    shadowColor: Colors.stone[900],
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  disabled: {
    opacity: 0.5,
  },
  text: {
    ...Typography.bodyMedium,
    color: Colors.stone[600],
  },
});
