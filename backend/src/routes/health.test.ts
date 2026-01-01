import { describe, expect, it } from 'vitest';
import app from '../index';

describe('GET /api/health', () => {
  it('should return 200 with status ok', async () => {
    const res = await app.request('/api/health');

    expect(res.status).toBe(200);

    const json = await res.json();
    expect(json).toEqual({
      success: true,
      data: {
        status: 'ok',
        timestamp: expect.any(String),
        version: '0.1.0',
      },
    });
  });

  it('should return ISO8601 timestamp', async () => {
    const res = await app.request('/api/health');
    const json = (await res.json()) as {
      success: boolean;
      data: { timestamp: string };
    };

    // Verify timestamp is valid ISO8601
    const date = new Date(json.data.timestamp);
    expect(date.toISOString()).toBe(json.data.timestamp);
  });

  it('should have correct content-type header', async () => {
    const res = await app.request('/api/health');

    expect(res.headers.get('content-type')).toContain('application/json');
  });
});
