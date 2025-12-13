# Phase 19: トラベルモードAI・リセットポイント設計書

**フェーズ**: 19 / 19  
**Part**: E（トラベルモード）  
**前提フェーズ**: Phase 18（トラベルモードUI）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料
- **[CLAUDE.md](../../CLAUDE.md)** - 開発ガイドライン・基本原則
- **[AI Prompt Design](../ai-prompt-design.md)** - AI設計指針
- **[UI Specification](../ui-spec.md)** - UI設計仕様書
- **[Technical Specification](../technical-spec.md)** - 技術仕様書
- **[Travel Mode & Condition Spec](../travel-mode-condition-spec.md)** - トラベルモード詳細仕様

### 📱 Swift/iOS専用資料
- **[UX Concepts & Principles](../../.claude/ux_concepts.md)** - UX設計原則
- **[Swift Coding Standards](../../.claude/swift-coding-standards.md)** - Swift開発標準

### 🔧 Backend専用資料
- **[TypeScript Hono Standards](../../.claude/typescript-hono-standards.md)** - TypeScript + Hono 開発標準

### ✅ 実装完了後の必須作業
実装完了後は必ず以下を実行してください：

**iOS側**:
```bash
swiftlint
swift-format --lint --recursive ios/
swift test
```

**Backend側**:
```bash
npm run typecheck
npm run lint
npm test
```

---

## このフェーズで実現すること

1. **AIプロンプトのトラベルモード分岐**
2. **リセットポイントの算出ロジック**
3. **「今日のリセットポイント」UI**
4. **トラベルモード時のアドバイス構造変化**
5. **適応ヒントのAI生成**

---

## 完了条件

- [ ] トラベルモードON時にAIプロンプトにトラベルコンテキストが追加される
- [ ] アドバイスがサーカディアンリズム調整中心の内容になる
- [ ] 「今日のリセットポイント」が算出・表示される
- [ ] 適応ヒントがAI生成される
- [ ] **トラベルモード機能完成**

---

## AIプロンプトの分岐

### Layer 3（ユーザーデータ）への追加

トラベルモードON時、プロンプトに `<travel_context>` セクションを追加:

```typescript
const buildUserDataPrompt = (params: GenerateAdviceParams): string => {
  let prompt = buildBaseUserDataPrompt(params);
  
  // トラベルモードON時のみ追加
  if (params.travelContext) {
    prompt += buildTravelContextPrompt(params.travelContext);
  }
  
  return prompt;
};

const buildTravelContextPrompt = (context: TravelContext): string => {
  return `
<travel_context>
  モード: トラベルモード（ON）
  
  拠点（ホーム）:
    都市: ${context.home.city}
    タイムゾーン: ${context.home.timezone}
    現地時刻: ${context.home.localTime}
  
  現在地:
    都市: ${context.current.city}
    タイムゾーン: ${context.current.timezone}
    現地時刻: ${context.current.localTime}
    滞在日数: ${context.stayDays}日目
  
  環境差分:
    時差: ${context.timezoneOffset}時間
    気温差: ${context.tempDiff}°C
    湿度差: ${context.humidityDiff}%
    気圧差: ${context.pressureDiff}hPa
  
  移動方向: ${context.direction} （${context.directionDescription}）
  
  ${context.previous ? `
  直前の滞在地:
    都市: ${context.previous.city}
    滞在期間: ${context.previous.stayDays}日間
  ` : ''}
</travel_context>

【重要】トラベルモードがONのため、以下の点を優先してください：
1. サーカディアンリズムの調整を最優先のアドバイスとする
2. 時差への適応方法（光、カフェイン、食事タイミング）を具体的に提案する
3. 環境差分（気温、湿度、気圧）への対応も含める
4. 通常の健康アドバイスは補助的に
`;
};
```

### 移動方向の判定

