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

  # add CDDO SSO provider
  Rails.application.config.app_middleware.use(
    OmniAuth::Strategies::OpenIDConnect,
    name: :cddo_sso,
    issuer: "https://sso.service.security.gov.uk",
    discovery: true,
    require_state: true,

    scope: %i[openid email profile],
    client_options: {
      identifier: Settings.cddo_sso.identifier,
      secret: Settings.cddo_sso.secret,
    },
  )

  # Configure Warden session management middleware
  # swap out the Warden::Manager installed by `gds-sso` gem
  Rails.application.config.app_middleware.swap Warden::Manager, Warden::Manager do |warden|
    warden.default_strategies(Settings.auth_provider.to_sym, :gds_bearer_token)
    warden.failure_app = AuthenticationController
  end
end
