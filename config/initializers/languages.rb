# Idiomas soportados: solo español e inglés. Los índices son los que guarda Account#locale,
# así que no se deben cambiar (ni reutilizar los índices de idiomas eliminados).

LANGUAGES_CONFIG = {
  0 => { name: 'English (en)', iso_639_3_code: 'eng', iso_639_1_code: 'en', enabled: true },
  12 => { name: 'Español (es)', iso_639_3_code: 'spa', iso_639_1_code: 'es', enabled: true }
}.freeze

Rails.configuration.i18n.available_locales = LANGUAGES_CONFIG.map { |_index, lang| lang[:iso_639_1_code].to_sym }
