# Phase 9: テスト・品質保証

## 目的

- ユニットテストの実装
- 統合テストの実装
- アクセシビリティ検証
- パフォーマンス検証

---

## 開始前に読むべきドキュメント

**必ず以下のドキュメントを全て読んでから実装を開始すること:**

| ドキュメント | パス | 確認ポイント |
|-------------|------|-------------|
| CLAUDE.md | `/CLAUDE.md` | テスト規約、コード品質 |
| React Native規約 | `/.claude/react-native-standards.md` | テスト実装パターン |
| TypeScript+Hono規約 | `/.claude/typescript-hono-standards.md` | バックエンドテスト規約 |
| UI/UX仕様 | `/docs/specs/ui_ux_design.md` | アクセシビリティ基準 |
| メトリクス仕様 | `/docs/specs/metrics_spec.md` | スコア算出ロジック検証 |

---

## Task 9.1: フロントエンドユニットテスト

### テスト対象

| カテゴリ | ファイル | テスト項目 |
|---------|---------|-----------|
| Services | `tempoScoreCalculator.ts` | スコア算出 |
| Services | `rhythmCalculator.ts` | フェーズ算出 |
| Services | `alertGenerator.ts` | アラート生成 |
| Utils | `format.ts` | フォーマット関数 |
| Stores | `healthStore.ts` | 状態管理 |
| Stores | `insightStore.ts` | 状態管理 |
| Stores | `breatheStore.ts` | 状態管理 |

### `app/__tests__/domain/services/tempoScoreCalculator.test.ts`

```typescript
import { describe, expect, it } from 'vitest';
import { calculateTempoScore } from '@/domain/services/tempoScoreCalculator';
import type { HealthMetrics } from '@/domain/models/health';

describe('tempoScoreCalculator', () => {
  describe('calculateTempoScore', () => {
    const baseMetrics: HealthMetrics = {
      sleep: {
        durationMinutes: 480,
        deepSleepMinutes: 100,
        remSleepMinutes: 90,
      },
      hrv: {
        value: 50,
        baseline30d: 50,
      },
      activity: {
        steps: 8000,
      },
    };

    it('should return score between 0 and 100', () => {
      const score = calculateTempoScore(baseMetrics);
      expect(score).toBeGreaterThanOrEqual(0);
      expect(score).toBeLessThanOrEqual(100);
    });

    it('should return higher score for above-baseline HRV', () => {
      const highHrvMetrics: HealthMetrics = {
        ...baseMetrics,
        hrv: { value: 60, baseline30d: 50 },
      };
      const normalScore = calculateTempoScore(baseMetrics);
      const highScore = calculateTempoScore(highHrvMetrics);
      expect(highScore).toBeGreaterThan(normalScore);
    });

    it('should return lower score for below-baseline HRV', () => {
      const lowHrvMetrics: HealthMetrics = {
        ...baseMetrics,
        hrv: { value: 40, baseline30d: 50 },
      };
      const normalScore = calculateTempoScore(baseMetrics);
      const lowScore = calculateTempoScore(lowHrvMetrics);
      expect(lowScore).toBeLessThan(normalScore);
    });

    it('should factor in sleep duration', () => {
      const shortSleepMetrics: HealthMetrics = {
        ...baseMetrics,
        sleep: { ...baseMetrics.sleep, durationMinutes: 300 },
      };
      const normalScore = calculateTempoScore(baseMetrics);
      const shortSleepScore = calculateTempoScore(shortSleepMetrics);
      expect(shortSleepScore).toBeLessThan(normalScore);
    });

    it('should factor in deep sleep ratio', () => {
      const goodDeepSleepMetrics: HealthMetrics = {
        ...baseMetrics,
        sleep: { ...baseMetrics.sleep, deepSleepMinutes: 120 },
      };
      const normalScore = calculateTempoScore(baseMetrics);
      const goodDeepScore = calculateTempoScore(goodDeepSleepMetrics);
      expect(goodDeepScore).toBeGreaterThanOrEqual(normalScore);
    });

    it('should handle zero values gracefully', () => {
      const zeroMetrics: HealthMetrics = {
        sleep: { durationMinutes: 0, deepSleepMinutes: 0, remSleepMinutes: 0 },
        hrv: { value: 0, baseline30d: 0 },
        activity: { steps: 0 },
      };
      const score = calculateTempoScore(zeroMetrics);
      expect(score).toBeGreaterThanOrEqual(0);
      expect(score).toBeLessThanOrEqual(100);
    });
  });
});
```

