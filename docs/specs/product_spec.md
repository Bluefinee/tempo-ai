# プロダクト仕様書

**バージョン**: 2.0  
**最終更新日**: 2026年1月7日

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [technical_spec.md](./technical_spec.md) | 技術仕様・システム構成 |
| [metrics_spec.md](./metrics_spec.md) | スコア算出ロジック |
| [ai_prompt_spec.md](./ai_prompt_spec.md) | AIプロンプト仕様 |
| [ui_ux_design.md](./ui_ux_design.md) | UI/UX設計詳細 |
| [i18n_design.md](./i18n_design.md) | 多言語対応設計 |
| [knowledge_base.md](./knowledge_base.md) | 科学的根拠 |

---

## 1. プロダクト概要

### 1.1 ビジョン

**「自分のテンポを知り、テンポに乗る」**

TempoAIは、サーカディアンリズム（体内時計）と自律神経の状態を可視化し、AIが毎朝パーソナライズされたアドバイスを提供するiOSアプリ。

### 1.2 デザイン原則

| 原則 | 説明 |
|------|------|
| **Calm Technology** | 1日1回の穏やかなアドバイス。押し付けない、追い立てない |
| **Data as Poetry** | 数値を「波」「リズム」のような詩的ビジュアルで表現 |
| **Personal Rhythm** | 他人との比較なし。過去の自分との対話 |

### 1.3 ターゲットユーザー

| 項目 | 内容 |
|------|------|
| 年齢層 | 25-40歳 |
| 属性 | 健康意識の高いプロフェッショナル |
| デバイス | Apple Watch装着者 |
| ペイン | 数字の羅列に疲れている、何をすべきかわからない |
| ゲイン | 自分の身体を理解したい、最適なタイミングで行動したい |

### 1.4 競合との差別化

| アプリ | 特徴 | TempoAIの差別化 |
|--------|------|----------------|
| Apple Health | データの羅列 | AIによる解釈とアドバイス |
| Athlytic | スコア中心、数値重視 | 詩的表現、温かいトーン |
| Oura | クリニカルな表現 | 親しみやすく行動提案 |
| Whoop | アスリート向け、数値重視 | 一般ユーザー向け |

---

## 2. 主要機能

### 2.1 4つのスコア

Today画面のメインとなる4つのコンディション指標。

| スコア | 説明 | 算出根拠 |
|--------|------|---------|
| **Recovery** | 身体の回復度（0-100%） | HRV + RHR + 睡眠の質 |
| **Sleep** | 睡眠パフォーマンス（0-100%） | Duration + Quality + Timing |
| **Rhythm** | リズムの安定性（0-100%） | 就寝/起床時刻の一貫性 |
| **Energy** | 今日のエネルギー予測（0-100%） | Recovery + Sleep + 天気 |

各スコアカードをタップすると詳細画面へ遷移。
- 詳細説明（テンプレート生成）
- 7D/30D/60Dの履歴チャート
- 教育コンテンツ（Learn）

詳細は [metrics_spec.md](./metrics_spec.md) を参照

### 2.2 AI Daily Insight

毎朝1回、パーソナライズされたアドバイスを生成。

| 要素 | 内容 |
|------|------|
| Today's Insight | 詩的なタイトル + 温かいコンディション説明 |
| WHY THIS MATTERS | HRV/Sleep/Rhythmの3項目の解釈 |
| WHAT THIS MEANS FOR TODAY | 今日への実践的アドバイス |
| Related Insight | 科学的根拠に基づく発見 |

### 2.3 Today's One Thing

1日1つの具体的なアクション提案。

| 要素 | 内容 |
|------|------|
| アクション | 時間・場所を含む具体的な提案 |
| WHY THIS ACTION | サーカディアンリズムの観点からの理由 |
| Benefits | 3つの期待効果 |
| HOW TO DO IT | 実践ステップ |
| EXPECTED BENEFIT | 科学的根拠に基づく効果 |
| リマインダー | 指定時刻に通知 |

詳細は [ai_prompt_spec.md](./ai_prompt_spec.md) を参照

### 2.4 Health Summary

Apple Watchから取得した詳細なHealth指標。

| 指標 | 単位 | 説明 |
|------|------|------|
| HRV | ms | 心拍変動（自律神経の状態） |
| RHR | bpm | 安静時心拍数 |
| Respiratory Rate | BrPM | 呼吸数 |
| SpO2 | % | 血中酸素濃度 |
| Wrist Temperature | °C | 手首体温 |

各指標に対して：
- 現在値 vs Baseline（60日平均）
- Typical Range（5-95パーセンタイル）
- Within/High/Lowのステータス表示
- 7D/30D/60Dの履歴チャート

