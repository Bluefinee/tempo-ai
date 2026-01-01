import { Hono } from 'hono';
import type { Bindings } from '../index';

interface HealthResponse {
  status: 'ok';
  timestamp: string;
  version: string;
}

const healthRoutes = new Hono<{ Bindings: Bindings }>();

healthRoutes.get('/', (c) => {
  const response: HealthResponse = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: '0.1.0',
  };

  return c.json({ success: true, data: response });
});

export { healthRoutes };
