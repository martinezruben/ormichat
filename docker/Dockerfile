# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.4.4
ARG NODE_VERSION=24.13.0

# --- Frontend: compila dashboard, widget, portal y SDK con Vite ---
FROM node:${NODE_VERSION}-bookworm-slim AS frontend
ENV RAILS_ENV=production
WORKDIR /app
RUN corepack enable
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build:sdk && pnpm exec vite build

# --- Gems y assets de Rails ---
FROM ruby:${RUBY_VERSION}-slim-bookworm AS builder
# execjs (uglifier) exige un runtime de JS al arrancar Rails
COPY --from=frontend /usr/local/bin/node /usr/local/bin/node
ENV RAILS_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/gems
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential git libpq-dev libyaml-dev libssl-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 && rm -rf /gems/ruby/*/cache
COPY . .
COPY --from=frontend /app/public ./public
RUN SECRET_KEY_BASE=precompile_placeholder VITE_RUBY_SKIP_ASSETS_PRECOMPILE_EXTENSION=true \
      bundle exec rake assets:precompile \
    && rm -rf spec node_modules tmp/cache log/*
ARG GIT_SHA=unknown
RUN echo "$GIT_SHA" > .git_sha

# --- Imagen final ---
FROM ruby:${RUBY_VERSION}-slim-bookworm
COPY --from=frontend /usr/local/bin/node /usr/local/bin/node
ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/gems \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    RUBY_YJIT_ENABLE=1
RUN apt-get update && apt-get install -y --no-install-recommends \
      libpq5 libyaml-0-2 libvips42 imagemagick postgresql-client curl tzdata ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 1000 ormichat
WORKDIR /app
COPY --from=builder --chown=ormichat:ormichat /gems /gems
COPY --from=builder --chown=ormichat:ormichat /app /app
RUN mkdir -p log tmp/pids tmp/cache storage && chown -R ormichat:ormichat log tmp storage
USER ormichat
EXPOSE 3000
ENTRYPOINT ["docker/entrypoints/rails.sh"]
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "3000"]
