import type React from "react";

/**
 * Since we have a root `not-found.tsx` page, a layout file
 * is required, even if it's just passing children through.
 *
 * @see https://next-intl.dev/docs/environments/error-files#catching-non-localized-requests
 */
export default function RootLayout({
  children,
}: { children: React.ReactNode }) {
  return children;
}
