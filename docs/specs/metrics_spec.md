# メトリクス・アルゴリズム仕様書

**バージョン**: 4.0  
**最終更新日**: 2026年1月7日

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [product_spec.md](./product_spec.md) | プロダクト仕様 |
| [technical_spec.md](./technical_spec.md) | 技術仕様 |
| [knowledge_base.md](./knowledge_base.md) | 科学的根拠 |

---

## 1. 概要

### 1.1 メトリクス体系

TempoAIは以下の2層構造でメトリクスを管理：

| 層 | 内容 | 用途 |
|---|------|------|
| **4つのスコア** | Recovery, Sleep, Rhythm, Energy | Today画面のメインカード |
| **Health指標** | HRV, RHR, Respiratory, SpO2, Temp | Health Summary詳細 |

### 1.2 計算の実行場所

| 項目 | 実行場所 | 理由 |
|------|---------|------|
| 4つのスコア | フロントエンド（ローカル） | 即時表示、オフライン対応 |
| Health指標の取得 | HealthKit | Apple Watch連携 |
| Typical Range計算 | フロントエンド（ローカル） | 過去データから統計計算 |
| Baseline計算 | フロントエンド（ローカル） | 30-60日の移動平均 |
| AIアドバイス | バックエンド（Claude API） | 高度な解釈 |

---

## 2. 4つのスコア

### 2.1 Recovery Score（回復度）

身体の回復状態を0-100%で表す。

**算出式**:
```typescript
function calculateRecoveryScore(
  hrv: { current: number; baseline: number },
  rhr: { current: number; baseline: number },
  sleepQuality: number // 0-100
): number {
  // HRVスコア（60%）- 高いほど良い
  const hrvRatio = hrv.current / hrv.baseline;
  const hrvScore = clamp((hrvRatio - 0.7) / 0.6 * 100, 0, 100);
  
  // RHRスコア（20%）- 低いほど良い
  const rhrRatio = rhr.baseline / rhr.current; // 逆比
  const rhrScore = clamp((rhrRatio - 0.85) / 0.3 * 100, 0, 100);
  
  // 睡眠の質（20%）
  const sleepScore = sleepQuality;
  
  return Math.round(hrvScore * 0.60 + rhrScore * 0.20 + sleepScore * 0.20);
}
```

**ステータス判定**:
| スコア | ステータス | 説明 |
|--------|-----------|------|
| 80-100 | Ready to Train | 高強度の活動OK |
| 60-79 | Moderate | 通常の活動OK |
| 40-59 | Light Activity | 軽めの活動を推奨 |
| 0-39 | Recovery Needed | 休息を優先 |

### 2.2 Sleep Score（睡眠スコア）

睡眠の質と量を0-100%で表す。

**算出式**:
```typescript
function calculateSleepScore(
  duration: { minutes: number; targetMinutes: number },
  stages: {
    deepMinutes: number;
    remMinutes: number;
    lightMinutes: number;
    awakeMinutes: number;
  },
  timing: {
    actualBedtime: Date;
    targetBedtime: Date;
    actualWakeTime: Date;
    targetWakeTime: Date;
  }
): number {
  const totalSleep = stages.deepMinutes + stages.remMinutes + stages.lightMinutes;
  
  // Duration Score (40%)
  const durationRatio = duration.minutes / duration.targetMinutes;
  const durationScore = clamp(durationRatio * 100, 0, 100);
  
  // Quality Score (40%)
  const deepRatio = stages.deepMinutes / totalSleep;
  const remRatio = stages.remMinutes / totalSleep;
  const deepScore = scoreRange(deepRatio, 0.15, 0.25); // 15-25%が理想
  const remScore = scoreRange(remRatio, 0.20, 0.25);   // 20-25%が理想
  const qualityScore = deepScore * 0.5 + remScore * 0.5;
  
  // Timing Score (20%)
  const bedtimeDeviation = Math.abs(
    timing.actualBedtime.getTime() - timing.targetBedtime.getTime()
  ) / (1000 * 60); // 分
  const wakeDeviation = Math.abs(
    timing.actualWakeTime.getTime() - timing.targetWakeTime.getTime()
  ) / (1000 * 60);
  const timingScore = clamp(100 - (bedtimeDeviation + wakeDeviation) / 2, 0, 100);
  
  return Math.round(
    durationScore * 0.40 + qualityScore * 0.40 + timingScore * 0.20
  );
}

function scoreRange(value: number, min: number, max: number): number {
  if (value >= min && value <= max) return 100;
  if (value < min) return (value / min) * 100;
  return Math.max(0, 100 - (value - max) * 200);
}
```

