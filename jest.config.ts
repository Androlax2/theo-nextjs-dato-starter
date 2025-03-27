/**
 * https://nextjs.org/docs/app/building-your-application/testing/jest
 */

import type { Config } from "jest";
import nextJest from "next/jest.js";

const createJestConfig = nextJest({
  dir: "./",
});

const config: Config = {
  coverageProvider: "v8",
  testEnvironment: "jsdom",
  globalSetup: "<rootDir>/jest/globalSetup.js",
  moduleNameMapper: {
    "^@/components/blocks/NonExistent/NonExistent$":
      "<rootDir>/jest/emptyModule.js",
    "^@/(.*)$": "<rootDir>/src/$1",
  },
  setupFilesAfterEnv: ["<rootDir>/jest.setup.ts"],
};

export default createJestConfig(config);
