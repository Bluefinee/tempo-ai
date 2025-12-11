import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { fetchWeatherData } from '../../src/services/weather.js';
import { WeatherApiError } from '../../src/utils/errors.js';

// Mock global fetch with proper typing
const mockFetch = vi.fn() as unknown as typeof global.fetch;
global.fetch = mockFetch;

describe('Weather Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe('fetchWeatherData', () => {
    const validParams = {
      latitude: 35.6895,
      longitude: 139.6917,
    };

    const mockWeatherResponse = {
      current: {
        temperature_2m: 14.2,
        relative_humidity_2m: 65,
        weather_code: 0,
        surface_pressure: 1018.5,
      },
      daily: {
        temperature_2m_max: [18.5],
        temperature_2m_min: [8.2],
        uv_index_max: [4.5],
        precipitation_probability_max: [10],
      },
    };

    describe('正常系', () => {
      it('有効な緯度経度で気象データを取得できる', async () => {
        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(mockWeatherResponse),
        } as unknown as Response);

        const result = await fetchWeatherData(validParams);

        expect(result).toEqual({
          condition: '快晴',
          tempCurrentC: 14.2,
          tempMaxC: 18.5,
          tempMinC: 8.2,
          humidityPercent: 65,
          uvIndex: 4.5,
          pressureHpa: 1018.5,
          precipitationProbability: 10,
        } as unknown as Response);
      });

      it('Weather Code 1 で晴れに変換される', async () => {
        const responseWithCode1 = {
          ...mockWeatherResponse,
          current: { ...mockWeatherResponse.current, weather_code: 1 },
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(responseWithCode1),
        } as unknown as Response);

        const result = await fetchWeatherData(validParams);
        expect(result.condition).toBe('晴れ');
      });

      it('未知のWeather Codeで不明に変換される', async () => {
        const responseWithUnknownCode = {
          ...mockWeatherResponse,
          current: { ...mockWeatherResponse.current, weather_code: 999 },
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(responseWithUnknownCode),
        } as unknown as Response);

        const result = await fetchWeatherData(validParams);
        expect(result.condition).toBe('不明');
      });
    });

    describe('異常系', () => {
      it('無効な緯度でエラーが発生する', async () => {
        await expect(
          fetchWeatherData({ latitude: 91, longitude: 139.6917 })
        ).rejects.toThrow(WeatherApiError);

        await expect(
          fetchWeatherData({ latitude: -91, longitude: 139.6917 })
        ).rejects.toThrow(WeatherApiError);
      });

      it('無効な経度でエラーが発生する', async () => {
        await expect(
          fetchWeatherData({ latitude: 35.6895, longitude: 181 })
        ).rejects.toThrow(WeatherApiError);

        await expect(
          fetchWeatherData({ latitude: 35.6895, longitude: -181 })
        ).rejects.toThrow(WeatherApiError);
      });

      it('API側エラー（500）でWeatherApiErrorが発生する', async () => {
        mockFetch.mockResolvedValueOnce({
          ok: false,
          status: 500,
          statusText: 'Internal Server Error',
        } as unknown as Response);

        await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      });

      it('ネットワークエラーでWeatherApiErrorが発生する', async () => {
        mockFetch.mockRejectedValueOnce(new Error('Network error'));

        await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      });

      it('不正なJSONレスポンスでエラーが発生する', async () => {
        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockRejectedValueOnce(new Error('Invalid JSON')),
        } as unknown as Response);

        await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      });

      it('currentデータが欠如している場合エラーが発生する', async () => {
        const invalidResponse = {
          daily: mockWeatherResponse.daily,
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(invalidResponse),
        } as unknown as Response);

        await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      });

      it('dailyデータが欠如している場合エラーが発生する', async () => {
        const invalidResponse = {
          current: mockWeatherResponse.current,
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(invalidResponse),
        } as unknown as Response);

        await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      });

      it('daily配列データが不正な場合エラーが発生する', async () => {
        const invalidResponse = {
          current: mockWeatherResponse.current,
          daily: {
            temperature_2m_max: [],
            temperature_2m_min: [8.2],
            uv_index_max: [4.5],
            precipitation_probability_max: [10],
          },
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(invalidResponse),
        } as unknown as Response);

        await expect(fetchWeatherData(validParams)).rejects.toThrow(WeatherApiError);
      });
    });

    describe('境界値', () => {
      it('緯度経度の境界値で正常に動作する', async () => {
        const setupMock = (): void => {
          mockFetch.mockResolvedValueOnce({
            ok: true,
            json: vi.fn().mockResolvedValueOnce(mockWeatherResponse),
          } as unknown as Response);
        };

        // 北極点
        setupMock();
        await expect(
          fetchWeatherData({ latitude: 90, longitude: 0 })
        ).resolves.toBeDefined();

        // 南極点
        setupMock();
        await expect(
          fetchWeatherData({ latitude: -90, longitude: 0 })
        ).resolves.toBeDefined();

        // 東端
        setupMock();
        await expect(
          fetchWeatherData({ latitude: 0, longitude: 180 })
        ).resolves.toBeDefined();

        // 西端
        setupMock();
        await expect(
          fetchWeatherData({ latitude: 0, longitude: -180 })
        ).resolves.toBeDefined();
      });
    });

    describe('APIリクエスト構築', () => {
      it('正しいURLパラメータでAPIが呼び出される', async () => {
        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(mockWeatherResponse),
        } as unknown as Response);

        await fetchWeatherData(validParams);

        expect(fetch).toHaveBeenCalledWith(
          expect.stringContaining('latitude=35.6895'),
          expect.any(Object)
        );
        expect(fetch).toHaveBeenCalledWith(
          expect.stringContaining('longitude=139.6917'),
          expect.any(Object)
        );
        expect(fetch).toHaveBeenCalledWith(
          expect.stringContaining('current=temperature_2m,relative_humidity_2m,weather_code,surface_pressure'),
          expect.any(Object)
        );
        expect(fetch).toHaveBeenCalledWith(
          expect.stringContaining('daily=temperature_2m_max,temperature_2m_min,uv_index_max,precipitation_probability_max'),
          expect.any(Object)
        );
        expect(fetch).toHaveBeenCalledWith(
          expect.stringContaining('timezone=Asia/Tokyo'),
          expect.any(Object)
        );
      });
    });
  });
});