// Test files allow any type for testing utilities and mocks
/* eslint-disable @typescript-eslint/no-explicit-any */

import { describe, it, expect } from 'vitest';
import {
  ValidationError,
  AuthenticationError,
  RateLimitError,
  WeatherApiError,
  AirQualityApiError,
  ClaudeApiError,
  InternalServerError,
  mapToAppError,
  createErrorResponse,
  createValidationErrorResponse,
} from './errors.js';

describe('Error Classes', () => {
  describe('ValidationError', () => {
    it('should create validation error with message and field', () => {
      const error = new ValidationError('Invalid field', 'email', 'test@invalid');

      expect(error.message).toBe('Invalid field');
      expect(error.field).toBe('email');
      expect(error.value).toBe('test@invalid');
      expect(error.statusCode).toBe(400);
      expect(error.isOperational).toBe(true);
      expect(error.code).toBe('VALIDATION_ERROR');
      expect(error.name).toBe('ValidationError');
    });

    it('should work without field and value', () => {
      const error = new ValidationError('General validation error');

      expect(error.message).toBe('General validation error');
      expect(error.field).toBeUndefined();
      expect(error.value).toBeUndefined();
    });
  });

  describe('AuthenticationError', () => {
    it('should create authentication error with default message', () => {
      const error = new AuthenticationError();

      expect(error.message).toBe('Authentication required');
      expect(error.statusCode).toBe(401);
      expect(error.isOperational).toBe(true);
      expect(error.code).toBe('UNAUTHORIZED');
    });

    it('should create authentication error with custom message', () => {
      const error = new AuthenticationError('Invalid API key');

      expect(error.message).toBe('Invalid API key');
      expect(error.statusCode).toBe(401);
    });
  });

  describe('RateLimitError', () => {
    it('should create rate limit error without retry after', () => {
      const error = new RateLimitError();

      expect(error.message).toBe('Rate limit exceeded');
      expect(error.statusCode).toBe(429);
      expect(error.isOperational).toBe(true);
      expect(error.code).toBe('RATE_LIMIT_EXCEEDED');
      expect(error.retryAfter).toBeUndefined();
    });

    it('should create rate limit error with retry after', () => {
      const error = new RateLimitError(60);

      expect(error.retryAfter).toBe(60);
    });
  });

  describe('WeatherApiError', () => {
    it('should create weather API error', () => {
      const error = new WeatherApiError('Weather service unavailable', 503);

      expect(error.message).toBe('Weather service unavailable');
      expect(error.statusCode).toBe(502);
      expect(error.service).toBe('weather');
      expect(error.code).toBe('WEATHER_API_ERROR');
      expect(error.apiStatusCode).toBe(503);
    });

    it('should work without API status code', () => {
      const error = new WeatherApiError('Network error');

      expect(error.apiStatusCode).toBeUndefined();
    });
  });

  describe('AirQualityApiError', () => {
    it('should create air quality API error', () => {
      const error = new AirQualityApiError('Service timeout', 504);

      expect(error.message).toBe('Service timeout');
      expect(error.service).toBe('air_quality');
      expect(error.code).toBe('AIR_QUALITY_API_ERROR');
      expect(error.apiStatusCode).toBe(504);
    });
  });

  describe('ClaudeApiError', () => {
    it('should create Claude API error', () => {
      const originalError = new Error('Original error');
      const error = new ClaudeApiError('Claude service failed', 500, originalError);

      expect(error.message).toBe('Claude service failed');
      expect(error.service).toBe('claude');
      expect(error.code).toBe('CLAUDE_API_ERROR');
      expect(error.apiStatusCode).toBe(500);
      expect(error.originalError).toBe(originalError);
    });

    it('should work without original error', () => {
      const error = new ClaudeApiError('Claude timeout');

      expect(error.originalError).toBeUndefined();
      expect(error.apiStatusCode).toBeUndefined();
    });
  });

  describe('InternalServerError', () => {
    it('should create internal server error with default message', () => {
      const error = new InternalServerError();

      expect(error.message).toBe('Internal server error');
      expect(error.statusCode).toBe(500);
      expect(error.isOperational).toBe(false);
      expect(error.code).toBe('INTERNAL_ERROR');
    });

    it('should create internal server error with custom message', () => {
      const error = new InternalServerError('Database connection failed');

      expect(error.message).toBe('Database connection failed');
    });
  });
});

describe('Error Mapping Utilities', () => {
  describe('mapToAppError', () => {
    it('should return AppError as-is', () => {
      const validationError = new ValidationError('Test error');
      const result = mapToAppError(validationError);

      expect(result).toBe(validationError);
    });

    it('should map network errors to ExternalApiError', () => {
      const networkError = new Error('fetch failed');
      const result = mapToAppError(networkError);

      expect(result.message).toContain('Network error: fetch failed');
      expect(result.code).toBe('EXTERNAL_API_ERROR');
    });

    it('should map rate limit errors to RateLimitError', () => {
      const rateLimitError = new Error('rate limit exceeded');
      const result = mapToAppError(rateLimitError);

      expect(result).toBeInstanceOf(RateLimitError);
      expect(result.code).toBe('RATE_LIMIT_EXCEEDED');
    });

    it('should map 429 errors to RateLimitError', () => {
      const error429 = new Error('HTTP 429 Too Many Requests');
      const result = mapToAppError(error429);

      expect(result).toBeInstanceOf(RateLimitError);
    });

    it('should map unknown Error to InternalServerError', () => {
      const unknownError = new Error('Unknown issue');
      const result = mapToAppError(unknownError);

      expect(result).toBeInstanceOf(InternalServerError);
      expect(result.message).toBe('Unknown issue');
    });

    it('should map non-Error objects to InternalServerError', () => {
      const result = mapToAppError('string error');

      expect(result).toBeInstanceOf(InternalServerError);
      expect(result.message).toBe('Unknown error occurred');
    });

    it('should map null/undefined to InternalServerError', () => {
      const resultNull = mapToAppError(null);
      const resultUndefined = mapToAppError(undefined);

      expect(resultNull).toBeInstanceOf(InternalServerError);
      expect(resultUndefined).toBeInstanceOf(InternalServerError);
    });
  });
});

describe('Error Response Helpers', () => {
  describe('createErrorResponse', () => {
    it('should create standardized error response', () => {
      const error = new ValidationError('Invalid input', 'email');
      const response = createErrorResponse(error);

      expect(response).toEqual({
        success: false,
        error: 'Invalid input',
        code: 'VALIDATION_ERROR',
      });
    });

    it('should work with different error types', () => {
      const authError = new AuthenticationError('Invalid token');
      const response = createErrorResponse(authError);

      expect(response.success).toBe(false);
      expect(response.error).toBe('Invalid token');
      expect(response.code).toBe('UNAUTHORIZED');
    });
  });

  describe('createValidationErrorResponse', () => {
    it('should create validation error response with multiple errors', () => {
      const errors = ['Email is required', 'Age must be positive'];
      const response = createValidationErrorResponse(errors);

      expect(response).toEqual({
        success: false,
        error: 'Validation failed: Email is required, Age must be positive',
        code: 'VALIDATION_ERROR',
      });
    });

    it('should handle single error', () => {
      const errors = ['Name is required'];
      const response = createValidationErrorResponse(errors);

      expect(response.error).toBe('Validation failed: Name is required');
    });

    it('should handle empty error array', () => {
      const errors: string[] = [];
      const response = createValidationErrorResponse(errors);

      expect(response.error).toBe('Validation failed: ');
    });
  });
});