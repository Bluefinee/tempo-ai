# Phase 6: 画面実装

## 目的

- Today画面の完全実装
- Rhythm画面の完全実装
- Breathe画面の完全実装
- Insights画面の完全実装
- Settings画面の更新

---

## 開始前に読むべきドキュメント

**必ず以下のドキュメントを全て読んでから実装を開始すること:**

| ドキュメント | パス | 確認ポイント |
|-------------|------|-------------|
| CLAUDE.md | `/CLAUDE.md` | TypeScript規約、コメントポリシー |
| React Native規約 | `/.claude/react-native-standards.md` | コンポーネント設計、スタイル定義 |
| UI/UX仕様 | `/docs/specs/ui_ux_design.md` | 各画面の構成要素、レイアウト |
| プロダクト仕様 | `/docs/specs/product_spec.md` | 機能要件 |
| メトリクス仕様 | `/docs/specs/metrics_spec.md` | スコア算出、フェーズ定義 |
| i18n設計 | `/docs/specs/i18n_design.md` | 翻訳キー命名規則 |
| Phase 3完了 | `/docs/cursor/03-phase3-components.md` | 使用するコンポーネント |
| Phase 4完了 | `/docs/cursor/04-phase4-stores.md` | 使用するStore |

---

## Task 6.1: Today画面

### `app/app/(main)/index.tsx`

