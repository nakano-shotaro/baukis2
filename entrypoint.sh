#!/bin/sh
set -e

rm -f /rails/tmp/pids/server.pid

echo "Waiting for postgres..."
until PGPASSWORD=password psql -h db -U postgres -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done
echo "Postgres is up!"

if [ "$RAILS_ENV" = "production" ]; then
  echo "=== 本番モード起動 ==="
  bundle exec rails db:prepare
else
  echo "=== 開発モード起動 ==="
  bundle exec rails db:prepare
  # 開発時は dartsass を即時ビルド（watchは bin/dev でやる）
  bundle exec rails dartsass:build
fi

exec "$@"

