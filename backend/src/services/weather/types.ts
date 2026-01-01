import { z } from 'zod';

// Request schema for weather API
export const WeatherRequestSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
});

export type WeatherRequest = z.infer<typeof WeatherRequestSchema>;

// Open-Meteo Weather API response schema
export const OpenMeteoWeatherResponseSchema = z.object({
  current: z.object({
    temperature_2m: z.number(),
    relative_humidity_2m: z.number(),
    pressure_msl: z.number(),
    weather_code: z.number(),
  }),
  daily: z.object({
    uv_index_max: z.array(z.number()),
    sunrise: z.array(z.string()),
    sunset: z.array(z.string()),
  }),
});

export type OpenMeteoWeatherResponse = z.infer<typeof OpenMeteoWeatherResponseSchema>;

// Open-Meteo Air Quality API response schema
export const OpenMeteoAirQualityResponseSchema = z.object({
  current: z.object({
    pm2_5: z.number(),
    us_aqi: z.number(),
  }),
});

export type OpenMeteoAirQualityResponse = z.infer<typeof OpenMeteoAirQualityResponseSchema>;

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
