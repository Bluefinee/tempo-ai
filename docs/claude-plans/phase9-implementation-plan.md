# Phase 9 実装計画書：Claude API統合

**作成日**: 2025-12-11  
**フェーズ**: 9 / 14  
**目的**: Claude Sonnet/Haiku APIとプロンプトキャッシングの統合

## 実装概要

### 目標
- 3層プロンプト構造の実装（システム・例文・ユーザーデータ）
- Claude Sonnet API統合（メインアドバイス生成）
- Claude Haiku API統合（追加アドバイス生成）
- Prompt Cachingによるコスト最適化
- 型安全なJSONパース・バリデーション実装

### 完了条件
- [ ] 3層プロンプト構造が正しく実装される
- [ ] Claude Sonnet でメインアドバイスが生成される
- [ ] Claude Haiku で追加アドバイスが生成される
- [ ] Prompt Cachingが有効になっている
- [ ] 生成されたJSONが正しくパースされる
- [ ] Mockレスポンスが実際のAI生成に置き換わる
- [ ] 全テストが通過する

## 技術仕様

### 使用モデル
| 用途 | モデル | 理由 |
|------|--------|------|
| メインアドバイス | claude-sonnet-4-20250514 | 複雑な分析、パーソナライズ |
| 追加アドバイス（昼・夕） | claude-haiku-4-5-20251001 | 短文、低コスト |

### プロンプト構造（3層）

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

## 実装詳細

### Stage 1: プロンプト構造実装

#### ファイル構成
```
backend/src/
├── prompts/
│   ├── system.ts           # Layer 1: システムプロンプト
│   └── examples/           # Layer 2: 関心ごと別例文
│       ├── fitness.ts
│       ├── beauty.ts
│       ├── mental.ts
│       ├── work.ts
│       ├── nutrition.ts
│       └── sleep.ts
├── utils/
│   └── prompt.ts           # Layer 3: プロンプト組み立て
└── types/
    └── claude.ts           # Claude API関連型定義
```

#### 型定義（backend/src/types/claude.ts）
```typescript
export interface GenerateAdviceParams {
  userProfile: UserProfile;
  healthData: HealthData;
  weatherData?: WeatherData;
  airQualityData?: AirQualityData;
  context: RequestContext;
  apiKey: string;
}

export interface AdditionalAdviceParams {
  mainAdvice: DailyAdvice;
  timeSlot: "midday" | "evening";
  userProfile: UserProfile;
  apiKey: string;
}

export interface ClaudePromptLayer {
  type: "text";
  text: string;
  cache_control?: { type: "ephemeral" };
}

export interface RequestContext {
  currentTime: string;
  dayOfWeek: string;
  isMonday: boolean;
  recentDailyTries: string[];
  lastWeeklyTry: string | null;
}
```

#### Layer 1: システムプロンプト（backend/src/prompts/system.ts）
```typescript
export const buildSystemPrompt = (): ClaudePromptLayer => ({
  type: "text",
  text: `あなたはTempo AIの専属ヘルスケアアドバイザーです。

【役割】
- ユーザーの健康データと環境データを分析し、パーソナライズされたアドバイスを提供
- 「年上の落ち着いた優しいお姉さん」として温かく寄り添うトーン
- データの掛け合わせ分析による洞察の提供

【禁止事項】
- 医学的診断や処方薬の提案
- 絵文字の使用
- 過度な心配や不安を煽る表現
- 具体的な数値目標の強制

【トーンルール】
- 敬語ベースの丁寧語（です・ます調）
- 温かい励ましと理解を示す表現
- 押し付けがましくない提案

【アドバイスバランス】
- ベースライン提案: 60-70%（基本的な健康習慣）
- 関心ごと反映: 30-40%（ユーザーの優先興味）

