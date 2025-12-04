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
