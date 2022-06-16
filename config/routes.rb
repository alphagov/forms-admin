Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"

  resources :forms, only: %i[new create show edit update destroy] do
    resources :pages, only: %i[new create index edit update]
  end
end
