/**
 * @fileoverview Standardized Response Utilities
 *
 * APIレスポンス生成の標準化ユーティリティ群。
 * 一貫したレスポンス形式とエラーハンドリングを提供。
 * CLAUDE.mdのDRY原則と型安全性原則に完全準拠。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import type { Context } from 'hono'
import { toValidStatusCode } from './errors'
import type { ValidationError } from './validation'

/**
 * 標準的な成功レスポンス型
 */
export interface SuccessResponse<T> {
  success: true
  data: T
}

/**
 * 標準的なエラーレスポンス型
 */
export interface ErrorResponse {
  success: false
  error: string
}

/**
 * APIレスポンスの型（成功またはエラー）
 */
export type ApiResponse<T> = SuccessResponse<T> | ErrorResponse

/**
 * HTTPステータスコード定数
 */
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNSUPPORTED_MEDIA_TYPE: 415,
  RATE_LIMITED: 429,
  INTERNAL_SERVER_ERROR: 500,
  BAD_GATEWAY: 502,
  SERVICE_UNAVAILABLE: 503,
  GATEWAY_TIMEOUT: 504,
} as const

/**
 * 成功レスポンスを生成
 *
 * @template T - レスポンスデータの型
 * @param data - レスポンスデータ
 * @returns 標準的な成功レスポンス
 */
export const createSuccessResponse = <T>(data: T): SuccessResponse<T> => ({
  success: true,
  data,
})

/**
 * エラーレスポンスを生成
 *
 * @param message - エラーメッセージ
 * @returns 標準的なエラーレスポンス
 */
export const createErrorResponse = (message: string): ErrorResponse => ({
  success: false,
  error: message,
})

/**
 * バリデーションエラーからHTTPレスポンスを生成
 *
 * @param c - Honoのcontext
 * @param error - バリデーションエラー
 * @returns HTTPレスポンス
 */
export const createValidationErrorResponse = (
  c: Context,
  error: ValidationError,
): Response => {
  // TypeScript Hono Standards準拠：シンプルで明確なエラーレスポンス
  const statusCode = toValidStatusCode(error.statusCode)
  return c.json({ success: false, error: error.message }, statusCode)
}

/**
 * 成功レスポンスを返すHTTPレスポンスを生成
 *
 * @template T - レスポンスデータの型
 * @param c - Honoのcontext
 * @param data - レスポンスデータ
 * @param status - HTTPステータスコード（デフォルト: 200）
 * @returns HTTPレスポンス
 */
export const sendSuccessResponse = <T>(
  c: Context,
  data: T,
  status: number = HTTP_STATUS.OK,
): Response => {
  // CLAUDE.md原則：シンプルで明確
  const validStatus =
    status >= 200 && status < 300 ? (status as 200 | 201) : HTTP_STATUS.OK
  return c.json(createSuccessResponse(data), validStatus)
}

/**
 * エラーレスポンスを返すHTTPレスポンスを生成
 *
 * @param c - Honoのcontext
 * @param message - エラーメッセージ
 * @param status - HTTPステータスコード（デフォルト: 500）
 * @returns HTTPレスポンス
 */
export const sendErrorResponse = (
  c: Context,
  message: string,
  status: number = HTTP_STATUS.INTERNAL_SERVER_ERROR,
): Response => {
  const validStatus = toValidStatusCode(status)
  return c.json(createErrorResponse(message), validStatus)
}

/**
 * 一般的なエラーレスポンス生成器
 */
export const CommonErrors = {
  /**
   * Bad Request (400) エラー
   */
  badRequest: (c: Context, message = 'Bad Request'): Response =>
    sendErrorResponse(c, message, HTTP_STATUS.BAD_REQUEST),

  /**
   * Unauthorized (401) エラー
   */
  unauthorized: (c: Context, message = 'Unauthorized'): Response =>
    sendErrorResponse(c, message, HTTP_STATUS.UNAUTHORIZED),

  /**
   * Forbidden (403) エラー
   */
  forbidden: (c: Context, message = 'Forbidden'): Response =>
    sendErrorResponse(c, message, HTTP_STATUS.FORBIDDEN),

  /**
   * Not Found (404) エラー
   */
  notFound: (c: Context, message = 'Not Found'): Response =>
    sendErrorResponse(c, message, HTTP_STATUS.NOT_FOUND),

  /**
   * Conflict (409) エラー
   */
  conflict: (c: Context, message = 'Conflict'): Response =>
    sendErrorResponse(c, message, HTTP_STATUS.CONFLICT),

  /**
   * Unsupported Media Type (415) エラー
   */
  unsupportedMediaType: (
    c: Context,
    message = 'Unsupported Media Type: application/json required',
  ): Response =>
    sendErrorResponse(c, message, HTTP_STATUS.UNSUPPORTED_MEDIA_TYPE),

  /**
   * Rate Limited (429) エラー
   */
  rateLimited: (c: Context, message = 'Rate limit exceeded'): Response =>
    sendErrorResponse(c, message, HTTP_STATUS.RATE_LIMITED),

  /**
   * Internal Server Error (500) エラー
   */
  internalError: (c: Context, message = 'Internal Server Error'): Response =>
    sendErrorResponse(c, message, HTTP_STATUS.INTERNAL_SERVER_ERROR),

  /**
   * Bad Gateway (502) エラー
   */
  badGateway: (c: Context, message = 'Bad Gateway'): Response =>
    sendErrorResponse(c, message, HTTP_STATUS.BAD_GATEWAY),

  /**
   * Service Unavailable (503) エラー
   */
  serviceUnavailable: (c: Context, message = 'Service Unavailable'): Response =>
    sendErrorResponse(c, message, HTTP_STATUS.SERVICE_UNAVAILABLE),
} as const

/**
 * 型ガード：レスポンスが成功かどうかを判定
 */
export const isSuccessResponse = <T>(
  response: ApiResponse<T>,
): response is SuccessResponse<T> => response.success

/**
 * 型ガード：レスポンスがエラーかどうかを判定
 */
export const isErrorResponse = <T>(
  response: ApiResponse<T>,
): response is ErrorResponse => !response.success

/**
 * APIレスポンスから値を安全に取得（エラー時は例外をthrow）
 */
export const unwrapResponse = <T>(response: ApiResponse<T>): T => {
  if (isSuccessResponse(response)) {
    return response.data
  }

  throw new Error(`API Error: ${response.error}`)
}
