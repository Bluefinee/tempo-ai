import React, { useEffect } from 'react';
import { StyleSheet, SafeAreaView, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { Colors, Spacing } from '../../src/theme';
import { MOCK_SCORES, MOCK_QUICK_ACTIONS } from '../../src/constants/mockData';
import {
  useUserStore,
  selectIsCalibrating,
  useHealthStore,
  useInsightStore,
  selectCurrentGenerationMessage,
} from '../../src/stores';
import {
  HomeHeader,
  CalibrationProgress,
  InsightCard,
  ScoresSection,
  RhythmStatusCard,
  WeatherCard,
  QuickActionsSection,
} from './components';
import type { JSX } from 'react';

export default function HomeScreen(): JSX.Element {
  const router = useRouter();

  // User store
  const profile = useUserStore((state) => state.profile);
  const isCalibrating = useUserStore(selectIsCalibrating);

  // Health store
  const weather = useHealthStore((state) => state.weather);
  const rhythmAnalysis = useHealthStore((state) => state.rhythmAnalysis);
  const setMockData = useHealthStore((state) => state.setMockData);

  // Insight store
  const isLoading = useInsightStore((state) => state.isGeneratingInsight);
  const shortGreeting = useInsightStore((state) => state.shortGreeting);
  const loadingMessage = useInsightStore(selectCurrentGenerationMessage);
  const generateDailyInsight = useInsightStore((state) => state.generateDailyInsight);

  // Use mock scores for now
  const scores = MOCK_SCORES;
  const nickname = profile?.nickname || 'ユーザー';

  useEffect(() => {
    // Initialize mock data on mount
    setMockData();

    // Generate insight with labor illusion
    generateDailyInsight();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <HomeHeader nickname={nickname} />

        {isCalibrating && profile && <CalibrationProgress profile={profile} />}

        <InsightCard
          isLoading={isLoading}
          loadingMessage={loadingMessage}
          shortGreeting={shortGreeting}
          onPress={() => router.push('/insight-detail')}
        />

        <ScoresSection scores={scores} isCalibrating={isCalibrating} />

        {rhythmAnalysis && <RhythmStatusCard rhythmAnalysis={rhythmAnalysis} />}

        {weather && <WeatherCard weather={weather} />}

        <QuickActionsSection actions={MOCK_QUICK_ACTIONS} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.slate[50],
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: Spacing.lg,
    paddingTop: Spacing.lg,
    paddingBottom: Spacing.huge,
  },
});
