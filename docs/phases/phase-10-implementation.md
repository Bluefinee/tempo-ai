# Phase 10: Backend調整 + エネルギーバッテリー 実装計画

**作成日**: 2025年12月31日
**ブランチ名**: `feature/phase-10-energy-battery`

---

## 概要

Phase 10は旧仕様（Phase 7）から新仕様への調整とエネルギーバッテリー機能の追加を行います。

### 削除対象
- 追加アドバイス生成ロジック（Claude Haiku使用）
- 今週のトライ生成ロジック

### 追加対象
- `insight`フィールド（因果関係を明示したAIの見立て）
- `scores`フィールド（HRV, 睡眠, リズム, 活動量の各スコア）
- `energyComment`フィールド（エネルギーレベルに応じたAIコメント）
- iOS: `EnergyBatteryView`コンポーネント

---

## 完了条件（phases.mdより）

- [ ] Claude Sonnetのみ使用（Haiku不使用）
- [ ] `insight`フィールドが因果関係を含む
- [ ] `scores`フィールドが出力に含まれる
- [ ] ホーム画面上部にエネルギーレベル（HRVスコア%）表示
- [ ] エネルギーに応じたAIコメント表示
- [ ] ai-prompt-spec.mdに準拠

---

## Stage 1: Backend - 不要コードの削除

### 目的
追加アドバイス（Claude Haiku）関連コードを完全に削除

### 変更ファイル

| ファイル | 変更内容 |
|----------|----------|
| `backend/src/services/claude.ts` | `generateAdditionalAdvice()`, `parseAdditionalAdviceResponse()`, `validateAdditionalAdvice()`, `createFallbackAdditionalAdvice()` を削除 |
| `backend/src/prompts/system.ts` | `buildAdditionalAdviceSystemPrompt()` を削除 |
| `backend/src/utils/prompt.ts` | `buildAdditionalAdviceUserPrompt()` を削除 |
| `backend/src/types/domain.ts` | `AdditionalAdviceSchema` を削除 |
| `backend/src/types/response.ts` | `AdviceResponseDataSchema` から `additionalAdvice` フィールドを削除 |
| `backend/src/types/claude.ts` | `AdditionalAdviceParams`, `AdditionalAdvice` インターフェースを削除（存在する場合） |
| `backend/src/routes/advice.ts` | 追加アドバイス呼び出しロジックを削除 |

### 完了条件
- [ ] 追加アドバイス関連コードが完全に削除
- [ ] `npm run typecheck` パス
- [ ] `npm run lint` パス

---

## Stage 2: Backend - 新しい型定義の追加

### 目的
`scores`, `insight`, `energyComment`の型定義を追加

### 変更ファイル

| ファイル | 変更内容 |
|----------|----------|
| `backend/src/types/domain.ts` | `HealthScoresSchema`, `DailyAdviceSchema`更新 |
| `backend/src/types/request.ts` | `HealthDataSchema`に`scores`, `rhythmStability`追加 |

### 新しい型定義

```typescript
// domain.ts
export const HealthScoresSchema = z.object({
  hrv: z.number().int().min(0).max(100),
  sleep: z.number().int().min(0).max(100),
  rhythm: z.number().int().min(0).max(100),
  activity: z.number().int().min(0).max(100),
});

// DailyAdviceSchemaの更新
export const DailyAdviceSchema = z.object({
  greeting: z.string().min(1),
  energyComment: z.string().min(1),  // 新規
  condition: z.object({
    summary: z.string().min(1),
    detail: z.string().min(1),
  }),
  insight: z.string().min(1),  // 新規
  dailyTry: z.object({
    title: z.string().min(1),
    detail: z.string().min(1),
  }),
  closingMessage: z.string().min(1),
  scores: HealthScoresSchema,  // 新規（必須）
  generatedAt: z.string(),
  timeSlot: TimeSlotSchema,
});
// 削除: actionSuggestions, weeklyTry
```

### 完了条件
- [ ] 新しい型が正しくコンパイル
- [ ] `npm run typecheck` パス

---

## Stage 3: Backend - システムプロンプトの更新

### 目的
Claude APIへのプロンプトを新しいJSON形式に対応

### 変更ファイル

| ファイル | 変更内容 |
|----------|----------|
| `backend/src/prompts/system.ts` | `buildOutputSchemaPrompt()` を新JSON形式に更新 |
| `backend/src/utils/prompt.ts` | `buildUserDataPrompt()` に scores, rhythm_stability を追加 |

### 新しい出力スキーマ（ai-prompt-spec.mdより）

