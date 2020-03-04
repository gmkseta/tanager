#!/bin/sh
set -e

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

bundle exec rails db:create db:migrate

if [ "$RAILS_ENV" = "production" ]; then
  echo 'cleaning cache'
  rm -rf node_modules yarn-offline-cache && yarn cache clean
  echo 'updating checksums'
  yarn --update-checksums
  echo 'precompiling assets'
  bundle exec rails assets:precompile
fi

bundle exec puma -C config/docker_puma.rb -p 3000

exec "$@"