### `app/__tests__/domain/services/rhythmCalculator.test.ts`

```typescript
import { describe, expect, it, beforeEach, afterEach, vi } from 'vitest';
import { calculateCircadianPhases, getCurrentPhase } from '@/domain/services/rhythmCalculator';

describe('rhythmCalculator', () => {
  describe('calculateCircadianPhases', () => {
    const wakeUpTime = '07:00';
    const windDownTime = '23:00';

    it('should return 6 phases', () => {
      const phases = calculateCircadianPhases(wakeUpTime, windDownTime);
      expect(phases).toHaveLength(6);
    });

    it('should include all required phase names', () => {
      const phases = calculateCircadianPhases(wakeUpTime, windDownTime);
      const phaseNames = phases.map((p) => p.name);
      expect(phaseNames).toContain('Wake Window');
      expect(phaseNames).toContain('Peak Focus');
      expect(phaseNames).toContain('Afternoon Dip');
      expect(phaseNames).toContain('Second Wind');
      expect(phaseNames).toContain('Wind Down');
      expect(phaseNames).toContain('Melatonin Window');
    });

    it('should calculate Peak Focus 2-4 hours after wake up', () => {
      const phases = calculateCircadianPhases(wakeUpTime, windDownTime);
      const peakFocus = phases.find((p) => p.name === 'Peak Focus');
      expect(peakFocus).toBeDefined();

      const wakeTime = new Date();
      wakeTime.setHours(7, 0, 0, 0);
      const expectedStart = new Date(wakeTime);
      expectedStart.setHours(wakeTime.getHours() + 2);

      expect(peakFocus?.start.getHours()).toBe(9);
    });

    it('should have non-overlapping time ranges', () => {
      const phases = calculateCircadianPhases(wakeUpTime, windDownTime);
      for (let i = 0; i < phases.length - 1; i++) {
        expect(phases[i]!.end.getTime()).toBeLessThanOrEqual(phases[i + 1]!.start.getTime());
      }
    });
  });

  describe('getCurrentPhase', () => {
    beforeEach(() => {
      vi.useFakeTimers();
    });

    afterEach(() => {
      vi.useRealTimers();
    });

    it('should return current phase based on time', () => {
      // 10:00 に設定（Peak Focus時間帯）
      vi.setSystemTime(new Date(2026, 0, 6, 10, 0, 0));

      const phases = calculateCircadianPhases('07:00', '23:00');
      const current = getCurrentPhase(phases);

      expect(current?.name).toBe('Peak Focus');
    });

    it('should return null when no phase matches', () => {
      // 深夜3時に設定
      vi.setSystemTime(new Date(2026, 0, 6, 3, 0, 0));

      const phases = calculateCircadianPhases('07:00', '23:00');
      const current = getCurrentPhase(phases);

      // 睡眠中はフェーズなし、またはMelatonin Windowの延長
      expect(current).toBeNull();
    });
  });
});
```

### `app/__tests__/domain/services/alertGenerator.test.ts`

