# TempoAI UI/Backend Migration Plan

**作成日**: 2026年1月6日
**ステータス**: 計画中

---

## 概要

新UIデザイン（`sozai/new/`）と新仕様書（`docs/specs/`）に基づき、TempoAIアプリのUI全面刷新とバックエンドの更新を行う。

### 変更範囲

| 対象 | 変更内容 |
|------|---------|
| フロントエンド (`/app`) | 3タブ → 5タブ構成、新コンポーネント、新画面実装 |
| バックエンド (`/backend`) | APIリクエスト/レスポンス形式の更新 |
| オンボーディング | **変更なし**（現在の9ステップを維持） |
| インフラ | **変更なし**（Cloudflare Workers設定、package.json構造） |

### 参照ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| `sozai/new/` | 新UIプロトタイプ（React/Vite） |
| `docs/specs/product_spec.md` | プロダクト仕様 |
| `docs/specs/technical_spec.md` | 技術仕様（API設計） |
| `docs/specs/metrics_spec.md` | Tempo Score算出ロジック |
| `docs/specs/ai_prompt_spec.md` | AIプロンプト仕様 |
| `docs/specs/ui_ux_design.md` | UI/UX設計詳細 |
| `docs/specs/i18n_design.md` | 多言語対応設計 |

---

## Phase 1: 基盤整備

### 1.1 i18n基盤構築

**目的**: 将来の英語対応に備え、文字列の外部化を徹底

**新規ファイル**:
```
app/src/i18n/
├── index.ts           # i18n設定
└── locales/
    └── ja.json        # 日本語翻訳ファイル
```

**依存パッケージ追加**:
```bash
pnpm add expo-localization i18n-js
```

**翻訳キー命名規則** (i18n_design.md準拠):
```
{画面/コンポーネント}.{セクション}.{要素}
例: screen.today.greeting.morning
```

### 1.2 デザインシステム更新

**ファイル**: `app/src/theme/colors.ts`

```typescript
// 新カラーパレット（ui_ux_design.md準拠）
export const colors = {
  // Primary
  indigo: {
    50: '#EEF2FF',
    500: '#6366F1',  // メイン
    600: '#4F46E5',
    900: '#312E81',
  },
  // Accent
  amber: '#F59E0B',    // Steps、Energy
  coral: '#FB7185',    // HRV
  emerald: '#10B981',  // Positive

  // Background
  offWhite: '#FAFAF9',
  deepNavy: '#0F172A',  // Breathe画面

  // Neutral
  stone: {
    50: '#FAFAF9',
    100: '#F5F5F4',
    500: '#78716C',
    700: '#44403C',
    900: '#1C1917',
  },
};
```

**新規ファイル**:
| ファイル | 内容 |
|---------|------|
| `app/src/theme/shadows.ts` | シャドウ定義（ui_ux_design.md準拠） |
| `app/src/theme/animations.ts` | アニメーション定義 |

### 1.3 Typography更新

**ファイル**: `app/src/theme/typography.ts`

| 用途 | フォント | サイズ |
|------|---------|--------|
| 大見出し | SF Pro Display Bold | 32px |
| 見出し | SF Pro Display Semibold | 24px |
| 本文 | SF Pro Text Regular | 16px |
| 数値 | SF Pro Rounded Bold | 48-72px |

### 1.4 スペーシング・角丸更新

**ファイル**: `app/src/theme/spacing.ts`

8pxグリッドシステム + 角丸定義（ui_ux_design.md準拠）

---

## Phase 2: ドメインモデル・ユーティリティ

### 2.1 新規ドメインモデル

**ファイル**: `app/src/domain/models/rhythm.ts`

```typescript
export interface RhythmPhase {
  name: 'Wake Window' | 'Peak Focus' | 'Afternoon Dip' | 'Second Wind' | 'Wind Down' | 'Melatonin Window';
  start: Date;
  end: Date;
  type: 'high' | 'low' | 'transition' | 'sleep';
  isCurrent: boolean;
}
```

**ファイル**: `app/src/domain/models/insight.ts`

```typescript
export interface Alert {
  id: string;
  type: 'recovery_needed' | 'recovery_complete' | 'sleep_deficit' | 'late_bedtime' | 'weekend_jetlag' | 'low_activity';
  icon: string;
  message: string;
  timestamp: Date;
  priority: 'high' | 'medium' | 'low';
}

export interface WeeklyInsight {
  weeklyScores: number[];
  avgScore: number;
  topDiscovery: {
    title: string;
    description: string;
    impact?: string;
  };
  recentAlerts: Alert[];
}
```

