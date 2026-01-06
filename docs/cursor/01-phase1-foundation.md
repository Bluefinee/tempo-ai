# Phase 1: 基盤整備

## 目的

- i18n基盤の構築（将来の英語対応準備）
- デザインシステムの更新（新UIカラーパレット）

---

## 開始前に読むべきドキュメント

**必ず以下のドキュメントを全て読んでから実装を開始すること:**

| ドキュメント | パス | 確認ポイント |
|-------------|------|-------------|
| CLAUDE.md | `/CLAUDE.md` | TypeScript規約、コメントポリシー、エラーハンドリング |
| React Native規約 | `/.claude/react-native-standards.md` | ファイル命名、コンポーネント設計、スタイル定義 |
| UI/UX仕様 | `/docs/specs/ui_ux_design.md` | カラーパレット、タイポグラフィ、スペーシング |
| i18n設計 | `/docs/specs/i18n_design.md` | 翻訳キー命名規則、実装ガイドライン |

---

## Task 1.1: i18n基盤構築

### 依存パッケージ追加

```bash
cd app
pnpm add expo-localization i18n-js
```

### ファイル作成

#### `app/src/i18n/index.ts`

```typescript
import { getLocales } from 'expo-localization';
import { I18n } from 'i18n-js';
import ja from './locales/ja.json';

const i18n = new I18n({ ja });

// デバイスロケール取得
const deviceLocale = getLocales()[0]?.languageCode ?? 'ja';

// 日本語のみサポート（将来英語追加）
i18n.locale = deviceLocale === 'ja' ? 'ja' : 'ja';
i18n.defaultLocale = 'ja';
i18n.enableFallback = true;

export const t = (key: string, options?: Record<string, unknown>): string => {
  return i18n.t(key, options);
};

export const setLocale = (locale: string): void => {
  i18n.locale = locale;
};

export const getLocale = (): string => {
  return i18n.locale;
};

export default i18n;
```

#### `app/src/i18n/locales/ja.json`

```json
{
  "common": {
    "button": {
      "save": "保存",
      "cancel": "キャンセル",
      "continue": "続ける",
      "start": "始める",
      "close": "閉じる"
    },
    "loading": "読み込み中...",
    "error": "エラーが発生しました"
  },
  "screen": {
    "today": {
      "greeting": {
        "morning": "おはようございます",
        "afternoon": "こんにちは",
        "evening": "こんばんは",
        "night": "お疲れ様です"
      },
      "tempoScore": "TEMPO SCORE",
      "todayOneThing": "TODAY'S ONE THING",
      "relatedInsight": "Related Insight",
      "metrics": {
        "sleep": "Sleep",
        "hrv": "HRV",
        "steps": "Steps"
      }
    },
    "rhythm": {
      "title": "Your Rhythm",
      "subtitle": "Synchronize with your natural energy",
      "upcomingWindows": "UPCOMING WINDOWS",
      "phases": {
        "wakeWindow": "Wake Window",
        "peakFocus": "Peak Focus",
        "afternoonDip": "Afternoon Dip",
        "secondWind": "Second Wind",
        "windDown": "Wind Down",
        "melatoninWindow": "Melatonin Window"
      },
      "sunrise": "Sunrise",
      "sunset": "Sunset"
    },
    "breathe": {
      "title": "Breathe",
      "inhale": "吸う",
      "hold": "止める",
      "exhale": "吐く",
      "tapToStart": "タップして開始"
    },
    "insights": {
      "title": "Insights",
      "subtitle": "Patterns discovered in your data.",
      "weeklyAverage": "Avg Score",
      "topDiscovery": "TOP DISCOVERY",
      "recentAlerts": "RECENT ALERTS"
    },
    "settings": {
      "title": "Settings",
      "subtitle": "Personalize your rhythm.",
      "profile": "Profile",
      "myRhythm": "MY RHYTHM",
      "targetBedtime": "Target Bedtime",
      "targetWakeUp": "Target Wake Up",
      "preferences": "PREFERENCES",
      "gentleNudges": "Gentle Nudges",
      "hapticFeedback": "Haptic Feedback",
      "dataSource": "DATA SOURCE",
      "appleHealth": "Apple Health",
      "ouraRing": "Oura Ring",
      "connected": "Connected",
      "connect": "Connect",
      "support": "SUPPORT",
      "helpCenter": "Help Center",
      "privacyPolicy": "Privacy Policy",
      "resetOnboarding": "Reset Onboarding",
      "signOut": "Sign Out",
      "version": "Version"
    }
  },
  "metric": {
    "sleep": {
      "label": "Sleep",
      "deepSleep": "Deep Sleep",
      "remSleep": "REM",
      "awake": "Awake"
    },
    "hrv": {
      "label": "HRV",
      "unit": "ms",
      "maxHrv": "Max HRV",
      "restingHr": "Resting HR",
      "readiness": "Readiness"
    },
    "steps": {
      "label": "Steps",
      "distance": "Distance",
      "calories": "Calories",
      "flights": "Flights"
    },
    "status": {
      "excellent": "Excellent",
      "good": "Good",
      "normal": "Normal",
      "needsAttention": "Needs Attention"
    }
  },
  "alert": {
    "recoveryNeeded": "Recovery Needed",
    "recoveryComplete": "Recovery Complete",
    "sleepDeficit": "Sleep Deficit",
    "lateBedtime": "Late Bedtime",
    "weekendJetlag": "Weekend Jetlag",
    "lowActivity": "Low Activity"
  },
  "error": {
    "network": "ネットワークエラーが発生しました",
    "api": "データの取得に失敗しました",
    "retry": "再試行"
  }
}
```

