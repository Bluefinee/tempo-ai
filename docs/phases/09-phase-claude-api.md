# Phase 9: Claude API統合設計書

**フェーズ**: 9 / 14  
**Part**: B（バックエンド）  
**前提フェーズ**: Phase 7（Backend基盤）、Phase 8（外部API統合）

---

## このフェーズで実現すること

1. **プロンプト構造**の実装（Layer 1〜3）
2. **Claude Sonnet**呼び出し（メインアドバイス用）
3. **Claude Haiku**呼び出し（追加アドバイス用）
4. **Prompt Caching**の設定
5. **JSONパース**とバリデーション

---

## 完了条件

- [ ] Claude Sonnet でメインアドバイスが生成される
- [ ] Claude Haiku で追加アドバイスが生成される
- [ ] プロンプトが3層構造（システム、例文、ユーザーデータ）で構成される
- [ ] Prompt Cachingが有効になっている
- [ ] 生成されたJSONが正しくパースされる
- [ ] Mockレスポンスが実際のAI生成に置き換わる

---

## プロンプト構造

### 3層構造

```
┌─────────────────────────────────────────────────────┐
│ Layer 1: システムプロンプト（静的・キャッシュ対象）    │
│ - 役割定義                                          │
│ - 禁止事項                                          │
│ - トーン・文体指定                                   │
│ - 出力JSON形式                                      │
│ - 約1,500トークン                                   │
│ - cache_control: { type: "ephemeral" }             │
├─────────────────────────────────────────────────────┤
│ Layer 2: 関心ごと別例文（動的選択・キャッシュ対象）    │
│ - ユーザーの優先タグに基づいて選択                   │
│ - 2つの例文（良好版・疲労版）                        │
│ - 約2,000トークン                                   │
│ - cache_control: { type: "ephemeral" }             │
├─────────────────────────────────────────────────────┤
│ Layer 3: ユーザーデータ（動的・キャッシュなし）       │
│ - プロフィール情報                                   │
│ - HealthKitデータ                                   │
│ - 気象・環境データ                                   │
│ - 過去の提案履歴                                    │
│ - 約500-800トークン                                 │
└─────────────────────────────────────────────────────┘
```

---

## ディレクトリ構造

```
backend/src/
├── services/
│   └── claude.ts           # Claude API呼び出し
├── prompts/
│   ├── system.ts           # Layer 1: システムプロンプト
│   └── examples/           # Layer 2: 関心ごと別例文
│       ├── fitness.ts
│       ├── beauty.ts
│       ├── mental.ts
│       ├── work.ts
│       ├── nutrition.ts
│       └── sleep.ts
└── utils/
    └── prompt.ts           # プロンプト組み立て
```

---

## モデル選定

| 用途 | モデル | 理由 |
|------|--------|------|
| メインアドバイス | claude-sonnet-4-20250514 | 複雑な分析、パーソナライズ |
| 追加アドバイス（昼・夕） | claude-haiku-4-5-20251001 | 短文、低コスト |

---

## Layer 1: システムプロンプト

### 含める内容

1. **役割定義**: Tempo AIのヘルスケアアドバイザー
2. **キャラクター**: 「年上の落ち着いた優しいお姉さん」
3. **禁止事項**: 医学的診断、処方薬提案、絵文字使用など
4. **トーンルール**: 敬語ベース、温かい励まし
5. **アドバイスバランス**: ベース60-70%、タグ反映30-40%
6. **データ統合の指針**: 複数データの掛け合わせ分析
7. **出力JSON形式**: 構造とフィールドの説明

### キャッシュ設定

```typescript
{
  type: "text",
  text: systemPrompt,
  cache_control: { type: "ephemeral" }
}
```

---

## Layer 2: 関心ごと別例文

### 例文の種類

各関心ごとに2パターン:

- **良好版**: HRV高め、睡眠良好、アクティブ傾向
- **疲労版**: HRV低め、睡眠不足、回復必要

### 例文選択ロジック

```typescript
const getExamplesForInterest = (primaryInterest: Interest): string => {
  switch (primaryInterest) {
    case "fitness":
      return fitnessExamples;
    case "beauty":
      return beautyExamples;
    case "mental_health":
      return mentalExamples;
    case "work_performance":
      return workExamples;
    case "nutrition":
      return nutritionExamples;
    case "sleep":
      return sleepExamples;
    default:
      return fitnessExamples; // デフォルト
  }
};
```

### キャッシュ設定

```typescript
{
  type: "text",
  text: examples,
  cache_control: { type: "ephemeral" }
}
```

