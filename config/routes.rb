Rails.application.routes.draw do
  get '/health', to: 'health#show'
  get '/metrics', to: 'metrics#show'

  # Auth0 routes
  get "/auth/auth0/callback" => "auth0#callback", as: 'auth0_callback'
  get "/auth/failure" => "auth0#failure"

  get '/signup_not_allowed' => 'user_sessions#signup_not_allowed', as: 'signup_not_allowed'
  get '/signup_error/:error_type' => 'user_sessions#signup_error', as: 'signup_error'
  resources :user_sessions, only: [:destroy]

  if Rails.env.development?
    post '/auth/developer/callback' => 'auth0#developer_callback'
  end

  resources :services, only: [:index, :edit, :update, :create] do
    member do
      resources :publish, only: [:index, :create]
      resources :pages, param: :page_uuid, only: [:create, :edit, :update, :destroy]

      resources :settings, only: [:index]
      namespace :settings do
        resources :form_information, only: [:index, :create]

        resources :submission, only: [:index] do
          collection do
            resources :email, only: [:index, :create]
          end
        end
      end

      mount MetadataPresenter::Engine => '/preview', as: :preview
    end
  end

  root to: 'home#show'
end
