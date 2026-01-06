/**
 * API Client
 */

import { API_BASE_URL, REQUEST_TIMEOUT, DEFAULT_HEADERS } from './config';
import {
  AdviceRequest,
  AdviceResponse,
  WeatherRequest,
  WeatherResponse,
} from './types';

class ApiError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public code?: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

const fetchWithTimeout = async (
  url: string,
  options: RequestInit,
  timeout: number = REQUEST_TIMEOUT
): Promise<Response> => {
  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), timeout);

  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal,
    });
    clearTimeout(id);
    return response;
  } catch (error) {
    clearTimeout(id);
    if (error instanceof Error && error.name === 'AbortError') {
      throw new ApiError('Request timeout', 408, 'TIMEOUT');
    }
    throw error;
  }
};

const handleResponse = async <T>(response: Response): Promise<T> => {
  if (!response.ok) {
    const errorBody = await response.json().catch(() => ({}));
    throw new ApiError(
      errorBody.message || `HTTP error ${response.status}`,
      response.status,
      errorBody.code
    );
  }
  const json = await response.json().catch(() => {
    console.warn('Failed to parse response as JSON');
    return {};
  });
  return json;
};

export const apiClient = {
  /**
   * Generate AI advice
   */
  advice: {
    generate: async (request: AdviceRequest): Promise<AdviceResponse> => {
      const response = await fetchWithTimeout(`${API_BASE_URL}/api/advice`, {
        method: 'POST',
        headers: DEFAULT_HEADERS,
        body: JSON.stringify(request),
      });
      return handleResponse<AdviceResponse>(response);
    },
  },

  /**
   * Get weather data
   */
  weather: {
    get: async (request: WeatherRequest): Promise<WeatherResponse> => {
      const { latitude, longitude } = request;
      const response = await fetchWithTimeout(
        `${API_BASE_URL}/api/weather?lat=${latitude}&lon=${longitude}`,
        {
          method: 'GET',
          headers: DEFAULT_HEADERS,
        }
      );
      return handleResponse<WeatherResponse>(response);
    },
  },

  /**
   * Health check endpoint
   */
  health: {
    check: async (): Promise<{ status: string }> => {
      const response = await fetchWithTimeout(`${API_BASE_URL}/api/health`, {
        method: 'GET',
        headers: DEFAULT_HEADERS,
      });
      return handleResponse<{ status: string }>(response);
    },
  },
};

export { ApiError };
