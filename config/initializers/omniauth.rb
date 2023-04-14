# Configure OmniAuth authentication middleware
Rails.application.config.after_initialize do
  # swap out the OmniAuth::Builder installed by `gds-sso` gem
  Rails.application.config.app_middleware.swap ::OmniAuth::Builder, ::OmniAuth::Builder do
    logger.debug('custom OmniAuth middleware called')
    provider :gds, GDS::SSO::Config.oauth_id, GDS::SSO::Config.oauth_secret,
             client_options: {
               site: GDS::SSO::Config.oauth_root_url,
               authorize_url: "#{GDS::SSO::Config.oauth_root_url}/oauth/authorize",
               token_url: "#{GDS::SSO::Config.oauth_root_url}/oauth/access_token",
               connection_opts: {
                 headers: {
                   user_agent: "gds-sso/#{GDS::SSO::VERSION} (forms-admin)",
                 },
               },
             }
  end
end
