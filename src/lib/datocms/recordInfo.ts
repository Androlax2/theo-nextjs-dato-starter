import type { SchemaTypes } from "@datocms/cma-client";
import type { Locale } from "use-intl";

export type ItemTypeApiKey = "page";

/*
 * Both the "Web Previews" and "SEO/Readability Analysis" plugins from DatoCMS
 * need to know the URL of the site that corresponds to each DatoCMS record to
 * work properly. These two functions are responsible for returning this
 * information, and are utilized by the route handlers associated with the two
 * plugins:
 *
 * - src/app/api/seo-analysis/route.tsx
 * - src/app/api/preview-links/route.tsx
 */

export async function recordToWebsiteRoute(
  item: SchemaTypes.Item,
  itemTypeApiKey: ItemTypeApiKey,
  locale: Locale,
): Promise<string | null> {
  switch (itemTypeApiKey) {
    case "page": {
      return `/${locale}/${await recordToSlug(item, itemTypeApiKey, locale)}`;
    }
    default:
      return null;
  }
}

export async function recordToSlug(
  item: SchemaTypes.Item,
  itemTypeApiKey: ItemTypeApiKey,
  locale: Locale,
): Promise<string | null> {
  switch (itemTypeApiKey) {
    case "page": {
      // @ts-ignore
      const slug: string = item.attributes.slug[locale];

      if (slug === "") {
        return "/"; // Homepage
      }

      return slug;
    }
    default:
      return null;
  }
}
