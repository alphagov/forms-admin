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
      post "/move-page" => "page_list#move_page", as: :move_page

      scope "/new" do
        get "/type-of-answer" => "pages/type_of_answer#new", as: :type_of_answer_new
        post "/type-of-answer" => "pages/type_of_answer#create", as: :type_of_answer_create
        get "/text-settings" => "pages/text_settings#new", as: :text_settings_new
        post "/text-settings" => "pages/text_settings#create", as: :text_settings_create
        get "/date-settings" => "pages/date_settings#new", as: :date_settings_new
        post "/date-settings" => "pages/date_settings#create", as: :date_settings_create
        get "/selections-settings" => "pages/selections_settings#new", as: :selections_settings_new
        post "/selections-settings" => "pages/selections_settings#create", as: :selections_settings_create
        get "/address-settings" => "pages/address_settings#new", as: :address_settings_new
        post "/address-settings" => "pages/address_settings#create", as: :address_settings_create
        get "/" => "pages#new", as: :new_page
        post "/" => "pages#create", as: :create_page
      end

      scope "/:page_id" do
        scope "/edit" do
          get "/type-of-answer" => "pages/type_of_answer#edit", as: :type_of_answer_edit
          post "/type-of-answer" => "pages/type_of_answer#update", as: :type_of_answer_update
          get "/text-settings" => "pages/text_settings#edit", as: :text_settings_edit
          post "/text-settings" => "pages/text_settings#update", as: :text_settings_update
          get "/date-settings" => "pages/date_settings#edit", as: :date_settings_edit
          post "/date-settings" => "pages/date_settings#update", as: :date_settings_update
          get "/selections-settings" => "pages/selections_settings#edit", as: :selections_settings_edit
          post "/selections-settings" => "pages/selections_settings#update", as: :selections_settings_update
          get "/address-settings" => "pages/address_settings#edit", as: :address_settings_edit
          post "/address-settings" => "pages/address_settings#update", as: :address_settings_update
          get "/" => "pages#edit", as: :edit_page
          patch "/" => "pages#update", as: :update_page
        end

        scope "/delete" do
          get "/" => "forms/delete_confirmation#delete", as: :delete_page
          delete "/" => "forms/delete_confirmation#destroy", as: :destroy_page
        end
      end
    end
  end

  # Page routes
  match "/403", to: "errors#forbidden", as: :error_403, via: :all
  match "/404", to: "errors#not_found", as: :error_404, via: :all
  match "/500", to: "errors#internal_server_error", as: :error_500, via: :all
end