```typescript
import { useCallback, useMemo, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { Colors, Spacing, Typography, Shadows } from '@/theme';
import { t } from '@/i18n';
import { WaveScore } from '@/components/WaveScore';
import { MetricCard } from '@/components/MetricCard';
import { MetricDetail } from '@/components/MetricDetail';
import { BottomSheet } from '@/components/BottomSheet';
import { useHealthStore } from '@/stores/healthStore';
import { useInsightStore } from '@/stores/insightStore';
import { formatDate } from '@/utils/format';
import type { MetricType } from '@/domain/models/health';

const getGreeting = (): string => {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return t('screen.today.greeting.morning');
  if (hour >= 12 && hour < 17) return t('screen.today.greeting.afternoon');
  if (hour >= 17 && hour < 21) return t('screen.today.greeting.evening');
  return t('screen.today.greeting.night');
};

export default function TodayScreen(): React.ReactElement {
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [selectedMetric, setSelectedMetric] = useState<MetricType | null>(null);
  const [isBottomSheetOpen, setIsBottomSheetOpen] = useState(false);

  const { tempoScore, sleepData, hrvData, activityData } = useHealthStore((state) => ({
    tempoScore: state.tempoScore,
    sleepData: state.sleepData,
    hrvData: state.hrvData,
    activityData: state.activityData,
  }));

  const { aiMessage, todayOneThing, relatedInsight, metricInsights } = useInsightStore((state) => ({
    aiMessage: state.aiMessage,
    todayOneThing: state.todayOneThing,
    relatedInsight: state.relatedInsight,
    metricInsights: state.metricInsights,
  }));

  const handleDateChange = useCallback((direction: 'prev' | 'next'): void => {
    setSelectedDate((prev) => {
      const newDate = new Date(prev);
      newDate.setDate(newDate.getDate() + (direction === 'prev' ? -1 : 1));
      return newDate;
    });
  }, []);

  const handleMetricPress = useCallback((metric: MetricType): void => {
    setSelectedMetric(metric);
    setIsBottomSheetOpen(true);
  }, []);

  const handleCloseBottomSheet = useCallback((): void => {
    setIsBottomSheetOpen(false);
    setSelectedMetric(null);
  }, []);

  const greeting = useMemo(() => getGreeting(), []);

  const oneThingIcon = useMemo((): keyof typeof Ionicons.glyphMap => {
    const iconMap: Record<string, keyof typeof Ionicons.glyphMap> = {
      walking: 'walk-outline',
      breathing: 'water-outline',
      rest: 'bed-outline',
    };
    return iconMap[todayOneThing?.icon ?? 'walking'] ?? 'flash-outline';
  }, [todayOneThing?.icon]);

  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* 日付ナビゲーション */}
        <View style={styles.dateNav}>
          <Pressable
            onPress={() => handleDateChange('prev')}
            hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
            accessibilityLabel="前の日"
          >
            <Ionicons name="chevron-back" size={24} color={Colors.stone[500]} />
          </Pressable>
          <Text style={styles.dateText}>{formatDate(selectedDate)}</Text>
          <Pressable
            onPress={() => handleDateChange('next')}
            hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
            accessibilityLabel="次の日"
          >
            <Ionicons name="chevron-forward" size={24} color={Colors.stone[500]} />
          </Pressable>
        </View>

        {/* 挨拶 */}
        <Text style={styles.greeting}>{greeting}</Text>

        {/* Tempo Score */}
        <View style={styles.scoreContainer}>
          <Text style={styles.scoreLabel}>{t('screen.today.tempoScore')}</Text>
          <WaveScore score={tempoScore ?? 0} />
        </View>

        {/* AIメッセージカード */}
        {aiMessage && (
          <View style={styles.messageCard}>
            <Text style={styles.messageTitle}>{aiMessage.title}</Text>
            <Text style={styles.messageBody}>{aiMessage.body}</Text>
            {relatedInsight && (
              <View style={styles.relatedInsight}>
                <Text style={styles.relatedLabel}>{t('screen.today.relatedInsight')}</Text>
                <Text style={styles.relatedText}>{relatedInsight.text}</Text>
              </View>
            )}
          </View>
        )}

        {/* Today's One Thing */}
        {todayOneThing && (
          <View style={styles.oneThingCard}>
            <Text style={styles.oneThingLabel}>{t('screen.today.todayOneThing')}</Text>
            <View style={styles.oneThingContent}>
              <View style={styles.oneThingIcon}>
                <Ionicons name={oneThingIcon} size={24} color={Colors.indigo[500]} />
              </View>
              <View style={styles.oneThingTextContainer}>
                <Text style={styles.oneThingText}>{todayOneThing.text}</Text>
                {todayOneThing.time && (
                  <Text style={styles.oneThingTime}>{todayOneThing.time}</Text>
                )}
              </View>
            </View>
          </View>
        )}

        {/* メトリクスグリッド */}
        <View style={styles.metricsGrid}>
          <MetricCard
            type="sleep"
            value={sleepData?.durationMinutes ?? 0}
            label={t('screen.today.metrics.sleep')}
            insight={metricInsights?.sleep}
            onPress={() => handleMetricPress('sleep')}
          />
          <MetricCard
            type="hrv"
            value={hrvData?.value ?? 0}
            label={t('screen.today.metrics.hrv')}
            insight={metricInsights?.hrv}
            onPress={() => handleMetricPress('hrv')}
          />
          <MetricCard
            type="steps"
            value={activityData?.steps ?? 0}
            label={t('screen.today.metrics.steps')}
            insight={metricInsights?.steps}
            onPress={() => handleMetricPress('steps')}
          />
        </View>
      </ScrollView>

      {/* ボトムシート */}
      <BottomSheet
        isOpen={isBottomSheetOpen}
        onClose={handleCloseBottomSheet}
      >
        {selectedMetric && (
          <MetricDetail
            type={selectedMetric}
            data={
              selectedMetric === 'sleep' ? sleepData :
              selectedMetric === 'hrv' ? hrvData :
              activityData
            }
            insight={metricInsights?.[selectedMetric]}
          />
        )}
      </BottomSheet>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.offWhite,
  },
  scrollContent: {
    paddingHorizontal: Spacing.xl,
    paddingBottom: Spacing.xxl,
  },
  dateNav: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: Spacing.md,
  },
  dateText: {
    ...Typography.bodyMedium,
    color: Colors.stone[700],
    marginHorizontal: Spacing.lg,
  },
  greeting: {
    ...Typography.heading1,
    color: Colors.stone[900],
    marginTop: Spacing.sm,
  },
  scoreContainer: {
    alignItems: 'center',
    marginTop: Spacing.xl,
  },
  scoreLabel: {
    ...Typography.label,
    color: Colors.stone[500],
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  messageCard: {
    backgroundColor: Colors.white,
    borderRadius: 16,
    padding: Spacing.lg,
    marginTop: Spacing.xl,
    ...Shadows.card,
  },
  messageTitle: {
    ...Typography.heading3,
    color: Colors.stone[900],
  },
  messageBody: {
    ...Typography.body,
    color: Colors.stone[600],
    marginTop: Spacing.sm,
    lineHeight: 24,
  },
  relatedInsight: {
    marginTop: Spacing.md,
    paddingTop: Spacing.md,
    borderTopWidth: 1,
    borderTopColor: Colors.stone[100],
  },
  relatedLabel: {
    ...Typography.label,
    color: Colors.stone[400],
  },
  relatedText: {
    ...Typography.caption,
    color: Colors.indigo[500],
    marginTop: Spacing.xs,
  },
  oneThingCard: {
    backgroundColor: Colors.indigo[50],
    borderRadius: 16,
    padding: Spacing.lg,
    marginTop: Spacing.lg,
  },
  oneThingLabel: {
    ...Typography.label,
    color: Colors.indigo[600],
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  oneThingContent: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: Spacing.md,
  },
  oneThingIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: Colors.white,
    alignItems: 'center',
    justifyContent: 'center',
  },
  oneThingTextContainer: {
    flex: 1,
    marginLeft: Spacing.md,
  },
  oneThingText: {
    ...Typography.bodyMedium,
    color: Colors.stone[900],
  },
  oneThingTime: {
    ...Typography.caption,
    color: Colors.indigo[500],
    marginTop: Spacing.xs,
  },
  metricsGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: Spacing.xl,
    gap: Spacing.sm,
  },
});
```

---

## Task 6.2: Rhythm画面

### `app/app/(main)/rhythm.tsx`

