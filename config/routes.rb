Rails.application.routes.draw do
  get '/health', to: 'health#show'

  resources :services, only: :index do
    mount MetadataPresenter::Engine => '/preview', as: :preview
  end
end
