/**
 * リトライユーティリティ
 * API呼び出しの自動リトライ機能
 */

/**
 * リトライオプション
 */
interface RetryOptions {
  /** 最大リトライ回数（デフォルト: 3） */
  maxRetries?: number;
  /** 初期待機時間（ミリ秒、デフォルト: 1000） */
  initialDelayMs?: number;
  /** 最大待機時間（ミリ秒、デフォルト: 10000） */
  maxDelayMs?: number;
  /** バックオフ倍率（デフォルト: 2） */
  backoffMultiplier?: number;
}

/**
 * デフォルトのリトライオプション
 */
const DEFAULT_OPTIONS: Required<RetryOptions> = {
  maxRetries: 3,
  initialDelayMs: 1000,
  maxDelayMs: 10000,
  backoffMultiplier: 2,
};

/**
 * 指定した関数を失敗時にリトライして実行
 * @param fn 実行する非同期関数
 * @param options リトライオプション
 * @returns 関数の戻り値
 * @throws 最大リトライ回数を超えた場合
 */
export const withRetry = async <T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> => {
  const opts = { ...DEFAULT_OPTIONS, ...options };
  let lastError: Error | null = null;
  let delay = opts.initialDelayMs;

  for (let attempt = 0; attempt <= opts.maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      if (attempt < opts.maxRetries) {
        // 次の試行前に待機
        await sleep(delay);
        // バックオフ（待機時間を増加）
        delay = Math.min(delay * opts.backoffMultiplier, opts.maxDelayMs);
      }
    }
  }

  throw lastError;
};

/**
 * 指定ミリ秒待機
 * @param ms 待機時間（ミリ秒）
 * @returns Promise<void>
 */
const sleep = (ms: number): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, ms));

/**
 * 条件付きリトライ（特定のエラーのみリトライ）
 * @param fn 実行する非同期関数
 * @param shouldRetry リトライすべきかどうかを判定する関数
 * @param options リトライオプション
 * @returns 関数の戻り値
 * @throws リトライ条件を満たさない場合、または最大リトライ回数を超えた場合
 */
export const withConditionalRetry = async <T>(
  fn: () => Promise<T>,
  shouldRetry: (error: Error) => boolean,
  options: RetryOptions = {}
): Promise<T> => {
  const opts = { ...DEFAULT_OPTIONS, ...options };
  let lastError: Error | null = null;
  let delay = opts.initialDelayMs;

  for (let attempt = 0; attempt <= opts.maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      // リトライ条件を満たさない場合は即座にエラー
      if (!shouldRetry(lastError)) {
        throw lastError;
      }

      if (attempt < opts.maxRetries) {
        await sleep(delay);
        delay = Math.min(delay * opts.backoffMultiplier, opts.maxDelayMs);
      }
    }
  }

  throw lastError;
};

