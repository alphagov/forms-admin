# Configure Warden authentication middleware
Rails.application.config.after_initialize do
  # swap out the Warden::Manager installed by `gds-sso` gem
  Rails.application.config.app_middleware.swap Warden::Manager, Warden::Manager do |warden|
    logger.debug('custom Warden middleware called')
    warden.default_strategies(*config.warden_default_strategies)
    warden.failure_app = GDS::SSO::FailureApp
  end
end