```typescript
import { useMemo } from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { Colors, Spacing, Typography, Shadows } from '@/theme';
import { t } from '@/i18n';
import { RhythmGraph } from '@/components/RhythmGraph';
import { useHealthStore } from '@/stores/healthStore';
import { useUserStore } from '@/stores/userStore';
import { formatTime } from '@/utils/format';
import type { RhythmPhase } from '@/domain/models/rhythm';

interface PhaseItemProps {
  phase: RhythmPhase;
  isNext: boolean;
}

const PhaseItem: React.FC<PhaseItemProps> = ({ phase, isNext }) => {
  const iconMap: Record<RhythmPhase['name'], keyof typeof Ionicons.glyphMap> = {
    'Wake Window': 'sunny-outline',
    'Peak Focus': 'flash-outline',
    'Afternoon Dip': 'cafe-outline',
    'Second Wind': 'trending-up-outline',
    'Wind Down': 'moon-outline',
    'Melatonin Window': 'bed-outline',
  };

  return (
    <View style={[styles.phaseItem, isNext && styles.phaseItemNext]}>
      <View style={[styles.phaseIcon, isNext && styles.phaseIconNext]}>
        <Ionicons
          name={iconMap[phase.name]}
          size={20}
          color={isNext ? Colors.white : Colors.stone[500]}
        />
      </View>
      <View style={styles.phaseInfo}>
        <Text style={[styles.phaseName, isNext && styles.phaseNameNext]}>
          {t(`screen.rhythm.phases.${phase.name.toLowerCase().replace(/\s+/g, '')}`)}
        </Text>
        <Text style={styles.phaseTime}>
          {formatTime(phase.start)} - {formatTime(phase.end)}
        </Text>
      </View>
      {isNext && (
        <View style={styles.nextBadge}>
          <Text style={styles.nextBadgeText}>NEXT</Text>
        </View>
      )}
    </View>
  );
};

export default function RhythmScreen(): React.ReactElement {
  const { circadianPhases, currentPhase, sunriseTime, sunsetTime } = useHealthStore((state) => ({
    circadianPhases: state.circadianPhases,
    currentPhase: state.currentPhase,
    sunriseTime: state.sunriseTime,
    sunsetTime: state.sunsetTime,
  }));

  const upcomingPhases = useMemo((): RhythmPhase[] => {
    if (!circadianPhases) return [];
    const now = new Date();
    return circadianPhases
      .filter((phase) => phase.end > now && !phase.isCurrent)
      .slice(0, 3);
  }, [circadianPhases]);

  const nextPhase = upcomingPhases[0] ?? null;

  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* ヘッダー */}
        <View style={styles.header}>
          <Text style={styles.title}>{t('screen.rhythm.title')}</Text>
          <Text style={styles.subtitle}>{t('screen.rhythm.subtitle')}</Text>
        </View>

        {/* エネルギーグラフ */}
        <View style={styles.graphContainer}>
          <RhythmGraph
            phases={circadianPhases ?? []}
            currentPhase={currentPhase}
          />
        </View>

        {/* 現在のフェーズ */}
        {currentPhase && (
          <View style={styles.currentPhaseCard}>
            <Text style={styles.currentPhaseLabel}>NOW</Text>
            <Text style={styles.currentPhaseName}>
              {t(`screen.rhythm.phases.${currentPhase.name.toLowerCase().replace(/\s+/g, '')}`)}
            </Text>
            <Text style={styles.currentPhaseTime}>
              until {formatTime(currentPhase.end)}
            </Text>
          </View>
        )}

        {/* UPCOMING WINDOWS */}
        <View style={styles.upcomingSection}>
          <Text style={styles.sectionTitle}>{t('screen.rhythm.upcomingWindows')}</Text>
          {upcomingPhases.map((phase, index) => (
            <PhaseItem
              key={phase.name}
              phase={phase}
              isNext={index === 0}
            />
          ))}
        </View>

        {/* Sunrise / Sunset */}
        <View style={styles.sunTimesContainer}>
          <View style={styles.sunTimeItem}>
            <Ionicons name="sunny" size={20} color={Colors.amber[500]} />
            <Text style={styles.sunTimeLabel}>{t('screen.rhythm.sunrise')}</Text>
            <Text style={styles.sunTimeValue}>{sunriseTime ?? '--:--'}</Text>
          </View>
          <View style={styles.sunTimeDivider} />
          <View style={styles.sunTimeItem}>
            <Ionicons name="moon" size={20} color={Colors.indigo[400]} />
            <Text style={styles.sunTimeLabel}>{t('screen.rhythm.sunset')}</Text>
            <Text style={styles.sunTimeValue}>{sunsetTime ?? '--:--'}</Text>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.offWhite,
  },
  scrollContent: {
    paddingBottom: Spacing.xxl,
  },
  header: {
    paddingHorizontal: Spacing.xl,
    paddingTop: Spacing.lg,
  },
  title: {
    ...Typography.heading1,
    color: Colors.stone[900],
  },
  subtitle: {
    ...Typography.caption,
    color: Colors.stone[500],
    marginTop: Spacing.xs,
  },
  graphContainer: {
    marginTop: Spacing.xl,
    paddingHorizontal: Spacing.md,
  },
  currentPhaseCard: {
    backgroundColor: Colors.indigo[500],
    marginHorizontal: Spacing.xl,
    marginTop: Spacing.lg,
    borderRadius: 16,
    padding: Spacing.lg,
    alignItems: 'center',
  },
  currentPhaseLabel: {
    ...Typography.label,
    color: Colors.indigo[200],
    letterSpacing: 2,
  },
  currentPhaseName: {
    ...Typography.heading2,
    color: Colors.white,
    marginTop: Spacing.sm,
  },
  currentPhaseTime: {
    ...Typography.caption,
    color: Colors.indigo[200],
    marginTop: Spacing.xs,
  },
  upcomingSection: {
    marginTop: Spacing.xl,
    paddingHorizontal: Spacing.xl,
  },
  sectionTitle: {
    ...Typography.label,
    color: Colors.stone[500],
    letterSpacing: 1,
    marginBottom: Spacing.md,
  },
  phaseItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    borderRadius: 12,
    padding: Spacing.md,
    marginBottom: Spacing.sm,
    ...Shadows.card,
  },
  phaseItemNext: {
    backgroundColor: Colors.indigo[50],
    borderWidth: 1,
    borderColor: Colors.indigo[200],
  },
  phaseIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Colors.stone[100],
    alignItems: 'center',
    justifyContent: 'center',
  },
  phaseIconNext: {
    backgroundColor: Colors.indigo[500],
  },
  phaseInfo: {
    flex: 1,
    marginLeft: Spacing.md,
  },
  phaseName: {
    ...Typography.bodyMedium,
    color: Colors.stone[700],
  },
  phaseNameNext: {
    color: Colors.indigo[700],
  },
  phaseTime: {
    ...Typography.caption,
    color: Colors.stone[400],
    marginTop: 2,
  },
  nextBadge: {
    backgroundColor: Colors.indigo[500],
    paddingHorizontal: Spacing.sm,
    paddingVertical: Spacing.xs,
    borderRadius: 6,
  },
  nextBadgeText: {
    ...Typography.label,
    color: Colors.white,
    fontSize: 10,
  },
  sunTimesContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: Spacing.xl,
    paddingHorizontal: Spacing.xl,
  },
  sunTimeItem: {
    alignItems: 'center',
    flex: 1,
  },
  sunTimeLabel: {
    ...Typography.caption,
    color: Colors.stone[500],
    marginTop: Spacing.xs,
  },
  sunTimeValue: {
    ...Typography.bodyMedium,
    color: Colors.stone[700],
    marginTop: 2,
  },
  sunTimeDivider: {
    width: 1,
    height: 40,
    backgroundColor: Colors.stone[200],
  },
});
```