### 2.2 スコア計算サービス

**ファイル**: `app/src/domain/services/tempoScoreCalculator.ts`

Tempo Score算出（metrics_spec.md準拠）:
```
Tempo Score = HRV Score × 0.40
            + Sleep Score × 0.35
            + Rhythm Score × 0.15
            + Activity Score × 0.10
```

### 2.3 Rhythmフェーズ計算サービス

**ファイル**: `app/src/domain/services/rhythmCalculator.ts`

- フェーズ計算（起床時刻ベース）
- エネルギー曲線データ生成（グラフ用）

### 2.4 Alert生成サービス

**ファイル**: `app/src/domain/services/alertGenerator.ts`

アラートトリガー条件（metrics_spec.md準拠）:
| 条件 | アラートタイプ | 優先度 |
|------|--------------|--------|
| HRV < ベースライン-20% | Recovery Needed | 高 |
| HRV > ベースライン+15% | Recovery Complete | 低 |
| 睡眠時間 < 6時間 | Sleep Deficit | 高 |
| 就寝時刻 > 目標+1時間 | Late Bedtime | 中 |

### 2.5 フォーマットユーティリティ

**ファイル**: `app/src/utils/format.ts`

- `formatDuration(minutes, locale)` - 睡眠時間等のフォーマット
- `formatTime(date, locale)` - 時刻フォーマット
- `formatDate(date, locale)` - 日付フォーマット

---

## Phase 3: 新規コンポーネント

### 3.1 WaveScore

**ファイル**: `app/src/components/WaveScore.tsx`

- SVGベースの波アニメーション（`react-native-svg`）
- スコアに応じた水位表示
- 4秒周期のアニメーション

**アクセシビリティ**:
- VoiceOverラベル: "Tempo Score {score}点"

### 3.2 MetricCard

**ファイル**: `app/src/components/MetricCard.tsx`

- メトリクス別カラー（Sleep: Indigo, HRV: Coral, Steps: Amber）
- 最小タップ領域: 44x44px
- Hapticフィードバック（Light）

### 3.3 MetricDetail

**ファイル**: `app/src/components/MetricDetail.tsx`

- 12時間バーグラフ
- AI Tempo Insightテキスト
- サブメトリクス3項目

### 3.4 BottomSheet

**ファイル**: `app/src/components/BottomSheet.tsx`

- `@gorhom/bottom-sheet`使用
- 350ms spring アニメーション

### 3.5 RhythmGraph

**ファイル**: `app/src/components/RhythmGraph.tsx`

- SVGエネルギー曲線
- 現在時刻インジケーター
- フェーズラベル

### 3.6 BreathingCircle

**ファイル**: `app/src/components/BreathingCircle.tsx`

- グロー効果付きアニメーション
- 4-7-8呼吸法タイミング
- Hapticフィードバック（フェーズ変化時: Medium）

### 依存パッケージ追加

```bash
pnpm add @gorhom/bottom-sheet expo-haptics
```

---

## Phase 4: Store更新

### 4.1 healthStore更新

**ファイル**: `app/src/stores/healthStore.ts`

追加:
```typescript
tempoScore: number | null;
circadianPhases: RhythmPhase[];
currentPhase: RhythmPhase | null;

calculateTempoScore: () => void;
calculateCircadianPhases: (wakeUpTime: string, windDownTime: string) => void;
```

### 4.2 insightStore更新

**ファイル**: `app/src/stores/insightStore.ts`

追加（新APIレスポンス形式対応）:
```typescript
aiMessage: { title: string; body: string; } | null;
todayOneThing: { icon: string; text: string; time?: string; } | null;
relatedInsight: { text: string; insightId: string; } | null;
metricInsights: { sleep: string; hrv: string; steps: string; } | null;

weeklyScores: number[];
topDiscovery: { title: string; description: string; } | null;
recentAlerts: Alert[];
```

### 4.3 breatheStore新規作成

**ファイル**: `app/src/stores/breatheStore.ts`

```typescript
interface BreatheState {
  isActive: boolean;
  phase: 'idle' | 'inhale' | 'hold' | 'exhale';
  timeRemaining: number;
  sessionDuration: number;  // デフォルト60秒
}
```

### 4.4 userStore更新

**ファイル**: `app/src/stores/userStore.ts`

追加:
```typescript
goals: string[];         // ["better_sleep", "more_energy"]
wakeUpTime: string;      // "07:00"
windDownTime: string;    // "23:00"
gentleNudges: boolean;
hapticFeedback: boolean;
```

