# 📱 Tempo AI - 仕様書

## 🎯 プロダクト概要

### コンセプト

Tempo AI は、HealthKit データ、環境情報、ユーザーの日々の体調を統合的に活用し、AI があなたの体調と環境に最適化された健康アドバイスを毎日提供するパーソナルヘルスケアアドバイザーです。

### ビジョン

「毎朝、あなた専用のヘルスケアアドバイザーが最適なアドバイスを届ける世界」

### ターゲットユーザー

- 健康意識の高い全世代
- iPhone ユーザー（Apple Watch 装着者はより詳細なデータ活用）
- データドリブンで健康管理したい人
- グローバル展開

### 対応言語

- 🇺🇸 **英語**（デフォルト）
- 🇯🇵 **日本語**

### 提供価値

1. **完全パーソナライズ**: 睡眠、心拍、活動量、環境を総合分析
2. **実行可能**: 具体的で今日すぐ実践できるアドバイス
3. **多言語対応**: ユーザーの母国語で理解しやすいアドバイス
4. **文化的適応**: 居住地域の食文化・生活習慣に合わせたアドバイス
5. **環境配慮**: 気圧、花粉、大気質を考慮した健康管理
6. **2 段階カスタマイズ**: データ分析後、さらに追加入力で精度向上
7. **時系列パターン認識**: 前日の活動と今朝のデータを比較し、体の反応を把握
8. **寄り添う提案**: 断定ではなく、ユーザーに寄り添う提案ベースのアドバイス
9. **段階的学習**: 専門用語を自然に理解できる教育システム
10. **多様なウェルネス提案**: 運動・食事だけでなく、呼吸法、マッサージ、マインドフルネスなど多彩な提案

---

## 📊 収集データ詳細

### 🏥 HealthKit データ

#### 基本データ

- 睡眠時間・睡眠ステージ（深い睡眠、REM 睡眠など）
- 心拍変動（HRV）
- 心拍数
- 歩数
- 活動カロリー

#### 拡充データ

- **安静時心拍数**: 自律神経の状態把握
- **血中酸素濃度（SpO2）**: 呼吸器系の健康指標
- **呼吸数**: ストレス・睡眠の質の指標
- **体温**: 体調変化の早期検知（発熱、疲労）
- **マインドフルネス時間**: メンタルケアの習慣把握
- **立ち上がり回数**: 座りすぎの警告
- **運動種別の詳細**: ランニング、筋トレ、ヨガ、サイクリングなど
- **消費カロリー詳細**: 基礎代謝 vs 活動代謝

#### 時系列パターン分析用データ

- **前日の活動量**: 歩数、運動時間、強度
- **前日の最終食事時刻**: HealthKit の栄養データから推定
- **前日の就寝時刻**: 今朝の状態との相関分析
- **過去 7 日間のトレンド**: HRV、安静時心拍、睡眠時間の推移
- **今朝の起床時データ**: 起床直後の HRV、心拍数、体温

**注**: Apple Watch を装着している場合、より精密なデータ（24 時間心拍モニタリング、詳細な睡眠ステージ、呼吸数など）が HealthKit を通じて自動的に取得されます。

---

### 🌤️ 環境データ

#### 基本データ

- 気温
- 天気（晴れ、曇り、雨など）
- 湿度

#### 拡充データ

- **気圧**: 頭痛・体調不良の予測（気圧病対策）
- **花粉情報**: アレルギー対策アドバイス（地域別）
- **大気質指数（AQI）**: 屋外活動の適切なタイミング提案
- **UV 指数**: 日焼け止め・日光浴のアドバイス
- **日の出/日の入り時刻**: 概日リズム最適化

#### 使用 API

- **Open-Meteo API**: 気圧、UV、日の出/入、花粉情報
- **IQAir API**: 大気質指数（AQI）

---

### 🌍 ロケーション・文化データ

#### 地域情報

- **居住国**: ユーザープロフィールから取得
- **居住都市**: 環境データ取得に使用
- **タイムゾーン**: 自動検出

#### 文化的適応

- **食文化**: 地域の一般的な食材・料理に基づいたアドバイス
  - 日本: 和食中心（納豆、味噌汁、魚、米など）
  - 北米: 洋食中心（オートミール、卵、ヨーグルトなど）
  - その他地域: 順次対応
- **生活習慣**: 地域の一般的な生活リズムを考慮
- **季節性**: 地域の季節に応じた食材・アドバイス

---

### ✅ 朝のクイックチェックイン（任意・追加カスタマイズ用）

#### 目的

データ分析による第 1 段階のアドバイスに加え、ユーザーの主観的な体調を反映して再カスタマイズ

#### タイミング

データ分析後のアドバイス表示時に「今日の調子はどうですか？」と任意で質問

#### 入力項目

1. **今日の気分**

   ```
   今朝の気分は？
   😊 調子いい  😐 普通  😔 疲れてる
   ```

2. **疲労度**（5 段階スライダー）

   ```
   疲労度: 1 ━━●━━━━━ 5
   ```

3. **睡眠の質感**

   ```
   睡眠の質は？
   ⭐️ ぐっすり  ☁️ 普通  💤 浅い
   ```

4. **前日の飲酒**
   ```
   昨晩お酒を飲みましたか？
   🍺 はい（グラス数: 1 2 3 4+）
   ❌ いいえ
   ```

#### UX 設計

- **スキップ可能**: 入力せずにそのまま利用可能
- **1 画面で完結**: 30 秒以内で完了
- **即座に反映**: 入力後、アドバイスが再カスタマイズされる

---

## 📱 アプリ構造

### ナビゲーション: タブバー（5 タブ）

```
┌─────┬─────┬─────┬─────┬─────┐
│ 🏠  │ 📅  │ 📈  │ 📚  │ 👤  │
│今日  │履歴  │傾向  │学ぶ  │私   │
└─────┴─────┴─────┴─────┴─────┘
```

---

## 🖼️ 画面仕様

### 1. オンボーディング（3-5 ページ）

#### ページ 1: ようこそ

**日本語版:**

```
┌─────────────────────────────┐
│                             │
│         🎯 Tempo AI         │
│                             │
│  あなただけのヘルスケア      │
│     アドバイザー             │
│                             │
│   毎朝、最適なアドバイスを    │
│   あなたのデータから生成      │
│                             │
│         [次へ →]            │
│                             │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│                             │
│         🎯 Tempo AI         │
│                             │
│  Your Personal Healthcare   │
│        Advisor              │
│                             │
│   Every morning, optimal    │
│   advice from your data     │
│                             │
│         [Next →]            │
│                             │
└─────────────────────────────┘
```

#### ページ 2: 何を見るのか

**日本語版:**

```
┌─────────────────────────────┐
│     📊 3つのデータを統合      │
│                             │
│  ┌─────────────────────┐   │
│  │  💤 あなたの体        │
│  │  睡眠・心拍・活動など   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  🌤️ 今日の環境        │
│  │  気圧・天気・花粉など   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  📝 昨日の過ごし方     │
│  │  運動・食事・睡眠など   │
│  └─────────────────────┘   │
│                             │
│         [次へ →]            │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│    📊 3 Types of Data       │
│                             │
│  ┌─────────────────────┐   │
│  │  💤 Your Body         │
│  │  Sleep, HR, Activity  │
│  │  and more             │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  🌤️ Today's Env       │
│  │  Pressure, Weather,   │
│  │  Pollen and more      │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  📝 Yesterday         │
│  │  Exercise, Diet,      │
│  │  Sleep and more       │
│  └─────────────────────┘   │
│                             │
│         [Next →]            │
└─────────────────────────────┘
```

#### ページ 3: 何がわかるのか

**日本語版:**

```
┌─────────────────────────────┐
│      🧠 AIが分析すること      │
│                             │
│   今朝のあなたの状態          │
│         +                   │
│   昨日の過ごし方との関係      │
│         +                   │
│   今日の環境への影響          │
│         ↓                   │
│   最適な1日のプラン          │
│                             │
│  「なぜこのアドバイスなのか」  │
│  理由も一緒にお届けします     │
│                             │
│         [次へ →]            │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│     🧠 What AI Analyzes      │
│                             │
│   Your condition this       │
│   morning                   │
│         +                   │
│   Relation to yesterday's   │
│   activities                │
│         +                   │
│   Today's environmental     │
│   impact                    │
│         ↓                   │
│   Optimal daily plan        │
│                             │
│  "Why this advice?"         │
│  We explain the reasons     │
│                             │
│         [Next →]            │
└─────────────────────────────┘
```

#### ページ 4: 何をするアプリか

**日本語版:**

