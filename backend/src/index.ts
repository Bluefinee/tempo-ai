import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { errorHandler } from './middleware/errorHandler';
import { logger } from './middleware/logger';
import { adviceRoutes } from './routes/advice';
import { healthRoutes } from './routes/health';
import { weatherRoutes } from './routes/weather';

export interface Bindings {
  ENVIRONMENT: 'development' | 'staging' | 'production';
  ANTHROPIC_API_KEY: string;
}

const app = new Hono<{ Bindings: Bindings }>();

// Middleware
app.use('/*', cors());
app.use('/*', logger());

// Error handler
app.onError(errorHandler);

// Routes
app.route('/api/advice', adviceRoutes);
app.route('/api/health', healthRoutes);
app.route('/api/weather', weatherRoutes);

export default app;
