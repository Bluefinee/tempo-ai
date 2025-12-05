/**
 * @fileoverview Validation Utilities Unit Tests
 *
 * utils/validation.tsの包括的なユニットテスト。
 * すべてのバリデーション関数の正常系・異常系を網羅的にテスト。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { beforeEach, describe, expect, it, vi } from 'vitest'
import { z } from 'zod'
import {
  combineValidations,
  isValidationSuccess,
  unwrapValidation,
  type ValidationResult,
  validateApiKey,
  validateCoordinates,
  validateRequestBody,
  validateRequiredFields,
} from '@/utils/validation'

// Mock Hono Context
const createMockContext = (
  headers: Record<string, string> = {},
  text: string = '{}',
  shouldThrow = false,
) => {
  const mockReq = {
    header: vi.fn((name: string) => headers[name]),
    text: vi.fn(async () => {
      if (shouldThrow) {
        throw new Error('Read error')
      }
      return text
    }),
  }

  return { req: mockReq } as any
}

describe('Validation Utilities', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('validateRequestBody', () => {
    const testSchema = z.object({
      name: z.string(),
      age: z.number(),
    })

    it('should successfully validate valid JSON request', async () => {
      const mockContext = createMockContext(
        { 'content-type': 'application/json' },
        '{"name": "John", "age": 30}',
      )

      const result = await validateRequestBody(mockContext, testSchema)

      expect(result.success).toBe(true)
      if (result.success) {
        expect(result.data).toEqual({ name: 'John', age: 30 })
      }
    })

    it('should fail with invalid content type', async () => {
      const mockContext = createMockContext(
        { 'content-type': 'text/plain' },
        '{"name": "John", "age": 30}',
      )

      const result = await validateRequestBody(mockContext, testSchema)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('CONTENT_TYPE')
        expect(result.error.statusCode).toBe(415)
        expect(result.error.message).toContain('application/json required')
      }
    })

    it('should fail with empty request body', async () => {
      const mockContext = createMockContext(
        { 'content-type': 'application/json' },
        '',
      )

      const result = await validateRequestBody(mockContext, testSchema)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('PARSE_ERROR')
        expect(result.error.statusCode).toBe(400)
        expect(result.error.message).toBe('Request body is empty')
      }
    })

    it('should fail with invalid JSON', async () => {
      const mockContext = createMockContext(
        { 'content-type': 'application/json' },
        '{"invalid": json}',
      )

      const result = await validateRequestBody(mockContext, testSchema)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('PARSE_ERROR')
        expect(result.error.statusCode).toBe(400)
        expect(result.error.message).toBe('Invalid JSON in request body')
      }
    })

    it('should fail with schema validation error', async () => {
      const mockContext = createMockContext(
        { 'content-type': 'application/json' },
        '{"name": "John", "age": "thirty"}',
      )

      const result = await validateRequestBody(mockContext, testSchema)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('SCHEMA_ERROR')
        expect(result.error.statusCode).toBe(400)
        expect(result.error.message).toContain('Validation failed')
        expect(result.error.field).toBe('age')
      }
    })

    it('should handle missing required fields', async () => {
      const mockContext = createMockContext(
        { 'content-type': 'application/json' },
        '{"name": "John"}',
      )

      const result = await validateRequestBody(mockContext, testSchema)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('SCHEMA_ERROR')
        expect(result.error.field).toBe('age')
      }
    })

    it('should handle request reading error', async () => {
      const mockContext = createMockContext(
        { 'content-type': 'application/json' },
        '',
        true,
      )

      const result = await validateRequestBody(mockContext, testSchema)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('PARSE_ERROR')
        expect(result.error.message).toBe('Failed to read request body')
      }
    })
  })

  describe('validateCoordinates', () => {
    it('should validate correct coordinates', () => {
      const result = validateCoordinates(35.6762, 139.6503)

      expect(result.success).toBe(true)
      if (result.success) {
        expect(result.data).toEqual({ latitude: 35.6762, longitude: 139.6503 })
      }
    })

    it('should validate extreme valid coordinates', () => {
      const result = validateCoordinates(90, -180)

      expect(result.success).toBe(true)
      if (result.success) {
        expect(result.data).toEqual({ latitude: 90, longitude: -180 })
      }
    })

    it('should fail with non-number latitude', () => {
      const result = validateCoordinates('35.6762', 139.6503)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('COORDINATE_ERROR')
        expect(result.error.field).toBe('latitude')
        expect(result.error.value).toBe('35.6762')
        expect(result.error.message).toBe(
          'Latitude and longitude must be numbers',
        )
      }
    })

    it('should fail with non-number longitude', () => {
      const result = validateCoordinates(35.6762, '139.6503')

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('COORDINATE_ERROR')
        expect(result.error.field).toBe('longitude')
        expect(result.error.value).toBe('139.6503')
      }
    })

    it('should fail with NaN latitude', () => {
      const result = validateCoordinates(NaN, 139.6503)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('COORDINATE_ERROR')
        expect(result.error.field).toBe('latitude')
        expect(result.error.message).toBe('Coordinates cannot be NaN')
      }
    })

    it('should fail with NaN longitude', () => {
      const result = validateCoordinates(35.6762, NaN)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('COORDINATE_ERROR')
        expect(result.error.field).toBe('longitude')
        expect(result.error.message).toBe('Coordinates cannot be NaN')
      }
    })

    it('should fail with latitude out of range (too high)', () => {
      const result = validateCoordinates(91, 139.6503)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('COORDINATE_ERROR')
        expect(result.error.field).toBe('latitude')
        expect(result.error.message).toBe('Latitude must be between -90 and 90')
        expect(result.error.value).toBe(91)
      }
    })

    it('should fail with latitude out of range (too low)', () => {
      const result = validateCoordinates(-91, 139.6503)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.field).toBe('latitude')
        expect(result.error.value).toBe(-91)
      }
    })

    it('should fail with longitude out of range (too high)', () => {
      const result = validateCoordinates(35.6762, 181)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.field).toBe('longitude')
        expect(result.error.message).toBe(
          'Longitude must be between -180 and 180',
        )
        expect(result.error.value).toBe(181)
      }
    })

    it('should fail with longitude out of range (too low)', () => {
      const result = validateCoordinates(35.6762, -181)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.field).toBe('longitude')
        expect(result.error.value).toBe(-181)
      }
    })
  })

  describe('validateRequiredFields', () => {
    it('should validate object with all required fields', () => {
      const obj = { name: 'John', age: 30, email: 'john@example.com' }
      const result = validateRequiredFields(obj, ['name', 'age'])

      expect(result.success).toBe(true)
      if (result.success) {
        expect(result.data).toEqual(obj)
      }
    })

    it('should fail with missing field', () => {
      const obj = { name: 'John' } as { name: string; age?: number }
      const result = validateRequiredFields(obj, ['name', 'age'])

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('MISSING_FIELD')
        expect(result.error.field).toBe('age')
        expect(result.error.message).toBe('Missing required field: age')
      }
    })

    it('should fail with null field', () => {
      const obj = { name: 'John', age: null }
      const result = validateRequiredFields(obj, ['name', 'age'])

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.field).toBe('age')
      }
    })

    it('should fail with undefined field', () => {
      const obj = { name: 'John', age: undefined }
      const result = validateRequiredFields(obj, ['name', 'age'])

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.field).toBe('age')
      }
    })

    it('should succeed with empty required fields array', () => {
      const obj = { name: 'John' }
      const result = validateRequiredFields(obj, [])

      expect(result.success).toBe(true)
    })
  })

  describe('validateApiKey', () => {
    it('should validate proper API key', () => {
      const result = validateApiKey('sk-ant-api03-valid-key-here')

      expect(result.success).toBe(true)
      if (result.success) {
        expect(result.data).toBe('sk-ant-api03-valid-key-here')
      }
    })

    it('should fail with undefined API key', () => {
      const result = validateApiKey(undefined)

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.type).toBe('MISSING_FIELD')
        expect(result.error.message).toBe('API key is missing or empty')
        expect(result.error.statusCode).toBe(500)
      }
    })

    it('should fail with empty API key', () => {
      const result = validateApiKey('')

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.message).toBe('API key is missing or empty')
      }
    })

    it('should fail with whitespace-only API key', () => {
      const result = validateApiKey('   ')

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.message).toBe('API key is missing or empty')
      }
    })

    it('should fail with placeholder API key', () => {
      const result = validateApiKey(
        'sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
      )

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.message).toBe('API key is not properly configured')
      }
    })

    it('should fail with test placeholder', () => {
      const result = validateApiKey('test-key-not-configured')

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.message).toBe('API key is not properly configured')
      }
    })

    it('should use custom key name in error message', () => {
      const result = validateApiKey(undefined, 'Claude API Key')

      expect(result.success).toBe(false)
      if (!result.success) {
        expect(result.error.message).toBe('Claude API Key is missing or empty')
        expect(result.error.field).toBe('claude_api_key')
      }
    })
  })

  describe('isValidationSuccess', () => {
    it('should return true for successful validation', () => {
      const successResult: ValidationResult<string> = {
        success: true,
        data: 'test',
      }

      expect(isValidationSuccess(successResult)).toBe(true)
    })

    it('should return false for failed validation', () => {
      const failResult: ValidationResult<string> = {
        success: false,
        error: {
          type: 'PARSE_ERROR',
          message: 'Test error',
          statusCode: 400,
        },
      }

      expect(isValidationSuccess(failResult)).toBe(false)
    })
  })

  describe('unwrapValidation', () => {
    it('should return data for successful validation', () => {
      const successResult: ValidationResult<string> = {
        success: true,
        data: 'test data',
      }

      expect(unwrapValidation(successResult)).toBe('test data')
    })

    it('should throw error for failed validation', () => {
      const failResult: ValidationResult<string> = {
        success: false,
        error: {
          type: 'PARSE_ERROR',
          message: 'Test error',
          statusCode: 400,
        },
      }

      expect(() => unwrapValidation(failResult)).toThrow(
        'Validation failed: Test error',
      )
    })
  })

  describe('combineValidations', () => {
    it('should combine successful validations', () => {
      const result1: ValidationResult<string> = { success: true, data: 'first' }
      const result2: ValidationResult<number> = { success: true, data: 42 }
      const result3: ValidationResult<boolean> = { success: true, data: true }

      const combined = combineValidations(result1, result2, result3)

      expect(combined.success).toBe(true)
      if (combined.success) {
        expect(combined.data).toEqual(['first', 42, true])
      }
    })

    it('should return first error when validations fail', () => {
      const result1: ValidationResult<string> = { success: true, data: 'first' }
      const result2: ValidationResult<number> = {
        success: false,
        error: {
          type: 'PARSE_ERROR',
          message: 'Second failed',
          statusCode: 400,
        },
      }
      const result3: ValidationResult<boolean> = {
        success: false,
        error: {
          type: 'SCHEMA_ERROR',
          message: 'Third failed',
          statusCode: 400,
        },
      }

      const combined = combineValidations(result1, result2, result3)

      expect(combined.success).toBe(false)
      if (!combined.success) {
        expect(combined.error.message).toBe('Second failed')
      }
    })

    it('should handle empty validation array', () => {
      const combined = combineValidations()

      expect(combined.success).toBe(true)
      if (combined.success) {
        expect(combined.data).toEqual([])
      }
    })
  })
})
