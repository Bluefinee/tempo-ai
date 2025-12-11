# Phase 8 実装計画書：外部API統合

**作成日**: 2025-12-11  
**フェーズ**: 8 / 14  
**目的**: Open-Meteo Weather APIとAir Quality APIの統合

## 実装概要

### 目標
- 位置情報（緯度・経度）から気象データを取得
- 位置情報（緯度・経度）から大気汚染データを取得  
- API失敗時のフォールバック処理実装
- Phase 9のClaude API統合に向けた環境データ準備

### 完了条件
- [ ] WeatherData型の気象データ取得が成功
- [ ] AirQualityData型の大気汚染データ取得が成功
- [ ] Weather API失敗時にフォールバック動作
- [ ] Air Quality API失敗時にフォールバック動作
- [ ] 取得データが型定義通りにパースされる

## 技術仕様

### 使用API

#### Open-Meteo Weather API
- **エンドポイント**: `https://api.open-meteo.com/v1/forecast`
- **特徴**: 無料、APIキー不要、全世界対応
- **パラメータ**:
  - `latitude`, `longitude`: 位置情報（必須）
  - `current`: `temperature_2m,relative_humidity_2m,weather_code,surface_pressure`
  - `daily`: `temperature_2m_max,temperature_2m_min,uv_index_max,precipitation_probability_max`
  - `timezone`: `Asia/Tokyo`

#### Open-Meteo Air Quality API
- **エンドポイント**: `https://air-quality-api.open-meteo.com/v1/air-quality`
- **特徴**: 無料（1日10,000リクエストまで）、APIキー不要
- **パラメータ**:
  - `latitude`, `longitude`: 位置情報（必須）
  - `current`: `pm2_5,pm10,us_aqi`

### 型定義

```typescript
interface WeatherData {
  condition: string;           // Weather Codeから変換した日本語天気
  tempCurrentC: number;        // 現在気温（℃）
  tempMaxC: number;            // 最高気温（℃）
  tempMinC: number;            // 最低気温（℃）
  humidityPercent: number;     // 湿度（%）
  uvIndex: number;             // UV指数
  pressureHpa: number;         // 気圧（hPa）
  precipitationProbability: number; // 降水確率（%）
}

interface AirQualityData {
  aqi: number;                 // 大気質指数（AQI）
  pm25: number;                // PM2.5濃度
  pm10?: number;               // PM10濃度（オプション）
}

interface EnvironmentData {
  weather?: WeatherData;       // 気象データ（取得失敗時はundefined）
  airQuality?: AirQualityData; // 大気汚染データ（取得失敗時はundefined）
}
```

### Weather Code変換表

| コード | 日本語天気 |
|--------|-----------|
| 0 | 快晴 |
| 1, 2, 3 | 晴れ |
| 45, 48 | 霧 |
| 51, 53, 55 | 霧雨 |
| 61, 63, 65 | 雨 |
| 71, 73, 75 | 雪 |
| 95 | 雷雨 |

### エラーハンドリング

#### カスタムエラークラス
```typescript
class WeatherApiError extends Error {
  constructor(message: string, public readonly statusCode?: number) {
    super(message);
    this.name = "WeatherApiError";
  }
}

class AirQualityApiError extends Error {
  constructor(message: string, public readonly statusCode?: number) {
    super(message);
    this.name = "AirQualityApiError";
  }
}
```

#### フォールバック戦略
| 失敗ケース | 対応 |
|-----------|-----|
| Weather API失敗 | 気象関連アドバイスを省略してアドバイス生成継続 |
| Air Quality API失敗 | 大気汚染関連アドバイスを省略してアドバイス生成継続 |
| 両方失敗 | 環境データなしでアドバイス生成 |
| タイムアウト | 5秒でタイムアウト、フォールバック |

## 実装詳細

### ファイル構成

```
backend/src/
├── types/domain.ts          # 型定義追加
├── utils/errors.ts          # カスタムエラークラス追加
├── services/
│   ├── weather.ts          # 新規作成：Weather API統合
│   └── airQuality.ts       # 新規作成：Air Quality API統合
└── routes/advice.ts         # 更新：環境データ統合
```

### 1. 型定義追加（backend/src/types/domain.ts）

既存のdomain.tsに以下を追加：
- `WeatherDataSchema`とzod型定義
- `AirQualityDataSchema`とzod型定義
- `EnvironmentDataSchema`とzod型定義
- TypeScript型エクスポート

### 2. カスタムエラー追加（backend/src/utils/errors.ts）

既存のerrors.tsに以下を追加：
- `WeatherApiError`クラス
- `AirQualityApiError`クラス

### 3. Weatherサービス（backend/src/services/weather.ts）

```typescript
interface WeatherParams {
  latitude: number;
  longitude: number;
}

export const fetchWeatherData = async (params: WeatherParams): Promise<WeatherData>
```

