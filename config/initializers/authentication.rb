Rails.application.config.before_initialize do
  # Configure Warden session management middleware
  # swap out the Warden::Manager installed by `gds-sso` gem
  Rails.application.config.app_middleware.swap Warden::Manager, Warden::Manager do |warden|
    warden.failure_app = AuthenticationController
  end
end
