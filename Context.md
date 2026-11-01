# Context.md — Ormichat

Documento de contexto general del proyecto para orientarse rápido antes de hacer cambios.

- Convenciones de código, estilo, i18n y flujo de PR → **`AGENTS.md`** (`CLAUDE.md` es un symlink a este).
- Deployment, Docker, Captain/Ollama, webhooks y troubleshooting → **`INSTALL.md`**.
- Este archivo no duplica esos dos: se enfoca en qué es el proyecto, el mapa del repo y qué se customizó.

## Qué es

**Ormichat** es una plataforma de atención al cliente omnicanal y self-hosted (alternativa a Intercom/Zendesk). La versión del código base está en `VERSION_CW`.

- Repo git propio: `github.com/martinezruben/ormichat`, sin vínculo con ningún repo externo (no se hacen merges de upstream).
- El primer commit es el código base; todo lo posterior son customizaciones de Ormichat (ver sección más abajo o `git log`).
- En el código interno muchos nombres siguen siendo "Chatwoot" (clases, contenedores, variables de entorno); el rebranding es solo de la capa de presentación.

## Stack técnico

- **Backend**: Ruby on Rails 7.2, PostgreSQL (con `pgvector`, requerido por Captain), Redis, Sidekiq, Searchkick + OpenSearch, Devise, ActionCable.
- **Frontend**: Vue 3 (Composition API, `<script setup>`), Vite, TailwindCSS (única fuente de estilos), Vitest, Histoire.
- **Paquetes**: `pnpm` para JS; Ruby vía `bundler` + `rbenv` (`.ruby-version`).
- **Ejecución**: Docker (`docker-compose.yml`: `postgres`, `redis`, `setup`, `rails`, `sidekiq`) con una imagen propia construida desde este repo (`docker/Dockerfile`, frontend incluido; sin bind mounts ni dependencia de imágenes de Chatwoot). Detalle en `INSTALL.md` §3–4.
- **IA**: Captain corre sobre un modelo local de **Ollama** (no OpenAI). Detalle en `INSTALL.md` §9.

## Estructura de alto nivel

```
app/
  controllers/    API (api/v1), dashboard, webhooks por proveedor, auth, super_admin, public
  models/         núcleo: Account, Conversation, Contact, Inbox, Label, AgentBot, AutomationRule, Campaign, CustomAttributeDefinition...
  services/       lógica de negocio por dominio
  jobs/           Sidekiq jobs por dominio
  listeners/      event listeners (pub/sub interno)
  policies/       autorización
  javascript/
    dashboard/      app principal del agente/admin (Vue 3) — api, components, components-next, store, routes, i18n
    v3/             superficie nueva/rediseño
    widget/         widget de chat embebible
    sdk/            SDK JS que carga el widget en sitios externos
    portal/         Help Center público
    design-system/  componentes compartidos
    shared/         helpers, composables, constantes y fuentes compartidas
enterprise/       overlay Enterprise (ver abajo)
lib/              utilidades transversales (llm/, captain/, integrations/, custom_exceptions/, seeders/...)
config/           routes.rb, application.rb, initializers
db/               schema.rb y migraciones
swagger/          OpenAPI de la API pública
spec/ , tests/    RSpec (Ruby) y Vitest (JS/Vue)
```

## Mecanismo Enterprise (importante antes de tocar código "core")

- `enterprise/` es un **overlay** que extiende/sobreescribe el código OSS; `config/application.rb` lo agrega a los `eager_load_paths`.
- Estructura paralela: `enterprise/app/{models,controllers,services,jobs,...}`.
- Extensión típica vía `prepend_mod_with` + hooks/feature flags — evitar forks duros.
- En este deployment los módulos Enterprise están **habilitados** (plan y features premium activados en todas las cuentas, `INSTALL.md` §5). Ej.: custom roles vive en `enterprise/app/models/custom_role.rb`.
- **Regla práctica**: antes de modificar un modelo/servicio/controlador core, buscar contraparte con `rg -n "NombreClase" app enterprise`.

## Multi-tenancy y dominio

- Todo gira en torno a `Account` (tenant); casi todos los modelos están scopeados por `account_id`.
- `Inbox` soporta muchos canales (email, widget, WhatsApp, Telegram, Facebook, Instagram, SMS, API...) — ver `app/models/channel/`. Los canales con webhook (p. ej. Telegram) necesitan `FRONTEND_URL` HTTPS público (túnel ngrok, `INSTALL.md` §8).
- `Captain` es el agente de IA (`lib/captain/`, `enterprise/app/models/captain/`, embeddings con pgvector).

## Customizaciones de Ormichat

