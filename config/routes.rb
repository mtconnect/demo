IMTS::Application.routes.draw do
  resources :devices do
    member do
      get :update_hmi
      get :update_alarms
      get :update_activity
    end
  end
  resources :apps do
    resources :app_pictures, :only => [:index, :destroy]
  end
  get "login", :to => "sessions#new"
  post "login", :to => "sessions#create"
  get "logout", :to => "sessions#destroy"
  root :to => "devices#index"
end
