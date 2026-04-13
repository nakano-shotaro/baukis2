# config/initializers/dartsass.rb
Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css",
  "staff/staff.scss" => "staff.css",      # これで staff.css が生成される
  "admin/admin.scss" => "admin.css",
  "customer/customer.scss" => "customer.css"
}