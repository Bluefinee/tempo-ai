import { Hono } from 'hono';
import { describe, expect, it } from 'vitest';
import { ApiError, errorHandler } from './errorHandler';

interface ErrorResponse {
  success: boolean;
  error: string;
}

describe('errorHandler middleware', () => {
  it('should catch and format generic errors', async () => {
    const app = new Hono();
    app.onError(errorHandler);
    app.get('/error', () => {
      throw new Error('Test error');
    });

    const res = await app.request('/error');

    expect(res.status).toBe(500);

    const json = (await res.json()) as ErrorResponse;
    expect(json.success).toBe(false);
    expect(json.error).toBe('Internal server error');
  });

  it('should handle ApiError with custom status code', async () => {
    const app = new Hono();
    app.onError(errorHandler);
    app.get('/not-found', () => {
      throw new ApiError('Resource not found', 404);
    });

    const res = await app.request('/not-found');

    expect(res.status).toBe(404);

    const json = (await res.json()) as ErrorResponse;
    expect(json.success).toBe(false);
    expect(json.error).toBe('Resource not found');
  });

  it('should handle ApiError with 400 status', async () => {
    const app = new Hono();
    app.onError(errorHandler);
    app.get('/bad-request', () => {
      throw new ApiError('Invalid request', 400);
    });

    const res = await app.request('/bad-request');

    expect(res.status).toBe(400);

    const json = (await res.json()) as ErrorResponse;
    expect(json.error).toBe('Invalid request');
  });

  it('should return JSON content type', async () => {
    const app = new Hono();
    app.onError(errorHandler);
    app.get('/error', () => {
      throw new Error('Test error');
    });

    const res = await app.request('/error');

    expect(res.headers.get('content-type')).toContain('application/json');
  });
});

describe('ApiError', () => {
  it('should create error with message and status code', () => {
    const error = new ApiError('Not found', 404);

    expect(error.message).toBe('Not found');
    expect(error.statusCode).toBe(404);
    expect(error.name).toBe('ApiError');
  });

  it('should default to 500 status code', () => {
    const error = new ApiError('Server error');

    expect(error.statusCode).toBe(500);
  });

  it('should be an instance of Error', () => {
    const error = new ApiError('Test');

    expect(error).toBeInstanceOf(Error);
  });
});
