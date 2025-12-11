import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { fetchAirQualityData } from '../../src/services/airQuality.js';
import { AirQualityApiError } from '../../src/utils/errors.js';

// Mock global fetch with proper typing
const mockFetch = vi.fn() as unknown as typeof global.fetch;
global.fetch = mockFetch;

describe('Air Quality Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe('fetchAirQualityData', () => {
    const validParams = {
      latitude: 35.6895,
      longitude: 139.6917,
    };

    const mockAirQualityResponse = {
      current: {
        pm2_5: 12.5,
        pm10: 25.3,
        us_aqi: 45,
      },
    };

    describe('正常系', () => {
      it('有効な緯度経度で大気汚染データを取得できる', async () => {
        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(mockAirQualityResponse),
        } as unknown as Response);

        const result = await fetchAirQualityData(validParams);

        expect(result).toEqual({
          aqi: 45,
          pm25: 12.5,
          pm10: 25.3,
        });
      });

      it('PM10が無効な場合はundefinedになる', async () => {
        const responseWithoutPM10 = {
          current: {
            pm2_5: 12.5,
            pm10: null,
            us_aqi: 45,
          },
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(responseWithoutPM10),
        } as unknown as Response);

        const result = await fetchAirQualityData(validParams);

        expect(result).toEqual({
          aqi: 45,
          pm25: 12.5,
          pm10: undefined,
        });
      });

      it('PM10が負の値の場合はundefinedになる', async () => {
        const responseWithNegativePM10 = {
          current: {
            pm2_5: 12.5,
            pm10: -5,
            us_aqi: 45,
          },
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(responseWithNegativePM10),
        } as unknown as Response);

        const result = await fetchAirQualityData(validParams);

        expect(result.pm10).toBeUndefined();
      });
    });

    describe('異常系', () => {
      it('無効な緯度でエラーが発生する', async () => {
        await expect(
          fetchAirQualityData({ latitude: 91, longitude: 139.6917 })
        ).rejects.toThrow(AirQualityApiError);

        await expect(
          fetchAirQualityData({ latitude: -91, longitude: 139.6917 })
        ).rejects.toThrow(AirQualityApiError);
      });

      it('無効な経度でエラーが発生する', async () => {
        await expect(
          fetchAirQualityData({ latitude: 35.6895, longitude: 181 })
        ).rejects.toThrow(AirQualityApiError);

        await expect(
          fetchAirQualityData({ latitude: 35.6895, longitude: -181 })
        ).rejects.toThrow(AirQualityApiError);
      });

      it('API側エラー（500）でAirQualityApiErrorが発生する', async () => {
        mockFetch.mockResolvedValueOnce({
          ok: false,
          status: 500,
          statusText: 'Internal Server Error',
        } as unknown as Response);

        await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      });

      it('ネットワークエラーでAirQualityApiErrorが発生する', async () => {
        mockFetch.mockRejectedValueOnce(new Error('Network error'));

        await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      });

      it('不正なJSONレスポンスでエラーが発生する', async () => {
        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockRejectedValueOnce(new Error('Invalid JSON')),
        } as unknown as Response);

        await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      });

      it('currentデータが欠如している場合エラーが発生する', async () => {
        const invalidResponse = {};

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(invalidResponse),
        } as unknown as Response);

        await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      });

      it('必須フィールドが欠如している場合エラーが発生する', async () => {
        const invalidResponse = {
          current: {
            pm10: 25.3,
            // pm2_5 と us_aqi が欠如
          },
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(invalidResponse),
        } as unknown as Response);

        await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      });

      it('PM2.5が負の値の場合エラーが発生する', async () => {
        const invalidResponse = {
          current: {
            pm2_5: -5,
            pm10: 25.3,
            us_aqi: 45,
          },
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(invalidResponse),
        } as unknown as Response);

        await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      });

      it('AQIが負の値の場合エラーが発生する', async () => {
        const invalidResponse = {
          current: {
            pm2_5: 12.5,
            pm10: 25.3,
            us_aqi: -1,
          },
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(invalidResponse),
        } as unknown as Response);

        await expect(fetchAirQualityData(validParams)).rejects.toThrow(AirQualityApiError);
      });
    });

    describe('境界値', () => {
      it('緯度経度の境界値で正常に動作する', async () => {
        const setupMock = (): void => {
          mockFetch.mockResolvedValueOnce({
            ok: true,
            json: vi.fn().mockResolvedValueOnce(mockAirQualityResponse),
          } as unknown as Response);
        };

        // 北極点
        setupMock();
        await expect(
          fetchAirQualityData({ latitude: 90, longitude: 0 })
        ).resolves.toBeDefined();

        // 南極点
        setupMock();
        await expect(
          fetchAirQualityData({ latitude: -90, longitude: 0 })
        ).resolves.toBeDefined();

        // 東端
        setupMock();
        await expect(
          fetchAirQualityData({ latitude: 0, longitude: 180 })
        ).resolves.toBeDefined();

        // 西端
        setupMock();
        await expect(
          fetchAirQualityData({ latitude: 0, longitude: -180 })
        ).resolves.toBeDefined();
      });

      it('ゼロ値で正常に動作する', async () => {
        const zeroResponse = {
          current: {
            pm2_5: 0,
            pm10: 0,
            us_aqi: 0,
          },
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(zeroResponse),
        } as unknown as Response);

        const result = await fetchAirQualityData(validParams);

        expect(result).toEqual({
          aqi: 0,
          pm25: 0,
          pm10: 0,
        });
      });

      it('非常に高い値で正常に動作する', async () => {
        const highValueResponse = {
          current: {
            pm2_5: 500.5,
            pm10: 1000.8,
            us_aqi: 500,
          },
        };

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(highValueResponse),
        } as unknown as Response);

        const result = await fetchAirQualityData(validParams);

        expect(result).toEqual({
          aqi: 500,
          pm25: 500.5,
          pm10: 1000.8,
        });
      });
    });

    describe('APIリクエスト構築', () => {
      it('正しいURLパラメータでAPIが呼び出される', async () => {
        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: vi.fn().mockResolvedValueOnce(mockAirQualityResponse),
        } as unknown as Response);

        await fetchAirQualityData(validParams);

        expect(fetch).toHaveBeenCalledWith(
          expect.stringContaining('latitude=35.6895'),
          expect.any(Object)
        );
        expect(fetch).toHaveBeenCalledWith(
          expect.stringContaining('longitude=139.6917'),
          expect.any(Object)
        );
        expect(fetch).toHaveBeenCalledWith(
          expect.stringContaining('current=pm2_5,pm10,us_aqi'),
          expect.any(Object)
        );
      });
    });
  });
});