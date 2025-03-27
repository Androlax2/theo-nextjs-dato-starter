import type { Locale } from "use-intl";

export type WithLocaleProps<
  AdditionalParams extends object = Record<string, unknown>,
> = {
  params: Promise<{ locale: Locale } & AdditionalParams>;
};
