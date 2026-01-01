# Phase 1: Backend基盤

## 概要

TempoAIのバックエンド基盤を構築します。Cloudflare Workers + Hono 4.xを使用し、Open-Meteo APIとの連携を含む基本的なAPIサーバーを実装します。

## 参照ドキュメント

- [x] docs/specs/technical-spec.md - API設計セクション
- [x] .claude/typescript-hono-standards.md - TypeScript/Hono開発規約

## ゴール

- [ ] Honoアプリケーションの基本構造構築
- [ ] Open-Meteo API連携（Weather + Air Quality）
- [ ] ヘルスチェック・エラーハンドリング

## 成功基準

- [ ] TypeScript strict modeでエラーなし
- [ ] `any`型を使用していない
- [ ] 全ての関数がアロー関数
- [ ] Biome lint/formatエラーなし
- [ ] 全テストがパス
- [ ] `GET /api/health` が200を返す
- [ ] `GET /api/weather` が天気データを返す

## 成果物ディレクトリ構造

```
backend/src/
├── index.ts                    # Honoアプリエントリーポイント
├── routes/
│   ├── health.ts               # ヘルスチェック
│   └── weather.ts              # 天気API
├── services/weather/
│   ├── OpenMeteoClient.ts      # Open-Meteo API クライアント
│   ├── WeatherService.ts       # 天気サービス
│   └── types.ts                # 型定義
├── middleware/
│   ├── errorHandler.ts         # グローバルエラーハンドリング
│   └── logger.ts               # リクエストロガー
└── utils/
    └── result.ts               # Result型パターン
```

## 実装ステップ

### Step 1: Result型ユーティリティ

**目的**: エラーハンドリングのためのResult型パターンを実装
**ファイル**: `backend/src/utils/result.ts`
**テスト**: `backend/src/utils/result.test.ts`
**ステータス**: [ ] Not Started

### Step 2: ヘルスチェックエンドポイント

**目的**: 最初のエンドポイントを作成し、Honoアプリの基本構造を確立
**ファイル**: `backend/src/routes/health.ts`, `backend/src/index.ts`
**テスト**: `backend/src/routes/health.test.ts`
**ステータス**: [ ] Not Started

### Step 3: 天気サービス型定義

**目的**: Open-Meteo APIのリクエスト/レスポンス型を定義
**ファイル**: `backend/src/services/weather/types.ts`
**ステータス**: [ ] Not Started

### Step 4: Open-Meteo APIクライアント

**目的**: Open-Meteo API（Weather + Air Quality）との通信を実装
**ファイル**: `backend/src/services/weather/OpenMeteoClient.ts`
**テスト**: `backend/src/services/weather/OpenMeteoClient.test.ts`
**ステータス**: [ ] Not Started

### Step 5: 天気サービス

**目的**: OpenMeteoClientをラップし、ビジネスロジックを分離
**ファイル**: `backend/src/services/weather/WeatherService.ts`
**テスト**: `backend/src/services/weather/WeatherService.test.ts`
**ステータス**: [ ] Not Started

### Step 6: 天気エンドポイント

**目的**: `GET /api/weather` エンドポイントを作成
**ファイル**: `backend/src/routes/weather.ts`
**テスト**: `backend/src/routes/weather.test.ts`
**ステータス**: [ ] Not Started

### Step 7: エラーハンドラーミドルウェア

**目的**: グローバルエラーハンドリングを実装
**ファイル**: `backend/src/middleware/errorHandler.ts`
**テスト**: `backend/src/middleware/errorHandler.test.ts`
**ステータス**: [ ] Not Started

### Step 8: ロガーミドルウェア

**目的**: リクエストログを実装
**ファイル**: `backend/src/middleware/logger.ts`
**ステータス**: [ ] Not Started

## API設計

### GET /api/health

**レスポンス（200）**:

```json
{
  "success": true,
  "data": {
    "status": "ok",
    "timestamp": "2025-01-01T00:00:00.000Z",
    "version": "0.1.0"
  }
}
```

### GET /api/weather

**リクエスト**:

```
GET /api/weather?latitude=35.6762&longitude=139.6503
```

**パラメータ**:

| パラメータ | 型     | 必須 | 説明               |
| ---------- | ------ | ---- | ------------------ |
| latitude   | number | Yes  | 緯度 (-90 ~ 90)    |
| longitude  | number | Yes  | 経度 (-180 ~ 180) |

**成功レスポンス（200）**:

```json
{
  "success": true,
  "data": {
    "temperature": 20.5,
    "humidity": 65,
    "pressure": 1013.25,
    "weatherCode": 0,
    "uvIndexMax": 5.2,
    "sunrise": "2025-01-01T06:50:00+09:00",
    "sunset": "2025-01-01T16:45:00+09:00",
    "airQuality": {
      "pm25": 12.5,
      "aqi": 42
    }
  }
}
```

**エラーレスポンス（400）**:

```json
{
  "success": false,
  "error": "Invalid coordinates provided"
}
```

## テストケース

### ユニットテスト

- [ ] Result型のok/err関数が正しく動作する
- [ ] Result型のisOk/isErr型ガードが正しく動作する
- [ ] ヘルスチェックが200を返す
- [ ] 天気APIが有効な座標で天気データを返す
- [ ] 天気APIが無効な座標で400を返す
- [ ] エラーハンドラーが例外をキャッチしてフォーマットする

## 完了チェックリスト

- [ ] 全ステップ完了
- [ ] 全テストパス（`pnpm test`）
- [ ] Lint/Formatパス（`pnpm check`）
- [ ] TypeCheckパス（`pnpm typecheck`）
- [ ] PRレビュー対応可能
