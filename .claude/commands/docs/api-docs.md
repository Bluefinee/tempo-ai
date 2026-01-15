---
description: APIドキュメントを生成
allowed-tools: Read, Glob, Grep, Write
---

# APIドキュメント生成

## 実行手順

### 1. ルートファイルの収集

```bash
find backend/src/routes -name "*.ts" -not -name "*.test.ts"
```

### 2. 各エンドポイントの分析

各ルートファイルから以下を抽出:
- HTTPメソッド（GET, POST, PUT, DELETE）
- パス
- リクエストスキーマ
- レスポンススキーマ
- エラーコード

### 3. ドキュメント生成

出力先: `docs/api-reference.md`

```markdown
# TempoAI API Reference

Base URL: `https://api.tempo-ai.app`

## 認証

現在、認証は不要です（将来的に追加予定）。

---

## Endpoints

### Health Check

#### GET /api/health

サーバーの稼働状態を確認します。

**Response**

```json
{
  "success": true,
  "data": {
    "status": "ok"
  }
}
```

---

### Weather

#### GET /api/weather

天気情報を取得します。

**Query Parameters**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| lat | number | Yes | 緯度 |
| lon | number | Yes | 経度 |

**Response**

```json
{
  "success": true,
  "data": {
    "temperature": 22.5,
    "humidity": 65,
    "condition": "sunny",
    "sunrise": "06:30",
    "sunset": "18:45"
  }
}
```

---

### Advice

#### POST /api/advice

AIアドバイスを生成します。

**Request Body**

```json
{
  "user": {
    "nickname": "string",
    "chronotype": "morning" | "intermediate" | "evening",
    "age": 30,
    "gender": "male" | "female" | "other"
  },
  "scores": {
    "recovery": 75,
    "sleep": 80,
    "rhythm": 85,
    "energy": 78
  },
  "healthMetrics": {
    "hrv": { "current": 45, "baseline": 42 },
    "rhr": { "current": 58, "baseline": 60 },
    "sleep": { "durationMinutes": 420, "efficiency": 0.85 }
  },
  "weather": {
    "temperature": 22,
    "condition": "sunny"
  }
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "todayInsight": {
      "title": "Riding the Morning Wave",
      "summary": "今日のコンディションは良好です...",
      "whyThisMatters": { ... },
      "whatThisMeansForToday": "..."
    },
    "todayOneThing": {
      "action": "午前10時に15分の散歩",
      "whyThisAction": "...",
      "benefits": ["...", "...", "..."]
    },
    "relatedInsight": {
      "title": "...",
      "content": "..."
    }
  }
}
```

**Error Codes**

| Code | Status | Description |
|------|--------|-------------|
| INVALID_REQUEST | 400 | リクエストの形式が不正 |
| AI_API_ERROR | 502 | AI APIでエラーが発生 |
| RATE_LIMIT_ERROR | 429 | レート制限に到達 |

---

## Error Response Format

```json
{
  "success": false,
  "error": "Error message"
}
```
```
