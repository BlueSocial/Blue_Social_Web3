const { getDefaultConfig } = require("expo/metro-config");

const config = getDefaultConfig(__dirname);

config.resolver.unstable_enablePackageExports = true;
config.resolver.unstable_conditionNames = [
  "react-native",
  "browser",
  "require",
];

config.transformer = {
  ...config.transformer,
  getTransformOptions: async () => ({
    transform: {
      routerRoot: __dirname // This sets the root directory as the router root
    },
  }),
};

module.exports = config;
