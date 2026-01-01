import { describe, expect, it } from 'vitest';
import { type Result, err, isErr, isOk, ok } from './result';

describe('Result type', () => {
  describe('ok', () => {
    it('should create success result with data', () => {
      const result = ok({ value: 42 });

      expect(result.ok).toBe(true);
      expect(result.data).toEqual({ value: 42 });
    });

    it('should work with primitive types', () => {
      const stringResult = ok('hello');
      const numberResult = ok(123);
      const boolResult = ok(true);

      expect(stringResult.data).toBe('hello');
      expect(numberResult.data).toBe(123);
      expect(boolResult.data).toBe(true);
    });
  });

  describe('err', () => {
    it('should create error result with message', () => {
      const result = err('Something went wrong');

      expect(result.ok).toBe(false);
      expect(result.error).toBe('Something went wrong');
    });

    it('should work with custom error objects', () => {
      const errorObj = { code: 'NOT_FOUND', message: 'Resource not found' };
      const result = err(errorObj);

      expect(result.ok).toBe(false);
      expect(result.error).toEqual(errorObj);
    });
  });

  describe('isOk', () => {
    it('should return true for success result', () => {
      const result = ok(42);

      expect(isOk(result)).toBe(true);
    });

    it('should return false for error result', () => {
      const result = err('error');

      expect(isOk(result)).toBe(false);
    });

    it('should narrow types correctly', () => {
      const result: Result<number, string> = ok(42);

      if (isOk(result)) {
        // TypeScript should know result.data is number here
        expect(result.data + 1).toBe(43);
      }
    });
  });

  describe('isErr', () => {
    it('should return true for error result', () => {
      const result = err('error');

      expect(isErr(result)).toBe(true);
    });

    it('should return false for success result', () => {
      const result = ok(42);

      expect(isErr(result)).toBe(false);
    });

    it('should narrow types correctly', () => {
      const result: Result<number, string> = err('failed');

      if (isErr(result)) {
        // TypeScript should know result.error is string here
        expect(result.error.toUpperCase()).toBe('FAILED');
      }
    });
  });

  describe('type safety', () => {
    it('should maintain type information through transformations', () => {
      type User = { id: number; name: string };
      type UserError = { code: string; details: string };

      const successResult: Result<User, UserError> = ok({
        id: 1,
        name: 'Alice',
      });
      const errorResult: Result<User, UserError> = err({
        code: 'NOT_FOUND',
        details: 'User not found',
      });

      if (isOk(successResult)) {
        expect(successResult.data.name).toBe('Alice');
      }

      if (isErr(errorResult)) {
        expect(errorResult.error.code).toBe('NOT_FOUND');
      }
    });
  });
});
