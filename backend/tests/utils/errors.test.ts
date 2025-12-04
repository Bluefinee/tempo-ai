/**
 * @fileoverview Error Handling Utility Tests
 *
 * このファイルは、エラーハンドリングユーティリティ（@/utils/errors）のユニットテストを担当します。
 * カスタムAPIエラークラスの動作、エラーハンドラー関数の処理、
 * およびエラーレスポンス形式の検証を行います。
 *
 * テスト対象:
 * - APIErrorクラス - カスタムエラークラス
 * - handleError関数 - 汎用エラーハンドラー
 * - エラーコードとステータスコードの処理
 * - エラーメッセージの形式検証
 * - 異なるエラータイプのハンドリング
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { describe, expect, it } from 'vitest'
import { APIError, handleError } from '@/utils/errors'

describe('Error handling utilities', () => {
  describe('APIError', () => {
    it('should create an APIError with message and status code', () => {
      const error = new APIError('Test error', 400, 'TEST_ERROR')

      expect(error.message).toBe('Test error')
      expect(error.statusCode).toBe(400)
      expect(error.code).toBe('TEST_ERROR')
      expect(error.name).toBe('APIError')
    })

    it('should default to status code 500', () => {
      const error = new APIError('Test error')

      expect(error.statusCode).toBe(500)
    })
  })

  describe('handleError', () => {
    it('should handle APIError correctly', () => {
      const apiError = new APIError('API Error', 404, 'NOT_FOUND')
      const result = handleError(apiError)

      expect(result.message).toBe('API Error')
      expect(result.statusCode).toBe(404)
    })

    it('should handle regular Error correctly', () => {
      const error = new Error('Regular error')
      const result = handleError(error)

      expect(result.message).toBe('Regular error')
      expect(result.statusCode).toBe(500)
    })

    it('should handle unknown errors', () => {
      const result = handleError('unknown error')

      expect(result.message).toBe('An unexpected error occurred')
      expect(result.statusCode).toBe(500)
    })
  })
})
