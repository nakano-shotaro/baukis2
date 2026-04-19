Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index" 

  namespace :staff do 
    root "top#index" 
    get "login" => "sessions#new", as: :login
    post "session" => "sessions#create", as: :session 
    delete "session" => "sessions#destroy"
  end 
  
  namespace :admin do 
    root "top#index" 
    get "login" => "sessions#new", as: :login 
    post "session" => "sessions#create", as: :session 
    delete "session" => "sessions#destroy" 
  end  

  namespace :customer do 
    root "top#index"
  end 
  
  get "up", to: "rails/health#show"   # ヘルスチェック用（Caddyがたまに叩く）
end
