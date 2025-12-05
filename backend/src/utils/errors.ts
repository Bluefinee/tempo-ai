/**
 * @fileoverview Error Handling Utilities
 *
 * API全体で使用されるエラーハンドリング機能。
 * カスタムAPIエラークラスと汎用エラーハンドラーを提供し、
 * 一貫性のあるエラーレスポンス形式を保証します。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

/**
 * カスタムAPIエラークラス
 * HTTPステータスコードとエラーコードを含む構造化エラー
 */
export class APIError extends Error {
  /**
   * APIErrorコンストラクタ
   *
   * @param message - エラーメッセージ
   * @param statusCode - HTTPステータスコード（デフォルト: 500）
   * @param code - アプリケーション固有のエラーコード（オプション）
   */
  constructor(
    message: string,
    public statusCode: number = 500,
    public code?: string,
  ) {
    super(message)
    this.name = 'APIError'

    // Ensure proper prototype chain for instanceof checks
    Object.setPrototypeOf(this, APIError.prototype)

    // Capture stack trace in V8 environments
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor)
    } else {
      // Fallback for environments without captureStackTrace
      const errorStack = new Error(message).stack
      if (errorStack) {
        this.stack = errorStack
      }
    }
  }
}

/**
 * 汎用エラーハンドラー
 *
 * 任意のエラーを受け取り、一貫した形式のレスポンスを返します。
 * APIErrorの場合はそのまま使用し、それ以外は500エラーとして処理します。
 *
 * @param error - 処理するエラーオブジェクト
 * @returns 正規化されたエラーレスポンス
 */
export const handleError = (
  error: unknown,
): { message: string; statusCode: number } => {
  if (error instanceof APIError) {
    return {
      message: error.message,
      statusCode: error.statusCode,
    }
  }

  if (error instanceof Error) {
    return {
      message: error.message,
      statusCode: 500,
    }
  }

  return {
    message: 'An unexpected error occurred',
    statusCode: 500,
  }
}

/**
 * Valid HTTP error status codes that can be returned by Hono
 */
export type ValidStatusCode =
  | 400
  | 401
  | 403
  | 404
  | 409
  | 415
  | 422
  | 429
  | 500
  | 502
  | 503
  | 504

/**
 * Normalizes HTTP status codes to ensure they're within valid error range
 *
 * @param statusCode - The status code to normalize
 * @returns A valid HTTP error status code (400-599) or 500 if invalid
 */
export const normalizeStatusCode = (statusCode: number): number =>
  statusCode >= 400 && statusCode <= 599 ? statusCode : 500

/**
 * Converts a numeric status code to a valid Hono-compatible status code type
 *
 * @param statusCode - The status code to convert
 * @returns A valid ValidStatusCode for use with Hono responses
 */
export const toValidStatusCode = (statusCode: number): ValidStatusCode => {
  // Direct comparison for performance and clarity
  switch (statusCode) {
    case 400:
    case 401:
    case 403:
    case 404:
    case 409:
    case 415:
    case 422:
    case 429:
    case 500:
    case 502:
    case 503:
    case 504:
      return statusCode as ValidStatusCode
    default:
      return 500 as ValidStatusCode
  }
}
