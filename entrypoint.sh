#!/bin/sh
set -e

rm -f /baukis2/tmp/pids/server.pid

echo "Waiting for postgres..."
until PGPASSWORD=password psql -h db -U postgres -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done
echo "Postgres is up!"

if [ "$RAILS_ENV" = "production" ]; then
  echo "=== 本番モード起動 ==="

  # 本番用のDB接続設定
  export DATABASE_URL="postgresql://postgres:password@db:5432/baukis2_production?pool=5"

  # 初回のみ db:prepare を実行（2回目以降はスキップ）
  if [ ! -f /baukis2/tmp/db_prepared ]; then
    echo "=== データベースを準備しています（初回のみ）==="
    bundle exec rails db:prepare
    mkdir -p /baukis2/tmp
    touch /baukis2/tmp/db_prepared
    echo "=== データベース準備完了 ==="
  else
    echo "=== データベースは既に準備済みです ==="
  fi

else
  # 開発モード
  echo "=== 開発モード: Dart Sass をビルドしています ==="
  bundle exec rails dartsass:build
  echo "=== Dart Sass ビルド完了 ==="

  if [ "$1" = "rails" ] && [ "$2" = "server" ] || [ "$1" = "./bin/rails" ] && [ "$2" = "server" ]; then
    echo "=== データベースを準備しています ==="
    bundle exec rails db:prepare
    echo "=== データベース準備完了 ==="
  fi
fi

exec "$@"

