"use client";

import { useTranslations } from "next-intl";
import { useEffect } from "react";

type ErrorProps = {
  error: Error & { digest?: string };
  reset: () => void;
};

/**
 * @see https://next-intl.dev/docs/environments/error-files#errorjs
 */
export default function CustomError({ error, reset }: ErrorProps) {
  const t = useTranslations("Error");

  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div className="flex min-h-screen items-center justify-center bg-[#f3f4f6] px-4">
      <div className="w-full max-w-md rounded-xl bg-[#ffffff] p-8 text-center shadow-md">
        <h1 className="mb-4 font-bold text-4xl text-[#dc2626]">{t("title")}</h1>
        <p className="mb-6 text-[#374151]">{t("message")}</p>
        <button
          type="button"
          onClick={reset}
          className="cursor-pointer rounded-md bg-[#dc2626] px-6 py-3 text-[#ffffff] transition hover:bg-[#b91c1c]"
        >
          {t("retry")}
        </button>
      </div>
    </div>
  );
}
