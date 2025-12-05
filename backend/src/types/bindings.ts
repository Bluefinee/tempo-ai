/**
 * @fileoverview Cloudflare Workers Environment Variable Type Definitions
 *
 * Cloudflare Workers環境変数の型定義。
 * 全ての環境変数をタイプセーフにアクセスするための共通型。
 *
 * @author Tempo AI Team
 * @since 1.0.0
 */

/**
 * Cloudflare Workers環境変数の型定義
 */
export type Bindings = {
  /** Anthropic Claude API キー */
  ANTHROPIC_API_KEY: string
}