```typescript
import { describe, expect, it } from 'vitest';
import { generateAlerts } from '@/domain/services/alertGenerator';
import type { HealthMetrics } from '@/domain/models/health';

describe('alertGenerator', () => {
  describe('generateAlerts', () => {
    const baseMetrics: HealthMetrics = {
      sleep: { durationMinutes: 480, deepSleepMinutes: 100, remSleepMinutes: 90 },
      hrv: { value: 50, baseline30d: 50 },
      activity: { steps: 8000 },
    };

    it('should return empty array for healthy metrics', () => {
      const alerts = generateAlerts(baseMetrics);
      expect(alerts.filter((a) => a.priority === 'high')).toHaveLength(0);
    });

    it('should generate recovery_needed alert for low HRV', () => {
      const lowHrvMetrics: HealthMetrics = {
        ...baseMetrics,
        hrv: { value: 35, baseline30d: 50 }, // 30% below baseline
      };
      const alerts = generateAlerts(lowHrvMetrics);
      const recoveryAlert = alerts.find((a) => a.type === 'recovery_needed');
      expect(recoveryAlert).toBeDefined();
      expect(recoveryAlert?.priority).toBe('high');
    });

    it('should generate recovery_complete alert for high HRV', () => {
      const highHrvMetrics: HealthMetrics = {
        ...baseMetrics,
        hrv: { value: 60, baseline30d: 50 }, // 20% above baseline
      };
      const alerts = generateAlerts(highHrvMetrics);
      const completeAlert = alerts.find((a) => a.type === 'recovery_complete');
      expect(completeAlert).toBeDefined();
      expect(completeAlert?.priority).toBe('low');
    });

    it('should generate sleep_deficit alert for short sleep', () => {
      const shortSleepMetrics: HealthMetrics = {
        ...baseMetrics,
        sleep: { ...baseMetrics.sleep, durationMinutes: 300 }, // 5 hours
      };
      const alerts = generateAlerts(shortSleepMetrics);
      const sleepAlert = alerts.find((a) => a.type === 'sleep_deficit');
      expect(sleepAlert).toBeDefined();
      expect(sleepAlert?.priority).toBe('high');
    });

    it('should generate low_activity alert for insufficient steps', () => {
      const lowActivityMetrics: HealthMetrics = {
        ...baseMetrics,
        activity: { steps: 2000 },
      };
      const alerts = generateAlerts(lowActivityMetrics);
      const activityAlert = alerts.find((a) => a.type === 'low_activity');
      expect(activityAlert).toBeDefined();
    });

    it('should generate multiple alerts when multiple conditions are met', () => {
      const problematicMetrics: HealthMetrics = {
        sleep: { durationMinutes: 300, deepSleepMinutes: 30, remSleepMinutes: 40 },
        hrv: { value: 35, baseline30d: 50 },
        activity: { steps: 2000 },
      };
      const alerts = generateAlerts(problematicMetrics);
      expect(alerts.length).toBeGreaterThan(1);
    });
  });
});
```

### `app/__tests__/utils/format.test.ts`

```typescript
import { describe, expect, it } from 'vitest';
import { formatDuration, formatTime, formatDate } from '@/utils/format';

describe('format utilities', () => {
  describe('formatDuration', () => {
    it('should format minutes to hours and minutes', () => {
      expect(formatDuration(480)).toBe('8h 0m');
      expect(formatDuration(450)).toBe('7h 30m');
      expect(formatDuration(90)).toBe('1h 30m');
      expect(formatDuration(45)).toBe('0h 45m');
    });

    it('should handle zero minutes', () => {
      expect(formatDuration(0)).toBe('0h 0m');
    });

    it('should handle large values', () => {
      expect(formatDuration(600)).toBe('10h 0m');
    });
  });

  describe('formatTime', () => {
    it('should format date to HH:MM', () => {
      const date = new Date(2026, 0, 6, 14, 30, 0);
      expect(formatTime(date)).toBe('14:30');
    });

    it('should pad single digits', () => {
      const date = new Date(2026, 0, 6, 7, 5, 0);
      expect(formatTime(date)).toBe('07:05');
    });
  });

  describe('formatDate', () => {
    it('should format date in Japanese locale', () => {
      const date = new Date(2026, 0, 6);
      const formatted = formatDate(date);
      expect(formatted).toContain('2026');
      expect(formatted).toContain('1');
      expect(formatted).toContain('6');
    });
  });
});
```

---

## Task 9.2: Storeテスト

### `app/__tests__/stores/healthStore.test.ts`

