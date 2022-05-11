Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"

  get "/form/new", to: "forms#new"
  post "/form/new", to: "forms#create"
end