### 2.3 Rhythm Score（リズム安定性）

就寝・起床時刻の一貫性を0-100%で表す。

**算出式**:
```typescript
function calculateRhythmScore(
  last7Days: {
    bedtime: Date;
    wakeTime: Date;
  }[]
): number {
  if (last7Days.length < 3) return 70; // データ不足時はデフォルト
  
  // 就寝時刻の標準偏差（分）
  const bedtimeMinutes = last7Days.map(d => dateToMinutes(d.bedtime));
  const bedtimeStdDev = calculateStdDev(bedtimeMinutes);
  
  // 起床時刻の標準偏差（分）
  const wakeMinutes = last7Days.map(d => dateToMinutes(d.wakeTime));
  const wakeStdDev = calculateStdDev(wakeMinutes);
  
  // スコア変換
  const bedtimeScore = stdDevToScore(bedtimeStdDev);
  const wakeScore = stdDevToScore(wakeStdDev);
  
  return Math.round((bedtimeScore + wakeScore) / 2);
}

function stdDevToScore(stdDev: number): number {
  // 標準偏差が小さいほど高スコア
  if (stdDev <= 15) return 100;  // ±15分以内
  if (stdDev <= 30) return 85;   // ±30分以内
  if (stdDev <= 45) return 70;
  if (stdDev <= 60) return 55;
  if (stdDev <= 90) return 40;
  return 25;
}

function calculateStdDev(values: number[]): number {
  const mean = values.reduce((a, b) => a + b, 0) / values.length;
  const squaredDiffs = values.map(v => Math.pow(v - mean, 2));
  const avgSquaredDiff = squaredDiffs.reduce((a, b) => a + b, 0) / values.length;
  return Math.sqrt(avgSquaredDiff);
}

function dateToMinutes(date: Date): number {
  // 深夜0時を基準に、24時以降は翌日として計算
  let minutes = date.getHours() * 60 + date.getMinutes();
  if (minutes < 180) minutes += 1440; // 3時より前は前日扱い
  return minutes;
}
```

### 2.4 Energy Score（エネルギー予測）

今日のエネルギーレベル予測を0-100%で表す。

**算出式**:
```typescript
function calculateEnergyScore(
  recovery: number,      // Recovery Score (0-100)
  sleep: number,         // Sleep Score (0-100)
  weather: {
    pressure: number;    // hPa
    pressureTrend: 'rising' | 'stable' | 'falling';
  }
): number {
  // ベーススコア（Recovery 50%, Sleep 40%）
  const baseScore = recovery * 0.50 + sleep * 0.40;
  
  // 天気補正（10%）
  let weatherFactor = 100;
  
  // 気圧の影響（急低下は-20%）
  if (weather.pressureTrend === 'falling' && weather.pressure < 1010) {
    weatherFactor -= 20;
  } else if (weather.pressureTrend === 'rising') {
    weatherFactor += 5;
  }
  
  const weatherScore = clamp(weatherFactor, 0, 100);
  
  return Math.round(baseScore + weatherScore * 0.10);
}
```

---

## 3. Health指標

### 3.1 取得データ一覧

| 指標 | HealthKit Identifier | 単位 | 取得タイミング |
|------|---------------------|------|---------------|
| HRV | `heartRateVariabilitySDNN` | ms | 睡眠中/朝のMindfulness |
| RHR | `restingHeartRate` | bpm | 日中の安静時 |
| Respiratory Rate | `respiratoryRate` | BrPM | 睡眠中 |
| SpO2 | `oxygenSaturation` | % | 睡眠中 |
| Wrist Temperature | `appleSleepingWristTemperature` | °C | 睡眠中 |

### 3.2 Baseline計算

各指標の個人ベースラインを30日または60日の移動平均で算出。