```typescript
type TravelDirection = "east" | "west" | "same";

const determineTravelDirection = (
  homeLongitude: number,
  currentLongitude: number
): TravelDirection => {
  const diff = currentLongitude - homeLongitude;
  
  // 経度差を-180〜180に正規化
  const normalizedDiff = ((diff + 540) % 360) - 180;
  
  if (Math.abs(normalizedDiff) < 15) {
    return "same";  // 南北移動または近距離
  } else if (normalizedDiff > 0) {
    return "east";  // 東向き
  } else {
    return "west";  // 西向き
  }
};

const getDirectionDescription = (direction: TravelDirection): string => {
  switch (direction) {
    case "east":
      return "東向き移動：体内時計を進める必要があり、適応に時間がかかりやすい";
    case "west":
      return "西向き移動：体内時計を遅らせる必要があり、比較的適応しやすい";
    case "same":
      return "南北移動または近距離：時差の影響は小さい";
  }
};
```

---

## トラベルモード時のアドバイス構造

### 通常モードとの違い

| 項目 | 通常モード | トラベルモード |
|------|-----------|---------------|
| greeting | 通常の挨拶 | 滞在日数を含む挨拶 |
| condition.summary | 全般的な状態 | リズムのずれ + 適応状況 |
| action_suggestions | 汎用的な提案 | 光/カフェイン/食事タイミング中心 |
| daily_try | 様々なトピック | リズム調整に関連 |
| reset_points | なし | **追加** |
| adaptation_hint | なし | **追加** |

### レスポンス型の拡張

```typescript
interface DailyAdvice {
  greeting: string;
  condition: {
    summary: string;
    detail: string;
  };
  actionSuggestions: ActionSuggestion[];
  closingMessage: string;
  dailyTry: TryContent;
  weeklyTry: TryContent | null;
  generatedAt: string;
  timeSlot: TimeSlot;
  
  // トラベルモード時のみ
  travelMode?: {
    resetPoints: ResetPoint[];
    adaptationHint: string;
    adaptationProgress: {
      currentDay: number;
      estimatedDays: number;
    };
  };
}

interface ResetPoint {
  type: ResetPointType;
  title: string;
  time: string;        // "7:00" 形式
  description: string;
}

type ResetPointType = 
  | "morning_light"    // 朝の光を浴びる
  | "evening_light"    // 夕方の光を避ける
  | "caffeine_cutoff"  // カフェインカットオフ
  | "meal_timing"      // 食事タイミング
  | "bedtime_goal";    // 目標就寝時刻
```

---

## リセットポイントの算出

### 概念

「今日のリセットポイント」は、サーカディアンリズムを現地時間に合わせるための具体的なアクションとタイミング。

### 算出ロジック

