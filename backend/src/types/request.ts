import { z } from 'zod';
import {
  HealthDataSchema,
  LocationDataSchema,
  RequestContextSchema,
  UserProfileSchema,
} from './domain.js';

// =============================================================================
// Main Advice Request
// =============================================================================

export const AdviceRequestSchema = z.object({
  userProfile: UserProfileSchema,
  healthData: HealthDataSchema,
  location: LocationDataSchema,
  context: RequestContextSchema,
});

export type AdviceRequest = z.infer<typeof AdviceRequestSchema>;

// =============================================================================
// Request Validation Helpers
// =============================================================================

export const isValidAdviceRequest = (data: unknown): data is AdviceRequest => {
  const result = AdviceRequestSchema.safeParse(data);
  return result.success;
};

// =============================================================================
// Request Validation with Error Details
// =============================================================================

export interface ValidationResult<T> {
  success: boolean;
  data?: T;
  errors?: string[];
}

/**
 * Validates advice request data with detailed error reporting
 *
 * Performs comprehensive validation of request structure and data types
 * using Zod schema validation. Returns structured validation result
 * with either successfully parsed data or detailed error messages.
 *
 * @param data - Unknown input data to validate as AdviceRequest
 * @returns ValidationResult with parsed data or validation errors
 * @example
 * const result = validateAdviceRequest(requestBody);
 * if (result.success) {
 *   const advice = await generateAdvice(result.data);
 * } else {
 *   console.error('Validation errors:', result.errors);
 * }
 */
export const validateAdviceRequest = (data: unknown): ValidationResult<AdviceRequest> => {
  const result = AdviceRequestSchema.safeParse(data);

  if (result.success) {
    return {
      success: true,
      data: result.data,
    };
  }

  return {
    success: false,
    errors: result.error.issues.map((issue) => `${issue.path.join('.')}: ${issue.message}`),
  };
};
