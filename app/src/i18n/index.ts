import { getLocales } from "expo-localization";
import { I18n } from "i18n-js";
import en from "./locales/en.json";
import ja from "./locales/ja.json";

const i18n = new I18n({ en, ja });

// Default to English regardless of device locale
// Users can change language in settings if needed
i18n.locale = "en";
i18n.defaultLocale = "en";
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
