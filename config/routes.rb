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
  get "forms/:id/contact-details" => "forms/contact_details#new", as: :contact_details
  post "forms/:id/contact-details" => "forms/contact_details#create", as: :contact_details_create

  # Page routes
  scope "forms/:form_id/pages" do
    get "/" => "pages#index", as: :form_pages
    get "/:page_id/edit" => "pages#edit", as: :edit_page
    patch "/:page_id/edit" => "pages#update", as: :update_page
    get "/new" => "pages#new", as: :new_page
    post "/new" => "pages#create", as: :create_page
    get "/:page_id/delete" => "forms/delete_confirmation#delete", as: :delete_page
    delete "/:page_id/delete" => "forms/delete_confirmation#destroy", as: :destroy_page
  end
  match "/404", to: "errors#not_found", as: :error_404, via: :all
  match "/500", to: "errors#internal_server_error", as: :error_500, via: :all

  match "*path", to: "errors#not_found", via: :all
end