```json
{
  "greeting": "〇〇さん、おはようございます",
  "energy_comment": "今日は絶好調ですね！",
  "condition": {
    "summary": "3-4文",
    "detail": "8-12文"
  },
  "insight": "3-5文（因果関係を明示）",
  "daily_try": {
    "title": "15文字以内",
    "detail": "3-5文"
  },
  "closing_message": "1-2文"
}
```

### 完了条件
- [ ] 新しいJSON形式でレスポンス生成
- [ ] `npm run typecheck` パス

---

## Stage 4: Backend - Claudeサービスの更新

### 目的
レスポンスパース・バリデーション・フォールバックを新形式に対応

### 変更ファイル

| ファイル | 変更内容 |
|----------|----------|
| `backend/src/services/claude.ts` | `parseAdviceResponse()`, `validateDailyAdvice()`, `createFallbackAdvice()` を更新 |
| `backend/src/utils/mockData.ts` | モックデータを新形式に更新 |

### 主な変更点
1. `parseAdviceResponse()`: `energy_comment` → `energyComment` のキー変換
2. `validateDailyAdvice()`: 新フィールドのバリデーション追加
3. `createFallbackAdvice()`: フォールバックに新フィールド追加

### 完了条件
- [ ] レスポンスパースが正常動作
- [ ] バリデーションが新フィールドを検証
- [ ] フォールバックに新フィールドが含まれる
- [ ] `npm test` パス

---

## Stage 5: Backend - テストの追加

### 目的
新機能のユニットテスト追加

### 変更ファイル

| ファイル | 変更内容 |
|----------|----------|
| `backend/src/services/claude.test.ts` | 新フィールドのテスト追加 |
| `backend/src/types/domain.test.ts` | スキーマバリデーションテスト追加 |

### テストケース
1. 新形式のDailyAdviceが正しくパース
2. energyComment欠落時にエラー
3. insight欠落時にエラー
4. scoresの範囲バリデーション

### 完了条件
- [ ] 全テストパス
- [ ] `npm test` パス

---

## Stage 6: iOS - モデルの更新

### 目的
iOS側のモデルをバックエンドの新形式に対応

### 変更ファイル

| ファイル | 変更内容 |
|----------|----------|
| `ios/TempoAI/TempoAI/Shared/Models/DailyAdvice.swift` | 新フィールド追加、不要フィールド削除 |

### モデル更新

```swift
struct HealthScores: Codable, Hashable {
    let hrv: Int
    let sleep: Int
    let rhythm: Int
    let activity: Int
}

struct DailyAdvice: Codable, Identifiable, Hashable {
    let id: UUID = UUID()
    let greeting: String
    let energyComment: String  // 新規
    let condition: Condition
    let insight: String  // 新規
    let dailyTry: TryContent
    let closingMessage: String
    let scores: HealthScores  // 新規（必須）
    let generatedAt: Date
    let timeSlot: TimeSlot

    // 削除: actionSuggestions, weeklyTry

    private enum CodingKeys: String, CodingKey {
        case greeting
        case energyComment = "energy_comment"
        case condition, insight
        case dailyTry = "daily_try"
        case closingMessage = "closing_message"
        case scores
        case generatedAt = "generated_at"
        case timeSlot = "time_slot"
    }
}

struct TryContent: Codable, Identifiable, Hashable {
    let id: UUID = UUID()
    let title: String
    let detail: String
    // 削除: summary
}

// 削除: AdditionalAdvice, AdviceResponseData.additionalAdvice
```

### 完了条件
- [ ] モデルがコンパイル
- [ ] CodingKeysがバックエンドと一致

---

## Stage 7: iOS - EnergyBatteryViewの作成

### 目的
ホーム画面上部に表示するエネルギーバッテリーコンポーネントを作成

### 新規ファイル

| ファイル | 内容 |
|----------|------|
| `ios/TempoAI/TempoAI/Features/Home/Views/EnergyBatteryView.swift` | 新規コンポーネント |

### コンポーネント仕様（ui-spec.mdより）

```
┌─────────────────────────────┐
│   エネルギー: 85%           │  ← 32pt フォント
│   ████████████░░░           │  ← 8pt 高さ
│   「今日は絶好調ですね！」  │  ← 14pt フォント
└─────────────────────────────┘
```

### 色分けルール

