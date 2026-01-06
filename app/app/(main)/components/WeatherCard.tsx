import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Cloud, ArrowDown } from 'lucide-react-native';
import { Colors, Spacing, Typography } from '../../../src/theme';
import { Card } from '../../../src/components';
import type { SimpleWeatherData } from '../../../src/domain/models';
import type { JSX } from 'react';

interface WeatherCardProps {
  weather: SimpleWeatherData;
}

export const WeatherCard = ({ weather }: WeatherCardProps): JSX.Element => {
  return (
    <Card style={styles.weatherCard}>
      <View style={styles.weatherHeader}>
        <Cloud size={20} color={Colors.slate[500]} />
        <Text style={styles.weatherLocation}>{weather.location}</Text>
      </View>
      <View style={styles.weatherContent}>
        <View style={styles.weatherMain}>
          <Text style={styles.weatherTemp}>{weather.temp}°</Text>
          <Text style={styles.weatherCondition}>{weather.condition}</Text>
        </View>
        <View style={styles.weatherDetails}>
          <View style={styles.weatherDetail}>
            <Text style={styles.weatherDetailLabel}>気圧</Text>
            <View style={styles.weatherDetailValue}>
              <Text style={styles.weatherDetailText}>{weather.pressure}hPa</Text>
              {weather.pressureTrend === 'down' && (
                <ArrowDown size={14} color={Colors.amber[500]} />
              )}
            </View>
          </View>
          <View style={styles.weatherDetail}>
            <Text style={styles.weatherDetailLabel}>UV</Text>
            <Text style={styles.weatherDetailText}>{weather.uv}</Text>
          </View>
        </View>
      </View>
      {weather.pressureTrend === 'down' && (
        <View style={styles.weatherAlert}>
          <Text style={styles.weatherAlertText}>⚠️ 午後から気圧が下がる予報です</Text>
        </View>
      )}
    </Card>
  );
};

const styles = StyleSheet.create({
  weatherCard: {
    marginBottom: Spacing.lg,
  },
  weatherHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.md,
  },
  weatherLocation: {
    ...Typography.caption,
    color: Colors.slate[500],
    marginLeft: Spacing.xs,
  },
  weatherContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  weatherMain: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: Spacing.sm,
  },
  weatherTemp: {
    ...Typography.scoreMedium,
    color: Colors.slate[800],
  },
  weatherCondition: {
    ...Typography.body,
    color: Colors.slate[500],
  },
  weatherDetails: {
    flexDirection: 'row',
    gap: Spacing.lg,
  },
  weatherDetail: {
    alignItems: 'flex-end',
  },
  weatherDetailLabel: {
    ...Typography.captionSmall,
    color: Colors.slate[400],
    marginBottom: 2,
  },
  weatherDetailValue: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 2,
  },
  weatherDetailText: {
    ...Typography.bodySmall,
    color: Colors.slate[600],
  },
  weatherAlert: {
    marginTop: Spacing.md,
    paddingTop: Spacing.md,
    borderTopWidth: 1,
    borderTopColor: Colors.slate[100],
  },
  weatherAlertText: {
    ...Typography.bodySmall,
    color: Colors.amber[600],
  },
});

