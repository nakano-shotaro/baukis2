
Rails.application.config.assets.css_compressor = nil
Rails.application.config.assets.js_compressor = nil

Rails.application.config.assets.version = "1.0" 
Rails.application.config.assets.precompile += %w[ 
  staff.css 
  admin.css 
  customer.css 
]

# config/initializers/assets.rb の末尾に追記
Rails.application.config.assets.paths << Rails.root.join("node_modules")
