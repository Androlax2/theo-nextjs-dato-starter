/**
 * List of supported locales in the application.
 */
export const LOCALES = ["fr", "en"] as const;

/**
 * The default locale used when no locale is specified.
 * Must be one of the values from LOCALES.
 */
export const DEFAULT_LOCALE: (typeof LOCALES)[number] = "fr";
