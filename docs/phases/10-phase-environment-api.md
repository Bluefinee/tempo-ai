# Phase 10: 環境データ拡張API設計書

**フェーズ**: 10 / 19  
**Part**: B（バックエンド）  
**前提フェーズ**: Phase 8（外部API統合）、Phase 9（Claude API統合）

---

## ⚠️ 実装前必読ドキュメント

**実装を開始する前に、以下のドキュメントを必ず確認してください：**

### 📋 必須参考資料
- **[CLAUDE.md](../../CLAUDE.md)** - 開発ガイドライン・基本原則
- **[AI Prompt Design](../ai-prompt-design.md)** - AI設計指針
- **[UI Specification](../ui-spec.md)** - UI設計仕様書
- **[Technical Specification](../technical-spec.md)** - 技術仕様書
- **[Travel Mode & Condition Spec](../travel-mode-condition-spec.md)** - コンディション画面詳細仕様

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

1. **気圧トレンド算出**（上昇/安定/下降）
2. **環境アドバイス生成**（気温・UV・AQIに基づく簡易ヒント）
3. **環境データ拡張エンドポイント**

---

## 完了条件

- [ ] `/api/environment` エンドポイントが動作する
- [ ] 気圧トレンドが正しく算出される（上昇/安定/下降）
- [ ] 環境アドバイスが条件に応じて生成される
- [ ] Phase 8の天気・大気質データと統合されている

---

## 設計方針

### iOS側との責務分担

| 責務 | 担当 | 理由 |
|------|------|------|
| 天気データ取得 | Backend | 外部API統合（Phase 8で実装済み） |
| 大気質データ取得 | Backend | 外部API統合（Phase 8で実装済み） |
| 気圧トレンド算出 | Backend | 過去データとの比較が必要 |
| 環境アドバイス生成 | Backend | ロジックの一元管理 |
| サーカディアンリズム算出 | iOS | HealthKitデータはiOS側に閉じる |
| HRV/睡眠/活動量トレンド | iOS | HealthKitデータはiOS側に閉じる |

---

## エンドポイント設計

### GET /api/environment

**リクエスト**:
```
GET /api/environment?lat=35.6762&lon=139.6503
```

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| lat | number | ✅ | 緯度 |
| lon | number | ✅ | 経度 |

**レスポンス**:
```typescript
interface EnvironmentResponse {
  location: {
    city: string;
    latitude: number;
    longitude: number;
  };
  weather: {
    current: {
      temp: number;           // 現在気温（℃）
      feelsLike: number;      // 体感温度（℃）
      tempMax: number;        // 最高気温（℃）
      tempMin: number;        // 最低気温（℃）
      humidity: number;       // 湿度（%）
      pressure: number;       // 気圧（hPa）
      windSpeed: number;      // 風速（m/s）
      uvIndex: number;        // UV指数
      weatherCode: string;    // 天気コード
      weatherDescription: string; // 天気説明（日本語）
    };
    pressureTrend: PressureTrend;  // 気圧トレンド
  };
  airQuality: {
    aqi: number;              // AQI
    aqiStatus: string;        // ステータス（良好/普通/敏感な人に影響/...）
    pm25: number;             // PM2.5（µg/m³）
    pm10: number;             // PM10（µg/m³）
  };
  advice: EnvironmentAdvice[];  // 環境アドバイス（0-3個）
  fetchedAt: string;            // 取得日時（ISO8601）
}

type PressureTrend = "rising" | "stable" | "falling";

interface EnvironmentAdvice {
  type: EnvironmentAdviceType;
  message: string;
}

type EnvironmentAdviceType = 
  | "temperature"
  | "uv"
  | "air_quality"
  | "humidity"
  | "pressure";
```

**レスポンス例**:
```json
{
  "location": {
    "city": "東京",
    "latitude": 35.6762,
    "longitude": 139.6503
  },
  "weather": {
    "current": {
      "temp": 12,
      "feelsLike": 10,
      "tempMax": 15,
      "tempMin": 8,
      "humidity": 45,
      "pressure": 1018,
      "windSpeed": 3,
      "uvIndex": 3,
      "weatherCode": "sunny",
      "weatherDescription": "晴れ"
    },
    "pressureTrend": "stable"
  },
  "airQuality": {
    "aqi": 42,
    "aqiStatus": "良好",
    "pm25": 12,
    "pm10": 28
  },
  "advice": [
    {
      "type": "temperature",
      "message": "気温が低めです。外出時は暖かい服装を"
    },
    {
      "type": "uv",
      "message": "UV指数は中程度。長時間の外出には日焼け止めを"
    },
    {
      "type": "air_quality",
      "message": "大気質は良好。屋外運動に適しています"
    }
  ],
  "fetchedAt": "2025-12-11T09:00:00Z"
}
```

