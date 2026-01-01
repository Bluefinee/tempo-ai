import { Hono } from 'hono';
import type { ContentfulStatusCode } from 'hono/utils/http-status';
import type { Bindings } from '../index';
import { AdviceService } from '../services/advice/AdviceService';
import type { AdviceErrorCode } from '../services/advice/types';
import { isOk } from '../utils/result';

const adviceRoutes = new Hono<{ Bindings: Bindings }>();

/**
 * Maps advice error codes to HTTP status codes
 */
const getStatusCode = (errorCode: AdviceErrorCode): ContentfulStatusCode => {
  const statusMap: Record<AdviceErrorCode, ContentfulStatusCode> = {
    INVALID_REQUEST: 400,
    AI_API_ERROR: 502,
    RATE_LIMIT_ERROR: 429,
    NETWORK_ERROR: 503,
    PARSE_ERROR: 500,
  };
  return statusMap[errorCode];
};

/**
 * POST /api/advice
 * AI Daily Insightを生成
 */
adviceRoutes.post('/', async (c) => {
  const apiKey = c.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    return c.json({ success: false, error: 'ANTHROPIC_API_KEY is not configured' }, 500);
  }

  let requestBody: unknown;
  try {
    requestBody = await c.req.json();
  } catch {
    return c.json({ success: false, error: 'Invalid JSON body' }, 400);
  }

  const service = new AdviceService(apiKey);
  const result = await service.generateAdvice(requestBody);

  if (isOk(result)) {
    return c.json({ success: true, data: result.data });
  }

  return c.json({ success: false, error: result.error.message }, getStatusCode(result.error.code));
});

export { adviceRoutes };