---

## Layer 3: ユーザーデータ

### 含める情報

```typescript
const buildUserDataPrompt = (params: {
  userProfile: UserProfile;
  healthData: HealthData;
  weatherData?: WeatherData;
  airQualityData?: AirQualityData;
  context: RequestContext;
}): string => {
  return `
<user_data>
  <profile>
    ニックネーム: ${params.userProfile.nickname}
    年齢: ${params.userProfile.age}歳
    性別: ${formatGender(params.userProfile.gender)}
    体重: ${params.userProfile.weightKg}kg
    身長: ${params.userProfile.heightCm}cm
    職業: ${formatOccupation(params.userProfile.occupation)}
    生活リズム: ${formatLifestyle(params.userProfile.lifestyleRhythm)}
    運動習慣: ${formatExercise(params.userProfile.exerciseFrequency)}
    関心ごと: ${params.userProfile.interests.join(", ")}
  </profile>

  <health_data>
    日付: ${params.healthData.date}
    
    睡眠データ:
    - 就寝: ${params.healthData.sleep?.bedtime ?? "不明"}
    - 起床: ${params.healthData.sleep?.wakeTime ?? "不明"}
    - 睡眠時間: ${params.healthData.sleep?.durationHours ?? "不明"}時間
    - 深い睡眠: ${params.healthData.sleep?.deepSleepHours ?? "不明"}時間
    - 中途覚醒: ${params.healthData.sleep?.awakenings ?? "不明"}回
    
    朝のバイタル:
    - 安静時心拍数: ${params.healthData.morningVitals?.restingHeartRate ?? "不明"}bpm
    - HRV: ${params.healthData.morningVitals?.hrvMs ?? "不明"}ms
    
    昨日の活動:
    - 歩数: ${params.healthData.yesterdayActivity?.steps ?? "不明"}歩
    - 運動: ${params.healthData.yesterdayActivity?.workoutType ?? "なし"}
    
    週間トレンド:
    - 平均睡眠時間: ${params.healthData.weekTrends?.avgSleepHours ?? "不明"}時間
    - 平均HRV: ${params.healthData.weekTrends?.avgHrv ?? "不明"}ms
    - 平均歩数: ${params.healthData.weekTrends?.avgSteps ?? "不明"}歩
  </health_data>

  <environment>
    ${params.weatherData ? `
    天気: ${params.weatherData.condition}
    気温: ${params.weatherData.tempCurrentC}℃（最高${params.weatherData.tempMaxC}℃/最低${params.weatherData.tempMinC}℃）
    湿度: ${params.weatherData.humidityPercent}%
    気圧: ${params.weatherData.pressureHpa}hPa
    UV指数: ${params.weatherData.uvIndex}
    降水確率: ${params.weatherData.precipitationProbability}%
    ` : "気象データ: 取得できませんでした"}
    
    ${params.airQualityData ? `
    AQI: ${params.airQualityData.aqi}
    PM2.5: ${params.airQualityData.pm25}μg/m³
    ` : "大気汚染データ: 取得できませんでした"}
  </environment>

  <context>
    現在時刻: ${params.context.currentTime}
    曜日: ${params.context.dayOfWeek}
    月曜日: ${params.context.isMonday ? "はい" : "いいえ"}
    過去2週間の今日のトライ: ${params.context.recentDailyTries.join(", ") || "なし"}
    先週の今週のトライ: ${params.context.lastWeeklyTry || "なし"}
  </context>
</user_data>

上記のデータに基づいて、今日のアドバイスをJSON形式で生成してください。
`;
};
```

---

## Claude API呼び出し

### メインアドバイス生成

```typescript
import Anthropic from "@anthropic-ai/sdk";

export const generateMainAdvice = async (
  params: GenerateAdviceParams
): Promise<DailyAdvice> => {
  const client = new Anthropic({ apiKey: params.apiKey });

  const systemPrompt = buildSystemPrompt();
  const examples = getExamplesForInterest(params.userProfile.interests[0]);
  const userData = buildUserDataPrompt(params);

  const response = await client.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 4096,
    system: [
      {
        type: "text",
        text: systemPrompt,
        cache_control: { type: "ephemeral" },
      },
      {
        type: "text",
        text: examples,
        cache_control: { type: "ephemeral" },
      },
    ],
    messages: [
      {
        role: "user",
        content: userData,
      },
    ],
  });

  return parseAdviceResponse(response);
};
```

### 追加アドバイス生成