---

## 気圧トレンド算出

### 算出ロジック

過去3時間の気圧変化を基に判定:

```typescript
type PressureTrend = "rising" | "stable" | "falling";

const calculatePressureTrend = (
  currentPressure: number,
  pressure3hAgo: number
): PressureTrend => {
  const diff = currentPressure - pressure3hAgo;
  
  if (diff > 2) {
    return "rising";    // 2hPa以上上昇
  } else if (diff < -2) {
    return "falling";   // 2hPa以上下降
  } else {
    return "stable";    // 変化なし
  }
};
```

### Open-Meteoからの取得

Phase 8で実装済みのOpen-Meteo Weather APIを拡張:

```typescript
// 過去の気圧データを含めてリクエスト
const url = `https://api.open-meteo.com/v1/forecast?` +
  `latitude=${lat}&longitude=${lon}` +
  `&current=temperature_2m,relative_humidity_2m,apparent_temperature,` +
  `weather_code,wind_speed_10m,pressure_msl,uv_index` +
  `&hourly=pressure_msl` +  // 時間ごとの気圧
  `&past_hours=3` +         // 過去3時間
  `&timezone=auto`;
```

---

## 環境アドバイス生成

### 生成ルール

AIを使わず、ルールベースで生成:

```typescript
const generateEnvironmentAdvice = (
  weather: WeatherData,
  airQuality: AirQualityData
): EnvironmentAdvice[] => {
  const advice: EnvironmentAdvice[] = [];
  
  // 気温アドバイス
  if (weather.current.temp < 10) {
    advice.push({
      type: "temperature",
      message: "気温が低めです。外出時は暖かい服装を"
    });
  } else if (weather.current.temp > 30) {
    advice.push({
      type: "temperature",
      message: "気温が高めです。こまめな水分補給と日陰での休憩を"
    });
  } else if (weather.current.feelsLike < weather.current.temp - 3) {
    advice.push({
      type: "temperature",
      message: "体感温度が低めです。風が強いので上着があると安心です"
    });
  }
  
  // UVアドバイス
  if (weather.current.uvIndex >= 6) {
    advice.push({
      type: "uv",
      message: "UV指数が高めです。日焼け止めと帽子の着用を推奨します"
    });
  } else if (weather.current.uvIndex >= 3) {
    advice.push({
      type: "uv",
      message: "UV指数は中程度。長時間の外出には日焼け止めを"
    });
  }
  
  // 大気質アドバイス
  if (airQuality.aqi <= 50) {
    advice.push({
      type: "air_quality",
      message: "大気質は良好。屋外運動に適しています"
    });
  } else if (airQuality.aqi <= 100) {
    advice.push({
      type: "air_quality",
      message: "大気質は普通です。敏感な方は長時間の屋外活動を控えめに"
    });
  } else {
    advice.push({
      type: "air_quality",
      message: "大気質が悪化しています。屋外での激しい運動は避けましょう"
    });
  }
  
  // 湿度アドバイス
  if (weather.current.humidity < 30) {
    advice.push({
      type: "humidity",
      message: "乾燥しています。保湿と水分補給を心がけましょう"
    });
  } else if (weather.current.humidity > 80) {
    advice.push({
      type: "humidity",
      message: "湿度が高めです。熱中症に注意しましょう"
    });
  }
  
  // 気圧アドバイス（トレンドベース）
  if (weather.pressureTrend === "falling") {
    advice.push({
      type: "pressure",
      message: "気圧が下降中です。頭痛が出やすい方はお気をつけて"
    });
  }
  
  // 最大3つまでに制限（優先度順に）
  return advice.slice(0, 3);
};
```

### アドバイスの優先順位

1. 大気質（健康への直接的影響）
2. 気温（体調管理）
3. UV（肌への影響）
4. 気圧（気象病）
5. 湿度（快適性）

---

## ディレクトリ構造

```
backend/src/
├── routes/
│   └── environment.ts      # /api/environment エンドポイント
├── services/
│   ├── weather.ts          # Phase 8で実装済み
│   ├── airQuality.ts       # Phase 8で実装済み
│   └── environmentAdvice.ts # 環境アドバイス生成
└── types/
    └── environment.ts      # 型定義
