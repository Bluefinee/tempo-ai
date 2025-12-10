import { z } from 'zod';
import { AdditionalAdviceSchema, DailyAdviceSchema } from './domain.js';

// =============================================================================
// Health Check Response
// =============================================================================

export const HealthCheckResponseSchema = z.object({
  status: z.literal('ok'),
  timestamp: z.string(),
  environment: z.enum(['development', 'production', 'staging']),
  service: z.literal('tempo-ai-backend'),
  version: z.string(),
});

export type HealthCheckResponse = z.infer<typeof HealthCheckResponseSchema>;

// =============================================================================
// API Info Response
// =============================================================================

export const ApiInfoResponseSchema = z.object({
  message: z.literal('Tempo AI Backend API'),
  version: z.string(),
  endpoints: z.record(z.string()),
});

export type ApiInfoResponse = z.infer<typeof ApiInfoResponseSchema>;

// Placeholder response removed - replaced with full API implementation

// =============================================================================
// Generic API Response Wrapper
// =============================================================================

/**
 * Generic schema factory for API responses
 * Provides consistent response structure across all endpoints
 */
export const ApiResponseSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    success: z.boolean(),
    data: dataSchema.optional(),
    error: z.string().optional(),
    code: z.string().optional(),
  });

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  code?: string;
}

// =============================================================================
// Advice Response Types
// =============================================================================

export const AdviceResponseDataSchema = z.object({
  mainAdvice: DailyAdviceSchema,
  additionalAdvice: AdditionalAdviceSchema.optional(),
});

export type AdviceResponseData = z.infer<typeof AdviceResponseDataSchema>;

// Using generic ApiResponseSchema to avoid duplication
export const AdviceResponseSchema = ApiResponseSchema(AdviceResponseDataSchema);
export type AdviceResponse = z.infer<typeof AdviceResponseSchema>;

// =============================================================================
// Additional Advice Response
// =============================================================================

// Using generic ApiResponseSchema to avoid duplication
export const AdditionalAdviceResponseSchema = ApiResponseSchema(AdditionalAdviceSchema);
export type AdditionalAdviceResponse = z.infer<typeof AdditionalAdviceResponseSchema>;

// =============================================================================
// Error Response Types
// =============================================================================

export const ErrorResponseSchema = z.object({
  success: z.literal(false),
  error: z.string(),
  code: z.string().optional(),
});

export type ErrorResponse = z.infer<typeof ErrorResponseSchema>;

// =============================================================================
// HTTP Status Code Constants
// =============================================================================

export const HttpStatus = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500,
  BAD_GATEWAY: 502,
  SERVICE_UNAVAILABLE: 503,
} as const;

export type HttpStatusCode = (typeof HttpStatus)[keyof typeof HttpStatus];
