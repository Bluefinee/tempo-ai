# 多言語対応設計書

**バージョン**: 1.0  
**最終更新日**: 2026年1月6日

---

## 1. 概要

TempoAIは日本語をデフォルトとし、将来的に英語対応を予定。

### 1.1 対応言語

| 言語 | ロケール | 優先度 | 状態 |
|------|---------|--------|------|
| 日本語 | `ja` | デフォルト | 実装中 |
| 英語 | `en` | 高 | 将来対応 |

### 1.2 基本方針

- **日本語ファースト**: 初期リリースは日本市場向け
- **多言語対応を見据えた設計**: 文字列の外部化を徹底
- **段階的な対応**: MVP後に英語対応を追加

---

## 2. 技術選定

### 2.1 React Native (Expo)

**推奨**: `expo-localization` + `i18n-js`

| ライブラリ | 用途 |
|-----------|------|
| expo-localization | デバイスロケール取得 |
| i18n-js | 翻訳管理 |

### 2.2 ディレクトリ構造

```
app/
├── src/
│   ├── i18n/
│   │   ├── index.ts           # i18n設定
│   │   └── locales/
│   │       ├── ja.json        # 日本語
│   │       └── en.json        # 英語（将来）
│   └── ...
```

---

## 3. 翻訳キー命名規則

### 3.1 基本ルール

```
{画面/コンポーネント}.{セクション}.{要素}
```

### 3.2 カテゴリ別プレフィックス

| カテゴリ | プレフィックス | 例 |
|---------|--------------|-----|
| 共通 | `common.` | `common.button.save` |
| 画面 | `screen.{name}.` | `screen.today.greeting` |
| コンポーネント | `component.{name}.` | `component.metricCard.sleep` |
| エラー | `error.` | `error.network` |

### 3.3 サンプル

```json
// locales/ja.json
{
  "common": {
    "button": {
      "save": "保存",
      "cancel": "キャンセル"
    },
    "loading": "読み込み中..."
  },
  "screen": {
    "today": {
      "greeting": {
        "morning": "おはようございます",
        "afternoon": "こんにちは",
        "evening": "こんばんは"
      },
      "tempoScore": "TEMPO SCORE",
      "todayOneThing": "TODAY'S ONE THING"
    },
    "rhythm": {
      "title": "Your Rhythm",
      "subtitle": "Synchronize with your natural energy",
      "upcomingWindows": "UPCOMING WINDOWS",
      "phases": {
        "peakFocus": "Peak Focus",
        "afternoonDip": "Afternoon Dip",
        "secondWind": "Second Wind",
        "windDown": "Wind Down"
      }
    },
    "breathe": {
      "inhale": "吸う",
      "hold": "止める",
      "exhale": "吐く"
    },
    "insights": {
      "title": "Insights",
      "subtitle": "Patterns discovered in your data.",
      "topDiscovery": "TOP DISCOVERY",
      "recentAlerts": "RECENT ALERTS"
    },
    "settings": {
      "title": "Settings",
      "subtitle": "Personalize your rhythm.",
      "targetBedtime": "Target Bedtime",
      "targetWakeUp": "Target Wake Up"
    }
  },
  "onboarding": {
    "welcome": {
      "tagline": "Find your rhythm.",
      "cta": "Get Started"
    },
    "goals": {
      "title": "What brings you here?",
      "subtitle": "Select all that apply.",
      "betterSleep": "Better Sleep",
      "moreEnergy": "More Energy",
      "lessStress": "Less Stress",
      "peakPerformance": "Peak Performance"
    },
    "schedule": {
      "title": "Set your rhythm.",
      "wakeUp": "Wake up",
      "windDown": "Wind down",
      "note": "You can change this later."
    },
    "healthConnect": {
      "title": "Connect your data.",
      "description": "TempoAI uses these to understand your rhythm:",
      "privacy": "Your data stays on your device.",
      "cta": "Connect Apple Health",
      "skip": "Skip for now"
    },
    "ready": {
      "title": "You're all set.",
      "description": "TempoAI will learn your personal baseline over the next 7 days.",
      "cta": "Begin"
    }
  },
  "metric": {
    "sleep": "Sleep",
    "hrv": "HRV",
    "steps": "Steps"
  },
  "error": {
    "network": "ネットワークエラーが発生しました",
    "retry": "再試行"
  }
}
```

---

## 4. 実装ガイドライン

### 4.1 現時点での準備

多言語対応の正式実装前に、文字列の外部化を徹底。

**避けるべき（ハードコード）**:

```tsx
// ❌
<Text>おはようございます</Text>
```

**推奨（定数化）**:

```tsx
// ✅
import { t } from '@/i18n';

<Text>{t('screen.today.greeting.morning')}</Text>
```

### 4.2 日付・数値フォーマット

```tsx
// ❌ 避けるべき
const formatted = `${hours}時間${minutes}分`;

// ✅ 推奨
import { formatDuration } from '@/utils/format';
const formatted = formatDuration(minutes, locale);
```

### 4.3 AIアドバイスの多言語対応

AIアドバイスは生成時に言語を指定。

```xml
<context>
  <locale>ja</locale>
</context>
```

System Promptに言語指示を追加:

```xml
<language>
出力言語: 日本語
- message.title は英語（詩的なタイトル）
- message.body は日本語
- todayOneThing.text は日本語
- metricInsights は日本語
</language>
```

---

## 5. 実装スケジュール

| フェーズ | 内容 | 時期 |
|---------|------|------|
| MVP | 日本語のみ、文字列外部化 | 現在 |
| Phase 2 | i18n-js導入、日本語完成 | MVP後 |
| Phase 3 | 英語翻訳追加 | グローバル展開時 |

---

## 6. チェックリスト

### 6.1 MVP完了条件

- [ ] 全てのハードコード文字列を定数化
- [ ] 日付・数値フォーマットユーティリティ作成
- [ ] AIアドバイスの言語指定対応

### 6.2 多言語対応実装時

- [ ] expo-localization導入
- [ ] i18n-js導入
- [ ] 翻訳ファイル（ja.json, en.json）作成
- [ ] 言語切替UI（Settings画面）
- [ ] AIプロンプトの言語切替対応

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2026-01-06 | 新規作成 |
