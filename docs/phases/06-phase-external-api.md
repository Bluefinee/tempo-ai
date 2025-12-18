# Phase 8: 外部API統合設計書

**フェーズ**: 8 / 14  
**Part**: B（バックエンド）  
**前提フェーズ**: Phase 7（Backend基盤）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料
- **[CLAUDE.md](../../CLAUDE.md)** - 開発ガイドライン・基本原則
- **[AI Prompt Design](../ai-prompt-design.md)** - AI設計指針
- **[UI Specification](../ui-spec.md)** - UI設計仕様書
- **[Technical Specification](../technical-spec.md)** - 技術仕様書

### 🔧 Backend専用資料
- **[TypeScript Hono Standards](../../.claude/typescript-hono-standards.md)** - TypeScript + Hono 開発標準

### ✅ 実装完了後の必須作業
実装完了後は必ず以下を実行してください：
```bash
# TypeScript型チェック
npm run typecheck

# リント・フォーマット確認
npm run lint

# テスト実行
npm test
```

---

## このフェーズで実現すること

1. **Open-Meteo Weather API**との統合
2. **Open-Meteo Air Quality API**との統合
3. **フォールバック処理**の実装

---

## 完了条件

- [ ] 位置情報（緯度・経度）から気象データを取得できる
- [ ] 位置情報（緯度・経度）から大気汚染データを取得できる
- [ ] Weather API失敗時にフォールバック動作する
- [ ] Air Quality API失敗時にフォールバック動作する
- [ ] 取得したデータが型定義に従ってパースされる

---

## API概要

### Open-Meteo Weather API

**エンドポイント**: `https://api.open-meteo.com/v1/forecast`

**特徴**:
- 無料（クレジット表記推奨）
- APIキー不要
- 日本を含む全世界対応

### Open-Meteo Air Quality API

**エンドポイント**: `https://air-quality-api.open-meteo.com/v1/air-quality`

**特徴**:
- 無料（1日10,000リクエストまで）
- APIキー不要

---

## Weather API統合

### リクエストパラメータ

| パラメータ | 値 | 説明 |
|-----------|-----|------|
| latitude | 緯度 | 必須 |
| longitude | 経度 | 必須 |
| current | temperature_2m, relative_humidity_2m, weather_code, surface_pressure | 現在の気象 |
| daily | temperature_2m_max, temperature_2m_min, uv_index_max, precipitation_probability_max | 日次予報 |
| timezone | Asia/Tokyo | タイムゾーン |

### リクエスト例

```
GET https://api.open-meteo.com/v1/forecast
  ?latitude=35.6895
  &longitude=139.6917
  &current=temperature_2m,relative_humidity_2m,weather_code,surface_pressure
  &daily=temperature_2m_max,temperature_2m_min,uv_index_max,precipitation_probability_max
  &timezone=Asia/Tokyo
```

### レスポンス例

```json
{
  "current": {
    "temperature_2m": 14.2,
    "relative_humidity_2m": 65,
    "weather_code": 0,
    "surface_pressure": 1018.5
  },
  "daily": {
    "temperature_2m_max": [18.5],
    "temperature_2m_min": [8.2],
    "uv_index_max": [4.5],
    "precipitation_probability_max": [10]
  }
}
```

### 型定義

```typescript
interface WeatherData {
  condition: string;
  tempCurrentC: number;
  tempMaxC: number;
  tempMinC: number;
  humidityPercent: number;
  uvIndex: number;
  pressureHpa: number;
  precipitationProbability: number;
}
```

### Weather Code → 天気文字列変換

| コード | 天気 |
|--------|------|
| 0 | 快晴 |
| 1, 2, 3 | 晴れ/一部曇り |
| 45, 48 | 霧 |
| 51, 53, 55 | 霧雨 |
| 61, 63, 65 | 雨 |
| 71, 73, 75 | 雪 |
| 95 | 雷雨 |

---

## Air Quality API統合

### リクエストパラメータ

| パラメータ | 値 | 説明 |
|-----------|-----|------|
| latitude | 緯度 | 必須 |
| longitude | 経度 | 必須 |
| current | pm2_5, pm10, us_aqi | 現在の大気質 |

### リクエスト例

```
GET https://air-quality-api.open-meteo.com/v1/air-quality
  ?latitude=35.6895
  &longitude=139.6917
  &current=pm2_5,pm10,us_aqi
```

### レスポンス例

```json
{
  "current": {
    "pm2_5": 12.5,
    "pm10": 25.3,
    "us_aqi": 45
  }
}
```

### 型定義

```typescript
interface AirQualityData {
  aqi: number;
  pm25: number;
  pm10?: number;
}
```

