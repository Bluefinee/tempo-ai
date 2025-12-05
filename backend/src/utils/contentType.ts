/**
 * @fileoverview Content Type Utility Functions
 *
 * HTTPリクエストのContent-Typeを検証・操作するためのユーティリティ関数。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

/**
 * Checks if the Content-Type header indicates JSON format
 *
 * @param contentType - The Content-Type header value
 * @returns true if the content type is application/json
 */
export const ensureJsonRequest = (
  contentType: string | null | undefined,
): boolean => {
  if (!contentType) return false
  return contentType.toLowerCase().includes('application/json')
}
