// Sentry pesa ~360 kB: solo se descarga si la instalación tiene un DSN configurado.
// Sin DSN, captureException y setContext no hacen nada.
let sentry = null;

export const initErrorTracking = async ({ app, router }) => {
  if (!window.errorLoggingConfig) return;

  sentry = await import('@sentry/vue');
  sentry.init({
    app,
    dsn: window.errorLoggingConfig,
    denyUrls: [
      // Chrome extensions
      /^chrome:\/\//i,
      /chrome-extension:/i,
      /extensions\//i,

      // Locally saved copies
      /file:\/\//i,

      // Safari extensions.
      /safari-web-extension:/i,
      /safari-extension:/i,
    ],
    integrations: [sentry.browserTracingIntegration({ router })],
    ignoreErrors: [
      'ResizeObserver loop completed with undelivered notifications',
    ],
  });
};

export const captureException = error => sentry?.captureException(error);

export const setContext = (name, context) => sentry?.setContext(name, context);