```typescript
interface ResetPointCalculatorParams {
  timezoneOffset: number;      // 時差（時間）
  direction: TravelDirection;  // 移動方向
  stayDays: number;           // 滞在日数
  currentLocalTime: Date;      // 現地時刻
  homeSunrise: string;         // 拠点の日の出時刻
  currentSunrise: string;      // 現地の日の出時刻
}

const calculateResetPoints = (
  params: ResetPointCalculatorParams
): ResetPoint[] => {
  const points: ResetPoint[] = [];
  const { timezoneOffset, direction, stayDays } = params;
  
  // 1日に調整できる時差の目安（時間）
  const adjustmentPerDay = direction === "west" ? 1.5 : 1.0;
  const remainingOffset = Math.max(
    0,
    Math.abs(timezoneOffset) - (stayDays - 1) * adjustmentPerDay
  );
  
  // 朝の光を浴びる時間
  const morningLightTime = calculateMorningLightTime(params);
  points.push({
    type: "morning_light",
    title: "朝の光を浴びる",
    time: morningLightTime,
    description: `起床後${morningLightTime}頃に30分以上の日光を。体内時計をリセットする最も効果的な方法です。`,
  });
  
  // 夕方の光を避ける時間（東向き移動の場合）
  if (direction === "east" && remainingOffset > 2) {
    points.push({
      type: "evening_light",
      title: "夕方は光を控える",
      time: "16:00以降",
      description: "夕方以降は明るい光を避け、サングラスの使用も効果的です。",
    });
  }
  
  // カフェインカットオフ
  const caffeineTime = calculateCaffeineCutoff(params);
  points.push({
    type: "caffeine_cutoff",
    title: "カフェインは午前中まで",
    time: caffeineTime,
    description: `${caffeineTime}以降はカフェインを控えて。睡眠の質を守ります。`,
  });
  
  // 食事タイミング
  if (Math.abs(timezoneOffset) >= 6) {
    points.push({
      type: "meal_timing",
      title: "現地時間で食事",
      time: "朝食を現地7-8時に",
      description: "食事のタイミングも体内時計に影響します。現地時間に合わせましょう。",
    });
  }
  
  // 目標就寝時刻
  const bedtimeGoal = calculateBedtimeGoal(params);
  points.push({
    type: "bedtime_goal",
    title: "今夜の目標就寝",
    time: bedtimeGoal,
    description: "無理に早く寝ようとせず、この時刻を目安に。",
  });
  
  return points;
};

const calculateMorningLightTime = (
  params: ResetPointCalculatorParams
): string => {
  const { direction, stayDays, currentSunrise } = params;
  
  // 基本は日の出時刻
  const sunriseHour = parseInt(currentSunrise.split(":")[0]);
  
  // 東向き移動：早めに光を浴びる
  // 西向き移動：少し遅めでもOK
  const adjustedHour = direction === "east" 
    ? Math.max(6, sunriseHour - 1)
    : sunriseHour;
  
  return `${adjustedHour}:00〜${adjustedHour + 1}:00`;
};

const calculateCaffeineCutoff = (
  params: ResetPointCalculatorParams
): string => {
  // 基本は14時、時差が大きい場合は早める
  const baseHour = 14;
  const adjustedHour = Math.abs(params.timezoneOffset) >= 8 
    ? 12 
    : baseHour;
  
  return `${adjustedHour}:00`;
};

const calculateBedtimeGoal = (
  params: ResetPointCalculatorParams
): string => {
  const { timezoneOffset, direction, stayDays } = params;
  
  // 目標：現地の23:00に向けて徐々に調整
  const targetHour = 23;
  const adjustmentPerDay = direction === "west" ? 1.5 : 1.0;
  
  // 初日は時差分ずらす、日ごとに調整
  const offset = Math.max(
    0,
    Math.abs(timezoneOffset) - (stayDays - 1) * adjustmentPerDay
  );
  
  const goalHour = direction === "east"
    ? targetHour - Math.min(offset, 3)  // 早めに寝る
    : targetHour + Math.min(offset, 3); // 遅めに寝る
  
  return `${Math.round(goalHour)}:00`;
};
```

---

## 「今日のリセットポイント」UI

### サーカディアンリズム詳細画面への追加

```
┌─────────────────────────────────────────┐
│ ← サーカディアンリズム                   │
├─────────────────────────────────────────┤
│                                         │
│ [24時間サークル図]                       │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 🎯 今日のリセットポイント        ← NEW! │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ ☀️ 朝の光を浴びる                   │ │
│ │    7:00〜8:00                       │ │
│ │    起床後に30分以上の日光を...      │ │
│ ├─────────────────────────────────────┤ │
│ │ ☕ カフェインは午前中まで           │ │
│ │    12:00                            │ │
│ │    12時以降はカフェインを控えて...  │ │
│ ├─────────────────────────────────────┤ │
│ │ 🍽️ 現地時間で食事                   │ │
│ │    朝食を現地7-8時に                │ │
│ │    食事のタイミングも体内時計に...  │ │
│ ├─────────────────────────────────────┤ │
│ │ 🌙 今夜の目標就寝                   │ │
│ │    23:00                            │ │
│ │    無理に早く寝ようとせず...        │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────────────────────────────────────── │
│                                         │
│ 📊 週間トレンド                         │
│ （以下、通常のコンテンツ）              │
└─────────────────────────────────────────┘
```

### 実装

