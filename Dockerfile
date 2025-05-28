# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.0.0
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /app

# Set environment for production
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_PATH=/bundle \
    BUNDLE_WITHOUT="development test"

# Install essential build tools and libraries
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

# Install Gems
COPY Gemfile Gemfile.lock ./
RUN gem update --system && \
    bundle install --jobs 4 --retry 3

# Copy rest of the app
COPY . .

# Precompile assets & bootsnap cache
RUN bundle exec rake assets:precompile && \
    bundle exec bootsnap precompile --gemfile app/ lib/

# Use a non-root user for security
RUN adduser --disabled-password --gecos "" appuser && \
    chown -R appuser:appuser /app
USER appuser

EXPOSE 3000

# Run database migrations and then start the server
CMD ["bash", "-c", "bundle exec rails db:migrate && bundle exec rails s -b 0.0.0.0"]
