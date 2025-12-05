/**
 * @fileoverview Centralized Validation Utilities
 *
 * 全バリデーション処理を集約した型安全なユーティリティ群。
 * CLAUDE.mdのDRY原則と型安全性原則に完全準拠。
 * Zodスキーマベースの統一バリデーション処理を提供します。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import type { Context } from 'hono'
import type { z } from 'zod'
import { ensureJsonRequest } from './contentType'

/**
 * バリデーション結果の型定義
 */
export type ValidationResult<T> =
  | { success: true; data: T }
  | { success: false; error: ValidationError }

/**
 * バリデーションエラーの詳細情報
 */
export interface ValidationError {
  type:
    | 'CONTENT_TYPE'
    | 'PARSE_ERROR'
    | 'SCHEMA_ERROR'
    | 'COORDINATE_ERROR'
    | 'MISSING_FIELD'
  message: string
  statusCode: number
  field?: string
  value?: unknown
}

/**
 * 座標情報の型定義
 */
export interface Coordinates {
  latitude: number
  longitude: number
}

/**
 * Honoリクエストボディを型安全に検証
 *
 * Content-Type確認、JSONパース、Zodスキーマ検証を一括実行。
 * 型アサーションを使用せず、完全に型安全な処理を実現。
 *
 * @template T - 期待されるリクエストボディの型
 * @param c - Honoのcontext
 * @param schema - 検証用Zodスキーマ
 * @returns 検証されたリクエストボディまたはエラー
 */
export const validateRequestBody = async <T>(
  c: Context,
  schema: z.ZodSchema<T>,
): Promise<ValidationResult<T>> => {
  // Content-Type検証
  const contentType = c.req.header('content-type')
  if (!ensureJsonRequest(contentType)) {
    return {
      success: false,
      error: {
        type: 'CONTENT_TYPE',
        message: 'Unsupported Media Type: application/json required',
        statusCode: 415,
      },
    }
  }

  try {
    // リクエストボディを文字列として取得
    const bodyText = await c.req.text()

    if (!bodyText.trim()) {
      return {
        success: false,
        error: {
          type: 'PARSE_ERROR',
          message: 'Request body is empty',
          statusCode: 400,
        },
      }
    }

    // JSONパース
    let parsed: unknown
    try {
      parsed = JSON.parse(bodyText)
    } catch (_parseError) {
      return {
        success: false,
        error: {
          type: 'PARSE_ERROR',
          message: 'Invalid JSON in request body',
          statusCode: 400,
        },
      }
    }

    // Zodスキーマによる検証
    const validationResult = schema.safeParse(parsed)

    if (!validationResult.success) {
      const firstIssue = validationResult.error.issues[0]
      const field = firstIssue
        ? firstIssue.path.join('.') || '(root)'
        : '(unknown)'
      const message = firstIssue ? firstIssue.message : 'Validation failed'

      return {
        success: false,
        error: {
          type: 'SCHEMA_ERROR',
          message: `Validation failed: ${message}`,
          statusCode: 400,
          field,
          value: parsed,
        },
      }
    }

    return {
      success: true,
      data: validationResult.data,
    }
  } catch (_error) {
    return {
      success: false,
      error: {
        type: 'PARSE_ERROR',
        message: 'Failed to read request body',
        statusCode: 400,
      },
    }
  }
}

/**
 * 座標（緯度・経度）の妥当性を検証
 *
 * 型チェックと範囲チェックを実行し、NaN値も検出します。
 *
 * @param latitude - 緯度（-90〜90の範囲）
 * @param longitude - 経度（-180〜180の範囲）
 * @returns 検証結果
 */
