require("dotenv").config({ path: [".env.local", ".env"] });
const { URL } = require("node:url");
const fs = require("node:fs");
const path = require("node:path");

const API_URL = "https://site-api.datocms.com/items";
const API_TOKEN = process.env.DATOCMS_CMA_TOKEN;
const BASE_URL = process.env.SITE_URL || "http://localhost:3000";
if (!API_TOKEN) {
  console.error("❌ Missing DATOCMS_CMA_TOKEN");
  process.exit(1);
}

async function fetchPage(offset = 0, limit = 100) {
  const url = new URL(API_URL);
  url.searchParams.set("filter[type]", "page");
  url.searchParams.set("page[limit]", String(limit));
  url.searchParams.set("page[offset]", String(offset));

  const res = await fetch(url.toString(), {
    headers: {
      Authorization: `Bearer ${API_TOKEN}`,
      "X-Api-Version": "3",
      Accept: "application/json",
    },
  });
  if (!res.ok) {
    throw new Error(`DatoCMS REST error: ${res.status}`);
  }
  return res.json();
}

async function buildUrls() {
  const first = await fetchPage(0, 100);
  const total = first.meta.total_count;
  const all = [...first.data];

  if (total > all.length) {
    const batches = Math.ceil((total - all.length) / 100);
    const jobs = Array.from({ length: batches }, (_, i) =>
      fetchPage((i + 1) * 100, 100),
    );
    const results = await Promise.all(jobs);
    for (const r of results) {
      all.push(...r.data);
    }
  }

  return all.flatMap((item) => {
    const slugs = item.attributes.slug || {};
    return Object.entries(slugs)
      .filter(([, slug]) => slug)
      .map(([locale, slug]) => {
        return `${BASE_URL}/${locale}/${slug}`.replace(/\/+$/, "");
      });
  });
}

(async () => {
  try {
    const urls = await buildUrls();
    const dest = path.resolve(__dirname, "../lhci-urls.json");
    fs.writeFileSync(dest, JSON.stringify(urls, null, 2));
    // biome-ignore lint/suspicious/noConsole: Logging is fine here.
    console.log(`✅ Wrote ${urls.length} URLs to ${dest}`);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