---

## Phase 5: ナビゲーション更新

### 5.1 タブレイアウト

**ファイル**: `app/app/(main)/_layout.tsx`

| タブ | アイコン | 画面 | 備考 |
|------|---------|------|------|
| Today | Home | `index.tsx` | メイン |
| Rhythm | Chart line | `rhythm.tsx` | 新規 |
| Breathe | Wave | `breathe.tsx` | 中央配置、浮き出しデザイン |
| Insights | Lightbulb | `insights.tsx` | 新規 |
| Settings | Gear | `settings.tsx` | 更新 |

### 5.2 新規画面ファイル

| ファイル | 内容 |
|---------|------|
| `app/app/(main)/rhythm.tsx` | Rhythm画面 |
| `app/app/(main)/breathe.tsx` | Breathe画面（フルスクリーンモーダル） |
| `app/app/(main)/insights.tsx` | Insights画面 |

### 5.3 削除ファイル

| ファイル | 理由 |
|---------|------|
| `app/app/(main)/analytics.tsx` | Insightsに置き換え |

---

## Phase 6: 画面実装

### 6.1 Today画面

**ファイル**: `app/app/(main)/index.tsx`

構成:
1. 日付ナビゲーション
2. 時間帯別挨拶（i18n対応）
3. WaveScore
4. AI Messageカード
5. Today's One Thing
6. Metricsグリッド（3列）

### 6.2 Rhythm画面

**ファイル**: `app/app/(main)/rhythm.tsx`

構成:
1. ヘッダー
2. RhythmGraph（SVGエネルギー曲線）
3. フェーズラベル
4. UPCOMING WINDOWSリスト
5. Sunrise/Sunset

### 6.3 Breathe画面

**ファイル**: `app/app/(main)/breathe.tsx`

構成:
1. Deep Navy背景
2. BreathingCircle
3. フェーズ指示テキスト（i18n対応: 吸う/止める/吐く）
4. タイマー
5. 再生/一時停止ボタン

4-7-8呼吸法:
- 吸う: 4秒
- 止める: 7秒
- 吐く: 8秒

### 6.4 Insights画面

**ファイル**: `app/app/(main)/insights.tsx`

構成:
1. 週間スコアバーチャート
2. TOP DISCOVERYカード
3. RECENT ALERTSリスト

### 6.5 Settings画面

**ファイル**: `app/app/(main)/settings.tsx`

構成:
1. Profileセクション
2. MY RHYTHMセクション
3. PREFERENCESセクション
4. DATA SOURCEセクション
5. SUPPORTセクション

---

## Phase 7: バックエンド更新

### 7.1 API型定義更新

**ファイル**: `backend/src/services/advice/types.ts`

リクエスト形式（technical_spec.md準拠）:
```typescript
interface AdviceRequest {
  user: {
    goals: string[];
    wakeUpTime: string;
    windDownTime: string;
  };
  healthMetrics: {
    sleep: { durationMinutes: number; deepSleepMinutes: number; remSleepMinutes: number; };
    hrv: { value: number; baseline30d: number; };
    activity: { steps: number; };
  };
  weather: {
    temperature: number;
    pressure: number;
    pressureTrend: "rising" | "stable" | "falling";
    sunrise: string;
    sunset: string;
  };
}
```

レスポンス形式:
```typescript
interface AdviceResponse {
  tempoScore: number;
  message: { title: string; body: string; };
  todayOneThing: { icon: string; text: string; time?: string; };
  relatedInsight: { text: string; insightId: string; };
  metricInsights: { sleep: string; hrv: string; steps: string; };
}
```

### 7.2 PromptBuilder更新

**ファイル**: `backend/src/services/advice/PromptBuilder.ts`

- 新システムプロンプト（ai_prompt_spec.md準拠）
- 新出力JSON構造
- 言語指定対応（locale: ja）

### 7.3 AnthropicClient更新

**ファイル**: `backend/src/services/advice/AnthropicClient.ts`

- 新レスポンスパース処理
- フォールバックメッセージ対応

### 7.4 テスト更新

| ファイル | 内容 |
|---------|------|
| `backend/src/services/advice/AdviceService.test.ts` | 新形式対応 |
| `backend/src/services/advice/PromptBuilder.test.ts` | 新形式対応 |

---

## Phase 8: フロントエンドAPI連携

### 8.1 API Types更新

**ファイル**: `app/src/api/types.ts`

新リクエスト/レスポンス型定義

### 8.2 API Client更新

**ファイル**: `app/src/api/client.ts`