---

## Task 6.3: Breathe画面

### `app/app/(main)/breathe.tsx`

```typescript
import { useCallback, useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Pressable, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { Colors, Spacing, Typography, Animations } from '@/theme';
import { t } from '@/i18n';
import { BreathingCircle } from '@/components/BreathingCircle';
import { useBreatheStore } from '@/stores/breatheStore';

const formatTimer = (seconds: number): string => {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
};

export default function BreatheScreen(): React.ReactElement {
  const { isActive, phase, elapsedTime, start, pause, reset } = useBreatheStore();
  const previousPhaseRef = useRef(phase);

  // フェーズ変化時のHaptic
  useEffect(() => {
    if (previousPhaseRef.current !== phase && isActive && Platform.OS === 'ios') {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    }
    previousPhaseRef.current = phase;
  }, [phase, isActive]);

  const handleToggle = useCallback((): void => {
    if (Platform.OS === 'ios') {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    }
    if (isActive) {
      pause();
    } else {
      start();
    }
  }, [isActive, start, pause]);

  const handleReset = useCallback((): void => {
    if (Platform.OS === 'ios') {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    }
    reset();
  }, [reset]);

  const getPhaseInstruction = (): string => {
    switch (phase) {
      case 'inhale':
        return t('screen.breathe.inhale');
      case 'hold':
        return t('screen.breathe.hold');
      case 'exhale':
        return t('screen.breathe.exhale');
      default:
        return t('screen.breathe.tapToStart');
    }
  };

  const getPhaseProgress = (): number => {
    // 4-7-8呼吸法のタイミング（ミリ秒）
    const phaseDurations = {
      inhale: Animations.duration.breatheIn,
      hold: Animations.duration.breatheHold,
      exhale: Animations.duration.breatheOut,
    };
    return phaseDurations[phase as keyof typeof phaseDurations] ?? 0;
  };

  return (
    <SafeAreaView style={styles.container} edges={['top', 'bottom']}>
      <View style={styles.content}>
        {/* タイトル */}
        <Text style={styles.title}>{t('screen.breathe.title')}</Text>

        {/* 呼吸円 */}
        <View style={styles.circleContainer}>
          <BreathingCircle
            isActive={isActive}
            phase={phase}
            duration={getPhaseProgress()}
          />
        </View>

        {/* 指示テキスト */}
        <Text style={styles.instruction}>{getPhaseInstruction()}</Text>

        {/* タイマー */}
        <Text style={styles.timer}>{formatTimer(elapsedTime)}</Text>

        {/* コントロールボタン */}
        <View style={styles.controls}>
          <Pressable
            style={styles.controlButton}
            onPress={handleToggle}
            accessibilityLabel={isActive ? 'Pause' : 'Start'}
            accessibilityRole="button"
          >
            <View style={styles.playPauseButton}>
              <Ionicons
                name={isActive ? 'pause' : 'play'}
                size={32}
                color={Colors.deepNavy}
              />
            </View>
          </Pressable>

          {elapsedTime > 0 && (
            <Pressable
              style={styles.resetButton}
              onPress={handleReset}
              accessibilityLabel="Reset"
              accessibilityRole="button"
            >
              <Ionicons name="refresh" size={24} color={Colors.stone[400]} />
            </Pressable>
          )}
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.deepNavy,
  },
  content: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: Spacing.xl,
  },
  title: {
    ...Typography.heading2,
    color: Colors.white,
    marginBottom: Spacing.xl,
  },
  circleContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: Spacing.xxl,
  },
  instruction: {
    ...Typography.heading3,
    color: Colors.white,
    textAlign: 'center',
    minHeight: 32,
  },
  timer: {
    ...Typography.scoreMD,
    color: Colors.stone[400],
    marginTop: Spacing.lg,
  },
  controls: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: Spacing.xxl,
    gap: Spacing.lg,
  },
  controlButton: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  playPauseButton: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: Colors.white,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: Colors.indigo[500],
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 12,
    elevation: 8,
  },
  resetButton: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: Colors.stone[600],
    alignItems: 'center',
    justifyContent: 'center',
  },
});
```