```
┌─────────────────────────────┐
│      💡 毎朝届くもの          │
│                             │
│   今日のあなたの              │
│   コンディションに合わせた    │
│                             │
│   🍳 食事プラン              │
│   💪 運動プラン              │
│   🌿 過ごし方プラン          │
│                             │
│   あなたの体と相談しながら    │
│   最適な1日を作りましょう     │
│                             │
│         [始める →]           │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│   💡 What You'll Receive    │
│                             │
│   Tailored to your          │
│   condition today           │
│                             │
│   🍳 Meal Plan              │
│   💪 Exercise Plan          │
│   🌿 Wellness Plan          │
│                             │
│   Let's create the perfect  │
│   day for your body         │
│                             │
│         [Start →]           │
└─────────────────────────────┘
```

---

### 2. ホーム画面（Today）

#### 基本表示

**日本語版:**

```
┌─────────────────────────────┐
│ 快晴の朝ですね、まさかずさん  │
│ 12月5日（木）☀️ 15°C         │
│ 東京                         │
├─────────────────────────────┤
│  ⚠️ 環境アラート              │
│  気圧が急降下しています        │
│  頭痛に注意 → 詳細           │
├─────────────────────────────┤
│  ┌─────────────────────┐   │
│  │ 今日のあなた           │
│  │                       │
│  │   ケアモード           │
│  │   [🔵🔵🔵🔵🔵⚪️⚪️⚪️⚪️⚪️]  │
│  │   50/100              │
│  │                       │
│  │   昨夜の筋トレから      │
│  │   体がまだ回復中のようです│
│  │                       │
│  │   💡 今日は軽めの      │
│  │   運動がおすすめです    │
│  │                       │
│  │   [詳しく見る] ⓘ      │
│  └─────────────────────┘   │
├─ 今日のアクションプラン ─────┤
│                             │
│ 🍳 食事プラン                │
│ 消化に優しい抗炎症食材を      │
│ おすすめします               │
│ 焼き魚（鮭）+ 納豆など       │
│ [詳細を見る] ⓘ             │
│                             │
│ 💪 運動プラン                │
│ 軽めのウォーキング 30分程度   │
│ がよさそうです               │
│ [詳細を見る] ⓘ             │
│                             │
│ 🌿 今日の過ごし方            │
│ 4-7-8呼吸法を取り入れて      │
│ みましょう                   │
│ [詳細を見る] ⓘ             │
│                             │
├─────────────────────────────┤
│  💬 今日の調子はどうですか？   │
│     [答える] [スキップ]       │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│ Beautiful morning, Masakazu!│
│ Thursday, Dec 5 ☀️ 59°F     │
│ Tokyo                       │
├─────────────────────────────┤
│  ⚠️ Environmental Alert      │
│  Atmospheric pressure       │
│  dropping → Details         │
├─────────────────────────────┤
│  ┌─────────────────────┐   │
│  │ Your Status Today    │
│  │                      │
│  │   Care Mode          │
│  │   [🔵🔵🔵🔵🔵⚪️⚪️⚪️⚪️⚪️] │
│  │   50/100             │
│  │                      │
│  │   Your body seems to │
│  │   be recovering from │
│  │   last night's workout│
│  │                      │
│  │   💡 Light exercise  │
│  │   recommended today  │
│  │                      │
│  │   [Learn more] ⓘ    │
│  └─────────────────────┘   │
├─ Today's Action Plan ───────┤
│                             │
│ 🍳 Meal Plan                │
│ Anti-inflammatory foods     │
│ recommended                 │
│ Grilled salmon + fermented  │
│ foods                       │
│ [Details] ⓘ                │
│                             │
│ 💪 Exercise Plan            │
│ Light walking for about     │
│ 30 minutes recommended      │
│ [Details] ⓘ                │
│                             │
│ 🌿 Wellness Plan            │
│ Try incorporating 4-7-8     │
│ breathing exercises         │
│ [Details] ⓘ                │
│                             │
├─────────────────────────────┤
│  💬 How are you feeling?     │
│     [Answer] [Skip]         │
└─────────────────────────────┘
```

#### 挨拶のバリエーション（天気・時間帯に応じて）

**日本語:**

**晴れの場合:**

- 快晴の朝ですね、[名前]さん
- 気持ちいい朝ですね、[名前]さん
- 良い天気です、[名前]さん

**曇りの場合:**

- 曇り空ですが元気にいきましょう、[名前]さん
- おはようございます、[名前]さん
- 今日も健康的な 1 日を、[名前]さん

**雨の場合:**

- 雨の朝ですね、[名前]さん
- 雨の日も体調管理しっかりと、[名前]さん
- 雨ですが今日も元気に、[名前]さん

**気温による追加:**

- 寒い朝ですね、温かくしてください
- 暖かい 1 日になりそうです
- 少し肌寒いですね

**英語:**

**晴れの場合:**

- Beautiful morning, [name]!
- What a lovely morning, [name]!
- Great weather today, [name]!

**曇りの場合:**

- Good morning, [name]!
- Cloudy but let's stay positive, [name]!
- Have a healthy day, [name]!

**雨の場合:**

- Rainy morning, [name]!
- Rainy day but stay healthy, [name]!
- Despite the rain, stay energized, [name]!

**気温による追加:**

- Cold morning, stay warm
- Looks like a warm day ahead
- A bit chilly today

#### 色分けシステム

```
🟢 好調モード / Optimal Mode (80-100)
   「体が最高の状態のようです」
   "Your body seems to be in peak condition"

🟡 標準モード / Standard Mode (60-79)
   「いつも通りの調子のようです」
   "You seem to be in your usual condition"

🔵 ケアモード / Care Mode (40-59)
   「体をいたわる日かもしれません」
   "Today might be a day to care for your body"

⚫️ 休息モード / Rest Mode (0-39)
   「しっかり休息が必要そうです」
   "Your body seems to need proper rest"
```

---

### 3. 詳細画面（パーソナライズ・寄り添い表現版）

#### 「今日のあなた」詳細

**日本語版:**

```
┌─────────────────────────────┐
│  ケアモード [🔵🔵🔵🔵🔵⚪️⚪️⚪️⚪️⚪️]│
│  50/100                      │
├─────────────────────────────┤
│                             │
│  昨夜の筋トレ（高強度）から   │
│  約12時間が経過しました。     │
│                             │
│  睡眠中も回復プロセスが       │
│  続いていたようで、今朝の     │
│  データにその影響が           │
│  表れているようです。         │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  【今朝の主なデータ】         │
│                             │
│  心拍変動: 58ms ⓘ           │
│  → あなたの平均より8%低め    │
│                             │
│  安静時心拍: 68bpm ⓘ        │
│  → あなたの平均より5bpm高め  │
│                             │
│  体温: 36.8°C ⓘ             │
│  → 平熱範囲内                │
│                             │
│  睡眠時SpO2: 97% ⓘ          │
│  → 良好な範囲です            │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  💡 今日のおすすめ           │
│                             │
│  データから判断すると、       │
│  体がまだ回復途中のようです。 │
│                             │
│  軽めの有酸素運動で血流を     │
│  促進し、アクティブリカバリー │
│  をぜひ行ってみてください。   │
│                             │
│  明日には通常の状態に         │
│  戻る可能性が高そうです。     │
│                             │
│  [各指標について学ぶ →]      │
│                             │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│  Care Mode [🔵🔵🔵🔵🔵⚪️⚪️⚪️⚪️⚪️]│
│  50/100                      │
├─────────────────────────────┤
│                             │
│  About 12 hours have passed │
│  since last night's         │
│  high-intensity workout.    │
│                             │
│  It seems the recovery      │
│  process continued during   │
│  sleep, and this appears to │
│  be reflected in this       │
│  morning's data.            │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  【Key Data This Morning】  │
│                             │
│  HRV: 58ms ⓘ                │
│  → 8% lower than your avg   │
│                             │
│  Resting HR: 68bpm ⓘ        │
│  → 5bpm higher than avg     │
│                             │
│  Body Temp: 98.2°F ⓘ        │
│  → Within normal range      │
│                             │
│  Sleep SpO2: 97% ⓘ          │
│  → Good range               │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  💡 Today's Recommendation  │
│                             │
│  Based on the data, your    │
│  body seems to still be     │
│  recovering.                │
│                             │
│  Light aerobic exercise to  │
│  promote blood flow and     │
│  active recovery would be   │
│  great to try today.        │
│                             │
│  You'll likely return to    │
│  your normal state by       │
│  tomorrow.                  │
│                             │
│  [Learn about indicators →] │
│                             │
└─────────────────────────────┘
```

#### 指標の ⓘ をタップした場合（心拍変動の例）

**日本語版:**

