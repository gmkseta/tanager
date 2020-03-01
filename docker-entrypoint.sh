#!/bin/sh
set -e

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

bundle exec rails db:create db:migrate

if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rails assets:precompile
  if [ "$CRON_JOB" = "ENABLED" ]; then
    service cron start
  fi
fi

bundle exec puma -C config/docker_puma.rb -p 3000

exec "$@"