---

## Task 6.4: Insights画面

### `app/app/(main)/insights.tsx`

```typescript
import { useMemo } from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, Spacing, Typography, Shadows } from '@/theme';
import { t } from '@/i18n';
import { useInsightStore } from '@/stores/insightStore';
import { formatDate } from '@/utils/format';
import type { Alert } from '@/domain/models/insight';

const WEEKDAYS = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

interface WeeklyBarProps {
  scores: number[];
  avgScore: number;
}

const WeeklyBarChart: React.FC<WeeklyBarProps> = ({ scores, avgScore }) => {
  const today = new Date().getDay();
  const maxScore = Math.max(...scores, 100);

  return (
    <View style={barStyles.container}>
      <View style={barStyles.avgLine}>
        <Text style={barStyles.avgLabel}>{t('screen.insights.weeklyAverage')}</Text>
        <Text style={barStyles.avgValue}>{avgScore}</Text>
      </View>
      <View style={barStyles.barsContainer}>
        {scores.map((score, index) => (
          <View key={index} style={barStyles.barWrapper}>
            <View
              style={[
                barStyles.bar,
                { height: `${(score / maxScore) * 100}%` },
                index === today && barStyles.barToday,
              ]}
            />
            <Text style={[barStyles.dayLabel, index === today && barStyles.dayLabelToday]}>
              {WEEKDAYS[index]}
            </Text>
          </View>
        ))}
      </View>
    </View>
  );
};

interface AlertItemProps {
  alert: Alert;
}

const AlertItem: React.FC<AlertItemProps> = ({ alert }) => {
  const iconMap: Record<Alert['type'], keyof typeof Ionicons.glyphMap> = {
    recovery_needed: 'warning-outline',
    recovery_complete: 'checkmark-circle-outline',
    sleep_deficit: 'bed-outline',
    late_bedtime: 'time-outline',
    weekend_jetlag: 'airplane-outline',
    low_activity: 'walk-outline',
  };

  const priorityColors: Record<Alert['priority'], string> = {
    high: Colors.coral[500],
    medium: Colors.amber[500],
    low: Colors.stone[400],
  };

  return (
    <View style={alertStyles.container}>
      <View style={[alertStyles.icon, { backgroundColor: priorityColors[alert.priority] + '20' }]}>
        <Ionicons
          name={iconMap[alert.type]}
          size={20}
          color={priorityColors[alert.priority]}
        />
      </View>
      <View style={alertStyles.content}>
        <Text style={alertStyles.message}>{alert.message}</Text>
        <Text style={alertStyles.timestamp}>{formatDate(alert.timestamp)}</Text>
      </View>
    </View>
  );
};

export default function InsightsScreen(): React.ReactElement {
  const router = useRouter();
  const { weeklyScores, topDiscovery, recentAlerts } = useInsightStore((state) => ({
    weeklyScores: state.weeklyScores,
    topDiscovery: state.topDiscovery,
    recentAlerts: state.recentAlerts,
  }));

  const avgScore = useMemo((): number => {
    if (!weeklyScores || weeklyScores.length === 0) return 0;
    const sum = weeklyScores.reduce((acc, score) => acc + score, 0);
    return Math.round(sum / weeklyScores.length);
  }, [weeklyScores]);

  const handleDiscoveryPress = (): void => {
    if (topDiscovery) {
      router.push('/insight-detail');
    }
  };

  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* ヘッダー */}
        <View style={styles.header}>
          <Text style={styles.title}>{t('screen.insights.title')}</Text>
          <Text style={styles.subtitle}>{t('screen.insights.subtitle')}</Text>
        </View>

        {/* 週間バーチャート */}
        <View style={styles.chartCard}>
          <WeeklyBarChart
            scores={weeklyScores ?? [0, 0, 0, 0, 0, 0, 0]}
            avgScore={avgScore}
          />
        </View>

        {/* TOP DISCOVERY */}
        {topDiscovery && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>{t('screen.insights.topDiscovery')}</Text>
            <Pressable
              style={styles.discoveryCard}
              onPress={handleDiscoveryPress}
              accessibilityRole="button"
            >
              <View style={styles.discoveryIcon}>
                <Ionicons name="bulb" size={24} color={Colors.white} />
              </View>
              <Text style={styles.discoveryTitle}>{topDiscovery.title}</Text>
              <Text style={styles.discoveryDescription}>{topDiscovery.description}</Text>
              {topDiscovery.impact && (
                <Text style={styles.discoveryImpact}>{topDiscovery.impact}</Text>
              )}
            </Pressable>
          </View>
        )}

        {/* RECENT ALERTS */}
        {recentAlerts && recentAlerts.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>{t('screen.insights.recentAlerts')}</Text>
            {recentAlerts.map((alert) => (
              <AlertItem key={alert.id} alert={alert} />
            ))}
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.offWhite,
  },
  scrollContent: {
    paddingBottom: Spacing.xxl,
  },
  header: {
    paddingHorizontal: Spacing.xl,
    paddingTop: Spacing.lg,
  },
  title: {
    ...Typography.heading1,
    color: Colors.stone[900],
  },
  subtitle: {
    ...Typography.caption,
    color: Colors.stone[500],
    marginTop: Spacing.xs,
  },
  chartCard: {
    backgroundColor: Colors.white,
    marginHorizontal: Spacing.xl,
    marginTop: Spacing.xl,
    borderRadius: 16,
    padding: Spacing.lg,
    ...Shadows.card,
  },
  section: {
    marginTop: Spacing.xl,
    paddingHorizontal: Spacing.xl,
  },
  sectionTitle: {
    ...Typography.label,
    color: Colors.stone[500],
    letterSpacing: 1,
    marginBottom: Spacing.md,
  },
  discoveryCard: {
    backgroundColor: Colors.indigo[500],
    borderRadius: 16,
    padding: Spacing.lg,
  },
  discoveryIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: Colors.indigo[400],
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: Spacing.md,
  },
  discoveryTitle: {
    ...Typography.heading3,
    color: Colors.white,
  },
  discoveryDescription: {
    ...Typography.body,
    color: Colors.indigo[100],
    marginTop: Spacing.sm,
  },
  discoveryImpact: {
    ...Typography.caption,
    color: Colors.indigo[200],
    marginTop: Spacing.md,
    fontStyle: 'italic',
  },
});

const barStyles = StyleSheet.create({
  container: {
    height: 180,
  },
  avgLine: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.md,
  },
  avgLabel: {
    ...Typography.caption,
    color: Colors.stone[500],
  },
  avgValue: {
    ...Typography.heading3,
    color: Colors.stone[900],
  },
  barsContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    paddingTop: Spacing.md,
  },
  barWrapper: {
    flex: 1,
    alignItems: 'center',
    height: '100%',
    justifyContent: 'flex-end',
  },
  bar: {
    width: 24,
    backgroundColor: Colors.stone[200],
    borderRadius: 4,
    marginBottom: Spacing.xs,
  },
  barToday: {
    backgroundColor: Colors.indigo[500],
  },
  dayLabel: {
    ...Typography.label,
    color: Colors.stone[400],
    fontSize: 10,
  },
  dayLabelToday: {
    color: Colors.indigo[500],
    fontWeight: '600',
  },
});

const alertStyles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    borderRadius: 12,
    padding: Spacing.md,
    marginBottom: Spacing.sm,
    ...Shadows.card,
  },
  icon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    flex: 1,
    marginLeft: Spacing.md,
  },
  message: {
    ...Typography.bodyMedium,
    color: Colors.stone[700],
  },
  timestamp: {
    ...Typography.caption,
    color: Colors.stone[400],
    marginTop: 2,
  },
});
```

