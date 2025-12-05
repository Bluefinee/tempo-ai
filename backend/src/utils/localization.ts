/**
 * @fileoverview Localization utilities for backend services
 *
 * 多言語対応のユーティリティ関数とタイプ定義。
 * Claude APIレスポンスやエラーメッセージの多言語化をサポートします。
 *
 * @author Tempo AI Team
 * @since Phase 0 - Internationalization
 */

/**
 * 多言語コンテンツの型定義
 */
export interface LocalizedContent {
  /** 日本語コンテンツ */
  ja: string
  /** 英語コンテンツ */
  en: string
}

/**
 * サポートされている言語コード
 */
export type SupportedLanguage = 'ja' | 'en'

/**
 * 地域情報を含む詳細な多言語化コンテキスト
 */
export interface LocalizationContext {
  /** 言語コード */
  language: SupportedLanguage
  /** 地域コード */
  region: 'JP' | 'US' | 'CA' | 'GB' | 'AU'
  /** タイムゾーン */
  timeZone: string
  /** 文化的コンテキスト */
  culturalContext?: {
    /** 食事の時間帯 */
    mealTimes: {
      breakfast: string // "07:00"
      lunch: string // "12:00"
      dinner: string // "19:00"
    }
    /** 敬語使用レベル (日本語の場合) */
    formalityLevel?: 'casual' | 'polite' | 'formal'
  }
}

/**
 * 指定された言語でローカライズされたメッセージを取得
 *
 * @param content - 多言語コンテンツオブジェクト
 * @param language - 対象言語 (デフォルト: 日本語)
 * @returns ローカライズされた文字列
 */
export const getLocalizedMessage = (
  content: LocalizedContent,
  language: SupportedLanguage = 'ja',
): string => {
  return content[language] || content.en || content.ja
}

/**
 * LocalizedContentオブジェクトを作成するヘルパー関数
 *
 * @param ja - 日本語テキスト
 * @param en - 英語テキスト
 * @returns LocalizedContentオブジェクト
 */
export const createLocalizedContent = (
  ja: string,
  en: string,
): LocalizedContent => ({
  ja,
  en,
})

/**
 * 言語コードの検証
 *
 * @param language - 検証する言語コード
 * @returns 有効な言語コードかどうか
 */
export const isValidLanguage = (
  language: string,
): language is SupportedLanguage => {
  return ['ja', 'en'].includes(language)
}

/**
 * Accept-Language ヘッダーから最適な言語を決定
 *
 * @param acceptLanguageHeader - HTTPのAccept-Languageヘッダー値
 * @returns 最適なサポート言語
 */
export const parseAcceptLanguage = (
  acceptLanguageHeader?: string,
): SupportedLanguage => {
  if (!acceptLanguageHeader) {
    return 'ja' // デフォルトは日本語
  }

  // 簡易的なパース (q値は考慮しない)
  const languages = acceptLanguageHeader
    .split(',')
    .map((lang) => lang.split(';')[0]?.trim().toLowerCase())
    .filter((lang): lang is string => Boolean(lang))

  // 完全一致をチェック
  for (const lang of languages) {
    if (isValidLanguage(lang)) {
      return lang
    }
  }

  // 部分一致をチェック (ja-JP -> ja)
  for (const lang of languages) {
    const primaryLanguage = lang.split('-')[0]
    if (primaryLanguage && isValidLanguage(primaryLanguage)) {
      return primaryLanguage
    }
  }

  return 'ja' // フォールバック
}

/**
 * 多言語化された日時フォーマット
 *
 * @param date - フォーマットする日時
 * @param language - 言語コード
 * @param options - Intl.DateTimeFormatのオプション
 * @returns フォーマットされた日時文字列
 */
export const formatLocalizedDate = (
  date: Date,
  language: SupportedLanguage = 'ja',
  options: Intl.DateTimeFormatOptions = {},
): string => {
  const locale = language === 'ja' ? 'ja-JP' : 'en-US'
  const defaultOptions: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    ...options,
  }

  return new Intl.DateTimeFormat(locale, defaultOptions).format(date)
}

