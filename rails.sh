#!/bin/sh
set -x

rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*


bundle install

bin/rails db:migrate


while ! nc -z rabbitmq 5672 ; do
    echo "Waiting for the rabbitmq Server"
    sleep 3
done

exec "$@"
