import { getLocales } from "expo-localization";
import { I18n } from "i18n-js";
import ja from "./locales/ja.json";

const i18n = new I18n({ ja });

// デバイスロケール取得
const deviceLocale = getLocales()[0]?.languageCode ?? "ja";

// 日本語のみサポート（将来英語追加）
i18n.locale = deviceLocale === "ja" ? "ja" : "ja";
i18n.defaultLocale = "ja";
i18n.enableFallback = true;

export const t = (key: string, options?: Record<string, unknown>): string => {
  return i18n.t(key, options);
};

export const setLocale = (locale: string): void => {
  i18n.locale = locale;
};

export const getLocale = (): string => {
  return i18n.locale;
};

export default i18n;