### AQI（大気質指数）の解釈

| AQI | レベル | アドバイスへの影響 |
|-----|--------|-------------------|
| 0-50 | 良好 | 屋外活動推奨 |
| 51-100 | 普通 | 通常通り |
| 101-150 | 敏感な人に不健康 | 長時間の屋外活動に注意 |
| 151-200 | 不健康 | 屋外活動を控える提案 |
| 201+ | 非常に不健康 | 外出を避ける提案 |

---

## サービス実装

### ディレクトリ構造

```
backend/src/services/
├── weather.ts        # Weather API統合
└── airQuality.ts     # Air Quality API統合
```

### WeatherService

```typescript
// services/weather.ts

interface WeatherParams {
  latitude: number;
  longitude: number;
}

export const fetchWeatherData = async (
  params: WeatherParams
): Promise<WeatherData> => {
  // API呼び出し
  // レスポンス変換
  // エラーハンドリング
};
```

### AirQualityService

```typescript
// services/airQuality.ts

interface AirQualityParams {
  latitude: number;
  longitude: number;
}

export const fetchAirQualityData = async (
  params: AirQualityParams
): Promise<AirQualityData> => {
  // API呼び出し
  // レスポンス変換
  // エラーハンドリング
};
```

---

## フォールバック処理

### 失敗ケースと対応

| 失敗ケース | フォールバック |
|-----------|---------------|
| Weather API失敗 | 気象関連アドバイスを省略してアドバイス生成 |
| Air Quality API失敗 | 大気汚染関連アドバイスを省略 |
| 両方失敗 | 気象・環境データなしでアドバイス生成 |
| タイムアウト | 5秒でタイムアウト、フォールバック |

### 統合関数

```typescript
// routes/advice.ts

interface EnvironmentData {
  weather?: WeatherData;
  airQuality?: AirQualityData;
}

const fetchEnvironmentData = async (
  location: LocationData
): Promise<EnvironmentData> => {
  const results: EnvironmentData = {};

  try {
    results.weather = await fetchWeatherData(location);
  } catch (error) {
    console.error("Weather fetch failed:", error);
    // weather は undefined のまま
  }

  try {
    results.airQuality = await fetchAirQualityData(location);
  } catch (error) {
    console.error("Air quality fetch failed:", error);
    // airQuality は undefined のまま
  }

  return results;
};
```

---

## エラー定義

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

---

## タイムアウト設定

```typescript
const TIMEOUT_MS = 5000; // 5秒

const fetchWithTimeout = async (
  url: string,
  timeoutMs: number = TIMEOUT_MS
): Promise<Response> => {
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

---

## adviceエンドポイントへの統合

Phase 7で作成した `/api/advice` を更新:

```typescript
// routes/advice.ts

app.post("/api/advice", async (c) => {
  const request = await c.req.json<AdviceRequest>();
  
  // 環境データを取得（フォールバック付き）
  const environmentData = await fetchEnvironmentData(request.location);
  
  // このフェーズではまだMockレスポンスを返す
  // 環境データは取得できていることを確認
  console.log("Weather:", environmentData.weather);
  console.log("AirQuality:", environmentData.airQuality);
  
  return c.json(mockAdviceResponse);
});
```

---

## テスト観点

### 正常系

- 東京の緯度経度で気象データが取得できる
- 大阪の緯度経度で大気汚染データが取得できる
- レスポンスが正しく型変換される

### 異常系

- 無効な緯度経度でエラーハンドリングされる
- タイムアウト時にフォールバックする
- API側エラー（500）でフォールバックする

### 境界値

- 日本国外の位置情報でもデータ取得できる
- 極端な緯度経度（北極、南極）の動作確認

---

## ログ出力

開発・デバッグ用のログ:

```typescript
console.log(`[Weather] Fetching for lat=${lat}, lon=${lon}`);
console.log(`[Weather] Response:`, weatherData);
console.error(`[Weather] Error:`, error);

console.log(`[AirQuality] Fetching for lat=${lat}, lon=${lon}`);
console.log(`[AirQuality] Response:`, airQualityData);
console.error(`[AirQuality] Error:`, error);
```

---

## 今後のフェーズとの関係

### Phase 9で使用

- Claude APIへのプロンプトに気象・大気汚染データを含める

### Phase 10で使用

- iOSから送信されるLocationDataを使って実際のデータを取得

---

## 関連ドキュメント

- `technical-spec.md` - セクション5「外部API統合」
- `product-spec.md` - セクション3.2〜3.3「気象データ」「大気汚染データ」

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-10 | 初版作成 |
