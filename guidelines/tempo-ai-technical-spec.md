承知いたしました。
プロダクト仕様書 Ver 2.0 に合わせ、技術仕様書も **Ver 2.0 (Phase 3-5 対応版)** にアップデートしました。

Cloudflare Workers のバックエンド構成はそのままに、**バッテリーロジック、気象 API 統合、タグ注入アーキテクチャ** を追加しています。

これを `tempo-ai-technical-spec.md` として保存し、Claude Code に読み込ませてください。

---

# Tempo AI 技術仕様書 (Ver 2.0)

## Technical Specification Document

### 概要 (Overview)

Tempo AI は、iOS SwiftUI アプリケーションと Cloudflare Workers TypeScript バックエンドで構成される健康アドバイスプラットフォームです。
HealthKit データ、Open-Meteo 気象データ、ユーザーの関心タグ（Focus Tags）を統合し、動的な「ヒューマンバッテリー」モデルを通じてパーソナライズされた行動指針を提供します。

---

## 1\. システムアーキテクチャ (System Architecture)

### 1.1 ハイレベル構成

```
┌──────────────────┐      ┌───────────────────────────┐      ┌─────────────────┐
│   iOS Client     │◄────►│    Cloudflare Workers     │◄────►│   Claude AI     │
│   (SwiftUI)      │      │     (Context Engine)      │      │  (3.5 Sonnet)   │
└──────────────────┘      └───────────────────────────┘      └─────────────────┘
         │                               │
         │ (Native)                      │ (REST API)
         ▼                               ▼
┌──────────────────┐      ┌───────────────────────────┐
│    HealthKit     │      │      Open-Meteo API       │
│ (Local Biology)  │      │     (Weather Context)     │
└──────────────────┘      └───────────────────────────┘
```

### 1.2 技術スタック

- **Backend:** Cloudflare Workers, Hono, TypeScript, Zod, @anthropic-ai/sdk
- **Frontend:** iOS 16.0+, SwiftUI, HealthKit, CoreLocation, Swift Charts
- **External API:** Open-Meteo (Weather), Anthropic Claude API

---

## 2\. データモデル設計 (Data Models)

### 2.1 ユーザープロファイル拡張 (User Profile)

Phase 3/4 で追加されるコア概念をサポートするためのモデル拡張。

```swift
// iOS: UserProfile.swift

enum UserMode: String, Codable {
    case standard  // 生活の質・効率重視
    case athlete   // トレーニング・パフォーマンス重視
}

enum FocusTag: String, Codable {
    case work    // 仕事・集中
    case beauty  // 美容・肌
    case diet    // 食事・代謝
    case chill   // サウナ・リセット
}

struct UserProfile {
    var mode: UserMode
    var focusTags: Set<FocusTag>
    // ... existing fields
}
```

### 2.2 ヒューマンバッテリーモデル (Battery Model)

バッテリー計算ロジックのためのデータ構造。

```swift
struct HumanBattery {
    var currentLevel: Double // 0-100%
    var morningCharge: Double // 起床時の初期容量
    var drainRate: Double     // 現在の放電速度 (-5%/hour etc)
    var state: BatteryState   // .high, .medium, .low, .critical
}
```

---

## 3\. コアロジック仕様 (Core Logic)

### 3.1 バッテリーエンジン (The Battery Engine)

iOS 側（ローカル）で計算を行い、リアルタイム性を担保する。

- **Morning Charge Calculation:**

  - `SleepScore` (時間+質) × 0.6
  - `HRVStatus` (ベースライン比) × 0.4
  - _上限補正:_ 前日のバッテリー残量が極端に低い場合はペナルティを与える。

- **Real-time Discharging:**

  - 基礎消費: 時間経過とともに減少。
  - 活動消費: `ActiveEnergyBurned` に応じて減少（Mode により係数変化）。
  - ストレス消費: HRV が低い状態が続くと加速減少。
  - **環境係数:** 気温 30℃ 以上、または気圧急低下時は `x1.2` 倍速で減少。

### 3.2 コンテキスト・プロンプトビルダー (Context Engine)

バックエンド（Cloudflare Workers）で、AI への指示を動的に生成する。

**処理フロー:**