```
┌─────────────────────────────┐
│  💓 心拍変動（HRV）について   │
├─────────────────────────────┤
│                             │
│  心拍と心拍の間隔の           │
│  「ばらつき」を示す指標です。 │
│                             │
│  ┌─────────────────────┐   │
│  │ 心拍 心拍 心拍 心拍    │   │
│  │  ↓    ↓    ↓    ↓    │   │
│  │ ●━━━━●━━●━━━━●     │   │
│  │  0.8秒 0.9秒 0.7秒    │   │
│  │                       │   │
│  │ ばらつきがある         │   │
│  │ = 体が柔軟に対応中     │   │
│  └─────────────────────┘   │
│                             │
│  🟢 高い（65ms以上）         │
│  リラックス・回復状態         │
│  体の準備ができています       │
│                             │
│  🟡 中程度（55-65ms）        │
│  通常の状態                  │
│  軽い運動に適しています       │
│                             │
│  🔵 低め（45-55ms）          │
│  回復中または疲労気味         │
│  ゆっくり過ごすのがおすすめ   │
│                             │
│  ⚫️ 低い（45ms未満）         │
│  休息が必要な状態             │
│  無理は避けましょう           │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  📊 あなたのHRV              │
│  平均: 63ms                 │
│  最高: 75ms (11/28)         │
│  最低: 52ms (11/15)         │
│                             │
│  💡 改善のヒント             │
│  • 質の高い睡眠7-8時間       │
│  • ストレス管理（呼吸法）     │
│  • 適度な運動と休養           │
│  • アルコールは控えめに       │
│                             │
│  [もっと詳しく学ぶ →]        │
│                             │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│  💓 About HRV                │
│     (Heart Rate Variability) │
├─────────────────────────────┤
│                             │
│  Indicates the "variation"  │
│  between heartbeat intervals│
│                             │
│  ┌─────────────────────┐   │
│  │ Beat Beat Beat Beat  │   │
│  │  ↓    ↓    ↓    ↓   │   │
│  │ ●━━━━●━━●━━━━●    │   │
│  │  0.8s  0.9s  0.7s    │   │
│  │                      │   │
│  │ Variation present    │   │
│  │ = Body adapting well │   │
│  └─────────────────────┘   │
│                             │
│  🟢 High (65ms+)            │
│  Relaxed & recovered state  │
│  Body is ready              │
│                             │
│  🟡 Moderate (55-65ms)      │
│  Normal condition           │
│  Suitable for light exercise│
│                             │
│  🔵 Low-ish (45-55ms)       │
│  Recovering or fatigued     │
│  Taking it easy recommended │
│                             │
│  ⚫️ Low (Below 45ms)        │
│  Rest needed                │
│  Avoid overexertion         │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  📊 Your HRV                │
│  Average: 63ms              │
│  Highest: 75ms (11/28)      │
│  Lowest: 52ms (11/15)       │
│                             │
│  💡 Tips for Improvement    │
│  • Quality sleep 7-8 hours  │
│  • Stress management        │
│  • Moderate exercise & rest │
│  • Limit alcohol            │
│                             │
│  [Learn more →]             │
│                             │
└─────────────────────────────┘
```

---

### 4. 詳細アドバイス画面（寄り添い表現版）

**日本語版:**

```
┌─────────────────────────────┐
│     今日のアクションプラン    │
├─────────────────────────────┤
│                             │
│ 🍳 食事プラン                │
│                             │
│ 【朝食のおすすめ】           │
│                             │
│ 消化に優しく、抗炎症作用の    │
│ ある食材がよさそうです。      │
│ ぜひ取り入れてみてください。  │
│                             │
│ • 焼き魚（鮭80g程度）        │
│   → オメガ3で炎症を抑制      │
│                             │
│ • 納豆 1パック               │
│   → 発酵食品で消化をサポート  │
│                             │
│ • アボカド 半分              │
│   → マグネシウムで           │
│     筋肉の緊張緩和           │
│                             │
│ • 玄米 小盛り（100g程度）    │
│   → エネルギー源として        │
│                             │
│ • 味噌汁（わかめ・豆腐）      │
│   → ミネラル補給             │
│                             │
│ • 緑茶 1-2杯                │
│   → 自律神経の調整に          │
│                             │
│ 💡 理由                     │
│ 昨夜22時の夕食から就寝まで   │
│ の時間が短めだったようなので、│
│ 今朝は消化器官への負担を      │
│ 考慮した内容をご提案します。  │
│                             │
│ また、昨夜の高強度トレーニング│
│ からの回復を促進する          │
│ 抗炎症食材を中心に            │
│ 組み立ててみました。          │
│                             │
│ ━━━━━━━━━━━━━━━━        │
│                             │
│ 💪 運動プラン                │
│                             │
│ 【今日のおすすめ】           │
│                             │
│ 軽めのウォーキングを          │
│ ぜひ試してみてください。      │
│                             │
│ 時間: 30分程度               │
│ 推奨心拍数: 100-115bpm       │
│ (あなたの最大心拍の55-60%)   │
│                             │
│ ペース: ゆっくり              │
│ （会話できるくらい）          │
│                             │
│ 時間帯: 10:00-11:00頃        │
│ （朝食2-3時間後）            │
│                             │
│ 💡 理由                     │
│ 昨日の高強度筋トレの影響が    │
│ 今朝のデータに表れています。  │
│                             │
│ HRVが平均より8%低く、         │
│ 安静時心拍が5bpm高めなので、  │
│ 今日は筋肉の回復と             │
│ 自律神経の安定を優先した      │
│ プランをご提案します。        │
│                             │
│ 軽めの有酸素運動で血流を      │
│ 促進し、アクティブリカバリー  │
│ をぜひ行ってみてください。    │
│                             │
│ 筋肉の乳酸除去を助け、        │
│ 明日以降のパフォーマンス向上  │
│ につながる可能性があります。   │
│                             │
│ 【今日は避けた方がよさそうなもの】│
│ ❌ HIIT（高強度インターバル） │
│ ❌ 重量挙げ・筋トレ           │
│ ❌ 長距離ランニング（60分以上）│
│                             │
│ 💡 あなたの過去データから    │
│ 過去30日の分析では、          │
│ 高強度筋トレの翌日に           │
│ アクティブリカバリーを         │
│ 行った日は、2日後のHRVが      │
│ 平均12%高くなる傾向が         │
│ 見られました。                │
│                             │
│ ━━━━━━━━━━━━━━━━        │
│                             │
│ 🌿 今日の過ごし方            │
│                             │
│ 【環境への対応】             │
│                             │
│ 気圧: 995hPa（低め）         │
│ → 頭痛に注意が必要そうです   │
│                             │
│ 花粉: 中程度                 │
│ → マスク着用をおすすめします  │
│                             │
│ 大気質: 良好                 │
│ → 屋外活動に適しています     │
│                             │
│ 【水分補給プラン】           │
│                             │
│ 今日の目標: 2.8L程度         │
│ （通常より300ml多め）        │
│                             │
│ • 起床後: 500ml              │
│ • 朝食時: 200ml（緑茶）      │
│ • 午前中: 600ml              │
│ • 昼食時: 300ml              │
│ • 午後: 600ml                │
│ • 夕食時: 300ml              │
│ • 就寝前: 200ml              │
│                             │
│ 💡 理由                     │
│ 気圧低下への対策として、      │
│ また筋肉回復のサポートとして、│
│ 通常より少し多めの水分補給を  │
│ おすすめします。              │
│                             │
│ 【呼吸法のおすすめ】         │
│                             │
│ 4-7-8呼吸法を                │
│ ぜひ取り入れてみてください。  │
│                             │
│ 実施回数: 1日5回程度         │
│                             │
│ タイミング:                  │
│ • 朝食後30分                 │
│ • 昼食後                     │
│ • 就寝前                     │
│                             │
│ 手順:                        │
│ 1. 4秒かけて鼻から吸う       │
│ 2. 7秒息を止める             │
│ 3. 8秒かけて口から吐く       │
│ 4. これを5回繰り返す         │
│                             │
│ 💡 理由                     │
│ HRVが通常より低めのため、     │
│ 副交感神経を活性化する        │
│ 呼吸法を通常より多めに        │
│ おすすめしています。          │
│                             │
│ 【その他のウェルネス提案】    │
│                             │
│ セサミオイルで足裏マッサージ  │
│ をぜひ試してみてください。    │
│                             │
│ 就寝前の10分程度、            │
│ 温めたセサミオイルで          │
│ 足裏を優しくマッサージすると、│
│ 血行が促進され、              │
│ リラックス効果が期待できます。│
│                             │
│ 特に筋トレ後の回復期には      │
│ 効果的かもしれません。        │
│                             │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│     Today's Action Plan      │
├─────────────────────────────┤
│                             │
│ 🍳 Meal Plan                │
│                             │
│ 【Breakfast Recommendations】│
│                             │
│ Easily digestible,          │
│ anti-inflammatory foods     │
│ would be great.             │
│ Please try incorporating    │
│ these.                      │
│                             │
│ • Grilled salmon (80g)      │
│   → Omega-3 reduces         │
│     inflammation            │
│                             │
│ • Fermented soybeans        │
│   (natto) 1 pack            │
│   → Supports digestion      │
│                             │
│ • Avocado half              │
│   → Magnesium relieves      │
│     muscle tension          │
│                             │
│ • Brown rice small bowl     │
│   (100g)                    │
│   → Energy source           │
│                             │
│ • Miso soup (seaweed, tofu) │
│   → Mineral supplement      │
│                             │
│ • Green tea 1-2 cups        │
│   → Autonomic regulation    │
│                             │
│ 💡 Reasoning                │
│ Since the time between last │
│ night's 10pm dinner and     │
│ sleep was short, we suggest │
│ a plan considering your     │
│ digestive system load this  │
│ morning.                    │
│                             │
│ Also, we've centered the    │
│ plan on anti-inflammatory   │
│ foods to promote recovery   │
│ from last night's           │
│ high-intensity training.    │
│                             │
│ ━━━━━━━━━━━━━━━━        │
│                             │
│ 💪 Exercise Plan            │
│                             │
│ 【Today's Recommendation】  │
│                             │
│ Light walking would be      │
│ great to try today.         │
│                             │
│ Duration: About 30 minutes  │
│ Target HR: 100-115bpm       │
│ (55-60% of your max HR)     │
│                             │
│ Pace: Slow                  │
│ (conversational pace)       │
│                             │
│ Time: Around 10-11am        │
│ (2-3 hours after breakfast) │
│                             │
│ 💡 Reasoning                │
│ The impact of yesterday's   │
│ high-intensity workout      │
│ appears in this morning's   │
│ data.                       │
│                             │
│ With HRV 8% below average   │
│ and resting HR 5bpm higher, │
│ we recommend prioritizing   │
│ muscle recovery and         │
│ autonomic stability today.  │
│                             │
│ Light aerobic exercise to   │
│ promote blood flow - please │
│ try active recovery today.  │
│                             │
│ This helps remove lactic    │
│ acid and may improve        │
│ performance in coming days. │
│                             │
│ 【Activities to Avoid Today】│
│ ❌ HIIT                      │
│ ❌ Weight training           │
│ ❌ Long-distance running     │
│   (60+ minutes)             │
│                             │
│ 💡 From Your Past Data      │
│ In the past 30 days,        │
│ when you did active         │
│ recovery the day after      │
│ high-intensity training,    │
│ your HRV was 12% higher     │
│ two days later on average.  │
│                             │
│ ━━━━━━━━━━━━━━━━        │
│                             │
│ 🌿 Wellness Plan            │
│                             │
│ 【Environmental Response】  │
│                             │
│ Pressure: 995hPa (low)      │
│ → Watch for headaches       │
│                             │
│ Pollen: Moderate            │
│ → Mask recommended          │
│                             │
│ Air Quality: Good           │
│ → Suitable for outdoor      │
│   activities                │
│                             │
│ 【Hydration Plan】          │
│                             │
│ Today's target: About 2.8L  │
│ (300ml more than usual)     │
│                             │
│ • After waking: 500ml       │
│ • Breakfast: 200ml (tea)    │
│ • Morning: 600ml            │
│ • Lunch: 300ml              │
│ • Afternoon: 600ml          │
│ • Dinner: 300ml             │
│ • Before bed: 200ml         │
│                             │
│ 💡 Reasoning                │
│ To counter low pressure,    │
│ and to support muscle       │
│ recovery, we recommend      │
│ slightly more hydration     │
│ than usual.                 │
│                             │
│ 【Breathing Exercise】      │
│                             │
│ Please try incorporating    │
│ 4-7-8 breathing.            │
│                             │
│ Frequency: About 5x daily   │
│                             │
│ Timing:                     │
│ • 30min after breakfast     │
│ • After lunch               │
│ • Before bed                │
│                             │
│ Steps:                      │
│ 1. Inhale through nose (4s) │
│ 2. Hold breath (7s)         │
│ 3. Exhale through mouth (8s)│
│ 4. Repeat 5 times           │
│                             │
│ 💡 Reasoning                │
│ Since HRV is lower than     │
│ usual, we recommend more    │
│ breathing exercises to      │
│ activate parasympathetic    │
│ nervous system.             │
│                             │
│ 【Other Wellness Suggestions】│
│                             │
│ Please try foot massage     │
│ with sesame oil.            │
│                             │
│ For about 10 minutes before │
│ bed, gently massage your    │
│ feet with warmed sesame oil.│
│ This promotes circulation   │
│ and may provide relaxation. │
│                             │
│ It can be particularly      │
│ effective during recovery   │
│ periods after training.     │
│                             │
└─────────────────────────────┘
```