---

## Task 6.5: Settings画面更新

### `app/app/(main)/settings.tsx`

```typescript
import { useCallback } from 'react';
import { View, Text, StyleSheet, ScrollView, Switch, Pressable, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import Constants from 'expo-constants';
import { Colors, Spacing, Typography, Shadows } from '@/theme';
import { t } from '@/i18n';
import { useUserStore } from '@/stores/userStore';

interface SettingsRowProps {
  icon: keyof typeof Ionicons.glyphMap;
  label: string;
  value?: string;
  showChevron?: boolean;
  onPress?: () => void;
  children?: React.ReactNode;
}

const SettingsRow: React.FC<SettingsRowProps> = ({
  icon,
  label,
  value,
  showChevron = false,
  onPress,
  children,
}) => {
  const content = (
    <View style={rowStyles.container}>
      <View style={rowStyles.iconContainer}>
        <Ionicons name={icon} size={20} color={Colors.stone[600]} />
      </View>
      <Text style={rowStyles.label}>{label}</Text>
      <View style={rowStyles.rightContent}>
        {children ?? (
          <>
            {value && <Text style={rowStyles.value}>{value}</Text>}
            {showChevron && (
              <Ionicons name="chevron-forward" size={20} color={Colors.stone[400]} />
            )}
          </>
        )}
      </View>
    </View>
  );

  if (onPress) {
    return (
      <Pressable onPress={onPress} accessibilityRole="button">
        {content}
      </Pressable>
    );
  }

  return content;
};

interface SectionProps {
  title: string;
  children: React.ReactNode;
}

const Section: React.FC<SectionProps> = ({ title, children }) => (
  <View style={sectionStyles.container}>
    <Text style={sectionStyles.title}>{title}</Text>
    <View style={sectionStyles.content}>{children}</View>
  </View>
);

export default function SettingsScreen(): React.ReactElement {
  const router = useRouter();
  const {
    nickname,
    wakeUpTime,
    windDownTime,
    gentleNudges,
    hapticFeedback,
    setGentleNudges,
    setHapticFeedback,
    resetOnboarding,
  } = useUserStore();

  const appVersion = Constants.expoConfig?.version ?? '1.0.0';

  const handleResetOnboarding = useCallback((): void => {
    Alert.alert(
      t('screen.settings.resetOnboarding'),
      'Are you sure you want to reset onboarding?',
      [
        { text: t('common.button.cancel'), style: 'cancel' },
        {
          text: 'Reset',
          style: 'destructive',
          onPress: () => {
            resetOnboarding();
            router.replace('/');
          },
        },
      ]
    );
  }, [resetOnboarding, router]);

  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* ヘッダー */}
        <View style={styles.header}>
          <Text style={styles.title}>{t('screen.settings.title')}</Text>
          <Text style={styles.subtitle}>{t('screen.settings.subtitle')}</Text>
        </View>

        {/* プロフィール */}
        <View style={styles.profileCard}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>
              {nickname?.charAt(0).toUpperCase() ?? 'U'}
            </Text>
          </View>
          <Text style={styles.profileName}>{nickname ?? 'User'}</Text>
        </View>

        {/* MY RHYTHM */}
        <Section title={t('screen.settings.myRhythm')}>
          <SettingsRow
            icon="sunny-outline"
            label={t('screen.settings.targetWakeUp')}
            value={wakeUpTime ?? '07:00'}
            showChevron
            onPress={() => {/* Time picker */}}
          />
          <SettingsRow
            icon="moon-outline"
            label={t('screen.settings.targetBedtime')}
            value={windDownTime ?? '23:00'}
            showChevron
            onPress={() => {/* Time picker */}}
          />
        </Section>

        {/* PREFERENCES */}
        <Section title={t('screen.settings.preferences')}>
          <SettingsRow
            icon="notifications-outline"
            label={t('screen.settings.gentleNudges')}
          >
            <Switch
              value={gentleNudges}
              onValueChange={setGentleNudges}
              trackColor={{ false: Colors.stone[200], true: Colors.indigo[200] }}
              thumbColor={gentleNudges ? Colors.indigo[500] : Colors.stone[400]}
            />
          </SettingsRow>
          <SettingsRow
            icon="phone-portrait-outline"
            label={t('screen.settings.hapticFeedback')}
          >
            <Switch
              value={hapticFeedback}
              onValueChange={setHapticFeedback}
              trackColor={{ false: Colors.stone[200], true: Colors.indigo[200] }}
              thumbColor={hapticFeedback ? Colors.indigo[500] : Colors.stone[400]}
            />
          </SettingsRow>
        </Section>

        {/* DATA SOURCE */}
        <Section title={t('screen.settings.dataSource')}>
          <SettingsRow
            icon="heart-outline"
            label={t('screen.settings.appleHealth')}
            value={t('screen.settings.connected')}
          />
          <SettingsRow
            icon="ellipse-outline"
            label={t('screen.settings.ouraRing')}
            value={t('screen.settings.connect')}
            showChevron
            onPress={() => {/* Oura connection */}}
          />
        </Section>

        {/* SUPPORT */}
        <Section title={t('screen.settings.support')}>
          <SettingsRow
            icon="help-circle-outline"
            label={t('screen.settings.helpCenter')}
            showChevron
            onPress={() => {/* Open help */}}
          />
          <SettingsRow
            icon="shield-checkmark-outline"
            label={t('screen.settings.privacyPolicy')}
            showChevron
            onPress={() => {/* Open privacy policy */}}
          />
          <SettingsRow
            icon="refresh-outline"
            label={t('screen.settings.resetOnboarding')}
            showChevron
            onPress={handleResetOnboarding}
          />
        </Section>

        {/* バージョン */}
        <View style={styles.versionContainer}>
          <Text style={styles.versionText}>
            {t('screen.settings.version')} {appVersion}
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.offWhite,
  },
  scrollContent: {
    paddingBottom: Spacing.xxl,
  },
  header: {
    paddingHorizontal: Spacing.xl,
    paddingTop: Spacing.lg,
  },
  title: {
    ...Typography.heading1,
    color: Colors.stone[900],
  },
  subtitle: {
    ...Typography.caption,
    color: Colors.stone[500],
    marginTop: Spacing.xs,
  },
  profileCard: {
    alignItems: 'center',
    marginTop: Spacing.xl,
    marginHorizontal: Spacing.xl,
    backgroundColor: Colors.white,
    borderRadius: 16,
    padding: Spacing.lg,
    ...Shadows.card,
  },
  avatar: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: Colors.indigo[100],
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatarText: {
    ...Typography.heading2,
    color: Colors.indigo[500],
  },
  profileName: {
    ...Typography.heading3,
    color: Colors.stone[900],
    marginTop: Spacing.md,
  },
  versionContainer: {
    alignItems: 'center',
    marginTop: Spacing.xl,
    paddingTop: Spacing.lg,
  },
  versionText: {
    ...Typography.caption,
    color: Colors.stone[400],
  },
});

const sectionStyles = StyleSheet.create({
  container: {
    marginTop: Spacing.xl,
    paddingHorizontal: Spacing.xl,
  },
  title: {
    ...Typography.label,
    color: Colors.stone[500],
    letterSpacing: 1,
    marginBottom: Spacing.sm,
  },
  content: {
    backgroundColor: Colors.white,
    borderRadius: 12,
    overflow: 'hidden',
    ...Shadows.card,
  },
});

const rowStyles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: Spacing.md,
    paddingHorizontal: Spacing.md,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: Colors.stone[100],
    minHeight: 52,
  },
  iconContainer: {
    width: 32,
    alignItems: 'center',
  },
  label: {
    ...Typography.body,
    color: Colors.stone[700],
    flex: 1,
    marginLeft: Spacing.sm,
  },
  rightContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  value: {
    ...Typography.body,
    color: Colors.stone[400],
    marginRight: Spacing.xs,
  },
});
```

