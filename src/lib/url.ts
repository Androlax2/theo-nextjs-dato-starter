import { getPathname } from "@/i18n/navigation";
import type { Locale } from "use-intl";

type Href = Parameters<typeof getPathname>[0]["href"];

/**
 * Returns the base URL of the site, optionally appending a provided path.
 *
 * @param path - Optional path to append to the base URL.
 *
 * @returns The complete base URL without trailing slash.
 */
export function getBaseUrl(path?: string): string {
  const baseUrl = (process.env.SITE_URL ?? "http://localhost:3000").replace(
    /\/$/,
    "",
  );

  if (path) {
    const normalizedPath = path.startsWith("/") ? path : `/${path}`;
    return `${baseUrl}${normalizedPath}`;
  }

  return baseUrl;
}

/**
 * Generates a localized URL based on the provided href and locale.
 *
 * @param href - The path or object describing the URL.
 * @param locale - The locale code (e.g., 'en', 'fr').
 *
 * @returns The fully constructed localized URL.
 */
export function getLocalizedUrl(href: Href, locale: Locale): string {
  return getBaseUrl() + getPathname({ locale, href });
}
