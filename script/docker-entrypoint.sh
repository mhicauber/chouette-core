#!/bin/sh

command=${1:-front}

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "Start $command"
case $command in
  async)
    mkdir -p tmp/pids
    exec bundle exec sidekiq -e production
    ;;
  sync)
    exec bash launch-cron
    ;;
  front)
    if [ "$CHOUETTE_MIGRATE" = "true" ]; then
      bundle exec rake db:migrate db:seed || exit $?
    fi
    exec bundle exec rails server -b 0.0.0.0
    ;;
  shell)
    exec bash
    ;;
  console)
    exec bundle exec rails console production
    ;;
esac