```typescript
export const generateAdditionalAdvice = async (
  params: AdditionalAdviceParams
): Promise<AdditionalAdvice> => {
  const client = new Anthropic({ apiKey: params.apiKey });

  const response = await client.messages.create({
    model: "claude-haiku-4-5-20251001",
    max_tokens: 1024,
    system: buildAdditionalAdviceSystemPrompt(),
    messages: [
      {
        role: "user",
        content: buildAdditionalAdviceUserPrompt(params),
      },
    ],
  });

  return parseAdditionalAdviceResponse(response);
};
```

---

## JSONパース

### パース関数

```typescript
const parseAdviceResponse = (response: Anthropic.Message): DailyAdvice => {
  const textContent = response.content.find((c) => c.type === "text");
  if (!textContent || textContent.type !== "text") {
    throw new Error("No text content in response");
  }

  // JSONブロックを抽出（```json ... ``` の場合も考慮）
  let jsonString = textContent.text;
  const jsonMatch = jsonString.match(/```json\s*([\s\S]*?)\s*```/);
  if (jsonMatch) {
    jsonString = jsonMatch[1];
  }

  const parsed = JSON.parse(jsonString);
  
  // バリデーション
  validateDailyAdvice(parsed);
  
  return parsed as DailyAdvice;
};
```

### バリデーション

```typescript
const validateDailyAdvice = (data: unknown): void => {
  if (typeof data !== "object" || data === null) {
    throw new Error("Invalid response: not an object");
  }

  const advice = data as Record<string, unknown>;

  // 必須フィールドの確認
  if (typeof advice.greeting !== "string") {
    throw new Error("Invalid response: missing greeting");
  }
  if (typeof advice.condition !== "object") {
    throw new Error("Invalid response: missing condition");
  }
  // ... 他のフィールドも同様に検証
};
```

---

## エラーハンドリング

### エラー種別

| エラー | 対応 |
|--------|------|
| API認証エラー | ログ出力、500エラー返却 |
| レート制限 | リトライ or フォールバック |
| JSONパースエラー | リトライ（1回）、失敗時はフォールバック |
| タイムアウト | フォールバック |

### フォールバックアドバイス

AI生成が失敗した場合に返す汎用アドバイス:

```typescript
const fallbackAdvice: DailyAdvice = {
  greeting: `${nickname}さん、おはようございます`,
  condition: {
    summary: "今日も一日、あなたのペースで過ごしていきましょう。",
    detail: "本日のアドバイスを生成できませんでした。ヘルスケアデータと環境情報を確認して、また後でお試しください。",
  },
  actionSuggestions: [
    {
      icon: "hydration",
      title: "こまめな水分補給を",
      detail: "1日を通して、こまめに水分を補給しましょう。",
    },
  ],
  closingMessage: "今日も良い一日をお過ごしください。",
  dailyTry: {
    title: "深呼吸を3回",
    summary: "ゆっくりと深呼吸をして、心を落ち着けてみませんか？",
    detail: "...",
  },
  weeklyTry: null,
  generatedAt: new Date().toISOString(),
  timeSlot: "morning",
};
```

---

## コスト見積もり

### メインアドバイス（Sonnet）

| 項目 | トークン数 | 単価 | コスト |
|------|-----------|------|--------|
| 入力（キャッシュヒット） | ~3,500 | $0.30/1M × 0.1 | $0.000105 |
| 入力（キャッシュミス） | ~500 | $3.00/1M | $0.0015 |
| 出力 | ~1,500 | $15.00/1M | $0.0225 |
| **小計** | | | **~$0.024** |

### 追加アドバイス（Haiku）

| 項目 | トークン数 | 単価 | コスト |
|------|-----------|------|--------|
| 入力 | ~500 | $0.80/1M | $0.0004 |
| 出力 | ~300 | $4.00/1M | $0.0012 |
| **小計** | | | **~$0.002** |

### 月間目安（1日1回利用、30日）

- メインのみ: ~$0.72/月/ユーザー
- メイン + 追加2回: ~$0.84/月/ユーザー

---

## 環境変数

### wrangler.toml

```toml
[vars]
ENVIRONMENT = "production"
```

### Secrets

```bash
wrangler secret put ANTHROPIC_API_KEY
```

---

## 今後のフェーズとの関係

### Phase 10で使用

- iOS側からリクエストを受けて実際にアドバイス生成

### Phase 12で追加

- 追加アドバイスの生成タイミング制御

---

## 関連ドキュメント

- `ai-prompt-design.md` - プロンプト設計の詳細
- `technical-spec.md` - セクション4「Claude API統合」

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-10 | 初版作成 |
