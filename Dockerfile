# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.0.0
FROM ruby:$RUBY_VERSION-bullseye

WORKDIR /app

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_PATH=/bundle \
    BUNDLE_WITHOUT="development test"

# Install OS dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    curl \
    git \
    libvips \
    nodejs \
    yarn \
    postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Install Ruby Gems
COPY Gemfile Gemfile.lock ./
RUN gem sources --clear-all && \
    gem sources -a https://rubygems.org && \
    bundle install --verbose

# Copy application
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile && \
    bundle exec bootsnap precompile --gemfile app/ lib/

# Use non-root user
RUN adduser --disabled-password --gecos "" appuser && \
    chown -R appuser:appuser /app
USER appuser

EXPOSE 3000
CMD ["bash", "-c", "bundle exec rails db:migrate && bundle exec rails s -b 0.0.0.0"]
