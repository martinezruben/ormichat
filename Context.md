# Context.md — Chatwoot

Documento de contexto general del proyecto para orientarse rápido antes de hacer cambios.
Para convenciones de código, estilo, i18n y flujo de PR ya existe **`AGENTS.md`** (symlink `CLAUDE.md`) — este archivo no lo duplica, se enfoca en la arquitectura y el mapa del repo.

## Qué es

Chatwoot es una plataforma de atención al cliente open-source (alternativa a Intercom/Zendesk), self-hosted. Versión actual: `4.17.1` (ver `VERSION_CW`).

No es un repositorio git en esta ruta (`/home/ruben/chatwoot` no tiene `.git`) — es un checkout plano del código.

## Stack técnico

- **Backend**: Ruby on Rails 7.2 (`Gemfile`), PostgreSQL (`pg`), Redis, Sidekiq (workers), Searchkick + OpenSearch (búsqueda), Devise (auth), ActionCable (websockets/tiempo real).
- **Frontend**: Vue 3 (Composition API), Vite como bundler (`vite.config.ts`, `vite.lib.config.ts`, `vite.sdk.analyze.config.mts`), TailwindCSS (única fuente de estilos, sin CSS custom/scoped), Vitest para tests JS, Histoire para componentes (`histoire.config.ts`).
- **Gestor de paquetes JS**: `pnpm` (`pnpm-lock.yaml`). Ruby vía `bundler` + `rbenv` (versión en `.ruby-version`).
- **Orquestación local**: `overmind` / `foreman` sobre `Procfile.dev` (`pnpm dev`).
- **Docker**: `docker-compose.yml` define servicios `postgres`, `redis`, `rails`, `sidekiq` (+ volúmenes `postgres_data`, `redis_data`).
- **Config de entorno**: `.env` (local, con `SECRET_KEY_BASE`; el resto de variables de Chatwoot se documentan en `.env.example` / `config/`).

## Estructura de alto nivel

```
app/
  controllers/    API pública (api/v1), dashboard, webhooks (twilio, slack, instagram, tiktok, shopify, notion, linear, microsoft...), auth, super_admin, public
  models/         ~98 tablas (ver db/schema.rb). Núcleo: Account, Conversation, Contact, Inbox, AgentBot, AutomationRule, CannedResponse, Campaign, CustomAttributeDefinition...
  services/       lógica de negocio (auto_assignment, automation_rules, conversations, contacts, crm, data_import, email...)
  jobs/           Sidekiq jobs (organizados por dominio: campaigns, channels, conversations, contacts, crm, data_imports...)
  listeners/       event listeners (pub/sub interno)
  policies/       autorización (Pundit-style)
  javascript/
    dashboard/    app principal del agente/admin (Vue 3) — api, components, components-next (nuevo, usar para message bubbles), store/stores, routes, i18n
    v3/           nueva superficie/rediseño en construcción (api, components, store, views)
    widget/       widget de chat embebible para sitios de clientes
    sdk/          SDK JS que se inyecta en sitios externos para cargar el widget
    portal/       Help Center / base de conocimiento pública
    design-system/ componentes de diseño compartidos
enterprise/       overlay de Chatwoot Enterprise (ver más abajo)
lib/              utilidades transversales (llm/, captain/, integrations/, webhooks/, custom_exceptions/, redis/, seeders/...)
config/           routes.rb (~770 líneas), application.rb, initializers, etc.
db/               schema.rb (~98 tablas) y migraciones
swagger/          documentación OpenAPI de la API pública
tests/ , spec/    tests (Vitest para JS/Vue, RSpec para Ruby — ver AGENTS.md para comandos)
```

## Mecanismo Enterprise (importante antes de tocar código "core")

- `enterprise/` es un **overlay** que extiende/sobreescribe el código OSS: `config/application.rb` agrega `enterprise/lib`, `enterprise/listeners` y todo `enterprise/app/**` a los `eager_load_paths`.
- Enterprise tiene su propia estructura paralela: `enterprise/app/{models,controllers,services,jobs,listeners,policies,presenters,builders,dispatchers,drops,fields,finders,helpers,mailers,validators,views}`.
- El patrón típico de extensión es `prepend_mod_with` (mixins que Enterprise puede prependear sobre clases OSS) más hooks/feature flags — evitar forks duros.
- **Regla práctica**: antes de modificar un modelo/servicio/controlador "core", buscar si existe contraparte en `enterprise/` (`rg -n "NombreClase" app enterprise`) y mantener compatibilidad en ambos árboles.

## Multi-tenancy y dominio

- Todo gira en torno a `Account` (tenant). La mayoría de modelos (`Conversation`, `Contact`, `Inbox`, `AgentBot`, etc.) están scopeados por `account_id`.
- Canales de entrada (`Inbox`) soportan múltiples proveedores: email, widget web, Facebook, Instagram, WhatsApp/Twilio, Slack, Line, Telegram, SMS, API genérica, etc. — ver `app/models/channel/` y los controllers de webhooks por proveedor.
- `Captain` es la funcionalidad de agente de IA (mencionada en README y presente como módulo en `lib/captain/`, `enterprise/app/models/captain/`, `app/models/article_embedding` sugiere uso de embeddings/RAG para la IA).

## Puntos de entrada útiles para explorar antes de cambiar algo

- Rutas: `config/routes.rb`
- API pública documentada: `swagger/`
- Autenticación: `app/controllers/auth/`, `devise_overrides/`, gem `devise`
- Tiempo real: ActionCable + `app/jobs/action_cable_broadcast_job.rb`
- Feature flags frontend: `app/javascript/dashboard/featureFlags.js`
- Branding/white-label: composable `shared/composables/useBranding` (`replaceInstallationName`)
- i18n: backend `en.yml`, frontend `en.json` (solo estos se editan a mano; el resto lo gestiona Crowdin)

## Comandos rápidos (detalle completo en AGENTS.md)

```bash
bundle install && pnpm install       # setup
pnpm dev                             # levanta rails+vite+sidekiq vía overmind
bundle exec rspec spec/path_spec.rb  # test Ruby puntual
pnpm test                            # tests JS/Vue (vitest)
bundle exec rubocop -a               # lint Ruby con autofix
pnpm eslint:fix                      # lint JS/Vue con autofix
```

## Notas para hacer cambios

- Seguir siempre las guías de `AGENTS.md` (estilo, PR format, reglas de Enterprise, i18n, Tailwind-only).
- Componentes de mensajes: usar `components-next/` (el resto de componentes de mensaje está en deprecación).
- Vue: Composition API con `<script setup>` siempre.
- No hay `.git` en este checkout — si se necesita versionar cambios, confirmar con el usuario cómo quiere manejarlo (¿inicializar git, aplicar patch, o es un mount temporal de otro repo?).
