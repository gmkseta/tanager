#!/bin/sh
set -e

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

bundle exec rails db:create db:migrate

if [ "$RAILS_ENV" = "production" ]; then
  echo 'precompiling assets'
  bundle exec rails assets:precompile
else
  echo 'webpacker install'
  bundle exec rails webpacker:install
fi

bundle exec puma -C config/docker_puma.rb -p 3000

exec "$@"