---

### 5. 学ぶタブ（新規追加）

#### トップ画面

**日本語版:**

```
┌─────────────────────────────┐
│       健康データについて      │
├─────────────────────────────┤
│                             │
│  基本の指標                  │
│                             │
│  ┌─────────────────────┐   │
│  │ 💓 心拍変動（HRV）     │   │
│  │ 回復力を示す重要指標    │   │
│  │ [読む 5分] →          │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ ❤️ 安静時心拍数        │   │
│  │ 心臓の健康度をチェック  │   │
│  │ [読む 3分] →          │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 😴 睡眠の質            │   │
│  │ 深い睡眠とREM睡眠     │   │
│  │ [読む 5分] →          │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 🌡️ 体温                │   │
│  │ 体調変化の早期発見      │   │
│  │ [読む 3分] →          │   │
│  └─────────────────────┘   │
│                             │
├─────────────────────────────┤
│                             │
│  環境と健康                  │
│                             │
│  ┌─────────────────────┐   │
│  │ 🌡️ 気圧と体調          │   │
│  │ 頭痛・だるさの原因      │   │
│  │ [読む 4分] →          │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 🌸 花粉と対策          │   │
│  │ 季節性アレルギー管理    │   │
│  │ [読む 4分] →          │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 💨 大気質（AQI）       │   │
│  │ 屋外活動の判断基準      │   │
│  │ [読む 3分] →          │   │
│  └─────────────────────┘   │
│                             │
├─────────────────────────────┤
│                             │
│  あなたのパターン            │
│                             │
│  ┌─────────────────────┐   │
│  │ 📊 あなたのHRVパターン  │   │
│  │ 過去30日のデータ分析    │   │
│  │ [見る] →              │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 💪 運動と回復の関係     │   │
│  │ あなたに最適な頻度は？  │   │
│  │ [見る] →              │   │
│  └─────────────────────┘   │
│                             │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│      About Health Data       │
├─────────────────────────────┤
│                             │
│  Basic Indicators           │
│                             │
│  ┌─────────────────────┐   │
│  │ 💓 HRV                 │   │
│  │ Key recovery indicator │   │
│  │ [Read 5min] →         │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ ❤️ Resting Heart Rate │   │
│  │ Check heart health    │   │
│  │ [Read 3min] →         │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 😴 Sleep Quality      │   │
│  │ Deep & REM sleep      │   │
│  │ [Read 5min] →         │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 🌡️ Body Temperature   │   │
│  │ Early condition       │   │
│  │ detection             │   │
│  │ [Read 3min] →         │   │
│  └─────────────────────┘   │
│                             │
├─────────────────────────────┤
│                             │
│  Environment & Health       │
│                             │
│  ┌─────────────────────┐   │
│  │ 🌡️ Pressure & Health  │   │
│  │ Headaches & fatigue   │   │
│  │ causes                │   │
│  │ [Read 4min] →         │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 🌸 Pollen & Measures  │   │
│  │ Seasonal allergy      │   │
│  │ management            │   │
│  │ [Read 4min] →         │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 💨 Air Quality (AQI)  │   │
│  │ Outdoor activity      │   │
│  │ criteria              │   │
│  │ [Read 3min] →         │   │
│  └─────────────────────┘   │
│                             │
├─────────────────────────────┤
│                             │
│  Your Patterns              │
│                             │
│  ┌─────────────────────┐   │
│  │ 📊 Your HRV Pattern   │   │
│  │ 30-day data analysis  │   │
│  │ [View] →              │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 💪 Exercise & Recovery│   │
│  │ Your optimal frequency│   │
│  │ [View] →              │   │
│  └─────────────────────┘   │
│                             │
└─────────────────────────────┘
```

#### 学ぶタブ - 記事例（HRV）

**日本語版:**