```

---

## 実装

### routes/environment.ts

```typescript
import { Hono } from "hono";
import { z } from "zod";
import { zValidator } from "@hono/zod-validator";
import { getWeatherData } from "../services/weather";
import { getAirQualityData } from "../services/airQuality";
import { generateEnvironmentAdvice } from "../services/environmentAdvice";
import { calculatePressureTrend } from "../utils/pressure";

const app = new Hono();

const querySchema = z.object({
  lat: z.string().transform(Number).pipe(z.number().min(-90).max(90)),
  lon: z.string().transform(Number).pipe(z.number().min(-180).max(180)),
});

app.get(
  "/",
  zValidator("query", querySchema),
  async (c) => {
    const { lat, lon } = c.req.valid("query");

    try {
      // 並列でデータ取得
      const [weatherData, airQualityData] = await Promise.all([
        getWeatherData(lat, lon, { includeHourlyPressure: true }),
        getAirQualityData(lat, lon),
      ]);

      // 気圧トレンド算出
      const pressureTrend = calculatePressureTrend(
        weatherData.current.pressure,
        weatherData.hourly?.pressure3hAgo
      );

      // 環境アドバイス生成
      const advice = generateEnvironmentAdvice(
        { ...weatherData, pressureTrend },
        airQualityData
      );

      const response: EnvironmentResponse = {
        location: {
          city: weatherData.city,
          latitude: lat,
          longitude: lon,
        },
        weather: {
          current: weatherData.current,
          pressureTrend,
        },
        airQuality: airQualityData,
        advice,
        fetchedAt: new Date().toISOString(),
      };

      return c.json(response);
    } catch (error) {
      console.error("Environment data fetch failed:", error);
      return c.json(
        { error: "Failed to fetch environment data" },
        500
      );
    }
  }
);

export default app;
```

### services/environmentAdvice.ts

```typescript
import type { 
  WeatherDataWithTrend, 
  AirQualityData, 
  EnvironmentAdvice 
} from "../types/environment";

export const generateEnvironmentAdvice = (
  weather: WeatherDataWithTrend,
  airQuality: AirQualityData
): EnvironmentAdvice[] => {
  const advice: EnvironmentAdvice[] = [];
  
  // 大気質（最優先）
  advice.push(generateAirQualityAdvice(airQuality));
  
  // 気温
  const tempAdvice = generateTemperatureAdvice(weather);
  if (tempAdvice) advice.push(tempAdvice);
  
  // UV
  const uvAdvice = generateUVAdvice(weather);
  if (uvAdvice) advice.push(uvAdvice);
  
  // 気圧
  const pressureAdvice = generatePressureAdvice(weather);
  if (pressureAdvice) advice.push(pressureAdvice);
  
  // 湿度
  const humidityAdvice = generateHumidityAdvice(weather);
  if (humidityAdvice) advice.push(humidityAdvice);
  
  // 最大3つまで
  return advice.slice(0, 3);
};

const generateAirQualityAdvice = (
  airQuality: AirQualityData
): EnvironmentAdvice => {
  if (airQuality.aqi <= 50) {
    return {
      type: "air_quality",
      message: "大気質は良好。屋外運動に適しています",
    };
  } else if (airQuality.aqi <= 100) {
    return {
      type: "air_quality",
      message: "大気質は普通です。敏感な方は長時間の屋外活動を控えめに",
    };
  } else {
    return {
      type: "air_quality",
      message: "大気質が悪化しています。屋外での激しい運動は避けましょう",
    };
  }
};

const generateTemperatureAdvice = (
  weather: WeatherDataWithTrend
): EnvironmentAdvice | null => {
  const { temp, feelsLike } = weather.current;
  
  if (temp < 10) {
    return {
      type: "temperature",
      message: "気温が低めです。外出時は暖かい服装を",
    };
  } else if (temp > 30) {
    return {
      type: "temperature",
      message: "気温が高めです。こまめな水分補給と日陰での休憩を",
    };
  } else if (feelsLike < temp - 3) {
    return {
      type: "temperature",
      message: "体感温度が低めです。風が強いので上着があると安心です",
    };
  }
  
  return null;
};

const generateUVAdvice = (
  weather: WeatherDataWithTrend
): EnvironmentAdvice | null => {
  const { uvIndex } = weather.current;
  
  if (uvIndex >= 6) {
    return {
      type: "uv",
      message: "UV指数が高めです。日焼け止めと帽子の着用を推奨します",
    };
  } else if (uvIndex >= 3) {
    return {
      type: "uv",
      message: "UV指数は中程度。長時間の外出には日焼け止めを",
    };
  }
  
  return null;
};