---

## Phase 6 完了時の検証

### 必須コマンド（全てパスすること）

```bash
cd app

# 1. 型チェック
pnpm typecheck

# 2. リント
pnpm lint

# 3. テスト
pnpm test

# 4. ビルド確認（iOS）
pnpm ios --no-dev

# 5. ビルド確認（Android）
pnpm android --no-dev
```

### 動作確認

```
# シミュレーター/エミュレーターで確認

Today画面:
- [ ] 日付ナビゲーションが動作する
- [ ] 時間帯に応じた挨拶が表示される
- [ ] WaveScoreがアニメーションで表示される
- [ ] AIメッセージカードが表示される
- [ ] Today's One Thingが表示される
- [ ] MetricCardをタップするとBottomSheetが開く

Rhythm画面:
- [ ] エネルギーグラフが表示される
- [ ] 現在のフェーズが強調表示される
- [ ] UPCOMING WINDOWSに次のフェーズが表示される
- [ ] Sunrise/Sunsetが表示される

Breathe画面:
- [ ] 深いネイビー背景
- [ ] 呼吸円がアニメーションする
- [ ] 4-7-8タイミングで指示テキストが変わる
- [ ] タイマーが動作する
- [ ] フェーズ変化時にHapticが動作する（iOS）

Insights画面:
- [ ] 週間バーチャートが表示される
- [ ] TOP DISCOVERYカードが表示される
- [ ] RECENT ALERTSが表示される

Settings画面:
- [ ] プロフィールが表示される
- [ ] MY RHYTHM設定が表示される
- [ ] トグルスイッチが動作する
- [ ] Reset Onboardingが動作する
```

### 完了チェックリスト

- [ ] `app/app/(main)/index.tsx` が完全実装されている
- [ ] `app/app/(main)/rhythm.tsx` が完全実装されている
- [ ] `app/app/(main)/breathe.tsx` が完全実装されている
- [ ] `app/app/(main)/insights.tsx` が完全実装されている
- [ ] `app/app/(main)/settings.tsx` が更新されている
- [ ] 全画面でi18nキーが使用されている
- [ ] アクセシビリティラベルが設定されている
- [ ] Hapticフィードバックが実装されている
- [ ] **`pnpm typecheck` でエラーなし**
- [ ] **`pnpm lint` でエラーなし**
- [ ] **`pnpm test` でエラーなし**
- [ ] **iOS ビルドが成功する**
- [ ] **Android ビルドが成功する**

---

## 次のフェーズ

Phase 6 の全てのチェックが完了したら、`07-phase7-backend.md` に進む。
