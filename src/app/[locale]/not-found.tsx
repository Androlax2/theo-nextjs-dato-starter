import { useTranslations } from "next-intl";
// biome-ignore lint/nursery/noRestrictedImports: We need to import `Link` from `next/link` in this file.
import Link from "next/link";

/**
 * @see https://next-intl.dev/docs/environments/error-files#not-foundjs
 */
export default function NotFoundPage() {
  const t = useTranslations("NotFoundPage");

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-gray-100 p-4">
      <h1 className="mb-4 font-bold text-6xl text-gray-800">{t("title")}</h1>
      <p className="mb-8 text-gray-600 text-xl">{t("message")}</p>
      <Link
        href="/"
        className="rounded-md bg-blue-600 px-6 py-3 text-white transition hover:bg-blue-700"
      >
        {t("cta")}
      </Link>
    </div>
  );
}
