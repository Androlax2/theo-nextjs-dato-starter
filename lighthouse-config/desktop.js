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
        "categories:performance": ["error", { minScore: 0.9 }],
        "categories:accessibility": ["error", { minScore: 0.9 }],
        "categories:best-practices": ["error", { minScore: 0.9 }],
        "categories:seo": ["error", { minScore: 0.9 }],
      },
    },
  },
});
