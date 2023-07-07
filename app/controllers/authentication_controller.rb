class AuthenticationController < ApplicationController
  skip_before_action :authenticate_and_check_access

  layout false

  def self.call(env)
    action(:redirect_to_omniauth).call(env)
  end

  def redirect_to_omniauth
    store_location(attempted_path) if request.get?
    redirect_to "/auth/#{default_provider}"
  end

  def callback_from_omniauth
    authenticate_user!
    redirect_to stored_location || "/"
  end

  def sign_out
    # get current_user before user is logged out of warden
    auth_provider = current_user&.provider

    if user_signed_in
      warden.logout
      redirect_to send(:"#{auth_provider}_sign_out_url"), allow_other_host: true
    else
      redirect_to root_path
    end
  end

private

  def attempted_path
    request.env["warden.options"][:attempted_path]
  end

  def store_location(path)
    # NOTE: If we ever start using Warden scopes, the key of this session
    # variable should change depending on the scope in warden.options
    session["user_return_to"] = path
  end

  def stored_location
    session["user_return_to"]
  end

  def default_provider
    if Settings.auth_provider == "gds_sso"
      "gds"
    else
      Settings.auth_provider
    end
  end

  def auth0_sign_out_url
    request_params = {
      returnTo: root_url,
      client_id: Settings.auth0.client_id,
    }

    URI::HTTPS.build(host: Settings.auth0.domain, path: "/v2/logout", query: request_params.to_query).to_s
  end

  def cddo_sso_sign_out_url
    request_params = {
      from_app: Settings.cddo_sso.identifier,
    }

    URI::HTTPS.build(host: "sso.service.security.gov.uk", path: "/sign-out", query: request_params.to_query).to_s
  end

  def mock_gds_sso_sign_out_url
    "https://signon.integration.publishing.service.gov.uk/users/sign_out"
  end
end