export const validateCoordinates = (
  latitude: unknown,
  longitude: unknown,
): ValidationResult<Coordinates> => {
  // 型チェック
  if (typeof latitude !== 'number' || typeof longitude !== 'number') {
    return {
      success: false,
      error: {
        type: 'COORDINATE_ERROR',
        message: 'Latitude and longitude must be numbers',
        statusCode: 400,
        field: typeof latitude !== 'number' ? 'latitude' : 'longitude',
        value: typeof latitude !== 'number' ? latitude : longitude,
      },
    }
  }

  // NaNチェック
  if (Number.isNaN(latitude) || Number.isNaN(longitude)) {
    return {
      success: false,
      error: {
        type: 'COORDINATE_ERROR',
        message: 'Coordinates cannot be NaN',
        statusCode: 400,
        field: Number.isNaN(latitude) ? 'latitude' : 'longitude',
        value: Number.isNaN(latitude) ? latitude : longitude,
      },
    }
  }

  // 範囲チェック
  if (latitude < -90 || latitude > 90) {
    return {
      success: false,
      error: {
        type: 'COORDINATE_ERROR',
        message: 'Latitude must be between -90 and 90',
        statusCode: 400,
        field: 'latitude',
        value: latitude,
      },
    }
  }

  if (longitude < -180 || longitude > 180) {
    return {
      success: false,
      error: {
        type: 'COORDINATE_ERROR',
        message: 'Longitude must be between -180 and 180',
        statusCode: 400,
        field: 'longitude',
        value: longitude,
      },
    }
  }

  return {
    success: true,
    data: { latitude, longitude },
  }
}

/**
 * 必須フィールドの存在を確認
 *
 * オブジェクトの指定されたフィールドが存在し、null/undefinedでないことを確認。
 *
 * @param obj - 確認対象のオブジェクト
 * @param fields - 必須フィールドのリスト
 * @returns 検証結果
 */
export const validateRequiredFields = <T extends Record<string, unknown>>(
  obj: T,
  fields: (keyof T)[],
): ValidationResult<T> => {
  for (const field of fields) {
    if (!(field in obj) || obj[field] === null || obj[field] === undefined) {
      return {
        success: false,
        error: {
          type: 'MISSING_FIELD',
          message: `Missing required field: ${String(field)}`,
          statusCode: 400,
          field: String(field),
        },
      }
    }
  }

  return {
    success: true,
    data: obj,
  }
}

/**
 * API Key（環境変数）の妥当性を検証
 *
 * @param apiKey - 検証するAPIキー
 * @param keyName - APIキーの名前（エラーメッセージ用）
 * @returns 検証結果
 */
export const validateApiKey = (
  apiKey: string | undefined,
  keyName = 'API key',
): ValidationResult<string> => {
  if (!apiKey || apiKey.trim() === '') {
    return {
      success: false,
      error: {
        type: 'MISSING_FIELD',
        message: `${keyName} is missing or empty`,
        statusCode: 500,
        field: keyName.toLowerCase().replace(/\s+/g, '_'),
      },
    }
  }

  // プレースホルダーキーのチェック
  if (apiKey.includes('xxxxxxxxxxxx') || apiKey === 'test-key-not-configured') {
    return {
      success: false,
      error: {
        type: 'MISSING_FIELD',
        message: `${keyName} is not properly configured`,
        statusCode: 500,
        field: keyName.toLowerCase().replace(/\s+/g, '_'),
      },
    }
  }

  return {
    success: true,
    data: apiKey,
  }
}

/**
 * 型ガード：ValidationResultが成功かどうかを判定
 */
export const isValidationSuccess = <T>(
  result: ValidationResult<T>,
): result is { success: true; data: T } => result.success

/**
 * バリデーション結果から値を安全に取得（エラー時は例外をthrow）
 */
export const unwrapValidation = <T>(result: ValidationResult<T>): T => {
  if (isValidationSuccess(result)) {
    return result.data
  }

  throw new Error(`Validation failed: ${result.error.message}`)
}

/**
 * 複数のバリデーション結果を組み合わせ
 *
 * すべてが成功の場合のみ成功を返し、一つでも失敗があれば最初の失敗を返す
 */
export const combineValidations = <T extends readonly unknown[]>(
  ...results: { [K in keyof T]: ValidationResult<T[K]> }
): ValidationResult<T> => {
  for (const result of results) {
    if (!isValidationSuccess(result)) {
      return result as ValidationResult<T>
    }
  }

  const dataArray = results.map(
    (result) => (result as { success: true; data: unknown }).data,
  )
  return {
    success: true,
    data: dataArray as unknown as T,
  }
}
