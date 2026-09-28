# Ormichat 🚀

**Ormichat** is an independent fork of **Chatwoot 4.17.1**, an open-source customer engagement platform with AI capabilities. It's a production-ready, self-hosted alternative to Intercom/Zendesk with local LLM support via Ollama.

> [Architecture Diagram](#architecture) • [Database Schema](#database-schema) • [Quick Start](#quick-start) • [Documentation](#documentation)

---

## ✨ What's New

### shadcn/ui Design System
- **Neutral palette** (dark/light mode): Replaced Ormichat's indigo theme with shadcn/ui's neutral design
- **Geist typography**: Consistent font across all surfaces
- **Component styling**: Button, Input, Dialog, etc. with shadcn/ui look & feel
- **No extra dependencies**: achieved via Tailwind tokens only

### Features (vs. Chatwoot 4.17.1)
- ✅ **Custom "File" attribute type** — attach binaries, preview images, insert into messages
- ✅ **AI via local LLM** — Captain runs on Hermes/Ollama (not OpenAI)
- ✅ **Contact panel** — city/country, location links, custom attributes formatting
- ✅ **Automation-only labels** — invisible to agents, visible to automations
- ✅ **Custom roles & sidebar visibility** — control menu item visibility per role
- ✅ **SMTP config in UI** — Settings > Security > Mailer (editable test email)
- ✅ **Spanish translations** — Full i18n for dashboard, Captain, campaigns, reports
- ✅ **Branding overrides** — Rebranded to "Ormichat", stripped Chatwoot/chwt.app links

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Vue 3 + Composition API, Vite, TailwindCSS + shadcn/ui, Vitest, Playwright |
| **Backend** | Rails 7.2, PostgreSQL (pgvector), Redis, Sidekiq, ActionCable |
| **Search** | OpenSearch (full-text conversations) |
| **Storage** | ActiveStorage (proxy-served files) |
| **AI** | Captain (Hermes/Ollama local LLM) |
| **Deployment** | Docker Compose (postgres, redis, rails, sidekiq) |
| **Infrastructure** | Telegram, Email (SMTP), Linear, Dyte webhooks |

---

## Architecture

![Architecture Diagram](https://claude.ai/code/artifact/ormichat-architecture)

**Key layers:**
1. **Frontend** — Dashboard (Vue), Widget (embeddable), Portal (help center), all with shadcn/ui theme
2. **API Gateway** — REST + ActionCable realtime
3. **Backend Services** — Rails + Captain AI
4. **Data Layer** — PostgreSQL, Redis, OpenSearch, ActiveStorage
5. **Integrations** — Telegram, Email, external APIs, Ollama

---

## Database Schema

```
Accounts (multi-tenant root)
├─ Inboxes (channels: email, telegram, widget, etc.)
├─ Contacts (widget visitors, email subscribers)
│  └─ CustomAttributes (file type, location, address)
├─ Conversations (1:1 threads per contact)
│  ├─ Messages (agent/visitor messages)
│  └─ Labels (selectable: true/false for automation-only)
├─ Agents (team members)
├─ AgentBots (automation players)
├─ AutomationRules (label/assign triggers)
└─ Campaigns (broadcasts, sequences)

Custom Extensions:
├─ CustomAttributeDefinition.attribute_type = 'file'
├─ CustomAttribute.value = signed URL (ActiveStorage proxy)
├─ Label.selectable = false (hides from agent UI)
└─ CustomRole.visible_menu_items (sidebar control)
```

---

## Quick Start

### Prerequisites
- Docker + Docker Compose
- Ruby 3.4.4 (for local dev)
- Node.js 18+
- PostgreSQL 14+ (if not Docker)
- Redis 6+ (if not Docker)
- Ollama (for Captain AI)

### Using Docker Compose (Recommended)
```bash
git clone https://github.com/martinezruben/ormichat.git
cd ormichat

# Configure
cp .env.example .env  # edit as needed
export FRONTEND_URL=http://localhost:3000

# Start stack
docker compose up -d

# Seed data
docker exec ormichat-rails-1 bundle exec rails db:chatwoot_prepare

# Visit http://localhost:3000
```

### Local Development
```bash
# Setup
rbenv install $(cat .ruby-version)  # Ruby 3.4.4
eval "$(rbenv init -)"
bundle install
pnpm install

# Database
bundle exec rails db:chatwoot_prepare

# Compile frontend
pnpm dev  # or `overmind start -f Procfile.dev`

# Tests
pnpm test                               # JS/Vue
bundle exec rspec spec/path_spec.rb    # Ruby
```

### Captain AI (Ollama)
```bash
# Start Ollama (macOS/Linux/Docker)
ollama serve

# Pull Hermes in another terminal
ollama pull hermes

# Configure in Ormichat Settings → Captain
# Endpoint: http://localhost:11434
# Model: hermes
```

---

## Documentation

| Document | Purpose |
|----------|---------|
| **AGENTS.md** | Code style, i18n, PR flow, enterprise patterns |
| **INSTALL.md** | Docker setup, Captain config, webhooks, troubleshooting |
| **Context.md** | Project overview, repo structure, customizations |

## Key Files

- `app/javascript/dashboard/` — Main agent dashboard (Vue 3)
- `app/models/` — Rails models (Account, Conversation, Contact, etc.)
- `app/services/` — Business logic (Captain, Automation, Webhooks)
- `enterprise/` — Enterprise feature overlay
- `lib/captain/` — Captain AI integration
- `config/` — Routes, database, initializers
- `theme/` — Tailwind tokens, Geist fonts

---

## Development Commands

```bash
# Linting & formatting
bundle exec rubocop -a                  # Ruby style
pnpm eslint:fix                         # JS/Vue style

# Testing
pnpm test                               # JS watch mode
pnpm test:watch                         # JS watch mode
bundle exec rspec                       # Ruby tests
bundle exec rspec spec/path:LINE        # Single test

# Servers
overmind start -f Procfile.dev          # All services (recommended)
bundle exec rails s                     # Rails only
pnpm vite                               # Frontend only
```

---

## Features by Module

### Conversations
- ✅ Multi-channel (Telegram, email, widget, SMS, API, etc.)
- ✅ Real-time via ActionCable
- ✅ Full-text search (OpenSearch)
- ✅ Selective labels (automation-only visibility)
- ✅ Canned responses, templates

### Contacts & Custom Attributes
- ✅ **File type** custom attributes (images, docs, binaries)
- ✅ City/country with location links
- ✅ Address fields
- ✅ Date/checkbox formatting in panel
- ✅ Contact history, activity timeline

### AI & Automations
- ✅ Captain (local Hermes/Ollama)
- ✅ Auto-assign via rules
- ✅ Auto-label
- ✅ Sequences & campaigns
- ✅ Conversation classification

### Security & Config
- ✅ Custom roles with sidebar visibility control
- ✅ SMTP config from UI (no restart)
- ✅ Audit logs
- ✅ Two-factor auth (Devise)
- ✅ API tokens with scopes

---

## Deployment Notes

### Environment Variables
```bash
FRONTEND_URL=https://yourdomain.com
RAILS_ENV=production
SECRET_KEY_BASE=<generate with bundle exec rails secret>
REDIS_URL=redis://localhost:6379/0
DATABASE_URL=postgres://user:pass@host/db
OLLAMA_ENDPOINT=http://localhost:11434
SMTP_ADDRESS=smtp.provider.com
SMTP_PORT=587
SMTP_USERNAME=...
SMTP_PASSWORD=...
```

### Production Checklist
- [ ] TLS certificate (Let's Encrypt)
- [ ] PostgreSQL backups (daily)
- [ ] Redis persistence
- [ ] Sidekiq monitoring
- [ ] Ollama GPU config
- [ ] Email provider (SendGrid/AWS SES)
- [ ] CDN for assets (optional)

---

## Contributing

1. Read **AGENTS.md** for style & conventions
2. Branch: `git checkout -b feat/your-feature`
3. Test: `pnpm test && bundle exec rspec`
4. PR with description of what changed & how to test
5. Comply with RuboCop & ESLint

---

## License

Ormichat is a fork of Chatwoot (MIT). Ormichat-specific customizations are also MIT.

---

## Support

- 📖 [INSTALL.md](INSTALL.md) — Setup & troubleshooting
- 💬 [GitHub Discussions](https://github.com/martinezruben/ormichat/discussions)
- 🐛 [Issues](https://github.com/martinezruben/ormichat/issues)

---

**Created:** September 2024 · **Base:** Chatwoot 4.17.1 · **Theme:** shadcn/ui neutral palette
