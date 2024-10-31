Rails.application.config.before_initialize do
  # Configure OmniAuth authentication middleware
  # add Auth0 provider
  Rails.application.config.app_middleware.use(
    OmniAuth::Strategies::Auth0,
    setup: lambda do |env|
      is_e2e = env["omniauth.strategy"].request.params["auth"] == "e2e"

      # use the e2e client if the request has the auth header is set to "e2e"
      env["omniauth.strategy"].options[:client_id] = is_e2e ? Settings.auth0.e2e_client_id : Settings.auth0.client_id
      env["omniauth.strategy"].options[:client_secret] = is_e2e ? Settings.auth0.e2e_client_secret : Settings.auth0.client_secret
      env["omniauth.strategy"].options[:domain] = Settings.auth0.domain
      env["omniauth.strategy"].options[:authorize_params] = {
        scope: "openid email",
      }

      # append the auth query param in e2e tests to ensure the correct client is used in the callback
      env["omniauth.strategy"].options[:callback_path] = is_e2e ? "/auth/auth0/callback?auth=e2e" : "/auth/auth0/callback"
    end,
  )

  # add developer provider
  if Rails.env.development? || Rails.env.test?
    Rails.application.config.app_middleware.use(
      OmniAuth::Strategies::Developer,
      fields: [:email],
    )
  end

  # Configure Warden session management middleware
  # swap out the Warden::Manager installed by `gds-sso` gem
  Rails.application.config.app_middleware.swap Warden::Manager, Warden::Manager do |warden|
    warden.default_strategies(Settings.auth_provider.to_sym, :gds_bearer_token)
    warden.failure_app = AuthenticationController
  end

  GDS::SSO::Config.auth_valid_for = Settings.auth_valid_for
end

# Need to do this because Signon allows both GET and POST requests
OmniAuth.config.allowed_request_methods = %i[post]

# Silence the warning about extra tokens - we expect id and access_token from
# auth0 see https://gitlab.com/oauth-xx/oauth2/#global-configuration
OAuth2.configure do |config|
  config.silence_extra_tokens_warning = true
end

# store the auth0 connection used to login in the warden session
Warden::Manager.after_authentication do |user, auth, _opts|
  if user.provider == "auth0"
    auth.session["auth0_connection_strategy"] = auth.env["omniauth.auth"][:extra][:raw_info][:auth0_connection_strategy]
  end

  user.signed_in!
end
