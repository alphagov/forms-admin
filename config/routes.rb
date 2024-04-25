Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "/up" => "rails/health#show", as: :rails_health_check

  # TODO: Remove once infrastructure has been updated to use /up
  get :ping, controller: :heartbeat

  root "forms#index"

  get "/sign-up" => "authentication#sign_up", as: :sign_up
  get "/sign-out" => "authentication#sign_out", as: :sign_out
  get "/sign-in" => "authentication#sign_in", as: :sign_in

  scope "auth/:provider" do
    match "/callback" => "authentication#callback_from_omniauth", via: %i[get post]
  end

  get "forms/new" => "forms/change_name#new", as: :new_form
  post "forms/new" => "forms/change_name#create"

  scope "forms/:form_id" do
    get "/" => "forms#show", as: :form
    get "/change-name" => "forms/change_name#edit", as: :change_form_name
    post "/change-name" => "forms/change_name#update"

    scope "/live" do
      get "/" => "forms/live#show_form", as: :live_form
      get "/pages" => "forms/live#show_pages", as: :live_form_pages
    end

    scope "/archived" do
      get "/" => "forms/archived#show_form", as: :archived_form
      get "/pages" => "forms/archived#show_pages", as: :archived_form_pages
    end

    get "/submission-email" => "forms/submission_email#new", as: :submission_email_input
    post "/submission-email" => "forms/submission_email#create"
    get "/confirm-submission-email" => "forms/submission_email#submission_email_code", as: :submission_email_code
    post "/confirm-submission-email" => "forms/submission_email#confirm_submission_email_code", as: :confirm_submission_email_code
    get "/submission-email-confirmed" => "forms/submission_email#submission_email_confirmed", as: :submission_email_confirmed
    get "/email-code-sent" => "forms/submission_email#submission_email_code_sent", as: :submission_email_code_sent

    get "/delete" => "forms/delete_confirmation#delete", as: :delete_form
    delete "/delete" => "forms/delete_confirmation#destroy", as: :destroy_form
    get "/archive" => "forms/archive_form#archive", as: :archive_form
    post "/archive" => "forms/archive_form#update", as: :archive_form_update
    get "/archive-success" => "forms/archive_form#confirmation", as: :archive_form_confirmation
    get "/privacy-policy" => "forms/privacy_policy#new", as: :privacy_policy
    post "/privacy-policy" => "forms/privacy_policy#create"
    get "/make-live" => "forms/make_live#new", as: :make_live
    post "/make-live" => "forms/make_live#create", as: :make_live_create
    get "/unarchive" => "forms/unarchive#new", as: :unarchive
    post "/unarchive" => "forms/unarchive#create", as: :unarchive_create
    get "/what-happens-next" => "forms/what_happens_next#new", as: :what_happens_next
    post "/what-happens-next" => "forms/what_happens_next#create", as: :what_happens_next_create
    post "/what-happens-next-preview" => "forms/what_happens_next#render_preview", as: :what_happens_next_render_preview
    get "/contact-details" => "forms/contact_details#new", as: :contact_details
    post "/contact-details" => "forms/contact_details#create", as: :contact_details_create
    get "/declaration" => "forms/declaration#new", as: :declaration
    post "/declaration" => "forms/declaration#create", as: :declaration_create
    get "/payment-link" => "forms/payment_link#new", as: :payment_link
    post "/payment-link" => "forms/payment_link#create", as: :payment_link_create

    scope "/pages" do
      get "/" => "pages#index", as: :form_pages
      post "/" => "forms#mark_pages_section_completed"
      post "/move-page" => "pages#move_page", as: :move_page

      scope "/new" do
        get "/start-new-question" => "pages#start_new_question", as: :start_new_question
        get "/guidance" => "pages/guidance#new", as: :guidance_new
        post "/guidance" => "pages/guidance#create", as: :guidance_create
        post "/guidance-preview" => "pages/guidance#render_preview", as: :guidance_render_preview
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
        get "/name-settings" => "pages/name_settings#new", as: :name_settings_new
        post "/name-settings" => "pages/name_settings#create", as: :name_settings_create
        get "/question_text" => "pages/question_text#new", as: :question_text_new
        post "/question_text" => "pages/question_text#create", as: :question_text_create
        get "/question" => "pages/questions#new", as: :new_question
        post "/question" => "pages/questions#create", as: :create_question
      end

      get "/new-condition" => "pages/conditions#routing_page", as: :routing_page
      post "/new-condition" => "pages/conditions#set_routing_page", as: :set_routing_page

      scope "/:page_id" do
        scope "/conditions" do
          get "/new" => "pages/conditions#new", as: :new_condition
          post "/new" => "pages/conditions#create", as: :create_condition
          get "/:condition_id" => "pages/conditions#edit", as: :edit_condition
          put "/:condition_id" => "pages/conditions#update", as: :update_condition
          get "/:condition_id/delete" => "pages/conditions#delete", as: :delete_condition
          delete "/:condition_id/delete" => "pages/conditions#destroy", as: :destroy_condition
        end

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
          get "/name-settings" => "pages/name_settings#edit", as: :name_settings_edit
          post "/name-settings" => "pages/name_settings#update", as: :name_settings_update
          get "/guidance" => "pages/guidance#edit", as: :guidance_edit
          post "/guidance" => "pages/guidance#update", as: :guidance_update
          get "/question" => "pages/questions#edit", as: :edit_question
          post "/question" => "pages/questions#update", as: :update_question
        end

        scope "/delete" do
          get "/" => "forms/delete_confirmation#delete", as: :delete_page
          delete "/" => "forms/delete_confirmation#destroy", as: :destroy_page
        end
      end
    end
  end

  resources :users, only: %i[index edit update]
  resource :user_upgrade_request, only: %i[new create], path_names: { new: "/" }, path: "/upgrade" do
    get "/requested", to: "user_upgrade_requests#confirmation", as: :confirmation
  end

  namespace :account do
    resource :name, only: %i[edit update]
    resource :organisation, only: %i[edit update]
  end

  resources :mou_signatures, only: %i[index], path: "mous"

  resource :mou_signature, only: %i[new show create], path: "/memorandum-of-understanding" do
    get "/signed", to: "mou_signatures#confirmation", as: :confirmation
  end

  resources :groups, except: :destroy do
    resources :forms, controller: :group_forms, only: %i[new create]
    resources :members, controller: :group_members, only: %i[index new create]
    member do
      get "upgrade", to: "groups#confirm_upgrade"
      post "upgrade", to: "groups#upgrade"
    end
  end

  resources :memberships, only: %i[destroy update]

  get "/maintenance" => "errors#maintenance", as: :maintenance_page
  match "/403", to: "errors#forbidden", as: :error_403, via: :all
  match "/404", to: "errors#not_found", as: :error_404, via: :all
  match "/500", to: "errors#internal_server_error", as: :error_500, via: :all
end
