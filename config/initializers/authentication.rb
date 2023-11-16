require "warden"

OmniAuth.config.logger = Rails.logger

Warden::Manager.after_authentication do |user, _auth, _opts|
  # We've successfully signed in.
  # If they were remotely signed out, clear the flag as they're no longer suspended
  user.clear_remotely_signed_out!
end

Warden::Manager.serialize_into_session do |user|
  if user.respond_to?(:uid) && user.uid
    [user.uid, Time.zone.now.utc.iso8601]
  end
end

Warden::Manager.serialize_from_session do |(uid, auth_timestamp)|
  # This will reject old sessions that don't have a previous login timestamp
  if auth_timestamp.is_a?(String)
    begin
      auth_timestamp = Time.zone.parse(auth_timestamp)
    rescue ArgumentError
      auth_timestamp = nil
    end
  end

  if auth_timestamp && ((auth_timestamp + Settings.auth_valid_for) > Time.zone.now.utc)
    User.where(uid:, remotely_signed_out: false).first
  end
end

Rails.application.config.app_middleware.use Warden::Manager do |warden|
  warden.default_strategies(Settings.auth_provider.to_sym, :gds_bearer_token)
  warden.failure_app = AuthenticationController
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    Settings.auth0.client_id,
    Settings.auth0.client_secret,
    Settings.auth0.domain,
    callback_path: "/auth/auth0/callback",
    authorize_params: {
      scope: "openid email",
      connection: "email", # default to using the passwordless flow
    },
  )
end

OmniAuth.config.allowed_request_methods = %i[post get]