```typescript
interface BaselineConfig {
  shortTerm: 7;   // 短期比較用
  mediumTerm: 30; // 標準ベースライン
  longTerm: 60;   // 長期ベースライン
}

function calculateBaseline(
  values: { date: Date; value: number }[],
  days: number
): number {
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - days);
  
  const relevantValues = values
    .filter(v => v.date >= cutoff)
    .map(v => v.value);
  
  if (relevantValues.length === 0) return 0;
  
  return relevantValues.reduce((a, b) => a + b, 0) / relevantValues.length;
}
```

### 3.3 Typical Range計算

個人の正常範囲を過去データの統計から算出。

```typescript
interface TypicalRange {
  min: number;
  max: number;
  source: 'personal' | 'default';
}

function calculateTypicalRange(
  values: number[],
  defaultRange: { min: number; max: number }
): TypicalRange {
  // 最低14日分のデータが必要
  if (values.length < 14) {
    return { ...defaultRange, source: 'default' };
  }
  
  // 5-95パーセンタイルを使用（外れ値を除外）
  const sorted = [...values].sort((a, b) => a - b);
  const p5Index = Math.floor(sorted.length * 0.05);
  const p95Index = Math.floor(sorted.length * 0.95);
  
  return {
    min: Math.round(sorted[p5Index]),
    max: Math.round(sorted[p95Index]),
    source: 'personal'
  };
}
```

**デフォルト範囲（データ不足時）**:

| 指標 | デフォルト Min | デフォルト Max |
|------|---------------|---------------|
| HRV | 20ms | 100ms |
| RHR | 50bpm | 80bpm |
| Respiratory | 10 BrPM | 16 BrPM |
| SpO2 | 95% | 100% |
| Wrist Temp | 35.5°C | 37.0°C |

### 3.4 ステータス判定

```typescript
type HealthStatus = 'within' | 'low' | 'high';

function determineStatus(
  value: number,
  range: TypicalRange
): { status: HealthStatus; message: string } {
  if (value >= range.min && value <= range.max) {
    return {
      status: 'within',
      message: `Within ${range.min}-${range.max}`
    };
  }
  if (value < range.min) {
    return {
      status: 'low',
      message: `Low < ${range.min}`
    };
  }
  return {
    status: 'high',
    message: `High > ${range.max}`
  };
}
```

---

## 4. 期間別データ取得

### 4.1 タブ切り替え対応

Health詳細画面の7D/30D/60Dタブに応じたデータ取得。

```typescript
type TimeRange = '7D' | '30D' | '60D';

interface ChartDataPoint {
  date: Date;
  value: number;
  label: string; // "Mon", "Jan 1" など
}

function getChartData(
  allData: { date: Date; value: number }[],
  range: TimeRange
): ChartDataPoint[] {
  const days = range === '7D' ? 7 : range === '30D' ? 30 : 60;
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - days);
  
  const filtered = allData.filter(d => d.date >= cutoff);
  
  // 7日: 日別表示
  if (range === '7D') {
    return filtered.map(d => ({
      date: d.date,
      value: d.value,
      label: formatDayLabel(d.date) // "T", "F", "S"...
    }));
  }
  
  // 30日/60日: 週別平均
  return aggregateByWeek(filtered);
}

function formatDayLabel(date: Date): string {
  const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  return days[date.getDay()];
}

function aggregateByWeek(
  data: { date: Date; value: number }[]
): ChartDataPoint[] {
  const weeks = new Map<string, number[]>();
  
  data.forEach(d => {
    const weekStart = getWeekStart(d.date);
    const key = weekStart.toISOString();
    if (!weeks.has(key)) weeks.set(key, []);
    weeks.get(key)!.push(d.value);
  });
  
  return Array.from(weeks.entries()).map(([key, values]) => ({
    date: new Date(key),
    value: values.reduce((a, b) => a + b, 0) / values.length,
    label: formatWeekLabel(new Date(key))
  }));
}
```

### 4.2 HealthKitクエリ

