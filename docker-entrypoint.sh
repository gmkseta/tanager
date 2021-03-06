#!/bin/sh
set -e

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

bundle exec bundle install
bundle exec rails db:migrate

bundle exec puma -C config/docker_puma.rb -p 3000

exec "$@"
