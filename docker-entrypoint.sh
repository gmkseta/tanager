#!/bin/sh
set -e

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

bundle exec db:migrate
bundle exec bundle update

bundle exec puma -C config/docker_puma.rb -p 3000

exec "$@"
