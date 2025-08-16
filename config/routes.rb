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
    
    # Campaign Management
    resources :providers
    resources :templates
    resources :schedules do
      member do
        post :materialize
        post :send_now
        post :test_send
        post :pause
        post :resume
      end
    end
    
    # Messages and Events (Logs)
    resources :messages, only: [:index, :show]
    resources :message_events, only: [:index, :show]
    
    # Contact Management
    resources :lists do
      resources :contact_list_memberships, only: [:create, :destroy]
    end
    
    resources :contact_list_memberships, only: [:destroy] do
      collection do
        post :bulk_add
        post :bulk_update
      end
    end
    
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
  
  # Webhook endpoints
  namespace :webhooks do
    post 'brevo', to: 'brevo#receive'
    get 'brevo/test', to: 'brevo#test'
    get 'brevo/status', to: 'brevo#status'
  end
  
  # PWA routes
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Letter opener in development
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
