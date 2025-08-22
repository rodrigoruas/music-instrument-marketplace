Rails.application.routes.draw do
  devise_for :users
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#index"
  
  # Public instrument routes
  resources :instruments, only: [:index, :show] do
    member do
      get :availability
    end
    collection do
      get :search
    end
  end
  
  # Rental routes (requires authentication)
  resources :rentals, only: [:index, :show, :new, :create] do
    member do
      post :confirm
      post :cancel
      get :payment
      post :process_payment
    end
    resources :reviews, only: [:new, :create]
  end
  
  # Owner namespace
  namespace :owner do
    get "dashboard", to: "dashboard#index"
    resources :instruments do
      member do
        patch :toggle_availability
      end
    end
    resources :rentals, only: [:index, :show] do
      member do
        post :approve
        post :reject
        post :complete
      end
    end
    resources :analytics, only: [:index]
  end
  
  # User profile routes
  resources :users, only: [:show] do
    member do
      get :reviews
      get :instruments
    end
  end
  
  # API routes for Turbo Streams
  namespace :api do
    namespace :v1 do
      resources :instruments, only: [] do
        member do
          get :price_calculation
        end
      end
    end
  end
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  
  # PWA routes (optional)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end