1.  **Input:** HealthData + UserMode + ActiveTags + WeatherData
2.  **Base Prompt:** Mode に基づく基本人格（優しいパートナー vs 熱血コーチ）を設定。
3.  **Injection:** Tag ごとの特記事項を追加。
    - `if tags.contains(.beauty)` → "肌の水分量と睡眠ホルモンについて言及せよ"
    - `if tags.contains(.work)` → "脳のパフォーマンスウィンドウについて助言せよ"
4.  **Weather Context:** 気象データ（気圧・湿度）を自然言語で補足説明に追加。

---

## 4\. API インターフェース (API Interface)

### 4.1 エンドポイント更新

**POST /api/health/analyze-contextual**
従来の分析 API を置き換える、コンテキスト認識型エンドポイント。

**Request Body (JSON):**

```typescript
interface ContextualAnalysisRequest {
  userMode: "standard" | "athlete";
  focusTags: string[]; // ["work", "beauty"]
  healthMetrics: {
    batteryLevel: number;
    hrvStatus: string;
    sleepEfficiency: number;
    // ... other metrics
  };
  location: { latitude: number; longitude: number }; // Weather取得用
}
```

**Response Body (JSON):**

```typescript
interface ContextualResponse {
  headline: {
    title: string; // "気圧低下注意"
    subtitle: string; // "頭痛が起きやすい状態です。無理せず。"
    impactLevel: "high" | "medium" | "low";
  };
  batteryComment: string; // "午後は急速に減る予測です"
  tagSuggestions: {
    tag: string; // "beauty"
    message: string; // "乾燥しています。保湿を。"
  }[];
  detailedAnalysis: string; // 詳細画面用の長文
}
```

---

## 5\. 外部サービス統合 (Integrations)

### 5.1 Open-Meteo API (Weather)

サーバーサイド（Cloudflare Workers）からコールし、API キー漏洩リスクを回避する。

- **Endpoint:** `https://api.open-meteo.com/v1/forecast`
- **Params:** `latitude`, `longitude`, `hourly=temperature_2m,relative_humidity_2m,surface_pressure`
- **Caching:** 同じ座標（丸めた値）へのリクエストは KV または Cache API でキャッシュし、負荷を軽減する。

---

## 6\. UI/UX 実装要件 (Frontend Requirements)

### 6.1 デジタル・コックピット (Home View)

- **Liquid Battery:** SwiftUI Canvas または SpriteKit を使用し、液体の物理演算（波打ち）を実装する。
  - _パフォーマンス:_ バッテリー残量が変化した時のみ再描画し、CPU 負荷を抑える。
- **Headlines:** Dynamic Type に対応しつつ、雑誌のようなレイアウト（Text Kerning, Line Spacing 調整）を実現する。

### 6.2 詳細画面 (Detail Views)

- **Charts:** Swift Charts を使用。
- **Tag Awareness:** `ViewBuilder` を使用し、アクティブなタグに応じて表示セクション（`if tags.contains(.beauty) { SkinScoreView() }`）を切り替える構造にする。

---

## 7\. セキュリティとプライバシー (Security)

### 7.1 データ最小化原則

- **位置情報:** Open-Meteo へのリクエストに必要な「緯度・経度（小数点 2 桁まで丸め）」のみをバックエンドに送信する。住所情報は送信しない。
- **HealthKit:** 生の心拍数（毎秒）は送信せず、「平均値」「最小/最大」「トレンド」に加工してから送信する。

---

## 8\. フェーズ別実装計画 (Implementation Phases)

### Phase 3: 基盤構築

1.  **UserMode** と **Battery Model** の実装。
2.  HealthKit からのデータ取得とバッテリー計算ロジックの実装。
3.  Open-Meteo API クライアントの実装（Backend）。
4.  ホーム画面 UI（Liquid Battery, Headline）の実装。

### Phase 4: パーソナライズ

1.  **Focus Tags** のオンボーディング UI 実装。
2.  バックエンドのプロンプトビルダー（Tag Injection）の実装。
3.  ホーム画面のスマートサジェスト（Tag Suggestions）実装。
4.  詳細画面のタグ分岐ロジック実装。

### Phase 5: クリーンアップ

1.  旧「ヘルススコア」ロジックの削除。
2.  未使用の View ファイルの削除。
3.  コードベースのフォーマット統一とドキュメント化。

---
