const deepmerge = require("deepmerge");
const { commonConfig } = require("./base");

module.exports = deepmerge(commonConfig, {
  ci: {
    collect: {
      settings: {
        emulatedFormFactor: "mobile",
      },
    },
    assert: {
      assertions: {
        // Mobile devices typically have lower performance scores, so 0.5 is a common baseline.
        "categories:performance": ["error", { minScore: 0.5 }],

        // Accessibility should remain high regardless of form factor.
        "categories:accessibility": ["error", { minScore: 0.9 }],

        // Best practices are essential for a smooth user experience.
        "categories:best-practices": ["error", { minScore: 0.9 }],

        // SEO is critical to drive traffic, so keep the score high.
        "categories:seo": ["error", { minScore: 0.9 }],
      },
    },
  },
});