```typescript
import { describe, expect, it, beforeEach } from 'vitest';
import { useHealthStore } from '@/stores/healthStore';

describe('healthStore', () => {
  beforeEach(() => {
    useHealthStore.setState({
      tempoScore: null,
      sleepData: null,
      hrvData: null,
      activityData: null,
      circadianPhases: [],
      currentPhase: null,
      sunriseTime: null,
      sunsetTime: null,
    });
  });

  describe('setTempoScore', () => {
    it('should set tempo score', () => {
      const { setTempoScore } = useHealthStore.getState();
      setTempoScore(75);
      expect(useHealthStore.getState().tempoScore).toBe(75);
    });
  });

  describe('setSleepData', () => {
    it('should set sleep data', () => {
      const { setSleepData } = useHealthStore.getState();
      const sleepData = {
        durationMinutes: 480,
        deepSleepMinutes: 100,
        remSleepMinutes: 90,
      };
      setSleepData(sleepData);
      expect(useHealthStore.getState().sleepData).toEqual(sleepData);
    });
  });

  describe('calculateTempoScore', () => {
    it('should calculate score from health metrics', () => {
      const store = useHealthStore.getState();
      store.setSleepData({ durationMinutes: 480, deepSleepMinutes: 100, remSleepMinutes: 90 });
      store.setHrvData({ value: 50, baseline30d: 50 });
      store.setActivityData({ steps: 8000 });

      store.calculateTempoScore();

      const { tempoScore } = useHealthStore.getState();
      expect(tempoScore).toBeDefined();
      expect(tempoScore).toBeGreaterThan(0);
      expect(tempoScore).toBeLessThanOrEqual(100);
    });
  });

  describe('calculateCircadianPhases', () => {
    it('should calculate phases from wake/wind down times', () => {
      const { calculateCircadianPhases } = useHealthStore.getState();
      calculateCircadianPhases('07:00', '23:00');

      const { circadianPhases, currentPhase } = useHealthStore.getState();
      expect(circadianPhases.length).toBeGreaterThan(0);
    });
  });
});
```

### `app/__tests__/stores/breatheStore.test.ts`

```typescript
import { describe, expect, it, beforeEach, vi, afterEach } from 'vitest';
import { useBreatheStore } from '@/stores/breatheStore';

describe('breatheStore', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    useBreatheStore.setState({
      isActive: false,
      phase: 'idle',
      elapsedTime: 0,
    });
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  describe('start', () => {
    it('should set isActive to true', () => {
      const { start } = useBreatheStore.getState();
      start();
      expect(useBreatheStore.getState().isActive).toBe(true);
    });

    it('should set phase to inhale', () => {
      const { start } = useBreatheStore.getState();
      start();
      expect(useBreatheStore.getState().phase).toBe('inhale');
    });
  });

  describe('pause', () => {
    it('should set isActive to false', () => {
      useBreatheStore.setState({ isActive: true, phase: 'inhale' });
      const { pause } = useBreatheStore.getState();
      pause();
      expect(useBreatheStore.getState().isActive).toBe(false);
    });
  });

  describe('reset', () => {
    it('should reset all state', () => {
      useBreatheStore.setState({ isActive: true, phase: 'exhale', elapsedTime: 30 });
      const { reset } = useBreatheStore.getState();
      reset();

      const state = useBreatheStore.getState();
      expect(state.isActive).toBe(false);
      expect(state.phase).toBe('idle');
      expect(state.elapsedTime).toBe(0);
    });
  });

  describe('phase transitions', () => {
    it('should transition from inhale to hold after 4 seconds', () => {
      const { start } = useBreatheStore.getState();
      start();

      // 4秒進める
      vi.advanceTimersByTime(4000);

      expect(useBreatheStore.getState().phase).toBe('hold');
    });

    it('should transition from hold to exhale after 7 seconds', () => {
      useBreatheStore.setState({ isActive: true, phase: 'hold' });

      // 7秒進める
      vi.advanceTimersByTime(7000);

      expect(useBreatheStore.getState().phase).toBe('exhale');
    });

    it('should transition from exhale to inhale after 8 seconds', () => {
      useBreatheStore.setState({ isActive: true, phase: 'exhale' });

      // 8秒進める
      vi.advanceTimersByTime(8000);

      expect(useBreatheStore.getState().phase).toBe('inhale');
    });
  });
});
```

---

## Task 9.3: コンポーネントテスト

### `app/__tests__/components/WaveScore.test.tsx`

```typescript
import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react-native';
import { WaveScore } from '@/components/WaveScore';

describe('WaveScore', () => {
  it('should render the score value', () => {
    render(<WaveScore score={75} />);
    expect(screen.getByText('75')).toBeTruthy();
  });

  it('should have accessibility label', () => {
    render(<WaveScore score={75} />);
    expect(screen.getByLabelText(/tempo score/i)).toBeTruthy();
  });

  it('should render 0 when score is 0', () => {
    render(<WaveScore score={0} />);
    expect(screen.getByText('0')).toBeTruthy();
  });

  it('should cap score at 100', () => {
    render(<WaveScore score={150} />);
    expect(screen.getByText('100')).toBeTruthy();
  });
});
```

### `app/__tests__/components/MetricCard.test.tsx`

