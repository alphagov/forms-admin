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
    },
  )

  # Configure Warden session management middleware
  # swap out the Warden::Manager installed by `gds-sso` gem
  Rails.application.config.app_middleware.swap Warden::Manager, Warden::Manager do |warden|
    warden.failure_app = AuthenticationController
  end
end