| スコア範囲 | 色 |
|-----------|-----|
| 80-100 | Primary (#7CB342) |
| 60-79 | Primary (#7CB342) |
| 40-59 | Yellow (#FFC107) |
| 20-39 | Orange (#FF9800) |
| 0-19 | Red (#F44336) |

### 完了条件
- [ ] コンポーネントが正しくレンダリング
- [ ] 色分けが仕様通り
- [ ] フォントサイズが仕様通り

---

## Stage 8: iOS - HomeViewの更新

### 目的
EnergyBatteryViewをホーム画面に統合

### 変更ファイル

| ファイル | 変更内容 |
|----------|----------|
| `ios/TempoAI/TempoAI/Features/Home/Views/HomeView.swift` | EnergyBatteryViewを追加 |

### レイアウト構造

```
HomeView
├── HomeHeaderView
├── ScrollView
│   ├── EnergyBatteryView     ← 新規（16pt from header）
│   ├── AdviceSummaryCard     （20pt from energy）
│   ├── DailyTryCard          （24pt from advice）
│   └── Spacer
```

### スペーシング

| 要素間 | 値 |
|--------|-----|
| ヘッダー → エネルギー | 16pt |
| エネルギー → アドバイス | 20pt |
| アドバイス → トライ | 24pt |

### 完了条件
- [ ] EnergyBatteryViewがアドバイスカードの上に表示
- [ ] スペーシングが仕様通り

---

## Stage 9: iOS - モックデータとテストの更新

### 目的
モックデータとテストを新形式に対応

### 変更ファイル

| ファイル | 変更内容 |
|----------|----------|
| `ios/TempoAI/TempoAI/Shared/Models/DailyAdvice.swift` | `createMock()` を更新 |
| `ios/TempoAI/TempoAITests/Mocks/MockAPIClient.swift` | モックアドバイスを更新 |

### 完了条件
- [ ] モックデータに新フィールドが含まれる
- [ ] `swift test` パス

---

## Stage 10: 統合テスト

### 目的
全変更の動作確認

### チェックリスト

**Backend:**
- [ ] `npm run typecheck` パス
- [ ] `npm run lint` パス
- [ ] `npm test` パス

**iOS:**
- [ ] `swiftlint` パス
- [ ] `swift test` パス
- [ ] ビルド成功
- [ ] シミュレーターで正常表示

---

## 依存関係

```
Stage 1 (削除)
    ↓
Stage 2 (型定義)
    ↓
Stage 3 (プロンプト)
    ↓
Stage 4 (サービス)
    ↓
Stage 5 (テスト)
    ↓
Stage 6 (iOSモデル)
    ↓
Stage 7 (EnergyBatteryView)
    ↓
Stage 8 (HomeView)
    ↓
Stage 9 (モック・テスト)
    ↓
Stage 10 (統合テスト)
```

---

## 主要ファイルパス

### Backend
- `/backend/src/services/claude.ts`
- `/backend/src/prompts/system.ts`
- `/backend/src/utils/prompt.ts`
- `/backend/src/types/domain.ts`
- `/backend/src/types/response.ts`
- `/backend/src/routes/advice.ts`
- `/backend/src/utils/mockData.ts`

### iOS
- `/ios/TempoAI/TempoAI/Shared/Models/DailyAdvice.swift`
- `/ios/TempoAI/TempoAI/Features/Home/Views/HomeView.swift`
- `/ios/TempoAI/TempoAI/Features/Home/Views/EnergyBatteryView.swift` (新規)
- `/ios/TempoAI/TempoAITests/Mocks/MockAPIClient.swift`

---

## 追加変更: actionSuggestions・summary削除に伴うUI調整

### Stage 6追加: 関連ビューの更新

以下のビューも更新が必要：

| ファイル | 変更内容 |
|----------|----------|
| `ios/TempoAI/TempoAI/Features/Home/Views/AdviceDetailView.swift` | actionSuggestionsセクションを削除、insightセクションを追加 |
| `ios/TempoAI/TempoAI/Features/Home/Views/DailyTryCard.swift` | summaryの代わりにtitleのみ表示、またはdetailの一部を表示 |
| `ios/TempoAI/TempoAI/Features/Home/Views/ActionSuggestionCard.swift` | 削除（使用されなくなるため） |

### AdviceDetailViewの新しい構造

```
AdviceDetailView
├── condition.detail（コンディション詳細）
├── insight（AIの見立て - 因果関係を明示）← 新規
└── closingMessage（お見送りメッセージ）
```

### DailyTryCardの新しい構造

```
DailyTryCard
├── アイコン + タイトル
├── detail（短縮表示）← summaryの代わり
└── 「詳しく見る」CTA
```

---

## 注意事項

1. **後方互換性不要**: 全ての新フィールド（`scores`, `energyComment`, `insight`）は必須フィールドとして実装
2. **TryContent.summary削除**: 完全に削除し、DailyTryCardはdetailの先頭部分を表示
3. **actionSuggestions削除**: 完全に削除し、AdviceDetailViewはinsightを表示
4. **ActionSuggestionCard.swift削除**: 使用されなくなるため削除