```typescript
import { describe, expect, it, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react-native';
import { MetricCard } from '@/components/MetricCard';

describe('MetricCard', () => {
  it('should render sleep card correctly', () => {
    render(
      <MetricCard
        type="sleep"
        value={450}
        label="Sleep"
        onPress={() => {}}
      />
    );
    expect(screen.getByText('Sleep')).toBeTruthy();
  });

  it('should render HRV card correctly', () => {
    render(
      <MetricCard
        type="hrv"
        value={52}
        label="HRV"
        onPress={() => {}}
      />
    );
    expect(screen.getByText('HRV')).toBeTruthy();
    expect(screen.getByText('52')).toBeTruthy();
  });

  it('should render steps card correctly', () => {
    render(
      <MetricCard
        type="steps"
        value={8200}
        label="Steps"
        onPress={() => {}}
      />
    );
    expect(screen.getByText('Steps')).toBeTruthy();
  });

  it('should call onPress when tapped', () => {
    const onPress = vi.fn();
    render(
      <MetricCard
        type="sleep"
        value={450}
        label="Sleep"
        onPress={onPress}
      />
    );

    fireEvent.press(screen.getByRole('button'));
    expect(onPress).toHaveBeenCalled();
  });

  it('should have minimum touch target size of 44x44', () => {
    const { getByTestId } = render(
      <MetricCard
        type="sleep"
        value={450}
        label="Sleep"
        onPress={() => {}}
        testID="metric-card"
      />
    );

    const card = getByTestId('metric-card');
    // スタイルの検証はスナップショットまたはスタイル検査で行う
    expect(card).toBeTruthy();
  });
});
```

---

## Task 9.4: API統合テスト

### `app/__tests__/api/client.test.ts`

```typescript
import { describe, expect, it, vi, beforeEach, afterEach } from 'vitest';
import { apiClient } from '@/api/client';

describe('apiClient', () => {
  beforeEach(() => {
    global.fetch = vi.fn();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe('health', () => {
    it('should return success for healthy response', async () => {
      vi.mocked(fetch).mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ status: 'ok' }),
      } as Response);

      const response = await apiClient.health();
      expect(response.success).toBe(true);
      if (response.success) {
        expect(response.data.status).toBe('ok');
      }
    });

    it('should return error for failed response', async () => {
      vi.mocked(fetch).mockResolvedValueOnce({
        ok: false,
        status: 500,
        json: () => Promise.resolve({ error: 'Server error' }),
      } as Response);

      const response = await apiClient.health();
      expect(response.success).toBe(false);
    });
  });

  describe('generateAdvice', () => {
    const mockRequest = {
      user: {
        goals: ['better_sleep'] as const,
        wakeUpTime: '07:00',
        windDownTime: '23:00',
      },
      healthMetrics: {
        sleep: { durationMinutes: 450, deepSleepMinutes: 100, remSleepMinutes: 90 },
        hrv: { value: 52, baseline30d: 48 },
        activity: { steps: 8200 },
      },
      weather: {
        temperature: 8,
        pressure: 1018,
        pressureTrend: 'falling' as const,
        sunrise: '06:50',
        sunset: '16:48',
      },
    };

    it('should return advice response', async () => {
      vi.mocked(fetch).mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({
          tempoScore: 78,
          message: { title: 'A Quiet Harmony', body: 'Test body' },
          todayOneThing: { icon: 'walking', text: 'Test action' },
          relatedInsight: { text: 'Test insight', insightId: 'test-001' },
          metricInsights: { sleep: 'Test', hrv: 'Test', steps: 'Test' },
        }),
      } as Response);

      const response = await apiClient.generateAdvice(mockRequest);
      expect(response.success).toBe(true);
      if (response.success) {
        expect(response.data.tempoScore).toBe(78);
      }
    });

    it('should handle timeout', async () => {
      vi.mocked(fetch).mockImplementationOnce(() =>
        new Promise((_, reject) => {
          const error = new Error('Aborted');
          error.name = 'AbortError';
          setTimeout(() => reject(error), 100);
        })
      );

      const response = await apiClient.generateAdvice(mockRequest);
      expect(response.success).toBe(false);
      if (!response.success) {
        expect(response.error.error).toBe('Request timeout');
      }
    });
  });
});
```

---

## Task 9.5: アクセシビリティテスト

### `app/__tests__/accessibility/accessibility.test.tsx`