**主要機能**:
- Open-Meteo Weather API呼び出し
- Weather Code → 日本語天気変換
- レスポンスデータの型変換
- 5秒タイムアウト設定
- エラーハンドリング（WeatherApiError）

### 4. Air Qualityサービス（backend/src/services/airQuality.ts）

```typescript
interface AirQualityParams {
  latitude: number;
  longitude: number;
}

export const fetchAirQualityData = async (params: AirQualityParams): Promise<AirQualityData>
```

**主要機能**:
- Open-Meteo Air Quality API呼び出し
- レスポンスデータの型変換
- 5秒タイムアウト設定
- エラーハンドリング（AirQualityApiError）

### 5. Adviceルート更新（backend/src/routes/advice.ts）

```typescript
const fetchEnvironmentData = async (location: LocationData): Promise<EnvironmentData>
```

**主要機能**:
- 両APIの並行呼び出し
- 個別エラーハンドリング（一方が失敗しても他方は取得）
- 環境データの統合
- デバッグログ出力

### タイムアウト実装

```typescript
const TIMEOUT_MS = 5000;

const fetchWithTimeout = async (url: string, timeoutMs: number = TIMEOUT_MS): Promise<Response> => {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(url, { signal: controller.signal });
    return response;
  } finally {
    clearTimeout(timeoutId);
  }
};
```

## テスト戦略

### ユニットテスト

#### Weather Service Tests
- **正常系**: 有効な緯度経度でデータ取得
- **異常系**: 無効な緯度経度、API側エラー、タイムアウト
- **境界値**: 極端な座標値、日本国外

#### Air Quality Service Tests  
- **正常系**: 有効な緯度経度でデータ取得
- **異常系**: 無効な緯度経度、API側エラー、タイムアウト
- **境界値**: 極端な座標値、日本国外

#### Environment Data Integration Tests
- **正常系**: 両API成功時の統合
- **部分失敗**: 片方のAPI失敗時のフォールバック
- **全失敗**: 両API失敗時の空オブジェクト返却

### 統合テスト

#### Advice Endpoint Tests
- 環境データ取得後のadviceレスポンス確認
- フォールバック動作の確認
- ログ出力の確認

## 品質チェック項目

### TypeScript
- [ ] 型エラーなし（`npm run typecheck`）
- [ ] `any`型の使用なし
- [ ] 適切な型ガード実装

### Linting/Formatting
- [ ] Biome linting pass（`npm run lint`）
- [ ] コードフォーマット適用

### Testing
- [ ] 全テストパス（`npm test`）
- [ ] カバレッジ80%以上維持
- [ ] エラーケースのテスト網羅

## ログ仕様

### 開発用ログ
```typescript
console.log(`[Weather] Fetching for lat=${lat}, lon=${lon}`);
console.log(`[Weather] Response:`, weatherData);
console.error(`[Weather] Error:`, error);

console.log(`[AirQuality] Fetching for lat=${lat}, lon=${lon}`);
console.log(`[AirQuality] Response:`, airQualityData);
console.error(`[AirQuality] Error:`, error);
```

### 本番用ログ（将来）
- エラー時のみログ出力
- 個人情報（緯度経度詳細）の除去
- 構造化ログ形式

## デプロイメント考慮事項

### Cloudflare Workers制約
- fetch APIサポート確認済み
- AbortControllerサポート確認済み
- 同時実行制限なし（2つのAPI呼び出し）

### パフォーマンス
- 並行API呼び出しで時間短縮
- タイムアウト5秒以内でレスポンス保証
- フォールバック処理で可用性向上

## 今後のフェーズとの連携

### Phase 9: Claude API統合
- `EnvironmentData`をClaude APIプロンプトに含める
- 気象・大気汚染情報に基づくアドバイス生成
- フォールバック時の代替アドバイス戦略

### Phase 10: iOS統合
- `LocationData`の緯度経度を使用
- リアルタイム環境データの活用
- エラー時のユーザーフィードバック

## リスク軽減策

### API可用性リスク
- **対策**: フォールバック処理による継続性確保
- **監視**: エラー率の継続監視（将来）

### パフォーマンスリスク  
- **対策**: 5秒タイムアウトとキャッシュ検討（将来）
- **監視**: レスポンス時間の測定

### データ品質リスク
- **対策**: 型安全性とバリデーション
- **監視**: 異常値の検出（将来）

## 成功指標

### 機能指標
- Weather API成功率 > 95%
- Air Quality API成功率 > 95%
- 統合処理時間 < 3秒（通常時）

### 品質指標
- TypeScriptエラー 0件
- テストカバレッジ > 80%
- Lintエラー 0件

---

**実装担当**: Claude Code  
**レビュー**: 実装完了後にユーザー確認  
**完了予定**: 当日中