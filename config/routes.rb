Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"

  get "forms/new" => "forms/change_name#new", as: :new_form
  post "forms/new" => "forms/change_name#create"
  resources :forms, only: %i[show]
  get "forms/:id/change-name" => "forms/change_name#edit", as: :change_form_name
  post "forms/:id/change-name" => "forms/change_name#update"
  get "forms/:id/change-email" => "forms/change_email#new", as: :change_form_email
  post "forms/:id/change-email" => "forms/change_email#create"
  get "forms/:form_id/delete" => "forms/delete_confirmation#delete", as: :delete_form
  delete "forms/:form_id/delete" => "forms/delete_confirmation#destroy", as: :destroy_form

  # Page routes
  get "forms/:form_id/pages" => "pages#index", as: :pages
  get "forms/:form_id/pages/:page_id/edit" => "pages#edit", as: :edit_page
  patch "forms/:form_id/pages/:page_id/edit" => "pages#update", as: :update_page
  get "forms/:form_id/pages/new" => "pages#new", as: :new_page
  post "forms/:form_id/pages/new" => "pages#create", as: :create_page
  get "forms/:form_id/pages/:page_id/delete" => "forms/delete_confirmation#delete", as: :delete_page
  delete "forms/:form_id/pages/:page_id/delete" => "forms/delete_confirmation#destroy", as: :destroy_page
end
