Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get :ping, controller: :heartbeat

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
  get "forms/:id/privacy_policy" => "forms/privacy_policy#new", as: :privacy_policy
  post "forms/:id/privacy_policy" => "forms/privacy_policy#create"
  get "forms/:id/make_live" => "forms/make_live#new", as: :make_live
  post "forms/:id/make_live" => "forms/make_live#create", as: :make_live_create
  get "forms/:id/live_confirmation" => "forms/make_live#confirmation", as: :live_confirmation
  get "forms/:id/what-happens-next" => "forms/what_happens_next#new", as: :what_happens_next
  post "forms/:id/what-happens-next" => "forms/what_happens_next#create", as: :what_happens_next_create

  # Page routes
  get "forms/:form_id/pages" => "pages#index", as: :form_pages
  get "forms/:form_id/pages/:page_id/edit" => "pages#edit", as: :edit_page
  patch "forms/:form_id/pages/:page_id/edit" => "pages#update", as: :update_page
  get "forms/:form_id/pages/new" => "pages#new", as: :new_page
  post "forms/:form_id/pages/new" => "pages#create", as: :create_page
  get "forms/:form_id/pages/:page_id/delete" => "forms/delete_confirmation#delete", as: :delete_page
  delete "forms/:form_id/pages/:page_id/delete" => "forms/delete_confirmation#destroy", as: :destroy_page

  match "/404", to: "errors#not_found", as: :error_404, via: :all
  match "/500", to: "errors#internal_server_error", as: :error_500, via: :all

  match "*path", to: "errors#not_found", via: :all
end
