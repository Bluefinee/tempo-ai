import { Hono } from 'hono';
import { cors } from 'hono/cors';

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
 * Provides health monitoring endpoints and placeholder routes for future
 * AI-powered health advice generation functionality.
 */
const app = new Hono<{ Bindings: Bindings }>();

// CORS middleware configuration
app.use(
  '*',
  cors({
    origin: ['http://localhost:3000', 'https://localhost:3000'],
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization', 'X-API-Key'],
  }),
);

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
    endpoints: {
      health: '/health',
      advice: '/api/advice (coming soon)',
    },
  });
});

/**
 * API routes placeholder for future development
 *
 * Currently returns placeholder responses for endpoints that will be
 * implemented in future phases of the Tempo AI development.
 */
app.route(
  '/api',
  new Hono().get('/advice', (c) => {
    return c.json({
      message: 'Advice endpoint not implemented yet',
      status: 'coming_soon' as const,
    });
  }),
);

export default app;
