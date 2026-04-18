#!/bin/sh
set -e

# server.pidの削除（Railsの再起動でよく使う）
rm -f /rails/tmp/pids/server.pid

echo "Waiting for postgres..."

# 改良版：pg_isready + 実際の接続テストを組み合わせ（より確実）
# DATABASE_xxx 環境変数を使う（composeで渡しているもの）
until PGPASSWORD="${DATABASE_PASSWORD:-password}" psql -h "${DATABASE_HOST:-db}" -U "${DATABASE_USER:-postgres}" -d "${DATABASE_NAME:-baukis2_development}" -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 2   # ← sleep 1 から 2 に変更（ログが多すぎないように）
done

echo "Postgres is up and ready!"

# ====================== Rails起動処理 ======================
if [ "$RAILS_ENV" = "production" ]; then
  echo "=== 本番モード起動 ==="
  bundle exec rails db:prepare
else
  echo "=== 開発モード起動 ==="
  bundle exec rails db:prepare
  # 開発時は dartsass を即時ビルド
  bundle exec rails dartsass:build
fi

# 最後に元のコマンドを実行（./bin/dev など）
exec "$@"

