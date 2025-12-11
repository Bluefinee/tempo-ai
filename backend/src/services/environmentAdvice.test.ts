import { describe, it, expect } from 'vitest';
import { generateEnvironmentAdvice } from './environmentAdvice.js';
import type { WeatherData, AirQualityData } from '../types/domain.js';

describe('Environment Advice Service', () => {
  const mockWeatherData: WeatherData = {
    condition: '晴れ',
    tempCurrentC: 20,
    tempMaxC: 25,
    tempMinC: 15,
    humidityPercent: 50,
    uvIndex: 5,
    pressureHpa: 1013,
    precipitationProbability: 10,
  };

  const mockAirQualityData: AirQualityData = {
    aqi: 45,
    pm25: 12,
    pm10: 25,
  };

  describe('generateEnvironmentAdvice', () => {
    it('should return maximum 3 advice items', () => {
      const advice = generateEnvironmentAdvice(
        {
          ...mockWeatherData,
          tempCurrentC: 5, // Trigger temperature advice
          uvIndex: 7, // Trigger UV advice
          humidityPercent: 25, // Trigger humidity advice
        },
        mockAirQualityData,
        'falling' // Trigger pressure advice
      );

      expect(advice.length).toBeLessThanOrEqual(3);
      expect(advice.length).toBeGreaterThan(0);
    });

    it('should always include air quality advice as first item', () => {
      const advice = generateEnvironmentAdvice(mockWeatherData, mockAirQualityData, 'stable');

      expect(advice[0]?.type).toBe('air_quality');
    });

    it('should prioritize advice correctly (air_quality > temperature > uv > pressure > humidity)', () => {
      const advice = generateEnvironmentAdvice(
        {
          ...mockWeatherData,
          tempCurrentC: 5, // Priority 2
          uvIndex: 7, // Priority 3
          humidityPercent: 25, // Priority 5
        },
        mockAirQualityData, // Priority 1
        'falling' // Priority 4
      );

      expect(advice.length).toBe(3);
      expect(advice[0]?.type).toBe('air_quality');
      expect(advice[1]?.type).toBe('temperature');
      expect(advice[2]?.type).toBe('uv');
    });

    it('should handle case with only air quality advice', () => {
      // Use weather data with no triggering conditions (uvIndex < 3, 10 <= temp <= 30, 30 <= humidity <= 80)
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, uvIndex: 2, tempCurrentC: 20, humidityPercent: 50 },
        mockAirQualityData,
        'stable'
      );

      expect(advice.length).toBe(1);
      expect(advice[0]?.type).toBe('air_quality');
    });
  });

  describe('Air Quality Advice', () => {
    it('should return "良好" advice when AQI <= 50', () => {
      const advice = generateEnvironmentAdvice(
        mockWeatherData,
        { aqi: 45, pm25: 12, pm10: 25 },
        'stable'
      );

      expect(advice[0]?.type).toBe('air_quality');
      expect(advice[0]?.message).toContain('良好');
      expect(advice[0]?.message).toContain('屋外運動に適しています');
    });

    it('should return "普通" advice when AQI <= 100', () => {
      const advice = generateEnvironmentAdvice(
        mockWeatherData,
        { aqi: 75, pm25: 25, pm10: 50 },
        'stable'
      );

      expect(advice[0]?.type).toBe('air_quality');
      expect(advice[0]?.message).toContain('普通');
      expect(advice[0]?.message).toContain('敏感な方は');
    });

    it('should return "悪化" advice when AQI > 100', () => {
      const advice = generateEnvironmentAdvice(
        mockWeatherData,
        { aqi: 150, pm25: 60, pm10: 120 },
        'stable'
      );

      expect(advice[0]?.type).toBe('air_quality');
      expect(advice[0]?.message).toContain('悪化');
      expect(advice[0]?.message).toContain('激しい運動は避けましょう');
    });

    it('should handle boundary value AQI = 50', () => {
      const advice = generateEnvironmentAdvice(
        mockWeatherData,
        { aqi: 50, pm25: 15, pm10: 30 },
        'stable'
      );

      expect(advice[0]?.type).toBe('air_quality');
      expect(advice[0]?.message).toContain('良好');
    });

    it('should handle boundary value AQI = 100', () => {
      const advice = generateEnvironmentAdvice(
        mockWeatherData,
        { aqi: 100, pm25: 35, pm10: 70 },
        'stable'
      );

      expect(advice[0]?.type).toBe('air_quality');
      expect(advice[0]?.message).toContain('普通');
    });
  });

  describe('Temperature Advice', () => {
    it('should return advice when temp < 10°C', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, tempCurrentC: 5 },
        mockAirQualityData,
        'stable'
      );

      const tempAdvice = advice.find((a) => a.type === 'temperature');
      expect(tempAdvice).toBeDefined();
      expect(tempAdvice?.message).toContain('気温が低めです');
      expect(tempAdvice?.message).toContain('暖かい服装');
    });

    it('should return advice when temp > 30°C', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, tempCurrentC: 35 },
        mockAirQualityData,
        'stable'
      );

      const tempAdvice = advice.find((a) => a.type === 'temperature');
      expect(tempAdvice).toBeDefined();
      expect(tempAdvice?.message).toContain('気温が高めです');
      expect(tempAdvice?.message).toContain('水分補給');
    });

    it('should not return advice when temp is between 10°C and 30°C', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, tempCurrentC: 20 },
        mockAirQualityData,
        'stable'
      );

      const tempAdvice = advice.find((a) => a.type === 'temperature');
      expect(tempAdvice).toBeUndefined();
    });

    it('should handle boundary value temp = 10°C', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, tempCurrentC: 10 },
        mockAirQualityData,
        'stable'
      );

      const tempAdvice = advice.find((a) => a.type === 'temperature');
      expect(tempAdvice).toBeUndefined();
    });

    it('should handle boundary value temp = 30°C', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, tempCurrentC: 30 },
        mockAirQualityData,
        'stable'
      );

      const tempAdvice = advice.find((a) => a.type === 'temperature');
      expect(tempAdvice).toBeUndefined();
    });

    it('should handle boundary value temp = 9.99°C', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, tempCurrentC: 9.99 },
        mockAirQualityData,
        'stable'
      );

      const tempAdvice = advice.find((a) => a.type === 'temperature');
      expect(tempAdvice).toBeDefined();
    });

    it('should handle boundary value temp = 30.01°C', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, tempCurrentC: 30.01 },
        mockAirQualityData,
        'stable'
      );

      const tempAdvice = advice.find((a) => a.type === 'temperature');
      expect(tempAdvice).toBeDefined();
    });
  });

  describe('UV Advice', () => {
    it('should return high UV advice when uvIndex >= 6', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, uvIndex: 7 },
        mockAirQualityData,
        'stable'
      );

      const uvAdvice = advice.find((a) => a.type === 'uv');
      expect(uvAdvice).toBeDefined();
      expect(uvAdvice?.message).toContain('高めです');
      expect(uvAdvice?.message).toContain('日焼け止め');
      expect(uvAdvice?.message).toContain('帽子');
    });

    it('should return moderate UV advice when uvIndex >= 3', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, uvIndex: 4 },
        mockAirQualityData,
        'stable'
      );

      const uvAdvice = advice.find((a) => a.type === 'uv');
      expect(uvAdvice).toBeDefined();
      expect(uvAdvice?.message).toContain('中程度');
    });

    it('should not return advice when uvIndex < 3', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, uvIndex: 2 },
        mockAirQualityData,
        'stable'
      );

      const uvAdvice = advice.find((a) => a.type === 'uv');
      expect(uvAdvice).toBeUndefined();
    });

    it('should handle boundary value uvIndex = 3', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, uvIndex: 3 },
        mockAirQualityData,
        'stable'
      );

      const uvAdvice = advice.find((a) => a.type === 'uv');
      expect(uvAdvice).toBeDefined();
      expect(uvAdvice?.message).toContain('中程度');
    });

    it('should handle boundary value uvIndex = 6', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, uvIndex: 6 },
        mockAirQualityData,
        'stable'
      );

      const uvAdvice = advice.find((a) => a.type === 'uv');
      expect(uvAdvice).toBeDefined();
      expect(uvAdvice?.message).toContain('高めです');
    });
  });

  describe('Pressure Advice', () => {
    it('should return advice when pressure trend is falling', () => {
      const advice = generateEnvironmentAdvice(mockWeatherData, mockAirQualityData, 'falling');

      const pressureAdvice = advice.find((a) => a.type === 'pressure');
      expect(pressureAdvice).toBeDefined();
      expect(pressureAdvice?.message).toContain('気圧が下降中です');
      expect(pressureAdvice?.message).toContain('頭痛');
    });

    it('should not return advice when pressure trend is rising', () => {
      const advice = generateEnvironmentAdvice(mockWeatherData, mockAirQualityData, 'rising');

      const pressureAdvice = advice.find((a) => a.type === 'pressure');
      expect(pressureAdvice).toBeUndefined();
    });

    it('should not return advice when pressure trend is stable', () => {
      const advice = generateEnvironmentAdvice(mockWeatherData, mockAirQualityData, 'stable');

      const pressureAdvice = advice.find((a) => a.type === 'pressure');
      expect(pressureAdvice).toBeUndefined();
    });
  });

  describe('Humidity Advice', () => {
    it('should return dry advice when humidity < 30%', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, humidityPercent: 25 },
        mockAirQualityData,
        'stable'
      );

      const humidityAdvice = advice.find((a) => a.type === 'humidity');
      expect(humidityAdvice).toBeDefined();
      expect(humidityAdvice?.message).toContain('乾燥');
      expect(humidityAdvice?.message).toContain('保湿');
    });

    it('should return humid advice when humidity > 80%', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, humidityPercent: 85 },
        mockAirQualityData,
        'stable'
      );

      const humidityAdvice = advice.find((a) => a.type === 'humidity');
      expect(humidityAdvice).toBeDefined();
      expect(humidityAdvice?.message).toContain('湿度が高めです');
      expect(humidityAdvice?.message).toContain('熱中症');
    });

    it('should not return advice when humidity is between 30% and 80%', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, humidityPercent: 50 },
        mockAirQualityData,
        'stable'
      );

      const humidityAdvice = advice.find((a) => a.type === 'humidity');
      expect(humidityAdvice).toBeUndefined();
    });

    it('should handle boundary value humidity = 30%', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, humidityPercent: 30 },
        mockAirQualityData,
        'stable'
      );

      const humidityAdvice = advice.find((a) => a.type === 'humidity');
      expect(humidityAdvice).toBeUndefined();
    });

    it('should handle boundary value humidity = 80%', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, humidityPercent: 80 },
        mockAirQualityData,
        'stable'
      );

      const humidityAdvice = advice.find((a) => a.type === 'humidity');
      expect(humidityAdvice).toBeUndefined();
    });

    it('should handle boundary value humidity = 29.99%', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, humidityPercent: 29.99 },
        mockAirQualityData,
        'stable'
      );

      const humidityAdvice = advice.find((a) => a.type === 'humidity');
      expect(humidityAdvice).toBeDefined();
    });

    it('should handle boundary value humidity = 80.01%', () => {
      const advice = generateEnvironmentAdvice(
        { ...mockWeatherData, humidityPercent: 80.01 },
        mockAirQualityData,
        'stable'
      );

      const humidityAdvice = advice.find((a) => a.type === 'humidity');
      expect(humidityAdvice).toBeDefined();
    });
  });
});
