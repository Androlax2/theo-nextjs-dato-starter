import { getBaseUrl } from "@/lib/url";
import type { IConfig } from "next-sitemap";

const serverSitemap = "/server-sitemap.xml";

const config: IConfig = {
  siteUrl: getBaseUrl(),
  generateRobotsTxt: true,
  exclude: [
    // Exclude all automatically discovered static pages so only our dynamic ones appear in the sitemap in production.
    process.env.NODE_ENV === "production" ? "/**" : "",

    // Exclude the server sitemap page from the sitemap in anything else than production.
    process.env.NODE_ENV !== "production" ? `/${serverSitemap}` : "",
  ],
  robotsTxtOptions: {
    additionalSitemaps: [
      // Include the server sitemap page in the `robots.txt` file in production.
      process.env.NODE_ENV === "production" ? getBaseUrl(serverSitemap) : "",
    ],
  },
};

// @ts-ignore
export = config;
