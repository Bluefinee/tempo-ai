import { z } from 'zod';

/**
 * Health check response schema
 */
export const HealthCheckResponseSchema = z.object({
  status: z.literal('ok'),
  timestamp: z.string(),
  environment: z.enum(['development', 'production', 'staging']),
  service: z.literal('tempo-ai-backend'),
  version: z.string(),
});

/**
 * API info response schema
 */
export const ApiInfoResponseSchema = z.object({
  message: z.literal('Tempo AI Backend API'),
  version: z.string(),
  endpoints: z.record(z.string()),
});

/**
 * Placeholder advice response schema
 */
export const PlaceholderAdviceResponseSchema = z.object({
  message: z.string(),
  status: z.literal('coming_soon'),
});

/**
 * Generic API response wrapper schema
 */
export const ApiResponseSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    success: z.boolean(),
    data: dataSchema.optional(),
    error: z.string().optional(),
  });

// Export type definitions
export type HealthCheckResponse = z.infer<typeof HealthCheckResponseSchema>;
export type ApiInfoResponse = z.infer<typeof ApiInfoResponseSchema>;
export type PlaceholderAdviceResponse = z.infer<typeof PlaceholderAdviceResponseSchema>;
export type ApiResponse<T> = z.infer<ReturnType<typeof ApiResponseSchema<z.ZodType<T>>>>;
