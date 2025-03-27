import DynamicContentRenderer, {
  DynamicContentRendererFragment,
} from "@/components/blocks/DynamicContentRenderer/DynamicContentRenderer";
import { routing } from "@/i18n/routing";
import { TagFragment } from "@/lib/datocms/commonFragments";
import { executeQuery } from "@/lib/datocms/executeQuery";
import { graphql } from "@/lib/datocms/graphql";
import type { WithLocaleProps } from "@/types/pageProps";
import type { Metadata, ResolvingMetadata } from "next";
import { hasLocale } from "next-intl";
import { setRequestLocale } from "next-intl/server";
import { draftMode } from "next/headers";
import { notFound } from "next/navigation";
import { toNextMetadata } from "react-datocms";
import type { Locale } from "use-intl";

/**
 * The GraphQL query that will be executed for this route to generate the page content and metadata.
 */
const query = graphql(
  /* GraphQL */ `
        query PageQuery($locale: SiteLocale!, $slug: String!) {
            page(filter: { slug: { eq: $slug } }, locale: $locale) {
                _seoMetaTags {
                    ...TagFragment
                }
                content {
                    ... on ContentRecord {
                        ...DynamicContentRendererFragment
                    }
                }
            }
        }
    `,
  [TagFragment, DynamicContentRendererFragment],
);

/**
 * A separate query to fetch all pages from DatoCMS for static path generation.
 */
const allPagesQuery = graphql(
  /* GraphQL */ `
        query AllPagesQuery {
            allPages {
                _allSlugLocales {
                    value
                    locale
                }
            }
        }
    `,
);

type PageProps = WithLocaleProps<{ slugs?: string[] }>;

/**
 * Combine the slugs array into a single slug string.
 * For example, ["blog", "my-post"] becomes "blog/my-post".
 * For the homepage (undefined or empty array), it returns an empty string.
 */
function buildSlug(slugs?: string[]): string {
  return Array.isArray(slugs) && slugs.length > 0 ? slugs.join("/") : "";
}

/**
 * Helper to extract and validate query variables from page props.
 */
async function getQueryVariables(
  params: PageProps["params"],
): Promise<{ locale: Locale; slug: string }> {
  const { locale, slugs } = await params;

  if (!hasLocale(routing.locales, locale)) {
    notFound();
  }

  // Build the slug; an empty string is acceptable for the homepage.
  return { locale, slug: buildSlug(slugs) };
}

export async function generateMetadata(
  pageProps: PageProps,
  parent: ResolvingMetadata,
): Promise<Metadata> {
  const variables = await getQueryVariables(pageProps.params);
  const { isEnabled: isDraftModeEnabled } = await draftMode();

  const [parentMetadata, data] = await Promise.all([
    parent,
    executeQuery(query, {
      variables,
      includeDrafts: isDraftModeEnabled,
    }),
  ]);

  if (!data.page) {
    notFound();
  }

  // Combine metadata from parent routes with those of this route.
  return {
    ...(parentMetadata as Metadata),
    ...toNextMetadata(data.page._seoMetaTags || []),
  };
}

/**
 * Generate the static parameters (paths) for Next.js at build time.
 * This function maps each page to its route parameters.
 */
export async function generateStaticParams(): Promise<
  Array<{ locale: Locale; slugs?: string[] }>
> {
  const data = await executeQuery(allPagesQuery, { includeDrafts: false });
  const paths: Array<{ locale: Locale; slugs?: string[] }> = [];

  // Iterate over each page and each locale version of its slug.
  for (const page of data.allPages) {
    if (!page._allSlugLocales) {
      continue;
    }

    for (const slugLocale of page._allSlugLocales) {
      if (!hasLocale(routing.locales, slugLocale.locale)) {
        continue;
      }

      paths.push({
        locale: slugLocale.locale,
        // If the value is an empty string, we treat it as the homepage.
        slugs: slugLocale.value ? slugLocale.value.split("/") : undefined,
      });
    }
  }

  return paths;
}

export default async function Page({ params }: PageProps) {
  const variables = await getQueryVariables(params);
  const { isEnabled: isDraftModeEnabled } = await draftMode();

  const { page } = await executeQuery(query, {
    includeDrafts: isDraftModeEnabled,
    variables,
  });

  if (!page) {
    notFound();
  }

  setRequestLocale(variables.locale);

  return <DynamicContentRenderer data={page.content} />;
}
