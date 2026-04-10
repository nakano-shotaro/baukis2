#!/bin/sh
set -e

# server.pid が残っていたら削除
rm -f /baukis2/tmp/pids/server.pid

echo "Waiting for postgres..."

# Postgres待機（既存のまま）
until PGPASSWORD=password psql -h db -U postgres -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "Postgres is up!"

# === ここから追加・変更 ===
echo "=== Dart Sass をビルドしています ==="
bundle exec rails dartsass:build
echo "=== Dart Sass ビルド完了 ==="

# Rails server起動時のみ db:prepare を実行（既存の処理はそのまま）
if [ "$1" = "rails" ] && [ "$2" = "server" ] || [ "$1" = "./bin/rails" ] && [ "$2" = "server" ]; then
  echo "=== データベースを準備しています（create or migrate）==="
  bundle exec rails db:prepare
  echo "=== データベース準備完了 ==="
fi

# 元のコマンドを実行
exec "$@"