Rails.application.routes.draw do
  get '/health', to: 'health#show'

  # Auth0 routes
  get "/auth/oauth2/callback" => "auth0#callback", as: 'auth0_callback'
  get "/auth/failure" => "auth0#failure"

  get '/signup_not_allowed' => 'user_sessions#signup_not_allowed', as: 'signup_not_allowed'
  get '/signup_error/:error_type' => 'user_sessions#signup_error', as: 'signup_error'
  resource :user_session, only: [:destroy]

  if Rails.env.development?
    post '/auth/developer/callback' => 'auth0#developer_callback'
  end

  resources :services, only: [:index, :edit, :update, :create] do
    member do
      resources :pages, param: :page_url, only: [:create, :edit, :update]
      resources :settings, only: [:index] do
        collection do
          get 'form_information'
          patch 'update_form_information'
        end
      end
    end
    mount MetadataPresenter::Engine => '/preview', as: :preview
  end

  root to: 'services#index'
end