```typescript
async function fetchHealthData(
  metric: HealthMetric,
  range: TimeRange
): Promise<{ date: Date; value: number }[]> {
  const days = range === '7D' ? 7 : range === '30D' ? 30 : 60;
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - days);
  
  const options = {
    startDate: startDate.toISOString(),
    endDate: new Date().toISOString(),
    type: getHealthKitType(metric),
  };
  
  // HealthKitから取得
  const results = await AppleHealthKit.getSamples(options);
  
  // 日付でグループ化して日別平均を計算
  return aggregateByDay(results);
}

function getHealthKitType(metric: HealthMetric): string {
  const mapping = {
    hrv: 'HeartRateVariability',
    rhr: 'RestingHeartRate',
    respiratory: 'RespiratoryRate',
    spo2: 'OxygenSaturation',
    wristTemp: 'AppleSleepingWristTemperature',
  };
  return mapping[metric];
}
```

### 4.3 データキャッシュ戦略

| データ | キャッシュ期間 | 更新トリガー |
|--------|--------------|-------------|
| 今日のHealth指標 | 1時間 | アプリ起動時、手動リフレッシュ |
| 過去7日分 | 6時間 | 日付変更時 |
| 過去30日分 | 24時間 | 週1回 |
| 過去60日分 | 24時間 | 週1回 |
| Baseline | 24時間 | 日次バッチ |
| Typical Range | 7日 | 週次バッチ |

```typescript
interface CacheEntry<T> {
  data: T;
  timestamp: number;
  expiresIn: number; // milliseconds
}

async function getCachedData<T>(
  key: string,
  fetcher: () => Promise<T>,
  expiresIn: number
): Promise<T> {
  const cached = await AsyncStorage.getItem(key);
  
  if (cached) {
    const entry: CacheEntry<T> = JSON.parse(cached);
    const now = Date.now();
    
    if (now - entry.timestamp < entry.expiresIn) {
      return entry.data;
    }
  }
  
  const freshData = await fetcher();
  
  await AsyncStorage.setItem(key, JSON.stringify({
    data: freshData,
    timestamp: Date.now(),
    expiresIn,
  }));
  
  return freshData;
}
```

---

## 5. Rhythmフェーズ計算

### 5.1 フェーズ定義

| フェーズ | 開始時刻 | 終了時刻 | エネルギー | 説明 |
|---------|---------|---------|-----------|------|
| Wake Window | 起床 | 起床+2h | 40-60 | 睡眠慣性からの移行 |
| Peak Focus | 起床+2h | 起床+5h | 80-95 | 最高の集中力 |
| Midday | 起床+5h | 起床+7h | 70-80 | 緩やかな低下 |
| Afternoon Dip | 起床+7h | 起床+9h | 45-55 | サーカディアン低点 |
| Second Wind | 起床+10h | 起床+13h | 70-80 | 夕方のエネルギー回復 |
| Wind Down | 就寝-2h | 就寝 | 40-50 | メラトニン分泌開始 |

### 5.2 フェーズ算出

```typescript
interface RhythmPhase {
  name: string;
  start: Date;
  end: Date;
  energyLevel: 'high' | 'medium' | 'low';
  description: string;
}

function calculateRhythmPhases(
  wakeUpTime: Date,
  windDownTime: Date
): RhythmPhase[] {
  return [
    {
      name: 'Wake Window',
      start: wakeUpTime,
      end: addHours(wakeUpTime, 2),
      energyLevel: 'medium',
      description: 'Ease into your day with light tasks'
    },
    {
      name: 'Peak Focus',
      start: addHours(wakeUpTime, 2),
      end: addHours(wakeUpTime, 5),
      energyLevel: 'high',
      description: 'Best time for complex, creative work'
    },
    {
      name: 'Afternoon Dip',
      start: addHours(wakeUpTime, 7),
      end: addHours(wakeUpTime, 9),
      energyLevel: 'low',
      description: 'Natural energy dip - avoid caffeine'
    },
    {
      name: 'Second Wind',
      start: addHours(wakeUpTime, 10),
      end: addHours(wakeUpTime, 13),
      energyLevel: 'medium',
      description: 'Good for routine tasks and exercise'
    },
    {
      name: 'Wind Down',
      start: addHours(windDownTime, -2),
      end: windDownTime,
      energyLevel: 'low',
      description: 'Prepare for sleep - dim lights'
    }
  ];
}
```

---

