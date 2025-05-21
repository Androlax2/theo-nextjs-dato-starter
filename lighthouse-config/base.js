let urls;

try {
  urls = require("../lhci-urls.json");
} catch (_) {
  console.warn("⚠️  LHCI URLs file not found: ./lhci-urls-clean.json");
  urls = [];
}

if (!Array.isArray(urls) || urls.length === 0) {
  console.warn(
    "⚠️  No URLs available for Lighthouse CI. " +
      "Make sure you’ve run `npm run lhci:generate-urls` before running lighthouse.",
  );
}

/**
 * The base Lighthouse CI configuration.
 */
const commonConfig = {
  ci: {
    collect: {
      url: urls,
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
