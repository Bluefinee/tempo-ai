/**
 * API Configuration
 */

// API Base URL - use environment variable or default to local dev server
export const API_BASE_URL: string =
  process.env.EXPO_PUBLIC_API_URL || 'http://localhost:8787';

if (__DEV__ && API_BASE_URL === 'http://localhost:8787') {
  console.warn('Using default API URL. Set EXPO_PUBLIC_API_URL environment variable for production.');
}

// Request timeout in milliseconds
export const REQUEST_TIMEOUT = 30000;

// Common headers for all requests
export const DEFAULT_HEADERS = {
  'Content-Type': 'application/json',
  Accept: 'application/json',
} as const;
