Rails.application.routes.draw do
  devise_for :users
  
  # Public routes
  root 'pages#home'
  get 'services', to: 'pages#services'
  get 'contact', to: 'pages#contact'
  get 'dashboard', to: 'dashboard#index'
  
  # Admin routes
  namespace :admin do
    root 'dashboard#index'
    
    resources :contacts do
      collection do
        get :export
      end
    end
    
    resources :imports, except: [:edit, :update] do
      member do
        get :mapping
        post :preview
        post :perform
        get :status
        get :download_errors
        get :download_processed
      end
    end
    
    resources :users, only: [:index, :show, :edit, :update, :destroy] do
      member do
        post :invite
      end
    end
  end

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
  
  # PWA routes
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Letter opener in development
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
