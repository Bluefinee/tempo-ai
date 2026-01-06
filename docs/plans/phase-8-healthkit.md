# Phase 8: HealthKit 連携

## 概要

| 項目 | 内容 |
|------|------|
| **目的** | 実機で HealthKit から健康データを取得し、完全動作を実現 |
| **期間目安** | 3-5日 |
| **依存** | Phase 7（API連携）+ Apple Developer アカウント |
| **成果物** | HealthKit 連携が動作する実機ビルド |

---

## 前提条件

### 必須要件

| 要件 | 状態 | 備考 |
|------|------|------|
| Apple Developer アカウント | これから取得 | $99/年、登録に数日 |
| 実機 (iPhone) | 必要 | Simulator では HealthKit 不可 |
| EAS Build | 必要 | Expo Go では ネイティブモジュール不可 |

### Apple Developer アカウント取得手順

1. [Apple Developer Program](https://developer.apple.com/programs/) にアクセス
2. Apple ID でサインイン
3. 個人として登録（$99/年）
4. 支払い完了後、48時間以内に有効化

---

## 技術選定

### react-native-health

| 項目 | 内容 |
|------|------|
| パッケージ | `react-native-health` |
| GitHub | https://github.com/agencyenterprise/react-native-health |
| サポート | iOS のみ（HealthKit） |
| Expo 対応 | Config Plugin あり |

### 取得するデータ

| データ種別 | HealthKit 識別子 | 用途 |
|-----------|-----------------|------|
| 睡眠分析 | `SleepAnalysis` | 就寝・起床時刻、睡眠ステージ |
| HRV | `HeartRateVariabilitySDNN` | 自律神経評価 |
| 歩数 | `StepCount` | 活動量評価 |
| 消費カロリー | `ActiveEnergyBurned` | 運動時間算出 |

---

## タスク詳細

### 8.1 パッケージ導入

#### 8.1.1 インストール

```bash
cd app
pnpm add react-native-health
```

#### 8.1.2 app.json 設定

```json
{
  "expo": {
    "ios": {
      "bundleIdentifier": "com.tempoai.app",
      "infoPlist": {
        "NSHealthShareUsageDescription": "睡眠データや心拍変動を分析して、あなたのコンディションを把握します",
        "NSHealthUpdateUsageDescription": "健康データを記録します"
      }
    },
    "plugins": [
      "expo-router",
      "expo-secure-store",
      "expo-location",
      [
        "react-native-health",
        {
          "isClinicalDataEnabled": false
        }
      ]
    ]
  }
}
```

#### 8.1.3 HealthKit Entitlement

EAS Build 時に自動的に追加されるが、明示的に設定する場合:

```json
// app.json の ios セクション
{
  "ios": {
    "entitlements": {
      "com.apple.developer.healthkit": true,
      "com.apple.developer.healthkit.access": []
    }
  }
}
```

---

### 8.2 EAS Build 設定

#### 8.2.1 EAS CLI インストール

```bash
pnpm add -g eas-cli
```

#### 8.2.2 EAS ログイン

```bash
eas login
```

#### 8.2.3 プロジェクト設定

```bash
cd app
eas build:configure
```

#### 8.2.4 eas.json 作成

```json
{
  "cli": {
    "version": ">= 5.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": false
      }
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": false
      }
    },
    "production": {
      "ios": {
        "simulator": false
      }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your-apple-id@example.com",
        "ascAppId": "your-app-store-connect-app-id"
      }
    }
  }
}
```

#### 8.2.5 Apple Developer 連携

```bash
# Apple Developer アカウントとの連携
eas credentials

# iOS Distribution Certificate の作成
# Provisioning Profile の作成
```

---

### 8.3 HealthKit Repository 実装

#### 8.3.1 型定義

```typescript
// app/src/infrastructure/healthkit/types.ts
export interface HealthKitConfig {
  permissions: {
    read: HealthKitPermission[]
    write: HealthKitPermission[]
  }
}

export type HealthKitPermission =
  | 'SleepAnalysis'
  | 'HeartRateVariabilitySDNN'
  | 'StepCount'
  | 'ActiveEnergyBurned'
  | 'HeartRate'
  | 'DistanceWalkingRunning'

export interface SleepSample {
  startDate: Date
  endDate: Date
  value: 'INBED' | 'ASLEEP' | 'AWAKE' | 'CORE' | 'DEEP' | 'REM'
}

export interface HRVSample {
  startDate: Date
  endDate: Date
  value: number // ms
}

export interface StepSample {
  startDate: Date
  endDate: Date
  value: number
}
```

#### 8.3.2 HealthKit Repository 実装

```typescript
// app/src/infrastructure/healthkit/HealthKitRepository.ts
import AppleHealthKit, {
  HealthKitPermissions,
  HealthValue,
} from 'react-native-health'
import {
  HealthRepository,
  HealthAuthorizationStatus,
} from '../HealthRepository'
import {
  HealthMetrics,
  SleepMetrics,
  HRVMetrics,
  ActivityMetrics,
} from '@/domain/models/healthMetrics'

const PERMISSIONS: HealthKitPermissions = {
  permissions: {
    read: [
      AppleHealthKit.Constants.Permissions.SleepAnalysis,
      AppleHealthKit.Constants.Permissions.HeartRateVariabilitySDNN,
      AppleHealthKit.Constants.Permissions.StepCount,
      AppleHealthKit.Constants.Permissions.ActiveEnergyBurned,
    ],
    write: [],
  },
}

export class HealthKitRepository implements HealthRepository {
  private isInitialized = false

  async isAvailable(): Promise<boolean> {
    return new Promise((resolve) => {
      AppleHealthKit.isAvailable((error, available) => {
        resolve(!error && available)
      })
    })
  }

  async getAuthorizationStatus(): Promise<HealthAuthorizationStatus> {
    const available = await this.isAvailable()
    if (!available) return 'unavailable'

    // HealthKit の場合、個別の権限状態は取得できないため、
    // 初期化されているかどうかで判断
    return this.isInitialized ? 'authorized' : 'notDetermined'
  }

  async requestAuthorization(): Promise<boolean> {
    return new Promise((resolve) => {
      AppleHealthKit.initHealthKit(PERMISSIONS, (error) => {
        if (error) {
          console.error('HealthKit initialization error:', error)
          resolve(false)
          return
        }
        this.isInitialized = true
        resolve(true)
      })
    })
  }

  async fetchTodayMetrics(): Promise<HealthMetrics> {
    const today = new Date()
    const [sleep, hrv, activity] = await Promise.all([
      this.fetchSleepMetrics(today),
      this.fetchHRVMetrics(today),
      this.fetchActivityMetrics(today),
    ])

    return {
      date: today,
      sleep: sleep || undefined,
      hrv: hrv || undefined,
      activity: activity || undefined,
    }
  }

  async fetchSleepMetrics(date: Date): Promise<SleepMetrics | null> {
    const startDate = new Date(date)
    startDate.setDate(startDate.getDate() - 1)
    startDate.setHours(18, 0, 0, 0) // 前日18時から

    const endDate = new Date(date)
    endDate.setHours(12, 0, 0, 0) // 当日12時まで

    return new Promise((resolve) => {
      AppleHealthKit.getSleepSamples(
        {
          startDate: startDate.toISOString(),
          endDate: endDate.toISOString(),
        },
        (error, results) => {
          if (error || !results || results.length === 0) {
            resolve(null)
            return
          }

          // 睡眠データを解析
          const sleepMetrics = this.parseSleepSamples(results)
          resolve(sleepMetrics)
        }
      )
    })
  }

  private parseSleepSamples(samples: HealthValue[]): SleepMetrics | null {
    if (samples.length === 0) return null

    // 睡眠セッションを特定（INBED または ASLEEP の最初と最後）
    const sortedSamples = samples
      .filter((s) => s.value === 'INBED' || s.value === 'ASLEEP')
      .sort(
        (a, b) =>
          new Date(a.startDate).getTime() - new Date(b.startDate).getTime()
      )

    if (sortedSamples.length === 0) return null

    const bedtime = new Date(sortedSamples[0].startDate)
    const wakeTime = new Date(sortedSamples[sortedSamples.length - 1].endDate)
    const durationMinutes = Math.round(
      (wakeTime.getTime() - bedtime.getTime()) / (1000 * 60)
    )

    // 深い睡眠とREM睡眠を計算
    let deepSleepMinutes = 0
    let remSleepMinutes = 0

    for (const sample of samples) {
      const duration = Math.round(
        (new Date(sample.endDate).getTime() -
          new Date(sample.startDate).getTime()) /
          (1000 * 60)
      )

      if (sample.value === 'DEEP') {
        deepSleepMinutes += duration
      } else if (sample.value === 'REM') {
        remSleepMinutes += duration
      }
    }

    return {
      bedtime,
      wakeTime,
      durationMinutes,
      deepSleepMinutes,
      remSleepMinutes,
    }
  }

  async fetchHRVMetrics(date: Date): Promise<HRVMetrics | null> {
    const startDate = new Date(date)
    startDate.setHours(0, 0, 0, 0)

    const endDate = new Date(date)
    endDate.setHours(23, 59, 59, 999)

    return new Promise((resolve) => {
      AppleHealthKit.getHeartRateVariabilitySamples(
        {
          startDate: startDate.toISOString(),
          endDate: endDate.toISOString(),
          ascending: false,
          limit: 10,
        },
        (error, results) => {
          if (error || !results || results.length === 0) {
            resolve(null)
            return
          }

          // 最新の HRV 値を使用
          const latestHRV = results[0].value

          // TODO: 30日平均は別途計算が必要
          // 現時点では最新値と同じにする（キャリブレーション期間後に更新）
          resolve({
            value: Math.round(latestHRV),
            baseline30d: Math.round(latestHRV),
          })
        }
      )
    })
  }

  async fetchActivityMetrics(date: Date): Promise<ActivityMetrics | null> {
    const yesterday = new Date(date)
    yesterday.setDate(yesterday.getDate() - 1)
    yesterday.setHours(0, 0, 0, 0)

    const yesterdayEnd = new Date(date)
    yesterdayEnd.setDate(yesterdayEnd.getDate() - 1)
    yesterdayEnd.setHours(23, 59, 59, 999)

    const [steps, activeEnergy] = await Promise.all([
      this.fetchSteps(yesterday, yesterdayEnd),
      this.fetchActiveEnergy(yesterday, yesterdayEnd),
    ])

    if (steps === null && activeEnergy === null) {
      return null
    }

    // 活動カロリーから運動時間を概算（100kcal = 約10分の中強度運動）
    const activeMinutes = Math.round((activeEnergy || 0) / 10)

    return {
      stepsYesterday: steps || 0,
      activeMinutesYesterday: activeMinutes,
    }
  }

  private fetchSteps(startDate: Date, endDate: Date): Promise<number | null> {
    return new Promise((resolve) => {
      AppleHealthKit.getStepCount(
        {
          startDate: startDate.toISOString(),
          endDate: endDate.toISOString(),
        },
        (error, results) => {
          if (error || !results) {
            resolve(null)
            return
          }
          resolve(Math.round(results.value))
        }
      )
    })
  }

  private fetchActiveEnergy(
    startDate: Date,
    endDate: Date
  ): Promise<number | null> {
    return new Promise((resolve) => {
      AppleHealthKit.getActiveEnergyBurned(
        {
          startDate: startDate.toISOString(),
          endDate: endDate.toISOString(),
        },
        (error, results) => {
          if (error || !results || results.length === 0) {
            resolve(null)
            return
          }

          const totalEnergy = results.reduce(
            (sum, r) => sum + (r.value || 0),
            0
          )
          resolve(Math.round(totalEnergy))
        }
      )
    })
  }

  async fetchSleepHistory(days: number): Promise<SleepMetrics[]> {
    const history: SleepMetrics[] = []

    for (let i = 0; i < days; i++) {
      const date = new Date()
      date.setDate(date.getDate() - i)
      const sleep = await this.fetchSleepMetrics(date)
      if (sleep) {
        history.push(sleep)
      }
    }

    return history
  }
}

// シングルトンインスタンス
export const healthKitRepository = new HealthKitRepository()
```

---

### 8.4 Repository 切り替え

#### 8.4.1 環境判定

```typescript
// app/src/infrastructure/index.ts
import { Platform } from 'react-native'
import { HealthRepository } from './HealthRepository'
import { mockHealthRepository } from './MockHealthRepository'

// HealthKit Repository は動的インポート（iOS のみ）
let healthKitRepository: HealthRepository | null = null

export const getHealthRepository = async (): Promise<HealthRepository> => {
  // 開発モードではモックを使用（__DEV__ で判定）
  if (__DEV__) {
    console.log('Using Mock Health Repository (development mode)')
    return mockHealthRepository
  }

  // iOS の場合は HealthKit を使用
  if (Platform.OS === 'ios') {
    if (!healthKitRepository) {
      const { healthKitRepository: hkRepo } = await import(
        './healthkit/HealthKitRepository'
      )
      healthKitRepository = hkRepo
    }
    return healthKitRepository
  }

  // Android や Web の場合はモック（将来的に Health Connect 対応）
  console.log('Using Mock Health Repository (non-iOS platform)')
  return mockHealthRepository
}
```

#### 8.4.2 healthStore での使用

```typescript
// app/src/stores/healthStore.ts
import { getHealthRepository } from '@/infrastructure'

interface HealthState {
  // ... 既存のプロパティ

  // Repository
  initializeHealthRepository: () => Promise<void>
  healthRepositoryReady: boolean
}

export const useHealthStore = create<HealthState>()(
  persist(
    (set, get) => ({
      // ... 既存の実装

      healthRepositoryReady: false,

      initializeHealthRepository: async () => {
        const repository = await getHealthRepository()
        const authorized = await repository.requestAuthorization()

        set({ healthRepositoryReady: authorized })

        if (authorized) {
          // 初回データ取得
          await get().fetchTodayMetrics()
        }
      },

      fetchTodayMetrics: async () => {
        set({ isLoadingMetrics: true, metricsError: null })

        try {
          const repository = await getHealthRepository()
          const metrics = await repository.fetchTodayMetrics()

          set({
            sleepMetrics: metrics.sleep || null,
            hrvMetrics: metrics.hrv || null,
            activityMetrics: metrics.activity || null,
            lastMetricsUpdate: new Date(),
            isLoadingMetrics: false,
          })

          // スコア計算
          get().calculateScores()
        } catch (error) {
          const message =
            error instanceof Error ? error.message : 'Unknown error'
          set({
            metricsError: message,
            isLoadingMetrics: false,
          })
        }
      },
    }),
    {
      name: 'health-storage',
      // ...
    }
  )
)
```

---

### 8.5 オンボーディング連携

#### 8.5.1 HealthKit 画面の更新

```typescript
// app/app/(onboarding)/healthkit.tsx
import { useHealthStore } from '@/stores/healthStore'

export default function HealthKitScreen(): JSX.Element {
  const router = useRouter()
  const initializeHealthRepository = useHealthStore(
    (s) => s.initializeHealthRepository
  )
  const [isRequesting, setIsRequesting] = useState(false)

  const handleAllowPress = async (): Promise<void> => {
    setIsRequesting(true)

    try {
      await initializeHealthRepository()
      router.push('/onboarding/nickname')
    } catch (error) {
      console.error('HealthKit authorization error:', error)
      // エラーでも次へ進める（後で設定可能）
      router.push('/onboarding/nickname')
    } finally {
      setIsRequesting(false)
    }
  }

  const handleLaterPress = (): void => {
    // HealthKit をスキップして次へ
    router.push('/onboarding/nickname')
  }

  return (
    <SafeAreaView style={styles.container}>
      {/* ... UI */}
      <PrimaryButton
        title={isRequesting ? '設定中...' : '許可する'}
        onPress={handleAllowPress}
        disabled={isRequesting}
      />
      <SecondaryButton title="あとで設定" onPress={handleLaterPress} />
    </SafeAreaView>
  )
}
```

---

### 8.6 Development Build 作成

#### 8.6.1 ビルド実行

```bash
cd app
eas build --profile development --platform ios
```

**所要時間**: 10-20分（初回は証明書作成を含む）

#### 8.6.2 実機インストール

ビルド完了後:
1. EAS からダウンロードリンク取得
2. iPhone で QR コードをスキャン
3. プロファイルをインストール
4. アプリをインストール

#### 8.6.3 動作確認

1. アプリを起動
2. オンボーディングで HealthKit 許可をリクエスト
3. システムダイアログで許可
4. ホーム画面で実データが表示されることを確認

---

## チェックリスト

### パッケージ導入

- [ ] `react-native-health` インストール
- [ ] `app.json` に HealthKit 設定追加
- [ ] 必要な権限説明を設定

### EAS Build

- [ ] `eas-cli` インストール
- [ ] `eas login` でログイン
- [ ] `eas.json` 作成
- [ ] Apple Developer 連携設定
- [ ] 証明書・プロビジョニングプロファイル作成

### HealthKit Repository

- [ ] 型定義作成
- [ ] `HealthKitRepository` クラス実装
- [ ] 睡眠データ取得実装
- [ ] HRV データ取得実装
- [ ] 活動データ取得実装

### 統合

- [ ] Repository 切り替えロジック実装
- [ ] `healthStore` での使用
- [ ] オンボーディング画面更新

### テスト

- [ ] Development Build 作成
- [ ] 実機インストール
- [ ] HealthKit 権限リクエスト確認
- [ ] 各種データ取得確認

---

## トラブルシューティング

### HealthKit が利用できない

- **原因**: Simulator で実行している
- **解決**: 実機で Development Build を使用

### 権限ダイアログが表示されない

- **原因**: `infoPlist` の設定不足
- **解決**: `NSHealthShareUsageDescription` を確認

### データが取得できない

- **原因**: HealthKit にデータがない
- **解決**: ヘルスケアアプリでデータを手動入力してテスト

### ビルドエラー

- **原因**: 証明書・プロファイルの問題
- **解決**: `eas credentials` で再設定

---

## 完了条件

1. Development Build が実機にインストールできる
2. HealthKit 権限リクエストダイアログが表示される
3. 許可後、睡眠・HRV・活動データが取得できる
4. ホーム画面に実データが表示される

---

## 次のフェーズへ

Phase 8 完了後、Phase 9（リリース準備）に進む。

Production Build を作成し、TestFlight 経由で App Store に申請。
