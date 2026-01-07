import React from 'react';
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  TextInputProps,
} from 'react-native';
import { Colors, BorderRadius, Spacing, Typography } from '../theme';
import type { ReactElement } from 'react';

interface InputFieldProps extends Omit<TextInputProps, 'style'> {
  label: string;
  suffix?: string;
  error?: string;
}

export const InputField: React.FC<InputFieldProps> = ({
  label,
  suffix,
  error,
  ...textInputProps
}): ReactElement => {
  return (
    <View style={styles.container}>
      <Text style={styles.label}>{label}</Text>
      <View style={[styles.inputContainer, error && styles.inputError]}>
        <TextInput
          style={styles.input}
          placeholderTextColor={Colors.stone[300]}
          {...textInputProps}
        />
        {suffix && <Text style={styles.suffix}>{suffix}</Text>}
      </View>
      {error && <Text style={styles.error}>{error}</Text>}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: Spacing.xl,
  },
  label: {
    ...Typography.label,
    color: Colors.stone[500],
    marginBottom: Spacing.sm,
    marginLeft: Spacing.xs,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    borderWidth: 1,
    borderColor: Colors.stone[100],
    borderRadius: BorderRadius.xl,
    shadowColor: Colors.stone[900],
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  input: {
    flex: 1,
    ...Typography.body,
    color: Colors.stone[800],
    paddingVertical: Spacing.lg,
    paddingHorizontal: Spacing.xl,
  },
  inputError: {
    borderColor: Colors.coral[500],
  },
  suffix: {
    ...Typography.bodyMedium,
    color: Colors.stone[400],
    paddingRight: Spacing.xl,
  },
  error: {
    ...Typography.caption,
    color: Colors.coral[500],
    marginTop: Spacing.xs,
    marginLeft: Spacing.xs,
  },
});
