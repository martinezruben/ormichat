# Ormichat — Instalación y configuración

Este documento describe cómo está armado este deployment de **Ormichat**, qué se le customizó respecto al código base, y cómo levantarlo/mantenerlo. Pensado para que alguien sin contexto previo pueda reproducir o continuar este setup.

## Índice

1. [Arquitectura general](#1-arquitectura-general)
2. [Requisitos previos](#2-requisitos-previos)
3. [Levantar el entorno desde cero](#3-levantar-el-entorno-desde-cero)
4. [Imagen propia y actualizaciones](#4-imagen-propia-y-actualizaciones)
5. [Módulos Enterprise habilitados](#5-módulos-enterprise-habilitados)
6. [Feature custom: Custom Attribute tipo "File"](#6-feature-custom-custom-attribute-tipo-file)
7. [Rebranding a Ormichat](#7-rebranding-a-ormichat)
8. [Canales con webhook (Telegram, etc.) — HTTPS público requerido](#8-canales-con-webhook-telegram-etc--https-público-requerido)
9. [Captain AI sobre Ollama local (gratis, sin OpenAI)](#9-captain-ai-sobre-ollama-local-gratis-sin-openai)
10. [Telemetría deshabilitada](#10-telemetría-deshabilitada)
11. [Control de versiones](#11-control-de-versiones)
12. [Troubleshooting](#12-troubleshooting)

---

## 1. Arquitectura general

- **Backend/Frontend**: Rails 7.2 + Vue 3, corriendo en Docker vía `docker-compose.yml`. La imagen `ormichat` se construye desde este repo con `docker/Dockerfile` (Ruby y Node fijados, frontend compilado dentro del build): no depende de ninguna imagen publicada por terceros (ver sección 4).
- **Servicios**: `postgres` (con `pgvector`, necesario para Captain), `redis`, `setup` (migraciones, corre una vez al arrancar), `rails`, `sidekiq`. Datos persistentes en los volúmenes `postgres_data`, `redis_data` y `storage_data` (archivos subidos).
- **Repo git**: propio, privado, sin ningún vínculo con repos externos (ver sección 11).
- **IA (Captain)**: corre 100% local sobre Ollama, sin depender de OpenAI (ver sección 9).

## 2. Requisitos previos

- Docker + Docker Compose.
- [Ollama](https://ollama.com) instalado en el host si se quiere usar Captain AI gratis (sección 9).
- Un archivo `.env` en la raíz del repo, copiado de `.env.example` (`FRONTEND_URL` con HTTPS público, `SECRET_KEY_BASE` y `POSTGRES_PASSWORD`, ambos generables con `openssl rand -hex 64`).

## 3. Levantar el entorno desde cero

```bash
cp .env.example .env     # completar FRONTEND_URL, SECRET_KEY_BASE y POSTGRES_PASSWORD
docker compose up -d --build
```

El primer build compila gemas y frontend (varios minutos). El servicio `setup` crea y migra la base de datos antes de que arranquen `rails` y `sidekiq`. La app queda en `http://localhost:3000` (detrás de tu proxy HTTPS en producción).

Una instalación nueva ya arranca con la marca Ormichat, el plan Enterprise y todas las features premium activadas (los defaults están en `config/installation_config.yml` y `config/features.yml`). Lo único que hay que configurar es la conexión de Captain (sección 9), después de crear la cuenta inicial en el onboarding:

```bash
docker compose exec -e CAPTAIN_ENDPOINT=http://<gateway-docker>:11434 rails bundle exec rails ormichat:setup
docker compose restart rails sidekiq
```

`CAPTAIN_ENDPOINT` es opcional; el gateway se obtiene con `docker network inspect <proyecto>_default`. También acepta `CAPTAIN_MODEL` y `CAPTAIN_EMBEDDING_MODEL`. La tarea sirve además para llevar una base ya existente al mismo estado (marca, plan y features en cuentas viejas) y es seguro correrla varias veces.

### Pasar de la versión anterior del compose (imagen `chatwoot/chatwoot` con bind mounts)

Si el servidor ya tiene volúmenes creados por esa versión, Postgres conserva sus credenciales originales (usuario `chatwoot`, base `chatwoot_production`, contraseña `chatwoot`). Para reutilizar los datos, el `.env` nuevo debe decirlo:

```
POSTGRES_USER=chatwoot
POSTGRES_DB=chatwoot_production
POSTGRES_PASSWORD=chatwoot
SECRET_KEY_BASE=<el mismo que ya usabas>
```

Conservar el `SECRET_KEY_BASE` mantiene las sesiones y los datos cifrados. Los archivos subidos que estaban dentro del contenedor anterior no se conservan (no tenían volumen).

## 4. Imagen propia y actualizaciones

`docker/Dockerfile` construye la imagen en tres etapas, todas con versiones fijadas (`RUBY_VERSION`, `NODE_VERSION`):

1. **frontend**: `pnpm install --frozen-lockfile`, SDK y Vite.
2. **builder**: `bundle install` (sin development/test) y `assets:precompile`.
3. **final**: Ruby slim con solo las librerías de ejecución (libpq, libvips, imagemagick, cliente de postgres), corriendo como usuario no root.

El código va dentro de la imagen: no hay bind mounts. Para aplicar cualquier cambio (Ruby, Vue, migraciones, traducciones):

```bash
git pull
docker compose up -d --build     # reconstruye y reinicia; `setup` aplica las migraciones nuevas
```

Los datos no se tocan: viven en volúmenes con nombre (`postgres_data`, `redis_data`, `storage_data`; este último guarda los archivos subidos, como adjuntos y fotos de recetas).

### Respaldos automáticos

El servicio `backup` de `docker-compose.yml` guarda cada 24 h, en `./backups/` del servidor:

- `db-AAAA-MM-DD_HHMM.sql.gz`: volcado de Postgres (se verifica con `gzip -t` antes de aceptarlo).
- `storage-AAAA-MM-DD_HHMM.tgz`: archivos subidos.

Conserva los últimos `BACKUP_KEEP_DAYS` días (14 por defecto). Revisar que funciona: `docker compose logs backup`.

**Copia fuera del servidor (obligatoria):** `./backups/` está en el mismo disco que los datos, así que no protege contra perder el servidor. Sincronizarla a otro lugar con un cron del host, por ejemplo `rclone sync ./backups remoto:ormichat-backups` o `rsync -a ./backups/ usuario@otro-servidor:/respaldos/ormichat/`.

**Restaurar** (probar al menos una vez en un entorno de prueba):

```bash
docker compose stop rails sidekiq
gunzip -c backups/db-AAAA-MM-DD_HHMM.sql.gz | docker compose exec -T postgres psql -U ormichat -d ormichat_production
docker run --rm -v ormichat_storage_data:/data -v "$PWD/backups":/in busybox tar xzf /in/storage-AAAA-MM-DD_HHMM.tgz -C /data
docker compose start rails sidekiq
```

(el prefijo `ormichat_` de los volúmenes es el nombre de la carpeta del proyecto; ver `docker volume ls`). Para restaurar sobre una base ya existente, recrearla antes: `DROP DATABASE` / `CREATE DATABASE`.

### HTTPS

`FORCE_SSL` vale `true` por defecto: Rails redirige a HTTPS, marca las cookies como seguras y envía HSTS. El proxy TLS delante debe enviar `X-Forwarded-Proto: https`. Para probar sin proxy en `http://localhost:3000` poner `FORCE_SSL=false` en `.env`.

## 5. Módulos Enterprise habilitados

El módulo `enterprise/` viene en el código y los defaults de este repo ya lo dejan activado en instalaciones nuevas. Para una base que ya existía (donde los defaults no se reescriben) se activa con `rails ormichat:setup`, que hace lo siguiente:

```ruby
# 1. Plan de instalación (interruptor maestro)
InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN').update!(value: 'enterprise')

# 2. Features premium — activadas en todas las cuentas existentes
premium = SuperAdmin::AccountFeaturesHelper.account_premium_features
Account.find_each { |a| a.enable_features!(*premium) }

# 3. Defaults para cuentas futuras (para no repetir el paso 2 cada vez)
InstallationConfig.find_or_initialize_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS').tap do |c|
  c.value = premium.map { |name| { name: name, enabled: true } }
  c.save!
end

GlobalConfig.clear_cache
```

**Features que necesitan infraestructura extra para funcionar de verdad** (el flag está prendido, pero sin esto no hacen nada):

| Feature | Requiere |
|---|---|
| `advanced_search` / `advanced_search_indexing` | `OPENSEARCH_URL` configurada |
| `saml` | Configurar `AccountSamlSettings` (IdP) por cuenta |
| `captain_*` | Ver sección 9 (ya resuelto con Ollama) |
| `channel_voice` | Credenciales de proveedor de voz (Twilio/Dyte) |

## 6. Feature custom: Custom Attribute tipo "File"

Se agregó un tipo de Custom Attribute nuevo (`file`) que permite subir un archivo como valor, disponible para `conversation_attribute` y `contact_attribute`. Diseño: el archivo se sube vía un endpoint de `direct_uploads` (ActiveStorage) y se guarda como valor del atributo la URL pública y permanente del blob (`/rails/active_storage/blobs/proxy/:signed_id/:filename`) — mismo patrón que ya usa el tipo `link`, sin necesitar cambios de esquema. Se usa la ruta `proxy` (Rails sirve el archivo) en vez de `redirect`, porque la redirección lleva a una URL firmada que expira a los 5 minutos; los valores viejos con `redirect` se reescriben a `proxy` al mostrarlos. Por seguridad, el dashboard solo muestra como enlace/imagen valores que empiezan con `/rails/active_storage/blobs/` (los atributos también se pueden escribir desde el SDK del widget).

**Archivos tocados:**
- `app/models/custom_attribute_definition.rb` — `file: 8` agregado al enum `attribute_display_type`.
- `config/routes.rb` + `app/controllers/api/v1/accounts/contacts/direct_uploads_controller.rb` — endpoint de upload nuevo para contactos (el de conversación ya existía).
- `app/javascript/dashboard/routes/dashboard/settings/attributes/constants.js` — tipo `FILE` en el selector.
- `app/javascript/dashboard/composables/useCustomAttributeFileUpload.js` — composable de subida (ActiveStorage `DirectUpload`).
- `app/javascript/dashboard/components/CustomAttribute.vue` — UI de subida en el panel de conversación.
- `app/javascript/dashboard/components-next/CustomAttributes/FileAttribute.vue` — UI de subida en el sidebar de perfil de contacto.

Cómo usarlo: Settings → Custom Attributes → Add Custom Attribute → Type = "File".

## 7. Rebranding a Ormichat

- `InstallationConfig`: `INSTALLATION_NAME` y `BRAND_NAME` = `Ormichat` (esto activa el mecanismo de white-labeling nativo de Chatwoot — `useBranding().replaceInstallationName()` y `isACustomBrandedInstance`, que además ocultan solos los links de ayuda propios de Chatwoot).
- Reemplazo directo del texto "Chatwoot" por "Ormichat" en: locale EN (dashboard/widget/survey), `config/locales/en.yml`, vistas de Super Admin, templates de email, `public/manifest.json`.
- Se eliminaron todos los links hardcodeados a `chwt.app` (help center de Chatwoot): `config/features.yml`, `featureHelper.js`, empty-states de Captain, guías de migración de WhatsApp, datos de ejemplo de Campaigns.
- **Se dejaron sin tocar a propósito** (renombrarlos rompería cosas): clases Ruby internas (`ChatwootHub`, `ChatwootApp`, etc.), `window.chatwootSDK` (API pública del widget embebible — la usan todos los sitios que ya tengan el snippet instalado), la feature flag `chatwoot_v4`, migraciones existentes en `db/migrate/`.

## 8. Canales con webhook (Telegram, etc.) — HTTPS público requerido

Los canales que usan webhooks (Telegram es el caso ya configurado) necesitan que `FRONTEND_URL` sea una **URL HTTPS públicamente accesible desde internet** — Telegram rechaza silenciosamente `http://localhost:3000` (el bug de fondo: `Channel::Telegram#setup_telegram_webhook` no valida el campo `ok` de la respuesta de Telegram, así que Chatwoot guarda el canal como si nada, sin avisar del error).

**Setup actual (desarrollo/pruebas): ngrok**

```bash
ngrok http 3000 --url https://tiffiny-chondriosomal-chandra.ngrok-free.dev
```

`FRONTEND_URL` en `.env` apunta a esa URL de ngrok. **Si el túnel cambia de URL** (se cae, se reinicia sin dominio fijo reservado en la cuenta de ngrok), hay que:

1. Actualizar `FRONTEND_URL` en `.env`.
2. `docker compose up -d --force-recreate rails sidekiq`
3. Re-registrar el webhook de cada canal Telegram existente:
   ```ruby
   Channel::Telegram.find_each(&:save!)   # dispara setup_telegram_webhook de nuevo
   ```
4. Verificar con la API de Telegram:
   ```ruby
   HTTParty.get("https://api.telegram.org/bot<TOKEN>/getWebhookInfo").parsed_response
   # "url" no debe estar vacío, "pending_update_count" debe bajar a 0
   ```

**Para producción real**: reemplazar el túnel de ngrok por un dominio propio con SSL.

## 9. Captain AI sobre Ollama local (gratis, sin OpenAI)

Captain (el agente de IA de Chatwoot) corre íntegramente sobre un modelo local de Ollama, sin ningún costo ni dependencia de OpenAI/Anthropic/Gemini.

### 9.1 Cómo funciona

Todo el tráfico de Captain (chat + embeddings) pasa por un único endpoint "OpenAI-compatible" configurable, vía el gem `ruby_llm`. Ollama expone justamente una API compatible con el protocolo de OpenAI, así que se lo conecta ahí.

### 9.2 Requisitos

```bash
# Instalar Ollama en el host: https://ollama.com
ollama pull llama3.1:8b          # modelo de chat (8B, corre bien en CPU)
ollama pull nomic-embed-text     # modelo de embeddings (274MB)
```

Verificar que escuche en todas las interfaces (no solo loopback), para que los contenedores lo alcancen:
```bash
ss -tlnp | grep 11434
# debe verse: LISTEN ... *:11434 ...  (no 127.0.0.1:11434)
```

Los contenedores llegan al host vía el gateway de la red de Docker (`docker network inspect chatwoot_default` → `Gateway`, normalmente `172.19.0.1` o similar — verificar con `docker network inspect` si cambia).

### 9.3 Cambios de código necesarios (ya aplicados en este repo)

El código de Chatwoot, tal cual viene, **no permite** usar un modelo que no esté en el catálogo estático del gem `ruby_llm` (`config/llm_models.json`, ~1250 modelos conocidos de OpenAI/Anthropic/etc.) — cualquier nombre de modelo de un proveedor gratis (`llama3.1:8b`, etc.) hace que la librería tire `RubyLLM::ModelNotFoundError`. Se parchearon 3 archivos:

- **`lib/llm/feature_router.rb`**: el override de modelo self-hosted (`CAPTAIN_OPEN_AI_MODEL`) antes solo aplicaba a 1 de las ~14 funciones de Captain (`conversation_completion`). Se sacó esa restricción para que aplique a todas (asistente, resúmenes, sugerencia de etiquetas, generación de FAQs, etc.).
- **`lib/captain/base_task_service.rb`** y **`enterprise/app/services/captain/llm/embedding_service.rb`**: se agregó un fallback — si `ruby_llm` no reconoce el modelo, reintentar con `provider: :openai, assume_model_exists: true` (mecanismo que el propio gem provee para modelos self-hosted/custom). Los modelos conocidos (GPT, Claude, etc.) siguen su camino normal sin cambios.
- **`lib/llm/config.rb`** / **`lib/captain/base_task_service.rb`**: normalización para que `CAPTAIN_OPEN_AI_ENDPOINT` siempre termine en `/v1` (requisito del cliente OpenAI-compatible), sin importar si el admin lo escribe con o sin esa barra.
- **`enterprise/app/models/concerns/agentable.rb`**: el asistente automático de Captain (el que le responde solo a un cliente, sección 9.8) **no pasa** por `Captain::BaseTaskService` — usa el gem `ai-agents` (`Agents::Agent.new`), que hace sus propios llamados a `ruby_llm` de forma independiente. Sufre el mismo `RubyLLM::ModelNotFoundError`. El gem ya soporta `provider:`/`assume_model_exists:` nativamente, así que se los pasa (gateado con `ChatwootApp.self_hosted_enterprise?`, igual que el resto).

### 9.4 Migración de dimensión de embeddings — IMPORTANTE

Las columnas `article_embeddings.embedding`, `captain_assistant_responses.embedding` y `captain_faq_suggestions.embedding` estaban fijadas en Postgres como `vector(1536)` (dimensión de `text-embedding-3-small` de OpenAI). Los modelos de embeddings locales tienen otra dimensión (`nomic-embed-text` = 768), y ese mismatch rompía **la sugerencia de respuesta completa** (no solo la función separada de Documents/RAG como se pensó al principio) — la herramienta interna `search_documentation` que Captain usa para buscar respuestas pasadas parecidas tira `Neighbor::Error: Expected 1536 dimensions, not 768` en cualquier cuenta, incluso vacía.

Se agregó la migración `db/migrate/20260906130000_change_captain_embedding_dimension_to_768.rb`, que:
1. Vacía los embeddings existentes (eran de 1536 dims, incompatibles con 768).
2. Cambia las 3 columnas a `vector(768)`.
3. Recrea los índices `ivfflat`.

**Si se usa otro modelo de embeddings con otra dimensión**, hay que ajustar el `768` de esa migración (o escribir una nueva) para que coincida.

### 9.5 Configuración

```ruby
{
  'CAPTAIN_OPEN_AI_ENDPOINT' => 'http://172.19.0.1:11434',   # IP del gateway docker hacia el host — verificar la propia
  'CAPTAIN_OPEN_AI_API_KEY'  => 'ollama-local',                # dummy, Ollama no valida auth pero el código exige un valor no vacío
  'CAPTAIN_OPEN_AI_MODEL'    => 'qwen2.5:7b-instruct',
  'CAPTAIN_EMBEDDING_MODEL'  => 'nomic-embed-text',
}.each { |k, v| InstallationConfig.find_by(name: k).update!(value: v) }
GlobalConfig.clear_cache
```

También hace falta tener habilitada la feature `captain_tasks` en la cuenta (ya cubierto por `ACCOUNT_LEVEL_FEATURE_DEFAULTS`, sección 5).

### 9.6 Elegir modelo — qué anduvo y qué no

Probado empíricamente contra `Captain::ReplySuggestionService` (botón "Suggest a reply") y contra el asistente automático real (sección 9.8), con casos reales de soporte:

| Modelo | Resultado |
|---|---|
| `llama3.2:3b` (3B) | Responde y sigue el formato, pero calidad simple/genérica. |
| `llama3.1:8b` (8B) | Responde bien en `ReplySuggestionService` (tono correcto, en español). **Pero falla en el asistente automático**: al usar la herramienta `faq_lookup` arma mal los argumentos (`ArgumentError: missing keyword: :query`) — confunde el schema de la herramienta con el de su propia respuesta estructurada, y termina haciendo handoff. |
| `qwen2.5:7b-instruct` (7.6B) | **Elegido.** Maneja bien la combinación de tools + salida estructurada que usa el asistente automático — sin errores, sin handoff espurio. |
| `deepseek-coder-v2:16b` | **No sirve.** Es un modelo de código (`Capabilities: completion, insert`, sin `tools`), no de chat — ignoró el formato pedido y no puede usar function-calling. |

**Conclusión práctica**: para el botón simple de "Suggest a reply" casi cualquier modelo instruct chico anda. Para el **asistente automático** (usa tools + JSON schema estructurado a la vez) hace falta un modelo con mejor adherencia a function-calling — `qwen2.5:7b-instruct` fue el primero que probamos que lo maneja bien; puede haber otros igual de buenos o mejores.

Para probar otro modelo de chat, alcanza con:
```bash
ollama pull <modelo>
```
```ruby
InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_MODEL').update!(value: '<modelo>')
GlobalConfig.clear_cache
```
Sin tocar código. Preferir modelos con capability `tools` en `ollama show <modelo>` (necesario para que el asistente pueda usar acciones como agregar nota, poner etiqueta, hacer handoff) — es necesario pero no garantiza que arme bien los argumentos de la herramienta, como vimos con `llama3.1:8b`.

### 9.7 Expectativas de calidad

Los modelos locales chicos (3B–8B) responden notablemente más simple que GPT-4.1/5.x, sobre todo en tareas que requieren seguir instrucciones complejas (resúmenes estructurados, function-calling con schema, etc.). Si el hardware da para más, modelos de 30B+ mejoran bastante la calidad a costa de más RAM/tiempo de respuesta.

### 9.8 Activar la respuesta automática a clientes (Captain Assistant)

El botón "Suggest a reply" del compose box (agent-assist) y la **respuesta automática a un cliente** son dos cosas distintas. Para lo segundo:

1. Dashboard → Captain → Assistants → crear un Assistant (nombre + descripción son obligatorios).
2. Desde la página del Assistant, ir a la sección de Inboxes y asignarlo al inbox deseado (API: `POST /captain/assistants/:id/inboxes`, tabla `captain_inboxes`, un assistant por inbox).
3. **La conversación tiene que estar en estado `pending`** (sin asignar) para que Captain la atienda — si ya tiene un agente asignado o está `open`, Captain no interviene (mismo criterio que un Agent Bot). Conversaciones nuevas entrantes, sin reglas de auto-asignación, arrancan en `pending` por default.
4. El procesamiento es 100% asíncrono (`Captain::Conversation::ResponseBuilderJob` vía Sidekiq) — no pasa por Puma/rack-timeout, así que no importa cuánto tarde Ollama.

Si Captain responde "Transferring to another agent for further assistance." en vez de contestar, mirar los logs de `sidekiq` (`docker compose logs sidekiq`) buscando `[Captain V2] Agent result` — el campo `error` te dice la causa real (`RubyLLM::ModelNotFoundError` = falta el fix de 9.3, `ArgumentError` = el modelo no maneja bien function-calling, ver 9.6).

### 9.9 Timeout de requests HTTP (solo afecta al botón "Suggest a reply", no al asistente automático)

`rack-timeout` corta cualquier request HTTP a los **15 segundos por default** (`RACK_TIMEOUT_SERVICE_TIMEOUT`). Un modelo local en CPU puede tardar más que eso, lo que mataba silenciosamente el botón "Suggest a reply" (HTTP 500 a los 15s, mientras el service en sí funcionaba bien). Se subió a 120s en `.env` (viene en `.env.example`):

```
RACK_TIMEOUT_SERVICE_TIMEOUT=120
```

Esto **no afecta** al asistente automático de la sección 9.8, que corre en Sidekiq (sin límite de tiempo por este middleware).

## 10. Telemetría deshabilitada

Por defecto, Chatwoot pinguea diariamente `hub.2.chatwoot.com` con métricas de la instalación, y relaya push notifications móviles a través del mismo hub. Se desactivó:

- `config/schedule.yml`: comentada la entrada `internal_check_new_versions_job` (el cron que dispara el ping diario). `sidekiq-cron` limpia automáticamente el job de Redis al no encontrarlo en el YAML tras un restart de `sidekiq`.
- `ENABLE_PUSH_RELAY_SERVER=false` en `docker-compose.yml` (anclado para `rails`, `sidekiq` y `setup`).
- El onboarding ya no envía nombre, empresa ni email al hub de Chatwoot (se quitó el checkbox y la llamada `ChatwootHub.register_instance`).

**No tocado**: el registro único al hub durante el onboarding inicial (`installation/onboarding_controller.rb`), por ser un evento único no recurrente.

## 11. Control de versiones

Repo git propio, sin remote hacia ningún otro repo, pusheado a `martinezruben/ormichat` (privado en GitHub).

`.gitignore` excluye: `.env`, `node_modules`, `public/vite|packs|assets` (artefactos de build), gemas, logs, tmp.

El repo es privado: contiene el módulo `enterprise/` y configuración de despliegue.

## 12. Troubleshooting

**"No veo mi cambio de código"** → el código va dentro de la imagen: hay que reconstruirla con `docker compose up -d --build` (sección 4).

**"No veo mi cambio de frontend después de rebuildear"** → hard refresh en el navegador (Ctrl+Shift+R) o probar en incógnito — Chatwoot tiene un service worker (PWA) que cachea assets agresivamente.

**"Los mensajes de Telegram no llegan"** → ver sección 8. Chequear `getWebhookInfo` de la API de Telegram; si `url` está vacío, `FRONTEND_URL` no es una URL HTTPS pública válida.

**"Captain tira `Neighbor::Error: Expected 1536 dimensions, not 768`"** → falta correr la migración de la sección 9.4, o se cambió el modelo de embeddings sin ajustar la dimensión de las columnas.

**"Error `RubyLLM::ModelNotFoundError`"** → el modelo configurado en `CAPTAIN_OPEN_AI_MODEL`/`CAPTAIN_EMBEDDING_MODEL` no existe en Ollama (`ollama pull <modelo>` primero) o el parche de la sección 9.3 no está aplicado en ese archivo (verificar que la imagen se haya reconstruido tras el cambio). Si el error aparece específicamente en el **asistente automático** (`[Captain V2] Agent result: ... error=#<RubyLLM::ModelNotFoundError...`) y no en el botón de sugerencia, revisar que el parche de `enterprise/app/models/concerns/agentable.rb` (sección 9.3) esté aplicado — es una ruta de código separada.

**"El botón 'Suggest a reply' no responde nada (sin error visible)"** → ver sección 9.9. `rack-timeout` corta el request a los 15s por default; confirmar `RACK_TIMEOUT_SERVICE_TIMEOUT=120` en `.env`, y confirmar en `docker compose logs rails` si aparece `source=rack-timeout ... state=timed_out`.

**"El asistente responde 'Transferring to another agent for further assistance.' en vez de contestar"** → eso es un handoff automático, no un bug de configuración en sí. Ver sección 9.8: revisar `docker compose logs sidekiq` buscando `[Captain V2] Agent result` para ver el `error` real detrás del handoff (`ModelNotFoundError`, `ArgumentError` de function-calling, etc.) — también puede pasar simplemente porque la conversación no estaba en estado `pending`.
