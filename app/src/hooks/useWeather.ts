/**
 * 天気情報取得フック
 */

import { useCallback, useState } from "react";
import * as Location from "expo-location";
import { apiClient } from "../api/client";
import type { WeatherResponse } from "../api/types";

interface UseWeatherReturn {
  isLoading: boolean;
  error: string | null;
  weather: WeatherResponse | null;
  fetchWeather: () => Promise<WeatherResponse | null>;
}

/**
 * 天気情報取得フック
 */
export const useWeather = (): UseWeatherReturn => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [weather, setWeather] = useState<WeatherResponse | null>(null);

  const fetchWeather =
    useCallback(async (): Promise<WeatherResponse | null> => {
      setIsLoading(true);
      setError(null);

      try {
        // 位置情報の取得
        const { status } = await Location.requestForegroundPermissionsAsync();
        if (status !== "granted") {
          throw new Error("Location permission not granted");
        }

        const location = await Location.getCurrentPositionAsync({});
        const { latitude, longitude } = location.coords;

        const response = await apiClient.getWeather(latitude, longitude);

        if (response.success) {
          setWeather(response.data);
          return response.data;
        } else {
          setError(response.error.message ?? "Failed to fetch weather");
          return null;
        }
      } catch (err) {
        const message = err instanceof Error ? err.message : "Unknown error";
        setError(message);
        return null;
      } finally {
        setIsLoading(false);
      }
    }, []);

  return {
    isLoading,
    error,
    weather,
    fetchWeather,
  };
};
