const baseConfig = require('./tailwind.config');

module.exports = {
  ...baseConfig,
  content: [
    './app/javascript/survey/**/*.vue',
    './app/javascript/shared/**/*.vue',
    './app/views/survey/**/*.erb',
  ],
};
