# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# vendor/javascript/ 内のファイルを参照する設定
# === 他の画面で必要な jQuery 関連（安全なCDNから読み込みます） ===
pin "jquery", to: "https://jspm.io"
pin "jquery-ui", to: "https://cloudflare.com"

# === 今回導入する Tagify ===
pin "@yaireo/tagify", to: "@yaireo--tagify.js" # @4.38.0
