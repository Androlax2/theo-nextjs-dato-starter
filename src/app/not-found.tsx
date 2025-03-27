"use client";

import NextError from "next/error";

/**
 * @see https://next-intl.dev/docs/environments/error-files#not-foundjs
 */
export default function NotFound() {
  return (
    <html lang="en">
      <body>
        <NextError statusCode={404} />
      </body>
    </html>
  );
}