---

## Task 1.2: デザインシステム更新

### `app/src/theme/colors.ts` を更新

```typescript
/**
 * TempoAI カラーパレット
 * @see docs/specs/ui_ux_design.md
 */
export const Colors = {
  // Primary - Soft Indigo
  indigo: {
    50: '#EEF2FF',
    100: '#E0E7FF',
    200: '#C7D2FE',
    300: '#A5B4FC',
    400: '#818CF8',
    500: '#6366F1',  // メインカラー
    600: '#4F46E5',
    700: '#4338CA',
    800: '#3730A3',
    900: '#312E81',
  },

  // Accent - Warm Amber (Steps, Energy)
  amber: {
    50: '#FFFBEB',
    100: '#FEF3C7',
    400: '#FBBF24',
    500: '#F59E0B',  // メインアクセント
    600: '#D97706',
  },

  // Accent - Soft Coral (HRV)
  coral: {
    50: '#FFF1F2',
    100: '#FFE4E6',
    400: '#FB7185',  // メインアクセント
    500: '#F43F5E',
    600: '#E11D48',
  },

  // Positive - Emerald
  emerald: {
    50: '#ECFDF5',
    100: '#D1FAE5',
    400: '#34D399',
    500: '#10B981',  // 成功・ポジティブ
    600: '#059669',
  },

  // Background
  offWhite: '#FAFAF9',
  deepNavy: '#0F172A',  // Breathe画面背景

  // Neutral - Stone
  stone: {
    50: '#FAFAF9',
    100: '#F5F5F4',
    200: '#E7E5E3',
    300: '#D6D3D1',
    400: '#A8A29E',
    500: '#78716C',
    600: '#57534E',
    700: '#44403C',
    800: '#292524',
    900: '#1C1917',
  },

  // Semantic
  white: '#FFFFFF',
  black: '#000000',
  transparent: 'transparent',
} as const;

// メトリクス別カラーマッピング
export const MetricColors = {
  sleep: Colors.indigo[500],
  hrv: Colors.coral[400],
  steps: Colors.amber[500],
} as const;

export type ColorKey = keyof typeof Colors;
```

### `app/src/theme/shadows.ts` を新規作成

```typescript
import { Platform, ViewStyle } from 'react-native';

/**
 * シャドウ定義
 * @see docs/specs/ui_ux_design.md
 */
export const Shadows = {
  // カード用シャドウ
  card: Platform.select<ViewStyle>({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 4 },
      shadowOpacity: 0.06,
      shadowRadius: 12,
    },
    android: {
      elevation: 4,
    },
  }) ?? {},

  // ボトムシート用シャドウ
  bottomSheet: Platform.select<ViewStyle>({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: -4 },
      shadowOpacity: 0.1,
      shadowRadius: 24,
    },
    android: {
      elevation: 16,
    },
  }) ?? {},

  // ボタン用シャドウ
  button: Platform.select<ViewStyle>({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.08,
      shadowRadius: 8,
    },
    android: {
      elevation: 2,
    },
  }) ?? {},

  // なし
  none: {} as ViewStyle,
} as const;

export type ShadowKey = keyof typeof Shadows;
```

### `app/src/theme/animations.ts` を新規作成