```swift
struct ResetPointsSection: View {
    let resetPoints: [ResetPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Image(systemName: "target")
                Text("今日のリセットポイント")
                    .font(.headline)
            }
            
            // リセットポイントリスト
            VStack(spacing: 0) {
                ForEach(resetPoints) { point in
                    ResetPointRow(point: point)
                    
                    if point.id != resetPoints.last?.id {
                        Divider()
                    }
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

struct ResetPointRow: View {
    let point: ResetPoint
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // アイコン
            Image(systemName: point.type.iconName)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                // タイトル + 時間
                HStack {
                    Text(point.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(point.time)
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
                
                // 説明
                Text(point.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

extension ResetPointType {
    var iconName: String {
        switch self {
        case .morningLight: return "sun.max"
        case .eveningLight: return "sun.haze"
        case .caffeineCutoff: return "cup.and.saucer"
        case .mealTiming: return "fork.knife"
        case .bedtimeGoal: return "moon.zzz"
        }
    }
}
```

---

## 適応ヒントのAI生成

### プロンプトへの追加

```typescript
const buildAdaptationHintPrompt = (context: TravelContext): string => {
  return `
また、以下の情報を踏まえて「adaptation_hint」として1-2文の適応アドバイスを生成してください：

- 移動方向: ${context.direction}（${context.directionDescription}）
- 時差: ${context.timezoneOffset}時間
- 滞在日数: ${context.stayDays}日目
- 推定適応日数: 約${context.estimatedAdaptationDays}日

適応ヒントは、移動方向に特化したアドバイスにしてください。
例：
- 西向き移動なら「体内時計を遅らせる必要があり、比較的適応しやすいです。夜更かし気味で過ごすのがコツです」
- 東向き移動なら「体内時計を進める必要があり、朝の光が特に重要です。早めに寝る努力をしましょう」
`;
};
```

### レスポンス例

```json
{
  "travelMode": {
    "resetPoints": [
      {
        "type": "morning_light",
        "title": "朝の光を浴びる",
        "time": "7:00〜8:00",
        "description": "起床後に30分以上の日光を。体内時計をリセットする最も効果的な方法です。"
      },
      {
        "type": "caffeine_cutoff",
        "title": "カフェインは午前中まで",
        "time": "12:00",
        "description": "12時以降はカフェインを控えて。睡眠の質を守ります。"
      },
      {
        "type": "bedtime_goal",
        "title": "今夜の目標就寝",
        "time": "23:00",
        "description": "無理に早く寝ようとせず、この時刻を目安に。"
      }
    ],
    "adaptationHint": "西向き移動は体内時計を遅らせる適応なので、比較的スムーズです。夜更かし気味に過ごしながら、朝の光で徐々にリセットしていきましょう。",
    "adaptationProgress": {
      "currentDay": 3,
      "estimatedDays": 10
    }
  }
}
```

---

## Backend実装

### routes/advice.ts の拡張

```typescript
app.post("/", async (c) => {
  const body = await c.req.json<AdviceRequest>();
  
  // トラベルモードの判定
  const isTravelMode = body.travelMode?.isEnabled ?? false;
  
  let advice: DailyAdvice;
  
  if (isTravelMode && body.travelContext) {
    // トラベルモード用のプロンプトで生成
    advice = await generateTravelModeAdvice(body);
  } else {
    // 通常モードの生成
    advice = await generateMainAdvice(body);
  }
  
  return c.json(advice);
});

const generateTravelModeAdvice = async (
  params: AdviceRequest
): Promise<DailyAdvice> => {
  const { travelContext } = params;
  
  // リセットポイントを算出
  const resetPoints = calculateResetPoints({
    timezoneOffset: travelContext.timezoneOffset,
    direction: travelContext.direction,
    stayDays: travelContext.stayDays,
    currentLocalTime: new Date(),
    homeSunrise: travelContext.home.sunrise,
    currentSunrise: travelContext.current.sunrise,
  });
  
  // AI生成
  const systemPrompt = buildSystemPrompt();
  const examples = getTravelModeExamples();  // トラベルモード用の例文
  const userData = buildUserDataPrompt(params);
  
  const response = await client.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 4096,
    system: [
      { type: "text", text: systemPrompt, cache_control: { type: "ephemeral" } },
      { type: "text", text: examples, cache_control: { type: "ephemeral" } },
    ],
    messages: [{ role: "user", content: userData }],
  });
  
  const baseAdvice = parseAdviceResponse(response);
  
  // トラベルモード固有のフィールドを追加
  return {
    ...baseAdvice,
    travelMode: {
      resetPoints,
      adaptationHint: baseAdvice.travelMode?.adaptationHint ?? "",
      adaptationProgress: {
        currentDay: travelContext.stayDays,
        estimatedDays: estimateAdaptationDays(travelContext.timezoneOffset),
      },
    },
  };
};
```

