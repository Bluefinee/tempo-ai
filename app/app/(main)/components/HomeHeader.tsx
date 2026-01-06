import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { format } from 'date-fns';
import { ja } from 'date-fns/locale';
import { Colors, Spacing, Typography } from '../../../src/theme';
import type { JSX } from 'react';

interface HomeHeaderProps {
  nickname: string;
}

export const HomeHeader = ({ nickname }: HomeHeaderProps): JSX.Element => {
  const today = new Date();
  const dateString = format(today, 'M月d日（E）', { locale: ja });

  return (
    <View style={styles.header}>
      <View>
        <Text style={styles.date}>{dateString}</Text>
        <Text style={styles.greeting}>こんにちは、{nickname}さん</Text>
      </View>
      <View style={styles.avatar}>
        <Text style={styles.avatarText}>{nickname.charAt(0)}</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.xl,
  },
  date: {
    ...Typography.caption,
    color: Colors.slate[500],
    marginBottom: 2,
  },
  greeting: {
    ...Typography.h4,
    color: Colors.slate[800],
  },
  avatar: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: Colors.primary[100],
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    ...Typography.bodyMedium,
    color: Colors.primary[600],
  },
});