```typescript
import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react-native';
import TodayScreen from '@/app/(main)/index';
import RhythmScreen from '@/app/(main)/rhythm';
import BreatheScreen from '@/app/(main)/breathe';
import InsightsScreen from '@/app/(main)/insights';
import SettingsScreen from '@/app/(main)/settings';

// モックプロバイダー
const renderWithProviders = (component: React.ReactElement) => {
  return render(component);
};

describe('Accessibility', () => {
  describe('Today Screen', () => {
    it('should have accessible navigation buttons', () => {
      renderWithProviders(<TodayScreen />);
      expect(screen.getByLabelText('前の日')).toBeTruthy();
      expect(screen.getByLabelText('次の日')).toBeTruthy();
    });
  });

  describe('Breathe Screen', () => {
    it('should have accessible play/pause button', () => {
      renderWithProviders(<BreatheScreen />);
      expect(screen.getByRole('button')).toHaveAccessibleLabel();
    });
  });

  describe('Settings Screen', () => {
    it('should have accessible toggle switches', () => {
      renderWithProviders(<SettingsScreen />);
      const switches = screen.getAllByRole('switch');
      switches.forEach((toggle) => {
        expect(toggle).toHaveAccessibleName();
      });
    });
  });
});
```

### アクセシビリティチェックリスト

```markdown
## アクセシビリティ検証チェックリスト

### コントラスト比（4.5:1以上）
- [ ] プライマリテキスト（stone-900）on オフホワイト: 16.1:1 ✓
- [ ] セカンダリテキスト（stone-500）on オフホワイト: 4.6:1 ✓
- [ ] キャプション（stone-400）on オフホワイト: 要確認
- [ ] Breathe画面テキスト（white）on ディープネイビー: 15.1:1 ✓

### タップターゲット（44x44px以上）
- [ ] タブバーアイコン
- [ ] 日付ナビゲーション矢印
- [ ] MetricCard
- [ ] BottomSheet閉じるボタン
- [ ] Breathe再生/一時停止ボタン
- [ ] Settings行

### VoiceOverラベル
- [ ] Tempo Score: "Tempo Score {value}点"
- [ ] MetricCard: "{type} {value}"
- [ ] Breathe指示: "{phase}フェーズ"
- [ ] ナビゲーションボタン: "前の日"/"次の日"
- [ ] トグルスイッチ: "{label} {state}"

### フォントサイズ
- [ ] 最小フォントサイズ: 14px（label）
- [ ] 本文: 16px
- [ ] 見出し: 20-32px
```

---

## Task 9.6: バックエンドE2Eテスト

### `backend/__tests__/e2e/advice.e2e.test.ts`

```typescript
import { describe, expect, it, beforeAll, afterAll } from 'vitest';
import { unstable_dev } from 'wrangler';
import type { UnstableDevWorker } from 'wrangler';

describe('Advice API E2E', () => {
  let worker: UnstableDevWorker;

  beforeAll(async () => {
    worker = await unstable_dev('src/index.ts', {
      experimental: { disableExperimentalWarning: true },
    });
  });

  afterAll(async () => {
    await worker.stop();
  });

  describe('POST /api/advice', () => {
    const validRequest = {
      user: {
        goals: ['better_sleep', 'more_energy'],
        wakeUpTime: '07:00',
        windDownTime: '23:00',
      },
      healthMetrics: {
        sleep: {
          durationMinutes: 450,
          deepSleepMinutes: 105,
          remSleepMinutes: 95,
        },
        hrv: {
          value: 52,
          baseline30d: 48,
        },
        activity: {
          steps: 8200,
        },
      },
      weather: {
        temperature: 8,
        pressure: 1018,
        pressureTrend: 'falling',
        sunrise: '06:50',
        sunset: '16:48',
      },
    };

    it('should return valid advice response', async () => {
      const response = await worker.fetch('/api/advice', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(validRequest),
      });

      expect(response.status).toBe(200);

      const data = await response.json();
      expect(data).toHaveProperty('tempoScore');
      expect(data).toHaveProperty('message');
      expect(data).toHaveProperty('todayOneThing');
      expect(data).toHaveProperty('relatedInsight');
      expect(data).toHaveProperty('metricInsights');
    });

    it('should return 400 for invalid request', async () => {
      const response = await worker.fetch('/api/advice', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ invalid: 'data' }),
      });

      expect(response.status).toBe(400);
    });

    it('should return valid response structure', async () => {
      const response = await worker.fetch('/api/advice', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(validRequest),
      });

      const data = await response.json();

      // メッセージ構造
      expect(data.message).toHaveProperty('title');
      expect(data.message).toHaveProperty('body');
      expect(typeof data.message.title).toBe('string');
      expect(typeof data.message.body).toBe('string');

      // todayOneThing構造
      expect(data.todayOneThing).toHaveProperty('icon');
      expect(data.todayOneThing).toHaveProperty('text');
      expect(['walking', 'breathing', 'rest', 'coffee', 'sun']).toContain(data.todayOneThing.icon);

      // metricInsights構造
      expect(data.metricInsights).toHaveProperty('sleep');
      expect(data.metricInsights).toHaveProperty('hrv');
      expect(data.metricInsights).toHaveProperty('steps');
    });
  });
});
```

