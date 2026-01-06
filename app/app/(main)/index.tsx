import React, { useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { useRouter } from 'expo-router';
import { ChevronRight, Cloud, Activity, ArrowDown } from 'lucide-react-native';
import { format } from 'date-fns';
import { ja } from 'date-fns/locale';
import { Colors, Spacing, Typography, BorderRadius } from '../../src/theme';
import { Card, ScoreGauge, ProgressBar } from '../../src/components';
import { MOCK_SCORES, MOCK_QUICK_ACTIONS } from '../../src/constants/mockData';
import { CALIBRATION_PERIOD_DAYS } from '../../src/domain/models';
import {
  useUserStore,
  selectIsCalibrating,
  useHealthStore,
  useInsightStore,
  selectCurrentGenerationMessage,
} from '../../src/stores';

export default function HomeScreen() {
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
    generateDailyInsight(nickname);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const today = new Date();
  const dateString = format(today, 'M月d日（E）', { locale: ja });

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <View>
            <Text style={styles.date}>{dateString}</Text>
            <Text style={styles.greeting}>こんにちは、{nickname}さん</Text>
          </View>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>{nickname.charAt(0)}</Text>
          </View>
        </View>

        {/* Calibration Progress (if calibrating) */}
        {isCalibrating && profile && (
          <Card style={styles.calibrationCard}>
            <View style={styles.calibrationHeader}>
              <Text style={styles.calibrationTitle}>キャリブレーション中</Text>
              <Text style={styles.calibrationDays}>
                {profile.calibrationDaysCompleted}/{CALIBRATION_PERIOD_DAYS}日
              </Text>
            </View>
            <ProgressBar
              value={(profile.calibrationDaysCompleted / CALIBRATION_PERIOD_DAYS) * 100}
              showAnimation={false}
            />
            <Text style={styles.calibrationNote}>
              あと{CALIBRATION_PERIOD_DAYS - profile.calibrationDaysCompleted}日で
              パーソナライズされたスコアが表示されます
            </Text>
          </Card>
        )}

        {/* AI Insight Card */}
        <TouchableOpacity
          onPress={() => router.push('/insight-detail')}
          activeOpacity={0.95}
        >
          <Card style={styles.insightCard}>
            {isLoading ? (
              <View style={styles.loadingContent}>
                <Activity
                  size={24}
                  color={Colors.primary[500]}
                  style={styles.loadingIcon}
                />
                <Text style={styles.loadingText}>
                  {loadingMessage}
                </Text>
              </View>
            ) : (
              <>
                <View style={styles.insightHeader}>
                  <Text style={styles.insightLabel}>今日のインサイト</Text>
                  <ChevronRight size={20} color={Colors.slate[400]} />
                </View>
                <Text style={styles.insightText} numberOfLines={3}>
                  {shortGreeting}
                </Text>
              </>
            )}
          </Card>
        </TouchableOpacity>

        {/* Scores Section */}
        <View style={styles.scoresSection}>
          <Text style={styles.sectionTitle}>今日のコンディション</Text>
          <View style={styles.scoresGrid}>
            <ScoreGauge
              label="自律神経"
              value={scores.autonomic}
              icon="💚"
              isCalibrating={isCalibrating}
            />
            <ScoreGauge
              label="睡眠"
              value={scores.sleep}
              icon="🌙"
              isCalibrating={isCalibrating}
            />
            <ScoreGauge
              label="リズム"
              value={scores.rhythm}
              icon="🎯"
              isCalibrating={isCalibrating}
            />
          </View>
        </View>

        {/* Rhythm Status */}
        {rhythmAnalysis && (
          <Card style={styles.rhythmCard}>
            <View style={styles.rhythmHeader}>
              <Text style={styles.rhythmTitle}>リズム状態</Text>
              <View
                style={[
                  styles.rhythmBadge,
                  rhythmAnalysis.isStable
                    ? styles.rhythmBadgeStable
                    : styles.rhythmBadgeUnstable,
                ]}
              >
                <Text
                  style={[
                    styles.rhythmBadgeText,
                    rhythmAnalysis.isStable
                      ? styles.rhythmBadgeTextStable
                      : styles.rhythmBadgeTextUnstable,
                  ]}
                >
                  {rhythmAnalysis.status === 'stable'
                    ? '安定'
                    : rhythmAnalysis.status === 'recovering'
                    ? '回復中'
                    : '不安定'}
                </Text>
              </View>
            </View>
            <Text style={styles.rhythmDescription}>
              {rhythmAnalysis.consecutiveStableDays}日連続で睡眠リズムが安定しています
            </Text>
          </Card>
        )}

        {/* Weather Card */}
        {weather && (
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
                    <Text style={styles.weatherDetailText}>
                      {weather.pressure}hPa
                    </Text>
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
                <Text style={styles.weatherAlertText}>
                  ⚠️ 午後から気圧が下がる予報です
                </Text>
              </View>
            )}
          </Card>
        )}

        {/* Quick Actions */}
        <View style={styles.actionsSection}>
          <Text style={styles.sectionTitle}>おすすめのアクション</Text>
          <View style={styles.actionsGrid}>
            {MOCK_QUICK_ACTIONS.map((action) => (
              <Card key={action.id} style={styles.actionCard}>
                <Text style={styles.actionIcon}>
                  {action.type === 'activity' ? '👟' : '🌬️'}
                </Text>
                <Text style={styles.actionText}>{action.text}</Text>
              </Card>
            ))}
          </View>
        </View>
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
  calibrationCard: {
    backgroundColor: Colors.amber[50],
    marginBottom: Spacing.lg,
  },
  calibrationHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  calibrationTitle: {
    ...Typography.bodyMedium,
    color: Colors.amber[700],
  },
  calibrationDays: {
    ...Typography.caption,
    color: Colors.amber[600],
  },
  calibrationNote: {
    ...Typography.caption,
    color: Colors.amber[600],
    marginTop: Spacing.sm,
  },
  insightCard: {
    backgroundColor: Colors.primary[50],
    marginBottom: Spacing.lg,
  },
  loadingContent: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: Spacing.sm,
  },
  loadingIcon: {
    marginRight: Spacing.md,
  },
  loadingText: {
    ...Typography.body,
    color: Colors.primary[600],
  },
  insightHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  insightLabel: {
    ...Typography.caption,
    color: Colors.primary[600],
  },
  insightText: {
    ...Typography.body,
    color: Colors.slate[700],
    lineHeight: 24,
  },
  scoresSection: {
    marginBottom: Spacing.lg,
  },
  sectionTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[700],
    marginBottom: Spacing.md,
  },
  scoresGrid: {
    flexDirection: 'row',
    gap: Spacing.sm,
  },
  rhythmCard: {
    marginBottom: Spacing.lg,
  },
  rhythmHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  rhythmTitle: {
    ...Typography.bodyMedium,
    color: Colors.slate[700],
  },
  rhythmBadge: {
    paddingVertical: Spacing.xxs,
    paddingHorizontal: Spacing.sm,
    borderRadius: BorderRadius.full,
  },
  rhythmBadgeStable: {
    backgroundColor: Colors.primary[100],
  },
  rhythmBadgeUnstable: {
    backgroundColor: Colors.amber[100],
  },
  rhythmBadgeText: {
    ...Typography.captionSmall,
  },
  rhythmBadgeTextStable: {
    color: Colors.primary[600],
  },
  rhythmBadgeTextUnstable: {
    color: Colors.amber[600],
  },
  rhythmDescription: {
    ...Typography.bodySmall,
    color: Colors.slate[500],
  },
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
  actionsSection: {
    marginBottom: Spacing.lg,
  },
  actionsGrid: {
    gap: Spacing.sm,
  },
  actionCard: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  actionIcon: {
    fontSize: 24,
    marginRight: Spacing.md,
  },
  actionText: {
    ...Typography.body,
    color: Colors.slate[700],
    flex: 1,
  },
});
