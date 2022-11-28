Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get :ping, controller: :heartbeat

  # Defines the root path route ("/")
  root "home#index"

  get "forms/new" => "forms/change_name#new", as: :new_form
  post "forms/new" => "forms/change_name#create"

  scope "forms/:form_id" do
    get "/" => "forms#show", as: :form
    get "/change-name" => "forms/change_name#edit", as: :change_form_name
    post "/change-name" => "forms/change_name#update"
    get "/change-email" => "forms/change_email#new", as: :change_form_email
    post "/change-email" => "forms/change_email#create"

    get "/submission-email" => "forms/submission_email#new", as: :submission_email_form
    post "/submission-email" => "forms/submission_email#create"
    get "/confirm-submission-email" => "forms/submission_email#submission_email_code", as: :submission_email_code
    post "/confirm-submission-email" => "forms/submission_email#confirm_submission_email_code", as: :confirm_submission_email_code
    get "/submission-email-confirmed" => "forms/submission_email#submission_email_confirmed", as: :submission_email_confirmed
    get "/email-code-sent" => "forms/submission_email#submission_email_code_sent", as: :submission_email_code_sent

    get "/delete" => "forms/delete_confirmation#delete", as: :delete_form
    delete "/delete" => "forms/delete_confirmation#destroy", as: :destroy_form
    get "/privacy-policy" => "forms/privacy_policy#new", as: :privacy_policy
    post "/privacy-policy" => "forms/privacy_policy#create"
    get "/make-live" => "forms/make_live#new", as: :make_live
    post "/make-live" => "forms/make_live#create", as: :make_live_create
    get "/live-confirmation" => "forms/make_live#confirmation", as: :live_confirmation
    get "/what-happens-next" => "forms/what_happens_next#new", as: :what_happens_next
    post "/what-happens-next" => "forms/what_happens_next#create", as: :what_happens_next_create
    get "/contact-details" => "forms/contact_details#new", as: :contact_details
    post "/contact-details" => "forms/contact_details#create", as: :contact_details_create
    get "/declaration" => "forms/declaration#new", as: :declaration
    post "/declaration" => "forms/declaration#create", as: :declaration_create

    scope "/pages" do
      get "/" => "page_list#edit", as: :form_pages
      post "/" => "page_list#update"
      get "/:page_id/edit" => "pages#edit", as: :edit_page
      patch "/:page_id/edit" => "pages#update", as: :update_page
      post "/move-page" => "page_list#move_page", as: :move_page
      get "/new" => "pages#new", as: :new_page
      post "/new" => "pages#create", as: :create_page
      get "/:page_id/delete" => "forms/delete_confirmation#delete", as: :delete_page
      delete "/:page_id/delete" => "forms/delete_confirmation#destroy", as: :destroy_page
    end
  end

  # Page routes
  match "/403", to: "errors#forbidden", as: :error_403, via: :all
  match "/404", to: "errors#not_found", as: :error_404, via: :all
  match "/500", to: "errors#internal_server_error", as: :error_500, via: :all
end