## 6. テンプレート文生成

### 6.1 Recovery詳細文

バックエンドではなく、フロントエンドでテンプレートから生成。

```typescript
function generateRecoveryAnalysis(
  hrv: { current: number; baseline: number; lastSampleTime: Date },
  rhr: { current: number; baseline: number; lastSampleTime: Date }
): string {
  const hrvDeviation = ((hrv.current - hrv.baseline) / hrv.baseline * 100).toFixed(0);
  const hrvDirection = hrv.current >= hrv.baseline ? 'higher' : 'lower';
  
  const rhrDeviation = ((rhr.current - rhr.baseline) / rhr.baseline * 100).toFixed(0);
  const rhrDirection = rhr.current >= rhr.baseline ? 'higher' : 'lower';
  
  return `Recovery is based on your daily average HRV of ${hrv.current}ms ` +
    `with the most recent sample taken at ${formatTime(hrv.lastSampleTime)} ` +
    `which is ${Math.abs(Number(hrvDeviation))}% ${hrvDirection} than your ` +
    `60 day average of ${hrv.baseline}ms and your most recent resting heart rate ` +
    `of ${rhr.current}bpm taken at ${formatTime(rhr.lastSampleTime)} which is ` +
    `${rhrDeviation === '0' ? 'equal to' : `${Math.abs(Number(rhrDeviation))}% ${rhrDirection} than`} ` +
    `your 60 day average of ${rhr.baseline}bpm.`;
}
```

### 6.2 Sleep詳細文

```typescript
function generateSleepAnalysis(
  duration: { actual: number; target: number },
  stages: { deep: number; rem: number; deepBaseline: number; remBaseline: number }
): string {
  const durationStatus = duration.actual >= duration.target ? 'met' : 'below';
  const deepStatus = stages.deep >= stages.deepBaseline ? 'higher' : 'lower';
  const remStatus = stages.rem >= stages.remBaseline ? 'higher' : 'lower';
  
  if (durationStatus === 'below' && (deepStatus === 'higher' || remStatus === 'higher')) {
    return `While your sleep was below your Target, your REM and Deep sleep ` +
      `were both higher than your normal ranges. This may suggest that your body ` +
      `is attempting to recover from your sleep deficit by prioritizing these ` +
      `restorative stages.`;
  }
  
  // 他のパターンに応じた文を返す
  return `Your sleep duration of ${formatDuration(duration.actual)} ` +
    `${durationStatus === 'met' ? 'met' : 'was below'} your target. ` +
    `Deep sleep was ${Math.round(stages.deep / duration.actual * 100)}% of total sleep.`;
}
```

---

## 7. キャリブレーション期間

### 7.1 学習期間の表示

| データ日数 | 表示 | 動作 |
|-----------|------|------|
| 0-2日 | "Setting up..." | 仮ベースライン使用 |
| 3-6日 | "Learning..." | 仮ベースライン使用 |
| 7日以上 | 数値表示 | 個人ベースライン使用 |

### 7.2 仮ベースライン

| 指標 | 仮ベースライン |
|------|---------------|
| HRV | 50ms |
| RHR | 60bpm |
| 睡眠時間 | 7時間 |
| Deep Sleep比率 | 20% |
| REM比率 | 22% |

---

## 8. ユーティリティ関数

```typescript
function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

function addHours(date: Date, hours: number): Date {
  return new Date(date.getTime() + hours * 60 * 60 * 1000);
}

function formatTime(date: Date): string {
  return date.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  });
}

function formatDuration(minutes: number): string {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return `${h}h ${m}m`;
}

function getWeekStart(date: Date): Date {
  const d = new Date(date);
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1);
  d.setDate(diff);
  d.setHours(0, 0, 0, 0);
  return d;
}

function formatWeekLabel(date: Date): string {
  return `${date.getMonth() + 1}/${date.getDate()}`;
}
```

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-01-01 | 初版作成 |
| 2.0 | 2026-01-06 | Tempo Score中心に簡素化 |
| 3.0 | 2026-01-06 | Rhythmフェーズ計算、Cosinor分析を追加 |
| 4.0 | 2026-01-07 | 4指標体系に全面改訂、Health指標追加、期間別データ取得追加 |
