/**
 * Success result type
 */
export interface Ok<T> {
  readonly ok: true;
  readonly data: T;
}

/**
 * Error result type
 */
export interface Err<E> {
  readonly ok: false;
  readonly error: E;
}

/**
 * Result type for explicit error handling
 * Inspired by Rust's Result type
 */
export type Result<T, E = string> = Ok<T> | Err<E>;

/**
 * Creates a success result with the given data
 */
export const ok = <T>(data: T): Ok<T> => ({
  ok: true,
  data,
});

/**
 * Creates an error result with the given error
 */
export const err = <E>(error: E): Err<E> => ({
  ok: false,
  error,
});

/**
 * Type guard to check if a result is successful
 */
export const isOk = <T, E>(result: Result<T, E>): result is Ok<T> => result.ok;

/**
 * Type guard to check if a result is an error
 */
export const isErr = <T, E>(result: Result<T, E>): result is Err<E> => !result.ok;
