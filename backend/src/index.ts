import { Hono } from 'hono';
import { cors } from 'hono/cors';
// import { notFoundHandler } from './middleware/errorHandler.js';
import { adviceRouter } from './routes/advice.js';

/**
 * Cloudflare Workers environment bindings for Tempo AI backend
 */
interface Bindings {
  /** Deployment environment */
  ENVIRONMENT: 'development' | 'production' | 'staging';
}

/**
 * Main Hono application instance for Tempo AI backend API
 *
 * Phase 7 Implementation:
 * - Health monitoring endpoints
 * - POST /api/advice endpoint with mock responses
 * - API authentication with simple API key
 * - Error handling and rate limiting
 * - Type-safe request/response handling
 */
const app = new Hono<{ Bindings: Bindings }>();

// =============================================================================
// Global Middleware
// =============================================================================

// Error handling with Hono's built-in onError hook
app.onError((err, c) => {
  console.error('API Error:', {
    timestamp: new Date().toISOString(),
    path: c.req.path,
    method: c.req.method,
    error: err.message,
  });
  
  return c.json({
    success: false,
    error: err.message || 'Internal server error',
    code: 'INTERNAL_ERROR',
  }, 500);
});

// CORS middleware configuration
app.use(
  '*',
  cors({
    origin: (origin, _c) => {
      if (!origin) return origin || null; // Allow same-origin requests

      const allowedOrigins = ['http://localhost:3000', 'https://localhost:3000'];

      // Check exact matches
      if (allowedOrigins.includes(origin)) return origin;

      // Check iOS simulator local IP patterns
      const localPatterns = [
        /^http:\/\/192\.168\.\d+\.\d+:\d+$/,
        /^http:\/\/10\.\d+\.\d+\.\d+:\d+$/,
        /^http:\/\/172\.\d+\.\d+\.\d+:\d+$/,
      ];

      const isAllowed = localPatterns.some((pattern) => pattern.test(origin));
      return isAllowed ? origin : null;
    },
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization', 'X-API-Key'],
  }),
);

// =============================================================================
// Health & Info Endpoints (No Authentication Required)
// =============================================================================

/**
 * Health check endpoint for monitoring service availability
 *
 * @returns JSON response with service status, environment info, and timestamp
 */
app.get('/health', (c) => {
  return c.json({
    status: 'ok' as const,
    timestamp: new Date().toISOString(),
    environment: c.env?.ENVIRONMENT || 'development',
    service: 'tempo-ai-backend' as const,
    version: '0.1.0',
    phase: 7,
  });
});

/**
 * Root API information endpoint
 *
 * @returns JSON response with API version and available endpoints
 */
app.get('/', (c) => {
  return c.json({
    message: 'Tempo AI Backend API' as const,
    version: '0.1.0',
    phase: 7,
    description: 'Backend foundation with mock advice generation',
    endpoints: {
      health: '/health - Service health check',
      advice: '/api/advice - Daily advice generation (POST)',
      adviceInfo: '/api/advice - Endpoint information (GET)',
    },
    authentication: {
      required: true,
      method: 'API Key',
      header: 'X-API-Key',
    },
  });
});

// =============================================================================
// API Routes (Authentication Required)
// =============================================================================

/**
 * Advice generation routes
 *
 * Includes:
 * - POST /api/advice - Main advice generation with mock responses
 * - GET /api/advice - Development endpoint information
 */
app.route('/api/advice', adviceRouter);

// =============================================================================
// 404 Handler
// =============================================================================

app.notFound((c) => {
  return c.json({
    success: false,
    error: 'Endpoint not found',
    code: 'NOT_FOUND',
  }, 404);
});

export default app;
