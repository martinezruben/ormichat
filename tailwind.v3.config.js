const baseConfig = require('./tailwind.config');

// Pantallas de login/registro (entrada v3app): solo escanea lo que realmente carga.
module.exports = {
  ...baseConfig,
  content: [
    './app/javascript/v3/**/*.vue',
    './app/javascript/shared/**/*.vue',
    './app/javascript/dashboard/components/auth/**/*.vue',
    './app/javascript/dashboard/components-next/button/**/*.vue',
    './app/javascript/dashboard/components-next/dialog/**/*.vue',
    './app/javascript/dashboard/components-next/icon/**/*.vue',
    './app/javascript/dashboard/components-next/TeleportWithDirection.vue',
    './app/views/devise/**/*.erb',
    './app/views/layouts/vueapp.html.erb',
  ],
};
