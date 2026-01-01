import type { MiddlewareHandler } from 'hono';

interface LogEntry {
  method: string;
  path: string;
  status: number;
  durationMs: number;
}

/**
 * Request logger middleware for Hono
 * Logs request method, path, response status, and duration
 */
export const logger = (): MiddlewareHandler => {
  return async (c, next) => {
    const start = Date.now();

    await next();

    const duration = Date.now() - start;
    const entry: LogEntry = {
      method: c.req.method,
      path: c.req.path,
      status: c.res.status,
      durationMs: duration,
    };

    console.log(JSON.stringify(entry));
  };
};