---

## iOS実装

### HomeViewModelの拡張

```swift
@MainActor
class HomeViewModel: ObservableObject {
    @Published var advice: DailyAdvice?
    @Published var resetPoints: [ResetPoint] = []
    @Published var adaptationHint: String?
    
    private let travelModeManager: TravelModeManagerProtocol
    private let locationHistoryManager: LocationHistoryManagerProtocol
    
    func loadAdvice() async {
        // トラベルコンテキストを構築
        let travelContext = buildTravelContext()
        
        let request = AdviceRequest(
            // ... 通常のパラメータ
            travelMode: TravelModeRequest(
                isEnabled: travelModeManager.isEnabled
            ),
            travelContext: travelContext
        )
        
        let response = try await apiClient.generateAdvice(request: request)
        
        advice = response
        
        // トラベルモード固有のデータを抽出
        if let travelMode = response.travelMode {
            resetPoints = travelMode.resetPoints
            adaptationHint = travelMode.adaptationHint
        }
    }
    
    private func buildTravelContext() -> TravelContext? {
        guard travelModeManager.isEnabled,
              let home = travelModeManager.homeLocation,
              let current = locationHistoryManager.currentLocation else {
            return nil
        }
        
        // 環境データを取得（キャッシュまたはAPI）
        // ... 
        
        return TravelContext(
            home: TravelLocationData(from: home),
            current: TravelLocationData(from: current),
            stayDays: current.stayDays,
            timezoneOffset: calculateTimezoneOffset(home: home, current: current),
            direction: determineTravelDirection(home: home, current: current),
            // ...
        )
    }
}
```

---

## テスト観点

### 正常系

- トラベルモードON → プロンプトにトラベルコンテキスト追加
- リセットポイントが正しく算出される
- 適応ヒントがAI生成される
- UIに正しく表示される

### 移動方向

- 東向き移動（例: 東京→ニューヨーク）
- 西向き移動（例: 東京→ロンドン）
- 南北移動（時差なし）

### 境界値

- 時差1時間（軽微）
- 時差6時間（中程度）
- 時差12時間（最大）
- 滞在1日目
- 滞在7日目（適応完了に近い）

### エラー系

- トラベルコンテキスト不完全時のフォールバック
- AI生成失敗時のデフォルトヒント

---

## 完成状態の確認

### トラベルモード完全フロー

```
1. 設定画面でトラベルモードをON
2. ホームロケーションが設定済み
3. 現在地が拠点から離れている
    │
    ↓
4. ホーム画面:
   - ヘッダーにトラベルインジケーター
   - 時差表示
   - 「適応の目安」カード
   - アドバイスがリズム調整中心
    │
    ↓
5. コンディション画面:
   - 環境差分セクション（トップ）
   - 通常のセクション
    │
    ↓
6. サーカディアンリズム詳細:
   - 24時間サークル
   - 「今日のリセットポイント」セクション
   - 週間トレンド
   - リズム安定度
   - ヒント（トラベルモード対応）
```

---

## 関連ドキュメント

- `18-phase-travel-mode-ui.md` - トラベルモードUI
- `17-phase-location-management.md` - ロケーション管理
- `09-phase-claude-api.md` - Claude API統合
- `travel-mode-condition-spec.md` - トラベルモード詳細仕様
- `ai-prompt-design.md` - AIプロンプト設計

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-11 | 初版作成 |
