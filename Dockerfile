# syntax = docker/dockerfile:1

# Base image com versão configurável do Ruby
ARG RUBY_VERSION=3.1.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Diretório de trabalho da aplicação
WORKDIR /rails

# Instalar pacotes básicos necessários para runtime
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Configurações de ambiente para o Rails
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Estágio de build para reduzir o tamanho final da imagem
FROM base AS build

# Instalar pacotes necessários para compilar gems e assets
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    pkg-config \
    libsqlite3-dev && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install --no-install-recommends -y \
    nodejs \
    yarn && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copiar arquivos de dependência para o build
COPY Gemfile Gemfile.lock ./

# Atualizar sistema de gems e instalar gems necessárias
RUN gem update --system && \
    gem install bundler && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copiar o código da aplicação
COPY . .

# Pré-compilar o código do Bootsnap para melhorar tempos de boot
RUN bundle exec bootsnap precompile app/ lib/

# Pré-compilar os assets de produção
RUN SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bundle exec rails assets:precompile || \
    (cat log/production.log && exit 1)

# Estágio final para criar a imagem de produção
FROM base

# Copiar os artefatos do build: gems e código da aplicação
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Criar e usar um usuário não-root para segurança
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Script de entrada para preparar o banco de dados
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expor a porta padrão do servidor Rails
EXPOSE 3000

# Comando padrão para iniciar o servidor
CMD ["./bin/rails", "server"]
