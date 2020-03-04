#!/bin/sh
set -e

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

bundle exec rails db:create db:migrate

if [ "$RAILS_ENV" = "production" ]; then
  echo 'precompiling assets'
  yarn cache clean
  rm -rf node_modules/ npm-packages-offline-cache
  yarn install --check-files
  bundle exec rails assets:precompile
fi

bundle exec puma -C config/docker_puma.rb -p 3000

exec "$@"
