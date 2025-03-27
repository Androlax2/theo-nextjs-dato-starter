import { routing } from "@/i18n/routing";
import { executeQuery } from "@/lib/datocms/executeQuery";
import { graphql } from "@/lib/datocms/graphql";
import { getBaseUrl, getLocalizedUrl } from "@/lib/url";
import { hasLocale } from "next-intl";
import { type ISitemapField, getServerSideSitemap } from "next-sitemap";
import type { Locale } from "use-intl";

/** GraphQL query to retrieve published pages and their localized slugs from CMS. */
const allPagesQuery = graphql(/* GraphQL */ `
    query AllPagesQuery {
        allPages {
            _publishedAt
            _allSlugLocales {
                value
                locale
            }
        }
    }
`);

/**
 * Static routes manually added to the sitemap.
 *
 * Add paths here that are not managed dynamically via CMS but should be included
 * in your sitemap. These could be special landing pages, standalone pages,
 * or any manually maintained static routes.
 *
 * Example:
 * [
 *   "/",
 *   "/about",
 *   "/contact-us"
 * ]
 */
const staticRoutes: string[] = [
  // "/",
  // "/pathnames",
];

/**
 * Generates and returns a dynamic server-side sitemap including both CMS-managed and static routes.
 *
 * @returns A dynamically generated sitemap for Next.js.
 */
export async function GET() {
  const { allPages } = await executeQuery(allPagesQuery, {
    includeDrafts: false,
  });

  /** Generates sitemap entries dynamically from CMS-managed content. */
  const dynamicSitemapEntries: ISitemapField[] = allPages.flatMap((page) =>
    (page._allSlugLocales || [])
      .filter((slugLocale): slugLocale is { value: string; locale: Locale } =>
        hasLocale(routing.locales, slugLocale.locale),
      )
      .flatMap((slugLocale) => ({
        loc: getLocalizedUrl(`/${slugLocale.value}`, slugLocale.locale),
        lastmod: page._publishedAt ?? undefined,
      })),
  );

  /** Generates sitemap entries from predefined static routes. */
  const staticSitemapEntries: ISitemapField[] = staticRoutes.flatMap(
    (route) => ({
      loc: getBaseUrl(route),
      lastmod: new Date().toISOString(),
    }),
  );

  /** Returns the complete sitemap combining both static and dynamic entries. */
  return getServerSideSitemap([
    ...staticSitemapEntries,
    ...dynamicSitemapEntries,
  ]);
}
