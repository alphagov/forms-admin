# Configure Warden authentication middleware
Rails.application.config.after_initialize do
  # swap out the Warden::Manager installed by `gds-sso` gem
  Rails.application.config.app_middleware.swap Warden::Manager, Warden::Manager do |warden|
    logger.debug('custom Warden middleware called')
    warden_strategies = Settings.basic_auth.enabled ? %i[basic_auth] : config.warden_default_strategies
    warden.default_strategies(*warden_strategies)
    warden.failure_app = GDS::SSO::FailureApp
  end
end
