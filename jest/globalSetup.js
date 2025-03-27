const { execSync } = require("node:child_process");

module.exports = async () => {
  execSync("node jest/generateFragmentMocks.js", { stdio: "inherit" });
};
