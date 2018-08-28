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
    exec bundle exec rake db:migrate db:seed && bundle exec rails server -b 0.0.0.0
    ;;
esac
