import { TagFragment } from "@/lib/datocms/commonFragments";
import { executeQuery } from "@/lib/datocms/executeQuery";
import { graphql } from "@/lib/datocms/graphql";
import { draftMode } from "next/headers";
import { toNextMetadata } from "react-datocms";

import "../global.css";
import { Link } from "@/i18n/navigation";
import { routing } from "@/i18n/routing";
import type { WithLocaleProps } from "@/types/pageProps";
import { NextIntlClientProvider, hasLocale } from "next-intl";
import { setRequestLocale } from "next-intl/server";
import { notFound } from "next/navigation";
import type React from "react";

const query = graphql(
  /* GraphQL */ `
        query query {
            _site {
                faviconMetaTags {
                    ...TagFragment
                }
            }
        }
    `,
  [TagFragment],
);

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

export async function generateMetadata() {
  const { isEnabled: isDraftModeEnabled } = await draftMode();
  const data = await executeQuery(query, { includeDrafts: isDraftModeEnabled });
  return toNextMetadata(data._site.faviconMetaTags);
}

type LocaleLayoutProps = {
  children: React.ReactNode;
} & WithLocaleProps;

export default async function LocaleLayout({
  children,
  params,
}: LocaleLayoutProps) {
  const { locale } = await params;

  if (!hasLocale(routing.locales, locale)) {
    notFound();
  }

  setRequestLocale(locale);

  return (
    <html lang={locale}>
      <body className="flex min-h-screen flex-col font-sans">
        <NextIntlClientProvider>
          <header className="bg-[#ffffff] shadow">
            <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-6">
              <Link href="/">
                <h1 className="font-semibold text-xl">
                  DatoCMS + Next.js Starter Kit
                </h1>
              </Link>
              <nav className="space-x-4">
                <a
                  className="text-[#2563eb] underline underline-offset-2 transition hover:text-[#1e40af]"
                  href="https://www.datocms.com/docs/next-js"
                >
                  📚 Guide
                </a>
              </nav>
            </div>
          </header>
          <main className="flex-grow">{children}</main>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
