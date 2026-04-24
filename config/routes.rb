Rails.application.routes.draw do 
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  config = Rails.application.config.baukis2

  constraints host: config[:staff][:host] do  
     namespace :staff, path: config[:staff][:path]  do    
      root "top#index" 
      get "login" => "sessions#new", as: :login
      resource :session, only: [ :create, :destroy ] 
      resource :account, except: [ :new, :create, :destroy ]  
    end 
  end   
  
  constraints host: config[:admin][:host] do 
    namespace :admin, path: config[:admin][:path] do  
      root "top#index" 
      get "login" => "sessions#new", as: :login 
      resource :session, only: [ :create, :destroy ] 
      resources :staff_members 
    end 
  end    
  
  constraints host: config[:customer][:host] do 
    namespace :customer, path: config[:customer][:path] do 
      root "top#index"
    end 
  end   
  
  get "up", to: "rails/health#show"   # ヘルスチェック用（Caddyがたまに叩く） 
end
