import { Hono } from 'hono';
import type { Context } from 'hono';
import { rateLimit, validateApiKey } from '../middleware/auth.js';
import { validateAdviceRequest, type AdviceRequest } from '../types/request.js';
import { HttpStatus } from '../types/response.js';
import { createValidationErrorResponse } from '../utils/errors.js';
import { createMockAdviceForTimeSlot } from '../utils/mockData.js';

// =============================================================================
// Advice Router Setup
// =============================================================================

interface Bindings {
  ENVIRONMENT: 'development' | 'production' | 'staging';
}

const adviceRouter = new Hono<{ Bindings: Bindings }>();

// Apply authentication and rate limiting to all advice routes
adviceRouter.use('/*', validateApiKey);
adviceRouter.use('/*', rateLimit);

// =============================================================================
// POST /api/advice - Main Advice Generation
// =============================================================================

/**
 * Main advice generation endpoint
 *
 * Phase 7: Returns fixed mock response for development and iOS integration testing
 * Future phases: Will integrate with Claude API for real advice generation
 *
 * @param c - Hono context
 * @returns AdviceResponse with mock daily advice
 */
adviceRouter.post('/', async (c: Context): Promise<Response> => {
  // Get request body
  const requestBody = await c.req.json().catch(() => ({}));

  // Validate request data
  const validation = validateAdviceRequest(requestBody);

  if (!validation.success) {
    const errorResponse = createValidationErrorResponse(validation.errors || []);
    return c.json(errorResponse, HttpStatus.BAD_REQUEST);
  }

  const adviceRequest = validation.data as AdviceRequest;

  // Determine time slot based on current time
  const timeSlot = determineTimeSlot(adviceRequest.context.currentTime);

  // Generate mock advice response
  const mockResponse = createMockAdviceForTimeSlot(adviceRequest.userProfile.nickname, timeSlot);

  // Log successful request (without sensitive data)
  console.log('Advice request processed:', {
    timestamp: new Date().toISOString(),
    nickname: adviceRequest.userProfile.nickname,
    timeSlot,
    interests: adviceRequest.userProfile.interests,
    hasHealthData: !!adviceRequest.healthData.sleep,
    location: adviceRequest.location.city || 'coordinates-only',
  });

  return c.json(mockResponse, HttpStatus.OK);
});

// =============================================================================
// GET /api/advice - Development Info
// =============================================================================

/**
 * Development endpoint to check advice route status
 * Will be removed in production
 */
adviceRouter.get('/', (c: Context): Response => {
  return c.json(
    {
      message: 'Tempo AI Advice API - Phase 7 Implementation',
      status: 'active',
      version: '0.1.0',
      environment: c.env?.ENVIRONMENT || 'development',
      endpoints: {
        advice: 'POST /api/advice - Generate daily advice',
      },
      phase: {
        current: 7,
        description: 'Backend foundation with mock responses',
        next: 'Phase 8 - External API integration',
      },
    },
    HttpStatus.OK,
  );
});

// =============================================================================
// Helper Functions
// =============================================================================

/**
 * Determines the current time slot based on ISO 8601 timestamp
 *
 * @param currentTime - ISO 8601 timestamp
 * @returns Time slot (morning, afternoon, evening)
 */
const determineTimeSlot = (currentTime: string): 'morning' | 'afternoon' | 'evening' => {
  try {
    const date = new Date(currentTime);
    const hour = date.getHours();

    if (hour >= 5 && hour < 12) {
      return 'morning';
    }
    if (hour >= 12 && hour < 18) {
      return 'afternoon';
    }
    return 'evening';
  } catch {
    // Default to morning if timestamp parsing fails
    return 'morning';
  }
};

export { adviceRouter };
