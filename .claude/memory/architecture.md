# アーキテクチャ詳細

このドキュメントには、TempoAI のアーキテクチャ詳細を記録します。

---

## システム構成図

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ユーザーのデバイス                            │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           React Native (Expo) アプリ                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │   │
│  │  │  HealthKit  │  │ AsyncStorage│  │  Location   │         │   │
│  │  │  (iOS)      │  │  (ローカル)  │  │  Service    │         │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘         │   │
│  │         │                │                │                 │   │
│  │         ▼                ▼                ▼                 │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              ローカル計算エンジン                      │   │   │
│  │  │  ├─ 4スコア算出 (Recovery/Sleep/Rhythm/Energy)       │   │   │
│  │  │  ├─ Baseline計算 (30日移動平均)                       │   │   │
│  │  │  └─ テンプレート文生成                                │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │ HTTPS
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Cloudflare Workers (バックエンド)                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Hono (TypeScript)                                          │   │
│  │  ├─ /api/health   - ヘルスチェック                           │   │
│  │  ├─ /api/weather  - 天気情報 (Open-Meteo経由)                │   │
│  │  └─ /api/advice   - AIアドバイス生成 (Claude経由)            │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
        ┌─────────────────┐     ┌─────────────────┐
        │   Open-Meteo    │     │   Anthropic     │
        │   (天気API)      │     │   Claude API    │
        └─────────────────┘     └─────────────────┘
```

---

## レイヤードアーキテクチャ

### フロントエンド

```
┌─────────────────────────────────────────────────────┐
│  Presentation Layer                                  │
│  ├─ app/ (expo-router pages)                        │
│  └─ components/ (UI コンポーネント)                   │
├─────────────────────────────────────────────────────┤
│  Application Layer                                   │
│  ├─ stores/ (Zustand ストア)                         │
│  └─ hooks/ (カスタムフック)                           │
├─────────────────────────────────────────────────────┤
│  Domain Layer                                        │
│  ├─ domain/models/ (型定義)                          │
│  └─ domain/services/ (ビジネスロジック)               │
├─────────────────────────────────────────────────────┤
│  Infrastructure Layer                                │
│  ├─ api/ (APIクライアント)                           │
│  └─ constants/ (モックデータ)                        │
└─────────────────────────────────────────────────────┘
```

### バックエンド

```
┌─────────────────────────────────────────────────────┐
│  Presentation Layer                                  │
│  └─ routes/ (Hono ルート定義)                        │
├─────────────────────────────────────────────────────┤
│  Application Layer                                   │
│  └─ middleware/ (エラーハンドリング、ログ)             │
├─────────────────────────────────────────────────────┤
│  Domain Layer                                        │
│  └─ services/ (ビジネスロジック)                      │
│      ├─ advice/ (AIアドバイス生成)                   │
│      └─ weather/ (天気情報取得)                      │
├─────────────────────────────────────────────────────┤
│  Infrastructure Layer                                │
│  └─ utils/ (Result型、ヘルパー)                       │
└─────────────────────────────────────────────────────┘
```

---

## データフロー

### 1. アプリ起動時

```
1. AsyncStorage からキャッシュ読み込み
   └─ userStore, healthStore の永続化データ

2. HealthKit からメトリクス取得（mock/healthkit 切り替え可能）
   └─ healthStore.fetchTodayMetrics()

3. スコア計算（ローカル）
   └─ domain/services/scoreCalculator.ts
   └─ domain/services/rhythmCalculator.ts

4. 天気情報取得（API）
   └─ GET /api/weather?lat=...&lon=...

5. AI アドバイス取得（API、1日1回）
   └─ POST /api/advice
```

### 2. AI アドバイス生成

```
[App]
  │
  ├─ healthStore から現在のメトリクス取得
  ├─ userStore からプロファイル取得
  ├─ 天気情報取得済み
  │
  ▼
[API Client]
  │
  ├─ AdviceRequest を構築
  │   ├─ user: { nickname, chronotype, age, ... }
  │   ├─ scores: { recovery, sleep, rhythm, energy }
  │   ├─ healthMetrics: { hrv, rhr, sleep, ... }
  │   └─ weather: { temperature, condition, ... }
  │
  ▼
