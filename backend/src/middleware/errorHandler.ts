import type { ErrorHandler } from 'hono';
import type { ContentfulStatusCode } from 'hono/utils/http-status';

/**
 * Custom API error class with HTTP status code
 */
export class ApiError extends Error {
  constructor(
    message: string,
    public readonly statusCode: ContentfulStatusCode = 500,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

/**
 * Global error handler middleware for Hono
 * Catches all unhandled errors and returns a consistent JSON response
 */
export const errorHandler: ErrorHandler = (err, c) => {
  // Log error details (in production, you might want to use a proper logger)
  console.error('[Error]', {
    message: err.message,
    name: err.name,
    // Only log stack trace in development
    stack: c.env?.ENVIRONMENT === 'development' || !c.env?.ENVIRONMENT ? err.stack : undefined,
  });

  // Handle custom ApiError
  if (err instanceof ApiError) {
    return c.json({ success: false, error: err.message }, err.statusCode);
  }

  // Handle all other errors as 500
  return c.json({ success: false, error: 'Internal server error' }, 500);
};
