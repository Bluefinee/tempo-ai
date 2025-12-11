// =============================================================================
// Custom Error Classes for Tempo AI Backend
// =============================================================================

/**
 * Base error class for all application errors
 */
export abstract class AppError extends Error {
  abstract readonly statusCode: number;
  abstract readonly isOperational: boolean;
  abstract readonly code?: string;

  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

// =============================================================================
// Client Error Classes (4xx)
// =============================================================================

/**
 * Validation error for request data
 */
export class ValidationError extends AppError {
  readonly statusCode = 400;
  readonly isOperational = true;
  readonly code = 'VALIDATION_ERROR';

  constructor(
    message: string,
    public readonly field?: string,
  ) {
    super(message);
  }
}

/**
 * Authentication error
 */
export class AuthenticationError extends AppError {
  readonly statusCode = 401;
  readonly isOperational = true;
  readonly code = 'UNAUTHORIZED';

  constructor(message = 'Authentication required') {
    super(message);
  }
}

/**
 * Rate limit exceeded error
 */
export class RateLimitError extends AppError {
  readonly statusCode = 429;
  readonly isOperational = true;
  readonly code = 'RATE_LIMIT_EXCEEDED';

  constructor(public readonly retryAfter?: number) {
    super('Rate limit exceeded');
  }
}

// =============================================================================
// Server Error Classes (5xx)
// =============================================================================

/**
 * External API service error
 */
export class ExternalApiError extends AppError {
  readonly statusCode: number = 502;
  readonly isOperational = true;
  readonly code: string = 'EXTERNAL_API_ERROR';

  constructor(
    message: string,
    public readonly service: 'claude' | 'weather' | 'air_quality',
  ) {
    super(message);
  }
}

/**
 * Weather API specific error
 */
export class WeatherApiError extends ExternalApiError {
  override readonly code = 'WEATHER_API_ERROR';
  readonly apiStatusCode?: number | undefined;

  constructor(message: string, apiStatusCode?: number) {
    super(message, 'weather');
    this.apiStatusCode = apiStatusCode;
  }
}

/**
 * Air Quality API specific error
 */
export class AirQualityApiError extends ExternalApiError {
  override readonly code = 'AIR_QUALITY_API_ERROR';
  readonly apiStatusCode?: number | undefined;

  constructor(message: string, apiStatusCode?: number) {
    super(message, 'air_quality');
    this.apiStatusCode = apiStatusCode;
  }
}

/**
 * Internal server error
 */
export class InternalServerError extends AppError {
  readonly statusCode = 500;
  readonly isOperational = false;
  readonly code = 'INTERNAL_ERROR';

  constructor(message = 'Internal server error') {
    super(message);
  }
}

// =============================================================================
// Error Mapping Utilities
// =============================================================================

/**
 * Maps unknown errors to appropriate AppError instances
 */
export const mapToAppError = (error: unknown): AppError => {
  if (error instanceof AppError) {
    return error;
  }

  if (error instanceof Error) {
    // Network or fetch errors
    if (error.message.includes('fetch') || error.message.includes('network')) {
      return new ExternalApiError(`Network error: ${error.message}`, 'claude');
    }

    // Rate limit errors (from external APIs)
    if (error.message.includes('rate limit') || error.message.includes('429')) {
      return new RateLimitError();
    }

    // Default to internal server error for unknown errors
    return new InternalServerError(error.message);
  }

  // For non-Error objects
  return new InternalServerError('Unknown error occurred');
};

// =============================================================================
// Error Response Helpers
// =============================================================================

/**
 * Creates a standardized error response object
 */
export const createErrorResponse = (error: AppError) => {
  return {
    success: false as const,
    error: error.message,
    code: error.code,
  };
};

/**
 * Creates a validation error response with field details
 */
export const createValidationErrorResponse = (errors: string[]) => {
  return {
    success: false as const,
    error: `Validation failed: ${errors.join(', ')}`,
    code: 'VALIDATION_ERROR',
  };
};
