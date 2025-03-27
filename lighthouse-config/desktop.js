const deepmerge = require("deepmerge");
const { commonConfig } = require("./base");

module.exports = deepmerge(commonConfig, {
  ci: {
    collect: {
      settings: {
        emulatedFormFactor: "desktop",
      },
    },
    assert: {
      assertions: {
        // Desktop devices are expected to deliver high performance.
        "categories:performance": ["error", { minScore: 0.9 }],

        // Accessibility remains essential for all users.
        "categories:accessibility": ["error", { minScore: 0.9 }],

        // Adhering to best practices ensures a solid user experience.
        "categories:best-practices": ["error", { minScore: 0.9 }],

        // SEO should remain high to drive organic traffic.
        "categories:seo": ["error", { minScore: 0.9 }],
      },
    },
  },
});