```
┌─────────────────────────────┐
│  < 戻る    💓 心拍変動（HRV） │
├─────────────────────────────┤
│                             │
│  読了時間: 約5分 📖          │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  HRVは「Heart Rate          │
│  Variability」の略で、       │
│  日本語では「心拍変動」と      │
│  呼ばれます。                │
│                             │
│  これは、心拍と心拍の間の     │
│  時間（間隔）がどれくらい     │
│  ばらついているかを示す       │
│  指標です。                  │
│                             │
│  ┌─────────────────────┐   │
│  │                       │   │
│  │   [図解: 心拍の間隔]   │   │
│  │                       │   │
│  │   ●━━━●━━●━━━●      │   │
│  │   0.8秒 0.9秒 0.7秒   │   │
│  │                       │   │
│  │   ばらつきがある       │   │
│  │   = HRVが高い         │   │
│  │   = 良い状態！         │   │
│  │                       │   │
│  └─────────────────────┘   │
│                             │
│  💡 なぜばらつきが良い？      │
│                             │
│  心臓は実は、規則正しく       │
│  「ドクン、ドクン」と         │
│  打っているわけではありません。│
│                             │
│  健康な心臓は、状況に応じて   │
│  柔軟に間隔を変えています。   │
│                             │
│  これは自律神経（交感神経と   │
│  副交感神経）が、体の状態に   │
│  合わせて心臓をコントロール   │
│  している証拠なのです。        │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  🟢 HRVが高い時              │
│                             │
│  • 副交感神経が優位           │
│  • リラックスしている         │
│  • 体が回復している           │
│  • ストレスが少ない           │
│  • 運動のパフォーマンスUP     │
│                             │
│  → この日は思い切り          │
│    トレーニングできそうです！  │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  🔵 HRVが低い時              │
│                             │
│  • 交感神経が優位             │
│  • ストレスがかかっている     │
│  • 疲労が残っている           │
│  • 睡眠不足                  │
│  • 病気の前兆の可能性         │
│                             │
│  → この日は軽めの運動や      │
│    休息がおすすめです         │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  📊 HRVの目安（成人）         │
│                             │
│  🟢 アスリート: 70-100ms     │
│  🟢 とても良い: 65-70ms      │
│  🟡 良い: 55-65ms            │
│  🔵 普通: 45-55ms            │
│  ⚫️ 低い: 45ms未満           │
│                             │
│  ※ 個人差が大きいため、       │
│  自分の平均値と比較する       │
│  ことが重要です               │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  💪 HRVを改善する方法        │
│                             │
│  1️⃣ 質の高い睡眠             │
│     毎日7-8時間、規則正しく   │
│                             │
│  2️⃣ 適度な運動               │
│     やりすぎは逆効果          │
│     回復日を設ける            │
│                             │
│  3️⃣ ストレス管理             │
│     呼吸法、瞑想、            │
│     リラックス時間            │
│                             │
│  4️⃣ 栄養バランス             │
│     オメガ3、マグネシウム     │
│     抗酸化物質                │
│                             │
│  5️⃣ アルコール控えめ         │
│     飲酒はHRVを下げます       │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  🎯 Tempo AIでの活用         │
│                             │
│  Tempo AIは、あなたの         │
│  今朝のHRVを、過去の          │
│  データと比較して、            │
│                             │
│  「今日はどう過ごすべきか」   │
│                             │
│  を提案します。               │
│                             │
│  HRVが低い日は軽めの運動、    │
│  高い日は思い切りトレーニング。│
│                             │
│  これにより、怪我のリスクを   │
│  減らし、最大の効果を         │
│  得ることができそうです。     │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  📚 関連記事                 │
│                             │
│  • 安静時心拍数との違い       │
│  • 睡眠とHRVの関係           │
│  • ストレスがHRVに与える影響  │
│                             │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│  < Back    💓 About HRV      │
├─────────────────────────────┤
│                             │
│  Reading time: About 5min 📖│
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  HRV stands for "Heart Rate │
│  Variability."              │
│                             │
│  It's an indicator showing  │
│  how much the time          │
│  (intervals) between        │
│  heartbeats varies.         │
│                             │
│  ┌─────────────────────┐   │
│  │                      │   │
│  │ [Diagram: Intervals] │   │
│  │                      │   │
│  │   ●━━━●━━●━━━●     │   │
│  │   0.8s  0.9s  0.7s   │   │
│  │                      │   │
│  │   Variation present  │   │
│  │   = High HRV         │   │
│  │   = Good condition!  │   │
│  │                      │   │
│  └─────────────────────┘   │
│                             │
│  💡 Why is variation good?  │
│                             │
│  Your heart doesn't         │
│  actually beat in a         │
│  perfectly regular          │
│  "thump-thump" pattern.     │
│                             │
│  A healthy heart flexibly   │
│  adjusts intervals based    │
│  on the situation.          │
│                             │
│  This is evidence that your │
│  autonomic nervous system   │
│  (sympathetic & para-       │
│  sympathetic) is            │
│  controlling your heart     │
│  according to your body's   │
│  state.                     │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  🟢 When HRV is High        │
│                             │
│  • Parasympathetic dominant │
│  • Relaxed state            │
│  • Body recovering          │
│  • Low stress               │
│  • Performance enhanced     │
│                             │
│  → Great day for intense    │
│    training!                │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  🔵 When HRV is Low         │
│                             │
│  • Sympathetic dominant     │
│  • Under stress             │
│  • Fatigue remaining        │
│  • Sleep deprived           │
│  • Possible illness onset   │
│                             │
│  → Light exercise or rest   │
│    recommended              │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  📊 HRV Guidelines (Adults) │
│                             │
│  🟢 Athletes: 70-100ms      │
│  🟢 Excellent: 65-70ms      │
│  🟡 Good: 55-65ms           │
│  🔵 Average: 45-55ms        │
│  ⚫️ Low: Below 45ms         │
│                             │
│  ※ Individual variation    │
│  is large, so comparing     │
│  to your personal average   │
│  is important               │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  💪 How to Improve HRV      │
│                             │
│  1️⃣ Quality Sleep           │
│     7-8 hours daily,        │
│     regular schedule        │
│                             │
│  2️⃣ Moderate Exercise       │
│     Overdoing is            │
│     counterproductive       │
│     Include recovery days   │
│                             │
│  3️⃣ Stress Management       │
│     Breathing exercises,    │
│     meditation,             │
│     relaxation time         │
│                             │
│  4️⃣ Balanced Nutrition      │
│     Omega-3, magnesium,     │
│     antioxidants            │
│                             │
│  5️⃣ Limit Alcohol           │
│     Drinking lowers HRV     │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  🎯 Using HRV in Tempo AI   │
│                             │
│  Tempo AI compares your     │
│  morning HRV with past      │
│  data to suggest:           │
│                             │
│  "How should you spend      │
│  today?"                    │
│                             │
│  Light exercise on low HRV  │
│  days, intense training on  │
│  high HRV days.             │
│                             │
│  This helps reduce injury   │
│  risk and maximize          │
│  effectiveness.             │
│                             │
│  ━━━━━━━━━━━━━━━━        │
│                             │
│  📚 Related Articles        │
│                             │
│  • Difference from          │
│    Resting Heart Rate       │
│  • Sleep and HRV            │
│  • Stress Impact on HRV     │
│                             │
└─────────────────────────────┘
```

---

### 6. 履歴画面（History）

**日本語版:**

```
┌─────────────────────────────┐
│         履歴（7日間）         │
├─────────────────────────────┤
│ ┌─────────────────────┐   │
│ │ 12月5日（木）           │
│ │ ケアモード              │
│ │ HRV: 58ms（-8%）       │
│ │ 前日: 筋トレ高強度      │
│ │ 気圧: 995hPa ↓        │
│ │ タップして詳細 >        │
│ └─────────────────────┘   │
│                             │
│ ┌─────────────────────┐   │
│ │ 12月4日（水）           │
│ │ 標準モード              │
│ │ HRV: 63ms（標準）      │
│ │ 前日: 有酸素運動        │
│ │ 気圧: 1010hPa →       │
│ └─────────────────────┘   │
│                             │
│ ┌─────────────────────┐   │
│ │ 12月3日（火）           │
│ │ 好調モード              │
│ │ HRV: 68ms（+8%）       │
│ │ 前日: 休養日            │
│ │ 気圧: 1015hPa ↑       │
│ └─────────────────────┘   │
│                             │
│        （以下続く）          │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│      History (7 days)        │
├─────────────────────────────┤
│ ┌─────────────────────┐   │
│ │ Dec 5 (Thu)          │
│ │ Care Mode            │
│ │ HRV: 58ms (-8%)      │
│ │ Previous: High       │
│ │ intensity training   │
│ │ Pressure: 995hPa ↓   │
│ │ Tap for details >    │
│ └─────────────────────┘   │
│                             │
│ ┌─────────────────────┐   │
│ │ Dec 4 (Wed)          │
│ │ Standard Mode        │
│ │ HRV: 63ms (Average)  │
│ │ Previous: Aerobic    │
│ │ exercise             │
│ │ Pressure: 1010hPa →  │
│ └─────────────────────┘   │
│                             │
│ ┌─────────────────────┐   │
│ │ Dec 3 (Tue)          │
│ │ Optimal Mode         │
│ │ HRV: 68ms (+8%)      │
│ │ Previous: Rest day   │
│ │ Pressure: 1015hPa ↑  │
│ └─────────────────────┘   │
│                             │
│      (Continues below)      │
└─────────────────────────────┘
```

