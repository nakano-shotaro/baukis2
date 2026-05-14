Rails.application.configure do 
  #config.hosts.clear   # 開発中はこれを有効に（全部許可）
  # 共通で許可したいホスト
  config.hosts << "localhost" 
  config.hosts << "127.0.0.1"
  config.hosts << "0.0.0.0"
  config.hosts << "example.com" 
  config.hosts << "baukis2.example.com" 
  #config.hosts = nil 

  # 開発環境のみすべて許可
  if Rails.env.development?
    config.hosts.clear
    #config.hosts = nil
  end
end     