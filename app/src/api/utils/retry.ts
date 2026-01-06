/**
 * リトライユーティリティ
 */

interface RetryOptions {
  maxRetries?: number;
  initialDelayMs?: number;
  maxDelayMs?: number;
  backoffMultiplier?: number;
}

const DEFAULT_OPTIONS: Required<RetryOptions> = {
  maxRetries: 3,
  initialDelayMs: 1000,
  maxDelayMs: 10000,
  backoffMultiplier: 2,
};

/** 指定ミリ秒待機 */
const sleep = (ms: number): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, ms));

/**
 * 条件付きリトライ（特定のエラーのみリトライ）
 * @param fn 実行する非同期関数
 * @param shouldRetry リトライ条件を判定する関数
 * @param options リトライオプション
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

/**
 * 指定した関数を失敗時にリトライして実行
 * @param fn 実行する非同期関数
 * @param options リトライオプション
 */
export const withRetry = async <T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> => withConditionalRetry(fn, () => true, options);

