const fs = require("node:fs");
const path = require("node:path");
const { URL } = require("node:url");
const { XMLParser } = require("fast-xml-parser");

/**
 * Reads and parses an XML file synchronously using fast-xml-parser.
 *
 * @param {string} filePath - The path to the XML file.
 * @returns {any} The parsed XML as a JavaScript object.
 */
function parseXmlFileSync(filePath) {
  try {
    const xmlData = fs.readFileSync(filePath, "utf8");
    const parser = new XMLParser({
      ignoreAttributes: false,
      removeNSPrefix: true,
    });
    return parser.parse(xmlData);
  } catch (error) {
    throw new Error(
      `Error reading or parsing file ${filePath}: ${error.message}`,
    );
  }
}

/**
 * Converts a sitemap URL to a corresponding local file path.
 *
 * @param {string} sitemapUrl - The sitemap URL.
 * @returns {string} The local file path.
 */
function getLocalFilePathFromUrl(sitemapUrl) {
  const urlObj = new URL(sitemapUrl);
  const relativePath = urlObj.pathname.startsWith("/")
    ? urlObj.pathname.slice(1)
    : urlObj.pathname;
  return path.join(__dirname, "..", "public", relativePath);
}

/**
 * @typedef {Object} ParsedSitemap
 * @property {SitemapUrlSet} [urlset]
 * @property {SitemapIndex} [sitemapindex]
 */

/**
 * @typedef {Object} SitemapUrlEntry
 * @property {string} loc - The URL location.
 */

/**
 * @typedef {Object} SitemapUrlSet
 * @property {SitemapUrlEntry|SitemapUrlEntry[]} url - The URL entry or entries.
 */

/**
 * @typedef {Object} SitemapIndexEntry
 * @property {string} loc - The sitemap URL.
 */

/**
 * @typedef {Object} SitemapIndex
 * @property {SitemapIndexEntry|SitemapIndexEntry[]} sitemap - The sitemap entry or entries.
 */

/**
 * Synchronously extracts URLs from the main sitemap or from referenced sitemaps.
 *
 * @returns {string[]} An array of URLs.
 */
function getUrlsFromSitemap() {
  const mainSitemapPath = path.join(__dirname, "..", "public", "sitemap.xml");
  /** @type {ParsedSitemap} */
  let result;
  try {
    result = parseXmlFileSync(mainSitemapPath);
  } catch (error) {
    console.error(`Error processing main sitemap: ${error.message}`);
    return [];
  }

  /** @type {string[]} */
  let urls = [];

  // Check if the main file is a regular sitemap (<urlset>).
  /** @type {SitemapUrlSet|undefined} */
  const urlset = result.urlset;
  if (urlset?.url) {
    /** @type {SitemapUrlEntry[]} */
    const urlEntries = Array.isArray(urlset.url) ? urlset.url : [urlset.url];
    urls = urlEntries.map((u) => u.loc);
  }
  // Otherwise, if it's a sitemap index (<sitemapindex>), process each referenced sitemap.
  /** @type {SitemapIndex|undefined} */
  const sitemapindex = result.sitemapindex;
  if (sitemapindex?.sitemap) {
    /** @type {SitemapIndexEntry[]} */
    const sitemapEntries = Array.isArray(sitemapindex.sitemap)
      ? sitemapindex.sitemap
      : [sitemapindex.sitemap];

    for (const sitemap of sitemapEntries) {
      const loc = sitemap.loc;
      const localSitemapPath = getLocalFilePathFromUrl(loc);
      try {
        const sitemapResult = parseXmlFileSync(localSitemapPath);
        /** @type {SitemapUrlSet|undefined}*/
        const nestedUrlset = sitemapResult.urlset;
        if (nestedUrlset?.url) {
          /** @type {SitemapUrlEntry[]} */
          const entries = Array.isArray(nestedUrlset.url)
            ? nestedUrlset.url
            : [nestedUrlset.url];
          const extractedUrls = entries.map((u) => u.loc);
          urls.push(...extractedUrls);
        } else {
          console.error(
            `Sitemap structure not recognized in file: ${localSitemapPath}`,
            sitemapResult,
          );
        }
      } catch (error) {
        console.error(
          `Failed to process sitemap file at path: ${localSitemapPath}: ${error.message}`,
        );
      }
    }
  } else {
    console.error("Sitemap XML structure is not recognized:", result);
  }

  return urls;
}

/**
 * The base Lighthouse CI configuration.
 */
const commonConfig = {
  ci: {
    collect: {
      url: getUrlsFromSitemap(),
      numberOfRuns: process.env.LHCI_NUMBER_OF_RUNS
        ? Number(process.env.LHCI_NUMBER_OF_RUNS)
        : 1,
      // Device-specific settings will be merged in the child configs.
      settings: {},
    },
    // The assertions will be overridden in device-specific files.
    assert: {
      assertions: {},
    },
    upload: {
      target: "temporary-public-storage",
    },
  },
};

module.exports = { commonConfig };