【出力JSON形式】
以下のJSON構造で必ず出力してください：
{
  "greeting": "挨拶メッセージ（ニックネーム使用）",
  "condition": {
    "summary": "今日の体調・状況の要約（1-2文）",
    "detail": "詳細分析（健康データと環境の掛け合わせ）"
  },
  "actionSuggestions": [
    {
      "icon": "hydration|movement|rest|nutrition|mindfulness",
      "title": "提案タイトル（15文字以内）",
      "detail": "詳細説明（50文字以内）"
    }
  ],
  "closingMessage": "締めの励ましメッセージ",
  "dailyTry": {
    "title": "今日のトライタイトル（20文字以内）",
    "summary": "概要説明（30文字以内）",
    "detail": "具体的な実践方法（100文字以内）"
  },
  "weeklyTry": null | {
    "title": "今週のトライタイトル（20文字以内）",
    "summary": "概要説明（30文字以内）",
    "detail": "具体的な実践方法（150文字以内）"
  },
  "generatedAt": "現在のISO時刻",
  "timeSlot": "morning"
}`,
  cache_control: { type: "ephemeral" },
});
```

#### Layer 2: 関心ごと別例文実装
各関心ごとに「良好版」「疲労版」の2パターンを用意

#### Layer 3: ユーザーデータプロンプト（backend/src/utils/prompt.ts）
```typescript
export const buildUserDataPrompt = (params: GenerateAdviceParams): string => {
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
    [健康データの詳細フォーマット]
  </health_data>

  <environment>
    [気象・大気汚染データ]
  </environment>

  <context>
    [リクエストコンテキスト]
  </context>
</user_data>

上記のデータに基づいて、今日のアドバイスをJSON形式で生成してください。`;
};
```

### Stage 2: Claude APIサービス実装

#### Claude APIサービス（backend/src/services/claude.ts）
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
      systemPrompt,
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

### Stage 3: JSONパース・バリデーション

#### レスポンスパース（backend/src/services/claude.ts）
```typescript
const parseAdviceResponse = (response: Anthropic.Message): DailyAdvice => {
  const textContent = response.content.find((c) => c.type === "text");
  if (!textContent || textContent.type !== "text") {
    throw new ClaudeApiError("No text content in response");
  }

  let jsonString = textContent.text;
  const jsonMatch = jsonString.match(/```json\s*([\s\S]*?)\s*```/);
  if (jsonMatch) {
    jsonString = jsonMatch[1];
  }

  try {
    const parsed = JSON.parse(jsonString);
    validateDailyAdvice(parsed);
    return parsed as DailyAdvice;
  } catch (error) {
    throw new ClaudeApiError(
      `Failed to parse Claude response: ${error instanceof Error ? error.message : String(error)}`
    );
  }
};
```

#### バリデーション関数
```typescript
const validateDailyAdvice = (data: unknown): void => {
  if (typeof data !== "object" || data === null) {
    throw new ValidationError("Invalid response: not an object", "root", data);
  }

  const advice = data as Record<string, unknown>;

  // 必須フィールドの確認
  if (typeof advice.greeting !== "string") {
    throw new ValidationError("Invalid response: missing greeting", "greeting", advice.greeting);
  }
  if (typeof advice.condition !== "object") {
    throw new ValidationError("Invalid response: missing condition", "condition", advice.condition);
  }
  // ... 他のフィールドの検証
};
```

#### エラーハンドリング
```typescript
class ClaudeApiError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number = 500,
    public readonly originalError?: Error
  ) {
    super(message);
    this.name = "ClaudeApiError";
  }
}
```

#### フォールバック処理
```typescript
const fallbackAdvice = (userProfile: UserProfile): DailyAdvice => ({
  greeting: `${userProfile.nickname}さん、おはようございます`,
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
    detail: "鼻から4秒で吸って、7秒間息を止め、口から8秒でゆっくり吐き出してみてください。",
  },
  weeklyTry: null,
  generatedAt: new Date().toISOString(),
  timeSlot: "morning",
});
```

### Stage 4: API統合

#### 環境変数設定
```bash
# .dev.vars
ANTHROPIC_API_KEY="your-api-key-here"
```

#### Adviceルート更新（backend/src/routes/advice.ts）
```typescript
// Mockデータ生成を削除し、Claude API呼び出しに置き換え
const advice = await generateMainAdvice({
  userProfile: body.userProfile,
  healthData: body.healthData,
  weatherData: environmentData.weather,
  airQualityData: environmentData.airQuality,
  context: requestContext,
  apiKey: getApiKey(c),
});
```

## テスト戦略

### ユニットテスト
- **プロンプト生成**: Layer別の正しい生成
- **Claude API呼び出し**: モック使用でAPI呼び出し確認
- **JSONパース**: 正常・異常ケースのパース確認
- **バリデーション**: 型安全性の確認

### 統合テスト
- **エンドポイント**: `/api/advice` の完全なフロー
- **エラーハンドリング**: Claude API失敗時のフォールバック
- **パフォーマンス**: レスポンス時間の測定

### テスト実装例
```typescript
describe("Claude API Service", () => {
  describe("generateMainAdvice", () => {
    it("should generate valid advice with proper prompt structure", async () => {
      const mockResponse = createMockClaudeResponse();
      const advice = await generateMainAdvice(mockParams);
      
      expect(advice.greeting).toContain(mockParams.userProfile.nickname);
      expect(advice.timeSlot).toBe("morning");
      expect(advice.actionSuggestions).toHaveLength.greaterThan(0);
    });

    it("should handle API errors gracefully", async () => {
      mockClaudeClient.messages.create.mockRejectedValue(new Error("API Error"));
      
      await expect(generateMainAdvice(mockParams)).rejects.toThrow(ClaudeApiError);
    });
  });
});
```

## 品質チェック項目

### TypeScript
- [ ] 型エラーなし（`npm run typecheck`）
- [ ] `any`型の使用なし
- [ ] 適切な型ガード実装
- [ ] Claude SDK型との整合性

### Linting/Formatting
- [ ] Biome linting pass（`npm run lint`）
- [ ] コードフォーマット適用
- [ ] アロー関数使用
- [ ] DRY原則適用

### Testing
- [ ] 全テストパス（`npm test`）
- [ ] カバレッジ80%以上維持
- [ ] エラーケースのテスト網羅
- [ ] Claude API モックテスト

## パフォーマンス考慮事項

### Prompt Caching効果
- **キャッシュヒット時**: 入力コスト90%削減
- **Layer 1+2**: ~3,500トークンがキャッシュ対象
- **月間コスト**: ~$0.72/月/ユーザー（メインアドバイスのみ）

### レスポンス時間目標
- **通常時**: 3-5秒以内
- **キャッシュヒット**: 2-3秒以内
- **タイムアウト**: 30秒で強制終了

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

## デプロイメント考慮事項

### Cloudflare Workers制約
- Claude SDK互換性確認済み
- 環境変数でのAPIキー管理
- メモリ使用量の監視

### セキュリティ
- APIキーの適切な管理
- ユーザーデータのログ除外
- エラー時の情報漏洩防止

## リスク軽減策

### Claude API可用性
- **対策**: フォールバック処理による継続性確保
- **監視**: API成功率の継続監視

### レスポンス品質
- **対策**: バリデーション強化とリトライ機能
- **監視**: 異常レスポンスの検出

### コスト管理
- **対策**: キャッシングによるコスト最適化
- **監視**: 使用量とコストの追跡

## 成功指標

### 機能指標
- Claude API成功率 > 95%
- レスポンス品質（JSON形式準拠）> 98%
- Prompt Caching効果 > 80%

### 品質指標
- TypeScriptエラー 0件
- テストカバレッジ > 80%
- Lintエラー 0件
- パフォーマンス < 5秒

---

**実装担当**: Claude Code  
**レビュー**: 実装完了後にユーザー確認  
**完了予定**: 当日中