### 8.3 adviceRequestBuilder更新

**ファイル**: `app/src/api/helpers/adviceRequestBuilder.ts`

新形式のリクエスト生成（goals, wakeUpTime, windDownTime追加）

---

## Phase 9: アクセシビリティ・品質保証

### 9.1 アクセシビリティ要件（ui_ux_design.md準拠）

| 項目 | 基準 |
|------|------|
| コントラスト比 | 4.5:1以上（AA） |
| 最小タップ領域 | 44x44px |
| フォントサイズ | 最小14px |
| VoiceOver | 全要素にラベル |

### 9.2 コンポーネントテスト

- WaveScoreアニメーション
- MetricCardインタラクション
- BottomSheet動作
- Breatheタイマー

### 9.3 画面統合テスト

- Todayデータフロー
- Rhythmフェーズ計算
- Insightsアラート生成
- Settings永続化

### 9.4 バックエンドテスト

- 新API形式の単体テスト
- E2Eテスト

---

## ファイル変更一覧

### 新規作成

| ファイル | Phase |
|---------|-------|
| `app/src/i18n/index.ts` | 1 |
| `app/src/i18n/locales/ja.json` | 1 |
| `app/src/theme/shadows.ts` | 1 |
| `app/src/theme/animations.ts` | 1 |
| `app/src/domain/models/rhythm.ts` | 2 |
| `app/src/domain/models/insight.ts` | 2 |
| `app/src/domain/services/tempoScoreCalculator.ts` | 2 |
| `app/src/domain/services/rhythmCalculator.ts` | 2 |
| `app/src/domain/services/alertGenerator.ts` | 2 |
| `app/src/utils/format.ts` | 2 |
| `app/src/components/WaveScore.tsx` | 3 |
| `app/src/components/MetricCard.tsx` | 3 |
| `app/src/components/MetricDetail.tsx` | 3 |
| `app/src/components/BottomSheet.tsx` | 3 |
| `app/src/components/RhythmGraph.tsx` | 3 |
| `app/src/components/BreathingCircle.tsx` | 3 |
| `app/src/stores/breatheStore.ts` | 4 |
| `app/app/(main)/rhythm.tsx` | 6 |
| `app/app/(main)/breathe.tsx` | 6 |
| `app/app/(main)/insights.tsx` | 6 |

### 更新

| ファイル | Phase |
|---------|-------|
| `app/src/theme/colors.ts` | 1 |
| `app/src/theme/typography.ts` | 1 |
| `app/src/theme/spacing.ts` | 1 |
| `app/src/stores/healthStore.ts` | 4 |
| `app/src/stores/insightStore.ts` | 4 |
| `app/src/stores/userStore.ts` | 4 |
| `app/app/(main)/_layout.tsx` | 5 |
| `app/app/(main)/index.tsx` | 6 |
| `app/app/(main)/settings.tsx` | 6 |
| `app/src/api/types.ts` | 8 |
| `app/src/api/client.ts` | 8 |
| `app/src/api/helpers/adviceRequestBuilder.ts` | 8 |
| `backend/src/services/advice/types.ts` | 7 |
| `backend/src/services/advice/PromptBuilder.ts` | 7 |
| `backend/src/services/advice/AnthropicClient.ts` | 7 |

### 削除

| ファイル | Phase |
|---------|-------|
| `app/app/(main)/analytics.tsx` | 5 |

---

## 依存パッケージ

```bash
# フロントエンド
cd app
pnpm add expo-localization i18n-js @gorhom/bottom-sheet expo-haptics
```

---

## 実行順序

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7 → Phase 8 → Phase 9
   ↓         ↓         ↓         ↓         ↓         ↓         ↓         ↓         ↓
 基盤      モデル   コンポーネント  Store    ナビ      画面    バックエンド  API連携    テスト
```

Phase 6（画面）とPhase 7（バックエンド）は並行作業可能。

---

## 成功基準

- [ ] 5タブが正しくレンダリングされる
- [ ] Tempo Scoreが波アニメーションで表示される
- [ ] MetricCardタップでBottomSheetが開く
- [ ] Rhythm画面で正しいフェーズが表示される
- [ ] Breatheが4-7-8サイクルで動作する
- [ ] Insightsに週間データとアラートが表示される
- [ ] Settingsが正しく永続化される
- [ ] AIアドバイスが新形式で生成される
- [ ] 全UIテキストがi18nキー経由で表示される
- [ ] アクセシビリティ基準を満たす
- [ ] オンボーディングに影響なし
- [ ] 全テスト通過
