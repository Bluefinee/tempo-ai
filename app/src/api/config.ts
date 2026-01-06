/**
 * API Configuration
 */

// API Base URL - use environment variable or default to local dev server
export const API_BASE_URL =
  process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000';

// Request timeout in milliseconds
export const REQUEST_TIMEOUT = 30000;

// Common headers for all requests
export const DEFAULT_HEADERS = {
  'Content-Type': 'application/json',
  Accept: 'application/json',
};
