Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"

  resources :forms, only: %i[new create show edit update destroy]
  get "forms/:id/change-name" => "forms/change_name#new", as: :change_form_name
  post "forms/:id/change-name" => "forms/change_name#create"
end
