Rails.application.configure do 
  config.hosts << "localhost" 
  config.hosts << "127.0.0.1"
  config.hosts << "0.0.0.0"
  config.hosts << "example.com" 
  config.hosts << "baukis2.example.com" 
  #config.hosts = nil 
end     