---

### 7. トレンド画面（Trends）

**日本語版:**

```
┌─────────────────────────────┐
│         データトレンド         │
├─────────────────────────────┤
│  期間: [7日間 ▼]            │
├─────────────────────────────┤
│                             │
│  睡眠時間（過去7日）          │
│   8h ┼        ●             │
│      │      ●   ●           │
│   7h ┼    ●       ●         │
│      │  ●           ●       │
│   6h ┼●                     │
│      └─────────────────     │
│      11/29  12/2  12/5      │
│                             │
│  平均: 7.2時間               │
│  先週比: +0.3時間 ↑          │
│                             │
│  💡 パターン分析             │
│  週末の睡眠時間が平日より     │
│  1時間長い傾向があるようです   │
│                             │
├─────────────────────────────┤
│  HRV（心拍変動）ⓘ           │
│  過去7日間                   │
│                             │
│  75ms ┼      ●               │
│       │    ●   ●             │
│  65ms ┼  ●       ●           │
│       │●           ●         │
│  55ms ┼                     │
│       └─────────────────     │
│                             │
│  平均: 65.5ms               │
│  先週比: -5.2ms ↓           │
│                             │
│  💡 パターン分析             │
│  筋トレ翌日のHRVは平均8%      │
│  低下する傾向があるようです    │
│                             │
│  気圧低下の日にHRVが          │
│  さらに下がる傾向が           │
│  見られます                  │
│                             │
├─────────────────────────────┤
│  活動とHRVの相関             │
│                             │
│  📊 前日の活動別HRV推移      │
│  休養日: 平均68ms           │
│  有酸素: 平均65ms           │
│  筋トレ: 平均58ms           │
│                             │
│  💡 あなたの最適パターン     │
│  「筋トレ→休養→有酸素」の    │
│  サイクルで、HRVが最も       │
│  安定しているようです        │
│                             │
├─────────────────────────────┤
│  環境要因との相関            │
│                             │
│  気圧 vs HRV                │
│  [グラフ表示]               │
│                             │
│  💡 気圧が1000hPa以下の時、  │
│  HRVが平均10%低下する        │
│  傾向があるようです          │
│                             │
│  💡 気圧低下日に筋トレを     │
│  すると、HRVは15%低下       │
│  → 軽い運動への変更を        │
│     おすすめします            │
│                             │
│  [HRVについてもっと学ぶ →]   │
│                             │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│         Data Trends          │
├─────────────────────────────┤
│  Period: [7 days ▼]         │
├─────────────────────────────┤
│                             │
│  Sleep Duration (Past 7d)   │
│   8h ┼        ●             │
│      │      ●   ●           │
│   7h ┼    ●       ●         │
│      │  ●           ●       │
│   6h ┼●                     │
│      └─────────────────     │
│      11/29  12/2  12/5      │
│                             │
│  Average: 7.2 hours         │
│  vs Last Week: +0.3h ↑      │
│                             │
│  💡 Pattern Analysis        │
│  Weekend sleep seems to be  │
│  1 hour longer than weekdays│
│                             │
├─────────────────────────────┤
│  HRV ⓘ                      │
│  Past 7 days                │
│                             │
│  75ms ┼      ●               │
│       │    ●   ●             │
│  65ms ┼  ●       ●           │
│       │●           ●         │
│  55ms ┼                     │
│       └─────────────────     │
│                             │
│  Average: 65.5ms            │
│  vs Last Week: -5.2ms ↓     │
│                             │
│  💡 Pattern Analysis        │
│  HRV seems to decrease by   │
│  8% on average after        │
│  training days              │
│                             │
│  HRV tends to drop further  │
│  on low pressure days       │
│                             │
├─────────────────────────────┤
│  Activity & HRV Correlation │
│                             │
│  📊 HRV by Previous Day     │
│  Rest day: Avg 68ms         │
│  Aerobic: Avg 65ms          │
│  Training: Avg 58ms         │
│                             │
│  💡 Your Optimal Pattern    │
│  "Training→Rest→Aerobic"    │
│  cycle shows the most       │
│  stable HRV                 │
│                             │
├─────────────────────────────┤
│  Environmental Correlation  │
│                             │
│  Pressure vs HRV            │
│  [Graph Display]            │
│                             │
│  💡 When pressure is below  │
│  1000hPa, HRV seems to      │
│  decrease by 10% on average │
│                             │
│  💡 Training on low pressure│
│  days: HRV drops 15%        │
│  → Light exercise           │
│     recommended instead     │
│                             │
│  [Learn more about HRV →]   │
│                             │
└─────────────────────────────┘
```

---

### 8. プロフィール画面（Me）

**日本語版:**

```
┌─────────────────────────────┐
│  [アイコン]  まさかず         │
│              28歳 / 男性     │
├─ 基本情報 ─────────────────┤
│  身長: 175cm / 体重: 70kg    │
│  安静時心拍: 65bpm（平均）   │
│  HRV平均: 63ms              │
├─ 居住地 ──────────────────┤
│  国: 日本                    │
│  都市: 東京                  │
│  タイムゾーン: Asia/Tokyo    │
├─ 目標 ────────────────────┤
│  ✓ 疲労回復                  │
│  ✓ 集中力向上                │
├─ 食事設定 ─────────────────┤
│  好み: 和食                  │
│  制限: グルテンフリー         │
├─ 運動習慣 ─────────────────┤
│  筋トレ: 週5-6回             │
│  有酸素: 週3回               │
│  通常時間帯: 19:00-20:30    │
├─ 環境設定 ─────────────────┤
│  花粉アレルギー: あり（スギ）  │
│  気圧敏感度: 高い            │
├─ 通知設定 ─────────────────┤
│  毎朝: 6:00                  │
│  クイックチェックイン: 任意    │
├─ 言語設定 ─────────────────┤
│  🇯🇵 日本語 / 🇺🇸 English      │
├─ HealthKit ────────────────┤
│  ✅ 接続済み                 │
│  📊 データ同期中              │
├─────────────────────────────┤
│  [プロフィールを編集]         │
│  [設定]                      │
│  [ヘルプ・サポート]           │
└─────────────────────────────┘
```

**英語版:**

```
┌─────────────────────────────┐
│  [Icon]  Masakazu           │
│          28 / Male          │
├─ Basic Info ────────────────┤
│  Height: 175cm / Weight: 70kg│
│  Resting HR: 65bpm (avg)    │
│  HRV avg: 63ms              │
├─ Location ──────────────────┤
│  Country: Japan             │
│  City: Tokyo                │
│  Timezone: Asia/Tokyo       │
├─ Goals ─────────────────────┤
│  ✓ Fatigue recovery         │
│  ✓ Focus improvement        │
├─ Diet Settings ─────────────┤
│  Preference: Japanese       │
│  Restrictions: Gluten-free  │
├─ Exercise Habits ───────────┤
│  Training: 5-6x/week        │
│  Aerobic: 3x/week           │
│  Usual time: 19:00-20:30    │
├─ Environment Settings ──────┤
│  Pollen allergy: Yes (Cedar)│
│  Pressure sensitivity: High │
├─ Notifications ─────────────┤
│  Daily: 6:00 AM             │
│  Quick check-in: Optional   │
├─ Language ──────────────────┤
│  🇯🇵 Japanese / 🇺🇸 English   │
├─ HealthKit ─────────────────┤
│  ✅ Connected               │
│  📊 Syncing data            │
├─────────────────────────────┤
│  [Edit Profile]             │
│  [Settings]                 │
│  [Help & Support]           │
└─────────────────────────────┘
```

---

## 🔔 通知仕様

### 毎朝の定期通知

**日本語メッセージ（天気に応じて）:**

- 晴れ: 「快晴です！今日のアドバイス準備できました」
- 曇り: 「おはようございます！今日も健康的な 1 日を」
- 雨: 「雨の朝ですが、今日のアドバイス確認しましょう」
- 寒い: 「寒い朝です。温かくして、今日の Tempo を確認」
- 暖かい: 「気持ちいい朝です！今日のアドバイスをチェック」

**英語メッセージ（天気に応じて）:**

- 晴れ: "Beautiful morning! Your daily advice is ready"
- 曇り: "Good morning! Let's make today healthy"
- 雨: "Rainy morning. Check your Tempo for today"
- 寒い: "Cold morning. Stay warm and check your advice"
- 暖かい: "Great morning! Your health tips are waiting"

**設定:**

- デフォルト時刻: 6:00（ユーザー変更可能）
- 曜日選択可能（デフォルト: 毎日）
- 通知メッセージは設定言語で表示
- 天気・気温に応じて自動でメッセージ選択

---

## 🎯 ユーザーフロー