**Infra / deployment**
- Imagen Docker propia (`docker/Dockerfile`) y volúmenes con nombre para base de datos, Redis y archivos subidos; marca Ormichat por defecto en `config/installation_config.yml`.
- Telemetría al hub de Chatwoot, registro del onboarding y push relay deshabilitados.
- `FRONTEND_URL` apuntando al túnel ngrok (webhooks de Telegram).
- `rack-timeout` ampliado para inferencia local lenta.

**Captain AI sobre Ollama**
- Captain enrutado a un modelo local de Ollama; migración que reduce columnas de embeddings a 768 dims; fix del gem `ai-agents` para modelos self-hosted.

**Branding y design system**
- Presentación rebrandeada a "Ormichat"; eliminados links a chatwoot.com / chwt.app.
- **Tema shadcn/ui** (reemplazó al Design System Ormichat índigo): paleta neutral de shadcn en claro/oscuro, primario neutral (`bg-n-brand` + `text-n-brand-foreground` para el texto encima), rojo destructivo, radios shadcn, sombras por defecto de Tailwind y tipografía **Geist** en todas las superficies (`font-inter`/`font-heading`/etc. apuntan a Geist). No se instaló shadcn-vue: el look se logra con tokens.
  - Tokens: `dashboard/assets/scss/_next-colors.scss` (dashboard, portal, encuestas, v3), `widget/assets/scss/woot.scss` y `dashboard/assets/scss/super_admin/index.scss` — mantenerlos alineados.
  - Componentes base con estilo shadcn (solo clases): `components-next/` Button, Input, TextArea, Checkbox, Dialog, DropdownMenu, y formularios legacy en `_base.scss`.
  - Colores con significado propio se mantienen (tipos de archivo, Linear, color del portal/widget configurable, logo).

**Features**
- **Custom attribute tipo "File"**: adjunta el archivo como binario al compositor y previsualiza imágenes; botón para insertar un custom attribute en el compositor (`dashboard/components/CustomAttribute.vue`).
- **Contactos**: campos de dirección y ubicación (link a Maps), país por defecto República Dominicana (`shared/helpers/locationHelper.js`); panel de contacto simplificado.
- **Labels "selectable"**: flag para ocultar labels que son solo para automatizaciones de los selectores manuales (`app/models/label.rb`, `useConversationLabels.js`).
- **Custom roles → visibilidad del sidebar**: un rol puede restringir qué ítems del menú ve (`visible_menu_items` en `custom_roles`, catálogo en `dashboard/constants/sidebarMenuCatalog.js`, `usePolicy.js`).
- **SMTP configurable desde Settings > Security**: `MailerSettingsService`, `ReloadMailerSettingsJob`, `Api::V1::Accounts::MailerSettingsController`, UI en `settings/security/components/MailerSettings.vue` (trim de campos y email de prueba editable).

**i18n**
- Idiomas soportados: solo `es` (por defecto) y `en`; el resto de locales y Crowdin se eliminaron. Todo string nuevo se escribe en ambos idiomas (ver `AGENTS.md`).

## Puntos de entrada útiles

- Rutas: `config/routes.rb`
- API pública: `swagger/`
- Auth: `app/controllers/auth/`, `devise_overrides/`
- Tiempo real: ActionCable + `app/jobs/action_cable_broadcast_job.rb`
- Feature flags frontend: `app/javascript/dashboard/featureFlags.js`
- Branding: `shared/composables/useBranding` (`replaceInstallationName`), `public/brand-assets/`
- Permisos frontend: `dashboard/composables/usePolicy.js`, `dashboard/helper/permissionsHelper.js`

## Comandos rápidos (detalle en AGENTS.md / INSTALL.md)

```bash
docker compose up -d                                                   # levanta el stack
docker compose exec rails bundle exec rails db:chatwoot_prepare   # migraciones
bundle install && pnpm install                                         # setup local
bundle exec rspec spec/path_spec.rb                                    # test Ruby puntual
pnpm test                                                              # tests JS/Vue
bundle exec rubocop -a                                                 # lint Ruby
pnpm eslint:fix                                                        # lint JS/Vue
```

## Notas para hacer cambios

- Seguir `AGENTS.md` (estilo, Conventional Commits, formato de PR, reglas Enterprise, Tailwind-only).
- Mensajes: usar `components-next/` (el resto está en deprecación).
- Cambios de backend: reiniciar `rails`/`sidekiq`; migraciones nuevas: correrlas dentro del contenedor; cambios de frontend: recompilar con `pnpm` en el host (`INSTALL.md` §4).
- Al agregar una customización relevante, anotarla en la sección "Customizaciones de Ormichat" de este archivo.