```typescript
/**
 * アニメーション定義
 * @see docs/specs/ui_ux_design.md
 */
export const Animations = {
  // デュレーション
  duration: {
    fast: 150,
    normal: 300,
    slow: 500,
    wave: 4000,       // Tempo Score波
    breatheIn: 4000,  // 4-7-8呼吸法: 吸う
    breatheHold: 7000,// 4-7-8呼吸法: 止める
    breatheOut: 8000, // 4-7-8呼吸法: 吐く
  },

  // イージング
  easing: {
    default: 'ease-in-out',
    spring: 'spring',
  },

  // 画面遷移
  transition: {
    duration: 300,
  },

  // ボトムシート
  bottomSheet: {
    duration: 350,
  },
} as const;
```

### `app/src/theme/spacing.ts` を更新

```typescript
/**
 * スペーシング定義（8pxグリッド）
 * @see docs/specs/ui_ux_design.md
 */
export const Spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
} as const;

/**
 * 角丸定義
 */
export const BorderRadius = {
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  full: 9999,
} as const;

export type SpacingKey = keyof typeof Spacing;
export type BorderRadiusKey = keyof typeof BorderRadius;
```

### `app/src/theme/typography.ts` を更新

```typescript
import { TextStyle, Platform } from 'react-native';

/**
 * タイポグラフィ定義
 * @see docs/specs/ui_ux_design.md
 */

const fontFamily = Platform.select({
  ios: 'System',
  android: 'Roboto',
});

export const Typography = {
  // 大見出し - 32px Bold
  heading1: {
    fontFamily,
    fontSize: 32,
    fontWeight: '700',
    lineHeight: 40,
  } as TextStyle,

  // 見出し - 24px Semibold
  heading2: {
    fontFamily,
    fontSize: 24,
    fontWeight: '600',
    lineHeight: 32,
  } as TextStyle,

  // 小見出し - 20px Semibold
  heading3: {
    fontFamily,
    fontSize: 20,
    fontWeight: '600',
    lineHeight: 28,
  } as TextStyle,

  // 本文 - 16px Regular
  body: {
    fontFamily,
    fontSize: 16,
    fontWeight: '400',
    lineHeight: 24,
  } as TextStyle,

  // 本文（強調） - 16px Medium
  bodyMedium: {
    fontFamily,
    fontSize: 16,
    fontWeight: '500',
    lineHeight: 24,
  } as TextStyle,

  // キャプション - 14px Regular
  caption: {
    fontFamily,
    fontSize: 14,
    fontWeight: '400',
    lineHeight: 20,
  } as TextStyle,

  // ラベル - 12px Medium
  label: {
    fontFamily,
    fontSize: 12,
    fontWeight: '500',
    lineHeight: 16,
    letterSpacing: 0.5,
  } as TextStyle,

  // 数値（大） - 72px Bold
  scoreXL: {
    fontFamily,
    fontSize: 72,
    fontWeight: '700',
    lineHeight: 80,
  } as TextStyle,

  // 数値（中） - 48px Bold
  scoreLG: {
    fontFamily,
    fontSize: 48,
    fontWeight: '700',
    lineHeight: 56,
  } as TextStyle,

  // 数値（小） - 32px Bold
  scoreMD: {
    fontFamily,
    fontSize: 32,
    fontWeight: '700',
    lineHeight: 40,
  } as TextStyle,
} as const;

export type TypographyKey = keyof typeof Typography;
```

### `app/src/theme/index.ts` を更新

```typescript
export * from './colors';
export * from './spacing';
export * from './typography';
export * from './shadows';
export * from './animations';
```

---

## Phase 1 完了時の検証

### 必須コマンド（全てパスすること）

```bash
cd app

# 1. 型チェック
pnpm typecheck

# 2. リント
pnpm lint

# 3. ビルド確認（iOS）
pnpm ios --no-dev

# 4. ビルド確認（Android）
pnpm android --no-dev
```

### 完了チェックリスト

- [ ] `expo-localization` と `i18n-js` がインストールされている
- [ ] `app/src/i18n/index.ts` が作成されている
- [ ] `app/src/i18n/locales/ja.json` が作成されている
- [ ] `app/src/theme/colors.ts` が更新されている
- [ ] `app/src/theme/shadows.ts` が新規作成されている
- [ ] `app/src/theme/animations.ts` が新規作成されている
- [ ] `app/src/theme/spacing.ts` が更新されている
- [ ] `app/src/theme/typography.ts` が更新されている
- [ ] `app/src/theme/index.ts` が更新されている
- [ ] **`pnpm typecheck` でエラーなし**
- [ ] **`pnpm lint` でエラーなし**
- [ ] **iOS ビルドが成功する**
- [ ] **Android ビルドが成功する**

---

## 次のフェーズ

Phase 1 の全てのチェックが完了したら、`02-phase2-domain.md` に進む。