/**
 * 多言語化された数値フォーマット
 *
 * @param number - フォーマットする数値
 * @param language - 言語コード
 * @param options - Intl.NumberFormatのオプション
 * @returns フォーマットされた数値文字列
 */
export const formatLocalizedNumber = (
  number: number,
  language: SupportedLanguage = 'ja',
  options: Intl.NumberFormatOptions = {},
): string => {
  const locale = language === 'ja' ? 'ja-JP' : 'en-US'
  return new Intl.NumberFormat(locale, options).format(number)
}

// MARK: - 事前定義されたエラーメッセージ

/**
 * 一般的なエラーメッセージの多言語対応
 */
export const errorMessages = {
  networkError: createLocalizedContent(
    'ネットワークエラーが発生しました',
    'A network error occurred',
  ),
  invalidData: createLocalizedContent('無効なデータです', 'Invalid data'),
  serverError: createLocalizedContent(
    'サーバーエラーが発生しました',
    'A server error occurred',
  ),
  notFound: createLocalizedContent(
    'リソースが見つかりません',
    'Resource not found',
  ),
  unauthorized: createLocalizedContent(
    '認証が必要です',
    'Authentication required',
  ),
  forbidden: createLocalizedContent(
    'アクセスが拒否されました',
    'Access denied',
  ),
  timeout: createLocalizedContent(
    'リクエストがタイムアウトしました',
    'Request timed out',
  ),
  rateLimitExceeded: createLocalizedContent(
    'リクエスト制限に達しました',
    'Rate limit exceeded',
  ),
} as const

/**
 * Claude API関連のエラーメッセージ
 */
export const claudeErrorMessages = {
  apiKeyMissing: createLocalizedContent(
    'Claude APIキーが設定されていません',
    'Claude API key not configured',
  ),
  invalidApiKey: createLocalizedContent(
    '無効なClaude APIキーです',
    'Invalid Claude API key',
  ),
  invalidResponse: createLocalizedContent(
    'Claude APIからの応答が無効です',
    'Invalid response from Claude API',
  ),
  jsonParseError: createLocalizedContent(
    'AIレスポンスのJSON解析に失敗しました',
    'Failed to parse AI response JSON',
  ),
  schemaValidationError: createLocalizedContent(
    'AIレスポンスの形式が無効です',
    'AI response format is invalid',
  ),
} as const

/**
 * 成功メッセージの多言語対応
 */
export const successMessages = {
  adviceGenerated: createLocalizedContent(
    '健康アドバイスを生成しました',
    'Health advice generated successfully',
  ),
  dataUpdated: createLocalizedContent(
    'データが更新されました',
    'Data updated successfully',
  ),
  settingsSaved: createLocalizedContent(
    '設定が保存されました',
    'Settings saved successfully',
  ),
} as const

/**
 * リクエストコンテキストから言語を抽出するヘルパー
 *
 * @param headers - HTTPヘッダーオブジェクト
 * @returns 抽出された言語コード
 */
export const extractLanguageFromHeaders = (
  headers: Record<string, string | string[] | undefined>,
): SupportedLanguage => {
  const acceptLanguage = Array.isArray(headers['accept-language'])
    ? headers['accept-language'][0]
    : headers['accept-language']

  return parseAcceptLanguage(acceptLanguage)
}

/**
 * LocalizationContextのデフォルト値を生成
 *
 * @param language - ベース言語
 * @returns デフォルトのLocalizationContext
 */
export const createDefaultLocalizationContext = (
  language: SupportedLanguage = 'ja',
): LocalizationContext => ({
  language,
  region: language === 'ja' ? 'JP' : 'US',
  timeZone: language === 'ja' ? 'Asia/Tokyo' : 'America/New_York',
  culturalContext: {
    mealTimes: {
      breakfast: language === 'ja' ? '07:00' : '08:00',
      lunch: language === 'ja' ? '12:00' : '12:30',
      dinner: language === 'ja' ? '19:00' : '18:30',
    },
    formalityLevel: language === 'ja' ? 'polite' : 'casual',
  },
})
