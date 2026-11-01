const baseConfig = require('./tailwind.config');

// Solo escanea lo que usa el widget: el CSS del bundle del widget baja de ~1.5 MB a lo necesario.
module.exports = {
  ...baseConfig,
  content: [
    './app/javascript/widget/**/*.vue',
    './app/javascript/shared/**/*.vue',
    './app/javascript/dashboard/components-next/avatar/**/*.vue',
    './app/javascript/dashboard/components-next/icon/**/*.vue',
    './app/views/widgets/**/*.erb',
  ],
};
