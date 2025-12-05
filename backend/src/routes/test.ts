/**
 * @fileoverview Test API Routes
 *
 * 開発・テスト用のAPIエンドポイントを定義します。
 * 外部API接続のテスト、モック応答の生成、および開発環境での
 * 機能検証を目的としたエンドポイントを提供します。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { Hono } from 'hono'
import { getWeather } from '../services/weather'
import type { Bindings } from '../types/bindings'
import { handleError, toValidStatusCode } from '../utils/errors'
import { WeatherTestRequestSchema, AnalyzeTestRequestSchema } from '../types/requests'
import { validateRequestBody, isValidationSuccess } from '../utils/validation'
import { sendSuccessResponse, createValidationErrorResponse } from '../utils/response'

/**
 * テスト用APIのルーターインスタンス
 * 開発・デバッグ目的のエンドポイントを管理
 */
export const testRoutes = new Hono<{ Bindings: Bindings }>()

/**
 * POST /weather
 *
 * 天気APIの接続テストを実行します。
 * Open-Meteo APIとの統合が正常に動作するかを確認するためのエンドポイントです。
 *
 * @param latitude - テスト用緯度座標
 * @param longitude - テスト用経度座標
 * @returns 天気データ取得の成功/失敗結果
 * @throws {400} 無効な座標が指定された場合
 * @throws {500} 天気API接続エラー
 */
testRoutes.post('/weather', async (c): Promise<Response> => {
  try {
    // 型安全なリクエストボディ検証
    const validationResult = await validateRequestBody(c, WeatherTestRequestSchema)

    if (!isValidationSuccess(validationResult)) {
      return createValidationErrorResponse(c, validationResult.error)
    }

    const { latitude, longitude } = validationResult.data

    const weather = await getWeather(latitude, longitude)
    return sendSuccessResponse(c, {
      weather,
      message: 'Weather API integration working correctly',
    })
  } catch (error) {
    const { message, statusCode } = handleError(error)
    const validStatusCode = toValidStatusCode(statusCode)
    return c.json({ error: message }, validStatusCode)
  }
})

/**
 * POST /analyze-mock
 *
 * モックAI応答を使用した分析テストを実行します。
 * 実際のClaude API呼び出しを行わずに、システム全体の動作を確認するためのエンドポイントです。
 * リアルな天気データとモックアドバイスを組み合わせてレスポンスを生成します。
 *
 * @param location - テスト用位置情報
 * @returns モック健康アドバイスとリアル天気データ
 * @throws {500} 天気API接続エラー
 */
testRoutes.post('/analyze-mock', async (c): Promise<Response> => {
  try {
    // 型安全なリクエストボディ検証
    const validationResult = await validateRequestBody(c, AnalyzeTestRequestSchema)

    if (!isValidationSuccess(validationResult)) {
      return createValidationErrorResponse(c, validationResult.error)
    }

    const { location } = validationResult.data

    // Get real weather data
    const weather = await getWeather(location.latitude, location.longitude)

    // Return mock advice
    const mockAdvice = {
      theme: 'Test Day',
      summary: 'This is a test response. Weather data was successfully retrieved and integrated.',
      breakfast: {
        recommendation: 'Test breakfast recommendation',
        reason: 'This is a test reason',
        examples: ['Test meal 1', 'Test meal 2'],
      },
      lunch: {
        recommendation: 'Test lunch recommendation',
        reason: 'Test reason',
        timing: '12:30 PM',
        examples: ['Test meal 1'],
        avoid: ['Test avoid'],
      },
      dinner: {
        recommendation: 'Test dinner recommendation',
        reason: 'Test reason',
        timing: '6:30 PM',
        examples: ['Test meal 1'],
        avoid: ['Test avoid'],
      },
      exercise: {
        recommendation: 'Test exercise',
        intensity: 'Moderate' as const,
        reason: 'Test reason',
        timing: 'Morning',
        avoid: ['Test avoid exercise'],
      },
      hydration: {
        target: '2.5L',
        schedule: {
          morning: '800ml',
          afternoon: '800ml',
          evening: '600ml',
        },
        reason: 'Test hydration reason',
      },
      breathing: {
        technique: 'Test breathing technique',
        duration: '5 minutes',
        frequency: '3 times',
        instructions: ['Step 1', 'Step 2', 'Step 3'],
      },
      sleep_preparation: {
        bedtime: '10:30 PM',
        routine: ['Activity 1', 'Activity 2'],
        avoid: ['Avoid 1', 'Avoid 2'],
      },
      weather_considerations: {
        warnings: [`Temperature: ${weather.current.temperature_2m}°C`],
        opportunities: ['Good weather for outdoor activities'],
      },
      priority_actions: ['Test priority 1', 'Test priority 2', 'Test priority 3'],
    }

    return sendSuccessResponse(c, {
      advice: mockAdvice,
      weather_summary: {
        temperature: weather.current.temperature_2m,
        humidity: weather.current.relative_humidity_2m,
        uv_index: weather.daily.uv_index_max[0],
      },
      message: 'Mock analysis complete with real weather data',
    })
  } catch (error) {
    const { message, statusCode } = handleError(error)
    const validStatusCode = toValidStatusCode(statusCode)
    return c.json({ error: message }, validStatusCode)
  }
})
