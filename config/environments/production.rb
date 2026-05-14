require "active_support/core_ext/integer/time"

Rails.application.configure do
  # 本番環境の基本設定
  config.enable_reloading = false
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.assets.compile = false 

  # ==================== アセット関連（ここに追加）====================
  # 圧縮を無効化（Tailwindや独自CSSで問題が出やすい場合）
  config.assets.css_compressor = nil
  # config.assets.js_compressor = :terser   # terser gemを入れている場合は有効化推奨

  # アセットのバージョン（キャッシュバスティング）
  config.assets.version = "1.0"   # デプロイで反映されない時は "1.1" に上げる

  config.active_storage.service = :local

  # SSL設定（Caddyなどリバースプロキシ使用時）
  config.assume_ssl = true
  config.force_ssl = true 
  config.ssl_options = {
    redirect: {
      exclude: ->(request) {
        request.host.in?(['localhost', '127.0.0.1', '0.0.0.0', '[::1]']) ||
        request.path == "/up" ||
        request.path.start_with?("/assets")
      }
    }
  }

  # Logging
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false

  # ==================== Host Authorization（本番環境用）====================
  # 本番で許可するホスト
  config.hosts = [
    "web",                       # Dockerコンテナ名（Caddyからアクセス用）
    "example.com",               # ← 本番ドメイン決まったらここに追加
    "baukis2.example.com"
    # /\A.*\.example\.com\z/     # 将来サブドメインを使う場合
  ]
  ### 本番ドメインが決まったら、example.com と baukis2.example.com の部分を実際のドメインに置き換えてください。

  # ヘルスチェックや内部アクセスをHost Authorizationの対象から除外
  config.host_authorization = {
    exclude: ->(request) {
      request.path == "/up" ||
      request.host.in?(['localhost', '127.0.0.1', '0.0.0.0', 'web'])
    }
  }
end