---

## Phase 9 完了時の検証

### 必須コマンド（全てパスすること）

```bash
# フロントエンド
cd app

# 1. 型チェック
pnpm typecheck

# 2. リント
pnpm lint

# 3. ユニットテスト
pnpm test

# 4. テストカバレッジ
pnpm test:coverage

# 5. ビルド確認（iOS）
pnpm ios --no-dev

# 6. ビルド確認（Android）
pnpm android --no-dev
```

```bash
# バックエンド
cd backend

# 1. 型チェック
pnpm typecheck

# 2. リント
pnpm lint

# 3. ユニットテスト
pnpm test

# 4. E2Eテスト
pnpm test:e2e

# 5. テストカバレッジ
pnpm test:coverage
```

### カバレッジ目標

| カテゴリ | 目標カバレッジ |
|---------|--------------|
| Services | 80%以上 |
| Utils | 90%以上 |
| Stores | 70%以上 |
| Components | 60%以上 |
| API | 80%以上 |

### 完了チェックリスト

- [ ] 全サービスのユニットテストが実装されている
- [ ] 全Storeのテストが実装されている
- [ ] 主要コンポーネントのテストが実装されている
- [ ] API統合テストが実装されている
- [ ] バックエンドE2Eテストが実装されている
- [ ] アクセシビリティ検証が完了している
- [ ] **フロントエンド `pnpm typecheck` でエラーなし**
- [ ] **フロントエンド `pnpm lint` でエラーなし**
- [ ] **フロントエンド `pnpm test` で全テスト通過**
- [ ] **バックエンド `pnpm typecheck` でエラーなし**
- [ ] **バックエンド `pnpm lint` でエラーなし**
- [ ] **バックエンド `pnpm test` で全テスト通過**
- [ ] **iOS ビルドが成功する**
- [ ] **Android ビルドが成功する**

---

## 全Phase完了後の最終確認

### デプロイ前チェックリスト

```markdown
## 最終確認チェックリスト

### 機能確認
- [ ] 5タブが正しくレンダリングされる
- [ ] Tempo Scoreが波アニメーションで表示される
- [ ] MetricCardタップでBottomSheetが開く
- [ ] Rhythm画面で正しいフェーズが表示される
- [ ] Breatheが4-7-8サイクルで動作する
- [ ] Insightsに週間データとアラートが表示される
- [ ] Settingsが正しく永続化される
- [ ] AIアドバイスが新形式で生成される

### 品質確認
- [ ] 全UIテキストがi18nキー経由で表示される
- [ ] アクセシビリティ基準を満たす
- [ ] オンボーディングに影響なし
- [ ] 全テスト通過
- [ ] TypeScriptエラーなし
- [ ] Lintエラーなし

### パフォーマンス確認
- [ ] 初回起動時間が許容範囲内
- [ ] スクロールがスムーズ
- [ ] アニメーションが60fps
- [ ] メモリリークなし
```

---

## 実装完了

全9フェーズの実装が完了しました。

各フェーズの要約:
1. **Phase 1**: i18n基盤、デザインシステム
2. **Phase 2**: ドメインモデル、サービス
3. **Phase 3**: UIコンポーネント
4. **Phase 4**: Zustand Store
5. **Phase 5**: 5タブナビゲーション
6. **Phase 6**: 全画面実装
7. **Phase 7**: バックエンドAPI更新
8. **Phase 8**: フロントエンドAPI連携
9. **Phase 9**: テスト・品質保証

お疲れ様でした！
