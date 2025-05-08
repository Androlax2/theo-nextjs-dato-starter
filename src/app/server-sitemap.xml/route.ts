import { routing } from "@/i18n/routing";
import { executeQuery } from "@/lib/datocms/executeQuery";
import { graphql } from "@/lib/datocms/graphql";
import { getBaseUrl, getLocalizedUrl } from "@/lib/url";
import { hasLocale } from "next-intl";
import { type ISitemapField, getServerSideSitemap } from "next-sitemap";
import type { Locale } from "use-intl";

/**
 * GraphQL query to retrieve published pages with pagination.
 * Uses the first/skip pattern for pagination.
 */
const sitemapPagesQuery = graphql(/* GraphQL */ `
    query SitemapPagesQuery($first: IntType = 100, $skip: IntType = 0) {
        allPages(first: $first, skip: $skip) {
            _updatedAt
            _allSlugLocales {
                value
                locale
            }
        }
        _allPagesMeta {
            count
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
  let totalPages = 0;
  const pageSize = 100;

  const initialResult = await executeQuery(sitemapPagesQuery, {
    includeDrafts: false,
    variables: {
      first: pageSize,
      skip: 0,
    },
  });

  let allPages = [...initialResult.allPages];
  totalPages = initialResult._allPagesMeta.count;

  // If we have more pages than the initial request can return,
  // fetch the remaining pages
  if (totalPages > pageSize) {
    const remainingRequests = Math.ceil(totalPages / pageSize) - 1;

    const remainingPagesPromises = Array.from(
      { length: remainingRequests },
      (_, i) =>
        executeQuery(sitemapPagesQuery, {
          includeDrafts: false,
          variables: {
            first: pageSize,
            skip: (i + 1) * pageSize,
          },
        }),
    );

    const remainingResults = await Promise.all(remainingPagesPromises);

    for (const result of remainingResults) {
      allPages = [...allPages, ...result.allPages];
    }
  }

  /** Generates sitemap entries dynamically from CMS-managed content. */
  const dynamicSitemapEntries: ISitemapField[] = allPages.flatMap((page) =>
    (page._allSlugLocales || [])
      .filter((slugLocale): slugLocale is { value: string; locale: Locale } =>
        hasLocale(routing.locales, slugLocale.locale),
      )
      .flatMap((slugLocale) => ({
        loc: getLocalizedUrl(`/${slugLocale.value}`, slugLocale.locale),
        lastmod: page._updatedAt ?? undefined,
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
