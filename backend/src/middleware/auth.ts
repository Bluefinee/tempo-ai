import type { Context, Next } from 'hono';
import { AuthenticationError, RateLimitError } from '../utils/errors.js';

// =============================================================================
// API Key Authentication Configuration
// =============================================================================

/**
 * API key header name
 */
const API_KEY_HEADER = 'X-API-Key';

/**
 * API key configuration with environment variable support
 *
 * ⚠️ セキュリティ警告:
 * - 本番環境では必ず環境変数 TEMPO_API_KEY を設定してください
 * - モバイルアプリに埋め込んだキーはリバースエンジニアリングで必ず漏洩します
 * - 本番運用ではOAuth/OIDC等のユーザー認証や署名付きリクエストに移行が必要です
 * - 現在のキーは識別子・レート制限・ロギング用途のみに使用してください
 */
const getValidApiKey = (environment?: string): string => {
  const envApiKey = process.env.TEMPO_API_KEY;

  // Production requires environment variable
  if (environment === 'production' && !envApiKey) {
    throw new Error(
      'TEMPO_API_KEY environment variable is required in production. ' +
        'Please set a secure API key in your environment variables.',
    );
  }

  // Use environment variable if available, otherwise fall back to development key
  return envApiKey || 'tempo-ai-mobile-app-key-v1';
};

// =============================================================================
// Authentication Middleware
// =============================================================================

/**
 * Validates API key authentication with environment-aware key management
 *
 * @param c - Hono context with environment bindings
 * @param next - Next middleware function
 * @throws {AuthenticationError} When API key is invalid or missing
 * @throws {Error} When production environment lacks required API key configuration
 */
export const validateApiKey = async (
  c: Context<{ Bindings: { ENVIRONMENT?: string } }>,
  next: Next,
): Promise<void> => {
  const apiKey = c.req.header(API_KEY_HEADER);
  const environment = c.env?.ENVIRONMENT;

  // Check if API key is provided
  if (!apiKey) {
    const error = new AuthenticationError('API key is required');
    throw error;
  }

  // Get valid API key based on environment
  let validApiKey: string;
  try {
    validApiKey = getValidApiKey(environment);
  } catch (configError) {
    // Production configuration error
    console.error('API key configuration error:', configError);
    const error = new AuthenticationError('Server configuration error');
    throw error;
  }

  // Validate API key
  if (apiKey !== validApiKey) {
    const error = new AuthenticationError('Invalid API key');
    throw error;
  }

  // Log successful authentication (without exposing key)
  console.log('API key validated:', {
    timestamp: new Date().toISOString(),
    environment: environment || 'development',
    keySource: process.env.TEMPO_API_KEY ? 'environment' : 'default',
  });

  // API key is valid, proceed to next middleware
  await next();
};

// =============================================================================
// Rate Limiting
// =============================================================================

/**
 * Simple in-memory rate limiter
 * Note: In production, use external rate limiting service (Redis, etc.)
 */
const rateLimiter = new Map<string, number[]>();

/**
 * Rate limiting configuration
 */
const RATE_LIMIT_CONFIG = {
  windowMs: 60 * 1000, // 1 minute window
  maxRequests: 10, // Maximum 10 requests per minute per client
  keyTTL: 60 * 60 * 1000, // Keep keys for 1 hour
};

/**
 * Rate limiting middleware
 *
 * @param c - Hono context
 * @param next - Next middleware function
 */
export const rateLimit = async (c: Context, next: Next): Promise<void> => {
  const clientKey = c.req.header(API_KEY_HEADER) || 'anonymous';
  const now = Date.now();

  // Get existing timestamps for this client
  const timestamps = rateLimiter.get(clientKey) || [];

  // Remove expired timestamps
  const validTimestamps = timestamps.filter(
    (timestamp) => now - timestamp < RATE_LIMIT_CONFIG.windowMs,
  );

  // Check if rate limit exceeded
  if (validTimestamps.length >= RATE_LIMIT_CONFIG.maxRequests) {
    const error = new RateLimitError(Math.ceil(RATE_LIMIT_CONFIG.windowMs / 1000));
    throw error;
  }

  // Add current timestamp
  validTimestamps.push(now);
  rateLimiter.set(clientKey, validTimestamps);

  // Clean up old entries periodically
  if (Math.random() < 0.01) {
    // 1% chance to cleanup
    cleanupRateLimiter();
  }

  await next();
};

/**
 * Cleanup expired rate limiter entries
 */
const cleanupRateLimiter = (): void => {
  const now = Date.now();
  const expiredKeys: string[] = [];

  for (const [key, timestamps] of rateLimiter.entries()) {
    const validTimestamps = timestamps.filter(
      (timestamp) => now - timestamp < RATE_LIMIT_CONFIG.keyTTL,
    );

    if (validTimestamps.length === 0) {
      expiredKeys.push(key);
    } else {
      rateLimiter.set(key, validTimestamps);
    }
  }

  // Remove expired keys
  for (const key of expiredKeys) {
    rateLimiter.delete(key);
  }
};