[Backend: /api/advice]
  │
  ├─ Zod でリクエストバリデーション
  ├─ PromptBuilder でプロンプト構築
  │   ├─ System Prompt（キャッシュ対象）
  │   └─ User Data（XML形式）
  │
  ▼
[Anthropic Claude API]
  │
  ├─ AI がアドバイス生成
  │
  ▼
[Backend: AdviceService]
  │
  ├─ レスポンスをパース
  ├─ フォールバック処理（エラー時）
  │
  ▼
[App: insightStore]
  │
  └─ dailyInsight を保存・表示
```

---

## 状態管理

### Zustand ストア構成

```
stores/
├─ userStore.ts          # ユーザープロファイル、オンボーディング
│   ├─ profile: UserProfile | null
│   ├─ isOnboardingComplete: boolean
│   └─ actions: setProfile, completeOnboarding, reset
│
├─ healthStore/          # ヘルスデータ、スコア
│   ├─ index.ts
│   │   ├─ metrics: HealthMetrics | null
│   │   ├─ scores: DailyScores | null
│   │   ├─ tempoScore: TempoScoreResult | null
│   │   └─ actions: fetchTodayMetrics, calculateScores
│   ├─ types.ts          # 型定義
│   └─ selectors.ts      # セレクター関数
│
├─ insightStore.ts       # AI インサイト
│   ├─ dailyInsight: TodayInsight | null
│   ├─ generationPhase: 'idle' | 'analyzing' | ...
│   └─ actions: setDailyInsight, generateAdvice
│
└─ breatheStore.ts       # 呼吸セッション
    ├─ currentSession: BreathSession | null
    └─ actions: startSession, endSession
```

### 永続化戦略

```typescript
// 永続化対象
persist(store, {
  name: 'store-name',
  storage: createJSONStorage(() => AsyncStorage),
  partialize: (state) => ({
    // 永続化するプロパティのみ
    profile: state.profile,
    isOnboardingComplete: state.isOnboardingComplete,
    // isLoading, error は永続化しない
  }),
});
```

---

## API 設計

### エンドポイント一覧

| Method | Path | 説明 |
|--------|------|------|
| GET | /api/health | ヘルスチェック |
| GET | /api/weather | 天気情報取得 |
| POST | /api/advice | AI アドバイス生成 |

### レスポンス形式

```typescript
// 成功
{
  "success": true,
  "data": { ... }
}

// エラー
{
  "success": false,
  "error": "Error message"
}
```

### エラーコード

| Code | HTTP Status | 説明 |
|------|-------------|------|
| INVALID_REQUEST | 400 | リクエスト形式不正 |
| UNAUTHORIZED | 401 | 認証エラー |
| NOT_FOUND | 404 | リソース未発見 |
| RATE_LIMIT | 429 | レート制限 |
| AI_API_ERROR | 502 | AI API エラー |
| INTERNAL_ERROR | 500 | 内部エラー |

---

## セキュリティ

### プライバシー設計

1. **データベースレス**: サーバーにユーザーデータを保存しない
2. **匿名化**: AI API に送信するデータは必要最小限
3. **ローカル優先**: スコア計算はデバイス内で実行

### API キー管理

```
Backend:
  └─ Cloudflare Workers Secrets
      └─ ANTHROPIC_API_KEY

Frontend:
  └─ API キーは保持しない
      └─ Backend を経由して AI API にアクセス
```

---

## パフォーマンス

### キャッシュ戦略

| 対象 | TTL | 場所 |
|------|-----|------|
| AI アドバイス | 24時間 | AsyncStorage |
| 天気情報 | 1時間 | メモリ |
| ヘルスメトリクス | 6時間 | AsyncStorage |

### Cloudflare Workers 最適化

```typescript
// CPU 時間の最小化
- 重い計算はクライアント側で実行
- ストリーミングレスポンス（必要に応じて）

// コールドスタート対策
- 依存関係の最小化
- ESM 形式でバンドル
```

---

## 監視・ログ

### ログ設計

```typescript
// リクエストログ
{
  timestamp: '2024-01-01T00:00:00Z',
  method: 'POST',
  path: '/api/advice',
  duration: 1234,
  status: 200,
}

// エラーログ
{
  timestamp: '2024-01-01T00:00:00Z',
  error: 'Error message',
  stack: '...',
  context: { ... },
}
```

### メトリクス（今後追加）

- リクエスト数
- レスポンス時間
- エラー率
- AI API レイテンシ