### 初回起動

```
アプリ起動
  ↓
オンボーディング（3-5画面）
  - Tempo AIの紹介
  - データの統合方法
  - AIの分析内容
  - 提供されるプラン
  - データプライバシーの説明
  ↓
権限リクエスト
  - HealthKit
  - 位置情報
  - 通知
  ↓
プロフィール設定
  - 基本情報（年齢、身長、体重、性別）
  - 居住地（国、都市）← 食文化適応のため
  - 目標（疲労回復、集中力向上など）
  - 食事設定（好み、制限）
  - 運動習慣（種別、頻度、時間帯）
  - 環境設定（花粉アレルギー、気圧敏感度）
  ↓
初回分析実行（10-15秒）
  - HealthKitデータ収集（過去7日分）
  - 環境データ取得
  - ベースライン計算（平均HRV、安静時心拍など）
  - AIアドバイス生成（居住地の食文化を考慮）
  ↓
ホーム画面
  - 初回アドバイス表示
  - クイックチェックインの案内（任意）
```

### 毎日の利用（2 段階アドバイス）

#### 第 1 段階: データのみで分析（パーソナライズ・文化適応・寄り添い表現）

```
起床
  ↓
通知受信（天気に応じたメッセージ）
  ↓
通知タップ
  ↓
アプリ起動
  ↓
「分析中...」（10-15秒）
  - 今朝のHealthKitデータ自動収集
    - 睡眠、HRV、心拍数、歩数など
    - 起床直後のバイタルデータ（重要）
  ↓
  - 前日のデータ取得
    - 活動量、運動種別、運動時間
    - 最終食事時刻（推定）
    - 就寝時刻
  ↓
  - 過去7日間のトレンド分析
    - HRV平均、安静時心拍平均
    - 活動パターンとバイタルの相関
  ↓
  - 環境データ取得
    - 気圧、花粉、AQI、UV、日の出/入
    - 天気、気温
  ↓
  - ユーザープロフィール確認
    - 居住地（食文化適応）
    - 食事好み・制限
    - アレルギー情報
  ↓
  - AIアドバイス生成（第1段階）
    - 今朝 vs 通常値の比較
    - 前日の活動との関連性分析
    - 環境要因の影響考慮
    - ユーザー固有のパターン活用
    - 居住地の食文化に基づくメニュー提案
    - 寄り添う表現でのアドバイス
    - 多様なウェルネス提案（呼吸法、マッサージなど）
  ↓
今日のアドバイス表示
  - 天気に応じた挨拶
  - モード表示（好調/標準/ケア/休息）
  - 前日の活動を踏まえた説明
  - 具体的な数値比較（今朝 vs 平均）
  - 文化的に適切な食事・運動・過ごし方の推奨
  - 環境アラート（該当時）
  - 「なぜこのアドバイスなのか」の理由
  - 寄り添う提案ベースの表現
  ↓
【ここまでで高度にパーソナライズされたアドバイスが完成】
```

#### 第 2 段階: クイックチェックインで再カスタマイズ（任意）

```
「今日の調子はどうですか？」
  ↓
[答える] or [スキップ]
  ↓
（答えるを選択した場合）
  ↓
クイックチェックイン画面（30秒）
  - 気分（😊😐😔）
  - 疲労度（1-5）
  - 睡眠の質感（⭐️☁️💤）
  - 飲酒記録（🍺❌）
  ↓
「アドバイスを再調整中...」（5秒）
  - ユーザー入力を考慮
  - データと主観のギャップを分析
  - AIアドバイス再生成（第2段階）
  ↓
アドバイス更新
  - より精密にパーソナライズ
  - 「✨あなたの体調に合わせて更新しました」
  - データと体感の両方を考慮
  ↓
詳細を見る（任意）
  ↓
学ぶタブで理解を深める（任意）
```

---

## 🧠 AI パーソナライゼーションロジック

### データ収集層

```
1. 今朝のデータ
   - 睡眠時間、睡眠ステージ
   - 起床時HRV、心拍数、体温
   - 起床時刻

2. 前日のデータ
   - 活動量（歩数、カロリー）
   - 運動種別、時間、強度
   - 最終食事時刻（推定）
   - 就寝時刻

3. 過去7日のトレンド
   - HRV平均値
   - 安静時心拍平均値
   - 睡眠時間平均
   - 活動パターン

4. ユーザープロフィール
   - 運動習慣（頻度、種別、時間帯）
   - 食事設定
   - 環境感受性
   - 居住地（食文化適応）

5. 環境データ
   - 天気、気温
   - 気圧、花粉、AQI
```

### 分析層

```
1. 偏差分析
   今朝の値 vs 過去7日平均
   → 標準偏差の何%か計算

2. 因果関係分析
   前日の活動 → 今朝のバイタル
   → 相関パターンの検出

3. 環境影響分析
   気圧、花粉 → バイタルへの影響
   → ユーザー固有の感受性考慮

4. パターン学習
   「筋トレ翌日はHRV-8%」
   → 過去データから学習

5. 文化的適応
   居住地 → 食材・料理の選択
   → 実現可能性の向上
```

### アドバイス生成層

```
1. コンテキスト構築
   - 今朝の状態
   - 前日の過ごし方
   - 通常値との比較
   - 環境要因
   - 天気・気温
   - 居住地の食文化

2. 理由の明確化
   「なぜこのアドバイスなのか」
   → 数値と因果関係で説明

3. 具体的な提案（寄り添い表現）
   - 食事メニュー（地域の食文化に基づく）
   - 運動（強度、時間、心拍数）
   - 水分補給（量、タイミング）
   - 回復方法
   - ウェルネス提案（呼吸法、マッサージなど）
   - 「〜がよさそうです」「ぜひ試してみてください」

4. 予測と目標
   「明日のHRV回復予測」
   → 行動と結果の紐付け
```

### 文化適応ロジック

```
居住地別の食材・料理データベース:

【日本】
朝食: 焼き魚、納豆、味噌汁、玄米、海藻
昼食: 定食、蕎麦、うどん、丼物
夕食: 鍋物、焼き魚、煮物、刺身

【北米】
朝食: オートミール、卵、ヨーグルト、アボカドトースト
昼食:サラダ、サンドイッチ、スープ
夕食: グリルチキン、ステーキ、パスタ

【その他地域】
今後追加予定
```

### ウェルネス提案のバリエーション

```
AIプロンプトに含めるべき要素:

1. 呼吸法
   - 4-7-8呼吸法
   - ボックスブリージング
   - 腹式呼吸

2. マッサージ・セルフケア
   - セサミオイルで足裏マッサージ
   - 頭皮マッサージ
   - 首・肩のセルフマッサージ

3. マインドフルネス
   - 5分間の瞑想
   - ボディスキャン
   - 感謝の日記

4. ストレッチ
   - ヨガポーズ
   - 動的ストレッチ
   - 静的ストレッチ

5. 環境調整
   - アロマセラピー（ラベンダー、ペパーミント）
   - 照明調整（暖色系）
   - 音楽療法（自然音、クラシック）

6. 温冷療法
   - 温かいお風呂（38-40°C）
   - 冷水シャワー（回復時）
   - 温冷交代浴

7. 栄養補助
   - ハーブティー（カモミール、ジンジャー）
   - スムージー
   - 発酵食品

ユーザーが普段取り入れないような、
新しい健康習慣を提案することで、
アプリの価値を高める
```

---

## 📚 ユーザー教育システム

### 教育戦略の全体像

#### 1. オンボーディング（初回のみ）

- 3-5 ページの簡潔な説明
- 「何を」「何に基づいて」「何をする」アプリか
- 専門用語は使わない
- データプライバシーの透明性

#### 2. 日常使用での段階的学習

```
レベル1（デフォルト - ホーム画面）
→ シンプル・視覚的
→ 色分け + モード名
→ 「ケアモード」のような分かりやすい表現
→ 数値は表示するが説明は最小限

レベル2（ⓘタップ - 詳細ポップアップ）
→ 中程度の詳細
→ 「なぜこの状態なのか」
→ 数値と平均の比較
→ 指標の意味を簡潔に説明

レベル3（さらに深掘り - 学ぶタブ）
→ 専門的な説明
→ 改善方法
→ 科学的背景
→ 5分程度で読める記事形式
```

#### 3. 学ぶタブ（能動的学習）

- 各指標の詳細記事
- 図解とビジュアル
- パーソナライズされたデータ例
- 3-5 分で読める長さ
- 関連記事へのリンク

#### 4. トレンド画面（発見型学習）

- データを見ながら自然に理解
- 「あなたの場合こうなります」
- パターン認識とフィードバック
- 学ぶタブへの誘導

### 表現ガイドライン

#### 寄り添う表現

