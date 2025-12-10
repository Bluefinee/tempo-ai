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
// Additional Advice Request
// =============================================================================

export const AdditionalAdviceRequestSchema = z.object({
  userProfile: UserProfileSchema.pick({
    nickname: true,
    interests: true,
  }),
  timeSlot: z.enum(['afternoon', 'evening']),
  morningData: z.object({
    hrvMs: z.number().positive().optional(),
    restingHeartRate: z.number().int().positive().optional(),
  }),
  currentData: z.object({
    stepsSoFar: z.number().int().nonnegative(),
    avgHeartRateSinceMorning: z.number().int().positive().optional(),
  }),
});

export type AdditionalAdviceRequest = z.infer<typeof AdditionalAdviceRequestSchema>;

// =============================================================================
// Request Validation Helpers
// =============================================================================

export const isValidAdviceRequest = (data: unknown): data is AdviceRequest => {
  const result = AdviceRequestSchema.safeParse(data);
  return result.success;
};

export const isValidAdditionalAdviceRequest = (data: unknown): data is AdditionalAdviceRequest => {
  const result = AdditionalAdviceRequestSchema.safeParse(data);
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

export const validateAdditionalAdviceRequest = (
  data: unknown,
): ValidationResult<AdditionalAdviceRequest> => {
  const result = AdditionalAdviceRequestSchema.safeParse(data);

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
