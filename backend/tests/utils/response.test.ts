/**
 * @fileoverview Response Utilities Unit Tests
 *
 * utils/response.tsの包括的なユニットテスト。
 * レスポンス生成とエラーハンドリングの正常系・異常系を検証。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

import { beforeEach, describe, expect, it, vi } from 'vitest'
import {
  createSuccessResponse,
  createErrorResponse,
  createValidationErrorResponse,
  sendSuccessResponse,
  sendErrorResponse,
  CommonErrors,
  HTTP_STATUS,
  isSuccessResponse,
  isErrorResponse,
  unwrapResponse,
  type ApiResponse,
} from '@/utils/response'
import type { ValidationError } from '@/utils/validation'

// Mock Hono Context
const createMockContext = () => {
  const mockJson = vi.fn((data: unknown, status?: number) => ({
    data,
    status: status || 200,
  }))

  return { json: mockJson } as any
}

describe('Response Utilities', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('createSuccessResponse', () => {
    it('should create success response with string data', () => {
      const response = createSuccessResponse('test data')

      expect(response.success).toBe(true)
      expect(response.data).toBe('test data')
    })

    it('should create success response with object data', () => {
      const data = { id: 1, name: 'Test' }
      const response = createSuccessResponse(data)

      expect(response.success).toBe(true)
      expect(response.data).toEqual(data)
    })

    it('should create success response with array data', () => {
      const data = [1, 2, 3]
      const response = createSuccessResponse(data)

      expect(response.success).toBe(true)
      expect(response.data).toEqual(data)
    })

    it('should create success response with null data', () => {
      const response = createSuccessResponse(null)

      expect(response.success).toBe(true)
      expect(response.data).toBe(null)
    })
  })

  describe('createErrorResponse', () => {
    it('should create error response with message', () => {
      const response = createErrorResponse('Something went wrong')

      expect(response.success).toBe(false)
      expect(response.error).toBe('Something went wrong')
    })

    it('should create error response with empty message', () => {
      const response = createErrorResponse('')

      expect(response.success).toBe(false)
      expect(response.error).toBe('')
    })
  })

  describe('createValidationErrorResponse', () => {
    it('should create HTTP response from validation error', () => {
      const mockContext = createMockContext()
      const error: ValidationError = {
        type: 'SCHEMA_ERROR',
        message: 'Validation failed',
        statusCode: 400,
        field: 'name',
      }

      const response = createValidationErrorResponse(mockContext, error)

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Validation failed' },
        400,
      )
      expect(response.status).toBe(400)
    })

    it('should handle invalid status codes', () => {
      const mockContext = createMockContext()
      const error: ValidationError = {
        type: 'PARSE_ERROR',
        message: 'Parse error',
        statusCode: 999, // Invalid status code
      }

      createValidationErrorResponse(mockContext, error)

      // toValidStatusCode should convert invalid codes to 500
      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Parse error' },
        500,
      )
    })
  })

  describe('sendSuccessResponse', () => {
    it('should send success response with default status', () => {
      const mockContext = createMockContext()
      const data = { message: 'Success' }

      sendSuccessResponse(mockContext, data)

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: true, data },
        200,
      )
    })

    it('should send success response with custom status', () => {
      const mockContext = createMockContext()
      const data = { id: 1 }

      sendSuccessResponse(mockContext, data, 201)

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: true, data },
        201,
      )
    })
  })

  describe('sendErrorResponse', () => {
    it('should send error response with default status', () => {
      const mockContext = createMockContext()

      sendErrorResponse(mockContext, 'Error occurred')

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Error occurred' },
        500,
      )
    })

    it('should send error response with custom status', () => {
      const mockContext = createMockContext()

      sendErrorResponse(mockContext, 'Not found', 404)

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Not found' },
        404,
      )
    })
  })

  describe('CommonErrors', () => {
    let mockContext: any

    beforeEach(() => {
      mockContext = createMockContext()
    })

    it('should create bad request error', () => {
      CommonErrors.badRequest(mockContext, 'Invalid input')

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Invalid input' },
        HTTP_STATUS.BAD_REQUEST,
      )
    })

    it('should create bad request error with default message', () => {
      CommonErrors.badRequest(mockContext)

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Bad Request' },
        HTTP_STATUS.BAD_REQUEST,
      )
    })

    it('should create unauthorized error', () => {
      CommonErrors.unauthorized(mockContext, 'Token invalid')

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Token invalid' },
        HTTP_STATUS.UNAUTHORIZED,
      )
    })

    it('should create forbidden error', () => {
      CommonErrors.forbidden(mockContext)

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Forbidden' },
        HTTP_STATUS.FORBIDDEN,
      )
    })

    it('should create not found error', () => {
      CommonErrors.notFound(mockContext, 'Resource not found')

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Resource not found' },
        HTTP_STATUS.NOT_FOUND,
      )
    })

    it('should create conflict error', () => {
      CommonErrors.conflict(mockContext, 'Already exists')

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Already exists' },
        HTTP_STATUS.CONFLICT,
      )
    })

    it('should create unsupported media type error', () => {
      CommonErrors.unsupportedMediaType(mockContext)

      expect(mockContext.json).toHaveBeenCalledWith(
        {
          success: false,
          error: 'Unsupported Media Type: application/json required',
        },
        HTTP_STATUS.UNSUPPORTED_MEDIA_TYPE,
      )
    })

    it('should create rate limited error', () => {
      CommonErrors.rateLimited(mockContext, 'Too many requests')

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Too many requests' },
        HTTP_STATUS.RATE_LIMITED,
      )
    })

    it('should create internal error', () => {
      CommonErrors.internalError(mockContext, 'Database connection failed')

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Database connection failed' },
        HTTP_STATUS.INTERNAL_SERVER_ERROR,
      )
    })

    it('should create bad gateway error', () => {
      CommonErrors.badGateway(mockContext, 'Upstream server error')

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Upstream server error' },
        HTTP_STATUS.BAD_GATEWAY,
      )
    })

    it('should create service unavailable error', () => {
      CommonErrors.serviceUnavailable(mockContext, 'Maintenance mode')

      expect(mockContext.json).toHaveBeenCalledWith(
        { success: false, error: 'Maintenance mode' },
        HTTP_STATUS.SERVICE_UNAVAILABLE,
      )
    })
  })

  describe('Type Guards', () => {
    describe('isSuccessResponse', () => {
      it('should return true for success response', () => {
        const response: ApiResponse<string> = {
          success: true,
          data: 'test',
        }

        expect(isSuccessResponse(response)).toBe(true)
      })

      it('should return false for error response', () => {
        const response: ApiResponse<string> = {
          success: false,
          error: 'Test error',
        }

        expect(isSuccessResponse(response)).toBe(false)
      })
    })

    describe('isErrorResponse', () => {
      it('should return false for success response', () => {
        const response: ApiResponse<string> = {
          success: true,
          data: 'test',
        }

        expect(isErrorResponse(response)).toBe(false)
      })

      it('should return true for error response', () => {
        const response: ApiResponse<string> = {
          success: false,
          error: 'Test error',
        }

        expect(isErrorResponse(response)).toBe(true)
      })
    })
  })

  describe('unwrapResponse', () => {
    it('should return data for success response', () => {
      const response: ApiResponse<string> = {
        success: true,
        data: 'test data',
      }

      expect(unwrapResponse(response)).toBe('test data')
    })

    it('should throw error for error response', () => {
      const response: ApiResponse<string> = {
        success: false,
        error: 'Something went wrong',
      }

      expect(() => unwrapResponse(response)).toThrow(
        'API Error: Something went wrong',
      )
    })

    it('should unwrap complex object data', () => {
      const data = { id: 1, name: 'Test', items: [1, 2, 3] }
      const response: ApiResponse<typeof data> = {
        success: true,
        data,
      }

      expect(unwrapResponse(response)).toEqual(data)
    })
  })

  describe('HTTP_STATUS constants', () => {
    it('should have correct status codes', () => {
      expect(HTTP_STATUS.OK).toBe(200)
      expect(HTTP_STATUS.CREATED).toBe(201)
      expect(HTTP_STATUS.BAD_REQUEST).toBe(400)
      expect(HTTP_STATUS.UNAUTHORIZED).toBe(401)
      expect(HTTP_STATUS.FORBIDDEN).toBe(403)
      expect(HTTP_STATUS.NOT_FOUND).toBe(404)
      expect(HTTP_STATUS.CONFLICT).toBe(409)
      expect(HTTP_STATUS.UNSUPPORTED_MEDIA_TYPE).toBe(415)
      expect(HTTP_STATUS.RATE_LIMITED).toBe(429)
      expect(HTTP_STATUS.INTERNAL_SERVER_ERROR).toBe(500)
      expect(HTTP_STATUS.BAD_GATEWAY).toBe(502)
      expect(HTTP_STATUS.SERVICE_UNAVAILABLE).toBe(503)
    })
  })
})
