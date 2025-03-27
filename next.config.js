const createNextIntlPlugin = require("next-intl/plugin");

const withNextIntl = createNextIntlPlugin({
  experimental: {
    // Provide the path to the messages that you're using in `AppConfig`
    createMessagesDeclaration: "./messages/en.json",
  },
});

/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack: (config) => {
    config.module.rules.push({
      test: /\.(test|spec)\.(tsx?|jsx?)$/,
      use: "ignore-loader",
    });

    return config;
  },
};

module.exports = withNextIntl(nextConfig);
