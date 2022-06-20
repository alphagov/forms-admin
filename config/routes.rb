Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"

  resources :forms, only: %i[new create show edit update destroy]
  get "forms/:id/change-name" => "forms/change_name#new", as: :change_form_name
  post "forms/:id/change-name" => "forms/change_name#create"

  # Page routes
  get "forms/:form_id/pages" => "pages#index", as: :pages
  get "forms/:form_id/pages/:page_id/edit" => "pages#edit", as: :edit_page
  patch "forms/:form_id/pages/:page_id/edit" => "pages#update", as: :update_page
  get "forms/:form_id/pages/new" => "pages#new", as: :new_page
  post "forms/:form_id/pages/new" => "pages#create", as: :create_page

end
