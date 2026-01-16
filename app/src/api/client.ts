/**
 * API Client
 * @see docs/specs/technical_spec.md
 */

import Constants from "expo-constants";
import type {
	AdviceRequest,
	AdviceResponse,
	ApiError,
	ApiResponse,
	WeatherResponse,
} from "./types";

const API_BASE_URL =
	Constants.expoConfig?.extra?.apiBaseUrl ?? "http://localhost:8787";
const API_TIMEOUT = 30000;

interface FetchOptions {
	method?: "GET" | "POST" | "PUT" | "DELETE";
	body?: unknown;
	timeout?: number;
}

/**
 * APIクライアント
 */
class ApiClient {
	private baseUrl: string;

	constructor(baseUrl: string) {
		this.baseUrl = baseUrl;
	}

	/**
	 * フェッチラッパー
	 */
	private async fetch<T>(
		endpoint: string,
		options: FetchOptions = {},
	): Promise<ApiResponse<T>> {
		const { method = "GET", body, timeout = API_TIMEOUT } = options;

		const controller = new AbortController();
		const timeoutId = setTimeout(() => controller.abort(), timeout);

		try {
			const response = await fetch(`${this.baseUrl}${endpoint}`, {
				method,
				headers: {
					"Content-Type": "application/json",
				},
				body: body ? JSON.stringify(body) : undefined,
				signal: controller.signal,
			});

			clearTimeout(timeoutId);

			if (!response.ok) {
				const errorData = (await response
					.json()
					.catch(() => ({}))) as Partial<ApiError>;
				return {
					success: false,
					error: {
						error: errorData.error ?? "Request failed",
						message: errorData.message,
						statusCode: response.status,
					},
				};
			}

			const json = await response.json();
			// バックエンドは { success: true, data: ... } 形式で返す
			if (json.success && json.data !== undefined) {
				return { success: true, data: json.data as T };
			}
			// 直接データが返ってくる場合
			return { success: true, data: json as T };
		} catch (error) {
			clearTimeout(timeoutId);

			if (error instanceof Error && error.name === "AbortError") {
				return {
					success: false,
					error: {
						error: "Request timeout",
						message: "The request took too long to complete",
					},
				};
			}

			return {
				success: false,
				error: {
					error: "Network error",
					message: error instanceof Error ? error.message : "Unknown error",
				},
			};
		}
	}

	/**
	 * ヘルスチェック
	 */
	async health(): Promise<ApiResponse<{ status: string }>> {
		return this.fetch("/api/health");
	}

	/**
	 * 天気情報取得
	 */
	async getWeather(
		lat: number,
		lon: number,
	): Promise<ApiResponse<WeatherResponse>> {
		return this.fetch(`/api/weather?lat=${lat}&lon=${lon}`);
	}

	/**
	 * AIアドバイス生成
	 */
	async generateAdvice(
		request: AdviceRequest,
	): Promise<ApiResponse<AdviceResponse>> {
		return this.fetch("/api/advice", {
			method: "POST",
			body: request,
		});
	}
}

// シングルトンインスタンス
export const apiClient = new ApiClient(API_BASE_URL);

// 型エクスポート
export type { ApiClient };