const generatePressureAdvice = (
  weather: WeatherDataWithTrend
): EnvironmentAdvice | null => {
  if (weather.pressureTrend === "falling") {
    return {
      type: "pressure",
      message: "気圧が下降中です。頭痛が出やすい方はお気をつけて",
    };
  }
  
  return null;
};

const generateHumidityAdvice = (
  weather: WeatherDataWithTrend
): EnvironmentAdvice | null => {
  const { humidity } = weather.current;
  
  if (humidity < 30) {
    return {
      type: "humidity",
      message: "乾燥しています。保湿と水分補給を心がけましょう",
    };
  } else if (humidity > 80) {
    return {
      type: "humidity",
      message: "湿度が高めです。熱中症に注意しましょう",
    };
  }
  
  return null;
};
```

---

## 既存APIとの統合

### /api/advice との関係

`/api/advice` でアドバイス生成時に、内部的に環境データを使用:

```typescript
// routes/advice.ts（Phase 9で実装済み）を拡張

import { getEnvironmentData } from "../services/environment";

app.post("/", async (c) => {
  const body = await c.req.json();
  
  // 環境データ取得（既存の天気・大気質に加えて気圧トレンドも）
  const environmentData = await getEnvironmentData(
    body.location.latitude,
    body.location.longitude
  );
  
  // Claude APIへのプロンプトに環境データを含める
  const advice = await generateMainAdvice({
    ...body,
    environment: environmentData,
  });
  
  return c.json(advice);
});
```

---

## エラーハンドリング

### 外部API失敗時

```typescript
const getEnvironmentDataWithFallback = async (
  lat: number,
  lon: number
): Promise<EnvironmentResponse> => {
  try {
    const [weather, airQuality] = await Promise.all([
      getWeatherData(lat, lon, { includeHourlyPressure: true }),
      getAirQualityData(lat, lon),
    ]);
    
    // 正常処理
    return buildResponse(weather, airQuality);
  } catch (error) {
    // 部分的な失敗の場合、取得できたデータだけで応答
    console.error("Partial environment data fetch failed:", error);
    
    return {
      location: { city: "不明", latitude: lat, longitude: lon },
      weather: null,
      airQuality: null,
      advice: [],
      fetchedAt: new Date().toISOString(),
      error: "一部のデータを取得できませんでした",
    };
  }
};
```

---

## キャッシュ戦略

### Cloudflare Workers KV

環境データは1時間キャッシュ:

```typescript
const CACHE_TTL_SECONDS = 3600; // 1時間

const getCachedEnvironmentData = async (
  kv: KVNamespace,
  lat: number,
  lon: number
): Promise<EnvironmentResponse | null> => {
  const key = `env:${lat.toFixed(2)}:${lon.toFixed(2)}`;
  const cached = await kv.get(key, "json");
  return cached as EnvironmentResponse | null;
};

const cacheEnvironmentData = async (
  kv: KVNamespace,
  lat: number,
  lon: number,
  data: EnvironmentResponse
): Promise<void> => {
  const key = `env:${lat.toFixed(2)}:${lon.toFixed(2)}`;
  await kv.put(key, JSON.stringify(data), {
    expirationTtl: CACHE_TTL_SECONDS,
  });
};
```

---

## テスト観点

### 正常系

- 緯度経度を指定して環境データが取得できる
- 気圧トレンドが正しく算出される
- 環境アドバイスが条件に応じて生成される

### 異常系

- 無効な緯度経度でエラーが返る
- 外部API失敗時にフォールバックが動作する

### 境界値

- 気温: 10°C, 30°C の境界
- UV指数: 3, 6 の境界
- AQI: 50, 100 の境界
- 気圧変化: ±2hPa の境界

---

## 今後のフェーズとの関係

### Phase 11で使用

- UI結合時に環境詳細画面と接続

### Phase 16-19（トラベルモード）で拡張

- 環境差分の算出（Home vs Current）
- ロケーション別の環境データキャッシュ

---

## 関連ドキュメント

- `08-phase-external-api.md` - 外部API統合（天気・大気質）
- `05-phase-condition-top.md` - コンディショントップ画面
- `055-phase-condition-detail.md` - 環境詳細画面
- `travel-mode-condition-spec.md` - 環境差分の仕様

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-11 | 初版作成 |