### 2.5 Rhythm View

サーカディアンリズムの可視化。

- 1日のエネルギー曲線をグラフ表示
- Peak Focus、Afternoon Dip などのフェーズ表示
- 現在地と次のフェーズ変化までの時間
- Sunrise/Sunset表示

### 2.6 Breathe

呼吸エクササイズ機能。

- 4-7-8呼吸法（吸う4秒・止める7秒・吐く8秒）
- Hapticフィードバック
- ダークモードの没入型UI

### 2.7 Insights

AIが発見したパターンの表示。

| 種類 | 内容 |
|------|------|
| TOP DISCOVERY | 週次分析から発見した相関パターン |
| RECENT ALERTS | リアルタイムの注意喚起 |

---

## 3. 画面構成

5タブ構成。詳細は [ui_ux_design.md](./ui_ux_design.md) を参照。

| タブ | 機能 |
|------|------|
| Today | ホーム（4スコア、AIアドバイス、Health Summary） |
| Rhythm | サーカディアンリズム可視化 |
| Breathe | 呼吸エクササイズ（中央配置） |
| Insights | AIパターン発見 |
| Settings | 設定・データソース連携 |

### 3.1 詳細画面一覧

| 画面 | トリガー | 内容 |
|------|---------|------|
| Recovery詳細 | Recoveryカードタップ | スコア詳細、履歴、Learn |
| Sleep詳細 | Sleepカードタップ | 睡眠ステージ、タイミング |
| Rhythm詳細 | Rhythmカードタップ | 一貫性分析 |
| Energy詳細 | Energyカードタップ | 予測の根拠 |
| Health詳細 | Health Summaryタップ | 全Health指標の詳細 |
| Today's Insight詳細 | AI INSIGHTタップ | WHY THIS MATTERS等 |
| Today's One Thing詳細 | ONE THINGタップ | アクションの詳細 |

---

## 4. オンボーディング

5画面構成のシンプルなフロー。

| # | 画面 | 目的 |
|---|------|------|
| 1 | Welcome | ブランド体験 |
| 2 | Goal Selection | パーソナライズ（複数選択可） |
| 3 | Schedule | 起床・就寝目標設定 |
| 4 | Health Connect | HealthKit連携 |
| 5 | Ready | 7日間学習期間の説明 |

### Goal Selection 選択肢

| 選択 | AIパーソナライズへの影響 |
|------|------------------------|
| Better Sleep | 睡眠関連のインサイト・アドバイスを優先 |
| More Energy | 日中の活動・Peak Focus活用を優先 |
| Less Stress | 呼吸法・リラックス提案を優先 |
| Peak Performance | 最適タイミング・集中力向上を優先 |

---

## 5. データソース

### 5.1 HealthKit（iOS）

| データ | 用途 | 必須 |
|--------|------|------|
| HRV（心拍変動） | Recovery計算 | ✅ |
| 安静時心拍数 | Recovery計算 | ✅ |
| 睡眠分析 | Sleep計算 | ✅ |
| 歩数 | Activity | ✅ |
| 呼吸数 | Health Summary | ○ |
| 血中酸素 | Health Summary | ○ |
| 手首体温 | Health Summary | ○ |

### 5.2 外部API

| API | 用途 |
|-----|------|
| Open-Meteo | 天気・気圧・Sunrise/Sunset |
| Claude API | AIアドバイス生成 |

### 5.3 将来対応予定

| ソース | 用途 |
|--------|------|
| Oura Ring | 追加のHRV・睡眠データ |
| Health Connect（Android） | Android対応時 |

---

## 6. 対応言語・地域

| 言語 | 優先度 | 状態 |
|------|--------|------|
| 日本語 | デフォルト | 実装中 |
| 英語 | 高 | 将来対応 |

詳細は [i18n_design.md](./i18n_design.md) を参照

---

## 7. リリース計画

### Phase 1: MVP

- Today画面（4スコア、AIアドバイス、Health Summary）
- 各詳細画面
- Rhythm画面
- Breathe画面
- Settings画面
- HealthKit連携（モック → 実データ）

### Phase 2: 拡張

- Insights画面
- 週次レポート
- ウィジェット対応
- パーソナル相関分析（v2 AI）

### Phase 3: 成長

- 英語対応
- Android対応
- Oura Ring連携

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2026-01-06 | 新UI設計に基づき新規作成 |
| 1.1 | 2026-01-06 | AI詳細画面を追加 |
| 2.0 | 2026-01-07 | 4指標体系に全面改訂、Health Summary追加、Tempo Score削除 |
