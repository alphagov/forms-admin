Rails.application.config.before_initialize do
  # Configure OmniAuth authentication middleware
  # add Auth0 provider
  Rails.application.config.app_middleware.use(
    OmniAuth::Strategies::Auth0,
    Settings.auth0.client_id,
    Settings.auth0.client_secret,
    Settings.auth0.domain,
    callback_path: "/auth/auth0/callback",
    authorize_params: {
      scope: "openid email",
      connection: "email", # default to using the passwordless flow
    },
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
