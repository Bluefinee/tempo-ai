import { z } from 'zod';

// Request schema for weather API
export const WeatherRequestSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
});

export type WeatherRequest = z.infer<typeof WeatherRequestSchema>;

// Open-Meteo Weather API response
export interface OpenMeteoWeatherResponse {
  current: {
    temperature_2m: number;
    relative_humidity_2m: number;
    pressure_msl: number;
    weather_code: number;
  };
  daily: {
    uv_index_max: number[];
    sunrise: string[];
    sunset: string[];
  };
}

// Open-Meteo Air Quality API response
export interface OpenMeteoAirQualityResponse {
  current: {
    pm2_5: number;
    us_aqi: number;
  };
}

// Unified weather data for the app
export interface WeatherData {
  /** Temperature in Celsius */
  temperature: number;
  /** Humidity percentage */
  humidity: number;
  /** Pressure in hPa */
  pressure: number;
  /** WMO Weather Code */
  weatherCode: number;
  /** Maximum UV index for the day */
  uvIndexMax: number;
  /** Sunrise time in ISO8601 format */
  sunrise: string;
  /** Sunset time in ISO8601 format */
  sunset: string;
  /** Air quality data */
  airQuality: {
    /** PM2.5 concentration */
    pm25: number;
    /** US Air Quality Index */
    aqi: number;
  };
}

// Error types for weather service
export type WeatherErrorCode =
  | 'INVALID_COORDINATES'
  | 'API_ERROR'
  | 'NETWORK_ERROR'
  | 'PARSE_ERROR';

export interface WeatherError {
  code: WeatherErrorCode;
  message: string;
  details?: unknown;
}