```
断定表現 → 提案表現

❌ 「体が回復中です」
⭕️ 「体が回復中のようです」

❌ 「今日は休息が必要です」
⭕️ 「今日は休息が必要そうです」

❌ 「このメニューを食べてください」
⭕️ 「このメニューをぜひ試してみてください」

❌ 「HRVが低いです」
⭕️ 「HRVが通常より低めのようです」

❌ 「運動は避けてください」
⭕️ 「今日は軽めの運動がよさそうです」
```

#### 前向きな表現

```
ネガティブ → ポジティブ

❌ 「注意が必要です」
⭕️ 「気をつけるとよさそうです」

❌ 「危険です」
⭕️ 「控えめがおすすめです」

❌ 「悪い状態です」
⭕️ 「ケアが必要な状態のようです」
```

---

## 📊 データプライバシー

### 収集データ

- **HealthKit**: 睡眠、HRV、心拍、歩数、血中酸素、呼吸数、体温など
- **位置情報**: 環境データ取得のみ（保存しない）
- **プロフィール**: サーバーに暗号化保存
- **クイックチェックイン**: 当日のみ使用、翌日削除
- **過去 7 日のトレンドデータ**: パーソナライズ精度向上のため一時保存

### データ保護

- **HealthKit データ**: デバイスローカルに保存されたまま
- **分析時のみサーバー送信**: 即座に削除（サーバー保存なし）
- **アドバイス履歴**: 7 日間のみ保存、8 日目に自動削除
- **トレンドデータ**: 7 日間のみ保存、統計情報のみ使用
- **第三者共有**: なし
- **クイックチェックイン**: 匿名化、暗号化

### セキュリティ

- **HTTPS 必須**: 全通信 TLS 1.3
- **匿名化**: ユーザー ID は UUID（個人特定不可）
- **API キー管理**: 環境変数で適切に管理
- **データ最小化**: 必要最小限のデータのみ収集

---

## 🔧 技術スタック

### iOS アプリ

- **言語**: Swift 5.9+
- **フレームワーク**: SwiftUI (iOS 16.0+)
- **ヘルスデータ**: HealthKit
- **位置情報**: CoreLocation
- **通知**: UserNotifications

### バックエンド API

- **プラットフォーム**: Cloudflare Workers
- **フレームワーク**: Hono (軽量 TypeScript)
- **AI**: Claude API (Anthropic)
  - モデル: Claude Sonnet 4.5

### 外部 API

- **環境データ**: Open-Meteo API
  - 気温、天気、湿度、気圧
  - UV 指数
  - 日の出/日の入り時刻
  - 花粉情報（Open-Meteo Pollen）
- **大気質**: IQAir API
  - AQI（大気質指数）

### データベース・インフラ

- **データベース**: PostgreSQL (Supabase)
- **接続最適化**: Hyperdrive
- **API ホスティング**: Cloudflare Workers
- **バージョン管理**: GitHub
- **CI/CD**: GitHub Actions

---

## 🔮 将来の検討事項

### データ拡張

- 血液検査データ統合（ビタミン D、鉄分、HbA1c など）
- 持続血糖モニター（CGM）連携
- 食事記録機能（写真 AI 認識）
- 体組成計連携（体脂肪率、筋肉量）

### 機能拡張

- 週次振り返りレポート（パターン分析強化）
- 月次ヘルスレポート（長期トレンド）
- カレンダー連携（ストレス予測）
- SNS・スクリーンタイム連携（メンタルヘルス）
- 予測機能: 「明日の HRV 予測」「今週のベストトレーニング日」

### グローバル展開

- 追加言語対応（スペイン語、フランス語、ドイツ語、中国語、韓国語）
- 地域特有の食材データベース拡充
  - ヨーロッパ各国
  - アジア各国
  - 南米各国
- 文化に応じた健康アドバイス
- 地域の祝祭日・イベント考慮

### 文化適応の進化

- より細かい地域対応（例: 関西 vs 関東）
- 個人の食の好みを AI が学習
- レストランメニューとの連携
- 地域の旬の食材提案

### ウェルネス提案の拡張

- AI 学習による個人の好みの把握
- より多様なセルフケア提案
- 専門家監修のコンテンツ追加
- コミュニティ機能（ユーザー同士の共有）

---

## 📈 パーソナライゼーションの進化

### Phase 1（現在）: ルールベース + データ比較 + 文化適応 + ユーザー教育

- 今朝 vs 過去 7 日平均
- 前日の活動との関連性
- ユーザープロフィール活用
- 居住地の食文化に基づくメニュー提案
- 寄り添う提案ベースの表現
- 段階的な学習システム
- 多様なウェルネス提案

### Phase 2（将来）: 機械学習による予測

- より長期のデータ蓄積（30 日、90 日）
- 季節性の考慮
- 個人別の最適パターン自動発見
- 個人の食の好みの学習
- ウェルネス提案の効果測定と最適化

### Phase 3（将来）: プロアクティブな提案

- 「明日の気圧低下を予測、今日から対策開始」
- 「来週の会議前、最高のコンディションにするプラン」
- 「あなたの体調サイクルから、ベストな旅行日を提案」
- 「今週末、新しいウェルネス習慣を試してみませんか？」

## 🎨 デザインシステム

### カラーパレット

#### プライマリカラー

```
ブランドカラー:
- Primary: #4A90E2 (青 - 信頼感、健康)
- Primary Dark: #2E5C8A
- Primary Light: #7DB3F5

アクセントカラー:
- Accent: #50C878 (緑 - 成長、バランス)
- Warning: #FFB84D (オレンジ - 注意喚起、温かみ)
```

#### モード別カラー

```
🟢 好調モード: #50C878 (緑)
   - 明るく、ポジティブ
   - RGB: 80, 200, 120

🟡 標準モード: #FFB84D (黄色/オレンジ)
   - 中立的、安定
   - RGB: 255, 184, 77

🔵 ケアモード: #4A90E2 (青)
   - 落ち着き、ケア
   - RGB: 74, 144, 226

⚫️ 休息モード: #8E8E93 (グレー)
   - 静か、休息
   - RGB: 142, 142, 147
```

#### テキストカラー

```
- Primary Text: #1C1C1E (ほぼ黒)
- Secondary Text: #8E8E93 (グレー)
- Tertiary Text: #C7C7CC (薄いグレー)
- Link: #4A90E2 (青)
```

#### 背景カラー

```
Light Mode:
- Background: #FFFFFF (白)
- Secondary Background: #F2F2F7 (薄いグレー)
- Card Background: #FFFFFF (白 + シャドウ)

Dark Mode (将来対応):
- Background: #000000 (黒)
- Secondary Background: #1C1C1E
- Card Background: #2C2C2E
```

### タイポグラフィ

#### フォント

```
システムフォント使用:
- iOS: SF Pro (San Francisco)
- 日本語: Hiragino Sans / ヒラギノ角ゴシック
- 英語: SF Pro Text / SF Pro Display

ウェイト:
- Regular: 400 (本文)
- Medium: 500 (強調)
- Semibold: 600 (見出し)
- Bold: 700 (タイトル)
```

#### テキストスタイル

```
Large Title: 34pt / Semibold
Title 1: 28pt / Semibold
Title 2: 22pt / Semibold
Title 3: 20pt / Semibold
Headline: 17pt / Semibold
Body: 17pt / Regular
Callout: 16pt / Regular
Subheadline: 15pt / Regular
Footnote: 13pt / Regular
Caption 1: 12pt / Regular
Caption 2: 11pt / Regular
```

### アイコン

#### アイコンスタイル

```
- SF Symbols使用（iOS標準）
- カスタムアイコンはSF Symbolsのスタイルに準拠
- 線の太さ: Medium (デフォルト)
- サイズ: 20pt, 24pt, 28pt（用途に応じて）
```

#### 主要アイコン

```
🏠 今日: house.fill
📅 履歴: calendar
📈 傾向: chart.line.uptrend.xyaxis
📚 学ぶ: book.fill
👤 私: person.fill

💤 睡眠: bed.double.fill
❤️ 心拍: heart.fill
💪 運動: figure.run
🍳 食事: fork.knife
💧 水分: drop.fill
🌿 過ごし方: leaf.fill
```

### スペーシング

#### マージン・パディング

```
XXS: 4pt
XS: 8pt
S: 12pt
M: 16pt
L: 24pt
XL: 32pt
XXL: 48pt
```

### シャドウ

#### カードシャドウ

```
Light Mode:
- Shadow Color: #000000
- Opacity: 0.08
- Offset: (0, 2)
- Radius: 8pt

Dark Mode:
- Shadow Color: #000000
- Opacity: 0.3
- Offset: (0, 2)
- Radius: 8pt
```

### アニメーション

#### トランジション

```
Standard: 0.3秒 / ease-in-out
Quick: 0.2秒 / ease-out
Slow: 0.5秒 / ease-in-out

Spring Animation:
- Damping: 0.8
- Response: 0.5
```

---
